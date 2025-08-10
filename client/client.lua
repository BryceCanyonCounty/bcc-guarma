local Core = exports.vorp_core:GetCore()

local BuyPrompt
local TravelPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local HasJob = false
local GuarmaMode = false

local DevModeActive = Config.devMode
local function DebugPrint(message)
    if DevModeActive then
        print('^1[DEV MODE] ^4' .. message)
    end
end

local function StartPrompts()
    BuyPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(BuyPrompt, Config.keys.buy)
    UiPromptSetText(BuyPrompt, CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt')))
    UiPromptSetVisible(BuyPrompt, true)
    UiPromptSetStandardMode(BuyPrompt, true)
    UiPromptSetGroup(BuyPrompt, PromptGroup, 0)
    UiPromptRegisterEnd(BuyPrompt)

    TravelPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(TravelPrompt, Config.keys.travel)
    UiPromptSetText(TravelPrompt, CreateVarString(10, 'LITERAL_STRING', _U('travelPrompt')))
    UiPromptSetVisible(TravelPrompt, true)
    UiPromptSetStandardMode(TravelPrompt, true)
    UiPromptSetGroup(TravelPrompt, PromptGroup, 0)
    UiPromptRegisterEnd(TravelPrompt)
end

local function isShopClosed(shopCfg)
    local hour = GetClockHours()
    local hoursActive = shopCfg.shop.hours.active

    if not hoursActive then
        return false
    end

    local openHour = shopCfg.shop.hours.open
    local closeHour = shopCfg.shop.hours.close

    if openHour < closeHour then
        -- Normal: shop opens and closes on the same day
        return hour < openHour or hour >= closeHour
    else
        -- Overnight: shop closes on the next day
        return hour < openHour and hour >= closeHour
    end
end

local function ManageBlip(shop, closed)
    local shopCfg = Shops[shop]

    if (closed and not shopCfg.blip.show.closed) or (not shopCfg.blip.show.open) then
        if shopCfg.Blip then
            RemoveBlip(shopCfg.Blip)
            shopCfg.Blip = nil
        end
        return
    end

    if not shopCfg.Blip then
        shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(shopCfg.Blip, shopCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blip.name)               -- SetBlipName
    end

    local color = shopCfg.blip.color.open
    if shopCfg.shop.jobsEnabled then color = shopCfg.blip.color.job end
    if closed then color = shopCfg.blip.color.closed end

    if Config.BlipColors[color] then
        Citizen.InvokeNative(0x662D364ABF16DE2F, shopCfg.Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
    else
        print('Error: Blip color not defined for color: ' .. tostring(color))
    end
end

local function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end

    if not HasModelLoaded(model) then
        RequestModel(model, false)

        local timeout = 10000
        local startTime = GetGameTimer()

        while not HasModelLoaded(model) do
            if GetGameTimer() - startTime > timeout then
                print('Failed to load model:', modelName)
                return
            end
            Wait(10)
        end
    end
end

local function AddNPC(shop)
    local shopCfg = Shops[shop]
    local coords = shopCfg.npc.coords

    if not shopCfg.NPC then
        local modelName = shopCfg.npc.model
        local model = joaat(modelName)
        LoadModel(model, modelName)

        shopCfg.NPC = CreatePed(model, coords.x, coords.y, coords.z, shopCfg.npc.heading, false, false, false, false)
        Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation

        --TaskStartScenarioInPlace(shopCfg.NPC, "WORLD_HUMAN_SMOKING", -1, true)
        SetEntityCanBeDamaged(shopCfg.NPC, false)
        SetEntityInvincible(shopCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(shopCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)
    end
end

local function RemoveNPC(shop)
    local shopCfg = Shops[shop]

    if shopCfg.NPC then
        DeleteEntity(shopCfg.NPC)
        shopCfg.NPC = nil
    end
end

local function CheckPlayerJob(shop)
    HasJob = false
    HasJob = Core.Callback.TriggerAwait('bcc-guarma:CheckJob', shop) == true
end

CreateThread(function()
    StartPrompts()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        if IsEntityDead(playerPed) then
            Wait(1000)
            goto END
        end

        for shop, shopCfg in pairs(Shops) do
            local distance = #(playerCoords - shopCfg.npc.coords)
            local isClosed = isShopClosed(shopCfg)

            ManageBlip(shop, isClosed)

            if distance > shopCfg.npc.distance or isClosed then
                RemoveNPC(shop)
            elseif shopCfg.npc.active then
                AddNPC(shop)
            end

            local ticketCost = nil
            if distance <= (shopCfg.shop.distance + 5) then
                local currency = shopCfg.price.currency
                local amount = tostring(shopCfg.price.amount)
                local currencyFormats = {
                    [1] = '$' .. amount,
                    [2] = amount .. ' Gold',
                    [3] = shopCfg.price.item.label .. ' x ' .. amount
                }
                ticketCost = currencyFormats[currency]
            end

            if distance <= shopCfg.shop.distance then
                sleep = 0
                local promptText = isClosed and shopCfg.shop.name .. _U('hours') .. shopCfg.shop.hours.open .. _U('to') ..
                shopCfg.shop.hours.close .. _U('hundred') or shopCfg.shop.prompt

                UiPromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', promptText))
                UiPromptSetText(BuyPrompt, CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt') .. (ticketCost or '')))
                UiPromptSetEnabled(BuyPrompt, not isClosed)
                UiPromptSetEnabled(TravelPrompt, not isClosed)

                if not isClosed then
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                        if shopCfg.shop.jobsEnabled then
                            CheckPlayerJob(shop)
                            if not HasJob then goto END end
                        end
                        TriggerServerEvent('bcc-guarma:BuyTicket', shop)

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

local function SendPlayer(location)
    local shopCfg = Shops[location]
    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. shopCfg.shop.name, '', '')        -- DisplayLoadingScreens
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

function CheckPlayerTicket(shop)
    if Core.Callback.TriggerAwait('bcc-guarma:CheckTicket') == true then
        SendPlayer(Shops[shop].travel.location)
    end
end

local function IsInGuarma() -- Credit to kibook / redm-guarma
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	return x >= 0 and y <= -4096
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

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    ClearPedTasksImmediately(PlayerPedId())

    for _, shopCfg in pairs(Shops) do
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
