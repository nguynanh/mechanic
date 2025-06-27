
local function OpenTow()
    for k, v in pairs(Config.Mechanics) do
        if v.job == dusa.playerData.job.name then
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'context',
                type = 'flatbed',
                translate = Config.Translations[Config.Locale]
            })
        else
            dusa.showNotification(Config.Translations[Config.Locale].notmechanic, 'error')
            return
        end
    end
end

RegisterCommand(Config.TowCommand, OpenTow)

-- Tow
local function DeployRamp()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local radius = 5.0

    local vehicle = nil
    ramp = not ramp
    if IsAnyVehicleNearPoint(playerCoords, radius) and ramp then
        vehicle = getClosestVehicle(playerCoords)
        local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

        if contains(vehicleName, Config.whitelist) then
            local vehicleCoords = GetEntityCoords(vehicle)

            for _, value in pairs(Config.offsets) do
                if vehicleName == value.model then
                    local ramp = CreateObject(RampHash, vector3(value.offset.x, value.offset.y, value.offset.z), true, false, false)
                    AttachEntityToEntity(ramp, vehicle, GetEntityBoneIndexByName(vehicle, 'chassis'), value.offset.x, value.offset.y, value.offset.z , 180.0, 180.0, 0.0, 0, 0, 1, 0, 0, 1)
                end
            end
            dusa.showNotification(Config.Translations[Config.Locale].rampdeployed, 'success')
            return
        end
        dusa.showNotification(Config.Translations[Config.Locale].needflatbed, 'error')
        return
    elseif not ramp then
        local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, RampHash, false, 0, 0)
    
        if not IsPedInAnyVehicle(player, false) then
            if GetHashKey(RampHash) == GetEntityModel(object) then
                DeleteObject(object)
                dusa.showNotification(Config.Translations[Config.Locale].rampremoved, 'success')
                return
            end
        end
        dusa.showNotification(Config.Translations[Config.Locale].getcloser, 'error')
    end
end

local function AttachVehicle()
    local player = PlayerPedId()
    local vehicle = nil

    if IsPedInAnyVehicle(player, false) then
        vehicle = GetVehiclePedIsIn(player, false)
        if GetPedInVehicleSeat(vehicle, -1) == player then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehicleOffset = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 0.0, -1.5)
            local vehicleRotation = GetEntityRotation(vehicle, 2)
            local belowEntity = GetVehicleBelowMe(vehicleCoords, vehicleOffset)
            local vehicleBelowRotation = GetEntityRotation(belowEntity, 2)
            local vehicleBelowName = GetDisplayNameFromVehicleModel(GetEntityModel(belowEntity))

            local vehiclesOffset = GetOffsetFromEntityGivenWorldCoords(belowEntity, vehicleCoords)

            local vehiclePitch = vehicleRotation.x - vehicleBelowRotation.x
            local vehicleYaw = vehicleRotation.z - vehicleBelowRotation.z

            if contains(vehicleBelowName, Config.whitelist) then
                if not IsEntityAttached(vehicle) then
                    AttachEntityToEntity(vehicle, belowEntity, GetEntityBoneIndexByName(belowEntity, 'chassis'), vehiclesOffset, vehiclePitch, 0.0, vehicleYaw, false, false, true, false, 0, true)
                    return dusa.showNotification(Config.Translations[Config.Locale].vehicleattached, 'succes')
                end
                return dusa.showNotification(Config.Translations[Config.Locale].alreadyattached, 'error')
            end
            return dusa.showNotification(Config.Translations[Config.Locale].couldntattach, 'error')
        end
        return dusa.showNotification(Config.Translations[Config.Locale].todriverseat, 'error')
    end
    dusa.showNotification(Config.Translations[Config.Locale].notinveh, 'error')
end

local function DetachVehicle()
    local player = PlayerPedId()
    local vehicle = nil

    if IsPedInAnyVehicle(player, false) then
        vehicle = GetVehiclePedIsIn(player, false)
        if GetPedInVehicleSeat(vehicle, -1) == player then
            if IsEntityAttached(vehicle) then
                DetachEntity(vehicle, false, true)
                return dusa.showNotification(Config.Translations[Config.Locale].vehdetached, 'success')
            else
                return dusa.showNotification(Config.Translations[Config.Locale].isntattached, 'error')
            end
        else
            return dusa.showNotification(Config.Translations[Config.Locale].todriverseat, 'error')
        end
    else
        return dusa.showNotification(Config.Translations[Config.Locale].notinveh, 'error')
    end
end

RegisterNUICallback('deployRamp', DeployRamp)
RegisterNUICallback('attachVehicle', AttachVehicle)
RegisterNUICallback('detachVehicle', DetachVehicle)

function getClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function GetVehicleBelowMe(cFrom, cTo) -- Function to get the vehicle under me
    local rayHandle = CastRayPointToPoint(cFrom.x, cFrom.y, cFrom.z, cTo.x, cTo.y, cTo.z, 10, PlayerPedId(), 0) -- Sends raycast under me
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle) -- Stores the vehicle under me
    return vehicle -- Returns the vehicle under me
end

function contains(item, list)
    for _, value in ipairs(list) do
        if value == item then return true end
    end
    return false
end