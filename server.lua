local function validateMachine(machine)
    if not machine then return false end
    return true
end

local function getMachinePrizes()
    return Config.prizes
end

local function removeMoney(src)
    local price = Config.price or 10
    
    -- Always use cash for simplified config
    local hasMoney = exports.ox_inventory:GetItemCount(src, 'money') >= price
    if hasMoney then
        return exports.ox_inventory:RemoveItem(src, 'money', price)
    end
    
    lib.notify(src, {
        title = 'Claw Machine',
        description = 'You don\'t have enough money!',
        type = 'error'
    })
    
    return false
end

RegisterNetEvent('qb-clawmachine:winPrize', function(machine)
    local src = source
    
    -- Validate source
    if not src or src <= 0 then
        print("[ERROR] Invalid source in qb-clawmachine:winPrize")
        return
    end
    
    -- Validate machine data
    if not validateMachine(machine) then
        print("[ERROR] Invalid machine configuration for player: " .. src)
        lib.notify(src, {
            title = 'Claw Machine',
            description = 'Invalid machine configuration!',
            type = 'error'
        })
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
            lib.notify(src, {
                title = 'Claw Machine',
                description = 'No prizes configured!',
                type = 'error'
            })
            local refundSuccess = exports.ox_inventory:AddItem(src, 'money', Config.price)
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
            lib.notify(src, {
                title = 'Claw Machine',
                description = 'Prize configuration error!',
                type = 'error'
            })
            -- Refund money
            local refundSuccess = exports.ox_inventory:AddItem(src, 'money', Config.price)
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
                        lib.notify(src, {
                            title = 'Claw Machine',
                            description = 'Invalid prize item!',
                            type = 'error'
                        })
                        local refundSuccess = exports.ox_inventory:AddItem(src, 'money', Config.price)
                        if not refundSuccess then
                            print("[ERROR] Failed to refund money to player: " .. src)
                        end
                        return
                    end
                    
                    -- Give the prize to the player
                    local amount = prize.amount or 1
                    local success = exports.ox_inventory:AddItem(src, prize.item, amount)
                    if success then
                        print("[INFO] Player " .. src .. " won: " .. amount .. "x " .. prize.item)
                        local description = 'You won: '
                        if amount > 1 then
                            description = description .. amount .. 'x ' .. (prize.label or prize.item) .. '!'
                        else
                            description = description .. (prize.label or prize.item) .. '!'
                        end
                        lib.notify(src, {
                            title = 'Claw Machine',
                            description = description,
                            type = 'success'
                        })
                        TriggerClientEvent("qb-clawmachine:client:animation", src, "win")
                    else
                        print("[ERROR] Failed to add prize to inventory for player: " .. src)
                        -- If inventory is full, refund the money
                        local refundSuccess = exports.ox_inventory:AddItem(src, 'money', Config.price)
                        if not refundSuccess then
                            print("[ERROR] Failed to refund money to player: " .. src)
                        end
                        lib.notify(src, {
                            title = 'Claw Machine',
                            description = "Your inventory is full! Money refunded.",
                            type = 'error'
                        })
                    end
                    return
                end
            end
        end
    end

    -- Player lost
    print("[INFO] Player " .. src .. " lost at claw machine")
    lib.notify(src, {
        title = 'Claw Machine',
        description = Config.Text['ate_money'],
        type = 'error'
    })
    TriggerClientEvent("qb-clawmachine:client:animation", src, "lose")
end)
