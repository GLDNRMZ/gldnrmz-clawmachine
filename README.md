# gldnrmz-clawmachine

A standalone, framework-agnostic FiveM claw machine script for server owners and developers. Highly configurable, optimized, and compatible with major targets and inventories.

---

## ✨ Features
- Standalone, framework-agnostic (auto-detects QBCore, ESX, QBox, or none)
- Target-agnostic (supports ox_target, qb-target, or none)
- Inventory-agnostic (supports ox_inventory, framework, or none)
- Fully configurable prize pool and machine locations
- Optimized entity management and cleanup
- Progress bar and notification support
- Easy integration with ox_lib and community_bridge
- Localization support
- Safe error handling and validation

## 📦 Requirements
| Dependency         | Required | Link                                                      |
|-------------------|----------|-----------------------------------------------------------|
| ox_lib            | Yes      | [overextended/ox_lib](https://github.com/overextended/ox_lib) |
| community_bridge  | Yes      | [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) |
| Target System     | Optional | ox_target / qb-target                                      |
| Inventory System  | Optional | ox_inventory / framework                                   |

## ⚡ Installation
1. Download or clone this repository into your resources folder.
2. Ensure `ox_lib` and `community_bridge` are installed and started before this resource.
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure community_bridge
   ensure gldnrmz-clawmachine
   ```
4. (Optional) Install and start your preferred target/inventory system before this resource.

## ⚙️ Configuration
- All configuration is handled in `config.lua`.
- Example config snippet:

```lua
Config = {
    Framework = 'auto', -- 'auto', 'qb', 'qbox', 'esx', 'none'
    Target = 'auto',    -- 'auto', 'ox_target', 'qb-target', 'none'
    Inventory = 'auto', -- 'auto', 'ox_inventory', 'framework', 'none'
    price = 10,
    prizechance = 40,
    progressTime = 7500,
    prizes = {
        { item = 'cash', chance = 75, amount = 10, label = 'Money' },
        { item = 'goldbar', chance = 8, amount = 1, label = 'Gold Bar' },
        -- ...
    },
    machines = {
        vector4(195.64, -249.91, 54.07, 159.21),
        -- ...
    },
    Text = {
        ['claw_machine'] = 'Claw Machine',
        ['use_claw'] = 'Use Claw Machine $',
        ['grab_toy'] = 'Working Joystick...',
        ['ate_money'] = 'You dropped it...'
    }
}
```

### Config Field Reference
| Field         | Type     | Description                                               |
|--------------|----------|----------------------------------------------------------|
| Framework    | string   | Framework to use ('auto', 'qb', 'qbox', 'esx', 'none')   |
| Target       | string   | Target system ('auto', 'ox_target', 'qb-target', 'none') |
| Inventory    | string   | Inventory system ('auto', 'ox_inventory', 'framework', 'none') |
| price        | number   | Cost to play the machine                                 |
| prizechance  | number   | % chance to win any prize                                |
| progressTime | number   | Progress bar duration (ms)                               |
| prizes       | table    | Prize pool (item, chance, amount, label)                 |
| machines     | table    | Machine locations (vector4)                              |
| Text         | table    | Localization strings                                     |

## 📘 Troubleshooting
- **Not enough money:** Ensure player has sufficient funds in the configured account.
- **No prizes configured:** Check `Config.prizes` for valid entries.
- **Inventory full:** Prize will not be given, money is refunded.
- **Dependency errors:** Ensure `ox_lib` and `community_bridge` are started first.
- **Debugging:** Check server/client console for `[ERROR]` logs.

## ❗ License / Usage Rules
- Licensed under GNU GPL v3. See LICENSE for details.
- Do **not** sell, resell, or monetize this script.
- Do **not** remove author credit.
- You may modify for personal/server use, but must retain attribution.

## 👤 Credit
- Script by **GLDNRMZ**
- Uses [ox_lib](https://github.com/overextended/ox_lib) and [community_bridge](https://github.com/GLDNRMZ/community_bridge)

## 📄 License Footer
- Attribution required in all copies and modifications.
- Redistribution allowed only under GNU GPL v3.
- Commercial use, selling, or credit removal is strictly prohibited.
