# Bridge Module Documentation

This folder contains reusable framework/target/inventory bridge modules that can be used across multiple FiveM scripts.

## Overview

The bridge modules provide a unified interface to multiple frameworks and systems:

- **framework.lua** - Handles QB/QBox/ESX detection and operations
- **target.lua** - Handles ox_target/qb-target detection and interactions
- **inventory.lua** - Handles ox_inventory/QB/QBox/ESX inventory operations

## Usage

### Framework Bridge (Server-side)

```lua
local Framework = require 'bridge.framework'

-- Initialize and detect framework
Framework:init()
print("Detected: " .. Framework.type) -- 'qb', 'qbox', 'esx', or 'none'

-- Get player money
local money = Framework:getPlayerMoney(playerId)

-- Remove money
Framework:removeMoney(playerId, 100)

-- Add money
Framework:addMoney(playerId, 100)

-- Send notification
Framework:notify(playerId, 'Title', 'Description', 'success')
```

### Target Bridge (Client-side)

```lua
local Target = require 'bridge.target'

-- Initialize and detect target system
Target:init()
print("Detected: " .. Target.type) -- 'ox_target', 'qb-target', or 'none'

-- Add model target
Target:addModel(`modelHash`, {
    {
        name = 'action_name',
        label = 'Use Item',
        icon = 'fas fa-hand',
        onSelect = function(data)
            -- Your code here
        end
    }
})

-- Remove model target
Target:removeModel(`modelHash`)

-- Add entity target
Target:addEntity(entityHandle, optionsTable)
Target:removeEntity(entityHandle)

-- Add box zone
Target:addBox(coords, size, optionsTable)
```

### Inventory Bridge (Server-side)

```lua
local Framework = require 'bridge.framework'
local Inventory = require 'bridge.inventory'

-- Initialize both
Framework:init()
Inventory:init(Framework) -- Inventory needs framework reference
print("Detected: " .. Inventory.type) -- 'ox_inventory', 'framework', or 'none'

-- Get item count
local count = Inventory:getItemCount(playerId, 'item_name')

-- Add item
Inventory:addItem(playerId, 'item_name', 1)

-- Remove item
Inventory:removeItem(playerId, 'item_name', 1)

-- Check if can carry
if Inventory:canCarryItem(playerId, 'item_name', 1) then
    Inventory:addItem(playerId, 'item_name', 1)
end

-- Get max inventory slots
local slots = Inventory:getMaxSlots(playerId)
```

## Configuration

All bridges respect the Config settings in your main config.lua:

```lua
Config = {
    -- Framework: 'auto', 'qb', 'qbox', 'esx', 'none'
    Framework = 'auto',
    
    -- Target: 'auto', 'ox_target', 'qb-target', 'none'
    Target = 'auto',
    
    -- Inventory: 'auto', 'ox_inventory', 'framework', 'none'
    Inventory = 'auto',
}
```

## Using in Other Scripts

### Copy to Your Resource

1. Copy the `bridge` folder to your resource directory
2. In your config.lua, add the framework/target/inventory options
3. In your scripts, require the appropriate bridge modules

### Example: Custom Script

**config.lua**
```lua
Config = {
    Framework = 'auto',
    Target = 'auto',
    Inventory = 'auto',
}
```

**server.lua**
```lua
local Framework = require 'bridge.framework'
local Inventory = require 'bridge.inventory'

Framework:init()
Inventory:init(Framework)

RegisterNetEvent('my_script:buyItem', function()
    local src = source
    if Framework:getPlayerMoney(src) >= 100 then
        Framework:removeMoney(src, 100)
        Inventory:addItem(src, 'some_item', 1)
        Framework:notify(src, 'Store', 'Purchase successful!', 'success')
    else
        Framework:notify(src, 'Store', 'Not enough money!', 'error')
    end
end)
```

**client.lua**
```lua
local Target = require 'bridge.target'

Target:init()

Target:addModel(`some_model_hash`, {
    {
        name = 'buy_item',
        label = 'Buy Item ($100)',
        icon = 'fas fa-shopping-cart',
        onSelect = function(data)
            TriggerServerEvent('my_script:buyItem')
        end
    }
})
```

## Framework Methods

### Available in Framework Bridge

| Method | Returns | Description |
|--------|---------|-------------|
| `init()` | self | Initialize framework detection |
| `getPlayerMoney(src)` | number | Get player's cash money |
| `removeMoney(src, amount)` | bool | Remove cash from player |
| `addMoney(src, amount)` | bool | Add cash to player |
| `notify(src, title, desc, type)` | nil | Send notification to player |

### Available in Target Bridge

| Method | Returns | Description |
|--------|---------|-------------|
| `init()` | self | Initialize target system detection |
| `addModel(model, options)` | varies | Add interaction to model |
| `removeModel(model)` | bool | Remove interaction from model |
| `addEntity(entity, options)` | varies | Add interaction to entity |
| `removeEntity(entity)` | bool | Remove interaction from entity |
| `addBox(coords, size, options)` | varies | Add zone interaction |

### Available in Inventory Bridge

| Method | Returns | Description |
|--------|---------|-------------|
| `init(framework)` | self | Initialize inventory (requires framework) |
| `getItemCount(src, item)` | number | Get item count in inventory |
| `addItem(src, item, amount)` | bool | Add item to inventory |
| `removeItem(src, item, amount)` | bool | Remove item from inventory |
| `canCarryItem(src, item, amount)` | bool | Check if can carry item |
| `getMaxSlots(src)` | number | Get max inventory slots |

## Detection Priority

### Framework
1. Config.Framework setting (if not 'auto')
2. qb-core
3. qbox
4. es_extended
5. none

### Target
1. Config.Target setting (if not 'auto')
2. ox_target
3. qb-target
4. none

### Inventory
1. Config.Inventory setting (if not 'auto')
2. ox_inventory
3. Framework inventory (if framework detected)
4. none

## Tips

- Always initialize Framework before Inventory
- Always initialize Target before using target interactions
- Check the `.type` property to see what was detected
- Fallback gracefully when type is 'none'
- Use Config to force specific systems if auto-detection fails

## Debugging

Enable debug logs in the console:

```lua
-- In server.lua
print("[DEBUG] Framework: " .. Framework.type)
print("[DEBUG] Inventory: " .. Inventory.type)

-- In client.lua
print("[DEBUG] Target: " .. Target.type)
```

Check server console output for "[INFO]" logs showing what was detected on startup.
