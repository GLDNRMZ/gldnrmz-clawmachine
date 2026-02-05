local Framework = exports.community_bridge:Framework()
local Inventory = exports.community_bridge:Inventory()
local Notify = exports.community_bridge:Notify()

local function validateMachine(machine)
    if not machine then return false end
    return true
end

local function getMachinePrizes()
    return Config.prizes
end

local function removeMoney(src)
    local price = Config.price or 10
    local balance = Framework.GetAccountBalance(src, 'money') or 0

    if balance >= price then
        return Framework.RemoveAccountBalance(src, 'money', price)
    end

    if Notify and Notify.SendNotify then
        Notify.SendNotify(src, "You don't have enough money!", 'error')
    end
    return false
end

RegisterNetEvent('clawmachine:winPrize', function(machine)
    local src = source
    
    -- Validate source
    if not src or src <= 0 then
        print("[ERROR] Invalid source in clawmachine:winPrize")
        return
    end
    
    -- Validate machine data
    if not validateMachine(machine) then
        print("[ERROR] Invalid machine configuration for player: " .. src)
        if Notify and Notify.SendNotify then
            Notify.SendNotify(src, 'Invalid machine configuration!', 'error')
        end
        return
    end
    
    -- Check if player has enough money
    local hasMoney = removeMoney(src)
    
    if not hasMoney then
        print("[ERROR] Player " .. src .. " doesn't have enough money")
        return
    end

    -- Calculate if player wins based on global prize chance
    local winRoll = math.random(1, 100)
    local prizeChance = Config.prizechance or 35
    
    if winRoll <= prizeChance then
        -- Player won, now determine which prize
        local prizes = getMachinePrizes()
        if not prizes then
            print("[ERROR] No prizes configured, refunding player: " .. src)
            if Notify and Notify.SendNotify then
                Notify.SendNotify(src, 'No prizes configured!', 'error')
            end
            local refundSuccess = Framework.AddAccountBalance(src, 'money', Config.price)
            if not refundSuccess then
                print("[ERROR] Failed to refund money to player: " .. src)
            end
            return
        end
        
        local totalChance = 0
        for _, prize in ipairs(prizes) do
            if prize and prize.chance and type(prize.chance) == "number" then
                totalChance = totalChance + prize.chance
            end
        end
        
        if totalChance <= 0 then
            print("[ERROR] Invalid prize chances configuration for player: " .. src)
            if Notify and Notify.SendNotify then
                Notify.SendNotify(src, 'Prize configuration error!', 'error')
            end
            -- Refund money
            local refundSuccess = Framework.AddAccountBalance(src, 'money', Config.price)
            if not refundSuccess then
                print("[ERROR] Failed to refund money to player: " .. src)
            end
            return
        end
        
        local prizeRoll = math.random(1, totalChance)
        local accumulatedChance = 0
        
        for _, prize in ipairs(prizes) do
            if prize and prize.chance and type(prize.chance) == "number" then
                accumulatedChance = accumulatedChance + prize.chance
                if prizeRoll <= accumulatedChance then
                    -- Validate prize item
                    if not prize.item or prize.item == "" then
                        print("[ERROR] Invalid prize item for player: " .. src)
                        if Notify and Notify.SendNotify then
                            Notify.SendNotify(src, 'Invalid prize item!', 'error')
                        end
                        local refundSuccess = Framework.AddAccountBalance(src, 'money', Config.price)
                        if not refundSuccess then
                            print("[ERROR] Failed to refund money to player: " .. src)
                        end
                        return
                    end
                    
                    -- Give the prize to the player
                    local amount = prize.amount or 1
                    local success = Inventory.AddItem(src, prize.item, amount)
                    if success then
                        print("[INFO] Player " .. src .. " won: " .. amount .. "x " .. prize.item)
                        local description = 'You won: '
                        if amount > 1 then
                            description = description .. amount .. 'x ' .. (prize.label or prize.item) .. '!'
                        else
                            description = description .. (prize.label or prize.item) .. '!'
                        end
                        if Notify and Notify.SendNotify then
                            Notify.SendNotify(src, description, 'success')
                        end
                        TriggerClientEvent("clawmachine:client:animation", src, "win")
                    else
                        print("[ERROR] Failed to add prize to inventory for player: " .. src)
                        -- If inventory is full, refund the money
                        local refundSuccess = Framework.AddAccountBalance(src, 'money', Config.price)
                        if not refundSuccess then
                            print("[ERROR] Failed to refund money to player: " .. src)
                        end
                        if Notify and Notify.SendNotify then
                            Notify.SendNotify(src, "Your inventory is full! Money refunded.", 'error')
                        end
                    end
                    return
                end
            end
        end
    end

    -- Player lost
    print("[INFO] Player " .. src .. " lost at claw machine")
    if Notify and Notify.SendNotify then
        Notify.SendNotify(src, (Config.Text and Config.Text['ate_money']) or 'You dropped it...', 'error')
    end
    TriggerClientEvent("clawmachine:client:animation", src, "lose")
end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/GLDNRMZ/'..GetCurrentResourceName()..'/main/version.txt', function(err, text, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not text then 
			print('^1[GLDNRMZ] Unable to check version for '..GetCurrentResourceName()..'^0')
			return 
		end
		local result = text:gsub("\r", ""):gsub("\n", "")
		if result ~= currentVersion then
			print('^1[GLDNRMZ] '..GetCurrentResourceName()..' is out of date! Latest: '..result..' | Current: '..currentVersion..'^0')
		else
			print('^2[GLDNRMZ] '..GetCurrentResourceName()..' is up to date! ('..currentVersion..')^0')
		end
	end)
end

-- Initialize bridges and start version check on resource start
CreateThread(function()
    Wait(1000)
    
    print("[INFO] Using community_bridge for framework/inventory/notify")
    
    -- Version check
    CheckVersion()
end)
