local ClientRPC = exports.vorp_core:ClientRpcCall()
-- Prompts
local BuyPrompt
local TravelPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
-- Start Guarma
CreateThread(function()
    StartPrompts()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local sleep = true
        local hour = GetClockHours()

        if not IsEntityDead(playerPed) then
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
                        local distance = #(pCoords - portCfg.npc.coords)
                        if distance <= portCfg.shop.distance then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', portCfg.shop.name .. _U('hours') .. portCfg.shop.hours.open .. _U('to') .. portCfg.shop.hours.close .. _U('hundred'))
                            PromptSetActiveGroupThisFrame(PromptGroup, shopClosed)
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
                        if not next(portCfg.shop.jobs) then
                            local distance = #(pCoords - portCfg.npc.coords)
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
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(BuyPrompt, true)
                                PromptSetEnabled(TravelPrompt, true)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                    local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
                                    if canTravel then
                                        SendPlayer(portCfg.travel.location)
                                    end
                                end
                            end
                        else
                            -- Using Shop Hours - Shop Open - Job Locked
                            if Config.shops[port].Blip then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.job])) -- BlipAddModifier
                            end
                            local distance = #(pCoords - portCfg.npc.coords)
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
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(BuyPrompt, true)
                                PromptSetEnabled(TravelPrompt, true)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                    local hasJob = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', port)
                                    if hasJob then
                                        TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                    local hasJob = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', port)
                                    if hasJob then
                                        local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
                                        if canTravel then
                                            SendPlayer(portCfg.travel.location)
                                        end
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
                    if not next(portCfg.shop.jobs) then
                        local distance = #(pCoords - portCfg.npc.coords)
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
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(BuyPrompt, true)
                            PromptSetEnabled(TravelPrompt, true)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
                                    if canTravel then
                                        SendPlayer(portCfg.travel.location)
                                    end
                            end
                        end
                    else
                        -- Not Using Shop Hours - Shop Always Open - Job Locked
                        if Config.shops[port].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[port].Blip, joaat(Config.BlipColors[portCfg.blip.color.job])) -- BlipAddModifier
                        end
                        local distance = #(pCoords - portCfg.npc.coords)
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
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', portCfg.shop.prompt)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(BuyPrompt, true)
                            PromptSetEnabled(TravelPrompt, true)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- PromptHasStandardModeCompleted
                                local hasJob = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', port)
                                if hasJob then
                                    TriggerServerEvent('bcc-guarma:BuyTicket', portCfg.travel)
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- PromptHasStandardModeCompleted
                                local hasJob = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', port)
                                if hasJob then
                                    local canTravel = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckTicket')
                                    if canTravel then
                                        SendPlayer(portCfg.travel.location)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if sleep then
            Wait(1000)
        end
    end
end)

-- Send Player to Destination
function SendPlayer(location)
    local portCfg = Config.shops[location]
    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. portCfg.shop.name, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, PlayerPedId(), portCfg.player.coords, portCfg.player.heading) -- SetEntityCoordsAndHeading
    if location == 'guarma' then
        Citizen.InvokeNative(0x74E2261D2A66849A, true) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 1) -- SetWorldWaterType (1 = Guarma)
    else
        Citizen.InvokeNative(0x74E2261D2A66849A, false) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    end
    Wait(portCfg.travel.time * 1000)
    ShutdownLoadingScreen()
    while GetIsLoadingScreenActive() do
        Wait(1000)
    end
    DoScreenFadeIn(1500)
    Wait(1500)
    SetCinematicModeActive(false)
end

-- On Player Death: Reset Map and Water to Default if not Setting a Spawn Location in Guarma
RegisterCommand('resetWorld', function()
    DoScreenFadeOut(1000)
    Wait(1000)
    Citizen.InvokeNative(0x74E2261D2A66849A, false) -- SetGuarmaWorldhorizonActive
    Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
    Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    DoScreenFadeIn(1000)
    Wait(1000)
end)

function StartPrompts()
    local buyStr = CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt'))
    BuyPrompt = PromptRegisterBegin()
    PromptSetControlAction(BuyPrompt, Config.keys.buy)
    PromptSetText(BuyPrompt, buyStr)
    PromptSetVisible(BuyPrompt, true)
    PromptSetStandardMode(BuyPrompt, true)
    PromptSetGroup(BuyPrompt, PromptGroup)
    PromptRegisterEnd(BuyPrompt)

    local travelStr = CreateVarString(10, 'LITERAL_STRING', _U('travelPrompt'))
    TravelPrompt = PromptRegisterBegin()
    PromptSetControlAction(TravelPrompt, Config.keys.travel)
    PromptSetText(TravelPrompt, travelStr)
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
    LoadModel(portCfg.npc.model)
    portCfg.NPC = CreatePed(portCfg.npc.model, portCfg.npc.coords, portCfg.npc.heading, false, false, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, portCfg.NPC, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(portCfg.NPC, false)
    SetEntityInvincible(portCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(portCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(portCfg.NPC, true)
end

function LoadModel(model)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
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
