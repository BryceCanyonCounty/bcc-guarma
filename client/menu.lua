local Core = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()
---@type BCCGuarmaDebugLib
local DBG = BCCGuarmaDebug

-- Function to format time from seconds to minutes and seconds
local function FormatTravelTime(seconds)
    if seconds > 59 then
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        if remainingSeconds == 0 then
            return string.format('%d %s', minutes, minutes == 1 and _U('minute') or _U('minutes'))
        else
            return string.format('%d %s %d %s', 
                minutes, minutes == 1 and _U('minute') or _U('minutes'),
                remainingSeconds, remainingSeconds == 1 and _U('second') or _U('seconds')
            )
        end
    else
        return string.format('%d %s', seconds, seconds == 1 and _U('second') or _U('seconds'))
    end
end

function GetAvailableDestinations()
    DBG.Info('Getting available destinations from Guarma')
    local destinations = {}
    -- These become available destinations FROM Guarma
    for shop, shopCfg in pairs(Shops) do
        if shop ~= 'guarma' and shopCfg.travel and shopCfg.travel.location == 'guarma' then
            local travelTime = shopCfg.travel.time or 15 -- Default fallback

            table.insert(destinations, {
                id = shop,
                name = shopCfg.shop.name,
                time = travelTime
            })
        end
    end

    -- Sort destinations alphabetically for consistent display
    table.sort(destinations, function(a, b)
        return a.name < b.name
    end)

    DBG.Info(string.format('Found %d available destinations', #destinations))
    return destinations
end

local GuarmaMenu = FeatherMenu:RegisterMenu('bcc-guarma:travel-menu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '250px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
        canclose = true
    }, {
        opened = function()
            InMenu = true
            DisplayRadar(false)
        end,
        closed = function()
            InMenu = false
            DisplayRadar(true)
        end
    })

-----------------------------------------------------
-- Main Page
-----------------------------------------------------
function OpenGuarmaMenu()
    DBG.Info('Creating Guarma travel menu')
    -- Main page with destination list
    local mainPage = GuarmaMenu:RegisterPage('main')
    mainPage:RegisterElement('header', {
        value = Guarma.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    mainPage:RegisterElement('subheader', {
        value = _U('travelMenuTitle'),
        slot = 'header',
        style = {
            ['color'] = '#CC9900',
            ['font-size'] = '1.0vw'
        }
    })

    mainPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    -- Add destination options - automatically from shops config
    local destinations = GetAvailableDestinations()
    for _, destination in ipairs(destinations) do
        mainPage:RegisterElement('button', {
            label = destination.name,
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            }
        }, function()
            DBG.Info(string.format('User selected destination: %s', destination.name))
            OpenDestinationPage(destination)
        end)
    end

    mainPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    mainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    mainPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DBG.Info('User closed Guarma travel menu')
        GuarmaMenu:Close()
    end)

    mainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    GuarmaMenu:Open({
        startupPage = mainPage
    })
end

-----------------------------------------------------
-- Destination Page  
-----------------------------------------------------
function OpenDestinationPage(destination)
    DBG.Info(string.format('Opening destination page for: %s', destination.name))
    local destinationPage = GuarmaMenu:RegisterPage('destination:page')

    destinationPage:RegisterElement('header', {
        value = Guarma.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    destinationPage:RegisterElement('subheader', {
        value = destination.name,
        slot = 'header',
        style = {
            ['color'] = '#CC9900',
            ['font-size'] = '1.0vw'
        }
    })

    destinationPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    -- Travel time information
    destinationPage:RegisterElement('textdisplay', {
        value = _U('travelTime') .. ': ' .. FormatTravelTime(destination.time),
        slot = 'content',
        style = {
            ['color'] = '#C0C0C0',
        }
    })

    destinationPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    -- Board ship button
    destinationPage:RegisterElement('button', {
        label = _U('travelPrompt'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DBG.Info(string.format('User initiated travel to: %s', destination.name))
        -- Consume ticket before travel
        local hasTicket = Core.Callback.TriggerAwait('bcc-guarma:CheckTicket')
        if hasTicket then
            GuarmaMenu:Close()
            SendPlayerToLocation(destination)
        else
            -- Ticket was consumed or user doesn't have one, close menu
            GuarmaMenu:Close()
        end
    end)

    -- Back button
    destinationPage:RegisterElement('button', {
        label = _U('goBack'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DBG.Info('User navigated back to main menu')
        OpenGuarmaMenu()
    end)

    destinationPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    GuarmaMenu:Open({
        startupPage = destinationPage
    })
end
