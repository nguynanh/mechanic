local vehicle, plate
local vehicleComponents = {}
local drivingDistance = {}

-- Function

local function InitializeVehicleComponents()
    if not Config.UseWearableParts then return end
    vehicleComponents[plate] = {}
    for part, data in pairs(Config.WearableParts) do
        vehicleComponents[plate][part] = data.maxValue
    end
end

local function ApplyComponentEffect(component) -- add custom effects here for each component in config
    if component == 'radiator' then
        local engineHealth = GetVehicleEngineHealth(vehicle)
        SetVehicleEngineHealth(vehicle, engineHealth - 50)
    elseif component == 'axle' then
        for i = 0, 360 do
            Wait(15)
            SetVehicleSteeringScale(vehicle, i)
        end
    elseif component == 'brakes' then
        SetVehicleHandbrake(vehicle, true)
        Wait(5000)
        SetVehicleHandbrake(vehicle, false)
    elseif component == 'clutch' then
        SetVehicleEngineOn(vehicle, false, false, true)
        SetVehicleUndriveable(vehicle, true)
        Wait(5000)
        SetVehicleEngineOn(vehicle, true, false, true)
        SetVehicleUndriveable(vehicle, false)
    elseif component == 'fuel' then
        local fuel = exports[Config.FuelResource]:GetFuel(vehicle)
        exports[Config.FuelResource]:SetFuel(vehicle, fuel - 10)
    end
end

local function DamageRandomComponent()
    if not Config.UseWearableParts then return end
    local componentKeys = {}
    for component, _ in pairs(Config.WearableParts) do
        componentKeys[#componentKeys + 1] = component
    end
    local componentToDamage = componentKeys[math.random(#componentKeys)]
    vehicleComponents[plate][componentToDamage] = math.max(0, vehicleComponents[plate][componentToDamage] - Config.WearablePartsDamage)
    if vehicleComponents[plate][componentToDamage] <= Config.DamageThreshold then
        ApplyComponentEffect(componentToDamage)
    end
end

local function GetDamageAmount(distance)
    for _, tier in ipairs(Config.MinimalMetersForDamage) do
        if distance >= tier.min and distance < tier.max then
            return tier.damage
        end
    end
    return 0
end

local function ApplyDamageBasedOnDistance(distance)
    if not Config.UseDistanceDamage then return end
    local damage = GetDamageAmount(distance)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    SetVehicleEngineHealth(vehicle, engineHealth - damage)
end

local function TrackDistance()
    CreateThread(function()
        while true do
            Wait(0)
            if not vehicle then break end

            local ped = PlayerPedId()
            local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
            local speed = GetEntitySpeed(vehicle)

            if isDriver then
                if plate and speed > 5 then
                    if not drivingDistance[plate] then
                        drivingDistance[plate] = { distance = 0, lastCoords = GetEntityCoords(vehicle) }
                        InitializeVehicleComponents()
                    else
                        local newCoords = GetEntityCoords(vehicle)
                        local distance = #(drivingDistance[plate].lastCoords - newCoords)
                        if distance < 5 then
                            drivingDistance[plate].distance = drivingDistance[plate].distance + distance
                            drivingDistance[plate].lastCoords = newCoords
                            -- Engine damage
                            local accumulatedDistance = drivingDistance[plate].distance
                            if accumulatedDistance >= Config.MinimalMetersForDamage[1].min then
                                ApplyDamageBasedOnDistance(accumulatedDistance)
                            end
                            -- Parts Damage
                            local randomNumber = math.random(1, 1000)
                            if randomNumber <= Config.WearablePartsChance then
                                DamageRandomComponent()
                            end
                        end
                    end
                end
            else
                if drivingDistance[plate] then
                    TriggerServerEvent('qb-mechanicjob:server:updateDrivingDistance', plate, drivingDistance[plate].distance)
                    TriggerServerEvent('qb-mechanicjob:server:updateVehicleComponents', plate, vehicleComponents[plate])
                end
                plate = nil
                vehicle = nil
                break
            end
        end
    end)
end

-- Handler

AddEventHandler('gameEventTriggered', function(event)
    if event == 'CEventNetworkPlayerEnteredVehicle' then
        if not Config.UseDistance then return end
        vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local originalPlate = GetVehicleNumberPlateText(vehicle)
        if not originalPlate then return end
        plate = Trim(originalPlate)
        local vehicleClass = GetVehicleClass(vehicle)
        if Config.IgnoreClasses[vehicleClass] then return end
        TrackDistance()
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    -- Lấy dữ liệu người chơi khi script bắt đầu
    PlayerData = QBCore.Functions.GetPlayerData()
end)

-- Sự kiện này chạy khi người chơi đã tải vào game thành công
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()

    -- Tạo các blip và khu vực tương tác (target zone) cho các cửa hàng cơ khí
    for k, v in pairs(Config.Shops) do
        -- Nếu tùy chọn showBlip được bật trong config, tạo blip trên bản đồ
        if v.showBlip then
            local blip = AddBlipForCoord(v.blipCoords)
            SetBlipSprite(blip, v.blipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.6)
            SetBlipColour(blip, v.blipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(v.shopLabel)
            EndTextCommandSetBlipName(blip)
        end

        -- Tạo vùng tương tác để vào/ra ca làm việc (duty)
        exports['qb-target']:AddCircleZone(k .. '_duty', v.duty, 0.5, {
            name = k .. '_duty',
            debugPoly = false,
            useZ = true
        }, {
            options = { {
                type = 'server',
                event = 'QBCore:ToggleDuty',
                label = Lang:t('target.duty'),
                icon = 'fas fa-user-clock',
                job = v.managed and k or nil
            } },
            distance = 2.0
        })

        -- Tạo vùng tương tác cho kho đồ (stash)
        exports['qb-target']:AddCircleZone(k .. '_stash', v.stash, 0.5, {
            name = k .. '_stash',
            debugPoly = false,
            useZ = true
        }, {
            options = { {
                label = Lang:t('target.stash'),
                icon = 'fas fa-box-open',
                job = v.managed and k or nil,
                type = 'server',
                event = 'qb-mechanicjob:server:stash',
            } },
            distance = 2.0
        })

        -- Tạo vùng tương tác cho khu vực sơn xe
        exports['qb-target']:AddCircleZone(k .. '_paintbooth', v.paint, 0.5, {
            name = k .. '_paintbooth',
            debugPoly = false,
            useZ = true
        }, {
            options = { {
                label = Lang:t('target.paint'),
                icon = 'fas fa-fill-drip',
                job = v.managed and k or nil,
                action = function()
                    PaintCategories() -- Gọi hàm từ file cosmetics.lua
                end
            } },
            distance = 2.0
        })

        -- Tạo vùng tương tác để lấy/cất xe của tiệm
        exports['qb-target']:AddCircleZone(k .. '_spawner', v.vehicles.withdraw, 0.5, {
            name = k .. '_spawner',
            debugPoly = false,
            useZ = true
        }, {
            options = {
                {
                    label = Lang:t('target.withdraw'),
                    icon = 'fas fa-car',
                    job = v.managed and k or nil,
                    canInteract = function()
                        -- Chỉ cho phép tương tác khi người chơi không ở trong xe
                        local inVehicle = GetVehiclePedIsUsing(PlayerPedId())
                        if inVehicle ~= 0 then return false end
                        return true
                    end,
                    action = function()
                        VehicleList(k) -- Gọi hàm để hiển thị danh sách xe
                    end
                },
                {
                    label = Lang:t('target.deposit'),
                    icon = 'fas fa-car',
                    job = k,
                    canInteract = function()
                        -- Chỉ cho phép tương tác khi người chơi đang ở trong xe
                        local inVehicle = GetVehiclePedIsUsing(PlayerPedId())
                        if inVehicle == 0 then return false end
                        return true
                    end,
                    action = function()
                        -- Xóa chiếc xe mà người chơi đang ngồi
                        SetEntityAsMissionEntity(GetVehiclePedIsUsing(PlayerPedId()), true, true)
                        DeleteVehicle(GetVehiclePedIsUsing(PlayerPedId()))
                    end
                }
            },
            distance = 5.0
        })
    end
end)


-- Sự kiện này chạy khi job của người chơi được cập nhật
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Sự kiện này chạy khi người chơi thoát game
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

--================================================================
--= GLOBAL FUNCTIONS (Các hàm dùng chung)
--================================================================

-- Hàm loại bỏ các khoảng trắng thừa ở đầu và cuối chuỗi (dùng cho biển số xe)
function Trim(plate)
    return (string.gsub(plate, '^%s*(.-)%s*$', '%1'))
end

-- Hàm đóng/mở nắp capo xe
function ToggleHood(vehicle)
    if GetVehicleDoorAngleRatio(vehicle, 4) > 0.0 then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorOpen(vehicle, 4, false, false)
    end
end

-- Hàm kiểm tra xem người chơi có đứng gần một bộ phận (bone) cụ thể của xe không
function IsNearBone(vehicle, bone)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local vehicleBoneIndex = GetEntityBoneIndexByName(vehicle, bone)
    if vehicleBoneIndex ~= -1 then
        local bonePos = GetWorldPositionOfEntityBone(vehicle, vehicleBoneIndex)
        if #(playerCoords - bonePos) <= 1.5 then
            return true
        end
    end
    return false
end

-- Hàm tìm bánh xe gần người chơi nhất
function GetClosestWheel(vehicle)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestWheelIndex
    for wheelIndex, wheelBone in pairs(Config.WheelBones) do
        local wheelBoneIndex = GetEntityBoneIndexByName(vehicle, wheelBone)
        if wheelBoneIndex ~= -1 then
            local wheelPos = GetWorldPositionOfEntityBone(vehicle, wheelBoneIndex)
            if #(playerCoords - wheelPos) <= 1.5 then
                closestWheelIndex = wheelIndex
                break
            end
        end
    end
    return closestWheelIndex
end

--================================================================
--= LOCAL FUNCTIONS (Các hàm cục bộ)
--================================================================

-- Hàm để spawn xe từ danh sách của tiệm
local function SpawnListVehicle(model, spawnPoint)
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, 'MECH' .. tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, spawnPoint.w)
        exports[Config.FuelResource]:SetFuel(veh, 100.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true, false)
    end, model, spawnPoint, true)
end

-- Hàm hiển thị menu danh sách xe của tiệm
local function VehicleList(shop)
    local vehicleMenu = { { header = Lang:t('menu.vehicle_list'), isMenuHeader = true } }
    local list = Config.Shops[shop].vehicles.list
    for i = 1, #list do
        local v = list[i]
        vehicleMenu[#vehicleMenu + 1] = {
            header = QBCore.Shared.Vehicles[v].name,
            params = {
                event = 'qb-mechanicjob:client:SpawnListVehicle',
                args = {
                    spawnName = v,
                    location = Config.Shops[shop].vehicles.spawn
                }
            }
        }
    end
    vehicleMenu[#vehicleMenu + 1] = {
        header = Lang:t('menu.close'),
        txt = '',
        params = {
            event = 'qb-menu:client:closeMenu'
        }

    }
    exports['qb-menu']:openMenu(vehicleMenu)
end

--================================================================
--= EVENTS (Sự kiện)
--================================================================

-- Sự kiện client để spawn xe từ menu
RegisterNetEvent('qb-mechanicjob:client:SpawnListVehicle', function(data)
    local vehicleSpawnName = data.spawnName
    local spawnPoint = data.location
    SpawnListVehicle(vehicleSpawnName, spawnPoint)
end)