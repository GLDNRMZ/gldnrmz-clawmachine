# Modernized Claw Machine Script

A fully modernized and optimized claw machine resource for FiveM servers with comprehensive error handling, improved performance, and streamlined configuration.

## ✨ Features

- **Modern FiveM Integration**: Updated to use latest FiveM practices and ox_lib
- **Ox_Target Support**: Seamless interaction system with ox_target
- **Ox_Inventory Integration**: Full compatibility with ox_inventory for item management
- **Centralized Configuration**: Simplified config structure with global settings
- **Comprehensive Error Handling**: Robust validation and error recovery throughout
- **Prop Cleanup System**: Automatic cleanup on resource stop/restart
- **Win/Lose Animations**: Visual feedback with celebration and disappointment reactions
- **Performance Optimized**: Efficient code with minimal resource usage
- **Network Synchronized**: Proper entity management and synchronization

## 📋 Dependencies

**Required:**
- ox_lib
- ox_target
- ox_inventory

**Optional:**
- Any framework (ESX, QBCore, etc.) - script is framework agnostic

## 🚀 Installation

1. Ensure all required dependencies are installed and running
2. Place the resource in your server's resources folder
3. Add `ensure gldnrmz-clawmachine` to your server.cfg
4. Configure machine locations in `config.lua`
5. Restart your server

## ⚙️ Configuration

The script uses a simplified, centralized configuration system:

```lua
Config = {
    price = 10,           -- Global price for all machines
    prizechance = 35,     -- Global win chance percentage
    progressTime = 7500,  -- Animation duration in milliseconds
    
    -- Single prize pool for all machines
    prizes = {
        { item = "meth", chance = 20, label = "Meth" },
        { item = "coke", chance = 20, label = "Cocaine" },
        { item = "rubber", chance = 25, label = "Rubber" },
        { item = "goldbar", chance = 25, label = "Gold Bar" },
        { item = "diamond", chance = 10, label = "Diamond" }
    },
    
    -- Machine locations (add as many as needed)
    machines = {
        vector4(-1659.94, -1070.68, 12.16, 140.28),
        vector4(-1650.24, -1074.47, 12.16, 140.28),
        -- Add more locations...
    },
    
    -- Localization
    Text = {
        ['use_claw'] = 'Use Claw Machine $',
        ['grab_toy'] = 'Grabbing toy...',
        ['ate_money'] = 'The machine ate your money!'
    }
}
```

## 🎮 Usage

1. **Approach** any claw machine at configured locations
2. **Interact** using ox_target (look at the machine)
3. **Pay** the configured amount (automatically deducted from inventory)
4. **Watch** the progress bar and animation
5. **Receive** your prize or see the lose animation

## 🔧 Technical Features

### Error Handling
- Comprehensive validation for all user inputs and server responses
- Graceful fallbacks for animation and interaction failures
- Detailed console logging for debugging
- Automatic refunds on system errors

### Performance Optimizations
- Efficient model loading and caching
- Proper entity cleanup and memory management
- Minimal network events and optimized data transfer
- Resource-aware prop management

### Modern Practices
- Uses ox_lib for all utility functions
- Proper async/await patterns where applicable
- Clean code structure with modular functions
- Framework-agnostic design

## 🎯 Animations

**Win Reactions:**
- Primary: Thumbs up celebration
- Fallback: Cheering scenario

**Lose Reactions:**
- Primary: Disappointment gesture
- Fallback: Impatient standing

## 🛠️ Troubleshooting

**Common Issues:**

1. **Machines not spawning**: Check console for model loading errors
2. **No interactions**: Verify ox_target is running and configured
3. **Inventory errors**: Ensure ox_inventory is properly set up
4. **Animation issues**: Animations will fallback to scenarios if dictionaries fail

**Debug Mode:**
Check F8 console for detailed error messages and system status.

## 📝 Changelog

### v2.0.0 (Latest)
- Complete modernization and rewrite
- Added ox_lib, ox_target, and ox_inventory integration
- Implemented comprehensive error handling
- Simplified configuration structure
- Added prop cleanup system
- Fixed win/lose animations
- Performance optimizations
- Framework-agnostic design

## 👥 Credits

- **Original Author**: Demo#1180
- **Modernization**: AI Assistant
- **Version**: 2.0.0

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

---

**Note**: This is a modernized version of the original QB Claw Machine script, updated with current FiveM best practices and improved functionality.