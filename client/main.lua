local shared = require 'config.shared'

local Target = exports.community_bridge:Target()
local Notify = exports.community_bridge:Notify()
local ProgressBar = exports.community_bridge:ProgressBar()

local OPTION_NAME = 'gldnrmz_clawmachine_play'

local PLAY_ANIM = { dict = 'anim_casino_a@amb@casino@games@arcadecabinet@maleleft', clip = 'insert_coins', flag = 16 }
local REACTIONS = {
    win = { dict = 'anim@mp_player_intcelebrationfemale@slow_clap', clip = 'slow_clap' },
    lose = { dict = 'gestures@m@standing@casual', clip = 'gesture_damn' },
}

---@class ClawMachine
---@field coords vector4
---@field point CPoint
---@field entity? integer
---@field blip? integer

local machines = {} ---@type ClawMachine[]
local playing = false

local function notify(message, nType)
    if Notify and Notify.SendNotify then
        return Notify.SendNotify(message, nType or 'inform')
    end
    lib.notify({ description = message, type = nType or 'inform' })
end

local function playReaction(kind)
    local reaction = REACTIONS[kind]
    if not pcall(lib.requestAnimDict, reaction.dict, 3000) then return end
    TaskPlayAnim(cache.ped, reaction.dict, reaction.clip, 8.0, -8.0, 3000, 48, 0, false, false, false)
    RemoveAnimDict(reaction.dict)
end

local function runProgress()
    local options = {
        duration = shared.playTime,
        label = locale('progress_label'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, mouse = false },
        anim = PLAY_ANIM,
    }
    if ProgressBar and ProgressBar.Open then
        return ProgressBar.Open(options)
    end
    return lib.progressBar(options)
end

local function showResult(result)
    if result.error then
        return notify(locale('error_' .. result.error), 'error')
    end

    if not result.won then
        notify(locale('lost'), 'error')
        return playReaction('lose')
    end

    if result.cash then
        notify(locale('won_cash', result.amount), 'success')
    elseif result.amount > 1 then
        notify(locale('won_items', result.amount, result.label), 'success')
    else
        notify(locale('won_item', result.label), 'success')
    end
    playReaction('win')
end

local function play(id)
    local machine = machines[id]
    if playing or lib.progressActive() or not machine.entity then return end
    if IsPedInAnyVehicle(cache.ped, false) or IsEntityDead(cache.ped) then return end

    playing = true

    TaskTurnPedToFaceEntity(cache.ped, machine.entity, 1000)
    Wait(800)

    local ok, reason = lib.callback.await('gldnrmz-clawmachine:start', false, id)
    if not ok then
        playing = false
        if reason then notify(locale('error_' .. reason), 'error') end
        return
    end

    if not runProgress() then
        TriggerServerEvent('gldnrmz-clawmachine:cancel')
        ClearPedTasks(cache.ped)
        playing = false
        return
    end

    ClearPedTasks(cache.ped)
    local result = lib.callback.await('gldnrmz-clawmachine:finish', false)
    playing = false

    if result then showResult(result) end
end

-- Props are client-side only and exist only while the player is nearby.

local function spawnMachine(id)
    local machine = machines[id]
    if machine.entity then return end

    if not pcall(lib.requestModel, shared.model, 5000) then
        return lib.print.error('Failed to load claw machine model')
    end

    local c = machine.coords
    local entity = CreateObject(shared.model, c.x, c.y, c.z - 1.0, false, false, false)
    SetModelAsNoLongerNeeded(shared.model)

    SetEntityHeading(entity, c.w - 180.0)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    machine.entity = entity

    Target.AddLocalEntity(entity, {
        {
            name = OPTION_NAME,
            icon = 'fas fa-coins',
            label = locale('target_label', shared.price),
            distance = shared.interactDistance,
            onSelect = function() play(id) end,
        },
    })
end

local function despawnMachine(id)
    local machine = machines[id]
    local entity = machine.entity
    if not entity then return end
    machine.entity = nil

    pcall(Target.RemoveLocalEntity, entity)
    if DoesEntityExist(entity) then DeleteEntity(entity) end
end

local function createBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, shared.blips.sprite)
    SetBlipColour(blip, shared.blips.colour)
    SetBlipScale(blip, shared.blips.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('blip_name'))
    EndTextCommandSetBlipName(blip)
    return blip
end

for id, coords in ipairs(shared.machines) do
    machines[id] = {
        coords = coords,
        point = lib.points.new({
            coords = coords.xyz,
            distance = shared.spawnDistance,
            onEnter = function() spawnMachine(id) end,
            onExit = function() despawnMachine(id) end,
        }),
        blip = shared.blips.enabled and createBlip(coords) or nil,
    }
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for id, machine in ipairs(machines) do
        despawnMachine(id)
        machine.point:remove()
        if machine.blip then RemoveBlip(machine.blip) end
    end
end)
