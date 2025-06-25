fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot & Jimathy (Merged by Nguyn Anh)'
description 'Custom Mechanic Job'
version '4.1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config/config.lua',
    'config/const.lua',
    'locales/*.lua'
}

client_scripts {
    'client/functions.lua', -- Tệp chứa TẤT CẢ các hàm phụ trợ của client
    'client/main.lua',
    'client/cosmetic.lua',
    'client/drivingdistance.lua',
    'client/performance.lua',
    'client/repair.lua',
    'client/tunerchip.lua',
    'client/cl_nos.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/sv_nos.lua'
}

ui_page 'html/index.html'

files {
    'html/*',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta'
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'