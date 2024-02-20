local VORPcore = exports.vorp_core:GetCore()

RegisterServerEvent('bcc-guarma:BuyTicket', function(travel)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local buyPrice = travel.buyPrice
    local canCarry = exports.vorp_inventory:canCarryItem(src, 'boat_ticket', 1)
    if not canCarry then
        VORPcore.NotifyRightTip(src, _U('maxTickets'), 4000)
        return
    end
    if Character.money < buyPrice then
        VORPcore.NotifyRightTip(src, _U('shortCash'), 4000)
        return
    end
    Character.removeCurrency(0, buyPrice)
    exports.vorp_inventory:addItem(src, 'boat_ticket', 1)
    VORPcore.NotifyRightTip(src, _U('boughtTicket'), 4000)
end)

VORPcore.Callback.Register('bcc-guarma:CheckTicket', function(source, cb)
    local src = source
    local ticket = exports.vorp_inventory:getItem(src, 'boat_ticket')
    if not ticket then
        VORPcore.NotifyRightTip(src, _U('noTicket'), 4000)
        cb(false)
        return
    end
    exports.vorp_inventory:subItem(src, 'boat_ticket', 1)
    cb(true)
end)

VORPcore.Callback.Register('bcc-guarma:CheckJob', function(source, cb, port)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charJob = Character.job
    local jobGrade = Character.jobGrade
    if not charJob then
        cb(false)
        return
    end
    local hasJob = false
    hasJob = CheckPlayerJob(charJob, jobGrade, port)
    if not hasJob then
        VORPcore.NotifyRightTip(src, _U('needJob'), 4000)
        cb(false)
        return
    end
    cb(true)
end)

function CheckPlayerJob(charJob, jobGrade, port)
    for _, job in pairs(Config.shops[port].shop.jobs) do
        if (charJob == job.name) and (tonumber(jobGrade) >= tonumber(job.grade)) then
            return true
        end
    end
end
