-- =================================================================
-- TỆP FUNCTIONS.LUA HOÀN CHỈNH CHO CLIENT
-- =================================================================
QBCore = exports['qb-core']:GetCoreObject()

-- Các hàm phụ trợ cơ bản
function trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function inCar()
    if IsPedSittingInAnyVehicle(PlayerPedId()) then
        triggerNotify(nil, "Không thể làm điều này khi ở trong xe", "error"); return false
    end; return true
end

function outCar()
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then
        triggerNotify(nil, "Phải ở trong xe để thực hiện", "error"); return false
    end; return true
end

function lockedCar(vehicle)
    if GetVehicleDoorLockStatus(vehicle) >= 2 then
        triggerNotify(nil, "Xe đang bị khóa", "error"); return true
    end; return false
end

function nearPoint(coords)
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.5) then
        triggerNotify(nil, "Không có xe nào gần đây", "error"); return false
    end; return true
end

function getClosest(coords)
    return QBCore.Functions.GetClosestVehicle(coords)
end

function pushVehicle(entity)
    if DoesEntityExist(entity) then
        SetVehicleModKit(entity, 0)
        if not NetworkHasControlOfEntity(entity) then NetworkRequestControlOfEntity(entity) end
        if not IsEntityAMissionEntity(entity) then SetEntityAsMissionEntity(entity, true, true) end
    end
end

function lookVeh(vehicle)
    if DoesEntityExist(vehicle) and not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(vehicle), 30.0) then
        TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(vehicle), 1500); Wait(1500)
    end
end

-- Các hàm logic client
function jobChecks() return true end -- Tạm thời bỏ qua kiểm tra job
function updateCar(vehicle) end -- Tạm thời bỏ qua
function emptyHands(playerPed) ClearPedTasks(playerPed) end
function playAnim(animDict, animName, duration, flag)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(1) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, flag, 1, false, false, false)
end

-- Hàm thông báo
function triggerNotify(title, message, type)
    exports['qb-core']:Notify(message or title, type or 'primary')
end

-- Hàm xử lý vật phẩm phía client
function toggleItem(give, item, amount)
    TriggerServerEvent("jim-mechanic:server:toggleItem", give, item, amount)
end

function HasItem(item, amount)
    local count = 0
    local items = QBCore.Functions.GetPlayerData().items
    for _, itemData in pairs(items) do
        if itemData and itemData.name == item then
            count = count + itemData.amount
        end
    end
    return count >= (amount or 1)
end

-- Hàm vẽ thanh bar
function nosBar(level)
    local full, empty = (Config.nosBarFull or "▓"), (Config.nosBarEmpty or "░")
    local green, yellow, red, grey = "green", "yellow", "red", "grey"
    if not Config.nosBarColour then green, yellow, red, grey = "white", "white", "white", "grey" end

    local bartable = {}
    for i = 1, 10 do bartable[i] = "<span style='color:"..green.."'>"..full.."</span>" end
    if level <= 91 then bartable[10] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 81 then bartable[9] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 71 then bartable[8] = "<span style='color:"..grey.."'>"..empty.."</span>"; for i=1,7 do bartable[i] = "<span style='color:"..yellow.."'>"..full.."</span>" end end
    if level <= 31 then for i=1,3 do bartable[i] = "<span style='color:"..red.."'>"..full.."</span>" end end
    if level <= 61 then bartable[7] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 51 then bartable[6] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 41 then bartable[5] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 21 then bartable[3] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 11 then bartable[2] = "<span style='color:"..grey.."'>"..empty.."</span>" end
    if level <= 1 then bartable[1] = "<span style='color:"..grey.."'>"..empty.."</span>" end

    return table.concat(bartable)
end

function HexTorgb(hex)
    local hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end