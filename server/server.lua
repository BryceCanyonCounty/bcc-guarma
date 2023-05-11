local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterServerEvent('bcc-guarma:BuyPassage')
AddEventHandler('bcc-guarma:BuyPassage', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local location = data.location
    local currencyType = data.currencyType
    local buyPrice = data.buyPrice

    if currencyType == "cash" then
        local money = Character.money
        if money >= buyPrice then
            Character.removeCurrency(0, buyPrice)
            VORPcore.NotifyRightTip(_source, _U("boughtTicket") .. data.label, 5000)
            TriggerClientEvent('bcc-guarma:SendPlayer', _source, location)
        else
            VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
        end

    elseif currencyType == "gold" then
        local gold = Character.gold
        if gold >= buyPrice then
            Character.removeCurrency(1, buyPrice)
            VORPcore.NotifyRightTip(_source, _U("boughtTicket") .. data.label, 5000)
            TriggerClientEvent('bcc-guarma:SendPlayer', _source, location)
        else
            VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
        end
    end
end)

-- Check Player Job and Job Grade
RegisterServerEvent('bcc-guarma:GetPlayerJob')
AddEventHandler('bcc-guarma:GetPlayerJob', function()
    local _source = source
    if _source then
        local Character = VORPcore.getUser(_source).getUsedCharacter
        local CharacterJob = Character.job
        local CharacterGrade = Character.jobGrade
        TriggerClientEvent('bcc-guarma:SendPlayerJob', _source, CharacterJob, CharacterGrade)
    end
end)