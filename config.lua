Config = {
    -- Framework & System Configuration
    -- Set to 'auto' to auto-detect, or manually specify: 'qb', 'qbox', 'esx', 'none'
    Framework = 'auto',
    
    -- Target system: 'auto' (detects ox_target > qb-target), 'ox_target', 'qb-target', 'none'
    Target = 'auto',
    
    -- Inventory system: 'auto' (detects ox_inventory first, then framework inventory), 'ox_inventory', 'framework', 'none'
    Inventory = 'auto',
    
    -- Global settings
    price = 10,
    prizechance = 40,
    progressTime = 7500,
    
    -- Single prize pool for all machines
    prizes = {
        { item = 'cash',                chance = 75, amount = 10,   label = 'Money' }, 
        { item = 'cash',                chance = 50, amount = 50,   label = 'Money' }, 
        { item = 'cash',                chance = 25, amount = 100,  label = 'Money' }, 
        { item = 'cash',                chance = 10, amount = 1000, label = 'Money' }, 
        { item = 'twerks_candy',        chance = 50, amount = 1,    label = 'Candy' }, 
        { item = 'snikkel_candy',       chance = 50, amount = 1,    label = 'Candy' }, 
        { item = 'strawberrygummybear', chance = 15, amount = 1,    label = 'Gummy Bear' }, 
        { item = 'raspberrygummybear',  chance = 15, amount = 1,    label = 'Gummy Bear' }, 
        { item = 'ak47_cookie',         chance = 15, amount = 1,    label = 'Cookie' }, 
        { item = 'skunk_cookie',        chance = 15, amount = 1,    label = 'Cookie' }, 
        { item = 'whitewidow_cookie',   chance = 15, amount = 1,    label = 'Cookie' }, 
        { item = 'goldbar',             chance = 8,  amount = 1,    label = 'Gold Bar' }, 
        { item = 'shitgpu',             chance = 2,  amount = 1,    label = 'GPU' },
        { item = '1050gpu',             chance = 2,  amount = 1,    label = 'GPU' },
        { item = '1060gpu',             chance = 2,  amount = 1,    label = 'GPU' },
        { item = 'bintenbo',            chance = 5,  amount = 1,    label = 'Console' },
        { item = 'gamebox',             chance = 5,  amount = 1,    label = 'Console' },
        { item = 'plugstation',         chance = 5,  amount = 1,    label = 'Console' },
    },
    
    -- Machine locations
    machines = {
        vector4(195.64, -249.91, 54.07, 159.21), -- White Widow
        vector4(-571.61, -1054.2, 22.34, 90.47), -- UWU
        vector4(-1199.12, -890.24, 13.89, 303.16), -- Old BuegerShot
        vector4(-1593.48, 5205.01, 4.32, 298.4), -- Fishing Store
        vector4(-306.66, 6273.11, 31.48, 228.52), -- Hen House
        vector4(1183.74, 2702.13, 38.17, 179.78), -- Route 68 Fleeca
        vector4(2560.19, 381.68, 108.62, 269.52), -- Palamino 24/7
        vector4(485.86, -1532.05, 29.27, 232.96), -- Himen Bar
        vector4(1242.44, -354.31, 69.21, 74.83), -- New BurgerShot
        vector4(-1507.98, 1502.89, 115.29, 254.97),-- Tongva Dr
        vector4(-2193.65, 4290.13, 49.17, 59.1), -- Hookies
        vector4(166.06, 6631.68, 31.54, 133.74), -- Poleto 24/7
        vector4(1701.89, 4935.17, 42.08, 54.58), -- Grapeseepd LTD
        vector4(2534.52, 2600.17, 37.95, 25.57), -- Rex's Diner
        vector4(954.95, 33.59, 81.0, 148.13), -- Casino
        vec4(13.36, -1606.71, 29.4, 140.13), -- Taco Famrer
        vec4(-1178.92, -1187.09, 5.71, 99.99), --BCM
    },
    
    -- Localization
    Text = {
        ['claw_machine'] = 'Claw Machine',
        ['use_claw'] = 'Use Claw Machine $',
        ['grab_toy'] = 'Working Joystick...',
        ['ate_money'] = 'You dropped it...'
    }
}