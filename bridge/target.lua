--[[
    Target Bridge (Client)
    ======================
    Target system-agnostic bridge for ox_target/qb-target support
    
    Usage (Client):
        local Target = require 'bridge.target'
        Target:init()
        print("Detected target system: " .. Target.type)
        Target:addModel(modelHash, optionsTable)
        Target:removeModel(modelHash)
]]

local Target = {
    type = 'none',
    _system = nil
}

function Target:init()
    -- Check if user manually set target in config
    if Config.Target and Config.Target ~= 'auto' then
        if Config.Target == 'ox_target' and GetResourceState('ox_target') == 'started' then
            self.type = 'ox_target'
            self._system = 'ox_target'
            return self
        elseif Config.Target == 'qb-target' and GetResourceState('qb-target') == 'started' then
            self.type = 'qb-target'
            self._system = 'qb-target'
            return self
        elseif Config.Target == 'none' then
            self.type = 'none'
            return self
        else
            print("[WARNING] Target system '" .. Config.Target .. "' not found or not running. Falling back to auto-detection.")
        end
    end
    
    -- Auto-detect target system
    if GetResourceState('ox_target') == 'started' then
        self.type = 'ox_target'
        self._system = 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        self.type = 'qb-target'
        self._system = 'qb-target'
    else
        self.type = 'none'
    end
    
    return self
end

function Target:addModel(model, options)
    if self.type == 'ox_target' then
        return exports.ox_target:addModel(model, options)
    elseif self.type == 'qb-target' then
        return exports['qb-target']:AddTargetModel(model, options)
    else
        print("[WARNING] No target system detected. Interactions won't work.")
        return false
    end
end

function Target:removeModel(model)
    if self.type == 'ox_target' then
        return pcall(function()
            exports.ox_target:removeModel(model)
        end)
    elseif self.type == 'qb-target' then
        return pcall(function()
            exports['qb-target']:RemoveTargetModel(model)
        end)
    end
    return true
end

function Target:addEntity(entity, options)
    if self.type == 'ox_target' then
        return exports.ox_target:addEntity(entity, options)
    elseif self.type == 'qb-target' then
        return exports['qb-target']:AddTargetEntity(entity, options)
    else
        return false
    end
end

function Target:removeEntity(entity)
    if self.type == 'ox_target' then
        return pcall(function()
            exports.ox_target:removeEntity(entity)
        end)
    elseif self.type == 'qb-target' then
        return pcall(function()
            exports['qb-target']:RemoveTargetEntity(entity)
        end)
    end
    return true
end

function Target:addBox(coords, size, options)
    if self.type == 'ox_target' then
        return exports.ox_target:addBoxZone(coords, size, options)
    elseif self.type == 'qb-target' then
        return exports['qb-target']:AddBoxZone(coords, size, options)
    else
        return false
    end
end

return Target
