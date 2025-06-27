-- Functions

local function RepairPart(vehicle, plate, component)
    local materials = Config.WearableParts[component].repair
    local hasItems = exports['ps-inventory']:HasItem(materials)
    if not hasItems then
        QBCore.Functions.Notify(Lang:t('warning.no_materials'), 'error')
        return
    end
    local componentLabel = Config.WearableParts[component].label or component
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', string.format(Lang:t('progress.repairing'), componentLabel), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        ToggleHood(vehicle)
        QBCore.Functions.Notify(string.format(Lang:t('success.part_repaired'), componentLabel), 'success')
        for item, amount in pairs(materials) do
            TriggerServerEvent('qb-mechanicjob:server:removeItem', item, amount)
        end
        TriggerServerEvent('qb-mechanicjob:server:repairVehicleComponent', plate, component)
    end, function()
        ToggleHood(vehicle)
    end)
end

-- Events

RegisterNetEvent('qb-mechanicjob:client:PartsMenu', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    local plate = QBCore.Functions.GetPlate(vehicle)
    if not plate then return end
    local vehicleClass = GetVehicleClass(vehicle)
    if Config.IgnoreClasses[vehicleClass] then return end
    QBCore.Functions.TriggerCallback('qb-mechanicjob:server:getVehicleStatus', function(status)
        if not status then return end

        local function getHealthColor(health)
            if health <= 250 then
                return 'red'
            elseif health <= 500 then
                return 'yellow'
            else
                return 'green'
            end
        end

        local engineHealth = GetVehicleEngineHealth(vehicle)
        local bodyHealth = GetVehicleBodyHealth(vehicle)
        local petrolTankHealth = GetVehiclePetrolTankHealth(vehicle)

        local vehicleMenu = {
            { header = Lang:t('menu.vehicle_stats'), isMenuHeader = true,                                                                                                                                                  icon = 'fas fa-gears' },
            { header = Lang:t('menu.engine_health'), txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(engineHealth) .. ';">' .. math.ceil((engineHealth / 1000) * 100) .. '%</span>',        isMenuHeader = true },
            { header = Lang:t('menu.body_health'),   txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(bodyHealth) .. ';">' .. math.ceil((bodyHealth / 1000) * 100) .. '%</span>',            isMenuHeader = true },
            { header = Lang:t('menu.fuel_health'),   txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(petrolTankHealth) .. ';">' .. math.ceil((petrolTankHealth / 1000) * 100) .. '%</span>', isMenuHeader = true },
        }

        -- Components
        for component, value in pairs(status) do
            local color = 'green'
            local percentage = math.ceil((value / Config.WearableParts[component].maxValue) * 100)

            if value <= Config.DamageThreshold then
                color = 'red'
            elseif value <= Config.WarningThreshold then
                color = 'yellow'
            end

            local statusText = '<span style="color:' .. color .. ';">' .. percentage .. '%</span>'

            vehicleMenu[#vehicleMenu + 1] = {
                header = Config.WearableParts[component].label or component,
                txt = Lang:t('menu.status') .. ': ' .. statusText,
                params = {
                    isAction = true,
                    event = function()
                        RepairPart(vehicle, plate, component)
                    end,
                    args = {}
                }
            }
        end
                local tiresBroken = false
        for i = 0, 5 do
            if IsVehicleTyreBurst(vehicle, i, false) then
                tiresBroken = true
                break
            end
        end
        if tiresBroken then
            vehicleMenu[#vehicleMenu + 1] = {
                header = 'Sửa Lốp xe',
                txt = 'Yêu cầu: 1x Bộ vá lốp', -- Sử dụng vật phẩm tirerepairkit có sẵn
                icon = 'fas fa-car-burst',
                params = {
                    event = 'qb-mechanicjob:client:repairTire'
                }
            }
        end

        -- Kiểm tra và thêm tùy chọn sửa KÍNH XE
        local windowsBroken = false
        for i = 0, 7 do
            if IsVehicleWindowIntact(vehicle, i) == 0 then
                windowsBroken = true
                break
            end
        end
        if windowsBroken then
            vehicleMenu[#vehicleMenu + 1] = {
                header = 'Sửa Kính xe',
                txt = 'Yêu cầu: 1x Bộ dụng cụ sửa chữa', -- Thay đổi mô tả
                icon = 'fas fa-window-maximize',
                params = {
                    isAction = true,
                    event = function() RepairWindows(vehicle) end
                }
            }
        end

        -- Kiểm tra và thêm tùy chọn sửa CỬA XE
        local doorsBroken = false
        for i = 0, 5 do
            if IsVehicleDoorDamaged(vehicle, i) then
                doorsBroken = true
                break
            end
        end
        if doorsBroken then
            vehicleMenu[#vehicleMenu + 1] = {
                header = 'Sửa Cửa xe',
                txt = 'Yêu cầu: 1x Bộ dụng cụ sửa chữa', -- Thay đổi mô tả
                icon = 'fas fa-door-open',
                params = {
                    isAction = true,
                    event = function() RepairDoors(vehicle) end
                }
            }
        end

        -- Kiểm tra và thêm tùy chọn sửa ĐÈN XE
        local lightsBroken = false
        for i=0,1 do -- 0 = đèn trước trái, 1 = đèn trước phải
            if GetVehicleLightDamaged(vehicle, i) then
                lightsBroken = true
                break
            end
        end
        if lightsBroken then
            vehicleMenu[#vehicleMenu + 1] = {
                header = 'Sửa Đèn xe',
                txt = 'Yêu cầu: 1x Bộ dụng cụ sửa chữa', -- Thay đổi mô tả
                icon = 'fas fa-lightbulb',
                params = {
                    isAction = true,
                    event = function() RepairLights(vehicle) end
                }
            }
        end
        vehicleMenu[#vehicleMenu + 1] = {
            header = Lang:t('menu.close'),
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
        exports['qb-menu']:openMenu(vehicleMenu)
    end, plate)
end)

RegisterNetEvent('qb-mechanicjob:client:repairVehicle', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', Lang:t('progress.repair_vehicle'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleEngineHealth(vehicle, engineHealth + 100)
        SetVehicleBodyHealth(vehicle, bodyHealth + 100)
        ToggleHood(vehicle)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'repairkit')
    end, function()
        ToggleHood(vehicle)
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:repairVehicleFull', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', Lang:t('progress.repair_vehicle'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleFixed(vehicle)
        ToggleHood(vehicle)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'advancedrepairkit')
    end, function()
        ToggleHood(vehicle)
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:repairTire', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    local closestWheel = GetClosestWheel(vehicle)
    if not closestWheel then return end
    QBCore.Functions.Progressbar('repairing_tire', Lang:t('progress.repair_tire'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer',
        flags = 1,
    }, {
        model = 'prop_wheel_tyre',
        bone = 60309,
        coords = vec3(-0.05, 0.16, 0.32),
        rotation = vec3(-130.0, -55.0, 150.0),
    }, {}, function()
        SetVehicleTyreFixed(vehicle, closestWheel)
        QBCore.Functions.Notify(Lang:t('success.tire_repaired'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'tirerepairkit')
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:cleanVehicle', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    QBCore.Functions.Progressbar('cleaning_vehicle', Lang:t('progress.cleaning'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@world_human_maid_clean@',
        anim = 'base',
        flags = 1,
    }, {
        model = 'prop_sponge_01',
        bone = 28422,
        coords = vec3(0.0, 0.0, -0.01),
        rotation = vec3(90.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleDirtLevel(vehicle, 0.0)
        QBCore.Functions.Notify(Lang:t('success.cleaned'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'cleaningkit')
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:fixEverything', function()
    QBCore.Functions.TriggerCallback('qb-mechanicjob:server:hasPermission', function(hasPermission)
        if not hasPermission then return end
        local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleFixed(vehicle)
        for i = 0, 5 do
            SetVehicleTyreFixed(vehicle, i)
        end
        for i = 0, 7 do
            FixVehicleWindow(vehicle, i)
        end
        exports[Config.FuelResource]:SetFuel(vehicle, 100)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
    end)
end)
ocal function RepairWindows(vehicle)
    -- Kiểm tra xem người chơi có 'repairkit' không
    if not exports['ps-inventory']:HasItem('repairkit', 1) then
        QBCore.Functions.Notify('Bạn không có Bộ dụng cụ sửa chữa!', 'error')
        return
    end
    QBCore.Functions.Progressbar('repairing_windows', 'Đang sửa kính xe...', 8000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {}, {}, function()
        for i = 0, 7 do
            FixVehicleWindow(vehicle, i)
        end
        -- Trừ đi 1 'repairkit'
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'repairkit', 1)
        QBCore.Functions.Notify('Tất cả kính xe đã được sửa!', 'success')
    end)
end

-- Hàm sửa Cửa xe
local function RepairDoors(vehicle)
    if not exports['ps-inventory']:HasItem('repairkit', 1) then
        QBCore.Functions.Notify('Bạn không có Bộ dụng cụ sửa chữa!', 'error')
        return
    end
    QBCore.Functions.Progressbar('repairing_doors', 'Đang nắn lại cửa xe...', 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
    }, {
        animDict = 'amb@world_human_vehicle_mechanic@male@base',
        anim = 'base',
        flags = 1,
    }, {}, {}, function()
        for i = 0, 5 do
            SetVehicleDoorBroken(vehicle, i, false)
        end
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'repairkit', 1)
        QBCore.Functions.Notify('Các cửa xe đã được sửa!', 'success')
    end)
end

-- Hàm sửa Đèn xe
local function RepairLights(vehicle)
    if not exports['ps-inventory']:HasItem('repairkit', 1) then
        QBCore.Functions.Notify('Bạn không có Bộ dụng cụ sửa chữa!', 'error')
        return
    end
    QBCore.Functions.Progressbar('repairing_lights', 'Đang thay thế đèn xe...', 7000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {}, {}, function()
        -- SetVehicleFixed là cách hiệu quả nhất để sửa đèn và các hư hỏng thân vỏ khác.
        -- Lưu ý: Lệnh này cũng sẽ sửa các hư hỏng nhỏ khác trên thân xe.
        SetVehicleFixed(vehicle)
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'repairkit', 1)
        QBCore.Functions.Notify('Hệ thống đèn đã được sửa!', 'success')
    end)
end