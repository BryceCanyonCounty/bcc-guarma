---@type BCCGuarmaDebugLib
local DBG = BCCGuarmaDebug

local SEED_VERSION = 1

local ITEMS = {
    { 'boat_ticket', 'Boat Ticket', 20, 1, 'item_standard', 1, 'Guarma Express Boarding Pass' },
}

local UPSERT_SQL = [[
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES (?, ?, ?, ?, ?, ?, ?)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `limit` = VALUES(`limit`), `can_remove` = VALUES(`can_remove`), `type` = VALUES(`type`), `usable` = VALUES(`usable`), `desc` = VALUES(`desc`);
]]

local CREATE_MIGRATIONS_SQL = [[
CREATE TABLE IF NOT EXISTS `resource_migrations` (
  `resource` VARCHAR(128) NOT NULL PRIMARY KEY,
  `version` INT NOT NULL
);
]]

local function hasAwaitMySQL()
    return (MySQL ~= nil and MySQL.query ~= nil and MySQL.query.await ~= nil) or false
end

local function waitForDB(maxAttempts, delay)
    maxAttempts = maxAttempts or 8
    delay = delay or 500
    for i = 1, maxAttempts do
        if hasAwaitMySQL() then
            local ok = pcall(function() return MySQL.query.await('SELECT 1') end)
            if ok then return true end
        else
            -- Check for oxmysql (most common for MariaDB setups)
            if exports.oxmysql then
                return true
            end
        end
        Wait(delay)
        delay = delay * 2
    end
    return false
end

local function dbExecuteAwait(sql, params)
    if hasAwaitMySQL() then
        return MySQL.update.await(sql, params)
    end
    
    -- Use oxmysql for MariaDB
    if exports.oxmysql then
        local promise = promise.new()
        exports.oxmysql:execute(sql, params or {}, function(result)
            promise:resolve(result)
        end)
        return Citizen.Await(promise)
    else
        error('oxmysql resource not found - required for database operations')
    end
end

local function dbQueryAwait(sql, params)
    if hasAwaitMySQL() then
        return MySQL.query.await(sql, params)
    end
    
    -- Use oxmysql for MariaDB
    if exports.oxmysql then
        local promise = promise.new()
        exports.oxmysql:execute(sql, params or {}, function(result)
            promise:resolve(result)
        end)
        return Citizen.Await(promise)
    else
        error('oxmysql resource not found - required for database operations')
    end
end

local function getMigrationVersion()
    if not waitForDB() then return 0 end
    if hasAwaitMySQL() then
        MySQL.update.await(CREATE_MIGRATIONS_SQL)
        local rows = MySQL.query.await('SELECT version FROM resource_migrations WHERE resource = ?', { GetCurrentResourceName() })
        if rows and rows[1] and rows[1].version then
            return tonumber(rows[1].version) or 0
        end
        return 0
    else
        dbExecuteAwait(CREATE_MIGRATIONS_SQL)
        local rows = dbQueryAwait('SELECT version FROM resource_migrations WHERE resource = ?', { GetCurrentResourceName() })
        if rows and rows[1] and rows[1].version then
            return tonumber(rows[1].version) or 0
        end
        return 0
    end
end

local function setMigrationVersion(v)
    if hasAwaitMySQL() then
        MySQL.update.await('INSERT INTO resource_migrations(resource, version) VALUES(?, ?) ON DUPLICATE KEY UPDATE version = VALUES(version);', { GetCurrentResourceName(), v })
    else
        dbExecuteAwait('INSERT INTO resource_migrations(resource, version) VALUES(?, ?) ON DUPLICATE KEY UPDATE version = VALUES(version);', { GetCurrentResourceName(), v })
    end
end

local function seedItems(force)
    if not Config then
        DBG.Warning('Config missing; cannot determine autoSeedDatabase setting. Skipping seeding.')
        return
    end
    if Config.autoSeedDatabase == false and not force then
        DBG.Info('autoSeedDatabase disabled in config; skipping DB seeding.')
        return
    end
    if not waitForDB() then
        DBG.Warning('Database not available after retries; skipping seeding.')
        return
    end

    local currentVersion = 0
    local ok, err = pcall(function() currentVersion = getMigrationVersion() end)
    if not ok then
        DBG.Warning(string.format('Failed to get migration version: %s', tostring(err)))
        currentVersion = 0
    end
    if currentVersion >= SEED_VERSION and not force then
        DBG.Info(string.format('Items already seeded (version %s), skipping.', tostring(currentVersion)))
        return
    end
    DBG.Info('Seeding items...')
    for _, item in ipairs(ITEMS) do
        local ok2, res = pcall(function()
            return dbExecuteAwait(UPSERT_SQL, { item[1], item[2], item[3], item[4], item[5], item[6], item[7] })
        end)
        if not ok2 then
            DBG.Error(string.format('Failed to upsert item %s: %s', tostring(item[1]), tostring(res)))
        else
            DBG.Info(string.format('Upserted item: %s', tostring(item[1])))
        end
    end
    pcall(function() setMigrationVersion(SEED_VERSION) end)
    DBG.Info(string.format('Seeding complete; set seed version to %s', tostring(SEED_VERSION)))
end

RegisterCommand('bcc-guarma:seed', function(source, args, raw)
    if source ~= 0 then
        DBG.Warning('bcc-guarma:seed can only be run from server console')
        return
    end
    seedItems(true)
end, true)

RegisterCommand('bcc-guarma:verify', function(source, args, raw)
    if source ~= 0 then
        DBG.Warning('bcc-guarma:verify can only be run from server console')
        return
    end
    if not waitForDB() then
        DBG.Warning('Database not available; cannot verify items.')
        return
    end
    local missing = {}
    for _, item in ipairs(ITEMS) do
        local rows = dbQueryAwait('SELECT item FROM items WHERE item = ?', { item[1] })
        if not rows or #rows == 0 then
            table.insert(missing, item[1])
        end
    end
    if #missing == 0 then
        DBG.Info('All items present in the items table.')
    else
        DBG.Warning(string.format('Missing items: %s', table.concat(missing, ', ')))
    end
end, true)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(1000)
        seedItems(false)
    end)
end)