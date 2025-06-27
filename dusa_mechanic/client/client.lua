local firstProperties
local currentProperties
local currentFitment
local temporaryProperties
local menuOpened = false
local ranks = {}
local tuning = {}
vehData = {}

local players_clean = {}
function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = dusa.getPlayersInArea(GetEntityCoords(playerPed), 10.0)

    players_clean = {}
    local found_players = false

    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            TriggerServerEvent('dusa_mechanic:sv:findIdentifier', GetPlayerServerId(players[i]))
        end
    end
    Wait(500)
    return players_clean
end

RegisterNetEvent('dusa_mechanic:cl:addToPlayersClean', function(name, id, identifier)
    found_players = true
    table.insert(players_clean, {name = name, identifier = identifier, rank = 0, img = "https://picsum.photos/300/300"} )
end)

function OpenMechanic()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    firstProperties = getVehicleProperties(vehicle)
    currentProperties = getVehicleProperties(vehicle)
    currentFitment = GetVehicleFitment(vehicle)
    local discount = json.decode(dusa.playerMechanic.mechanic).discount
    local playername = GetPlayerName(PlayerId())
    if dusa.framework == 'qb' then dusa.playerData.identifier = dusa.playerData.citizenid playername = dusa.playerData.charinfo.firstname.." "..dusa.playerData.charinfo.lastname end
    DisplayHud(false)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'mechanic',
        mechanic = dusa.playerMechanic,
        mods = loadMods(vehicle),
        status = VehicleStatus(),
        neons = tuning[GetVehicleNumberPlateText(vehicle)],
        closestPlayers = GetNeareastPlayers(),
        translate = Config.Translations[Config.Locale],
        discount = discount
    })
    FreezeEntityPosition(vehicle, true)
    menuOpened = true
    -- HideMap(true)
end

function OpenTuning()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'tuning',
        neons = tuning[GetVehicleNumberPlateText(vehicle)],
        translate = Config.Translations[Config.Locale]
    })
    menuOpened = true
end

RegisterNetEvent('dusa_mechanic:cl:useTuning', OpenTuning)

RegisterNUICallback('addEmployee', function(data)
    local data = data.data
    TriggerServerEvent('dusa_mechanic:sv:addEmployee', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('kickStaff', function(data)
    local data = data.data
    TriggerServerEvent('dusa_mechanic:sv:kickStaff', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('demote', function(data)
    local data = data.data
    TriggerServerEvent('dusa_mechanic:sv:demote', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('promote', function(data)
    local data = data.data
    TriggerServerEvent('dusa_mechanic:sv:promote', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('withdraw', function(data)
    local data = data.data
    dusa.showNotification(Config.Translations[Config.Locale].withdrawn .. data.amount, 'success')
    TriggerServerEvent('dusa_mechanic:sv:vault', 'withdraw', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('deposit', function(data)
    local data = data.data
    dusa.showNotification(Config.Translations[Config.Locale].deposited .. data.amount, 'success')
    TriggerServerEvent('dusa_mechanic:sv:vault', 'deposit', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('setFee', function(data)
    local data = data.data
    dusa.showNotification(Config.Translations[Config.Locale].fee .. data.fee, 'success')
    TriggerServerEvent('dusa_mechanic:sv:setFee', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('setDiscount', function(data)
    local data = data.data
    dusa.showNotification(Config.Translations[Config.Locale].discount .. data.discount, 'success')
    TriggerServerEvent('dusa_mechanic:sv:setDiscount', data, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('setName', function(data)
    local data = data.data
    dusa.showNotification(Config.Translations[Config.Locale].name .. data.name, 'success')
    TriggerServerEvent('dusa_mechanic:sv:setName', data, tonumber(dusa.playerMechanic.m_id))
    TriggerServerEvent('dusa_mechanic:sv:syncBlips')
end)

RegisterNetEvent('dusa_mechanic:cl:syncBlips', function()
    RemoveBlips()
end)

RegisterNetEvent('dusa_mechanic:cl:placeBlips', function(v)
    SetBlips(v)
end)

RegisterNUICallback('applyTuning', function(data)
    local data = data.data
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local plate = GetVehicleNumberPlateText(vehicle)
    tuning[plate] = {headlights = false, front_neon = false, back_neon = false, left_neon = false, right_neon = false, neoncolor = false}
    for k, v in pairs(data) do
        tuning[plate][k] = v
    end
    local veri = {
        plate = plate,
        tuning = tuning[plate]
    }
    dusa.showNotification('Tuning changes applied successfully to vehicle!', 'success')
    ToggleNeons()
    SwitchMode(vehicle, data.vehiclemode)
    SetTuning(vehicle, data)
    TriggerServerEvent("dusa_mechanic:sv:addElement", "tuning", veri)
    -- TriggerServerEvent('dusa_mechanic:sv:saveTuning', tuning)
end)

-- RegisterCommand('nitroo', function()
--     local ped = PlayerPedId()
--     local vehicle = GetVehiclePedIsIn(ped)
--     local plate = GetVehicleNumberPlateText(vehicle)
--     local veri = {
--         plate = plate,
--         nitro = true,
--         remaining = 5
--     }
--     TriggerServerEvent("dusa_mechanic:sv:addElement", "nitro", veri)
-- end)

RegisterNetEvent('dusa_mechanic:cl:useNitro', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
    local plate = GetVehicleNumberPlateText(vehicle)
    local veri = {
        plate = plate,
        nitro = true,
        remaining = Config.Settings.nitro.stock
    }

        if IsInVehicle and not IsThisModelABike(GetEntityModel(GetVehiclePedIsIn(ped))) then
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                dusa.progressBar('use_nos', 'Connecting NOS', 1000, false, false, false, true, function() TriggerServerEvent("dusa_mechanic:sv:addElement", "nitro", veri) end)
            else
                dusa.showNotification('You have to be driver of vehicle', "error")
            end
        else
            dusa.showNotification('You are not in vehicle', 'error')
        end
end)

RegisterNUICallback('closeUI', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    SetNuiFocus(false, false)
    FreezeEntityPosition(vehicle, false)
    -- HideMap(false)
    DisplayHud(true)
    menuOpened = false
end)

RegisterNUICallback("repairVehicle", function(data, cbj)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

	WashDecalsFromVehicle(vehicle, 1.0)
	SetVehicleDirtLevel(vehicle)
    SetVehicleEngineOn(vehicle, true, true)
    SetVehicleEngineHealth(vehicle, 1000.0) 
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    cbj("ok")
end)

RegisterNetEvent('dusa_mechanic:cl:playermechanic', function(data)
    dusa.playerMechanic = data
end)

-- TUNING
LastEngineMultiplier = 1.0
function SetTuning(veh, data)
    local multp = 0.12
    local dTrain = 0.0
    local plate = GetVehicleNumberPlateText(veh)
    local vehicleAcceleration = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")
    local vehicleBraking = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")
    tuning[plate].boost = data.boost
    tuning[plate].acceleration = data.acceleration
    tuning[plate].breaking = data.breaking
    tuning[plate].gearchange = data.gearchange
    tuning[plate].drivetrain = data.drivetrain
    data.boost = data.boost / 20
    data.acceleration = data.acceleration / 20
    data.breaking = data.breaking / 20
    data.gearchange = data.gearchange / 20
    data.drivetrain = data.drivetrain / 20
    if tonumber(data.drivetrain) <= 2.5 then dTrain = 0.5 elseif tonumber(data.drivetrain) > 2.5 then dTrain = 1.0 end
    if not DoesEntityExist(veh) or not data then return nil end
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost * multp)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", vehicleAcceleration + (data.acceleration * multp))
    SetVehicleEnginePowerMultiplier(veh, data.gearchange * multp)
    LastEngineMultiplier = data.gearchange * multp
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", dTrain*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.breaking * multp)
end

function resetVeh(veh)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", 1.0)
    SetVehicleEnginePowerMultiplier(veh, 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.5)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", 1.0)
end

-- CAR MODES
function SwitchMode(veh, type)
    local plate = GetVehicleNumberPlateText(veh)
    if not tuning[plate] then tuning[plate] = {} else tuning[plate].vehiclemode = type end 
    if type == 'sport' then
        local speed = Config.IncreaseSpeed
        local maxspeed = Config.MaxSpeed
        -- dusa.showNotification(Config.Translations[Config.Locale].sport, 'success')
        SetDriftTyresEnabled(veh, false)
        SetReduceDriftVehicleSuspension(veh, false)
        SetVehicleEnginePowerMultiplier(veh, speed)
        SetVehicleEngineTorqueMultiplier(veh, speed)
        SetEntityMaxSpeed(veh, maxspeed)
    elseif type == 'drift' then
        -- dusa.showNotification(Config.Translations[Config.Locale].drift, 'success')
        SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
        SetVehicleEngineTorqueMultiplier(veh, 1.0)

        SetDriftTyresEnabled(veh, true)
        SetReduceDriftVehicleSuspension(veh, true)
    elseif type == 'eco' then
        -- dusa.showNotification(Config.Translations[Config.Locale].eco, 'success')
        SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
        SetVehicleEngineTorqueMultiplier(veh, 1.0)
        SetDriftTyresEnabled(veh, false)
        SetReduceDriftVehicleSuspension(veh, false)
    end
end

-- NEON
function ToggleNeons()
	if player == nil then
		player = PlayerPedId()
	end
	if vehicle == nil then
		vehicle = GetVehiclePedIsIn(player, false)
	end
	if plate == nil then
		plate = GetVehicleNumberPlateText(vehicle)
	end		
    if tuning[plate].left_neon == true then
        SetVehicleNeonLightEnabled(vehicle, 0, true)
    else
        SetVehicleNeonLightEnabled(vehicle, 0, false)
    end
    if tuning[plate].right_neon == true then
        SetVehicleNeonLightEnabled(vehicle, 1, true)
    else
        SetVehicleNeonLightEnabled(vehicle, 1, false)
    end
    if tuning[plate].front_neon == true then
        SetVehicleNeonLightEnabled(vehicle, 2, true)
    else
        SetVehicleNeonLightEnabled(vehicle, 2, false)
    end
    if tuning[plate].back_neon == true then
        SetVehicleNeonLightEnabled(vehicle, 3, true)
    end
    if tuning[plate].headlights then
        local r, g, b = tuning[plate].headlights:match("rgb%((%d+), (%d+), (%d+)%)")
        -- ToggleVehicleMod(vehicle, 22, true)
        -- SetVehicleXenonLightsCustomColor(vehicle, tonumber(r), tonumber(g), tonumber(b))
        TriggerServerEvent('dusa_mechanic:sv:syncHeadlight', NetworkGetNetworkIdFromEntity(vehicle), tonumber(r), tonumber(g), tonumber(b))
    end
    if tuning[plate].neoncolor then
        local r, g, b = tuning[plate].neoncolor:match("rgb%((%d+), (%d+), (%d+)%)")
        SetVehicleNeonLightsColour(vehicle, tonumber(r), tonumber(g), tonumber(b))
    end
    ToggleRainbow(player, vehicle, plate)
    local anims = tuning[plate].anims
    if anims.blinking or anims.snake or anims.fourways or anims.lightnings or anims.crisscross then AnimNeons(player, vehicle, plate) end
end

function ToggleRainbow(player, vehicle, vehicleplate)
	Citizen.CreateThread(function()
		local function RGBRainbow(frequency)
			local result = {}
			local curtime = GetGameTimer() / 1000
			result.r = math.floor( math.sin( curtime * frequency + 0 ) * 127 + 128 )
			result.g = math.floor( math.sin( curtime * frequency + 2 ) * 127 + 128 )
			result.b = math.floor( math.sin( curtime * frequency + 4 ) * 127 + 128 )	
			return result
		end
	    while true do
	    	Citizen.Wait(500)
			if player == nil then
				player = PlayerPedId()
			end
			if vehicle == nil then
				vehicle = GetVehiclePedIsIn(player, false)
			end
			if vehicleplate == nil then
				vehicleplate = GetVehicleNumberPlateText(vehicle)
			end				
			if IsPedSittingInAnyVehicle(player) and GetPedInVehicleSeat(vehicle, -1) == player then
				if tuning[vehicleplate].neonrgb == true then
			        local rainbow = RGBRainbow(1.36)
					SetVehicleNeonLightsColour(vehicle, rainbow.r, rainbow.g, rainbow.b)
				end
				if tuning[vehicleplate].headlightsrgb == true then
			        local rainbow = RGBRainbow(1.36)
                    ToggleVehicleMod(vehicle, 22, true)
                    SetVehicleXenonLightsCustomColor(vehicle, rainbow.r, rainbow.g, rainbow.b)
				end
			else
				break
			end
		end
	end)
end

function AnimNeons(player, vehicle, plate)
    CreateThread(function()
        while true do
            Wait(500)
            -- Blink
            if tuning[plate].anims.blinking == true then
                AnimateNeon(vehicle, 'open')
                if tuning[plate].anims.blinking == true then
                    AnimateNeon(vehicle, 'close')
                end
            -- Snake
            elseif tuning[plate].anims.snake == true then -- 3, 1, 2, 0, 3, 1, 2, 0
                AnimateNeon(vehicle, 'openone', 3)
                if tuning[plate].anims.snake == true then
                    AnimateNeon(vehicle, 'openone', 1)
                    if tuning[plate].anims.snake == true then
                        AnimateNeon(vehicle, 'openone', 2)
                        if tuning[plate].anims.snake == true then
                            AnimateNeon(vehicle, 'openone', 0)
                            if tuning[plate].anims.snake == true then	
                                AnimateNeon(vehicle, 'openone', 3)
                                if tuning[plate].anims.snake == true then
                                    AnimateNeon(vehicle, 'openone', 1)
                                    if tuning[plate].anims.snake == true then
                                        AnimateNeon(vehicle, 'openone', 2)
                                        if tuning[plate].anims.snake == true then
                                            AnimateNeon(vehicle, 'openone', 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif tuning[plate].anims.fourways == true then
                AnimateNeon(vehicle, 'openone', 3)
                AnimateNeon(vehicle, 'openone', 1)
                AnimateNeon(vehicle, 'openone', 2)
                AnimateNeon(vehicle, 'openone', 0)
            elseif tuning[plate].anims.lightnings == true then
                SetVehicleNeonLightEnabled(vehicle, 3, true)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                Citizen.Wait(500)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                Citizen.Wait(500)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                Citizen.Wait(500)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                Citizen.Wait(500)
            elseif tuning[plate].anims.crisscross == true then
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                Citizen.Wait(500)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                SetVehicleNeonLightEnabled(vehicle, 3, true)			
                Citizen.Wait(500)  
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
                Citizen.Wait(500)
            else
                StopAnimates(vehicle)
                break
            end
        end
    end)
end

function AnimateNeon(vehicle, action, neon)
    if action == 'open' then
        SetVehicleNeonLightEnabled(vehicle, 3, true)
        SetVehicleNeonLightEnabled(vehicle, 1, true)
        SetVehicleNeonLightEnabled(vehicle, 2, true)
        SetVehicleNeonLightEnabled(vehicle, 0, true)
    elseif action == 'close' then
        SetVehicleNeonLightEnabled(vehicle, 3, false)
        SetVehicleNeonLightEnabled(vehicle, 1, false)
        SetVehicleNeonLightEnabled(vehicle, 2, false)
        SetVehicleNeonLightEnabled(vehicle, 0, false)
    elseif action == 'openone' then
        for i = 1, 4 do
            if i == neon then
                SetVehicleNeonLightEnabled(vehicle, i, true)
            else
                SetVehicleNeonLightEnabled(vehicle, i, false)
            end
        end
    elseif action == 'closeone' then
        for i = 1, 4 do
            if i == neon then
                SetVehicleNeonLightEnabled(vehicle, i, false)
            else
                SetVehicleNeonLightEnabled(vehicle, i, true)
            end
        end
    end
    Citizen.Wait(500)
end

function StopAnimates(vehicle)
    SetVehicleNeonLightEnabled(vehicle, 3, false)
    SetVehicleNeonLightEnabled(vehicle, 1, false)
    SetVehicleNeonLightEnabled(vehicle, 2, false)
    SetVehicleNeonLightEnabled(vehicle, 0, false)
end

-- MECHANIC
addMod = function(vehicle, modId, stock, modPrice)
	SetVehicleModKit(vehicle, 0)
    local mechanic_parts = {}
    local found = false

    if modId == "plates" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Blue on White 1", mod = 0, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Blue On White 2", mod = 3, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Blue On White 3", mod = 4, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Yellow on Blue", mod = 2, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Yellow on Black", mod = 1, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "plates", label = "Yankton", mod = 5, price = modPrice.basePrice}
        local currentModIndex = GetVehicleNumberPlateTextIndex(vehicle)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == "vehicle_traction" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "vehicle_traction", label = "Stock", mod = "Stock", price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = "vehicle_traction", label = "FWD", mod = "FWD", price = modPrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = "vehicle_traction", label = "RWD", mod = "RWD", price = modPrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "vehicle_traction", label = "AWD", mod = "AWD", price = modPrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = "vehicle_traction", label = "FourWD", mod = "FourWD", price = modPrice}
        local currentModIndex = trim(GetVehicleNumberPlateText(vehicle))
        mechanic_parts[1].attached = true
        for plate, vehd in pairs(vehData) do
            if plate == currentModIndex then
                if vehd.vehicle_traction then
                    for k,v in pairs(mechanic_parts) do
                        if v.mod == vehd.vehicle_traction then
                            v.attached = true
                            mechanic_parts[1].attached = nil
                        end
                    end
                end
            end
        end
    elseif modId == "nitro" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "nitro", label = "Stock", mod = "Stock", price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = "nitro", label = "NOS", mod = "nos", price = modPrice }
        local currentModIndex = trim(GetVehicleNumberPlateText(vehicle))
        mechanic_parts[1].attached = true
        for plate, vehd in pairs(vehData) do
            if plate == currentModIndex then
                if vehd.nitro then
                    for k,v in pairs(mechanic_parts) do
                        if v.mod == vehd.nitro then
                            v.attached = true
                            mechanic_parts[1].attached = nil
                        end
                    end
                end
            end
        end
    elseif modId == "popcorn" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "popcorn", label = "Stock", mod = "Stock", price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = "popcorn", label = "Popcorn Exhaust", mod = "popcorn", price = modPrice }
        local currentModIndex = trim(GetVehicleNumberPlateText(vehicle))
        mechanic_parts[1].attached = true
        for plate, vehd in pairs(vehData) do
            if plate == currentModIndex then
                if vehd.popcorn then
                    for k,v in pairs(mechanic_parts) do
                        if v.mod == vehd.popcorn then
                            v.attached = true
                            mechanic_parts[1].attached = nil
                        end
                    end
                end
            end
        end
    elseif modId == 12 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 12, label = "Street Brakes", mod = 0, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = 12, label = "Sport Brakes", mod = 1, price = modPrice.basePrice + (modPrice.increaseby * 2) }
        mechanic_parts[#mechanic_parts + 1] = { modId = 12, label = "Race Brakes", mod = 2, price = modPrice.basePrice + (modPrice.increaseby * 3) }
        local currentModIndex = GetVehicleMod(vehicle, 12)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == 13 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 13, label = "Street Transmission", mod = 0, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = 13, label = "Sports Transmission", mod = 1, price = modPrice.basePrice + (modPrice.increaseby * 2) }
        mechanic_parts[#mechanic_parts + 1] = { modId = 13, label = "Race Transmission", mod = 2, price = modPrice.basePrice + (modPrice.increaseby * 3) }
        local currentModIndex = GetVehicleMod(vehicle, 13)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == 18 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 18, label = "None", mod = 0, price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = 18, label = "Turbo Tuning", mod = 1, price = modPrice }
        if IsToggleModOn(vehicle, 18) then
            mechanic_parts[2].attached = true
        else
            mechanic_parts[1].attached = true
        end
    elseif modId == "tire_smoke" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "tire_smoke", label = "Disable", mod = 0, price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = "tire_smoke", label = "Enable", mod = 1, price = modPrice.basePrice}
        if IsToggleModOn(vehicle, 20) then
            mechanic_parts[2].attached = true
        else
            mechanic_parts[1].attached = true
        end
    elseif modId == "window_tint" then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Stock", mod = 4, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "None", mod = 0, price = modPrice.basePrice + (modPrice.increaseby * 2)} 
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Limo", mod = 5, price = modPrice.basePrice + (modPrice.increaseby * 3)} 
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Light Smoke", mod = 3, price = modPrice.basePrice + (modPrice.increaseby * 4)} 
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Dark Smoke", mod = 2, price = modPrice.basePrice + (modPrice.increaseby * 5)} 
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Pure Black", mod = 1, price = modPrice.basePrice + (modPrice.increaseby * 6)} 
        mechanic_parts[#mechanic_parts + 1] = { modId = "window_tint", label = "Green", mod = 6, price = modPrice.basePrice + (modPrice.increaseby * 7)} 
        local currentModIndex = GetVehicleWindowTint(vehicle)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == 15 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 15, label = "Lowered Suspension", mod = 0, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = 15, label = "Street Suspension", mod = 1, price = modPrice.basePrice + (modPrice.increaseby * 2) }
        mechanic_parts[#mechanic_parts + 1] = { modId = 15, label = "Sport Suspension", mod = 2, price = modPrice.basePrice + (modPrice.increaseby * 3) }
        mechanic_parts[#mechanic_parts + 1] = { modId = 15, label = "Competition Suspension", mod = 3, price = modPrice.basePrice + (modPrice.increaseby * 4) }
        local currentModIndex = GetVehicleMod(vehicle, 15)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == 11 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 11, label = "Level 2", mod = 0, price = modPrice.basePrice }
        mechanic_parts[#mechanic_parts + 1] = { modId = 11, label = "Level 3", mod = 1, price = modPrice.basePrice + (modPrice.increaseby * 2) }
        mechanic_parts[#mechanic_parts + 1] = { modId = 11, label = "Level 4", mod = 2, price = modPrice.basePrice + (modPrice.increaseby * 3) }
        local currentModIndex = GetVehicleMod(vehicle, 11)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    elseif modId == 22 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 22, label = "Stock Lights", mod = 0, price = 0 }
        mechanic_parts[#mechanic_parts + 1] = { modId = 22, label = "Xenon Lights", mod = 1, price = modPrice.basePrice }
        if IsToggleModOn(vehicle, 22) then
            mechanic_parts[2].attached = true
        else
            mechanic_parts[1].attached = true
        end
    elseif modId == 14 then
        found = true
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Truck Horn", mod = 0, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Police Horn", mod = 1, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Clown Horn", mod = 2, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Musical Horn 1", mod = 3, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Musical Horn 2", mod = 4, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Musical Horn 3", mod = 5, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Musical Horn 4", mod = 6, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Musical Horn 5", mod = 7, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Sadtrombone Horn", mod = 8, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 1", mod = 9, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 2", mod = 10, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 3", mod = 11, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 4", mod = 12, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 5", mod = 13, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 6", mod = 14, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Calssical Horn 7", mod = 15, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scaledo Horn", mod = 16, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scalere Horn", mod = 17, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scalemi Horn", mod = 18, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scalefa Horn", mod = 19, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scalesol Horn", mod = 20, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scalela Horn", mod = 21, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scaleti Horn", mod = 22, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Scaledo Horn High", mod = 23, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Jazz Horn 1", mod = 25, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Jazz Horn 2", mod = 26, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Jazz Horn 3", mod = 27, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Jazzloop Horn", mod = 28, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Starspangban Horn 1", mod = 29, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Starspangban Horn 2", mod = 30, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Starspangban Horn 3", mod = 31, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Starspangban Horn 4", mod = 32, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Classicalloop Horn 1", mod = 33, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Classicalloop Horn 2", mod = 34, price = modPrice.basePrice}
        mechanic_parts[#mechanic_parts + 1] = { modId = 14, label = "Classicalloop Horn 3", mod = 35, price = modPrice.basePrice}
        local currentModIndex = GetVehicleMod(vehicle, 14)
        for k,v in pairs(mechanic_parts) do
            if v.mod == currentModIndex then
                v.attached = true
            end
        end
    else
        if (GetNumVehicleMods(vehicle, modId) ~= nil and GetNumVehicleMods(vehicle, modId) > 0) then
            if stock then
                mechanic_parts[#mechanic_parts + 1] = {
                    label = "Stock",
                    modId = modId,
                    price = 0,
                    mod = -1
                }
            end
            for i = 0, tonumber(GetNumVehicleMods(vehicle, modId)) - 1 do
                local modText = GetModTextLabel(vehicle, modId, i)
                local modLabel = tostring(GetLabelText(modText))
                mechanic_parts[#mechanic_parts + 1] = {
                    label = modLabel ~= "NULL" and modLabel or ("Mod %s"):format(#mechanic_parts),
                    modId = modId,
                    price = (modPrice.basePrice) + ((modPrice.increaseby and modPrice.increaseby * i) or 0) ,
                    mod = i,
                }
            end

            local currentMod = GetVehicleMod(vehicle, modId)
            if currentMod > -1 then
                for k,v in pairs(mechanic_parts) do
                    if v.mod == currentMod then
                        mechanic_parts[k].attached = true
                    end
                end
            end

            found = true
        end
    end

    if not found then
        return nil
    end

    return mechanic_parts
end

loadMods = function(vehicle)
    local modifyMenu = Config.Menus
    local modMenu = {}
    local chassis, interior, fbumper, rbumper, isBike = false, false, false, false, false

    for i = 0, 48 do
        if GetNumVehicleMods(vehicle, i) ~= nil and GetNumVehicleMods(vehicle, i) ~= false and GetNumVehicleMods(vehicle, i) > 0 then
            if i == 1 then
                fbumper = true
            elseif i == 2 then
                rbumper = true
            elseif (i >= 42 and i <= 46) or i == 5 then 
                chassis = true
            elseif i >= 27 and i <= 37 then 
                interior = true
            end
        end
    end

    if IsThisModelABike(GetEntityModel(vehicle)) then
        isBike = true
    end

    modMenu[1] = {
        label = "Vehicle Customization",
        category = "vehicle",
        img = "vehicle",
        type = "main",
        items = {}
    }

    modMenu[2] = {
        label = "Vehicle Cosmetics",
        category = "cosmetic",
        img = "cosmetic",
        type = "main",
        items = {}
    }

    modMenu[3] = {
        label = "Upgrades",
        category = "upgrades",
        img = "upgrades",
        type = "main",
        items = {}
    }

    modMenu[4] = {
        label = "Wheels",
        category = "wheel",
        img = "wheel",
        type = "main",
        items = {}
    }

    modMenu[5] = {
        label = "Paint Booth",
        category = "paintbrush",
        img = "paintbrush",
        type = "main",
        items = {}
    }

    modMenu[6] = {
        label = "Wheel Fitment",
        category = "fitment",
        img = "fitment",
        type = "main",
        items = {}
    }

    -- modMenu[7] = {
    --     label = "Repair Vehicle",
    --     img = "repair",
    --     type = "main",
    --     items = {}
    -- }

    modMenu[3].items["Brakes"] = {
        img = "brakes",
        type = "submenu",
        items = addMod(vehicle, 12, true, modifyMenu.upgrades.brakes)
    }

    modMenu[3].items["Transmission"] = {
        img = "transmission",
        type = "submenu",
        items = addMod(vehicle, 13, true, modifyMenu.upgrades.transmission)
    }

    modMenu[3].items["Turbo"] = {
        img = "turbo",
        type = "submenu",
        items = addMod(vehicle, 18, false, modifyMenu.upgrades.turbo)
    }

    modMenu[3].items["Suspension"] = {
        img = "suspension",
        type = "submenu",
        items = addMod(vehicle, 15, true, modifyMenu.upgrades.suspension)
    }

    modMenu[3].items["Engine"] = {
        img = "engine",
        type = "submenu",
        items = addMod(vehicle, 11, true, modifyMenu.upgrades.engine)
    }

    modMenu[1].items["Spoiler"] = {
        img = "spoiler",
        type = "submenu",
        items = addMod(vehicle, 0, true, modifyMenu.customization.spoiler)
    }

    modMenu[1].items["Skirts"] = {
        img = "skirts",
        type = "submenu",
        items = addMod(vehicle, 3, true, modifyMenu.customization.skirts)
    }

    modMenu[1].items["Exhausts"] = {
        img = "exhausts",
        type = "submenu",
        items = addMod(vehicle, 4, true, modifyMenu.customization.exhausts)
    }

    modMenu[1].items["Grille"] = {
        img = "grille",
        type = "submenu",
        items = addMod(vehicle, 6, true, modifyMenu.customization.grille)
    }

    modMenu[1].items["Hood"] = {
        img = "hood",
        type = "submenu",
        items = addMod(vehicle, 7, true, modifyMenu.customization.hood)
    }

    modMenu[1].items["Fenders"] = {
        img = "fenders",
        type = "submenu",
        items = addMod(vehicle, 8, true, modifyMenu.customization.fenders)
    }

    modMenu[1].items["Roof"] = {
        img = "roof",
        type = "submenu",
        items = addMod(vehicle, 10, true, modifyMenu.customization.roof)
    }

    modMenu[1].items["Horn"] = {
        img = "horn",
        type = "submenu",
        items = addMod(vehicle, 14, true, modifyMenu.customization.horn)
    }

    modMenu[1].items["Engine Block"] = {
        img = "engine_block",
        type = "submenu",
        items = addMod(vehicle, 39, true, modifyMenu.customization.engine_block)
    }

    modMenu[1].items["Air Filters"] = {
        img = "air_filters",
        type = "submenu",
        items = addMod(vehicle, 40, true, modifyMenu.customization.air_filters)
    }

    modMenu[1].items["Struts"] = {
        img = "struts",
        type = "submenu",
        items = addMod(vehicle, 41, true, modifyMenu.customization.struts)
    }

    modMenu[1].items["License"] = {
        img = "license_plate",
        type = "submenu",
        items = addMod(vehicle, "plates", true, modifyMenu.customization.license_plate)
    }

    modMenu[1].items["Plate Holders"] = {
        img = "plate_holders",
        type = "submenu",
        items = addMod(vehicle, 25, true, modifyMenu.customization.plate_holders)
    }

    modMenu[1].items["Vanity Plates"] = {
        img = "vanity_plates",
        type = "submenu",
        items = addMod(vehicle, 26, true, modifyMenu.customization.vanity_plates)
    }

    -- modMenu[1].items["Headlights"] = {
    --     img = "headlights",
    --     type = "submenu",
    --     items = addMod(vehicle, 22, false, modifyMenu.customization.headlights)
    -- }

    if fbumper then
        modMenu[1].items["Front Bumper"] = {
            img = "front_bumper",
            type = "submenu",
            items = addMod(vehicle, 1, true, modifyMenu.customization.front_bumper)
        }
    end

    if rbumper then
        modMenu[1].items["Rear Bumper"] = {
            img = "rear_bumper",
            type = "submenu",
            items = addMod(vehicle, 2, true, modifyMenu.customization.rear_bumper)
        }
    end

    if chassis then
        modMenu[1].items["Arch Cover"] = {
            img = "arch_cover",
            type = "submenu",
            items = addMod(vehicle, 42, true, modifyMenu.customization.arch_cover)
        }

        modMenu[1].items["Aerials"] = {
            img = "aerials",
            type = "submenu",
            items = addMod(vehicle, 43, true, modifyMenu.customization.aerials)
        }

        modMenu[1].items["Trim"] = {
            img = "trim",
            type = "submenu",
            items = addMod(vehicle, 44, true, modifyMenu.customization.trim)
        }

        modMenu[1].items["Tank"] = {
            img = "tank",
            type = "submenu",
            items = addMod(vehicle, 45, true, modifyMenu.customization.tank)
        }

        modMenu[1].items["Windows"] = {
            img = "windows",
            type = "submenu",
            items = addMod(vehicle, 46, true, modifyMenu.customization.windows)
        }

        modMenu[1].items["Frame"] = {
            img = "frame",
            type = "submenu",
            items = addMod(vehicle, 5, true, modifyMenu.customization.frame)
        }
    end

    -- modMenu[2].items["Headlight Color"] = {
    --     img = "headlights",
    --     type = "submenu",
    --     items = addMod(vehicle, "headlight_color", true, modifyMenu.cosmetic.headlight_color)
    -- }
    modMenu[2].items["Livery"] = {
        img = "livery",
        type = "submenu",
        items = addMod(vehicle, 48, true, modifyMenu.cosmetic.livery)
    }
    -- modMenu[2].items["Neon"] = {
    --     img = "neon",
    --     type = "submenu",
    --     items = addMod(vehicle, "neon", true, modifyMenu.cosmetic.neon)
    -- }
    modMenu[2].items["Window Tint"] = {
        img = "window_tint",
        type = "submenu",
        items = addMod(vehicle, "window_tint", true, modifyMenu.cosmetic.window_tint)
    }
    modMenu[2].items["Tire Smoke"] = {
        img = "tire_smoke",
        type = "submenu",
        items = addMod(vehicle, "tire_smoke", true, modifyMenu.cosmetic.tire_smoke)
    }
    if interior then
        modMenu[2].items["Trim Design"] = {
            img = "interior",
            type = "submenu",
            items = addMod(vehicle, 27, true, modifyMenu.cosmetic.trim_design)
        }
        modMenu[2].items["Ornaments"] = {
            img = "ornaments",
            type = "submenu",
            items = addMod(vehicle, 28, true, modifyMenu.cosmetic.ornaments)
        }
        modMenu[2].items["Dashboard"] = {
            img = "dashboard",
            type = "submenu",
            items = addMod(vehicle, 29, true, modifyMenu.cosmetic.dashboard)
        }
        modMenu[2].items["Dial Design"] = {
            img = "dial",
            type = "submenu",
            items = addMod(vehicle, 30, true, modifyMenu.cosmetic.dial_design)
        }
        modMenu[2].items["Door Speaker"] = {
            img = "speaker",
            type = "submenu",
            items = addMod(vehicle, 31, true, modifyMenu.cosmetic.door_speaker)
        }
        modMenu[2].items["Seats"] = {
            img = "seats",
            type = "submenu",
            items = addMod(vehicle, 32, true, modifyMenu.cosmetic.seats)
        }
        modMenu[2].items["Steering Wheels"] = {
            img = "cosmetic",
            type = "submenu",
            items = addMod(vehicle, 33, true, modifyMenu.cosmetic.steering_wheels)
        }
        modMenu[2].items["Shifter leavers"] = {
            img = "shifter_leavers",
            type = "submenu",
            items = addMod(vehicle, 34, true, modifyMenu.cosmetic.shifter_leavers)
        }
        modMenu[2].items["Plaques"] = {
            img = "plaques",
            type = "submenu",
            items = addMod(vehicle, 35, true, modifyMenu.cosmetic.plaques)
        }
        modMenu[2].items["Speakers"] = {
            img = "speaker",
            type = "submenu",
            items = addMod(vehicle, 36, true, modifyMenu.cosmetic.speakers)
        }
        modMenu[2].items["Trunk"] = {
            img = "trunk",
            type = "submenu",
            items = addMod(vehicle, 37, true, modifyMenu.cosmetic.trunk)
        }
    end

    if isBike then
        modMenu[4].items["Front Wheels"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 6,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }  
        modMenu[4].items["Back Wheels"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 6,
            items = addMod(vehicle, 24, true, modifyMenu.cosmetic.wheels)
        }   
    else
        modMenu[4].items["Sports"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 0,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Muscle"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 1,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Lowrider"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 2,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["SUV"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 3,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Offroad"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 4,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Tuner"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 5,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["High End"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 7,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Benny's (1)"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 8,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Benny's (2)"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 9,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Open Wheel"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 10,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Street"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 11,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
        modMenu[4].items["Track"] = {
            img = "wheel",
            type = "submenu",
            wheelType = 12,
            items = addMod(vehicle, 23, true, modifyMenu.cosmetic.wheels)
        }
    end

    if not isBike and isIllegalMechanic then
        modMenu[7].items["Vehicle Traction"] = {
            img = "all_wheel",
            type = "submenu",
            items = addMod(vehicle, "vehicle_traction", true, modifyMenu.tuning.vehicle_traction)
        }
        -- modMenu[7].items["Tuner Chip"] = {
        --     img = "chip",
        --     type = "submenu",
        --     items = addMod(vehicle, "tuner_chip", true, modifyMenu.tuning.tuner_chip)
        -- }
        modMenu[7].items["Nitro"] = {
            img = "nitro",
            type = "submenu",
            items = addMod(vehicle, "nitro", true, modifyMenu.tuning.nitro)
        }
        modMenu[7].items["Exhausts"] = {
            img = "popcorn",
            type = "submenu",
            items = addMod(vehicle, "popcorn", true, modifyMenu.tuning.popcorn)
        }
    end

    return modMenu
end

-- Fitment
GetVehicleFitment = function(vehicle)
    local fitment = {}
    fitment.wheelsWidth = GetVehicleWheelWidth(vehicle)
    fitment.wheelsFrontLeft = GetVehicleWheelXOffset(vehicle, 0)
    fitment.wheelsFrontRight = GetVehicleWheelXOffset(vehicle, 1)
    fitment.wheelsRearLeft = GetVehicleWheelXOffset(vehicle, 2)
    fitment.wheelsRearRight = GetVehicleWheelXOffset(vehicle, 3)
    fitment.wheelsFrontCamberLeft = GetVehicleWheelYRotation(vehicle, 0)
    fitment.wheelsFrontCamberRight = GetVehicleWheelYRotation(vehicle, 1)
    fitment.wheelsRearCamberLeft = GetVehicleWheelYRotation(vehicle, 2)
    fitment.wheelsRearCamberRight = GetVehicleWheelYRotation(vehicle, 3)
    return fitment
end

RegisterNUICallback('getFitment', function(data, cb)
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    local fitment = GetVehicleFitment(vehicle)
    cb(fitment)
end)

RegisterNUICallback('changeFitment', function(data)
    local data = data.data
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    local wheelcambers = {
        wheelsFrontCamberLeft = 0,
        wheelsFrontCamberRight = 1,
        wheelsRearCamberLeft = 2,
        wheelsRearCamberRight = 3
    }
    local wheeloffsets = {
        wheelsFrontLeft = 0,
        wheelsFrontRight = 1,
        wheelsRearLeft = 2,
        wheelsRearRight = 3
    }

    for k, v in pairs(wheelcambers) do
        if data.type == k then
            if tonumber(data.value) == 1 then data.value = 0.99 elseif tonumber(data.value) == -1 then data.value = -0.99 end
            SetVehicleWheelYRotation(vehicle, v, tonumber(data.value))
        end
    end

    for k, v in pairs(wheeloffsets) do
        if data.type == k then
            if tonumber(data.value) == 1 then data.value = 0.99 elseif tonumber(data.value) == -1 then data.value = -0.99 end
            SetVehicleWheelXOffset(vehicle, v, tonumber(data.value))
        end
    end
end)

RegisterNUICallback('applyFitment', function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    local plate = GetVehicleNumberPlateText(vehicle)
    local data = {
        plate = plate,
        fitment = GetVehicleFitment(vehicle)
    }
    dusa.showNotification(Config.Translations[Config.Locale].fitment, 'success')
    TriggerServerEvent("dusa_mechanic:sv:syncFitment", NetworkGetNetworkIdFromEntity(vehicle), GetVehicleFitment(vehicle), plate)
    TriggerServerEvent("dusa_mechanic:sv:addElement", "fitment", data)
end)

RegisterNetEvent("dusa_mechanic:cl:syncFitment", function(vehicleId, fitmentData)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    local wheelcambers = {
        wheelsFrontCamberLeft = 0,
        wheelsFrontCamberRight = 1,
        wheelsRearCamberLeft = 2,
        wheelsRearCamberRight = 3
    }
    local wheeloffsets = {
        wheelsFrontLeft = 0,
        wheelsFrontRight = 1,
        wheelsRearLeft = 2,
        wheelsRearRight = 3
    }

    for a, b in pairs(fitmentData) do
        for k, v in pairs(wheelcambers) do
            if a == k then
                if tonumber(b) == 1 then b = 0.99 elseif tonumber(b) == -1 then b = -0.99 end
                SetVehicleWheelYRotation(vehicle, v, tonumber(b))
            end
        end

        for k, v in pairs(wheeloffsets) do
            if a == k then
                if tonumber(b) == 1 then b = 0.99 elseif tonumber(b) == -1 then b = -0.99 end
                SetVehicleWheelXOffset(vehicle, v, tonumber(b))
            end
        end
    end
end)

RegisterNetEvent("dusa_mechanic:cl:syncHeadlight", function(vehicleId, r, g, b)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    ToggleVehicleMod(vehicle, 22, true)
    SetVehicleXenonLightsCustomColor(vehicle, tonumber(r), tonumber(g), tonumber(b))
end)

-- Buy and ?preview? component
trim = function(value)
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

RegisterNUICallback('hoverModel', function(data)
    local data = data.data
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    SetVehicleModData(vehicle, data.modId, data.mod)
end)

RegisterNUICallback('removeHover', function(data)
    local data = data.data
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    
    setVehicleProperties(vehicle, currentProperties)

    local wheelcambers = {
        wheelsFrontCamberLeft = 0,
        wheelsFrontCamberRight = 1,
        wheelsRearCamberLeft = 2,
        wheelsRearCamberRight = 3
    }
    local wheeloffsets = {
        wheelsFrontLeft = 0,
        wheelsFrontRight = 1,
        wheelsRearLeft = 2,
        wheelsRearRight = 3
    }

    for a, b in pairs(currentFitment) do
        for k, v in pairs(wheelcambers) do
            if a == k then
                SetVehicleWheelYRotation(vehicle, v, tonumber(b))
            end
        end

        for k, v in pairs(wheeloffsets) do
            if a == k then
                SetVehicleWheelXOffset(vehicle, v, tonumber(b))
            end
        end        
    end
end)

RegisterNUICallback('checkMoney', function(data, cb) -- satın alım
    dusa.serverCallback('dusa_mechanic:cb:checkMoney', function(hasmoney)
        if hasmoney then
            cb({true, data.totalPrice})
        else
            cb(false)
        end
    end, data.totalPrice, data.type, tonumber(dusa.playerMechanic.m_id))
end)

RegisterNUICallback('checkBossMoney', function(data, cb) -- satın alım
    dusa.serverCallback('dusa_mechanic:cb:checkMoney', function(hasmoney)
        if hasmoney then
            cb(true)
        else
            cb(false)
        end
    end, data.amount, data.type)
end)

RegisterNUICallback('notEnoughMoney', function()
    dusa.showNotification(Config.Translations[Config.Locale].notenoughmoney, 'error')
end)

RegisterNUICallback('applyModify', function(data) -- satın alım
    local data = data.data
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local newProperties = getVehicleProperties(vehicle)
    local plate = trim(GetVehicleNumberPlateText(vehicle))
    local totalprice = 0
    if data.bought then
        if data.hasMoney then
            setVehicleProperties(vehicle, newProperties)
            if data.type == 'company' then
                TriggerServerEvent('dusa_mechanic:sv:removeMoney', data.totalPrice, data.type, tonumber(dusa.playerMechanic.m_id))
            else
                TriggerServerEvent('dusa_mechanic:sv:removeMoney', data.totalPrice, data.type)
            end
            TriggerServerEvent('dusa_mechanic:sv:saveModification', plate, newProperties)
            -- save to db
            dusa.showNotification(Config.Translations[Config.Locale].modified, 'success')
        else
            dusa.showNotification(Config.Translations[Config.Locale].notenoughmoney, 'error')
            setVehicleProperties(vehicle, firstProperties)
        end
    else
        setVehicleProperties(vehicle, firstProperties)
    end
    currentProperties = nil
    currentFitment = nil
    firstProperties = nil
end)

RegisterNUICallback('applyModifyTemporarily', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    currentProperties = getVehicleProperties(vehicle)
end)

function SetVehicleModData(vehicle, modType, data)
	SetVehicleModKit(vehicle, 0)
	SetVehicleAutoRepairDisabled(vehicle, false)
    local colorindex = 0
    local colortype = 0

	if (modType == 'plates') then
		SetVehicleNumberPlateTextIndex(vehicle, data)
	elseif (modType == 'color1') then
        local r, g, b = data:match("rgb%((%d+), (%d+), (%d+)%)")
        ClearVehicleCustomPrimaryColour(vehicle)
		SetVehicleCustomPrimaryColour(vehicle, tonumber(r), tonumber(g), tonumber(b))
	elseif (modType == 'color2') then
        local r, g, b = data:match("rgb%((%d+), (%d+), (%d+)%)")
        ClearVehicleCustomSecondaryColour(vehicle)
		SetVehicleCustomSecondaryColour(vehicle, tonumber(r), tonumber(g), tonumber(b))
	elseif (modType == 'paintType1') then
        ClearVehicleCustomPrimaryColour(vehicle)
        if data.type == 'Pearlescent' then local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle) SetVehicleModColor_1(vehicle, colortype, colorindex) SetVehicleExtraColours(vehicle, 74, wheelColor) return end
        if data.type == 'Classic' then colortype = 0 colorindex = 0 end
        if data.type == 'Metallic' then colortype = 1 colorindex = 0 end
        if data.type == 'Matte' then colortype = 3 colorindex = 12 end
        if data.type == 'Metal' then colortype = 4 colorindex = 0 end
        if data.type == 'Chrome' then colortype = 5 colorindex = 0 end
        SetVehicleModColor_1(vehicle, colortype, colorindex)
	elseif (modType == 'paintType2') then
        if data.type == 'Pearlescent' then local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle) SetVehicleModColor_2(vehicle, colortype, colorindex) SetVehicleExtraColours(vehicle, 74, wheelColor) return end
        if data.type == 'Classic' then colortype = 0 colorindex = 0 end
        if data.type == 'Metallic' then colortype = 1 colorindex = 0 end
        if data.type == 'Matte' then colortype = 3 colorindex = 12 end
        if data.type == 'Metal' then colortype = 4 colorindex = 0 end
        if data.type == 'Chrome' then colortype = 5 colorindex = 0 end
        SetVehicleModColor_2(vehicle, colortype, colorindex)
	elseif (modType == 'pearlescentColor') then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, tonumber(data), wheelColor)
	elseif (modType == 'wheelColor') then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, pearlescentColor, tonumber(data))
	elseif (modType == 'wheels') then
		SetVehicleMod(vehicle, 23, -1, false)
		SetVehicleWheelType(vehicle, tonumber(data))
	elseif (modType == 'window_tint') then
		SetVehicleWindowTint(vehicle, tonumber(data))
	elseif (modType == 'extras') then
		local tempList = {}
		for id = 0, 25, 1 do
			if (DoesExtraExist(vehicle, id)) then
				table.insert(tempList, id)
			end
		end
		
		if (DoesExtraExist(vehicle, tempList[data.id])) then
			SetVehicleExtra(vehicle, tempList[data.id], data.enable)
		end
	elseif (modType == 'neonColor') then
		SetVehicleNeonLightEnabled(vehicle, 0, true)
		SetVehicleNeonLightEnabled(vehicle, 1, true)
		SetVehicleNeonLightEnabled(vehicle, 2, true)
		SetVehicleNeonLightEnabled(vehicle, 3, true)
		
		SetVehicleNeonLightsColour(vehicle, tonumber(data[1]), tonumber(data[2]), tonumber(data[3]))
	elseif (modType == 'tire_smoke') then
		ToggleVehicleMod(vehicle, 20, true)
		SetVehicleTyreSmokeColor(vehicle, tonumber(data[1]), tonumber(data[2]), tonumber(data[3]))
	elseif (modType == 'modXenon') then
		ToggleVehicleMod(vehicle, 22, true)

		if (true) then
			SetVehicleXenonLightsColour(vehicle, tonumber(data))
		end
	elseif (modType == 'livery') then
		SetVehicleLivery(vehicle, data)
	elseif (type(modType) == 'number' and (modType == 23 or modType == 24)) then
		SetVehicleMod(vehicle, 23, data, false)

		if (IsThisModelABike(GetEntityModel(vehicle))) then
			SetVehicleMod(vehicle, 24, data, false)
		end
	elseif (type(modType) == 'number' and modType >= 17 and modType <= 22) then -- TOGGLE
		ToggleVehicleMod(vehicle, modType, data + 1)
	elseif (type(modType) == 'number') then -- MOD
		SetVehicleMod(vehicle, modType, data, false)
	end
    -- currentProperties = getVehicleProperties(vehicle)
	-- local props = ESX.Game.GetVehicleProperties(vehicle)
	-- TriggerServerEvent('saveVehicle', props.plate, props)
end

-- camera for preview
local rotatedCam = nil
local oldPartId = nil
local freecam = false
local partData = {
    ["main"] = {
        offset = vector3(-4.5, 4.5, 1.0),
        rotation = vector3(0.0, 0.0, 230.0),
    },
    ["rear bumper"] = {
        offset = vector3(1.0, -4.0, 0.0),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["front bumper"] = {
        offset = vector3(-1.0, 4.0, 0.0),
        rotation = vector3(0.0, 0.0, 210.0),
    },
    ["spoiler"] = {
        offset = vector3(1.5, -4.5, 0.9),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["exhausts"] = {
        offset = vector3(1.0, -3.5, 0.0),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["skirts"] = {
        offset = vector3(2.5, 1.0, 0.0),
        rotation = vector3(0.0, 0.0, 110.0),
    },
    ["suspension"] = {
        offset = vector3(2.0, -3.0, 0.0),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["brakes"] = {
        offset = vector3(-2.0, 2.5, 0.0),
        rotation = vector3(0.0, 0.0, 230.0),
    },
    ["engine"] = {
        offset = vector3(-1.5, 4.0, 1.0),
        rotation = vector3(0.0, 0.0, 210.0),
        doorId = 4,
    },
    ["hood"] = {
        offset = vector3(0.0, 4.5, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["turbo"] = {
        offset = vector3(-1.5, 3.5, 1.0),
        rotation = vector3(-10.0, 0.0, 210.0),
        doorId = 4,
    },
    ["horn"] = {
        offset = vector3(-1.5, 3.5, 1.0),
        rotation = vector3(-10.0, 0.0, 210.0),
        doorId = 4,
    },
    ["transmission"] = {
        offset = vector3(-1.5, 3.5, 0.5),
        rotation = vector3(-10.0, 0.0, 210.0),
        doorId = 4,
    },
    ["headlights"] = {
        offset = vector3(1.0, 3.5, 0.3),
        rotation = vector3(0.0, 0.0, 160.0),
    },
    ["headlight color"] = {
        offset = vector3(1.0, 3.5, 0.3),
        rotation = vector3(0.0, 0.0, 160.0),
    },
    ["wheels"] = {
        offset = vector3(2.0, 3.0, 0.0),
        rotation = vector3(0.0, 0.0, 140.0),
    },
    ["aerials"] = {
        offset = vector3(0.0, 4.5, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["air filters"] = {
        offset = vector3(0.0, 3.0, 1.0),
        rotation = vector3(-30.0, 0.0, 180.0),
        doorId = 4,
    },
    ["arch cover"] = {
        offset = vector3(0.0, 3.5, 0.3),
        rotation = vector3(0.0, 0.0, 180.0),
    },
    ["engine block"] = {
        offset = vector3(0.0, 3.0, 1.0),
        rotation = vector3(-30.0, 0.0, 180.0),
        doorId = 4,
    },
    ["fenders"] = {
        offset = vector3(4.5, 0.0, 0.5),
        rotation = vector3(0.0, 0.0, 90.0),
    },
    ["frame"] = {
        offset = vector3(0.0, 5.0, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["grille"] = {
        offset = vector3(0.0, 4.0, 0.3),
        rotation = vector3(0.0, 0.0, 180.0),
    },
    ["license"] = {
        offset = vector3(1.0, -4.0, 0.5),
        rotation = vector3(-10.0, 0.0, 30.0),
    },
    ["plate holders"] = {
        offset = vector3(0.0, 4.0, 0.3),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["roof"] = {
        offset = vector3(0.0, 2.5, 1.75),
        rotation = vector3(-20.0, 0.0, 180.0),
    },
    ["struts"] = {
        offset = vector3(0.0, 3.0, 1.0),
        rotation = vector3(-30.0, 0.0, 180.0),
        doorId = 4,
    },
    ["tank"] = {
        offset = vector3(0.0, 3.5, 0.0),
        rotation = vector3(0.0, 0.0, 180.0),
    },
    ["trim"] = {
        offset = vector3(0.0, 2.5, 1.75),
        rotation = vector3(-20.0, 0.0, 180.0),
    },
    ["vanity plates"] = {
        offset = vector3(0.0, 3.5, 0.0),
        rotation = vector3(0.0, 0.0, 180.0),
    },
    ["windows"] = {
        offset = vector3(2.0, 0.0, 1.0),
        rotation = vector3(-20.0, 0.0, 90.0),
    },
    ["nitro"] = {
        offset = vector3(1.0, -3.5, 0.0),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["vehicle traction"] = {
        offset = vector3(2.5, 1.0, 0.0),
        rotation = vector3(0.0, 0.0, 110.0),
    },
    ["tuner chip"] = {
        offset = vector3(-1.5, 4.0, 1.0),
        rotation = vector3(0.0, 0.0, 210.0),
        doorId = 4,
    },
    ["dashboard"] = {
        offset = vector3(0.0, -0.2, 0.5),
        rotation = vector3(-10.0, 0.0, 0.0),
    },
    ["dial design"] = {
        offset = vector3(0.0, -0.2, 0.5),
        rotation = vector3(-10.0, 0.0, 0.0),
    },
    ["trim design"] = {
        offset = vector3(0.0, 5.0, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["ornaments"] = {
        offset = vector3(0.0, -0.2, 0.5),
        rotation = vector3(-10.0, 0.0, 0.0),
    },
    ["steering wheels"] = {
        offset = vector3(-0.2, -0.2, 0.5),
        rotation = vector3(-10.0, 0.0, 0.0),
    },
    ["shifter leavers"] = {
        offset = vector3(0.0, -0.2, 0.5),
        rotation = vector3(-10.0, 0.0, 0.0),
    },
    ["seats"] = {
        offset = vector3(0.0, 5.0, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["interior"] = {
        offset = vector3(0.0, 5.0, 1.0),
        rotation = vector3(-10.0, 0.0, 180.0),
    },
    ["plaques"] = {
        offset = vector3(1.5, -4.5, 0.9),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["speakers"] = {
        offset = vector3(1.5, -4.5, 0.9),
        rotation = vector3(0.0, 0.0, 30.0),
    },
    ["trunk"] = {
        offset = vector3(1.5, -4.5, 0.9),
        rotation = vector3(0.0, 0.0, 30.0),
        doorId = 5,
    },
    ["door speaker"] = {
        offset = vector3(-1.2, -1.0, 0.3),
        rotation = vector3(0.0, 0.0, 0.0),
        doorId = 0,
    },
    ["window tint"] = {
        offset = vector3(2.0, 0.0, 1.0),
        rotation = vector3(-20.0, 0.0, 90.0),
    },
    ["tire smoke"] = {
        offset = vector3(1.0, -3.5, 0.0),
        rotation = vector3(0.0, 0.0, 30.0),
    },
}

RegisterNUICallback('freeCam', function(data)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId(), false)
    -- if data.data then dusa.showNotification(Config.Translations[Config.Locale].freecamactive, 'success') end
    SendNUIMessage({action = 'hideUI', boolean = false, translate = Config.Translations[Config.Locale]})
    unregisterAllCams();
    SetNuiFocus(false, false)
    if data.data.bool then
        CreateThread(function()
            while true do
                if IsControlJustPressed(0, 61) then
                    -- dusa.showNotification(Config.Translations[Config.Locale].freecamdeactive, 'error')
                    SetNuiFocus(true, true)
                    freecam = false
                    SendNUIMessage({action = 'hideUI', boolean = true, translate = Config.Translations[Config.Locale]})
                    if not data.data.isFitment then
                        rotateCam("main")
                    end
                    break;
                end
                Wait(1)
            end
        end)
    end
end)

unregisterCam = function(partId)
    if not partData[partId] then
        return
    end

    if not DoesCamExist(partData[partId].camera) then
        return
    end

    DestroyCam(partData[partId].camera)
    partData[partId].camera = nil
end

registerCam = function(playerVehicle, partId)
    if not playerVehicle then
        return
    end

    if not partData[partId] then
        return
    end

    local data = partData[partId]

    if DoesCamExist(data.camera) then
        return
    end

    local partCoords = GetOffsetFromEntityInWorldCoords(playerVehicle, data.offset)
    local partRotation = GetEntityRotation(playerVehicle) + data.rotation
    data.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamCoord(data.camera, partCoords)
    SetCamRot(data.camera, partRotation)
    SetCamFov(data.camera, 50.0)
end

unregisterAllCams = function()
    for k,v in pairs(partData) do
        if DoesCamExist(v.camera) then
            SetCamActive(v.camera, false)
            DestroyCam(v.camera)
        end
    end
    RenderScriptCams(false, false, 500, false, false)
    DestroyAllCams()
end

rotateCam = function(partId)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId(), false)
    if not partData[partId] then
        return
    end

    -- if partId ~= "main" then
    --     unregisterCam(oldPartId)
    --     oldPartId = partId
    -- end

    registerCam(vehicle, "main")
    registerCam(vehicle, partId)

    DisableCamCollisionForEntity(vehicle)


    local data = partData[partId]

    if data.doorId then
		if GetVehicleDoorAngleRatio(vehicle, data.doorId) > 0.0 then
            if IsVehicleDoorFullyOpen(vehicle, data.doorId) then
			    SetVehicleDoorShut(vehicle, data.doorId, false)
            end
		else
            if not IsVehicleDoorFullyOpen(vehicle, data.doorId) then
			    SetVehicleDoorOpen(vehicle, data.doorId, false)
            end
		end
    end

    if partId == "main" then
        for i = 0, 5 do
            if GetVehicleDoorAngleRatio(vehicle, i) > 0.0 then
                SetVehicleDoorShut(vehicle, i, false)
            end
        end
    end

    if DoesCamExist(rotatedCam) and data.camera ~= rotatedCam then
        SetCamActiveWithInterp(data.camera, rotatedCam, 1500, 1, 1)
        SetCamActive(data.camera, true)
    end
    
    rotatedCam = data.camera
    SetCamActive(rotatedCam, true)
    RenderScriptCams(true, true, 500, true, true)
end

RegisterNUICallback("disableCamera", function(data, cbj)
    for k,v in pairs(partData) do
        if DoesCamExist(v.camera) then
            SetCamActive(v.camera, false)
            DestroyCam(v.camera)
        end
    end
    RenderScriptCams(false, false, 500, false, false)
    DestroyAllCams()
    cbj("ok")
end)

RegisterNUICallback("rotateCamera", function(data, cbj)
    local data = data.data
    if data.objectId == 3 then
        data.component = "wheels"
    end

    if not data.component and data.menu == "menu" or data.menu == "submenu" then
        rotateCam("main")
        return cbj("ok")
    end

    if data.component then
        rotateCam(string.lower(data.component))
        return cbj("ok")
    end

    cbj("ok")
end)

-- Vehicle old data
getVehicleProperties = function(vehicle)
	if DoesEntityExist(vehicle) then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        if GetIsVehiclePrimaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            colorPrimary = {r, g, b}
        end

        if GetIsVehicleSecondaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
            colorSecondary = {r, g, b}
        end

        local extras = {}
        for extraId = 0, 12 do
            if DoesExtraExist(vehicle, extraId) then
                local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                extras[tostring(extraId)] = state
            end
        end

        local modLivery = GetVehicleMod(vehicle, 48)
        if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= 0 then
            modLivery = GetVehicleLivery(vehicle)
        end

        return {
            model = GetEntityModel(vehicle),
            plate = string.gsub(GetVehicleNumberPlateText(vehicle), "^%s*(.-)%s*$", "%1"),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            dirtLevel = Round(GetVehicleDirtLevel(vehicle), 0.1),
            oilLevel = Round(GetVehicleOilLevel(vehicle), 0.1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            dashboardColor = GetVehicleDashboardColour(vehicle),
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            wheelSize = GetVehicleWheelSize(vehicle),
            wheelWidth = GetVehicleWheelWidth(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            xenonColor = GetVehicleXenonLightsColour(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            headlightColor = GetVehicleHeadlightsColour(vehicle),
            interiorColor = GetVehicleInteriorColour(vehicle),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modKit17 = GetVehicleMod(vehicle, 17),
            modTurbo = IsToggleModOn(vehicle, 18),
            modKit19 = GetVehicleMod(vehicle, 19),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modKit21 = GetVehicleMod(vehicle, 21),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modCustomTiresF = GetVehicleModVariation(vehicle, 23),
            modCustomTiresR = GetVehicleModVariation(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modKit47 = GetVehicleMod(vehicle, 47),
            modLivery = modLivery,
            modKit49 = GetVehicleMod(vehicle, 49),
            liveryRoof = GetVehicleRoofLivery(vehicle),
        }
	else
		return
	end
end

setVehicleProperties = function(vehicle, props)
	if DoesEntityExist(vehicle) and props then
        if props.extras then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        SetVehicleModKit(vehicle, 0)
        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
        if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
        if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
        if props.oilLevel then
            SetVehicleOilLevel(vehicle, props.oilLevel)
        end
        if props.color1 then
            if type(props.color1) == "number" then
                ClearVehicleCustomPrimaryColour(vehicle)
                SetVehicleColours(vehicle, props.color1, colorSecondary)
            else
                SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
            end
        end
        if props.color2 then
            if type(props.color2) == "number" then
                ClearVehicleCustomSecondaryColour(vehicle)
                SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
            else
                SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
            end
        end
        if props.pearlescentColor then
            if type(props.pearlescentColor) == "number" then
                wheelColor = GetVehicleExtraColours(vehicle) 
                SetVehicleModColor_1(vehicle, 0, props.pearlescentColor) 
                SetVehicleExtraColours(vehicle, 74, wheelColor)
            end
        end
        if props.pearlescentColor then
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end
        if props.interiorColor then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
        if props.dashboardColor then
            SetVehicleDashboardColour(vehicle, props.dashboardColor)
        end
        if props.wheelColor then
            SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
        end
        if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end
        if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
        if props.windowStatus then
            for windowIndex, smashWindow in pairs(props.windowStatus) do
                if not smashWindow then SmashVehicleWindow(vehicle, windowIndex) end
            end
        end
        if props.doorStatus then
            for doorIndex, breakDoor in pairs(props.doorStatus) do
                if breakDoor then
                    SetVehicleDoorBroken(vehicle, tonumber(doorIndex), true)
                end
            end
        end
        if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
        if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
        if props.headlightColor then
            SetVehicleHeadlightsColour(vehicle, props.headlightColor)
        end
        if props.interiorColor then
            SetVehicleInteriorColour(vehicle, props.interiorColor)
        end
        if props.wheelSize then
            SetVehicleWheelSize(vehicle, props.wheelSize)
        end
        if props.wheelWidth then
            SetVehicleWheelWidth(vehicle, props.wheelWidth)
        end
        if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
        if props.modSpoilers then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end
        if props.modFrontBumper then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end
        if props.modRearBumper then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end
        if props.modSideSkirt then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end
        if props.modExhaust then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end
        if props.modFrame then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end
        if props.modGrille then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end
        if props.modHood then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end
        if props.modFender then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end
        if props.modRightFender then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end
        if props.modRoof then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end
        if props.modEngine then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        if props.modBrakes then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        if props.modTransmission then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        if props.modHorns then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end
        if props.modSuspension then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        if props.modArmor then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
        if props.modKit17 then
            SetVehicleMod(vehicle, 17, props.modKit17, false)
        end
        if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        if props.modKit19 then
            SetVehicleMod(vehicle, 19, props.modKit19, false)
        end
        if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
        end
        if props.modKit21 then
            SetVehicleMod(vehicle, 21, props.modKit21, false)
        end
        if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
        if props.xenonColor then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
        if props.modFrontWheels then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
        end
        if props.modBackWheels then
            SetVehicleMod(vehicle, 24, props.modBackWheels, false)
        end
        if props.modCustomTiresF then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
        end
        if props.modCustomTiresR then
            SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
        end
        if props.modPlateHolder then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end
        if props.modVanityPlate then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end
        if props.modTrimA then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end
        if props.modOrnaments then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end
        if props.modDashboard then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end
        if props.modDial then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end
        if props.modDoorSpeaker then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end
        if props.modSeats then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end
        if props.modSteeringWheel then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end
        if props.modShifterLeavers then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end
        if props.modAPlate then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end
        if props.modSpeakers then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end
        if props.modTrunk then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end
        if props.modHydrolic then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end
        if props.modEngineBlock then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end
        if props.modAirFilter then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end
        if props.modStruts then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end
        if props.modArchCover then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end
        if props.modAerials then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end
        if props.modTrimB then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end
        if props.modTank then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end
        if props.modWindows then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end
        if props.modKit47 then
            SetVehicleMod(vehicle, 47, props.modKit47, false)
        end
        if props.modLivery then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
        if props.modKit49 then
            SetVehicleMod(vehicle, 49, props.modKit49, false)
        end
        if props.liveryRoof then
            SetVehicleRoofLivery(vehicle, props.liveryRoof)
        end
	end
end
-- Status
function VehicleStatus()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId(), false)
    local vehicleModel = GetEntityModel(vehicle)

    local spP = 7
    local brP = 1.5
    local epP = 6
    local acP = 5

    local vehDisplayName = GetDisplayNameFromVehicleModel(vehicleModel)
    local vehicleLabelText = GetLabelText(vehDisplayName)
    local vehicleName = vehicleLabelText == 'NULL' and vehDisplayName or vehicleLabelText
    
    local acceleration = (GetVehicleModelAcceleration(vehicleModel) or 0.0) * 10
    local maxSpeed = (GetVehicleModelEstimatedMaxSpeed(vehicleModel) or 0.0) / 10
    local breaks = GetVehicleModelMaxBraking(vehicleModel) or 0.0
    local power = (acceleration + maxSpeed) / 2
    local carmodel 
    local status = {
        [1] = {
            label = "Acceleration",
            value = acceleration * 20
        },
        [2] = {
            label = "Max Speed",
            value = maxSpeed * 15
        },
        [3] = {
            label = "Brakes",
            value = breaks * 60
        },
        [4] = {
            label = "Engine Power",
            value = power * 15
        },
        [5] = {
            name = vehicleName
        }
    }
    return status
end

RegisterNetEvent('dusa_mechanic:cl:getRanks', function(ranks)
    ranks = ranks
end)

RegisterNetEvent('dusa_mechanic:cl:updateRanks', function(ranks)
    ranks = ranks
    dusa.showNotification(Config.Translations[Config.Locale].ranksupdated, 'success')
    dusa.playerMechanic.ranks = ranks
end)

RegisterNetEvent('dusa_mechanic:cl:syncRank', function(ranks)
    if dusa.playerMechanic then
        dusa.playerMechanic.ranks = ranks
    end
end)

RegisterNUICallback('applyRanks', function(data)
    local data = data.data
    TriggerServerEvent('dusa_mechanic:sv:updateRank', dusa.playerMechanic.m_id, data)
end)

function HideMap(bool)
    while true do
        if bool then
            HideHudComponentThisFrame(1)
            HideHudComponentThisFrame(2)
            HideHudComponentThisFrame(3)
            HideHudComponentThisFrame(4)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(13)
            HideHudComponentThisFrame(17)
            HideHudComponentThisFrame(20)
        else
            break
        end
        Wait(0)
    end
end

function CheckPlayerMechanic()
    for i = 1, #Config.Mechanics, 1 do
        if Config.Mechanics[i].job == dusa.playerData.job.name then
            local playername = GetPlayerName(PlayerId())
            local rank = dusa.playerData.job.grade
            if dusa.framework == 'qb' then rank = dusa.playerData.job.grade.level playername = dusa.playerData.charinfo.firstname.." "..dusa.playerData.charinfo.lastname end
            if dusa.framework == 'qb' then dusa.playerData.identifier = dusa.playerData.citizenid playername = dusa.playerData.charinfo.firstname.." "..dusa.playerData.charinfo.lastname end
            TriggerServerEvent('dusa_mechanic:sv:updatePlayerRank', rank, i)
            TriggerServerEvent('dusa_mechanic:sv:addAutoJobPlayers', {identifier = dusa.playerData.identifier, name = playername, img = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmf3Op_-7qH0BvsTgAT7v8cyR-iBq6QUIYoEs-e1FWoHRllGWC7itgsi6MJ3cZMWU3stc&usqp=CAU",  rank = rank}, i, PlayerId(), playername)
        end
    end
end

RegisterNetEvent('dusa_mechanic:cl:updatePlayerRank', function(rank, id, job)
    if dusa.playerData.job.name == job then
        TriggerServerEvent('dusa_mechanic:sv:updatePlayerRank', rank, id)
    end
end)

RegisterNetEvent('dusa_mechanic:cl:updateEmployees', function(employees, job)
    if dusa.playerData.job.name == job then
        dusa.playerMechanic.employees = employees
    end
end)

RegisterNetEvent('dusa_mechanic:cl:updateVault', function(vault, job)
    if dusa.playerData.job.name == job then
        dusa.playerMechanic.mechanic = json.decode(dusa.playerMechanic.mechanic)
        dusa.playerMechanic.mechanic.vault = vault
        dusa.playerMechanic.mechanic = json.encode(dusa.playerMechanic.mechanic)
    end
end)

RegisterNetEvent('dusa_mechanic:cl:updateFee', function(fee, job)
    if dusa.playerData.job.name == job then
        dusa.playerMechanic.mechanic = json.decode(dusa.playerMechanic.mechanic)
        dusa.playerMechanic.mechanic.fee = fee
        dusa.playerMechanic.mechanic = json.encode(dusa.playerMechanic.mechanic)
    end
end)

RegisterNetEvent('dusa_mechanic:cl:updateDiscount', function(discount, job)
    if dusa.playerData.job.name == job then
        dusa.playerMechanic.mechanic = json.decode(dusa.playerMechanic.mechanic)
        dusa.playerMechanic.mechanic.discount = discount
        dusa.playerMechanic.mechanic = json.encode(dusa.playerMechanic.mechanic)
    end
end)

RegisterNetEvent('dusa_mechanic:cl:updateName', function(name, job)
    if dusa.playerData.job.name == job then
        dusa.playerMechanic.mechanic = json.decode(dusa.playerMechanic.mechanic)
        dusa.playerMechanic.mechanic.name = name
        dusa.playerMechanic.mechanic = json.encode(dusa.playerMechanic.mechanic)
    end
end)

RegisterNetEvent("dusa_mechanic:cl:updateVehData", function(obj)
    vehData = obj
end)

RegisterNetEvent("dusa_mechanic:cl:getVehData", function(obj)
    vehData = obj
end)

exports('ApplyTunes', function(plate)
    TriggerServerEvent('dusa_mechanic:sv:getVehData', plate)
end)

local nitroBoosted = false

Citizen.CreateThread(function()
    while true do
        local sleep = 750
        local playerPed = PlayerPedId()
        if next(vehData) then
            if IsPedInAnyVehicle(playerPed) and not menuOpened then
                local pVehicle = GetVehiclePedIsUsing(playerPed)
                local vehPlate = trim(GetVehicleNumberPlateText(pVehicle))
                tuning[vehPlate] = {}
                if vehData[vehPlate] then
                    if vehData[vehPlate].nitro then
                        sleep = 1
                        if IsControlJustPressed(0, Config.Settings.nitro.keyCode) and not nitroBoosted then
                            if tonumber(vehData[vehPlate]['nitro'].remaining) > 0 then
                                nitroBoosted = true
                                useNitro(pVehicle)
                                vehData[vehPlate]['nitro'].remaining = vehData[vehPlate]['nitro'].remaining - 1
                                dusa.showNotification(Config.Translations[Config.Locale].usednitro .. vehData[vehPlate]['nitro'].remaining, 'success')
                            else
                                dusa.showNotification(Config.Translations[Config.Locale].outofnitro, 'error')
                                vehData[vehPlate].nitro = false
                                sleep = 750
                            end
                        end
                    end
                    if vehData[vehPlate].fitment then
                        sleep = 1000
                        if not menuOpened then
                            local wheelcambers = {
                                wheelsFrontCamberLeft = 0,
                                wheelsFrontCamberRight = 1,
                                wheelsRearCamberLeft = 2,
                                wheelsRearCamberRight = 3
                            }
                            local wheeloffsets = {
                                wheelsFrontLeft = 0,
                                wheelsFrontRight = 1,
                                wheelsRearLeft = 2,
                                wheelsRearRight = 3
                            }
                            if type(vehData[vehPlate].fitment) == 'string' then vehData[vehPlate].fitment = json.decode(vehData[vehPlate].fitment) end
                            for a, b in pairs(vehData[vehPlate].fitment) do
                                for k, v in pairs(wheelcambers) do
                                    if a == k then
                                        SetVehicleWheelYRotation(pVehicle, v, tonumber(b))
                                    end
                                end
                        
                                for k, v in pairs(wheeloffsets) do
                                    if a == k then
                                        SetVehicleWheelXOffset(pVehicle, v, tonumber(b))
                                    end
                                end
                            end
                        end
                    end
                    if vehData[vehPlate].tuning then
                        sleep = 1 * 30000
                        local data = vehData[vehPlate].tuning
                        if type(data) == 'string' then data = json.decode(data) end
                        for k, v in pairs(data) do
                            tuning[vehPlate][k] = v
                        end
                        SwitchMode(pVehicle, tuning[vehPlate].vehiclemode)
                        SetTuning(pVehicle, tuning[vehPlate])
                        ToggleNeons()
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

addEffect = function(pVehicle, bone)
    UseParticleFxAssetNextCall('core')
    local ptfx = StartParticleFxLoopedOnEntityBone('veh_light_red_trail', pVehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bone, 1.0, false, false, false)
    SetParticleFxLoopedEvolution(ptfx, "speed", 1.0, false)
    return ptfx
end

RegisterNetEvent("dusa_mechanic:client:useNitro", function(vehicleId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    local ptfx01 = addEffect(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"))
    local ptfx02 = addEffect(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"))
    Citizen.CreateThread(function()
        local remainingTime = GetGameTimer() + Config.Settings.nitro.time   
        while remainingTime > GetGameTimer() do 
            Citizen.Wait(750)
        end
        StopParticleFxLooped(ptfx01)
        StopParticleFxLooped(ptfx02)
    end)
end)

useNitro = function(pVehicle)
    SetVehicleBoostActive(pVehicle, 1, 0)
    TriggerServerEvent("dusa_mechanic:server:useNitro", NetworkGetNetworkIdFromEntity(pVehicle))
    SetFlash(0, 0, 100, 3000, 100)
    StartScreenEffect("Heist4CameraFlash", 3000, false)
    Citizen.CreateThread(function()
        local remainingTime = GetGameTimer() + Config.Settings.nitro.time   
        while remainingTime > GetGameTimer() do 
            SetVehicleForwardSpeed(pVehicle, (GetEntitySpeed(PlayerPedId()) * Config.Settings.nitro.multiplier))
            SetVehicleTurboPressure(pVehicle, 100.0)
            Citizen.Wait(750)
        end
        SetVehicleBoostActive(pVehicle, 0, 0)
    end)

    Citizen.SetTimeout(Config.Settings.nitro.cooldown, function()
        nitroBoosted = false
    end)
end

-- STANCER
-- local vehiclesinarea = {}
-- AddStateBagChangeHandler('stancer' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
-- 	Wait(0)
-- 	-- if not value or not value['wheelsetting'] then return end
--     local vehicle = GetEntityFromStateBagName(bagName)
-- 	if not DoesEntityExist(vehicle) then return end
-- 	local plate = GetVehicleNumberPlateText(vehicle)
--     print(bagName, key, value)
--     Stancers[plate] = vehicle
--     if key == 'stancer' then vehData[plate].fitment = value end
--     -- if not menuOpened then
--     --     local wheelcambers = {
--     --         wheelsFrontCamberLeft = 0,
--     --         wheelsFrontCamberRight = 1,
--     --         wheelsRearCamberLeft = 2,
--     --         wheelsRearCamberRight = 3
--     --     }
--     --     local wheeloffsets = {
--     --         wheelsFrontLeft = 0,
--     --         wheelsFrontRight = 1,
--     --         wheelsRearLeft = 2,
--     --         wheelsRearRight = 3
--     --     }
--     --     print(type(vehData[plate].fitment), vehData[plate].fitment)
--     --     if type(vehData[plate].fitment) == 'string' then vehData[plate].fitment = json.decode(vehData[plate].fitment) end
--     --     for a, b in pairs(vehData[plate].fitment) do
--     --         for k, v in pairs(wheelcambers) do
--     --             if a == k then
--     --                 SetVehicleWheelYRotation(pVehicle, v, tonumber(b))
--     --             end
--     --         end
    
--     --         for k, v in pairs(wheeloffsets) do
--     --             if a == k then
--     --                 SetVehicleWheelXOffset(pVehicle, v, tonumber(b))
--     --             end
--     --         end
--     --     end
--     -- end

-- 	-- Stancers[plate] = vehicle
-- 	SetVehicleSuspensionHeight(vehicle,value.height)
-- 	SetStanceSetting(vehicle,value['wheelsetting'])
-- 	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberFront', value['wheelsetting']['wheelrotationfront']['0'])
-- 	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberRear', value['wheelsetting']['wheelrotationrear']['2'])
-- 	SetVehicleWheelWidth(vehicle,tonumber(value['wheelsetting']['wheelwidth']))
-- 	SetVehicleWheelSize(vehicle,tonumber(value['wheelsetting']['wheelsize']))
-- 	--SetReduceDriftVehicleSuspension(vehicle,true)
-- 	--SetVehicleHandlingField(vehicle, 'CCarHandlingData', 'strAdvancedFlags', 0x8000+0x4000000)
-- 	if vehiclesinarea[plate] == nil then vehiclesinarea[plate] = {} vehiclesinarea[plate]['plate'] = plate end
-- 	vehiclesinarea[plate]['wheelsetting'] = value['wheelsetting']
-- 	vehiclesinarea[plate]['speed'] = GetEntitySpeed(vehicle)
-- 	vehiclesinarea[plate]['entity'] = vehicle
-- 	vehiclesinarea[plate]['dist'] = #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId()))
-- 	vehiclesinarea[plate]['wheeledit'] = value.wheeledit
-- 	for k,v in pairs(vehiclesinarea) do
-- 		table.insert(cachedata,v)
-- 	end
-- 	cache = cachedata
-- end)