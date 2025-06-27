-- =================================================================
-- TỆP FUNCTIONS.LUA PHIÊN BẢN HOÀN CHỈNH - ĐÃ BỔ SUNG PUSHVEHICLE
-- =================================================================
QBCore = exports['qb-core']:GetCoreObject()

function trim(str)
    if type(str) == 'string' then
        return str:match("^%s*(.-)%s*$")
    end
    return str
end

-- HÀM QUAN TRỌNG BỊ THIẾU
function pushVehicle(entity)
	if DoesEntityExist(entity) then
		SetVehicleModKit(entity, 0)
		if not NetworkHasControlOfEntity(entity) then
			NetworkRequestControlOfEntity(entity)
			local timeout = 2000
			while timeout > 0 and not NetworkHasControlOfEntity(entity) do
				Wait(100)
				timeout = timeout - 100
			end
		end
		if not IsEntityAMissionEntity(entity) then
			SetEntityAsMissionEntity(entity, true, true)
			local timeout = 2000
			while timeout > 0 and not IsEntityAMissionEntity(entity) do
				Wait(100)
				timeout = timeout - 100
			end
		end
	end
end
function searchCar(vehicle)
    if not DoesEntityExist(vehicle) then return "Unknown Vehicle" end
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local brand = GetMakeNameFromVehicleModel(GetEntityModel(vehicle))
    local vehicleData = QBCore.Shared.Vehicles[vehicleName:lower()]
    if vehicleData and vehicleData.name then
        return vehicleData.brand .. " " .. vehicleData.name
    end
    return brand .. " " .. vehicleName
end

function getClass(vehicle)
    if not DoesEntityExist(vehicle) then return "Unknown" end
	local classlist = {
		"Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports Classics", "Sports", "Super", "Motorcycles",
		"Off-road", "Industrial", "Utility", "Vans", "Cycles", "Boats", "Helicopters", "Planes", "Service",
		"Emergency", "Military", "Commercial", "Trains"
	}
	local classId = GetVehicleClass(vehicle)
	return classlist[classId + 1] or "Unknown"
end

function searchPrice(vehicle)
    if not DoesEntityExist(vehicle) then return "$0" end
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if k == vehicleName then
            local price = v.price
            local formatted = price
            while true do
                formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
                if (k==0) then break end
            end
            return "$" .. formatted
        end
    end
    return "$0"
end

function outCar()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end
-- Thêm các hàm này vào cuối tệp qb-mechanicjob/client/functions.lua

function searchCar(vehicle)
    if not DoesEntityExist(vehicle) then return "Unknown Vehicle" end
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local brand = GetMakeNameFromVehicleModel(GetEntityModel(vehicle))
    -- Cố gắng tìm trong QBCore.Shared.Vehicles để có tên đẹp hơn
    local vehicleData = QBCore.Shared.Vehicles[vehicleName:lower()]
    if vehicleData and vehicleData.name then
        return vehicleData.brand .. " " .. vehicleData.name
    end
    return brand .. " " .. vehicleName
end

function getClass(vehicle)
    if not DoesEntityExist(vehicle) then return "Unknown" end
	local classlist = {
		"Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports Classics", "Sports", "Super", "Motorcycles",
		"Off-road", "Industrial", "Utility", "Vans", "Cycles", "Boats", "Helicopters", "Planes", "Service",
		"Emergency", "Military", "Commercial", "Trains"
	}
	local classId = GetVehicleClass(vehicle)
	return classlist[classId + 1] or "Unknown"
end

function searchPrice(vehicle)
    if not DoesEntityExist(vehicle) then return "$0" end
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if k == vehicleName then
            local price = v.price
            local formatted = price
            while true do
                formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
                if (k==0) then break end
            end
            return "$" .. formatted
        end
    end
    return "$0"
end

function outCar()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end
function jobChecks()
	local check = true
	-- [[ Logic này yêu cầu Config.RequireJob và Config.JobRoles trong qb-mechanicjob/config/config.lua ]]
	if Config.RequireJob == true then check = false
		for k, v in pairs(Config.JobRoles or {}) do
			if v == QBCore.Functions.GetPlayerData().job.name then check = true end
		end
		if check == false then QBCore.Functions.Notify("Only a mechanic knows how to do this", "error") check = false end
	end
	return check
end

function locationChecks()
	local check = true
    -- [[ Logic này yêu cầu biến 'inMechanicLocation' được thiết lập trong qb-mechanicjob/client/main.lua ]]
	if Config.PreviewLocation then
		if inMechanicLocation then
            check = true
        else
            check = false
            QBCore.Functions.Notify("Can't work outside of a shop", "error")
		end
	end
	return check
end

function nearPoint(coords)
	if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.5) then
        QBCore.Functions.Notify("There is no vehicle nearby", "error")
        return false
	else
        return true
    end
end

-- [[ ĐÂY LÀ HÀM GÂY RA LỖI CỦA BẠN ]]
function inCar()
	local inCar = false
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		QBCore.Functions.Notify("Cannot do this from inside the vehicle", "error")
		inCar = false
	else inCar = true end
	return inCar
end

function lockedCar(vehicle)
	local locked = false
	if GetVehicleDoorLockStatus(vehicle) >= 2 then
		QBCore.Functions.Notify("Vehicle is Locked", "error")
		locked = true
	else locked = false end
	return locked
end

function emptyHands(playerPed, dpemote)
	if dpemote ~= nil then TriggerEvent('animations:client:EmoteCommandStart', {"c"}) ClearPedTasks(playerPed)
	else ClearPedTasks(playerPed) end
	for k, v in pairs(GetGamePool('CObject')) do
		for _, model in pairs({`prop_sponge_01`, `prop_weld_torch`, `prop_rag_01`, `prop_fib_clipboard`, `v_ind_cs_toolbox4`, `p_amb_clipboard_01`, `ng_proc_spraycan01b`}) do
			if GetEntityModel(v) == model then
				if IsEntityAttachedToEntity(playerPed, v) then
					DeleteObject(v)
					DetachEntity(v, 0, 0)
					SetEntityAsMissionEntity(v, true, true)
					Wait(100)
					DeleteEntity(v)
				end
			end
		end
	end
end

function lookVeh(vehicle)
	if type(vehicle) == "vector3" then
		if not IsPedHeadingTowardsPosition(PlayerPedId(), vehicle, 30.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), vehicle, 1500)
			Wait(1500)
		end
	elseif DoesEntityExist(vehicle) then
        if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(vehicle), 30.0) then
            TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(vehicle), 1500)
            Wait(1500)
        end
	end
end

function getClosest(coords)
	local vehs = { 71, 0, 2, 4, 6, 7, 23, 127, 260, 2146, 2175, 12294, 16834, 16386, 20503, 32768, 67590, 67711, 98309, 100359 }
    local closestVehicle = 0
	for _, v in pairs(vehs) do
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.5, 0, v)
        if vehicle ~= 0 then
            closestVehicle = vehicle
            break
        end
    end
	return closestVehicle
end

function updateCar(vehicle)
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    TriggerServerEvent('qb-mechanicjob:server:SaveVehicleProps', vehicleProps)
end

function playAnim(animDict, animName, duration, flag)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, flag, 1, false, false, false)
end

function triggerNotify(title, message, type)
    QBCore.Functions.Notify(message, type, 5000)
end

function toggleItem(give, item, amount)
    TriggerServerEvent("qb-mechanicjob:server:toggleItem", give, item, amount)
end

function HexToRgb(hex)
	local hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function rgbToHex(r,g,b)
	local rgb = (r * 0x10000) + (g * 0x100) + b
	return string.format("%06x", rgb)
end

function trim(value)
	if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end