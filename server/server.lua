local VORPcore = {}
local VORPInv = {}

TriggerEvent('getCore', function(core)
    VORPcore = core
end)
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

-- Check Ticket Qty on Player and Buy Ticket if Below Max
RegisterNetEvent('bcc-guarma:BuyTicket', function(data)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local buyPrice = data.buyPrice
    local canCarry = VORPInv.canCarryItem(src, 'boat_ticket', 1)
    if canCarry then
        if Character.money >= buyPrice then
            Character.removeCurrency(0, buyPrice)
            VORPInv.addItem(src, 'boat_ticket', 1)
            VORPcore.NotifyRightTip(src, _U('boughtTicket'), 4000)
        else
            VORPcore.NotifyRightTip(src, _U('shortCash'), 4000)
        end
    else
        VORPcore.NotifyRightTip(src, _U('maxTickets'), 4000)
    end
end)

-- If Player has Ticket, Take it and Send to Destination
RegisterNetEvent('bcc-guarma:TakeTicket', function(data)
    local src = source
    local ticket = VORPInv.getItem(src, 'boat_ticket')
    if ticket then
        VORPInv.subItem(src, 'boat_ticket', 1)
        TriggerClientEvent('bcc-guarma:SendPlayer', src, data.location)
    else
        VORPcore.NotifyRightTip(src, _U('noTicket'), 4000)
    end
end)

-- Check if Player has Required Job
VORPcore.addRpcCallback('CheckPlayerJob', function(source, cb, shop)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local playerJob = Character.job
    local jobGrade = Character.jobGrade

    if playerJob then
        for _, job in pairs(Config.shops[shop].allowedJobs) do
            if playerJob == job then
                if tonumber(jobGrade) >= tonumber(Config.shops[shop].jobGrade) then
                    cb(true)
                    return
                end
            end
        end
    end
    VORPcore.NotifyRightTip(src, _U('needJob'), 4000)
    cb(false)
end)
