# gldnrmz-clawmachine

Claw machines for FiveM that work with any framework, target and inventory supported by [community_bridge](https://github.com/TheOrderFivem/community_bridge).

## Features
- Works with QBCore, QBox, ESX and others through community_bridge
- Works with ox_target, qb-target, sleepless_interact or no target
- Item prizes and cash prizes (paid straight into a framework account)
- Server-authoritative: the server checks distance, cooldown, play length and balance, so a modified client can't skip the progress bar or play from across the map
- One player per machine at a time
- Props are client-side and only spawn when you're nearby
- Prize odds are kept on the server and never sent to players
- Startup checks warn about prize items missing from ox_inventory and about prize pools that pay out more cash than a play costs
- Translations through ox_lib locales
- Optional map blips and ox_lib logging

## Requirements
| Dependency | Required |
|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | Yes |
| [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) | Yes |
| OneSync | Yes |

## Installation
1. Put this folder in your resources.
2. Add to `server.cfg` after its dependencies:
   ```
   ensure ox_lib
   ensure community_bridge
   ensure gldnrmz-clawmachine
   ```

## Configuration
| File | Contents |
|---|---|
| `config/shared.lua` | Model, price, charged account, play time, distances, blips, machine locations |
| `config/server.lua` | Win chance, cooldown, anti-cheat tolerances, logging, version check, prize pool |
| `locales/en.json` | All text players see. Copy it to e.g. `de.json` and set `setr ox:locale de` |

### Prizes
`chance` is a weight: a prize's odds are its chance divided by the sum of all chances. Each prize needs either `item` or `account`:

```lua
{ item = 'goldbar',  chance = 8,  amount = 1,  label = 'Gold Bar' },
{ account = 'money', chance = 75, amount = 10, label = 'Cash' },
```

### Machines
Each entry is `vec4(x, y, z, heading)` for where the player stands. The list position is the machine's id, so add new machines at the end.

## Upgrading from 2.x
- `config.lua` was split into `config/shared.lua` and `config/server.lua`. Copy your locations and prizes across.
- `Framework`, `Target` and `Inventory` options were removed. community_bridge already detects these.
- `Text` moved to `locales/en.json`.
- Cash prizes should use `account = 'money'` instead of `item = 'cash'`.

## Troubleshooting
- **"This machine is out of order"**: no valid prizes. Check the server console for warnings.
- **Prize skipped at startup**: the item name doesn't exist in ox_inventory.
- **"possible exploit" warning**: a client finished a play faster than `playTime` allows.

## License
GNU GPL v3. See LICENSE. Do not sell or remove author credit.

## Credit
Script by **GLDNRMZ**.
