local VORPcore = {}
-- Prompts
local BuyPrompt
local TravelPrompt
local ClosedPrompt
local ActiveGroup = GetRandomIntInRange(0, 0xffffff)
local ClosedGroup = GetRandomIntInRange(0, 0xffffff)
-- Jobs
local PlayerJob
local JobName
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
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if not dead then
            for portId, portConfig in pairs(Config.ports) do
                if portConfig.portHours then
                    -- Using Port Hours - Port Closed
                    if hour >= portConfig.portClose or hour < portConfig.portOpen then
                        if Config.blipAllowedClosed then
                            if not Config.ports[portId].BlipHandle and portConfig.blipAllowed then
                                AddBlip(portId)
                            end
                        else
                            if Config.ports[portId].BlipHandle then
                                RemoveBlip(Config.ports[portId].BlipHandle)
                                Config.ports[portId].BlipHandle = nil
                            end
                        end
                        if Config.ports[portId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.ports[portId].BlipHandle, joaat(portConfig.blipColorClosed)) -- BlipAddModifier
                        end
                        if portConfig.NPC then
                            DeleteEntity(portConfig.NPC)
                            DeletePed(portConfig.NPC)
                            SetEntityAsNoLongerNeeded(portConfig.NPC)
                            portConfig.NPC = nil
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsPort = vector3(portConfig.npc.x, portConfig.npc.y, portConfig.npc.z)
                        local distPort = #(coordsDist - coordsPort)

                        if (distPort <= portConfig.distPort) then
                            sleep = false
                            local portClosed = CreateVarString(10, 'LITERAL_STRING', portConfig.portName .. _U('closed'))
                            PromptSetActiveGroupThisFrame(ClosedGroup, portClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, ClosedPrompt) then -- UiPromptHasStandardModeCompleted
                                Wait(100)
                                VORPcore.NotifyRightTip(portConfig.portName .. _U('hours') .. portConfig.portOpen .. _U('to') .. portConfig.portClose .. _U('hundred'), 4000)
                            end
                        end
                    elseif hour >= portConfig.portOpen then
                        -- Using Port Hours - Port Open
                        if not Config.ports[portId].BlipHandle and portConfig.blipAllowed then
                            AddBlip(portId)
                        end
                        if not portConfig.NPC and portConfig.npcAllowed then
                            SpawnNPC(portId)
                        end
                        if not next(portConfig.allowedJobs) then
                            if Config.ports[portId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.ports[portId].BlipHandle, joaat(portConfig.blipColorOpen)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsPort = vector3(portConfig.npc.x, portConfig.npc.y, portConfig.npc.z)
                            local distPort = #(coordsDist - coordsPort)

                            if (distPort <= portConfig.distPort) then
                                sleep = false
                                local portActive = CreateVarString(10, 'LITERAL_STRING', portConfig.promptName)
                                PromptSetActiveGroupThisFrame(ActiveGroup, portActive)

                                local data = portConfig.tickets
                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:BuyTicket', data)

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:TakeTicket', data)
                                end
                            end
                        else
                            -- Using Port Hours - Port Open - Job Locked
                            if Config.ports[portId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.ports[portId].BlipHandle, joaat(portConfig.blipColorJob)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsPort = vector3(portConfig.npc.x, portConfig.npc.y, portConfig.npc.z)
                            local distPort = #(coordsDist - coordsPort)

                            if (distPort <= portConfig.distPort) then
                                sleep = false
                                local portActive = CreateVarString(10, 'LITERAL_STRING', portConfig.promptName)
                                PromptSetActiveGroupThisFrame(ActiveGroup, portActive)

                                local data = portConfig.tickets
                                if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(portConfig.allowedJobs, PlayerJob) then
                                            if tonumber(portConfig.jobGrade) <= tonumber(JobGrade) then
                                                TriggerServerEvent('bcc-guarma:BuyTicket', data)
                                            else
                                                VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                    end

                                elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                    TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(portConfig.allowedJobs, PlayerJob) then
                                            if tonumber(portConfig.jobGrade) <= tonumber(JobGrade) then
                                                TriggerServerEvent('bcc-guarma:TakeTicket', data)
                                            else
                                                VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Not Using Port Hours - Port Always Open
                    if not Config.ports[portId].BlipHandle and portConfig.blipAllowed then
                        AddBlip(portId)
                    end
                    if not portConfig.NPC and portConfig.npcAllowed then
                        SpawnNPC(portId)
                    end
                    if not next(portConfig.allowedJobs) then
                        if Config.ports[portId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.ports[portId].BlipHandle, joaat(portConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsPort = vector3(portConfig.npc.x, portConfig.npc.y, portConfig.npc.z)
                        local distPort = #(coordsDist - coordsPort)

                        if (distPort <= portConfig.distPort) then
                            sleep = false
                            local portActive = CreateVarString(10, 'LITERAL_STRING', portConfig.promptName)
                            PromptSetActiveGroupThisFrame(ActiveGroup, portActive)
                            local data = portConfig.tickets
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:BuyTicket', data)

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:TakeTicket', data)
                            end
                        end
                    else
                        -- Not Using Port Hours - Port Always Open - Job Locked
                        if Config.ports[portId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.ports[portId].BlipHandle, joaat(portConfig.blipColorJob)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsPort = vector3(portConfig.npc.x, portConfig.npc.y, portConfig.npc.z)
                        local distPort = #(coordsDist - coordsPort)

                        if (distPort <= portConfig.distPort) then
                            sleep = false
                            local portActive = CreateVarString(10, 'LITERAL_STRING', portConfig.promptName)
                            PromptSetActiveGroupThisFrame(ActiveGroup, portActive)

                            local data = portConfig.tickets
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, BuyPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(portConfig.allowedJobs, PlayerJob) then
                                        if tonumber(portConfig.jobGrade) <= tonumber(JobGrade) then
                                            TriggerServerEvent('bcc-guarma:BuyTicket', data)
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                end

                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, TravelPrompt) then -- UiPromptHasStandardModeCompleted
                                TriggerServerEvent('bcc-guarma:GetPlayerJob')
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(portConfig.allowedJobs, PlayerJob) then
                                        if tonumber(portConfig.jobGrade) <= tonumber(JobGrade) then
                                            TriggerServerEvent('bcc-guarma:TakeTicket', data)
                                        else
                                            VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U('needJob') .. JobName .. " " .. portConfig.jobGrade, 5000)
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
RegisterNetEvent('bcc-guarma:SendPlayer')
AddEventHandler('bcc-guarma:SendPlayer', function(location)
    local player = PlayerPedId()
    local destination = location
    local portConfig = Config.ports[destination]
    DoScreenFadeOut(1000)
    Wait(1000)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. portConfig.portName, '', '') -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, player, portConfig.player.x, portConfig.player.y, portConfig.player.z, portConfig.player.h) -- SetEntityCoordsAndHeading
    if destination == 'guarma' then
        Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 1) -- SetWorldWaterType (1 = Guarma)
        Citizen.InvokeNative(0x74E2261D2A66849A, 1) -- SetGuarmaWorldhorizonActive
    elseif destination == 'stdenis' then
        Citizen.InvokeNative(0x74E2261D2A66849A, 0) -- SetGuarmaWorldhorizonActive
        Citizen.InvokeNative(0xA657EC9DBC6CC900, -1868977180) -- SetMinimapZone
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 0) -- SetWorldWaterType (0 = World)
    end
    Wait(Config.travelTime)
    ShutdownLoadingScreen()
    DoScreenFadeIn(1000)
    Wait(1000)
    SetCinematicModeActive(false)
end)

-- Menu Prompts
function Buy()
    local str = _U('buyPrompt')
    BuyPrompt = PromptRegisterBegin()
    PromptSetControlAction(BuyPrompt, Config.buyKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BuyPrompt, str)
    PromptSetEnabled(BuyPrompt, 1)
    PromptSetVisible(BuyPrompt, 1)
    PromptSetStandardMode(BuyPrompt, 1)
    PromptSetGroup(BuyPrompt, ActiveGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, BuyPrompt, true)
    PromptRegisterEnd(BuyPrompt)
end

function Travel()
    local str = _U('travelPrompt')
    TravelPrompt = PromptRegisterBegin()
    PromptSetControlAction(TravelPrompt, Config.travelKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(TravelPrompt, str)
    PromptSetEnabled(TravelPrompt, 1)
    PromptSetVisible(TravelPrompt, 1)
    PromptSetStandardMode(TravelPrompt, 1)
    PromptSetGroup(TravelPrompt, ActiveGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, TravelPrompt, true)
    PromptRegisterEnd(TravelPrompt)
end

function Closed()
    local str = _U('closedPrompt')
    ClosedPrompt = PromptRegisterBegin()
    PromptSetControlAction(ClosedPrompt, Config.buyKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ClosedPrompt, str)
    PromptSetEnabled(ClosedPrompt, 1)
    PromptSetVisible(ClosedPrompt, 1)
    PromptSetStandardMode(ClosedPrompt, 1)
    PromptSetGroup(ClosedPrompt, ClosedGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, ClosedPrompt, true)
    PromptRegisterEnd(ClosedPrompt)
end

-- Blips
function AddBlip(portId)
    local portConfig = Config.ports[portId]
    portConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, portConfig.npc.x, portConfig.npc.y, portConfig.npc.z) -- BlipAddForCoords
    SetBlipSprite(portConfig.BlipHandle, portConfig.blipSprite, 1)
    SetBlipScale(portConfig.BlipHandle, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, portConfig.BlipHandle, portConfig.blipName) -- SetBlipNameFromPlayerString
end

-- NPCs
function SpawnNPC(portId)
    local portConfig = Config.ports[portId]
    LoadModel(portConfig.npcModel)
    local npc = CreatePed(portConfig.npcModel, portConfig.npc.x, portConfig.npc.y, portConfig.npc.z, portConfig.npc.h, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.ports[portId].NPC = npc
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
        JobName = jobAllowed
        if JobName == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent('bcc-guarma:SendPlayerJob')
AddEventHandler('bcc-guarma:SendPlayerJob', function(Job, grade)
    PlayerJob = Job
    JobGrade = grade
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    PromptDelete(BuyPrompt)
    PromptDelete(TravelPrompt)
    PromptDelete(ClosedPrompt)
    ClearPedTasksImmediately(PlayerPedId())

    for _, portConfig in pairs(Config.ports) do
        if portConfig.BlipHandle then
            RemoveBlip(portConfig.BlipHandle)
        end
        if portConfig.NPC then
            DeleteEntity(portConfig.NPC)
            DeletePed(portConfig.NPC)
            SetEntityAsNoLongerNeeded(portConfig.NPC)
        end
    end
end)
