Loc = {}

Config = {}

---------------------------------
-- CẤU HÌNH TỪ QB-MECHANICJOB --
---------------------------------
Config.RequireJob = false
Config.FuelResource = 'LegacyFuel'

Config.PaintTime = 5
Config.ColorFavorites = false

Config.NitrousBoost = 1.8
Config.NitrousUsage = 0.1

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
            withdraw = vector3(0, 0, 0),
            spawn = vector4(-370.51, -107.88, 38.35, 72.56),
            list = { 'flatbed', 'towtruck', 'minivan', 'blista' }
        },
    },
}

---------------------------------
-- CẤU HÌNH TỪ JIM-MECHANIC --
---------------------------------
Config.Lan = "en" -- Ngôn ngữ sử dụng

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
-- Cấu hình cho trạm nạp NOS
Config.NosRefillStation = {
    coords = vector3(-228.15, -1334.16, 30.89),
    blip = { colour = 75, id = 569, scale = 0.8 },
    target = {
        item = "noscan", -- Vật phẩm yêu cầu để nạp
        icon = "fas fa-gas-pump",
        label = "Nạp lại bình NOS"
    }
}

-- Skill Check
Config.skillcheck = "false"
Config.explosiveFail = true
Config.explosiveFailJob = false