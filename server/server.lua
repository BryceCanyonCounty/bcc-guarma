local Core = exports.vorp_core:GetCore()

RegisterServerEvent('bcc-guarma:BuyTicket', function(travel)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    local character = user.getUsedCharacter
    local buyPrice = travel.buyPrice
    local canCarry = exports.vorp_inventory:canCarryItem(src, 'boat_ticket', 1)
    if not canCarry then
        Core.NotifyRightTip(src, _U('maxTickets'), 4000)
        return
    end
    if character.money < buyPrice then
        Core.NotifyRightTip(src, _U('shortCash'), 4000)
        return
    end
    character.removeCurrency(0, buyPrice)
    exports.vorp_inventory:addItem(src, 'boat_ticket', 1)
    Core.NotifyRightTip(src, _U('boughtTicket'), 4000)
end)

Core.Callback.Register('bcc-guarma:CheckTicket', function(source, cb)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local ticket = exports.vorp_inventory:getItem(src, 'boat_ticket')
    if not ticket then
        Core.NotifyRightTip(src, _U('noTicket'), 4000)
        cb(false)
        return
    end
    exports.vorp_inventory:subItem(src, 'boat_ticket', 1)
    cb(true)
end)

Core.Callback.Register('bcc-guarma:CheckJob', function(source, cb, shop)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local Character = user.getUsedCharacter
    local charJob = Character.job
    local jobGrade = Character.jobGrade
    if not charJob then
        cb(false)
        return
    end
    local hasJob = false
    hasJob = CheckPlayerJob(charJob, jobGrade, shop)
    if not hasJob then
        Core.NotifyRightTip(src, _U('needJob'), 4000)
        cb(false)
        return
    end
    cb(true)
end)

function CheckPlayerJob(charJob, jobGrade, shop)
    for _, job in pairs(Config.shops[shop].shop.jobs) do
        if (charJob == job.name) and (tonumber(jobGrade) >= tonumber(job.grade)) then
            return true
        end
    end
end
