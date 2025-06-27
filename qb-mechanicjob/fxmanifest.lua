fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Merged by Nguyn Anh '
description 'Custom Mechanic Job - Unified Version'
version '5.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config/config.lua',
    'config/const.lua',
    'locales/*.lua'
}

client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/cosmetic.lua',
    'client/drivingdistance.lua',
    'client/performance.lua',
    'client/repair.lua',
    'client/cl_nos.lua',
    'client/cl_preview.lua',
    'client/tuning_tablet.lua' -- Thêm tệp preview
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/sv_nos.lua' -- Tách biệt logic NOS
}

ui_page "web/index.html"

files {
    'html/index.html',
    'html/js/main.js',
    'html/js/vue.min.js',
    'html/assets/css/style.css',
    'html/assets/css/tuning.css',
    'html/assets/css/notify.css',
    'html/assets/img/tuning/*.png',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta'
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'