-- Settings both the client and the server need.
-- Text shown to players lives in locales/*.json (pick a language with `setr ox:locale en`).
return {
    model = `ch_prop_arcade_claw_01a`,

    price = 10,           -- cost per play
    account = 'money',    -- account charged (community_bridge maps 'money' to cash on QB/QBX)
    playTime = 7500,      -- progress bar length in ms (the server enforces this)

    interactDistance = 1.5, -- target reach in metres
    spawnDistance = 75.0,   -- props only exist while a player is within this range

    blips = {
        enabled = false,
        sprite = 740,
        colour = 48,
        scale = 0.6,
    },

    -- vec4(x, y, z, heading): where the player stands, facing the machine.
    -- The array index is the machine id the server validates against, so append new entries at the end.
    machines = {
        vec4(195.64, -249.91, 54.07, 159.21),   -- White Widow
        vec4(-571.61, -1054.2, 22.34, 90.47),   -- UwU Cafe
        vec4(-1199.12, -890.24, 13.89, 303.16), -- Old Burger Shot
        vec4(-1593.48, 5205.01, 4.32, 298.4),   -- Fishing Store
        vec4(-306.66, 6273.11, 31.48, 228.52),  -- Hen House
        vec4(1183.74, 2702.13, 38.17, 179.78),  -- Route 68 Fleeca
        vec4(2560.19, 381.68, 108.62, 269.52),  -- Palomino 24/7
        vec4(485.86, -1532.05, 29.27, 232.96),  -- Hi-Men Bar
        vec4(1242.44, -354.31, 69.21, 74.83),   -- New Burger Shot
        vec4(-1507.98, 1502.89, 115.29, 254.97),-- Tongva Dr
        vec4(-2193.65, 4290.13, 49.17, 59.1),   -- Hookies
        vec4(166.06, 6631.68, 31.54, 133.74),   -- Paleto 24/7
        vec4(1701.89, 4935.17, 42.08, 54.58),   -- Grapeseed LTD
        vec4(2534.52, 2600.17, 37.95, 25.57),   -- Rex's Diner
        vec4(954.95, 33.59, 81.0, 148.13),      -- Casino
        vec4(13.36, -1606.71, 29.4, 140.13),    -- Taco Farmer
        vec4(-1178.92, -1187.09, 5.71, 99.99),  -- BCM
    },
}
