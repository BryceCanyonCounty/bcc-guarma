local Core = exports.vorp_core:GetCore()
---@type BCCGuarmaDebugLib
local DBG = BCCGuarmaDebug

local BuyPrompt
local TravelPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptStarted = false
local InMenu = false
local GuarmaMode = false

-- Create combined shops table once at script load
local AllShops = {}
for shop, shopCfg in pairs(Shops) do
    AllShops[shop] = shopCfg
end
AllShops['guarma'] = Guarma

-- Pre-calculate ticket costs at script load (static data)
local TicketCosts = {}
for shop, shopCfg in pairs(AllShops) do
    local currency = shopCfg.price.currency
    local amount = tostring(shopCfg.price.amount)

    if currency == 1 then
        TicketCosts[shop] = '$' .. amount
    elseif currency == 2 then
        TicketCosts[shop] = amount .. ' Gold'
    elseif currency == 3 then
        TicketCosts[shop] = shopCfg.price.item.label .. ' x ' .. amount
    else
        TicketCosts[shop] = amount -- fallback
    end
end

local function StartPrompts()
    if PromptStarted then
        DBG.Success('Prompts are already started')
        return
    end

    if not PromptGroup then
        DBG.Error('PromptGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.buy or not Config.keys.travel then
        DBG.Error('Prompt keys are not configured')
        return
    end

    BuyPrompt = UiPromptRegisterBegin()
    if not BuyPrompt or BuyPrompt == 0 then
        DBG.Error('Failed to register BuyPrompt')
        return
    end
    UiPromptSetControlAction(BuyPrompt, Config.keys.buy)
    UiPromptSetText(BuyPrompt, CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt')))
    UiPromptSetVisible(BuyPrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, BuyPrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(BuyPrompt, PromptGroup, 0)
    UiPromptRegisterEnd(BuyPrompt)

    TravelPrompt = UiPromptRegisterBegin()
    if not TravelPrompt or TravelPrompt == 0 then
        DBG.Error('Failed to register TravelPrompt')
        return
    end
    UiPromptSetControlAction(TravelPrompt, Config.keys.travel)
    UiPromptSetText(TravelPrompt, CreateVarString(10, 'LITERAL_STRING', _U('travelPrompt')))
    UiPromptSetVisible(TravelPrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, TravelPrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(TravelPrompt, PromptGroup, 0)
    UiPromptRegisterEnd(TravelPrompt)

    PromptStarted = true
    DBG.Success('Menu prompt started successfully')
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
    local shopCfg = shop == 'guarma' and Guarma or Shops[shop]

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
    -- Validate input
    if not model or not modelName then
        DBG.Error(('Invalid model or modelName for LoadModel: %s, %s'):format(tostring(model), tostring(modelName)))
        return false
    end

    -- Check if model is already loaded
    if HasModelLoaded(model) then
        DBG.Success(('Model already loaded: %s'):format(tostring(modelName)))
        return true
    end

    -- Check if model is valid
    if not IsModelValid(model) then
        DBG.Error(('Invalid model: %s'):format(tostring(modelName)))
        return false
    end

    -- Request model
    DBG.Info(('Requesting model: %s'):format(tostring(modelName)))
    RequestModel(model, false)

    -- Set timeout (5 seconds)
    local timeout = 5000
    local startTime = GetGameTimer()

    -- Wait for model to load
    while not HasModelLoaded(model) do
        -- Check for timeout
        if GetGameTimer() - startTime > timeout then
            DBG.Error(('Timeout while loading model: %s'):format(tostring(modelName)))
            return false
        end
        Wait(10)
    end

    DBG.Success(('Model loaded successfully: %s'):format(tostring(modelName)))
    return true
end

local function AddNPC(shop)
    -- Validate shop configuration
    if not shop then
        DBG.Error(('Invalid shop: %s'):format(tostring(shop)))
        return
    end

    local shopCfg = shop == 'guarma' and Guarma or Shops[shop]
    if not shopCfg or not shopCfg.npc then
        DBG.Error(('Invalid shop configuration for: %s'):format(tostring(shop)))
        return
    end

    -- Check if NPC already exists
    if shopCfg.NPC then
        return
    end

    -- Validate NPC coordinates and model
    local coords = shopCfg.npc.coords
    if not coords then
        DBG.Error(('Invalid NPC coordinates for shop: %s'):format(tostring(shop)))
        return
    end

    local modelName = shopCfg.npc.model
    if not modelName then
        DBG.Error(('Invalid NPC model for shop: %s'):format(tostring(shop)))
        return
    end

    -- Load model
    local model = joaat(modelName)
    if not LoadModel(model, modelName) then
        DBG.Error(('Failed to load NPC model for shop: %s'):format(tostring(shop)))
        return
    end

    -- Create NPC
    shopCfg.NPC = CreatePed(model, coords.x, coords.y, coords.z, shopCfg.npc.heading, false, false, false, false)

    if not shopCfg.NPC or not DoesEntityExist(shopCfg.NPC) then
        DBG.Error(('Failed to create NPC for shop: %s'):format(tostring(shop)))
        return
    end

    -- Configure the NPC
    Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation
    SetEntityCanBeDamaged(shopCfg.NPC, false)
    SetEntityInvincible(shopCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(shopCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)

    DBG.Success(('NPC created successfully for shop: %s'):format(tostring(shop)))
end

local function RemoveNPC(shop)
    -- Validate shop input
    if not shop then
        DBG.Error(('Invalid shop: %s'):format(tostring(shop)))
        return
    end

    local shopCfg = shop == 'guarma' and Guarma or Shops[shop]
    if not shopCfg then
        DBG.Error(('Shop configuration not found: %s'):format(tostring(shop)))
        return
    end

    -- Check if NPC exists
    if not shopCfg.NPC then
        return
    end

    -- Check if the entity exists before deletion
    if not DoesEntityExist(shopCfg.NPC) then
        DBG.Warning(('NPC entity does not exist for shop: %s'):format(tostring(shop)))
        shopCfg.NPC = nil -- Clean up reference
        return
    end

    -- Delete the NPC entity
    DeleteEntity(shopCfg.NPC)
    shopCfg.NPC = nil

    DBG.Info(('Successfully removed NPC for shop: %s'):format(tostring(shop)))
end

local function CheckPlayerTicket(shop)
    local shopCfg = Shops[shop]

    if not shopCfg then
        DBG.Error('Shop configuration not found for: ' .. tostring(shop))
        return
    end

    -- Single destination logic for non-Guarma shops
    if shopCfg.travel and shopCfg.travel.location then
        if Core.Callback.TriggerAwait('bcc-guarma:CheckTicket') == true then
            local targetShopCfg = shopCfg.travel.location == 'guarma' and Guarma or Shops[shopCfg.travel.location]
            local destination = {
                id = shopCfg.travel.location,
                name = targetShopCfg.shop.name,
                time = shopCfg.travel.time or 15
            }
            SendPlayerToLocation(destination)
        end
    else
        DBG.Error('Invalid travel configuration for shop: ' .. tostring(shop))
    end
end

CreateThread(function()
    StartPrompts()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        if InMenu or IsEntityDead(playerPed) then
            Wait(1000)
            goto END
        end

        for shop, shopCfg in pairs(AllShops) do
            local distance = #(playerCoords - shopCfg.npc.coords)
            local isClosed = isShopClosed(shopCfg)

            ManageBlip(shop, isClosed)

            if distance > shopCfg.npc.distance or isClosed then
                RemoveNPC(shop)
            elseif shopCfg.npc.active then
                AddNPC(shop)
            end

            if distance <= shopCfg.shop.distance then
                sleep = 0

                -- Set prompt text based on shop status
                local promptText
                if isClosed then
                    promptText = ('%s %s %d %s %d %s'):format(
                        shopCfg.shop.name,
                        _U('hours'),
                        shopCfg.shop.hours.open,
                        _U('to'),
                        shopCfg.shop.hours.close,
                        _U('hundred')
                    )
                elseif shop == 'guarma' then
                    -- Show Guarma name for Guarma location
                    promptText = shopCfg.shop.name
                else
                    promptText = shopCfg.shop.prompt
                end

                UiPromptSetActiveGroupThisFrame(PromptGroup, CreateVarString(10, 'LITERAL_STRING', promptText))
                UiPromptSetText(BuyPrompt, CreateVarString(10, 'LITERAL_STRING', _U('buyPrompt') .. TicketCosts[shop]))
                -- Set travel prompt text - different for Guarma
                local travelPromptText = shop == 'guarma' and _U('openTravelMenu') or _U('travelPrompt')
                UiPromptSetText(TravelPrompt, CreateVarString(10, 'LITERAL_STRING', travelPromptText))
                -- Enable/disable prompts based on shop status
                UiPromptSetEnabled(BuyPrompt, not isClosed)
                UiPromptSetEnabled(TravelPrompt, not isClosed)

                if not isClosed then
                    if Citizen.InvokeNative(0xE0F65F0640EF0617, BuyPrompt) then -- PromptHasHoldModeCompleted
                        Wait(500) -- Prevent multiple rapid purchases
                        if shopCfg.shop.jobsEnabled then
                            local hasJob = Core.Callback.TriggerAwait('bcc-guarma:CheckJob', shop) == true
                            if not hasJob then goto END end
                        end
                        TriggerServerEvent('bcc-guarma:BuyTicket', shop)

                    elseif Citizen.InvokeNative(0xE0F65F0640EF0617, TravelPrompt) then -- PromptHasHoldModeCompleted
                        Wait(500) -- Prevent multiple rapid travel initiations
                        if shopCfg.shop.jobsEnabled then
                            local hasJob = Core.Callback.TriggerAwait('bcc-guarma:CheckJob', shop) == true
                            if not hasJob then goto END end
                        end

                        -- Handle Guarma differently - open menu directly
                        if shop == 'guarma' then
                            OpenGuarmaMenu()
                        else
                            CheckPlayerTicket(shop)
                        end
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function SendPlayerToLocation(destination)
    -- Validate destination parameter
    if not destination or type(destination) ~= 'table' then
        DBG.Error('Invalid destination parameter for SendPlayerToLocation')
        return
    end

    if not destination.id or not destination.name then
        DBG.Error('Destination missing required fields (id, name)')
        return
    end
    -- Handle both regular shops and Guarma
    local shopCfg = destination.id == 'guarma' and Guarma or Shops[destination.id]

    DoScreenFadeOut(1500)
    Wait(1500)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, _U('traveling') .. destination.name, '', '')        -- DisplayLoadingScreens
    Citizen.InvokeNative(0x203BEFFDBE12E96A, PlayerPedId(), shopCfg.player.coords, shopCfg.player.heading) -- SetEntityCoordsAndHeading
    Wait(destination.time * 1000)
    ShutdownLoadingScreen()
    while GetIsLoadingScreenActive() do
        Wait(500)
    end
    DoScreenFadeIn(1500)
    Wait(1500)
    SetCinematicModeActive(false)
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

    -- Clean up all shops
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

    -- Clean up Guarma as well
    if Guarma.Blip then
        RemoveBlip(Guarma.Blip)
        Guarma.Blip = nil
    end

    if Guarma.NPC then
        DeleteEntity(Guarma.NPC)
        Guarma.NPC = nil
    end
end)
