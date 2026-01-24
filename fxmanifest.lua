fx_version 'cerulean'
game 'gta5'

name 'gldnrmz-clawmachine'
author 'GLDNRMZ'
description 'Framework-agnostic, Target-agnostic, Inventory-agnostic Claw Machine'
version '2.1.0'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {
    'ox_lib',
}

optional_dependencies {
    'qb-core',
    'qbox',
    'es_extended',
    'ox_target',
    'qb-target',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

files {
    'bridge/framework.lua',
    'bridge/target.lua',
    'bridge/inventory.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}