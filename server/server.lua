local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
---@type BCCGuarmaDebugLib
local DBG = BCCGuarmaDebug

RegisterNetEvent('bcc-guarma:BuyTicket', function(shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error('User not found for source: ' .. src)
        return
    end

    -- Validate shop parameter
    if not shop or type(shop) ~= 'string' then
        DBG.Error('Invalid shop parameter received from source: ' .. src)
        return
    end

    -- Validate shop configuration exists
    local shopCfg = shop == 'guarma' and Guarma or Shops[shop]
    if not shopCfg then
        DBG.Error('Shop configuration not found for shop: ' .. tostring(shop))
        return
    end

    local character = user.getUsedCharacter
    local currency = shopCfg.price.currency
    local amount = shopCfg.price.amount
    local ticket = Config.ticket.name
    local maxTickets = Config.ticket.quantity

    local ticketCount = exports.vorp_inventory:getItemCount(src, nil, ticket)
    if ticketCount >= maxTickets or not exports.vorp_inventory:canCarryItem(src, ticket, 1) then
        DBG.Warning('User already has maximum tickets.')
        Core.NotifyRightTip(src, _U('maxTickets'), 4000)
        return
    end

    DBG.Info(string.format('Attempting to buy ticket from shop: %s with currency: %s', shop, currency))

    local paymentSuccess = false
    if currency == 1 and character.money >= amount then
        DBG.Info(string.format('Paying with cash: %d', amount))
        character.removeCurrency(0, amount)
        paymentSuccess = true

    elseif currency == 2 and character.gold >= amount then
        DBG.Info(string.format('Paying with gold: %d', amount))
        character.removeCurrency(1, amount)
        paymentSuccess = true

    elseif currency == 3 then
        local item = shopCfg.price.item.name
        local shouldRemove = shopCfg.price.item.remove ~= false -- Default to true if not specified
        local itemCount = exports.vorp_inventory:getItemCount(src, nil, item)
        if itemCount >= amount then
            if shouldRemove then
                DBG.Info(string.format('Paying with item (consuming): %s, amount: %d', item, amount))
                exports.vorp_inventory:subItem(src, item, amount)
            else
                DBG.Info(string.format('Paying with item (checking only): %s, amount: %d', item, amount))
            end
            paymentSuccess = true
        else
            DBG.Warning(string.format('Insufficient item count for: %s', item))
        end
    else
        DBG.Warning('Invalid currency type or insufficient funds.')
    end

    if paymentSuccess then
        DBG.Info('Payment successful, giving ticket.')
        exports.vorp_inventory:addItem(src, ticket, 1)
        Core.NotifyRightTip(src, _U('boughtTicket'), 4000)
    else
        local notification = currency == 1 and _U('shortCash') or (currency == 2 and _U('shortGold') or _U('shortItem'))
        DBG.Warning('Payment failed: ' .. notification)
        Core.NotifyRightTip(src, notification, 4000)
    end
end)

Core.Callback.Register('bcc-guarma:CheckTicket', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error('User not found for source: ' .. src)
        return cb(false)
    end

    local ticket = Config.ticket.name
    if not exports.vorp_inventory:getItem(src, ticket) then
        DBG.Warning('No boat ticket found in inventory.')
        Core.NotifyRightTip(src, _U('noTicket'), 4000)
        return cb(false)
    end

    DBG.Info('Removing one boat ticket from inventory.')
    exports.vorp_inventory:subItem(src, ticket, 1)
    cb(true)
end)

Core.Callback.Register('bcc-guarma:CheckJob', function(source, cb, shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error('User not found for source: ' .. src)
        return cb(false)
    end

    -- Validate shop parameter
    if not shop or type(shop) ~= 'string' then
        DBG.Error('Invalid shop parameter received from source: ' .. src)
        return cb(false)
    end

    local Character = user.getUsedCharacter
    local charJob = Character.job
    local jobGrade = Character.jobGrade

    DBG.Info(string.format('Checking job for user: charJob=%s, jobGrade=%s', charJob, jobGrade))

    if not charJob or not CheckPlayerJob(charJob, jobGrade, shop) then
        DBG.Warning('User does not have the required job or grade.')
        Core.NotifyRightTip(src, _U('needJob'), 4000)
        return cb(false)
    end

    DBG.Success('User has the required job and grade.')
    cb(true)
end)

function CheckPlayerJob(charJob, jobGrade, shop)
    -- Validate shop configuration exists
    local shopCfg = shop == 'guarma' and Guarma or Shops[shop]
    if not shopCfg or not shopCfg.shop or not shopCfg.shop.jobs then
        DBG.Error('Invalid shop configuration for job check: ' .. tostring(shop))
        return false
    end

    local jobs = shopCfg.shop.jobs
    for _, job in ipairs(jobs) do
        if charJob == job.name and jobGrade >= job.grade then
            return true
        end
    end
    return false
end

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-guarma')