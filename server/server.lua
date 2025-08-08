local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()

local DevModeActive = Config.devMode.active

local function DebugPrint(message)
    if DevModeActive then
        print('^1[DEV MODE] ^4' .. message)
    end
end

RegisterNetEvent('bcc-guarma:BuyTicket', function(shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DebugPrint(string.format('User not found for source: %s', src))
        return
    end

    local character = user.getUsedCharacter
    local shopCfg = Config.shops[shop]
    local currency = shopCfg.price.currency
    local amount = shopCfg.price.amount

    DebugPrint(string.format("Attempting to buy ticket from shop: %s with currency: %s", shop, currency))

    if not exports.vorp_inventory:canCarryItem(src, 'boat_ticket', 1) then
        DebugPrint('Cannot carry more tickets, max limit reached.')
        Core.NotifyRightTip(src, _U('maxTickets'), 4000)
        return
    end

    local paymentSuccess = false

    if currency == 1 and character.money >= amount then
        DebugPrint(string.format('Paying with cash: %d', amount))
        character.removeCurrency(0, amount)
        paymentSuccess = true

    elseif currency == 2 and character.gold >= amount then
        DebugPrint(string.format('Paying with gold: %d', amount))
        character.removeCurrency(1, amount)
        paymentSuccess = true

    elseif currency == 3 then
        local item = shopCfg.price.item.name
        local itemCount = exports.vorp_inventory:getItemCount(src, nil, item)
        if itemCount >= amount then
            DebugPrint(string.format('Paying with item: %s, amount: %d', item, amount))
            exports.vorp_inventory:subItem(src, item, amount)
            paymentSuccess = true
        else
            DebugPrint(string.format("Insufficient item count for: %s", item))
        end
    else
        DebugPrint('Invalid currency type or insufficient funds.')
    end

    if paymentSuccess then
        DebugPrint('Payment successful, giving ticket.')
        exports.vorp_inventory:addItem(src, 'boat_ticket', 1)
        Core.NotifyRightTip(src, _U('boughtTicket'), 4000)
    else
        local notification = currency == 1 and _U('shortCash') or (currency == 2 and _U('shortGold') or _U('shortItem'))
        DebugPrint('Payment failed: ' .. notification)
        Core.NotifyRightTip(src, notification, 4000)
    end
end)

Core.Callback.Register('bcc-guarma:CheckTicket', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DebugPrint(string.format('User not found for source: %s', src))
        return cb(false)
    end

    local ticket = exports.vorp_inventory:getItem(src, 'boat_ticket')
    if not ticket then
        DebugPrint('No boat ticket found in inventory.')
        Core.NotifyRightTip(src, _U('noTicket'), 4000)
        cb(false)
        return
    end

    DebugPrint('Removing one boat ticket from inventory.')
    exports.vorp_inventory:subItem(src, 'boat_ticket', 1)
    cb(true)
end)

Core.Callback.Register('bcc-guarma:CheckJob', function(source, cb, shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DebugPrint(string.format('User not found for source: %s', src))
        return cb(false)
    end

    local Character = user.getUsedCharacter
    local charJob = Character.job
    local jobGrade = Character.jobGrade

    DebugPrint(string.format("Checking job for user: charJob=%s, jobGrade=%s", charJob, jobGrade))

    if not charJob or not CheckPlayerJob(charJob, jobGrade, shop) then
        DebugPrint('User does not have the required job or grade.')
        Core.NotifyRightTip(src, _U('needJob'), 4000)
        return cb(false)
    end

    DebugPrint('User has the required job and grade.')
    cb(true)
end)

function CheckPlayerJob(charJob, jobGrade, shop)
    local jobs = Config.shops[shop].shop.jobs
    for _, job in ipairs(jobs) do
        if charJob == job.name and jobGrade >= job.grade then
            return true
        end
    end
    return false
end

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-guarma')