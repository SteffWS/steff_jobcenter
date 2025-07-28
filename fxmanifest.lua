fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Steff'
description 'Advanced QB Job Center'
version '1.0.0'

shared_scripts {
    -- '@qb-core/import.lua',
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config.lua'
}

client_script {
    'client/cl_main.lua'
}

server_script {
    'server/sv_main.lua'
}

dependencies {
  'qb-core',
}
