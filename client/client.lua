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
            for shop, shopCfg in pairs(Config.shops) do
                if shopCfg.shopHours then
                    -- Using Shop Hours - Shop Closed
                    if hour >= shopCfg.shopClose or hour < shopCfg.shopOpen then
                        if shopCfg.blipOn and Config.blipOnClosed then
                            if not Config.shops[shop].Blip then
                                AddBlip(shop)
                            end
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipClosed])) -- BlipAddModifier
                        else
                            if Config.shops[shop].Blip then
                                RemoveBlip(Config.shops[shop].Blip)
                                Config.shops[shop].Blip = nil
                            end
                        end
                        if shopCfg.NPC then
                            DeleteEntity(shopCfg.NPC)
                            shopCfg.NPC = nil
                        end
                        local sDist = #(pCoords - shopCfg.npcPos)
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopCfg.shopName .. _U('hours') .. shopCfg.shopOpen .. _U('to') .. shopCfg.shopClose .. _U('hundred'))
                            PromptSetActiveGroupThisFrame(PromptGroup, shopClosed)
                            PromptSetEnabled(BuyPrompt, 0)
                            PromptSetEnabled(TravelPrompt, 0)
                        end
                    elseif hour >= shopCfg.shopOpen then
                        -- Using Shop Hours - Shop Open
                        if shopCfg.blipOn and not Config.shops[shop].Blip then
                            AddBlip(shop)
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                        end
                        if not next(shopCfg.allowedJobs) then
                            local sDist = #(pCoords - shopCfg.npcPos)
                            if shopCfg.npcOn then
                                if sDist <= shopCfg.nDistance then
                                    if not shopCfg.NPC then
                                        AddNPC(shop)
                                    end
                                else
                                    if shopCfg.NPC then
                                        DeleteEntity(shopCfg.NPC)
                                        shopCfg.NPC = nil
                                    end
                                end
                            end
                            if sDist <= shopCfg.sDistance then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(BuyPrompt, 1)
                                PromptSetEnabled(TravelPrompt, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                                end
                            end
                        else
                            -- Using Shop Hours - Shop Open - Job Locked
                            if Config.shops[shop].Blip then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
                            end
                            local sDist = #(pCoords - shopCfg.npcPos)
                            if shopCfg.npcOn then
                                if sDist <= shopCfg.nDistance then
                                    if not shopCfg.NPC then
                                        AddNPC(shop)
                                    end
                                else
                                    if shopCfg.NPC then
                                        DeleteEntity(shopCfg.NPC)
                                        shopCfg.NPC = nil
                                    end
                                end
                            end
                            if sDist <= shopCfg.sDistance then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                                PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                                PromptSetEnabled(BuyPrompt, 1)
                                PromptSetEnabled(TravelPrompt, 1)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                    local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', shop)
                                    if result then
                                        TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)
                                    else
                                        return
                                    end
                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                    local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', shop)
                                    if result then
                                        TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                                    else
                                        return
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Not Using Shop Hours - Shop Always Open
                    if shopCfg.blipOn and not Config.shops[shop].Blip then
                        AddBlip(shop)
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                    end
                    if not next(shopCfg.allowedJobs) then
                        local sDist = #(pCoords - shopCfg.npcPos)
                        if shopCfg.npcOn then
                            if sDist <= shopCfg.nDistance then
                                if not shopCfg.NPC then
                                    AddNPC(shop)
                                end
                            else
                                if shopCfg.NPC then
                                    DeleteEntity(shopCfg.NPC)
                                    shopCfg.NPC = nil
                                end
                            end
                        end
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(BuyPrompt, 1)
                            PromptSetEnabled(TravelPrompt, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                            end
                        end
                    else
                        -- Not Using Shop Hours - Shop Always Open - Job Locked
                        if Config.shops[shop].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipJob])) -- BlipAddModifier
                        end
                        local sDist = #(pCoords - shopCfg.npcPos)
                        if shopCfg.npcOn then
                            if sDist <= shopCfg.nDistance then
                                if not shopCfg.NPC then
                                    AddNPC(shop)
                                end
                            else
                                if shopCfg.NPC then
                                    DeleteEntity(shopCfg.NPC)
                                    shopCfg.NPC = nil
                                end
                            end
                        end
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopCfg.promptName)
                            PromptSetActiveGroupThisFrame(PromptGroup, shopOpen)
                            PromptSetEnabled(BuyPrompt, 1)
                            PromptSetEnabled(TravelPrompt, 1)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', shop)
                                if result then
                                    TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)
                                else
                                    return
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                local result = ClientRPC.Callback.TriggerAwait('bcc-guarma:CheckPlayerJob', shop)
                                if result then
                                    TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                                else
                                    return
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
RegisterNetEvent('bcc-guarma:SendPlayer', function(location)
    local shopCfg = Config.shops[location]
    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. shopCfg.shopName, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, PlayerPedId(), shopCfg.playerPos.x, shopCfg.playerPos.y, shopCfg.playerPos.z, shopCfg.playerHeading) -- SetEntityCoordsAndHeading
    if location == 'guarma' then
        Citizen.InvokeNative(0x74E2261D2A66849A, 1) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 1) -- SetWorldWaterType (1 = Guarma)
    elseif location == 'stdenis' then
        Citizen.InvokeNative(0x74E2261D2A66849A, 0) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    end
    Wait(Config.travelTime * 1000)
    ShutdownLoadingScreen()
    while GetIsLoadingScreenActive() do
        Wait(1000)
    end
    DoScreenFadeIn(1500)
    Wait(1500)
    SetCinematicModeActive(false)
end)

-- Use to Reset Map and Water to Default if not Setting a Spawn Location in Guarma
RegisterCommand('resetWorld', function()
    ResetWorld()
end)

function ResetWorld()
    DoScreenFadeOut(1000)
    Wait(1000)
    Citizen.InvokeNative(0x74E2261D2A66849A, 0) -- SetGuarmaWorldhorizonActive
    Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
    Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    DoScreenFadeIn(1000)
    Wait(1000)
end

-- Menu Prompts
function StartPrompts()
    local buyStr = CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt'))
    BuyPrompt = PromptRegisterBegin()
    PromptSetControlAction(BuyPrompt, Config.keys.buy)
    PromptSetText(BuyPrompt, buyStr)
    PromptSetVisible(BuyPrompt, 1)
    PromptSetStandardMode(BuyPrompt, 1)
    PromptSetGroup(BuyPrompt, PromptGroup)
    PromptRegisterEnd(BuyPrompt)

    local travelStr = CreateVarString(10, 'LITERAL_STRING', _U('travelPrompt'))
    TravelPrompt = PromptRegisterBegin()
    PromptSetControlAction(TravelPrompt, Config.keys.travel)
    PromptSetText(TravelPrompt, travelStr)
    PromptSetVisible(TravelPrompt, 1)
    PromptSetStandardMode(TravelPrompt, 1)
    PromptSetGroup(TravelPrompt, PromptGroup)
    PromptRegisterEnd(TravelPrompt)
end

-- Blips
function AddBlip(shop)
    local shopCfg = Config.shops[shop]
    shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npcPos) -- BlipAddForCoords
    SetBlipSprite(shopCfg.Blip, shopCfg.blipSprite, true)
    SetBlipScale(shopCfg.Blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blipName) -- SetBlipNameFromPlayerString
end

-- NPCs
function AddNPC(shop)
    local shopCfg = Config.shops[shop]
    LoadModel(shopCfg.npcModel)
    shopCfg.NPC = CreatePed(shopCfg.npcModel, shopCfg.npcPos.x, shopCfg.npcPos.y, shopCfg.npcPos.z, shopCfg.npcHeading, false, false, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(shopCfg.NPC, false)
    SetEntityInvincible(shopCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(shopCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)
end

function LoadModel(npcModel)
    local model = joaat(npcModel)
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
