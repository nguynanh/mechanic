
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

Citizen.CreateThread(function()
    local isDrawn = false
    while true do
        local sleep = 500
        if currLocation and Config.Locations[currLocation] then
            local dist = #(GetEntityCoords(PlayerPedId()) - Config.Locations[currLocation].control)
            if dist < 1.5 then
                sleep = 5
                DrawMarker(27, Config.Locations[currLocation].control.x, Config.Locations[currLocation].control.y, Config.Locations[currLocation].control.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 150, false, false, 2, true, nil, nil, false)
                if dist < 1.5 then
                    if not isDrawn then
                        _ShowHelpNotification("Nhấn [E] để bật/tắt phun sơn")
                        isDrawn = true
                    end
                elseif isDrawn then
                    lib.hideTextUI()
                    isDrawn = false
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterCommand("toggleSpray", function()
    if not currLocation then
        _ShowNotification("Bạn không ở gần khu vực phun.")
        return
    end

    local vehicle = GetVehicleInSprayCoords(Config.Locations[currLocation].vehicle)
    if not vehicle then
        _ShowNotification("Không có xe ở khu vực phun.")
        return
    end

    if not isEffectActive then
        isEffectActive = true
        _ShowNotification("🚿 Đã bật phun sơn!")

        local sprays = Config.Locations[currLocation].sprays
        for i, spray in ipairs(sprays) do
            local gun = sprayGuns[i]
            if gun then
                local color = rainbowColors[(i - 1) % #rainbowColors + 1]
                local particle = SprayParticles("core", "ent_amb_steam", spray.scale, color, gun.object, spray.rotation)
                table.insert(activeParticles, particle)
            end
        end
    else
        isEffectActive = false
        _ShowNotification("❌ Đã tắt phun sơn.")
        for _, p in ipairs(activeParticles) do
            StopParticleFxLooped(p, false)
        end
        activeParticles = {}
    end
end, false)

RegisterKeyMapping("toggleSpray", "Bật/Tắt hiệu ứng phun sơn", "keyboard", "E")

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, v in ipairs(sprayGuns) do
            if DoesEntityExist(v.object) then DeleteEntity(v.object) end
        end
        sprayGuns = {}
    end
end)

function GetVehicleInSprayCoords(location)
    local closestVehicle, closestDistance = _GetClosestVehicle(location)
    if closestVehicle and closestDistance <= 4.0 then
        return closestVehicle
    end
    return nil
end
