-- Server-only settings. This file is never sent to clients.
return {
    winChance = 40,      -- % chance a play wins anything (decimals allowed)
    cooldown = 2000,     -- ms a player must wait between plays
    maxDistance = 3.0,   -- max metres between player and machine, checked on start and finish
    timeTolerance = 750, -- ms of network slack allowed when checking the play actually lasted playTime

    logging = true,      -- send plays to ox_lib's logger (only does anything if `ox:logger` is configured)
    versionCheck = true,

    -- Weighted prize pool. `chance` is a weight, not a percent: a prize's odds are chance / sum of all chances.
    -- Use `item` for inventory items, or `account` to pay straight into a framework account.
    prizes = {
        { account = 'money',            chance = 75, amount = 10,   label = 'Cash' },
        { account = 'money',            chance = 50, amount = 50,   label = 'Cash' },
        { account = 'money',            chance = 25, amount = 100,  label = 'Cash' },
        { account = 'money',            chance = 10, amount = 1000, label = 'Cash' },
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
}
