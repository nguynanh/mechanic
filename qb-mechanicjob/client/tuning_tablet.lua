-- =================================================================
-- TỆP LOGIC CHO TUNING TABLET - TÍCH HỢP TỪ DUSA_MECHANIC
-- Đã được điều chỉnh để hoạt động với qb-mechanicjob
-- =================================================================

QBCore = exports['qb-core']:GetCoreObject()
local menuOpened = false
local tuning = {}
local LastEngineMultiplier = 1.0

-- Mở giao diện Tuning Tablet
function OpenTuning()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    if vehicle == 0 then return end

    -- Lấy dữ liệu tuning hiện tại của xe (nếu có) để hiển thị trên UI
    -- Bạn cần đảm bảo server gửi dữ liệu này qua, hoặc có thể để trống
    local plate = QBCore.Functions.GetPlate(vehicle)
    local vehicleTuningData = tuning[plate] or {}

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'tuning',
        neons = vehicleTuningData, -- Gửi dữ liệu tuning hiện tại
        translate = Lang.Pack -- Sử dụng gói ngôn ngữ đã được hợp nhất
    })
    menuOpened = true
end

-- Đăng ký sự kiện để mở giao diện từ vật phẩm hoặc lệnh
RegisterNetEvent('qb-mechanicjob:client:useTuning', OpenTuning)

-- Callback khi người dùng áp dụng cài đặt từ NUI
RegisterNUICallback('applyTuning', function(data)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle == 0 then return end

    local plate = QBCore.Functions.GetPlate(vehicle)
    local dataToSave = data.data

    tuning[plate] = dataToSave

    QBCore.Functions.Notify("Đã áp dụng cài đặt tinh chỉnh!", "success")

    ToggleNeons(vehicle, plate)
    SwitchMode(vehicle, dataToSave.vehiclemode)
    SetTuning(vehicle, dataToSave)

    -- Gửi dữ liệu đến server để lưu vào database
    TriggerServerEvent("qb-mechanicjob:sv:saveVehicleTuning", plate, dataToSave)
end)

-- Callback khi đóng giao diện
RegisterNUICallback('closeUI', function()
    SetNuiFocus(false, false)
    menuOpened = false
end)

-- Hàm áp dụng các thay đổi về hiệu suất
function SetTuning(veh, data)
    if not DoesEntityExist(veh) or not data then return end

    local multp = 0.12
    local dTrain = 0.5 -- Mặc định là FWD/RWD
    if tonumber(data.drivetrain) and tonumber(data.drivetrain) > 75 then
        dTrain = 1.0 -- AWD
    end

    local originalAcceleration = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")

    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", (data.boost / 100) * multp + 0.3)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", originalAcceleration + (data.acceleration / 100 * multp))
    SetVehicleEnginePowerMultiplier(veh, (data.gearchange / 100) * multp + 1.0)
    LastEngineMultiplier = (data.gearchange / 100) * multp + 1.0
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", dTrain)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", (data.breaking / 100) * multp + 0.5)
end

-- Hàm thay đổi chế độ lái
function SwitchMode(veh, type)
    if not DoesEntityExist(veh) then return end
    local plate = QBCore.Functions.GetPlate(veh)

    if not tuning[plate] then tuning[plate] = {} end
    tuning[plate].vehiclemode = type

    if type == 'sport' then
        SetDriftTyresEnabled(veh, false)
        SetVehicleEnginePowerMultiplier(veh, Config.IncreaseSpeed or 35.0)
        SetVehicleEngineTorqueMultiplier(veh, Config.IncreaseSpeed or 35.0)
        SetEntityMaxSpeed(veh, Config.MaxSpeed or 999.0)
    elseif type == 'drift' then
        SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
        SetVehicleEngineTorqueMultiplier(veh, 1.0)
        SetDriftTyresEnabled(veh, true)
    elseif type == 'eco' then
        SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
        SetVehicleEngineTorqueMultiplier(veh, 1.0)
        SetDriftTyresEnabled(veh, false)
    end
end

-- =============================================
-- LOGIC XỬ LÝ NEON VÀ ĐÈN PHA
-- (Sao chép nguyên bản từ dusa_mechanic/client/client.lua)
-- =============================================
function ToggleNeons(vehicle, plate)
	if not vehicle or not DoesEntityExist(vehicle) then return end

    local neonData = tuning[plate]
    if not neonData then return end

    SetVehicleNeonLightEnabled(vehicle, 0, neonData.left_neon)
    SetVehicleNeonLightEnabled(vehicle, 1, neonData.right_neon)
    SetVehicleNeonLightEnabled(vehicle, 2, neonData.front_neon)
    SetVehicleNeonLightEnabled(vehicle, 3, neonData.back_neon)

    if neonData.headlights and type(neonData.headlights) == 'string' then
        local r, g, b = neonData.headlights:match("rgb%((%d+), (%d+), (%d+)%)")
        if r then
            ToggleVehicleMod(vehicle, 22, true)
            -- Cần một sự kiện server để đồng bộ màu đèn pha cho người chơi khác
            TriggerServerEvent('qb-mechanicjob:sv:syncHeadlight', VehToNet(vehicle), tonumber(r), tonumber(g), tonumber(b))
        end
    end

    if neonData.neoncolor and type(neonData.neoncolor) == 'string' then
        local r, g, b = neonData.neoncolor:match("rgb%((%d+), (%d+), (%d+)%)")
        if r then
            SetVehicleNeonLightsColour(vehicle, tonumber(r), tonumber(g), tonumber(b))
        end
    end

    -- Khởi chạy hiệu ứng cầu vồng nếu được bật
    ToggleRainbow(vehicle, plate)
end


function ToggleRainbow(vehicle, vehicleplate)
	CreateThread(function()
		local function RGBRainbow(frequency)
			local result = {}
			local curtime = GetGameTimer() / 1000
			result.r = math.floor( math.sin( curtime * frequency + 0 ) * 127 + 128 )
			result.g = math.floor( math.sin( curtime * frequency + 2 ) * 127 + 128 )
			result.b = math.floor( math.sin( curtime * frequency + 4 ) * 127 + 128 )
			return result
		end

        -- Vòng lặp chỉ chạy khi xe và người chơi hợp lệ
	    while IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), false) == vehicle and tuning[vehicleplate] and (tuning[vehicleplate].neonrgb or tuning[vehicleplate].headlightsrgb) do
	    	Wait(50) -- Tối ưu hóa vòng lặp
            if not DoesEntityExist(vehicle) then break end

            local currentTuning = tuning[vehicleplate]
            if not currentTuning then break end

			if currentTuning.neonrgb then
		        local rainbow = RGBRainbow(1.36)
				SetVehicleNeonLightsColour(vehicle, rainbow.r, rainbow.g, rainbow.b)
			end
			if currentTuning.headlightsrgb then
		        local rainbow = RGBRainbow(1.36)
                ToggleVehicleMod(vehicle, 22, true)
                -- Đồng bộ màu đèn pha
                TriggerServerEvent('qb-mechanicjob:sv:syncHeadlight', VehToNet(vehicle), rainbow.r, rainbow.g, rainbow.b)
			end
		end
	end)
end

-- Đồng bộ khi có người chơi khác thay đổi
RegisterNetEvent('qb-mechanicjob:client:syncHeadlight', function(vehicleId, r, g, b)
    if NetworkDoesEntityExistWithNetworkId(vehicleId) then
        local vehicle = NetToVeh(vehicleId)
        ToggleVehicleMod(vehicle, 22, true)
        SetVehicleXenonLightsCustomColor(vehicle, tonumber(r), tonumber(g), tonumber(b))
    end
end)

-- Sự kiện nhận dữ liệu tuning từ server khi vào xe
RegisterNetEvent('qb-mechanicjob:client:applyTuningOnEnter', function(plate, tuningData)
    if tuningData then
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local currentPlate = QBCore.Functions.GetPlate(vehicle)
            if currentPlate == plate then
                tuning[plate] = tuningData
                SetTuning(vehicle, tuningData)
                SwitchMode(vehicle, tuningData.vehiclemode)
                ToggleNeons(vehicle, plate)
            end
        end
    end
end)