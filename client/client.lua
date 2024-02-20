local ClientRPC = exports.vorp_core:ClientRpcCall()

local BuyPrompt
local TravelPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local HasJob = false
local GuarmaMode = false
-- Start Guarma
CreateThread(function()
    StartPrompts()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local hour = GetClockHours()

        if IsEntityDead(playerPed) then
            goto continue
        end
        for port, portCfg in pairs(Config.shops) do
            if portCfg.shop.hours.active then
                -- Using Shop Hours - Shop Closed
                if hour >= portCfg.shop.hours.close or hour < portCfg.shop.hours.open then
                    if portCfg.blip.show.closed then
                        if not Config.shops[port].Blip then
                            AddBlip(port)
                        end
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.closed])) -- BlipAddModifier
                    else
                        if Config.shops[port].Blip then
                            RemoveBlip(Config.shops[port].Blip)
                            Config.shops[port].Blip = nil
                        end
                    end
                    if portCfg.NPC then
                        DeleteEntity(portCfg.NPC)
                        portCfg.NPC = nil
                    end
                    local distance = #(playerCoords - portCfg.npc.coords)
                    if distance <= portCfg.shop.distance then
                        sleep = 0
                        PromptSetActiveGroupThisFrame(PromptGroup,
                        CreateVarString(10, 'LITERAL_STRING', portCfg.shop.name .. _U('hours') .. portCfg.shop.hours.open .. _U('to') .. portCfg.shop.hours.close .. _U('hundred')))
                        PromptSetEnabled(BuyPrompt, false)
                        PromptSetEnabled(TravelPrompt, false)
                    end
                elseif hour >= portCfg.shop.hours.open then
                    -- Using Shop Hours - Shop Open
                    if portCfg.blip.show.open then
                        if not Config.shops[port].Blip then
                            AddBlip(port)
                        end
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.open])) -- BlipAddModifier
                    end
                    if not portCfg.shop.jobsEnabled then
                        local distance = #(playerCoords - portCfg.npc.coords)
                        if portCfg.npc.active then
                            if distance <= portCfg.npc.distance then
                                if not portCfg.NPC then
                                    AddNPC(port)
                                end
                            else
                                if portCfg.NPC then
                                    DeleteEntity(portCfg.NPC)
                                    portCfg.NPC = nil
                                end
                            end
                        end
                        if distance <= portCfg.shop.distance then
                            sleep = 0
                            PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt))
                            PromptSetEnabled(BuyPrompt, true)
                            PromptSetEnabled(TravelPrompt, true)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                CheckPlayerTicket(port)
                            end
                        end
                    else
                        -- Using Shop Hours - Shop Open - Job Locked
                        if Config.shops[port].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.job])) -- BlipAddModifier
                        end
                        local distance = #(playerCoords - portCfg.npc.coords)
                        if portCfg.npc.active then
                            if distance <= portCfg.npc.distance then
                                if not portCfg.NPC then
                                    AddNPC(port)
                                end
                            else
                                if portCfg.NPC then
                                    DeleteEntity(portCfg.NPC)
                                    portCfg.NPC = nil
                                end
                            end
                        end
                        if distance <= portCfg.shop.distance then
                            sleep = 0
                            PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt))
                            PromptSetEnabled(BuyPrompt, true)
                            PromptSetEnabled(TravelPrompt, true)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                CheckPlayerJob(port)
                                if HasJob then
                                    TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                CheckPlayerJob(port)
                                if HasJob then
                                    CheckPlayerTicket(port)
                                end
                            end
                        end
                    end
                end
            else
                -- Not Using Shop Hours - Shop Always Open
                if portCfg.blip.show.open then
                    if not Config.shops[port].Blip then
                        AddBlip(port)
                    end
                    Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.open])) -- BlipAddModifier
                end
                if not portCfg.shop.jobsEnabled then
                    local distance = #(playerCoords - portCfg.npc.coords)
                    if portCfg.npc.active then
                        if distance <= portCfg.npc.distance then
                            if not portCfg.NPC then
                                AddNPC(port)
                            end
                        else
                            if portCfg.NPC then
                                DeleteEntity(portCfg.NPC)
                                portCfg.NPC = nil
                            end
                        end
                    end
                    if distance <= portCfg.shop.distance then
                        sleep = 0
                        PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt))
                        PromptSetEnabled(BuyPrompt, true)
                        PromptSetEnabled(TravelPrompt, true)

                        if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                            TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)

                        elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                            CheckPlayerTicket(port)
                        end
                    end
                else
                    -- Not Using Shop Hours - Shop Always Open - Job Locked
                    if Config.shops[port].Blip then
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.job])) -- BlipAddModifier
                    end
                    local distance = #(playerCoords - portCfg.npc.coords)
                    if portCfg.npc.active then
                        if distance <= portCfg.npc.distance then
                            if not portCfg.NPC then
                                AddNPC(port)
                            end
                        else
                            if portCfg.NPC then
                                DeleteEntity(portCfg.NPC)
                                portCfg.NPC = nil
                            end
                        end
                    end
                    if distance <= portCfg.shop.distance then
                        sleep = 0
                        PromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt))
                        PromptSetEnabled(BuyPrompt, true)
                        PromptSetEnabled(TravelPrompt, true)

                        if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                            CheckPlayerJob(port)
                            if HasJob then
                                TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)
                            end
                        elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                            CheckPlayerJob(port)
                            if HasJob then
                                CheckPlayerTicket(port)
                            end
                        end
                    end
                end
            end
        end
        ::continue::
        Wait(sleep)
    end
end)

function SendPlayer(location)
    local portCfg = Config.shops[location]
    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. portCfg.shop.name, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, PlayerPedId(), portCfg.player.coords, portCfg.player.heading) -- SetEntityCoordsAndHeading
    Wait(portCfg.travel.time * 1000)
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

function CheckPlayerJob(port)
    HasJob = false
    local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckJob', port)
    if result then
        HasJob = true
    end
end

function CheckPlayerTicket(port)
    local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
    if canTravel then
        SendPlayer(Config.shops[port].travel.location)
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

function AddBlip(port)
    local portCfg = Config.shops[port]
    portCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, portCfg.npc.coords) -- BlipAddForCoords
    SetBlipSprite(portCfg.Blip, portCfg.blip.sprite, true)
    SetBlipScale(portCfg.Blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, portCfg.Blip, portCfg.blip.name) -- SetBlipNameFromPlayerString
end

function AddNPC(port)
    local portCfg = Config.shops[port]
    local model = joaat(portCfg.npc.model)
    LoadModel(model)
    portCfg.NPC = CreatePed(model, portCfg.npc.coords, portCfg.npc.heading, false, false, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, portCfg.NPC, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(portCfg.NPC, false)
    SetEntityInvincible(portCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(portCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(portCfg.NPC, true)
end

function LoadModel(model)
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

    for _, portCfg in pairs(Config.shops) do
        if portCfg.Blip then
            RemoveBlip(portCfg.Blip)
            portCfg.Blip = nil
        end
        if portCfg.NPC then
            DeleteEntity(portCfg.NPC)
            portCfg.NPC = nil
        end
    end
end)
