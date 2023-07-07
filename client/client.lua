local VORPcore = {}
-- Prompts
local BuyPrompt
local TravelPrompt
local ClosedPrompt
local ActiveGroup = GetRandomIntInRange(0, 0xffffff)
local ClosedGroup = GetRandomIntInRange(0, 0xffffff)
-- Jobs
local PlayerJob
local JobGrade

TriggerEvent('getCore', function(core)
    VORPcore = core
end)

-- Start Guarma
CreateThread(function()
    Buy()
    Travel()
    Closed()

    while true do
        Wait(0)
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)
        local sleep = true
        local hour = GetClockHours()

        if not IsEntityDead(player) then
            for shop, shopCfg in pairs(Config.shops) do
                if shopCfg.shopHours then
                    -- Using Shop Hours - Shop Closed
                    if hour >= shopCfg.shopClose or hour < shopCfg.shopOpen then
                        if shopCfg.blipOn and Config.blipOnClosed then
                            if not Config.shops[shop].Blip then
                                AddBlip(shop)
                            end
                        else
                            if Config.shops[shop].Blip then
                                RemoveBlip(Config.shops[shop].Blip)
                                Config.shops[shop].Blip = nil
                            end
                        end
                        if Config.shops[shop].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipClosed])) -- BlipAddModifier
                        end
                        if shopCfg.NPC then
                            DeleteEntity(shopCfg.NPC)
                            shopCfg.NPC = nil
                        end
                        local sDist = #(pcoords - shopCfg.npc)
                        if sDist <= shopCfg.sDistance then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopCfg.shopName .. _U('closed'))
                            PromptSetActiveGroupThisFrame(ClosedGroup, shopClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, ClosedPrompt) then -- UiPromptHasStandardModeCompleted
                                Wait(100)
                                VORPcore.NotifyRightTip(shopCfg.shopName .. _U('hours') .. shopCfg.shopOpen .. _U('to') .. shopCfg.shopClose .. _U('hundred'), 4000)
                            end
                        end
                    elseif hour >= shopCfg.shopOpen then
                        -- Using Shop Hours - Shop Open
                        if shopCfg.blipOn and not Config.shops[shop].Blip then
                            AddBlip(shop)
                        end
                        if not next(shopCfg.allowedJobs) then
                            if Config.shops[shop].Blip then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                            end
                            local sDist = #(pcoords - shopCfg.npc)
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
                                PromptSetActiveGroupThisFrame(ActiveGroup, shopOpen)

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
                            local sDist = #(pcoords - shopCfg.npc)
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
                                PromptSetActiveGroupThisFrame(ActiveGroup, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopCfg.allowedJobs, PlayerJob) then
                                            if tonumber(shopCfg.jobGrade) <= tonumber(JobGrade) then
                                                TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)
                                            else
                                                VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                    end

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopCfg.allowedJobs, PlayerJob) then
                                            if tonumber(shopCfg.jobGrade) <= tonumber(JobGrade) then
                                                TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                                            else
                                                VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Not Using Shop Hours - Shop Always Open
                    if shopCfg.blipOn and not Config.shops[shop].Blip then
                        AddBlip(shop)
                    end
                    if not next(shopCfg.allowedJobs) then
                        if Config.shops[shop].Blip then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.shops[shop].Blip, joaat(Config.BlipColors[shopCfg.blipOpen])) -- BlipAddModifier
                        end
                        local sDist = #(pcoords - shopCfg.npc)
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
                            PromptSetActiveGroupThisFrame(ActiveGroup, shopOpen)

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
                        local sDist = #(pcoords - shopCfg.npc)
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
                            PromptSetActiveGroupThisFrame(ActiveGroup, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopCfg.allowedJobs, PlayerJob) then
                                        if tonumber(shopCfg.jobGrade) <= tonumber(JobGrade) then
                                            TriggerServerEvent('bcc-guarma:BuyTicket', shopCfg.tickets)
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                end

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopCfg.allowedJobs, PlayerJob) then
                                        if tonumber(shopCfg.jobGrade) <= tonumber(JobGrade) then
                                            TriggerServerEvent('bcc-guarma:TakeTicket', shopCfg.tickets)
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob'), 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U('needJob'), 5000)
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
    local player = PlayerPedId()
    local shopCfg = Config.shops[location]
    DoScreenFadeOut(1000)
    Wait(1000)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. shopCfg.shopName, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, player, shopCfg.player) -- SetEntityCoordsAndHeading
    FreezeEntityPosition(player, true)
    TaskStandStill(player, -1)
    if location == 'guarma' then
        Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 1) -- SetWorldWaterType (1 = Guarma)
        Citizen.InvokeNative(0x74E2261D2A66849A, 1) -- SetGuarmaWorldhorizonActive
    elseif location == 'stdenis' then
        Citizen.InvokeNative(0x74E2261D2A66849A, 0) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    end
    Wait(Config.travelTime * 1000)
    ShutdownLoadingScreen()
    FreezeEntityPosition(player, false)
    ClearPedTasksImmediately(player)
    DoScreenFadeIn(2000)
    Wait(1000)
    SetCinematicModeActive(false)
end)

-- Menu Prompts
function Buy()
    local str = _U('buyPrompt')
    BuyPrompt = PromptRegisterBegin()
    PromptSetControlAction(BuyPrompt, Config.keys.buy)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BuyPrompt, str)
    PromptSetEnabled(BuyPrompt, 1)
    PromptSetVisible(BuyPrompt, 1)
    PromptSetStandardMode(BuyPrompt, 1)
    PromptSetGroup(BuyPrompt, ActiveGroup)
    PromptRegisterEnd(BuyPrompt)
end

function Travel()
    local str = _U('travelPrompt')
    TravelPrompt = PromptRegisterBegin()
    PromptSetControlAction(TravelPrompt, Config.keys.travel)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(TravelPrompt, str)
    PromptSetEnabled(TravelPrompt, 1)
    PromptSetVisible(TravelPrompt, 1)
    PromptSetStandardMode(TravelPrompt, 1)
    PromptSetGroup(TravelPrompt, ActiveGroup)
    PromptRegisterEnd(TravelPrompt)
end

function Closed()
    local str = _U('closedPrompt')
    ClosedPrompt = PromptRegisterBegin()
    PromptSetControlAction(ClosedPrompt, Config.keys.buy)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ClosedPrompt, str)
    PromptSetEnabled(ClosedPrompt, 1)
    PromptSetVisible(ClosedPrompt, 1)
    PromptSetStandardMode(ClosedPrompt, 1)
    PromptSetGroup(ClosedPrompt, ClosedGroup)
    PromptRegisterEnd(ClosedPrompt)
end

-- Blips
function AddBlip(shop)
    local shopCfg = Config.shops[shop]
    shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc) -- BlipAddForCoords
    SetBlipSprite(shopCfg.Blip, shopCfg.blipSprite, 1)
    SetBlipScale(shopCfg.Blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blipName) -- SetBlipNameFromPlayerString
end

-- NPCs
function AddNPC(shop)
    local shopCfg = Config.shops[shop]
    LoadModel(shopCfg.npcModel)
    local npc = CreatePed(shopCfg.npcModel, shopCfg.npc, shopCfg.npcHeading, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.shops[shop].NPC = npc
end

function LoadModel(npcModel)
    local model = joaat(npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

-- Check if Player has Job
function CheckJob(allowedJob, playerJob)
    for _, jobAllowed in pairs(allowedJob) do
        if jobAllowed == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent('bcc-guarma:SendPlayerJob', function(Job, grade)
    PlayerJob = Job
    JobGrade = grade
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    local player = PlayerPedId()
    PromptDelete(BuyPrompt)
    PromptDelete(TravelPrompt)
    PromptDelete(ClosedPrompt)
    FreezeEntityPosition(player, false)
    ClearPedTasksImmediately(player)

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
