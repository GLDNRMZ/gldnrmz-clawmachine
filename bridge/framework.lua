--[[
    Framework Bridge
    ================
    Framework-agnostic bridge for QB/QBox/ESX support
    
    Usage (Server):
        local Framework = require 'bridge.framework'
        Framework:init()
        print("Detected framework: " .. Framework.type)
        Framework:getPlayerMoney(playerId)
        Framework:removeMoney(playerId, amount)
        Framework:addMoney(playerId, amount)
        Framework:notify(playerId, title, description, type)
]]

local Framework = {
    type = 'none',
    _instance = nil
}

function Framework:init()
    -- Check if user manually set framework in config
    if Config.Framework and Config.Framework ~= 'auto' then
        if Config.Framework == 'qb' and GetResourceState('qb-core') == 'started' then
            self._instance = exports['qb-core']:GetCoreObject()
            self.type = 'qb'
            return self
        elseif Config.Framework == 'qbox' and GetResourceState('qbox') == 'started' then
            self._instance = exports.qbox:GetCoreObject()
            self.type = 'qbox'
            return self
        elseif Config.Framework == 'esx' and GetResourceState('es_extended') == 'started' then
            self._instance = exports.es_extended:getSharedObject()
            self.type = 'esx'
            return self
        elseif Config.Framework == 'none' then
            self.type = 'none'
            return self
        else
            print("[WARNING] Framework '" .. Config.Framework .. "' not found or not running. Falling back to auto-detection.")
        end
    end
    
    -- Auto-detect framework
    if GetResourceState('qb-core') == 'started' then
        self._instance = exports['qb-core']:GetCoreObject()
        self.type = 'qb'
    elseif GetResourceState('qbox') == 'started' then
        self._instance = exports.qbox:GetCoreObject()
        self.type = 'qbox'
    elseif GetResourceState('es_extended') == 'started' then
        self._instance = exports.es_extended:getSharedObject()
        self.type = 'esx'
    else
        self.type = 'none'
    end
    
    return self
end

function Framework:getPlayerMoney(src)
    if self.type == 'qb' or self.type == 'qbox' then
        local Player = self._instance.Functions.GetPlayer(src)
        if not Player then return 0 end
        return Player.PlayerData.money.cash
    elseif self.type == 'esx' then
        local xPlayer = self._instance.GetPlayerFromId(src)
        if not xPlayer then return 0 end
        return xPlayer.getMoney()
    end
    return 0
end

function Framework:removeMoney(src, amount)
    if self.type == 'qb' or self.type == 'qbox' then
        local Player = self._instance.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.RemoveMoney('cash', amount)
        return true
    elseif self.type == 'esx' then
        local xPlayer = self._instance.GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.removeMoney(amount)
        return true
    end
    return false
end

function Framework:addMoney(src, amount)
    if self.type == 'qb' or self.type == 'qbox' then
        local Player = self._instance.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.AddMoney('cash', amount)
        return true
    elseif self.type == 'esx' then
        local xPlayer = self._instance.GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.addMoney(amount)
        return true
    end
    return false
end

function Framework:notify(src, title, description, type)
    local notifType = type or 'info'
    if self.type == 'qb' or self.type == 'qbox' then
        TriggerClientEvent('QBCore:Notify', src, description, notifType)
    elseif self.type == 'esx' then
        TriggerClientEvent('esx:showNotification', src, description)
    end
end

return Framework
