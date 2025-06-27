-- =================================================================
-- TỆP FUNCTIONS.LUA PHIÊN BẢN HOÀN CHỈNH - ĐÃ BỔ SUNG PUSHVEHICLE
-- =================================================================
QBCore = exports['qb-core']:GetCoreObject()

function Trim(str)
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