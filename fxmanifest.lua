fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'gldnrmz-clawmachine'
author 'GLDNRMZ'
description 'Framework, target and inventory agnostic claw machines'
version '3.0.1'
repository 'https://github.com/GLDNRMZ/gldnrmz-clawmachine'

ox_lib 'locale'

dependencies {
    '/onesync',
    'ox_lib',
    'community_bridge',
}

shared_script '@ox_lib/init.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

-- config/server.lua is intentionally NOT listed here so prize odds never reach clients.
files {
    'config/shared.lua',
    'locales/*.json',
}
