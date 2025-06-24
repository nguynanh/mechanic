
local sprayGuns = {}
local isEffectActive = false
local activeParticles = {}
local currLocation

local function _ShowNotification(msg)
    lib.notify({ title = msg })
end

local function _ShowHelpNotification(msg)
    lib.showTextUI(msg)
end

local function _GetPlayerJobName()
    return exports['qb-core']:GetCoreObject().Functions.GetPlayerData().job.name
end

local function _GetClosestVehicle(location)
    return exports['qb-core']:GetCoreObject().Functions.GetClosestVehicle(location)
end

local rainbowColors = {
    {r = 255, g = 0, b = 0},
    {r = 0, g = 255, b = 0},
    {r = 0, g = 0, b = 255},
    {r = 255, g = 255, b = 0},
    {r = 255, g = 0, b = 255},
    {r = 0, g = 255, b = 255},
}

function SpawnSprayGuns(id)
    local hash = GetHashKey(Config.SprayModel)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    for k, v in ipairs(Config.Locations[id].sprays) do
        local object = CreateObject(hash, v.pos.x, v.pos.y, v.pos.z, false, true, false)
        SetEntityRotation(object, v.rotation.x, v.rotation.y, v.rotation.z, 0, 1)
        FreezeEntityPosition(object, true)
        table.insert(sprayGuns, { object = object, id = id, location = k })
    end
end

function SprayParticles(dict, name, scale, color, entity, rotation)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do Wait(10) end
    UseParticleFxAsset(dict)
    local handle = StartParticleFxLoopedOnEntity(name, entity, 0.2, 0.0, 0.1, 0.0, 80.0, 0.0, scale, false, false, false)
    if color and color.r then
        SetParticleFxLoopedColour(handle, color.r / 255.0, color.g / 255.0, color.b / 255.0)
    end
    SetParticleFxLoopedAlpha(handle, 1.0)
    return handle
end

Citizen.CreateThread(function()
    for k in ipairs(Config.Locations) do
        SpawnSprayGuns(k)
    end

    if not Config.UseTarget then
        while true do
            Wait(1000)
            local coords = GetEntityCoords(PlayerPedId())
            currLocation = nil
            for k, v in ipairs(Config.Locations) do
                if #(coords - v.control) < 15.0 then
                    currLocation = k
                    break
                end
            end
        end
    end
end)

-- Hàm để bắt đầu hiệu ứng phun sơn
function StartSonSprayEffect()
    if not currLocation then return end -- Đảm bảo người chơi đang ở gần khu vực
    if not isEffectActive then
        isEffectActive = true
        _ShowNotification("🚿 Đã bật phun sơn từ súng!")

        local sprays = Config.Locations[currLocation].sprays
        -- Xóa các particle cũ nếu có để tránh trùng lặp
        for _, p in ipairs(activeParticles) do
            StopParticleFxLooped(p, false)
        end
        activeParticles = {}
        -- Tạo particle mới
        for i, spray in ipairs(sprays) do
            local gun = sprayGuns[i]
            if gun then
                local color = rainbowColors[(i - 1) % #rainbowColors + 1]
                local particle = SprayParticles("core", "ent_amb_steam", spray.scale, color, gun.object, spray.rotation)
                table.insert(activeParticles, particle)
            end
        end
    end
end

-- Hàm để dừng hiệu ứng phun sơn
function StopSonSprayEffect()
    if isEffectActive then
        isEffectActive = false
        _ShowNotification("❌ Đã tắt phun sơn từ súng.")
        for _, p in ipairs(activeParticles) do
            StopParticleFxLooped(p, false)
        end
        activeParticles = {}
    end
end