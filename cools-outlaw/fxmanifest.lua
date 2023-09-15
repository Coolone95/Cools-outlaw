fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Coolone95'
description 'cools-outlaw'

escrow_ignore {
    'config.lua',
}

shared_scripts {
    '@rsg-core/shared/locale.lua',
    'locales/en.lua', -- preferred language
    'config.lua',
}

client_scripts {
    'client/*.lua',
	'client/menu.lua',
	'json.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
	'json.lua',
}

lua54 'yes'