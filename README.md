# gldnrmz-clawmachine

Claw machines for FiveM that work with any framework, target and inventory supported by [community_bridge](https://github.com/TheOrderFivem/community_bridge).

## ✨ Features
- Works with QBCore, QBox, ESX and others through community_bridge
- Works with ox_target, qb-target, sleepless_interact or no target
- Item prizes and cash prizes (paid straight into a framework account)
- Server-authoritative: the server checks distance, cooldown, play length and balance, so a modified client can't skip the progress bar or play from across the map
- One player per machine at a time
- Props are client-side and only spawn when you're nearby
- Prize odds are kept on the server and never sent to players
- Startup checks warn about prize items missing from your inventory and about prize pools that pay out more cash than a play costs
- Translations through ox_lib locales
- Optional map blips and ox_lib logging

## 📦 Requirements
| Dependency | Required |
|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | Yes |
| [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) **0.13.6+** | Yes |
| [OneSync](https://docs.fivem.net/docs/scripting-reference/onesync/) | Yes |

## ⚡ Installation
1. Put this folder in your resources.
2. Add every prize item to your inventory's item list.
3. Add to `server.cfg` after its dependencies:
   ```
   ensure ox_lib
   ensure community_bridge
   ensure gldnrmz-clawmachine
   ```

## ⚙️ Configuration
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

## 🆕 Upgrading from 2.x
- `config.lua` was split into `config/shared.lua` and `config/server.lua`. Copy your locations and prizes across.
- `Framework`, `Target` and `Inventory` options were removed. community_bridge already detects these.
- `Text` moved to `locales/en.json`.
- Cash prizes should use `account = 'money'` instead of `item = 'cash'`.

## ❗ Troubleshooting
- **"This machine is out of order"**: no valid prizes. Check the server console for warnings.
- **Prize skipped at startup**: the item name doesn't exist in your inventory's item list.
- **"possible exploit" warning**: a client finished a play faster than `playTime` allows.

## 🙏 Credit
Script by **GLDNRMZ**.

## 📄 License

**GLDNRMZ Script License** - see [LICENSE](LICENSE).

- ✅ Run it on your own server and edit it for that server
- ❌ Don't sell it, re-upload or share it (free or paid), or put it in a pack or server build
- ❌ Don't remove the credits or claim it as your own

Need something else, like a commercial license? Ask on [Discord](https://discord.gg/7YHJ7774jA).

<!-- gldnrmz-links -->
---

## 🔗 Links

<p align="center">
  <a href="https://discord.gg/7YHJ7774jA"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>
  <a href="https://forum.cfx.re/u/gldnrmz/summary"><img src="https://img.shields.io/badge/Cfx.re-F40552?style=for-the-badge&logoColor=white" alt="Cfx.re forum" /></a>
  <a href="https://5metrics.dev/resources?search=gldnrmz"><img src="https://img.shields.io/badge/5Metrics-00BFFF?style=for-the-badge&logoColor=white" alt="5Metrics" /></a>
  <a href="https://gldnrmz.tebex.io"><img src="https://img.shields.io/badge/Tebex-FFD700?style=for-the-badge&logoColor=black" alt="Tebex store" /></a>
  <a href="https://www.buymeacoffee.com/gldnrmz"><img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-FF813F?style=for-the-badge&logo=buymeacoffee&logoColor=white" alt="Buy me a coffee" /></a>
</p>
