local VORPcore = {}
local VORPInv = {}

TriggerEvent('getCore', function(core)
    VORPcore = core
end)
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

-- Check Ticket Qty on Player and Buy Ticket if Below Max
RegisterNetEvent('bcc-guarma:BuyTicket', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local buyPrice = data.buyPrice
    local canCarry = VORPInv.canCarryItem(_source, 'boat_ticket', 1)
    if canCarry then
        if Character.money >= buyPrice then
            Character.removeCurrency(0, buyPrice)
            VORPInv.addItem(_source, 'boat_ticket', 1)
            VORPcore.NotifyRightTip(_source, _U('boughtTicket'), 4000)
        else
            VORPcore.NotifyRightTip(_source, _U('shortCash'), 4000)
        end
    else
        VORPcore.NotifyRightTip(_source, _U('maxTickets'), 4000)
    end
end)

-- If Player has Ticket, Take it and Send to Destination
RegisterNetEvent('bcc-guarma:TakeTicket', function(data)
    local _source = source
    local ticket = VORPInv.getItem(_source, 'boat_ticket')
    if ticket then
        VORPInv.subItem(_source, 'boat_ticket', 1)
        TriggerClientEvent('bcc-guarma:SendPlayer', _source, data.location)
    else
        VORPcore.NotifyRightTip(_source, _U('noTicket'), 4000)
    end
end)

-- Check Player Job and Job Grade
RegisterNetEvent('bcc-guarma:GetPlayerJob', function()
    local _source = source
    if _source then
        local Character = VORPcore.getUser(_source).getUsedCharacter
        local CharacterJob = Character.job
        local CharacterGrade = Character.jobGrade
        TriggerClientEvent('bcc-guarma:SendPlayerJob', _source, CharacterJob, CharacterGrade)
    end
end)
