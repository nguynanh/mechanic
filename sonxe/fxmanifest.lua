fx_version 'cerulean'
game 'gta5'

author 'BryaN'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@oxmysql/lib/MySQL.lua', -- This line is crucial
    'config.lua',
}

client_scripts {
    'functions.lua',
    'client.lua',
}
server_script 'server.lua'

dependencies {
    'ox_lib',
    'oxmysql', -- This line is also important
}