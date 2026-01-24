--[[
    Inventory Bridge (Server)
    =========================
    Inventory system-agnostic bridge for ox_inventory/QB/QBox/ESX support
    
    Usage (Server):
        local Inventory = require 'bridge.inventory'
        Inventory:init()
        print("Detected inventory system: " .. Inventory.type)
        Inventory:getItemCount(playerId, itemName)
        Inventory:addItem(playerId, itemName, amount)
        Inventory:removeItem(playerId, itemName, amount)
        Inventory:canCarryItem(playerId, itemName, amount)
]]

local Inventory = {
    type = 'none',
    _framework = nil
}

function Inventory:init(framework)
    self._framework = framework
    
    -- Check if user manually set inventory in config
    if Config.Inventory and Config.Inventory ~= 'auto' then
        if Config.Inventory == 'ox_inventory' and GetResourceState('ox_inventory') == 'started' then
            self.type = 'ox_inventory'
            return self
        elseif Config.Inventory == 'framework' and (framework.type == 'qb' or framework.type == 'qbox' or framework.type == 'esx') then
            self.type = 'framework'
            return self
        elseif Config.Inventory == 'none' then
            self.type = 'none'
            return self
        else
            print("[WARNING] Inventory '" .. Config.Inventory .. "' not found or not running. Falling back to auto-detection.")
        end
    end
    
    -- Auto-detect inventory system
    if GetResourceState('ox_inventory') == 'started' then
        self.type = 'ox_inventory'
    elseif framework.type == 'qb' or framework.type == 'qbox' or framework.type == 'esx' then
        self.type = 'framework'
    else
        self.type = 'none'
    end
    
    return self
end

function Inventory:getItemCount(src, item)
    if self.type == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    elseif self.type == 'framework' then
        if self._framework.type == 'qb' or self._framework.type == 'qbox' then
            local Player = self._framework._instance.Functions.GetPlayer(src)
            if not Player then return 0 end
            local itemData = Player.Functions.GetItemByName(item)
            return itemData and itemData.amount or 0
        elseif self._framework.type == 'esx' then
            local xPlayer = self._framework._instance.GetPlayerFromId(src)
            if not xPlayer then return 0 end
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and itemData.count or 0
        end
    end
    return 0
end

function Inventory:addItem(src, item, amount)
    if self.type == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, item, amount)
    elseif self.type == 'framework' then
        if self._framework.type == 'qb' or self._framework.type == 'qbox' then
            local Player = self._framework._instance.Functions.GetPlayer(src)
            if not Player then return false end
            return Player.Functions.AddItem(item, amount)
        elseif self._framework.type == 'esx' then
            local xPlayer = self._framework._instance.GetPlayerFromId(src)
            if not xPlayer then return false end
            xPlayer.addInventoryItem(item, amount)
            return true
        end
    end
    return false
end

function Inventory:removeItem(src, item, amount)
    if self.type == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    elseif self.type == 'framework' then
        if self._framework.type == 'qb' or self._framework.type == 'qbox' then
            local Player = self._framework._instance.Functions.GetPlayer(src)
            if not Player then return false end
            return Player.Functions.RemoveItem(item, amount)
        elseif self._framework.type == 'esx' then
            local xPlayer = self._framework._instance.GetPlayerFromId(src)
            if not xPlayer then return false end
            xPlayer.removeInventoryItem(item, amount)
            return true
        end
    end
    return false
end

function Inventory:canCarryItem(src, item, amount)
    if self.type == 'ox_inventory' then
        local count = exports.ox_inventory:GetItemCount(src, item)
        if count then
            return true
        end
        return false
    elseif self.type == 'framework' then
        -- Framework inventories handle space automatically
        return true
    end
    return false
end

function Inventory:getMaxSlots(src)
    if self.type == 'ox_inventory' then
        return exports.ox_inventory:GetSlotCount(src) or 50
    elseif self.type == 'framework' then
        if self._framework.type == 'qb' or self._framework.type == 'qbox' then
            return 50 -- Default QB inventory size
        elseif self._framework.type == 'esx' then
            return 30 -- Default ESX inventory size
        end
    end
    return 0
end

return Inventory
