Config = {}

---------------------------------
-- CẤU HÌNH CHUNG
---------------------------------
Config.FuelResource = 'LegacyFuel'
Config.Debug = false

---------------------------------
-- CẤU HÌNH TÍNH NĂNG TỪ QB-MECHANICJOB GỐC
---------------------------------
Config.RequireJob = false -- Đặt thành true nếu chỉ job mechanic mới dùng được các chức năng của qb-mechanicjob
Config.PaintTime = 5 -- Thời gian (giây) cho mỗi lớp sơn

Config.UseDistance = true
Config.UseDistanceDamage = true
Config.UseWearableParts = true
Config.WearablePartsChance = 1
Config.WearablePartsDamage = math.random(1, 2)
Config.DamageThreshold = 25
Config.WarningThreshold = 50

Config.MinimalMetersForDamage = {
    { min = 5000,  max = 10000, damage = 10 },
    { min = 15000, max = 20000, damage = 20 },
    { min = 25000, max = 30000, damage = 30 },
}

Config.WearableParts = {
    radiator = { label = 'Radiator', maxValue = 100, repair = { steel = 2 } },
    axle = { label = 'Axle', maxValue = 100, repair = { aluminum = 2 } },
    brakes = { label = 'Brakes', maxValue = 100, repair = { copper = 2 } },
    clutch = { label = 'Clutch', maxValue = 100, repair = { copper = 2 } },
    fuel = { label = 'Fuel', maxValue = 100, repair = { plastic = 2 } },
}

Config.Shops = {
    bennys = {
        managed = true,
        shopLabel = 'Benny\'s Motorworks',
        showBlip = true,
        blipSprite = 72,
        blipColor = 46,
        blipCoords = vector3(-211.73, -1325.28, 30.89),
        duty = vector3(-202.92, -1313.74, 31.70),
        stash = vector3(-199.58, -1314.65, 31.08),
        paint = vector3(-202.42, -1322.16, 31.29),
        vehicles = {
            withdraw = vector3(-187.25, -1310.55, 31.3),
            spawn = vector4(-182.74, -1317.61, 30.63, 357.23),
            list = { 'flatbed', 'towtruck', 'minivan', 'blista' }
        },
    },
}

---------------------------------
-- CẤU HÌNH TÍCH HỢP TỪ JIM-MECHANIC
---------------------------------

-- Cấu hình NOS
Config.NosRefillCharge = 1000
Config.NosTopSpeed = 55.0
Config.NosBoostPower = { 10.0, 30.0, 50.0 }
Config.NitrousUseRate = 0.4
Config.NitrousCoolDown = 7
Config.CooldownConfirm = true
Config.nosDamage = true
Config.boostExplode = true
Config.skillcheck = "ps-ui" -- Các lựa chọn: "qb-lock", "ps-ui", "qb-skillbar", hoặc false để tắt
Config.explosiveFail = true -- Đặt thành true để bật nguy cơ nổ khi thất bại
Config.explosiveFailJob = false -- Nếu false, thợ máy sẽ không gây nổ

-- Hiệu ứng NOS
Config.EnableFlame = true
Config.EnableTrails = true
Config.EnableScreen = true

-- Cấu hình trạm nạp NOS
Config.NosRefillStation = {
    coords = vector3(-228.15, -1334.16, 30.89),
    blip = { colour = 75, id = 569, scale = 0.8 },
     polyzone = { -- <-- THÊM MỤC NÀY
            vector2(-189.07, -1311.31),
            vector2(-188.36, -1343.46),
            vector2(-217.37, -1343.54),
            vector2(-244.44, -1342.33),
            vector2(-244.07, -1312.06)
       },
    target = {
        item = "noscan",
        icon = "fas fa-gas-pump",
        label = "Nạp lại bình NOS"
    }
}

-- Cấu hình Preview
Config.PreviewPhone = true
Config.PreviewJob = false
Config.PreviewLocation = false
Config.PhoneMail = "qb" -- "qb", "gks", "qs"
Config.DiscordPreview = false
Config.DiscordDefault = ""
Config.DiscordColour = 16753920
-- Thêm vào cuối tệp qb-mechanicjob/config/config.lua

-- tệp: qb-mechanicjob/config.lua

Config.PreviewSpot = {
    enabled = true,
    coords = vector3(-211.72, -1324.1, 30.27),
    
    -- Cài đặt cho tương tác "Nhấn E"
    interaction = {
        radius = 3.0,
        label = "Xem trước tùy chỉnh",
        icon = "fas fa-eye",
    },

    -- Cài đặt cho Marker hiển thị trên mặt đất
    marker = {
        enabled = true,
        drawDist = 20.0,
        type = 23,
        size = { x = 3.0, y = 3.0, z = 0.5 },
        color = { r = 255, g = 0, b = 0, a = 100 },
        zOffset = -0.35
    },

    -- CÀI ĐẶT CHO BLIP TRÊN BẢN ĐỒ (Thêm mục này)
    blip = {
        enabled = true, -- Đặt thành false để tắt blip
        sprite = 15,    -- ID của icon blip (72 là icon của Benny's)
        display = 4,    -- Cách hiển thị (4 là luôn luôn)
        scale = 0.7,    -- Kích thước blip
        color = 46,     -- Màu của blip (46 là màu xanh lá cây nhạt)
        label = "Điểm Xem Trước Xe" -- Tên hiển thị trên bản đồ
    }
}
