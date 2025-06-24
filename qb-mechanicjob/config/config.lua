Config = {}
Config.RequireJob = false                       -- do you need a mech job to use parts?
Config.FuelResource = 'LegacyFuel'             -- supports any that has a GetFuel() and SetFuel() export

Config.PaintTime = 5                           -- how long it takes to paint a vehicle in seconds
Config.ColorFavorites = false                  -- add your own colors to the favorites menu (see bottom of const.lua)

Config.NitrousBoost = 1.8                      -- how much boost nitrous gives (want this above 1.0)
Config.NitrousUsage = 0.1                      -- how much nitrous is used per frame while holding key

Config.UseDistance = true                      -- enable/disable saving vehicle distance
Config.UseDistanceDamage = true                -- damage vehicle engine health based on vehicle distance
Config.UseWearableParts = true                 -- enable/disable wearable parts
Config.WearablePartsChance = 1                 -- chance of wearable parts being damaged while driving if enabled
Config.WearablePartsDamage = math.random(1, 2) -- how much wearable parts are damaged when damaged if enabled
Config.DamageThreshold = 25                    -- how worn a part needs to be or below to apply an effect if enabled
Config.WarningThreshold = 50                   -- how worn a part needs to be to show a warning color in toolbox if enabled

Config.MinimalMetersForDamage = {              -- unused if Config.UseDistanceDamage is false
    { min = 5000,  max = 10000, damage = 10 },
    { min = 15000, max = 20000, damage = 20 },
    { min = 25000, max = 30000, damage = 30 },
}

Config.WearableParts = { -- unused if Config.UseWearableParts is false (feel free to add/remove parts)
    radiator = { label = Lang:t('menu.radiator_repair'), maxValue = 100, repair = { steel = 2 } },
    axle = { label = Lang:t('menu.axle_repair'), maxValue = 100, repair = { aluminum = 2 } },
    brakes = { label = Lang:t('menu.brakes_repair'), maxValue = 100, repair = { copper = 2 } },
    clutch = { label = Lang:t('menu.clutch_repair'), maxValue = 100, repair = { copper = 2 } },
    fuel = { label = Lang:t('menu.fuel_repair'), maxValue = 100, repair = { plastic = 2 } },
}

Config.Shops = {
    bennys = { -- Default Bennys Location
        managed = true,
        shopLabel = 'Benny\'s Motorworks',
        showBlip = true,
        blipSprite = 72,
        blipColor = 46,
        blipCoords = vector3(-211.73, -1325.28, 30.89),
        duty = vector3(-202.92, -1313.74, 31.70),
        stash = vector3(-199.58, -1314.65, 31.08),
        paint = vector3(-202.42, -1322.16, 31.29),
        
        vehicles = {
            withdraw = vector3(0, 0, 0),
            spawn = vector4(-370.51, -107.88, 38.35, 72.56),
            list = { 'flatbed', 'towtruck', 'minivan', 'blista' }
        },
    },
   
}

NOS STUFF
	NosRefillCharge = 1000, -- amount in dollars required to refill a nos can

	NosTopSpeed = 55.0, -- Enabling this adds a multiplier to the top speed of the vehicle
						-- Set this to "-1.0" to disable this
						-- This doesn't affect the boost acceleration
	NosBoostPower = { -- NOS boost acceleration power
		10.0, -- Level 1
		30.0, -- Level 2
		50.0, -- Level 3
	},

	NitrousUseRate = 0.4, -- How fast the nitrous drains (halved for level1, doubled for level3)

	NitrousCoolDown = 7, -- 7 Seconds, set to 0 to disable
	CooldownConfirm = true, -- Will play a confirmation beep when cooldown is done

	nosDamage = true, -- This enables NOS causing damage to engine while boosting
	boostExplode = true, -- If boosting too long at level 3 boost, tank will explode.
