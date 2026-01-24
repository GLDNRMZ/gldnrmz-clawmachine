# Framework, Target & Inventory Support Guide

This claw machine script is now **fully agnostic** to frameworks, target systems, and inventory systems. It automatically detects and integrates with your server's setup.

## Supported Frameworks

### Primary Frameworks
- **QB-Core** - Full integration with QBCore
- **QBox** - Full integration with QBox (modern QBCore fork)
- **ESX** - Full integration with es_extended

### Framework Detection Priority
1. QB-Core
2. QBox
3. ESX
4. Standalone (no framework required)

## Supported Target Systems

### Available Target Systems
- **ox_target** - Modern target system
- **qb-target** - QB's target system

### Target Detection Priority
1. ox_target
2. qb-target
3. None (machines won't be interactive if no target system found)

## Supported Inventory Systems

### Available Inventory Systems
- **ox_inventory** - Standalone inventory system (works with any framework or alone)
- **Framework Inventory** - QB, QBox, and ESX native inventory systems
  - QB/QBox: Uses Player.Functions.AddItem()
  - ESX: Uses xPlayer.addInventoryItem()

### Inventory Detection Priority
1. ox_inventory (if running)
2. Framework inventory (if QB/QBox/ESX detected)
3. None (inventory operations will fail if nothing is detected)

## Installation Scenarios

### Scenario 1: QB + ox_target + ox_inventory
```
ensure qb-core
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure gldnrmz-clawmachine
```
✅ Full compatibility

### Scenario 2: QB + qb-target + QB Inventory
```
ensure qb-core
ensure ox_lib
ensure qb-target
ensure gldnrmz-clawmachine
```
✅ Full compatibility

### Scenario 3: ESX + ox_target + ESX Inventory
```
ensure es_extended
ensure ox_lib
ensure ox_target
ensure gldnrmz-clawmachine
```
✅ Full compatibility

### Scenario 4: QBox + ox_target + QBox Inventory
```
ensure qbox
ensure ox_lib
ensure ox_target
ensure gldnrmz-clawmachine
```
✅ Full compatibility

### Scenario 5: Standalone + ox_inventory + ox_target
```
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure gldnrmz-clawmachine
```
✅ Full compatibility (no framework needed)

### Scenario 6: QB + ox_target + ESX Inventory (Mixed)
```
ensure qb-core
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure gldnrmz-clawmachine
```
✅ Compatible (ox_inventory takes priority)

## Server Logs

The script logs all detected systems on startup:

```
[INFO] Framework detected: qb
[INFO] Target system detected: ox_target
[INFO] Inventory system detected: framework
```

or

```
[INFO] Framework detected: esx
[INFO] Target system detected: qb-target
[INFO] Inventory system detected: ox_inventory
```

Check server console on startup to confirm proper detection.

## How It Works

### Framework Detection (Client & Server)
The script tries to export from each framework resource in order:
- qb-core → qbox → es_extended → None

### Target System Detection (Client Only)
The script detects available target systems:
- ox_target (uses `exports.ox_target:addModel()`)
- qb-target (uses `exports['qb-target']:AddTargetModel()`)

### Inventory System Detection (Server Only)
The script prioritizes inventory systems:
1. **ox_inventory** - If running, uses ox_inventory APIs
2. **Framework Inventory** - Uses framework's native item functions
   - QB/QBox: Player.Functions.AddItem, RemoveItem, etc.
   - ESX: xPlayer.addInventoryItem, removeInventoryItem, etc.
3. **None** - Falls back to error handling

## Troubleshooting

### "Target system not detected" in logs
**Solution:** Ensure at least one target system is running:
```
ensure ox_target
-- or
ensure qb-target
```

### "Inventory system not detected" in logs
**Solution:** Ensure you have a framework OR ox_inventory:
```
ensure qb-core  -- QB framework handles inventory
-- or
ensure ox_inventory  -- Standalone inventory
-- or
ensure es_extended  -- ESX framework handles inventory
```

### Players can't use machines
1. Check server logs for all three detection lines
2. Verify target system is installed and running
3. Test target system with other scripts
4. Check player has required inventory items

### Items not being added to inventory
1. Verify inventory system is detected correctly
2. Check that Config.prizes items exist in your server
3. Ensure player inventory isn't full
4. Check server logs for errors

### Framework not detected (says "none")
1. Ensure framework resource is started BEFORE this resource in server.cfg
2. Verify framework is actually running (`status qb-core`, `status es_extended`, etc.)
3. Check for typos in resource names

## Event Names

The script uses generic event names compatible with all frameworks:

- **Client → Server:** `clawmachine:winPrize`
- **Server → Client:** `clawmachine:client:animation`

These work across all framework/target/inventory combinations.

## Version History

- **v2.1.0** - Full agnostic support (framework + target + inventory)
- **v2.0.0** - Framework-agnostic rewrite (QB/QBox/ESX)
- **v1.0.0** - Original QB-only version
