fx_version 'cerulean'
game 'gta5'

name 'gldnrmz-clawmachine'
author 'GLDNRMZ'
description 'Interactive Claw Machine with ox_inventory integration'
version '1.1.0'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}