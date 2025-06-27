local craftTables, boxzones = {}, {}
local spawnBenchs, isInBench = true, false
local rotatedCam = nil
--- Prepare Model
---@param model string
local function PrepareModel(model)
    RequestModel(model)
    while (not HasModelLoaded(model)) do Wait(0) end
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

--- Create Car Lift
---@param id number
---@param propName string
---@param x number
---@param y number
---@param z number
local function CreateCraftBench(id, x, y, z)
    local model = GetHashKey(Config.CraftBenchs[id].prop)
    if IsModelValid(model) then
        ClearAreaOfObjects(vector3(x, y, z), 30.0, 0)
        local craftBench = createObject(model, x, y, z)
        SetEntityCollision(craftBench, true, true)
        FreezeEntityPosition(craftBench, true)
        SetEntityCoords(craftBench, x, y, z, false, false, false, false)
        SetEntityRotation(craftBench, 0.0, 0.0, 0.0, 4, false)
        SetEntityHeading(craftBench, Config.CraftBenchs[id].coords.h)
        -- Create poles
        craftTables[id] = {id = id, entity = craftBench, coords = vector3(x, y, z)}
        Config.CraftBenchs[id].entity = craftBench
        -- TriggerServerEvent('dusa_carlift:server:update', elevators)
    end
end

-- local function KeyListener()
--     Citizen.CreateThread(function()
--         local ped = PlayerPedId()
--         local pedCoords = GetEntityCoords(ped)
--         while true do
--             Citizen.Wait(0)
--             if isInBench then
--                 local player = PlayerPedId()
--                 if IsControlJustReleased(0, 38) then
--                     -- menüyü aç
--                     for k, val in pairs(craftTables) do
--                         local dist = #(pedCoords - vec3(val.coords.x, val.coords.y, val.coords.z))
--                         if dist < 5 then
--                             RotateCraftCam(val.entity)
--                             TriggerServerEvent('dusa_mechanic:sv:getItemCounts')
--                             break;
--                         end
--                     end

--                     dusa.hideUI()
--                     break;
--                 end
--             else
--                 break;
--             end
--         end
--     end)
-- end

function InventoryLoop()
    CreateThread(function()
        while true do
            dusa.serverCallback('dusa_mechanic:cb:getItemCounts', function(table)
                craftItems = table
            end)
            Wait(1 * 60000)
        end
    end)
end

function InteractCraft()
    if isInBench then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for k, val in pairs(craftTables) do
            local dist = #(pedCoords - vec3(val.coords.x, val.coords.y, val.coords.z))
            if dist < 5 then
                RotateCraftCam(val.entity)
                TriggerServerEvent('dusa_mechanic:sv:getItemCounts')
            end
        end
    end
end

--- Create BoxZone
---@param id number
---@param x number
---@param y number
---@param z number
local function CreateBoxZone(id, x, y, z)
    boxzones["boxzone_" .. id] = {}
    boxzones["boxzone_" .. id].zone = BoxZone:Create(vector2(x, y), Config.CraftBenchs[id].workarea.length, Config.CraftBenchs[id].workarea.wide, { minZ = z, maxZ = z + 4, name = "boxzone_" .. id, debugPoly = false, heading = Config.CraftBenchs[id].coords.h})
    boxzones["boxzone_" .. id].zonecombo = ComboZone:Create({boxzones["boxzone_" .. id].zone}, {name = "boxzone", debugPoly = false})
    boxzones["boxzone_" .. id].zonecombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            for k, v in pairs(Config.Mechanics) do
                if v.job == dusa.playerData.job.name then
                    isInBench = true
                    zone["craft"..id] = true
                    -- KeyListener()
                    if Config.CraftBenchs[id].openMenu then
                        dusa.textUI(Config.Translations[Config.Locale].etocraft)
                    end
                end
            end
        else
            zone["craft"..id] = false
            isInBench = false
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
local function SpawnProp(id, x, y, z)
    CreateCraftBench(id, x, y, z)
    CreateBoxZone(id, x, y, z)
end


function DeployBenchs()
    if spawnBenchs then
        spawnBenchs = false
        for id, val in pairs(Config.CraftBenchs) do
            if not val.spawned then
                SpawnProp(val.id, val.coords.x, val.coords.y, val.coords.z)
                val.spawned = true
            end
        end
    end
end

DeployBenchs()

function RemoveBenchs()
    CreateThread(function()
        for id, val in pairs(craftTables) do
            if val.spawned then
                DeleteObject(val.entity)
                val.entity = nil
                val.spawned = false
            end
        end
    end)
end

RegisterNetEvent('dusa_mechanic:cl:getItemCounts', function(craftItems)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'craft',
        craft = craftItems,
        translate = Config.Translations[Config.Locale]
    })
    -- HideMap(true)
end)

RegisterNUICallback('craft', function(data)
    local craft = data.data
    TriggerServerEvent('dusa_mechanic:sv:craftItem', craft)
end)


-- Cameras
local camdata = {
    offset = vector3(0.0, -1.5, 1.5),
    rotation = vector3(0.0, 0.0, 0.0),
}

CreateCraftCam = function(bench)
    if not bench then return end
    local player = PlayerPedId()

    if DoesCamExist(camdata.camera) then
        return
    end

    local benchCoords = GetOffsetFromEntityInWorldCoords(bench, camdata.offset)
    local benchRotation = GetEntityRotation(bench) + camdata.rotation
    camdata.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamCoord(camdata.camera, benchCoords)
    SetCamRot(camdata.camera, benchRotation)
    SetCamFov(camdata.camera, 50.0)
    SetEntityAlpha(player, 60, false)
end

DeleteCraftCam = function()
    if not camdata.camera then
        return
    end
    local player = PlayerPedId()

    if not DoesCamExist(camdata.camera) then
        return
    end

    ResetEntityAlpha(player)
    RenderScriptCams(false, false, 500, false, false)
    SetCamActive(camdata.camera, false)
    DestroyCam(camdata.camera)
    DestroyCam(camdata.camera)
    camdata.camera = nil
end

RotateCraftCam = function(bench)
    local player = PlayerPedId()

    CreateCraftCam(bench)

    DisableCamCollisionForEntity(player)

    if DoesCamExist(rotatedCam) and camdata.camera ~= rotatedCam then
        SetCamActiveWithInterp(camdata.camera, rotatedCam, 1500, 1, 1)
        SetCamActive(camdata.camera, true)
    end
    
    rotatedCam = camdata.camera
    SetCamActive(rotatedCam, true)
    RenderScriptCams(true, true, 500, true, true)
end


local craftObject

RegisterNUICallback('previewObject', function(data)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for k, val in pairs(craftTables) do
        local dist = #(pedCoords - vec3(val.coords.x, val.coords.y, val.coords.z))
        if dist < 5 then -- data.object ile obje çekilir
            craftObject = createObject(data.data.prop, val.coords.x, val.coords.y, val.coords.z + 1.35)
            SetEntityNoCollisionEntity(craftObject, val.entity, true)
            SetEntityDrawOutline(craftObject, true)
            FreezeEntityPosition(craftObject, true)
            SetEntityDrawOutlineColor(255,255,255,255)
            SetEntityCoords(craftObject, val.coords.x - 0.2, val.coords.y, val.coords.z + 1.35, false, false, false, false)
            -- SetEntityRotation(craftObject, -180.0, -40.0, -250.0, 4, false)
            PreviewAnimation()
        end
    end
end)

function PreviewAnimation(bool)
    isRunning = true
    
    Citizen.CreateThread(function()
        while isRunning do
            local currentHeading = GetEntityHeading(craftObject)
            SetEntityHeading(craftObject, currentHeading + 0.2)
            Wait(10)
        end
    end)
end

RegisterNUICallback('destroyPreview', function()
    -- PreviewAnimation(false)
    isRunning = false
    DeleteObject(craftObject)
end)

RegisterNUICallback('closeCraft', function()
    SetNuiFocus(false, false)
    DeleteCraftCam()
    -- PreviewAnimation(false)
    isRunning = false
    DeleteObject(craftObject)
end)
