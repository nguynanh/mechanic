-- Nội dung cho file qb-mechanicjob/client/nos.lua

local nitrousVehicles = {}
local nitrousActive = false
local currentVehicle, currentPlate, currentNetId

-- Nhận dữ liệu NOS từ server
RegisterNetEvent('qb-mechanicjob:client:syncNitrousState', function(plate, data)
    nitrousVehicles[plate] = data
end)

-- Kích hoạt event cài đặt NOS từ server
RegisterNetEvent('qb-mechanicjob:client:installNitrous', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then 
        QBCore.Functions.Notify("Bạn phải ở ngoài xe để cài đặt NOS.", "error")
        return 
    end
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then
        QBCore.Functions.Notify("Không có xe nào ở gần.", "error")
        return
    end

    local isTurboOn = IsToggleModOn(vehicle, 18)
    if not isTurboOn then
        QBCore.Functions.Notify("Xe cần có Turbo để lắp NOS.", "error")
        return
    end

    QBCore.Functions.Progressbar('installing_nos', "Đang lắp đặt NOS...", 7000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
    }, {}, {}, {}, function() -- onFinish
        local plate = QBCore.Functions.GetPlate(vehicle)
        TriggerServerEvent('qb-mechanicjob:server:installNitrous', plate)
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'nitrous') -- 'nitrous' là tên vật phẩm trong shared/items.lua
        QBCore.Functions.Notify("Đã lắp đặt NOS thành công!", "success")
    end, function() -- onCancel
        QBCore.Functions.Notify("Lắp đặt NOS đã bị hủy.", "error")
    end)
end)

-- Vòng lặp chính để xử lý NOS
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local plate = QBCore.Functions.GetPlate(vehicle)

            -- Kiểm tra xem có phải là xe mới không
            if vehicle ~= currentVehicle then
                currentVehicle = vehicle
                currentPlate = plate
                currentNetId = VehToNet(vehicle)
                -- Lấy dữ liệu NOS cho xe hiện tại từ server
                QBCore.Functions.TriggerCallback('qb-mechanicjob:server:GetNosData', function(vehicles)
                    nitrousVehicles = vehicles
                end)
            end

            if nitrousVehicles and nitrousVehicles[currentPlate] and nitrousVehicles[currentPlate].hasnitro == 1 and nitrousVehicles[currentPlate].level > 0 then
                if IsControlPressed(0, 71) then -- Nút Left Shift (có thể đổi)
                    nitrousActive = true
                    SetVehicleBoostActive(currentVehicle, true)
                    -- Giảm mức NOS
                    nitrousVehicles[currentPlate].level = nitrousVehicles[currentPlate].level - Config.NitrousUseRate
                    TriggerEvent('hud:client:UpdateNitrous', nitrousVehicles[currentPlate].level, true) -- Event để cập nhật HUD của bạn
                    -- Hiệu ứng
                    TriggerServerEvent('qb-mechanicjob:server:syncNitrousEffects', currentNetId, 'flames', true)
                else
                    if nitrousActive then
                        nitrousActive = false
                        SetVehicleBoostActive(currentVehicle, false)
                        TriggerServerEvent('qb-mechanicjob:server:syncNitrousEffects', currentNetId, 'flames', false)
                        -- Lưu lại mức NOS khi nhả nút
                        TriggerServerEvent('qb-mechanicjob:server:saveNitrousOnLeave', currentPlate, nitrousVehicles[currentPlate].level)
                    end
                end

                -- Nếu hết NOS
                if nitrousVehicles[currentPlate].level <= 0 then
                    nitrousVehicles[currentPlate].hasnitro = 0
                    TriggerServerEvent('qb-mechanicjob:server:removeNitrous', currentPlate)
                    TriggerEvent('hud:client:UpdateNitrous', 0, false)
                    QBCore.Functions.Notify("NOS đã hết!", "error")
                end

            else
                nitrousActive = false
            end
        else
            if currentVehicle then -- Người chơi vừa rời khỏi xe
                if nitrousVehicles and nitrousVehicles[currentPlate] then
                    TriggerServerEvent('qb-mechanicjob:server:saveNitrousOnLeave', currentPlate, nitrousVehicles[currentPlate].level)
                end
                currentVehicle = nil
                currentPlate = nil
                currentNetId = nil
                nitrousActive = false
                TriggerEvent('hud:client:UpdateNitrous', 0, false)
            end
        end
    end
end)

-- Xử lý hiệu ứng
RegisterNetEvent('qb-mechanicjob:client:playNitrousEffects', function(netId, effectType, toggle)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local vehicle = NetToVeh(netId)
        if effectType == 'flames' then
            SetVehicleNitroEnabled(vehicle, toggle)
        end
    end
end)