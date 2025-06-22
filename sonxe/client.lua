local sprayGuns = {}
local isSpraying, isBusy = false, {}
local currLocation

local rainbowColors = {
    {r = 255, g = 0, b = 0}, {r = 255, g = 127, b = 0}, {r = 255, g = 255, b = 0}, {r = 0, g = 255, b = 0},
    {r = 0, g = 0, b = 255}, {r = 75, g = 0, b = 130}, {r = 148, g = 0, b = 211},
}

RegisterNetEvent('bryan_paintjob:client:setLocationBusy', function(pos, value)
    isBusy[pos] = value
end)

RegisterNetEvent('bryan_paintjob:client:initalizePaint', function(id, vehicle, p)
    local plyCoords = GetEntityCoords(PlayerPedId())
    local loc = Config.Locations[id]
    if not loc or #(plyCoords - loc.control) > 15.0 then return end
    
    local veh = NetToVeh(vehicle)
    if not DoesEntityExist(veh) then return end

    if p.shouldApplyPaint then
        if p.paintChoice == 'primary' then
            SetVehicleModColor_1(veh, p.paintType, 0)
        else
            SetVehicleModColor_2(veh, p.paintType, 0)
        end
    end

    PaintVehicle(veh, p.paintAnimColor, p.paintChoice == 'primary')
    InitializeParticles(id, p.particleColor, veh)
end)

RegisterNetEvent('bryan_paintjob:client:stopPaint', function(id)
    isSpraying = false
end)

Citizen.CreateThread(function()
    for k in ipairs(Config.Locations) do SpawnSprayGuns(k) end
    if Config.UseTarget then
        for k, v in ipairs(Config.Locations) do
            exports.ox_target:addSphereZone({
                coords = v.control, radius = 1.5,
                options = {{ name = 'paint_job', label = 'Sơn Xe', distance = 2.0, canInteract = function() return DoesHaveRequiredJob(k) and not isBusy[k] end, onSelect = function() InitializePaint(k) end }}
            })
        end
    else
        while true do Wait(1000) local coords = GetEntityCoords(PlayerPedId()) currLocation = nil for k, v in ipairs(Config.Locations) do if #(coords - v.control) < 15.0 then currLocation = k; break end end end
    end
end)

if not Config.UseTarget then
    Citizen.CreateThread(function()
        local isDrawn = false
        while true do
            local sleep = 500
            if currLocation and Config.Locations[currLocation] then
                local dist = #(GetEntityCoords(PlayerPedId()) - Config.Locations[currLocation].control)
                if dist < 15.0 then
                    sleep = 5
                    DrawMarker(27, Config.Locations[currLocation].control.x, Config.Locations[currLocation].control.y, Config.Locations[currLocation].control.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 150, false, false, 2, true, nil, nil, false)
                    if dist < 1.5 then
                        if not isBusy[currLocation] then
                            if DoesHaveRequiredJob(currLocation) then
                                if not isDrawn then _ShowHelpNotification('Nhấn [E] để mở tùy chọn sơn'); isDrawn = true end
                                if IsControlJustReleased(0, 38) then lib.hideTextUI(); isDrawn = false; InitializePaint(currLocation) end
                            else
                                if not isDrawn then _ShowHelpNotification('Bạn không có công việc phù hợp.'); isDrawn = true end
                            end
                        else
                            if not isDrawn then _ShowHelpNotification('Phòng sơn đang bận'); isDrawn = true end
                        end
                    elseif isDrawn then
                         lib.hideTextUI(); isDrawn = false
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

function DoesHaveRequiredJob(pos)
    if not Config.Locations[pos] or not Config.Locations[pos].jobs or #Config.Locations[pos].jobs == 0 then return true end
    local playerJob = _GetPlayerJobName() if not playerJob then return false end
    for _, v in ipairs(Config.Locations[pos].jobs) do if v == playerJob then return true end end
    return false
end

function InitializePaint(pos)
    currLocation = pos
    local vehicle = GetVehicleInSprayCoords(Config.Locations[pos].vehicle)
    if not vehicle then return _ShowNotification('Không có xe trong vị trí sơn') end

    TriggerServerEvent('bryan_paintjob:server:setLocationBusy', pos, true)

    local liveryOptions, liverySystem, defaultLivery = {}, 'none', -1
    local liveryCount = GetVehicleLiveryCount(vehicle)
    local altLiveryCount = GetNumVehicleMods(vehicle, 48)
    if liveryCount > 1 then
        liverySystem = 'standard'; defaultLivery = GetVehicleLivery(vehicle)
        table.insert(liveryOptions, { value = -1, label = 'Xóa Decal' })
        for i = 0, liveryCount - 1 do table.insert(liveryOptions, { value = i, label = string.format('Decal #%d [%d/%d]', (i + 1), (i + 1), liveryCount) }) end
    elseif altLiveryCount > 0 then
        liverySystem = 'mod'; defaultLivery = GetVehicleMod(vehicle, 48)
        table.insert(liveryOptions, { value = -1, label = 'Xóa Decal / Mặc định' })
        for i = 0, altLiveryCount - 1 do table.insert(liveryOptions, { value = i, label = string.format('Decal (DLC) #%d [%d/%d]', (i + 1), (i + 1), altLiveryCount) }) end
    else
        table.insert(liveryOptions, { value = -1, label = 'Không có' })
    end

    local pearlescentOptions = {{ value = -1, label = 'Không dùng' }}
    if Config.PearlescentColors and type(Config.PearlescentColors) == 'table' then
        for _, data in ipairs(Config.PearlescentColors) do table.insert(pearlescentOptions, { value = data.value, label = data.label }) end
    else 
        for i = 0, 75 do table.insert(pearlescentOptions, { value = i, label = 'Màu Ngọc Trai #' .. i }) end
    end
    local currentPearlescent, currentWheelColor = GetVehicleExtraColours(vehicle)

    local input = lib.inputDialog('Tùy Chỉnh Sơn & Decal', {
        { type = 'checkbox', label = 'Bật/Tắt Sơn Màu', default = true, help = 'Bật để áp dụng các thay đổi về màu sơn.' },
        { type = 'select', label = 'Sơn Màu', options = {{ value = 'primary', label = 'Màu Chính' }, { value = 'secondary', label = 'Màu Phụ' }}, default = 'primary' },
        { type = 'select', label = 'Loại Sơn', options = {{ value = '0', label = 'Thường' }, { value = '1', label = 'Metallic' }, { value = '2', label = 'Pearl' }, { value = '3', label = 'Matte' }, { value = '4', label = 'Metal' }, { value = '5', label = 'Chrome' }}, default = '0' },
        { type = 'color', label = 'Màu Sắc', default = '#ffffff' },
        { type = 'checkbox', label = 'Bật/Tắt Màu Ngọc Trai', default = false, help = 'Bật để áp dụng màu ngọc trai.'},
        { type = 'select', label = 'Màu Ngọc Trai (Pearlescent)', options = pearlescentOptions, default = currentPearlescent },
        { type = 'checkbox', label = 'Bật/Tắt Decal', default = false, help = 'Bật để áp dụng thay đổi decal.'},
        { type = 'select', label = 'Decal / Livery', options = liveryOptions, default = defaultLivery }
    })

    if not input then return TriggerServerEvent('bryan_paintjob:server:setLocationBusy', pos, false) end

    local params = {
        shouldApplyPaint = input[1],
        paintChoice = input[2],
        paintType = tonumber(input[3]),
        color = Hex2Rgb(input[4]),
        shouldApplyPearlescent = input[5],
        pearlescentColor = tonumber(input[6]),
        shouldApplyLivery = input[7],
        targetLivery = tonumber(input[8]),
    }

    params.liveryChanged = (liverySystem == 'standard' and params.targetLivery ~= defaultLivery) or (liverySystem == 'mod' and params.targetLivery ~= defaultLivery)
    params.pearlescentChanged = params.pearlescentColor ~= currentPearlescent

    if params.shouldApplyLivery and params.liveryChanged then
        if liverySystem == 'standard' then if params.targetLivery == -1 then SetVehicleLivery(vehicle, GetVehicleLiveryCount(vehicle)) else SetVehicleLivery(vehicle, params.targetLivery) end
        elseif liverySystem == 'mod' then SetVehicleMod(vehicle, 48, params.targetLivery, false) end
        _ShowNotification("Đã áp dụng Decal!")
    end

    -- =================================================================================
    -- SỬA LẠI HOÀN TOÀN LOGIC TẠI ĐÂY
    -- =================================================================================
    local effectNeeded = params.shouldApplyPaint or (params.shouldApplyLivery and params.liveryChanged) or (params.shouldApplyPearlescent and params.pearlescentChanged)

    if effectNeeded then
        local function handleFinish()
            while isSpraying do Wait(100) end
            -- Áp dụng màu ngọc trai sau khi sơn xong
            if params.shouldApplyPearlescent and params.paintChoice == 'primary' and params.pearlescentChanged then
                SetVehicleExtraColours(vehicle, params.pearlescentColor, currentWheelColor)
                _ShowNotification("Đã áp dụng màu ngọc trai!")
            end

            -- Lấy thông tin màu sắc cuối cùng của xe
            local primaryR, primaryG, primaryB = GetVehicleCustomPrimaryColour(vehicle)
            local secondaryR, secondaryG, secondaryB = GetVehicleCustomSecondaryColour(vehicle)
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            local livery = GetVehicleLivery(vehicle)
            local modLivery = GetVehicleMod(vehicle, 48) -- Lấy mod 48 (livery)

            -- Lấy biển số xe làm định danh
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)

            -- Gửi dữ liệu màu sắc lên server để lưu vào database
            TriggerServerEvent('bryan_paintjob:server:saveVehiclePaint', vehiclePlate, {
                primary = {r = primaryR, g = primaryG, b = primaryB},
                secondary = {r = secondaryR, g = secondaryG, b = secondaryB},
                pearlescent = pearlescentColor,
                wheel = wheelColor,
                livery = livery,
                modLivery = modLivery
            })

            TriggerServerEvent('bryan_paintjob:server:setLocationBusy', pos, false)
            TriggerServerEvent('bryan_paintjob:server:stopPaint', pos)
        end
        
        if params.shouldApplyPaint then
            params.paintAnimColor = params.color
        else
            local r, g, b
            if params.paintChoice == 'primary' then r, g, b = GetVehicleCustomPrimaryColour(vehicle) else r, g, b = GetVehicleCustomSecondaryColour(vehicle) end
            if r == nil then r, g, b = 255, 255, 255 end
            params.paintAnimColor = { r = r, g = g, b = b }
        end
        
        params.particleColor = (params.shouldApplyLivery and params.liveryChanged) and 'rainbow' or (params.shouldApplyPaint and params.color)
        
        TriggerServerEvent('bryan_paintjob:server:initalizePaint', pos, VehToNet(vehicle), params)
        CreateThread(handleFinish)
    else
        TriggerServerEvent('bryan_paintjob:server:setLocationBusy', pos, false)
    end
end

function GetVehicleInSprayCoords(location)
    local closestVehicle, closestDistance = _GetClosestVehicle(location)
    if closestVehicle and closestVehicle ~= 0 and type(closestDistance) == 'number' and closestDistance <= 4.0 then return closestVehicle end
    return nil
end

function PaintVehicle(vehicle, color, primary)
    if not color or not color.r then return end
    local r, g, b
    if primary then r, g, b = GetVehicleCustomPrimaryColour(vehicle) else r, g, b = GetVehicleCustomSecondaryColour(vehicle) end
    if r == nil then return end

    CreateThread(function()
        isSpraying = true
        local startTime = GetGameTimer()
        local minEffectDuration = 4000 
        while r ~= color.r or g ~= color.g or b ~= color.b do
            Wait(100)
            if not isSpraying or not DoesEntityExist(vehicle) or (GetGameTimer() - startTime > 20000) then break end
            r = color.r > r and r + 1 or (color.r < r and r - 1 or r)
            g = color.g > g and g + 1 or (color.g < g and g - 1 or g)
            b = color.b > b and b + 1 or (color.b < b and b - 1 or b)
            if DoesEntityExist(vehicle) then
                if primary then SetVehicleCustomPrimaryColour(vehicle, r, g, b) else SetVehicleCustomSecondaryColour(vehicle, r, g, b) end
            end
        end
        local elapsedTime = GetGameTimer() - startTime
        if elapsedTime < minEffectDuration then Wait(minEffectDuration - elapsedTime) end
        if DoesEntityExist(vehicle) then
            if primary then SetVehicleCustomPrimaryColour(vehicle, color.r, color.g, color.b) else SetVehicleCustomSecondaryColour(vehicle, color.r, color.g, color.b) end
        end
        isSpraying = false
    end)
end

function InitializeParticles(id, color, vehicle)
    CreateThread(function()
        local particles = {}
        local isRainbow = type(color) == 'string' and color == 'rainbow'
        if DoesEntityExist(vehicle) then FreezeEntityPosition(vehicle, true) end
        for _, gun in ipairs(sprayGuns) do
            if gun.id == id then
                local particleColor = isRainbow and rainbowColors[math.random(1, #rainbowColors)] or color
                local sprayConfig = Config.Locations[gun.id].sprays[gun.location]
                table.insert(particles, SprayParticles('core', 'ent_amb_steam', sprayConfig.scale, particleColor, gun.object, sprayConfig.rotation))
            end
        end
        while isSpraying do Wait(100) end
        if DoesEntityExist(vehicle) then FreezeEntityPosition(vehicle, false) end
        for _, particle in ipairs(particles) do StopParticleFxLooped(particle, false) end
        local smokeEffect = SprayParticles('scr_paintnspray', 'scr_respray_smoke', 0.5, {r = 128, g = 128, b = 128}, vehicle, vector3(0.0, 0.0, 0.0))
        Wait(3000)
        StopParticleFxLooped(smokeEffect, false)
    end)
end

function SprayParticles(dict, name, scale, color, entity, rotation)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do Wait(10) end
    UseParticleFxAsset(dict)
    local particleHandle = StartParticleFxLoopedOnEntity(name, entity, 0.2, 0.0, 0.1, 0.0, 80.0, 0.0, scale, false, false, false)
    if color and color.r then SetParticleFxLoopedColour(particleHandle, color.r / 255.0, color.g / 255.0, color.b / 255.0, 0) end
    SetParticleFxLoopedAlpha(particleHandle, 1.0)
    return particleHandle
end

function Hex2Rgb(hex)
    if not hex or type(hex) ~= 'string' or #hex ~= 7 then return { r = 255, g = 255, b = 255 } end
    hex = hex:gsub('#', '')
    local r, g, b = tonumber('0x' .. hex:sub(1, 2)), tonumber('0x' .. hex:sub(3, 4)), tonumber('0x' .. hex:sub(5, 6))
    if r and g and b then return { r = r, g = g, b = b } end
    return { r = 255, g = 255, b = 255 }
end

function SpawnSprayGuns(id)
    local hash = GetHashKey(Config.SprayModel)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    for k, v in ipairs(Config.Locations[id].sprays) do
        local object = CreateObject(hash, v.pos.x, v.pos.y, v.pos.z, false, true, false)
        SetEntityRotation(object, v.rotation.x, v.rotation.y, v.rotation.z, 0, 1)
        FreezeEntityPosition(object, true)
        table.insert(sprayGuns, { object = object, id = id, location = k })
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, v in ipairs(sprayGuns) do if DoesEntityExist(v.object) then DeleteEntity(v.object) end end
        sprayGuns = {}
    end
end)