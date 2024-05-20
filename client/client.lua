local ClientRPC = exports.vorp_core:ClientRpcCall()

local BuyPrompt
local TravelPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local HasJob = false
local GuarmaMode = false

CreateThread(function()
    StartPrompts()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local hour = GetClockHours()

        if IsEntityDead(playerPed) then goto END end

        for shop, shopCfg in pairs(Config.shops) do
            local distance = #(playerCoords - shopCfg.npc.coords)

            -- Shop Closed
            if (shopCfg.shop.hours.active and hour >= shopCfg.shop.hours.close) or (shopCfg.shop.hours.active and hour < shopCfg.shop.hours.open) then
                if shopCfg.blip.show then
                    ManageBlip(shop, true)
                end
                RemoveNPC(shop)
                if distance <= shopCfg.shop.distance then
                    sleep = 0
                    PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', shopCfg.shop.name .. _U('hours') ..
                    shopCfg.shop.hours.open .. _U('to') .. shopCfg.shop.hours.close .. _U('hundred')))
                    PromptSetEnabled(BuyPrompt, false)
                    PromptSetEnabled(TravelPrompt, false)
                end

            -- Shop Open
            else
                if shopCfg.blip.show then
                    ManageBlip(shop, false)
                end
                if distance <= shopCfg.npc.distance then
                    if shopCfg.npc.active then
                        AddNPC(shop)
                    end
                else
                    RemoveNPC(shop)
                end
                if distance <= shopCfg.shop.distance then
                    sleep = 0
                    PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', shopCfg.shop.prompt))
                    PromptSetEnabled(BuyPrompt, true)
                    PromptSetEnabled(TravelPrompt, true)

                    if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                        if shopCfg.shop.jobsEnabled then
                            CheckPlayerJob(shop)
                            if not HasJob then goto END end
                        end
                        TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.travel)

                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                        if shopCfg.shop.jobsEnabled then
                            CheckPlayerJob(shop)
                            if not HasJob then goto END end
                        end
                        CheckPlayerTicket(shop)
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function SendPlayer(location)
    local shopCfg = Config.shops[location]
    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. shopCfg.shop.name, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, PlayerPedId(), shopCfg.player.coords, shopCfg.player.heading) -- SetEntityCoordsAndHeading
    Wait(shopCfg.travel.time * 1000)
    ShutdownLoadingScreen()
    while GetIsLoadingScreenActive() do
        Wait(500)
    end
    DoScreenFadeIn(1500)
    Wait(1500)
    SetCinematicModeActive(false)
end

CreateThread(function() -- Credit to kibook / redm-guarma
	while true do
		Wait(1000)
		if IsInGuarma() then
			if not GuarmaMode then
                Citizen.InvokeNative(0x74E2261D2A66849A , true)         -- SetGuarmaWorldhorizonActive
                Citizen.InvokeNative(0xE8770EE02AEE45C2, 1)             -- SetWorldWaterType (1 = Guarma)
                Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277)    -- SetMinimapZone
				GuarmaMode = true
			end
		else
			if GuarmaMode then
                Citizen.InvokeNative(0x74E2261D2A66849A , false)        -- SetGuarmaWorldhorizonActive
                Citizen.InvokeNative(0xE8770EE02AEE45C2, 0)             -- SetWorldWaterType (0 = World)
                Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180)   -- SetMinimapZone
				GuarmaMode = false
			end
		end
	end
end)

function IsInGuarma() -- Credit to kibook / redm-guarma
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	return x >= 0 and y <= -4096
end

function CheckPlayerJob(shop)
    HasJob = false
    local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckJob', shop)
    if result then
        HasJob = true
    end
end

function CheckPlayerTicket(shop)
    local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
    if canTravel then
        SendPlayer(Config.shops[shop].travel.location)
    end
end

function StartPrompts()
    BuyPrompt = PromptRegisterBegin()
    PromptSetControlAction(BuyPrompt, Config.keys.buy)
    PromptSetText(BuyPrompt, CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt')))
    PromptSetVisible(BuyPrompt, true)
    PromptSetStandardMode(BuyPrompt, true)
    PromptSetGroup(BuyPrompt, PromptGroup)
    PromptRegisterEnd(BuyPrompt)

    TravelPrompt = PromptRegisterBegin()
    PromptSetControlAction(TravelPrompt, Config.keys.travel)
    PromptSetText(TravelPrompt, CreateVarString(10, 'LITERAL_STRING', _U('travelPrompt')))
    PromptSetVisible(TravelPrompt, true)
    PromptSetStandardMode(TravelPrompt, true)
    PromptSetGroup(TravelPrompt, PromptGroup)
    PromptRegisterEnd(TravelPrompt)
end

function ManageBlip(shop, closed)
    local shopCfg = Config.shops[shop]

    if closed and not shopCfg.blip.show.closed then
        if Config.shops[shop].Blip then
            RemoveBlip(Config.shops[shop].Blip)
            Config.shops[shop].Blip = nil
        end
        return
    end

    if not Config.shops[shop].Blip then
        shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(shopCfg.Blip, shopCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blip.name) -- SetBlipNameFromPlayerString
    end

    local color = shopCfg.blip.color.open
    if shopCfg.shop.jobsEnabled then color = shopCfg.blip.color.job end
    if closed then color = shopCfg.blip.color.closed end
    Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
end

function AddNPC(shop)
    local shopCfg = Config.shops[shop]
    if not shopCfg.NPC then
        local modelName = shopCfg.npc.model
        local model = joaat(modelName)
        LoadModel(model, modelName)
        shopCfg.NPC = CreatePed(model, shopCfg.npc.coords, shopCfg.npc.heading, false, false, false, false)
        Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation
        SetEntityCanBeDamaged(shopCfg.NPC, false)
        SetEntityInvincible(shopCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(shopCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)
    end
end

function RemoveNPC(shop)
    local shopCfg = Config.shops[shop]
    if shopCfg.NPC then
        DeleteEntity(shopCfg.NPC)
        shopCfg.NPC = nil
    end
end

function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    ClearPedTasksImmediately(PlayerPedId())

    for _, shopCfg in pairs(Config.shops) do
        if shopCfg.Blip then
            RemoveBlip(shopCfg.Blip)
            shopCfg.Blip = nil
        end
        if shopCfg.NPC then
            DeleteEntity(shopCfg.NPC)
            shopCfg.NPC = nil
        end
    end
end)
