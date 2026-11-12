local shared = require 'config.shared'
local config = require 'config.server'

local Framework = exports.community_bridge:Framework()
local Inventory = exports.community_bridge:Inventory()

local RESOURCE = GetCurrentResourceName()
local SESSION_TIMEOUT = shared.playTime + 15000 -- a session this old was abandoned

---@class ClawSession
---@field machine integer
---@field startedAt integer

local sessions = {}  ---@type table<integer, ClawSession> keyed by player
local occupied = {}  ---@type table<integer, integer> machine id -> player
local cooldowns = {} ---@type table<integer, integer> player -> game timer when they may play again

local prizePool, totalWeight = {}, 0

-- Prize pool -----------------------------------------------------------------

local function itemExists(name)
    if GetResourceState('ox_inventory') ~= 'started' then return true end -- can't check, assume fine
    return exports.ox_inventory:Items(name) ~= nil
end

local function buildPrizePool()
    for i, prize in ipairs(config.prizes) do
        local weight = tonumber(prize.chance) or 0
        local amount = math.floor(tonumber(prize.amount) or 1)

        if weight <= 0 or amount <= 0 or not (prize.item or prize.account) then
            lib.print.warn(('Prize #%d is missing an item/account, chance or amount - skipped'):format(i))
        elseif prize.item and not itemExists(prize.item) then
            lib.print.warn(('Prize #%d: item "%s" does not exist in ox_inventory - skipped'):format(i, prize.item))
        else
            totalWeight = totalWeight + weight
            prizePool[#prizePool + 1] = {
                item = prize.item,
                account = prize.account,
                amount = amount,
                label = prize.label or prize.item or 'Cash',
                cumulative = totalWeight,
            }
        end
    end

    if totalWeight <= 0 then
        lib.print.error('No valid prizes configured - machines will refuse to play')
        return
    end

    -- Warn when cash prizes alone pay back more than a play costs.
    local cashPerWin = 0
    local previous = 0
    for _, prize in ipairs(prizePool) do
        if prize.account == shared.account then
            cashPerWin = cashPerWin + prize.amount * (prize.cumulative - previous) / totalWeight
        end
        previous = prize.cumulative
    end
    local cashPerPlay = cashPerWin * config.winChance / 100
    if cashPerPlay >= shared.price then
        lib.print.warn(('Cash prizes pay out $%.2f per play on average but a play costs $%d - players make money by playing')
            :format(cashPerPlay, shared.price))
    end
end

local function rollPrize()
    local roll = math.random() * totalWeight
    for i = 1, #prizePool do
        if roll < prizePool[i].cumulative then return prizePool[i] end
    end
    return prizePool[#prizePool]
end

local function givePrize(src, prize)
    if prize.account then
        return Framework.AddAccountBalance(src, prize.account, prize.amount)
    end
    if Inventory.CanCarryItem and not Inventory.CanCarryItem(src, prize.item, prize.amount) then
        return false
    end
    return Inventory.AddItem(src, prize.item, prize.amount)
end

-- Sessions -------------------------------------------------------------------

local function isNearMachine(src, machine)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end
    return #(GetEntityCoords(ped) - machine.xyz) <= config.maxDistance
end

local function endSession(src)
    local session = sessions[src]
    if not session then return end
    sessions[src] = nil
    if occupied[session.machine] == src then
        occupied[session.machine] = nil
    end
    return session
end

local function isStale(session, now)
    return now - session.startedAt > SESSION_TIMEOUT
end

local function log(src, message, ...)
    if config.logging then
        lib.logger(src, 'clawmachine', message, ...)
    end
end

lib.callback.register('gldnrmz-clawmachine:start', function(src, machineId)
    local machine = math.type(machineId) == 'integer' and shared.machines[machineId]
    if not machine then return false end
    if totalWeight <= 0 then return false, 'unavailable' end

    local now = GetGameTimer()

    local current = sessions[src]
    if current then
        if not isStale(current, now) then return false, 'busy' end
        endSession(src)
    end

    if (cooldowns[src] or 0) > now then return false, 'cooldown' end

    local occupant = occupied[machineId]
    if occupant then
        local theirs = sessions[occupant]
        if theirs and not isStale(theirs, now) then return false, 'occupied' end
        endSession(occupant)
    end

    if not isNearMachine(src, machine) then return false, 'too_far' end
    if (Framework.GetAccountBalance(src, shared.account) or 0) < shared.price then return false, 'no_money' end

    sessions[src] = { machine = machineId, startedAt = now }
    occupied[machineId] = src
    return true
end)

lib.callback.register('gldnrmz-clawmachine:finish', function(src)
    -- End the session before anything can yield so a duplicate call finds nothing.
    local session = endSession(src)
    if not session then return end

    local now = GetGameTimer()
    cooldowns[src] = now + config.cooldown

    local elapsed = now - session.startedAt
    if elapsed < shared.playTime - config.timeTolerance then
        lib.print.warn(('Player %d finished a play in %dms (needs %dms) - possible exploit'):format(src, elapsed, shared.playTime))
        log(src, ('Rejected play: finished in %dms'):format(elapsed), 'exploit')
        return
    end

    if not isNearMachine(src, shared.machines[session.machine]) then
        return { error = 'too_far' }
    end

    local balance = Framework.GetAccountBalance(src, shared.account) or 0
    if balance < shared.price or not Framework.RemoveAccountBalance(src, shared.account, shared.price) then
        return { error = 'no_money' }
    end

    if math.random() * 100 >= config.winChance then
        log(src, ('Lost at machine #%d'):format(session.machine))
        return { won = false }
    end

    local prize = rollPrize()
    if not givePrize(src, prize) then
        Framework.AddAccountBalance(src, shared.account, shared.price)
        return { error = 'refunded' }
    end

    log(src, ('Won %dx %s at machine #%d'):format(prize.amount, prize.item or prize.account, session.machine))
    return {
        won = true,
        label = prize.label,
        amount = prize.amount,
        cash = prize.account ~= nil,
    }
end)

RegisterNetEvent('gldnrmz-clawmachine:cancel', function()
    endSession(source)
end)

AddEventHandler('playerDropped', function()
    endSession(source)
    cooldowns[source] = nil
end)

-- Version check --------------------------------------------------------------

local function parseVersion(text)
    local major, minor, patch = tostring(text):match('(%d+)%.(%d+)%.?(%d*)')
    return { tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0 }
end

local function compareVersions(a, b)
    for i = 1, 3 do
        if a[i] ~= b[i] then return a[i] < b[i] and -1 or 1 end
    end
    return 0
end

local function checkVersion()
    local current = GetResourceMetadata(RESOURCE, 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/GLDNRMZ/gldnrmz-clawmachine/main/version.txt', function(status, body)
        if status ~= 200 or not body then
            return lib.print.warn('Unable to check for updates')
        end
        local latest = body:gsub('%s', '')
        local cmp = compareVersions(parseVersion(current), parseVersion(latest))
        if cmp < 0 then
            print(('^3[%s] Update available: %s (running %s)^0'):format(RESOURCE, latest, current))
        else
            print(('^2[%s] Up to date (%s)^0'):format(RESOURCE, current))
        end
    end, 'GET')
end

-- Startup --------------------------------------------------------------------

CreateThread(function()
    -- Give ox_inventory a moment if it's starting alongside us, so item validation works.
    local waited = 0
    while GetResourceState('ox_inventory') == 'starting' and waited < 10000 do
        Wait(250)
        waited = waited + 250
    end

    buildPrizePool()
    lib.print.info(('Loaded %d machines and %d prizes'):format(#shared.machines, #prizePool))

    if config.versionCheck then checkVersion() end
end)
