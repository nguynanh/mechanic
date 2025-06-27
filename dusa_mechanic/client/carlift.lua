local boxzones = {}
local elevators = {}
local elevatorUp = false
local elevatorDown = false
local isInElevatorZone = false
local elevatorProp = nil
local attachedVehicle = nil
local isAttach = false

--- Get Distance
---@param pos1 vector
---@param pos2 vector
local function GetDistance(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

--- Prepare Model
---@param model string
local function PrepareModel(model)
    RequestModel(model)
    while (not HasModelLoaded(model)) do Wait(0) end
end

--- Elevator Menu
---@param id number
local function ElevatorMenu(id)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'context',
        type = 'lift',
        translate = Config.Translations[Config.Locale]
    })
end

--- create Object
---@param model string
---@param x number
---@param y number
---@param z number
local function createObject(model, x, y, z)
    PrepareModel(model)
    local obj = CreateObject(model, x, y, z, true)
    SetEntityAsMissionEntity(obj, true, true)
    return obj
end

--- Create Poles
---@param id number
---@param elevatorProp string
local function CreatePoles(id, elevatorProp)
    local polemodel = GetHashKey(Config.LiftPoleModel)
    PrepareModel(polemodel)
    if IsModelValid(polemodel) then
        local platformCoords = GetEntityCoords(elevatorProp)
        local PropHeading = GetEntityHeading(elevatorProp)
        -- Lift Electra Box
        if Config.SpawnElectraBox then
            local elecbox = GetHashKey(Config.LiftElecBox)
            PrepareModel(elecbox)
            if IsModelValid(elecbox) then
                local elecboxOffset = GetOffsetFromEntityInWorldCoords(elevatorProp, Config.BoxOffset.x, Config.BoxOffset.y, Config.BoxOffset.z)
                local BoxCoords = vector3(elecboxOffset.x, elecboxOffset.y, elecboxOffset.z)
                local ElecBox = createObject(elecbox, BoxCoords.x, BoxCoords.y, BoxCoords.z)
                SetEntityHeading(ElecBox, PropHeading)
                SetEntityCollision(ElecBox, true, true)
                FreezeEntityPosition(ElecBox, true)
            end
        end
        -- left front pole
        local poleOffset1 = GetOffsetFromEntityInWorldCoords(elevatorProp, 1.43, -2.880, Config.PoleZOffzet)
        local Pole1Coords = vector3(poleOffset1.x, poleOffset1.y, poleOffset1.z)
        local pole1 = createObject(polemodel, Pole1Coords.x, Pole1Coords.y, Pole1Coords.z)
        SetEntityHeading(pole1, PropHeading - 180)
        SetEntityCollision(pole1, true, true)
        FreezeEntityPosition(pole1, true)
        -- right front pole
        local poleOffset2 = GetOffsetFromEntityInWorldCoords(elevatorProp, -1.43, -2.880, Config.PoleZOffzet)
        local Pole2Coords = vector3(poleOffset2.x, poleOffset2.y, poleOffset2.z)
        local pole2 = createObject(polemodel, Pole2Coords.x, Pole2Coords.y, Pole2Coords.z)
        SetEntityHeading(pole2, PropHeading)
        SetEntityCollision(pole2, true, true)
        FreezeEntityPosition(pole2, true)
        -- right rear pole
        local poleOffset3 = GetOffsetFromEntityInWorldCoords(elevatorProp, -1.43, 2.880, Config.PoleZOffzet)
        local Pole3Coords = vector3(poleOffset3.x, poleOffset3.y, poleOffset3.z)
        local pole3 = createObject(polemodel, Pole3Coords.x, Pole3Coords.y, Pole3Coords.z)
        SetEntityHeading(pole3, PropHeading)
        SetEntityCollision(pole3, true, true)
        FreezeEntityPosition(pole3, true)
        -- left rear pole
        local poleOffset4 = GetOffsetFromEntityInWorldCoords(elevatorProp, 1.43, 2.880, Config.PoleZOffzet)
        local Pole4Coords = vector3(poleOffset4.x, poleOffset4.y, poleOffset4.z)
        local pole4 = createObject(polemodel, Pole4Coords)
        SetEntityHeading(pole4, PropHeading - 180)
        SetEntityCollision(pole4, true, true)
        FreezeEntityPosition(pole4, true)
    end
end

--- Create Car Lift
---@param id number
---@param propName string
---@param x number
---@param y number
---@param z number
local function CreateCarLift(id, propName, x, y, z)
    local model = GetHashKey(propName)
    if IsModelValid(model) then
        ClearAreaOfObjects(vector3(x, y, z), 30.0, 0)
        local elevatorProp = createObject(model, x, y, z)
        SetEntityCollision(elevatorProp, true, true)
        FreezeEntityPosition(elevatorProp, true)
        SetEntityCoords(elevatorProp, x, y, z, false, false, false, false)
        SetEntityRotation(elevatorProp, 0.0, 0.0, 0.0, 4, false)
        SetEntityHeading(elevatorProp, Config.Elevators[id].coords.h)
        -- Create poles
        if Config.Elevators[id].needPoles then CreatePoles(id, elevatorProp) end
        elevators[id] = {id = id, entity = elevatorProp, coords = vector3(x, y, z)}
        Config.Elevators[id].entity = elevatorProp
        TriggerServerEvent('dusa_carlift:server:update', elevators)
    end
end

--- Create BoxZone
---@param id number
---@param x number
---@param y number
---@param z number
local function CreateBoxZone(id, x, y, z)
    boxzones["boxzone_" .. id] = {}
    boxzones["boxzone_" .. id].zone = BoxZone:Create(vector2(x, y), Config.Elevators[id].workarea.length, Config.Elevators[id].workarea.wide, { minZ = z, maxZ = z + 4, name = "boxzone_" .. id, debugPoly = Config.DebugPoly, heading = Config.Elevators[id].coords.h})
    boxzones["boxzone_" .. id].zonecombo = ComboZone:Create({boxzones["boxzone_" .. id].zone}, {name = "boxzone", debugPoly = Config.DebugPoly})
    boxzones["boxzone_" .. id].zonecombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            for k, v in pairs(Config.Mechanics) do
                if v.job == dusa.playerData.job.name then
                    zone["lift"..id] = true
                    isInElevatorZone = true
                    -- ElevatorHandler(true)
                    if Config.Elevators[id].openMenu then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            dusa.textUI(Config.Translations[Config.Locale].etocarlift)
                        elseif IsPedInAnyVehicle(PlayerPedId()) then
                            dusa.textUI(Config.Translations[Config.Locale].etoattach)
                        end
                    end
                end
            end
        else
            zone["lift"..id] = false
            isInElevatorZone = false
            TriggerEvent('dusa_carlift:client:use', {handle = "stop", id = id})
            dusa.hideUI()
        end
    end)
end

--- Spawn Prop
---@param id number
---@param propName string
---@param x number
---@param y number
---@param z number
local function SpawnProp(id, propName, x, y, z)
    CreateCarLift(id, propName, x, y, z)
    CreateBoxZone(id, x, y, z)
end

--- Get Closest Lift Object
local function GetClosestLiftObject()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    local entity = nil
    local hasAccess = false
    for id, v in pairs(Config.Elevators) do
        local dist2 = #(vector3(pos.x, pos.y, pos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
        if current then
            if dist2 < dist then
                current = v.id
                entity = v.entity
                dist = dist2
                coords = v.coords
            end
        else
            dist = dist2
            current = v.id
            entity = v.entity
            coords = v.coords
        end
    end
    return current, dist, entity, coords
end
exports('GetClosestLiftObject', GetClosestLiftObject)

--- Clear All Elevator Areas
function ClearAllElevatorAreas()
    for i = 1, #Config.Elevators do
        ClearAreaOfObjects(vector3(Config.Elevators[i].coords.x, Config.Elevators[i].coords.y, Config.Elevators[i].coords.z), 30.0, 0)
    end
end

--- Get Vehicle Model
---@param vehicle number
local function GetVehicleModel(vehicle)
    local model = nil
    local props = getVehicleProperties(vehicle)
    if props then name = GetDisplayNameFromVehicleModel(props.model) end
    return name:lower()
end

RegisterNetEvent('dusa_carlift:client:spawnElevators', function()
    spawnElevators = true
end)

RegisterNetEvent('dusa_carlift:client:updateElevators', function(data)
    for id, elevator in pairs(Config.Elevators) do
        CreateBoxZone(id, elevator.coords.x, elevator.coords.y, elevator.coords.z)
        Config.Elevators[id].entity = data.entity
        elevators[id] = {id = id, entity = elevator.entity, coords = vector3(elevator.coords.x, elevator.coords.y, elevator.coords.z)}
    end
end)

RegisterNetEvent('dusa_carlift:client:use', function(data)
    TriggerServerEvent('dusa_carlift:server:use', data)
end)

RegisterNetEvent('dusa_carlift:client:elevatorUp', function(data)
    elevatorDown = false
    elevatorUp = true
end)

RegisterNetEvent('dusa_carlift:client:elevatorDown', function(data)
    elevatorUp = false
    elevatorDown = true
end)

RegisterNetEvent('dusa_carlift:client:elevatorStop', function(data)
    elevatorUp = false
    elevatorDown = false
end)

RegisterNetEvent('dusa_carlift:client:connect', function(lift)
    if not isAttach then
        local vehicle, distance = dusa.getClosestVehicle(GetEntityCoords(PlayerPedId()))
        if distance < 5.0 then
            attachedVehicle = vehicle
            local model = GetVehicleModel(vehicle)
            local offset = Config.VehicleAttachOffset[model]
            if offset then
                AttachEntityToEntity(vehicle, lift, 11816, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
            else
                AttachEntityToEntity(vehicle, lift, 11816, 0.0, 0.0, 0.36, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
            end
            isAttach = true
        end
    end
end)

RegisterNetEvent('dusa_carlift:client:disconnect', function()
    if isAttach and attachedVehicle ~= nil then
        DetachEntity(attachedVehicle, true, false)
        isAttach = false
        attachedVehicle = nil
    end
end)

RegisterNUICallback('lift', function(data)
    local data = data.data
    if data.action == 'up' then
        elevatorDown = false
        elevatorUp = true
        progress = true
        status = true
    elseif data.action == 'down' then
        elevatorUp = false
        elevatorDown = true
        progress = true
        status = true
    elseif data.action == 'stop' then
        elevatorUp = false
        elevatorDown = false
        progress = false
        status = false
    elseif data.action == 'detach' then
        elevatorUp = false
        elevatorDown = false
        progress = false
        TriggerEvent('dusa_carlift:client:disconnect')
        status = false
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         local id, _, entity, _ = GetClosestLiftObject()
--         local elevatorCoords = GetEntityCoords(entity, false)
--         if elevatorUp then
--             if elevatorCoords.z < Config.Elevators[id].max then
--                 if (elevatorCoords.z > Config.Elevators[id].beforemax) then
--                     Config.Elevators[id].coords.z = Config.Elevators[id].coords.z + Config.Speed_up_slow
--                     SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
--                 else
--                     Config.Elevators[id].coords.z = Config.Elevators[id].coords.z + Config.Speed_up
--                     SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
--                 end
--             end
--         end
--         if elevatorDown then
--             if elevatorCoords.z > Config.Elevators[id].min then
--                 if (elevatorCoords.z < Config.Elevators[id].beforemin) then
--                     Config.Elevators[id].coords.z = Config.Elevators[id].coords.z - Config.Speed_down_slow
--                     SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
--                 else
--                     Config.Elevators[id].coords.z = Config.Elevators[id].coords.z - Config.Speed_down
--                     SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
--                 end
--             end
--         end
--     end
-- end)
local progress = false
status = false
-- function RunLift(status)
--     if progress then return end
--     progress = true
--     local sleep = 3000
    
-- end

CreateThread(function()
    local sleep = 2000
    while true do
        local id, _, entity, _ = GetClosestLiftObject()
        local elevatorCoords = GetEntityCoords(entity, false)
        if status then
            if elevatorUp then
                sleep = 0
                if elevatorCoords.z < Config.Elevators[id].max then
                    if (elevatorCoords.z > Config.Elevators[id].beforemax) then
                        Config.Elevators[id].coords.z = Config.Elevators[id].coords.z + Config.Speed_up_slow
                        SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
                    else
                        Config.Elevators[id].coords.z = Config.Elevators[id].coords.z + Config.Speed_up
                        SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
                    end
                end
            end
            if elevatorDown then
                sleep = 0
                if elevatorCoords.z > Config.Elevators[id].min then
                    if (elevatorCoords.z < Config.Elevators[id].beforemin) then
                        Config.Elevators[id].coords.z = Config.Elevators[id].coords.z - Config.Speed_down_slow
                        SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
                    else
                        Config.Elevators[id].coords.z = Config.Elevators[id].coords.z - Config.Speed_down
                        SetEntityCoords(entity, Config.Elevators[id].coords.x, Config.Elevators[id].coords.y, Config.Elevators[id].coords.z, false, false, false, false)
                    end
                end
            end
        else
            sleep = 2000
            progress = false
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if spawnElevators then
            spawnElevators = false
            for id, elevator in pairs(Config.Elevators) do
                if not elevator.spawned then
                    SpawnProp(elevator.id, Config.LiftPlatformModel, elevator.coords.x, elevator.coords.y, elevator.coords.z)
                    elevator.spawned = true
                end
            end
        end
        Wait(1000)
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         local player = PlayerPedId()
--         local id, _, entity, _ = GetClosestLiftObject()
--         local elevatorCoords = GetEntityCoords(entity)
--         local vehicle = GetVehiclePedIsIn(player, false)
--         local vehicleCoords = GetEntityCoords(vehicle)
--         if vehicle ~= 0 then
--             local distance = GetDistance(elevatorCoords, vehicleCoords)
--             if distance < 6 and not isAttach and IsPedInAnyVehicle(player) then
--                 SetEntityNoCollisionEntity(entity, vehicle, true)
--                 SetEntityNoCollisionEntity(vehicle, entity, true)
--             end
--         end
--         Citizen.Wait(0)
--     end
-- end)

-- function ElevatorHandler(bool)
--     Citizen.CreateThread(function()
--         while true do
--             Citizen.Wait(0)
--             if isInElevatorZone then
--                 local player = PlayerPedId()
--                 if bool then
--                     local id, _, entity, _ = GetClosestLiftObject()
--                     local vehicle = GetVehiclePedIsIn(player, false)
--                     local vehicleCoords = GetEntityCoords(vehicle)
--                     local elevatorCoords = GetEntityCoords(entity)
--                     if IsControlJustReleased(0, 38) then
--                         if not IsPedInAnyVehicle(player) then
--                             if Config.Elevators[id].openMenu then ElevatorMenu(id) end
--                         else
--                             if not isAttach then
--                                 local vehicle = GetVehiclePedIsIn(player, false)
--                                 attachedVehicle = vehicle
--                                 TaskLeaveVehicle(player, vehicle, 1)
--                                 Wait(2500)
--                                 local model = GetVehicleModel(vehicle)
--                                 local offset = Config.VehicleAttachOffset[model]
--                                 if offset then
--                                     AttachEntityToEntity(vehicle, entity, 11816, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
--                                 else
--                                     AttachEntityToEntity(vehicle, entity, 11816, 0.0, 0.0, 0.36, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
--                                 end
--                                 isAttach = true
--                             end
--                         end
--                         dusa.hideUI()
--                     end
--                     if vehicle ~= 0 then
--                         local distance = GetDistance(elevatorCoords, vehicleCoords)
--                         if distance < 6 and not isAttach and IsPedInAnyVehicle(player) then
--                             SetEntityNoCollisionEntity(entity, vehicle, true)
--                             SetEntityNoCollisionEntity(vehicle, entity, true)
--                         end
--                     end
--                 else
--                     break
--                 end
--             else
--                 break
--             end
--         end
--     end)
-- end

function InteractCarLift()
    local player = PlayerPedId()
    local id, _, entity, _ = GetClosestLiftObject()
    local vehicle = GetVehiclePedIsIn(player, false)
    local vehicleCoords = GetEntityCoords(vehicle)
    local elevatorCoords = GetEntityCoords(entity)
    if not IsPedInAnyVehicle(player) then
        if Config.Elevators[id].openMenu then ElevatorMenu(id) end
    else
        if not isAttach then
            local vehicle = GetVehiclePedIsIn(player, false)
            attachedVehicle = vehicle
            TaskLeaveVehicle(player, vehicle, 1)
            Wait(2500)
            local model = GetVehicleModel(vehicle)
            local offset = Config.VehicleAttachOffset[model]
            if offset then
                AttachEntityToEntity(vehicle, entity, 11816, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
            else
                AttachEntityToEntity(vehicle, entity, 11816, 0.0, 0.0, 0.36, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
            end
            isAttach = true
        end
    end
    dusa.hideUI()
    if vehicle ~= 0 then
        local distance = GetDistance(elevatorCoords, vehicleCoords)
        if distance < 6 and not isAttach and IsPedInAnyVehicle(player) then
            SetEntityNoCollisionEntity(entity, vehicle, true)
            SetEntityNoCollisionEntity(vehicle, entity, true)
        end
    end
end