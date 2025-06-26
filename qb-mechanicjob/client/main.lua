-- =================================================================
-- NỘI DUNG HOÀN CHỈNH CHO qb-mechanicjob/client/main.lua
-- =================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentShopBlips = {}

-- Handlers
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- Local Functions
local function SpawnListVehicle(model, spawnPoint)
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, 'MECH' .. tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, spawnPoint.w)
        if exports[Config.FuelResource] then
            exports[Config.FuelResource]:SetFuel(veh, 100.0)
        end
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true, false)
    end, model, spawnPoint, true)
end

local function VehicleList(shop)
    local vehicleMenu = { { header = Lang:t('menu.vehicle_list'), isMenuHeader = true } }

    if not Config.Shops[shop] or not Config.Shops[shop].vehicles or not Config.Shops[shop].vehicles.list then
        print('^1[ERROR] Khong tim thay danh sach xe cho garage: ' .. shop .. ' trong config.lua^7')
        QBCore.Functions.Notify("Garage này chưa được cấu hình danh sách xe!", "error")
        return
    end

    local list = Config.Shops[shop].vehicles.list
    for i = 1, #list do
        local vehicleData = QBCore.Shared.Vehicles[list[i]]
        local vehicleName = (vehicleData and vehicleData.name) or list[i]
        vehicleMenu[#vehicleMenu + 1] = {
            header = vehicleName,
            params = {
                event = 'qb-mechanicjob:client:SpawnListVehicle',
                args = {
                    spawnName = list[i],
                    location = Config.Shops[shop].vehicles.spawn
                }
            }
        }
    end

    vehicleMenu[#vehicleMenu + 1] = {
        header = Lang:t('menu.close'),
        params = { event = 'qb-menu:client:closeMenu' }
    }
    exports['qb-menu']:openMenu(vehicleMenu)
end

-- Events
RegisterNetEvent('qb-mechanicjob:client:SpawnListVehicle', function(data)
    SpawnListVehicle(data.spawnName, data.location)
end)

-- Main Thread
CreateThread(function()
    -- Tạo target cho các cửa hàng
    if Config.Shops and type(Config.Shops) == 'table' then
        for k, v in pairs(Config.Shops) do
            if v and type(v) == 'table' then
               if v.polyzone then
                   local shopZone = PolyZone:Create(v.polyzone, { name = k, debugPoly = Config.Debug })
                   shopZone:onPlayerInOut(function(isPointInside)
                      if isPointInside then
                         TriggerEvent("qb-mechanicjob:client:SetInsideLocation", true)
                      else
                          TriggerEvent("qb-mechanicjob:client:SetInsideLocation", false)
                      end
                   end)
              end
                if v.showBlip and v.blipCoords and not currentShopBlips[k] then
                    local blip = AddBlipForCoord(v.blipCoords)
                    SetBlipSprite(blip, v.blipSprite); SetBlipDisplay(blip, 4); SetBlipScale(blip, 0.6); SetBlipColour(blip, v.blipColor); SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(v.shopLabel); EndTextCommandSetBlipName(blip)
                    currentShopBlips[k] = blip
                end
                if v.duty then
                    exports['qb-target']:AddCircleZone(k .. '_duty', v.duty, 0.5, { name = k .. '_duty', useZ = true }, { options = { { event = 'QBCore:ToggleDuty', type = 'server', label = Lang:t('target.duty'), icon = 'fas fa-user-clock', job = v.managed and k or nil } }, distance = 2.0 })
                end
                if v.stash then
                    exports['qb-target']:AddCircleZone(k .. '_stash', v.stash, 0.5, { name = k .. '_stash', useZ = true }, { options = { { event = 'qb-mechanicjob:server:stash', type = 'server', data = { job = k }, label = Lang:t('target.stash'), icon = 'fas fa-box-open', job = v.managed and k or nil } }, distance = 2.0 })
                end
                if v.paint then
                    exports['qb-target']:AddCircleZone(k .. '_paintbooth', v.paint, 2.5, { name = k .. '_paintbooth', useZ = true }, { options = { { label = Lang:t('target.paint'), icon = 'fas fa-fill-drip', job = v.managed and k or nil, action = function() PaintCategories() end } }, distance = 2.5 })
                end
                if v.vehicles and v.vehicles.withdraw then
                    exports['qb-target']:AddCircleZone(k .. '_spawner', v.vehicles.withdraw, 1.5, { name = k .. '_spawner', useZ = true }, {
                        options = {
                            {
                                label = Lang:t('target.withdraw'), icon = 'fas fa-car', job = v.managed and k or nil,
                                canInteract = function() return GetVehiclePedIsUsing(PlayerPedId()) == 0 end,
                                action = function() VehicleList(k) end
                            },
                            {
                                label = Lang:t('target.deposit'), icon = 'fas fa-car', job = k,
                                canInteract = function() return GetVehiclePedIsUsing(PlayerPedId()) ~= 0 end,
                                action = function() DeleteEntity(GetVehiclePedIsUsing(PlayerPedId())) end
                            }
                        },
                        distance = 2.5
                    })
                end
            end
        end
    end
end)



-- Thay thế toàn bộ hàm CreateThread đầu tiên bằng phiên bản này
CreateThread(function()
    -- Tạo target và blip cho các cửa hàng (giữ nguyên)
    if Config.Shops and type(Config.Shops) == 'table' then
        for k, v in pairs(Config.Shops) do
            if v and type(v) == 'table' then
               if v.polyzone then
                   local shopZone = PolyZone:Create(v.polyzone, { name = k, debugPoly = Config.Debug })
                   shopZone:onPlayerInOut(function(isPointInside)
                      if isPointInside then
                         TriggerEvent("qb-mechanicjob:client:SetInsideLocation", true)
                      else
                          TriggerEvent("qb-mechanicjob:client:SetInsideLocation", false)
                      end
                   end)
              end
                if v.showBlip and v.blipCoords and not currentShopBlips[k] then
                    local blip = AddBlipForCoord(v.blipCoords.x, v.blipCoords.y, v.blipCoords.z) -- Sửa lại để đọc table
                    SetBlipSprite(blip, v.blipSprite); SetBlipDisplay(blip, 4); SetBlipScale(blip, 0.6); SetBlipColour(blip, v.blipColor); SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(v.shopLabel); EndTextCommandSetBlipName(blip)
                    currentShopBlips[k] = blip
                end
                if v.duty then
                    exports['qb-target']:AddCircleZone(k .. '_duty', vector3(v.duty.x, v.duty.y, v.duty.z), 0.5, { name = k .. '_duty', useZ = true }, { options = { { event = 'QBCore:ToggleDuty', type = 'server', label = Lang:t('target.duty'), icon = 'fas fa-user-clock', job = v.managed and k or nil } }, distance = 2.0 })
                end
                if v.stash then
                    exports['qb-target']:AddCircleZone(k .. '_stash', vector3(v.stash.x, v.stash.y, v.stash.z), 0.5, { name = k .. '_stash', useZ = true }, { options = { { event = 'qb-mechanicjob:server:stash', type = 'server', data = { job = k }, label = Lang:t('target.stash'), icon = 'fas fa-box-open', job = v.managed and k or nil } }, distance = 2.0 })
                end
                if v.paint then
                    exports['qb-target']:AddCircleZone(k .. '_paintbooth', vector3(v.paint.x, v.paint.y, v.paint.z), 2.5, { name = k .. '_paintbooth', useZ = true }, { options = { { label = Lang:t('target.paint'), icon = 'fas fa-fill-drip', job = v.managed and k or nil, action = function() PaintCategories() end } }, distance = 2.5 })
                end
                if v.vehicles and v.vehicles.withdraw then
                    exports['qb-target']:AddCircleZone(k .. '_spawner', vector3(v.vehicles.withdraw.x, v.vehicles.withdraw.y, v.vehicles.withdraw.z), 1.5, { name = k .. '_spawner', useZ = true }, {
                        options = {
                            {
                                label = Lang:t('target.withdraw'), icon = 'fas fa-car', job = v.managed and k or nil,
                                canInteract = function() return GetVehiclePedIsUsing(PlayerPedId()) == 0 end,
                                action = function() VehicleList(k) end
                            },
                            {
                                label = Lang:t('target.deposit'), icon = 'fas fa-car', job = k,
                                canInteract = function() return GetVehiclePedIsUsing(PlayerPedId()) ~= 0 end,
                                action = function() DeleteEntity(GetVehiclePedIsUsing(PlayerPedId())) end
                            }
                        },
                        distance = 2.5
                    })
                end
            end
        end
    end

    -- =============================================================
    -- PHẦN ĐƯỢC THÊM VÀO ĐỂ TẠO BLIP CHO ĐIỂM XEM TRƯỚC
    -- =============================================================
    if Config.PreviewSpot and Config.PreviewSpot.blip and Config.PreviewSpot.blip.enabled then
        local spotCfg = Config.PreviewSpot
        local mapBlip = AddBlipForCoord(spotCfg.coords.x, spotCfg.coords.y, spotCfg.coords.z)
        SetBlipSprite(mapBlip, spotCfg.blip.sprite)
        SetBlipDisplay(mapBlip, spotCfg.blip.display)
        SetBlipScale(mapBlip, spotCfg.blip.scale)
        SetBlipColour(mapBlip, spotCfg.blip.color)
        SetBlipAsShortRange(mapBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(spotCfg.blip.label)
        EndTextCommandSetBlipName(mapBlip)
    end
end)