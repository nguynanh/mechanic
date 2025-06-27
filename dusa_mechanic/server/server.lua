-- __________________  .____    _____.___. ____   ____._____________ 
-- \______   \_____  \ |    |   \__  |   | \   \ /   /|   \______   \
--  |     ___//   |   \|    |    /   |   |  \   Y   / |   ||     ___/
--  |    |   /    |    \    |___ \____   |   \     /  |   ||    |    
--  |____|   \_______  /_______ \/ ______|    \___/   |___||____|    
--                   \/        \/\/                                  
-- [https://discord.gg/gaJJjnKGpg] 
-- [https://discord.gg/TCD9zn8Xqx]

local AllMechanics =  {}
local vehData = {}

CreateThread(function()
    if dusa.framework == 'qb' then
        MySQL.Async.fetchAll("SELECT * FROM player_vehicles",{}, function(result)
            for plate, data in pairs(result) do
                vehData[data.plate] = data
            end
        end)

        MySQL.update(
            [[
            CREATE TABLE IF NOT EXISTS `dusa_mechanic` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `m_id` varchar(50) DEFAULT NULL,
            `mechanic` varchar(255) DEFAULT NULL,
            `boss` varchar(100) DEFAULT NULL,
            `employees` longtext DEFAULT NULL,
            `history` longtext DEFAULT NULL,
            `ranks` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4;
            ]]     , {}, function(success)
            if success then
                print("[dusa_mechanic] ^2Mechanic Tables successfully updated^7")
            else
                print("[dusa_mechanic] ^3Error connecting to DB^7")
            end
        end)

        MySQL.update(
            [[
                ALTER TABLE player_vehicles
                ADD COLUMN IF NOT EXISTS tuning LONGTEXT DEFAULT NULL,
                ADD COLUMN IF NOT EXISTS fitment VARCHAR(500) DEFAULT NULL;
            ]]     , {}, function(success) 
        end)
    else
        MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{}, function(result)
            for plate, data in pairs(result) do
                vehData[data.plate] = data
            end
        end)

        MySQL.update(
            [[
            CREATE TABLE IF NOT EXISTS `dusa_mechanic` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `m_id` varchar(50) DEFAULT NULL,
            `mechanic` varchar(255) DEFAULT NULL,
            `boss` varchar(100) DEFAULT NULL,
            `employees` longtext DEFAULT NULL,
            `history` longtext DEFAULT NULL,
            `ranks` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4;
            ]]     , {}, function(success)
            if success then
                print("[dusa_mechanic] ^2Mechanic Tables successfully updated^7")
            else
                print("[dusa_mechanic] ^3Error connecting to DB^7")
            end
        end)

        MySQL.update(
            [[
                ALTER TABLE owned_vehicles
                ADD COLUMN IF NOT EXISTS tuning LONGTEXT DEFAULT NULL,
                ADD COLUMN IF NOT EXISTS fitment VARCHAR(500) DEFAULT NULL;
            ]]     , {}, function(success) 
        end)
    end
    
    AllMechanics = MySQL.prepare.await('SELECT * FROM dusa_mechanic', {})
end)

RegisterNetEvent('dusa_mechanic:sv:reload', function()
	local source = source
    local identifier = dusa.getIdentifier(source)
    if AllMechanics then
        dusa.AllMechanics = AllMechanics
        dusa.AllMechanics = json.decode(json.encode(dusa.AllMechanics))
        if dusa.AllMechanics.m_id then
            local boss = json.decode(dusa.AllMechanics.boss)
            if boss.identifier == identifier then
                TriggerClientEvent('dusa_mechanic:cl:playermechanic', source, dusa.AllMechanics)
            end
            local employees = json.decode(dusa.AllMechanics.employees)
            for a, b in pairs(employees) do
                if b.identifier == identifier then
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', source, dusa.AllMechanics)
                end
            end
        else
            for k, v in pairs(dusa.AllMechanics) do
                local boss = json.decode(v.boss)
                if boss.identifier == identifier then
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', source, v)
                end
                local employees = json.decode(v.employees)
                for a, b in pairs(employees) do
                    if b.identifier == identifier then
                        TriggerClientEvent('dusa_mechanic:cl:playermechanic', source, v)
                    end
                end
            end
        end
    end
    CreateMechanic()
end)

function CreateMechanic()
    for a, b in pairs(Config.Mechanics) do
        local mechanic = {name = 'Mechanic', vault = 5000, discount = 15, fee = 200}
        local boss
        if b.bossIdentifier and b.bossIdentifier ~= "" then
            if dusa.getName(dusa.getPlayerFromIdentifier(b.bossIdentifier)) then
                boss = {name = dusa.getName(dusa.getPlayerFromIdentifier(b.bossIdentifier)), identifier = b.bossIdentifier}
            else
                boss = {name = "", identifier= b.bossIdentifier}
            end
        else
            boss = {name = "", identifier= ""}
        end
        local employees = {}
        local job = {}
        local history = {}
        local allJobs = dusa.getJobs()

        for k, v in pairs(allJobs) do
            if k == b.job then
                for id, grd in pairs(v.grades) do
                    if dusa.framework == 'esx' then
                        if grd.name == 'boss' then
                            job[#job+1] = {id = id, name = grd.name, sellCompany = true, withdraw = true, deposit = true,  addEmployee = true, updateDiscount = true, updateWashPrice = true, updateMechanicName = true, updateRank = true, kickEmployee = true, managePerm = true}
                        else
                            job[#job+1] = {id = id, name = grd.name, sellCompany = false, withdraw = false, deposit = false,  addEmployee = false, updateDiscount = false, updateWashPrice = false, updateMechanicName = false, updateRank = false, kickEmployee = false, managePerm = false}
                        end
                    elseif dusa.framework == 'qb' then
                        if grd.isboss then
                            job[#job+1] = {id = id, name = grd.name, sellCompany = true, withdraw = true, deposit = true,  addEmployee = true, updateDiscount = true, updateWashPrice = true, updateMechanicName = true, updateRank = true, kickEmployee = true, managePerm = true}
                        else
                            job[#job+1] = {id = id, name = grd.name, sellCompany = false, withdraw = false, deposit = false,  addEmployee = false, updateDiscount = false, updateWashPrice = false, updateMechanicName = false, updateRank = false, kickEmployee = false, managePerm = false}
                        end
                    end
                end
            end
        end
        MySQL.Async.fetchAll("SELECT * FROM dusa_mechanic WHERE m_id = @m_id", {
            ["@m_id"] = b.id
        }, function(output)
            if #output > 0 then
            else
                if dusa.AllMechanics.m_id then
                    if dusa.AllMechanics.m_id == b.id then return end
                else
                    for k, v in pairs(dusa.AllMechanics) do if v.m_id == b.id then return end end
                end
                MySQL.Async.execute('INSERT INTO dusa_mechanic (m_id, mechanic, boss, employees, ranks, history) VALUES (@m_id, @mechanic, @boss, @employees, @ranks, @history)',
                {
                    ['@m_id']   = b.id,
                    ['@mechanic']   = json.encode(mechanic),
                    ['@boss']   = json.encode(boss),
                    ['@employees']   = json.encode(employees),
                    ['@ranks']   = json.encode(job),
                    ['@history']   = json.encode(history),
                }, function (rowsChanged)
                    dusa.AllMechanics = MySQL.prepare.await('SELECT * FROM dusa_mechanic', {})
                end)
            end
        end)      
    end
end

dusa.registerCallback('dusa_mechanic:cb:GetMechanicData', function(source, cb, id)
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            dusa.mechanic = v
            cb(v)
        end
    end
end)

dusa.registerCallback('dusa_mechanic:cb:checkMoney', function(source, cb, money, type, id)
    if type == 'company' then
        for _, v in ipairs(dusa.AllMechanics) do
            if tonumber(v.m_id) == tonumber(id) then
                local pMechanic = json.decode(v.mechanic)
                if pMechanic.vault >= money then
                    cb(true)
                else
                    cb(false)
                end
            end
        end
    else
        local pmoney = dusa.getMoney(source, type)
        if pmoney >= money then
            cb(true)
        else
            cb(false)
        end
    end
end)

dusa.registerCallback('dusa_mechanic:cb:getRanks', function(source, cb, mid)
    for _, v in ipairs(dusa.AllMechanics) do
        if v.m_id == mid then
            cb(v.ranks)
        end
    end
end)

dusa.registerCallback('dusa_mechanic:cb:getAllMechanics', function(source, cb)
    cb(dusa.AllMechanics)
end)

RegisterServerEvent('dusa_mechanic:sv:getItemCounts', function()
    local source = source
    local table = {}
    local count
    table = Config.CraftItems
    for k, v in pairs(Config.CraftItems) do
        for i=1, #Config.CraftItems[k].requirements, 1 do
            local item = dusa.getItem(source, Config.CraftItems[k].requirements[i].item)
            if item then
                if dusa.framework == 'esx' then count = item.count elseif dusa.framework == 'qb' then count = item.amount end
                Config.CraftItems[k].requirements[i].owned = count
                table[k].requirements[i].owned = count
            else
                Config.CraftItems[k].requirements[i].owned = 0
                table[k].requirements[i].owned = 0
            end
        end
    end
    TriggerClientEvent('dusa_mechanic:cl:getItemCounts', source, table)
end)

dusa.registerCallback('dusa_mechanic:cb:getItem', function(source, cb, item)
    local item = dusa.getItem(source, item)
    cb(item)
end)

RegisterServerEvent('dusa_mechanic:sv:removeMoney', function(money, type, id)
    local source = source
    local pJob = dusa.getJob(source)
    if type == 'company' then
        for _, v in ipairs(dusa.AllMechanics) do
            if tonumber(v.m_id) == tonumber(id) then
                local pMechanic = json.decode(v.mechanic)
                pMechanic.vault = pMechanic.vault - tonumber(money)
                TriggerClientEvent('dusa_mechanic:cl:updateVault', -1, pMechanic.vault, pJob.name)
                v.mechanic = json.encode(pMechanic)
                MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                    ['@mechanic'] = json.encode(pMechanic),
                    ['@m_id'] = id,
                }, function(rowsChanged) end)
            end
        end
    else
        dusa.removeMoney(source, type, money)
    end
end)

RegisterServerEvent('dusa_mechanic:sv:syncBlips', function()
    local source = source
    -- dusa.AllMechanics
    TriggerClientEvent('dusa_mechanic:cl:syncBlips', -1)
    for _, v in ipairs(dusa.AllMechanics) do
        TriggerClientEvent('dusa_mechanic:cl:placeBlips', -1, v)
    end
end)

RegisterServerEvent('dusa_mechanic:sv:updateMechanic', function()
    local source = source
    id = 'ASDASD'
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            dusa.mechanic = v
            cb(v)
        end
    end
end)

RegisterNetEvent("dusa_mechanic:sv:findIdentifier", function(plysrc)
    local source = source
    local otherPlayer = plysrc
    TriggerClientEvent('dusa_mechanic:cl:addToPlayersClean', source, dusa.getName(dusa.getPlayer(otherPlayer)), plysrc, dusa.getIdentifier(otherPlayer))
end)

RegisterServerEvent('dusa_mechanic:sv:getRanks', function(mid)
    for _, v in ipairs(dusa.AllMechanics) do
        if v.m_id == mid then
            TriggerClientEvent('dusa_mechanic:cl:getRanks', v.ranks)
        end
    end
end)

-- RegisterServerEvent('dusa_mechanic:sv:saveTuning', function(tuning)
--     Tunings = tuning
--     for k, v in pairs(tuning) do
--         MySQL.Async.execute('UPDATE owned_vehicles SET tuning = @tuning WHERE plate = @plate', {
--             ['@tuning'] = json.encode(v),
--             ['@plate'] = k,
--         }, function(rowsChanged) end)
--     end
-- end)

RegisterServerEvent('dusa_mechanic:sv:updateRank', function(id, data)
    local source = source
    for _, v in ipairs(dusa.AllMechanics) do
        if v.m_id == id then
            -- update ranks table
            local jobTable = json.decode(v.ranks)
            jobTable = data
            MySQL.Async.execute('UPDATE dusa_mechanic SET ranks = @ranks WHERE m_id = @m_id', {
                ['@ranks'] = json.encode(jobTable),
                ['@m_id'] = id,
            }, function(rowsChanged) end)
            TriggerClientEvent('dusa_mechanic:cl:updateRanks', source, json.encode(jobTable))
            TriggerClientEvent('dusa_mechanic:cl:syncRank', -1, json.encode(jobTable))
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:promote', function(data, id)
    local source = source
    local tPlayer = dusa.getPlayerFromIdentifier(data.identifier)
    local tSource = dusa.playerSrc(tPlayer)
    local tJob = dusa.getJob(tSource)
    local allJobs = dusa.getJobs()
    for k, v in pairs(allJobs) do
        if k == tJob.name then
            local grade = tJob.grade
            if dusa.framework == 'qb' then grade = tJob.grade.level end
            if grade + 1 <= LastIndex(v.grades) then
                dusa.setJob(tSource, tJob.name, grade + 1)
                TriggerClientEvent('dusa_mechanic:cl:updatePlayerRank', -1, grade + 1, id, tJob.name)
                TriggerClientEvent('dusa_mechanic:cl:notify', tSource, Config.Translations[Config.Locale].youpromoted, 'success')
                TriggerClientEvent('dusa_mechanic:cl:updateEmployees', tSource, v.employees, tJob.name)
                return
            else
                TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].alreadymaxgrade, 'error')
                return
            end
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:demote', function(data, id)
    local source = source
    local tPlayer = dusa.getPlayerFromIdentifier(data.identifier)
    local tSource = dusa.playerSrc(tPlayer)
    local tJob = dusa.getJob(tSource)
    local allJobs = dusa.getJobs()
    for k, v in pairs(allJobs) do
        if k == tJob.name then
            local grade = tJob.grade
            if dusa.framework == 'qb' then grade = tJob.grade.level end
            if grade - 1 >= 0 then
                dusa.setJob(tSource, tJob.name, grade - 1)
                TriggerClientEvent('dusa_mechanic:cl:updatePlayerRank', -1, grade - 1, id, tJob.name)
                TriggerClientEvent('dusa_mechanic:cl:notify', tSource, Config.Translations[Config.Locale].youdemoted, 'error')
                TriggerClientEvent('dusa_mechanic:cl:updateEmployees', tSource, v.employees, tJob.name)
                return
            else
                TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].alreadymingrade, 'error')
                return
            end
        end
    end
end)

local employees = {}
local including = {}
RegisterServerEvent('dusa_mechanic:sv:addEmployee', function(data, id)
    local source = source
    local pJob = dusa.getJob(source)
    local tPlayer = dusa.getPlayerFromIdentifier(data.identifier)
    local tSource = dusa.playerSrc(tPlayer)
    local isDuplicate = false
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            boss = json.decode(v.boss)
            employees = json.decode(v.employees)
            for i=1, #Config.Mechanics do
                if boss.identifier ~= data.identifier and Config.Mechanics[i].bossIdentifier ~= data.identifier then
                    local rank
                    if data.rank then rank = data.rank else rank = 0 end 
                    if not next(employees) then
                        -- db boş ise
                        employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = rank}
                        v.employees = json.encode(employees)
                    else
                        for i=1, #employees, 1 do
                            if data.identifier == employees[i].identifier then
                                isDuplicate = true
                                break
                            end
                        end

                        if not isDuplicate then
                            employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = data.rank}
                            v.employees = json.encode(employees)
                        end
                    end
                    TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, v.employees, pJob.name)
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, v)
                    dusa.setJob(tSource, Config.Mechanics[i].job, 0)
                    TriggerClientEvent('dusa_mechanic:cl:notify', tSource, Config.Translations[Config.Locale].youhired, 'success')
                elseif Config.Mechanics[i].bossIdentifier == data.identifier then
                    boss.identifier = Config.Mechanics[i].bossIdentifier
                    boss.name = data.name
                    TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, v.employees, pJob.name)
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, v)
                end
            end
        end
    end
    MySQL.Async.execute('UPDATE dusa_mechanic SET employees = @employees, boss = @boss WHERE m_id = @m_id', {
        ['@employees'] = json.encode(employees),
        ['@boss'] = json.encode(boss),
        ['@m_id'] = id,
    }, function (rowsChanged)
        dusa.AllMechanics = MySQL.prepare.await('SELECT * FROM dusa_mechanic', {})
    end)
end)

RegisterServerEvent('dusa_mechanic:sv:updatePlayerRank', function(newRank, id)
    local source = source
    local player = dusa.getPlayer(source)
    local identifier = dusa.getIdentifier(source)
    local pJob = dusa.getJob(source)
    for i=1, #dusa.AllMechanics, 1 do
        if tonumber(dusa.AllMechanics[i].m_id) == tonumber(id) then
            employees = json.decode(dusa.AllMechanics[i].employees)
            -- oyuncunun mekaniğine geldik
            for a=1, #employees, 1 do
                if employees[a].identifier == identifier then
                    employees[a].rank = newRank
                    dusa.AllMechanics[i].employees = json.encode(employees)
                    TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, dusa.AllMechanics[i].employees, pJob.name)
                end
            end
        end
    end
    MySQL.Async.execute('UPDATE dusa_mechanic SET employees = @employees WHERE m_id = @m_id', {
        ['@employees'] = json.encode(employees),
        ['@m_id'] = id,
    }, function (rowsChanged)
    end)
end)

RegisterServerEvent('dusa_mechanic:sv:addAutoJobPlayers', function(data, id)
    local source = source
    local tPlayer = dusa.getPlayerFromIdentifier(data.identifier)
    local tSource = dusa.playerSrc(tPlayer)
    local isDuplicate = false
    local allMechs = json.decode(json.encode(dusa.AllMechanics))
    if allMechs.m_id then
        if tonumber(allMechs.m_id) == tonumber(id) then
            boss = json.decode(allMechs.boss)
            employees = json.decode(allMechs.employees)
            for i=1, #Config.Mechanics do
                if boss.identifier ~= data.identifier and Config.Mechanics[i].bossIdentifier ~= data.identifier then
                    local rank
                    if data.rank then rank = data.rank else rank = 0 end 
                    if not next(employees) then
                        -- db boş ise
                        employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = rank}
                        allMechs.employees = json.encode(employees)
                    else
                        for i=1, #employees, 1 do
                            if data.identifier == employees[i].identifier then
                                isDuplicate = true
                                break
                            end
                        end

                        if not isDuplicate then
                            employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = data.rank}
                            allMechs.employees = json.encode(employees)
                        end
                    end
                    TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, allMechs.employees, Config.Mechanics[i].job)
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, allMechs)
                elseif Config.Mechanics[i].bossIdentifier == data.identifier then
                    boss.identifier = Config.Mechanics[i].bossIdentifier
                    boss.name = data.name
                    TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, allMechs.employees, Config.Mechanics[i].job)
                    TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, allMechs)
                end
            end
        end
    else
        for k, v in pairs(dusa.AllMechanics) do
            if tonumber(v.m_id) == tonumber(id) then
                boss = json.decode(v.boss)
                employees = json.decode(v.employees)
                for i=1, #Config.Mechanics do
                    if boss.identifier ~= data.identifier and Config.Mechanics[i].bossIdentifier ~= data.identifier then
                        local rank
                        if data.rank then rank = data.rank else rank = 0 end 
                        if not next(employees) then
                            -- db boş ise
                            employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = rank}
                            v.employees = json.encode(employees)
                        else
                            for i=1, #employees, 1 do
                                if data.identifier == employees[i].identifier then
                                    isDuplicate = true
                                    break
                                end
                            end
    
                            if not isDuplicate then
                                employees[#employees+1] = {name = data.name, identifier = data.identifier, img = data.img, rank = data.rank}
                                v.employees = json.encode(employees)
                            end
                        end
                        TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, v.employees, Config.Mechanics[i].job)
                        TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, v)
                    elseif Config.Mechanics[i].bossIdentifier == data.identifier then
                        boss.identifier = Config.Mechanics[i].bossIdentifier
                        boss.name = data.name
                        TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, v.employees, Config.Mechanics[i].job)
                        TriggerClientEvent('dusa_mechanic:cl:playermechanic', tSource, v)
                    end
                end
            end
        end
    end

    MySQL.Async.execute('UPDATE dusa_mechanic SET employees = @employees, boss = @boss WHERE m_id = @m_id', {
        ['@employees'] = json.encode(employees),
        ['@boss'] = json.encode(boss),
        ['@m_id'] = id,
    }, function (rowsChanged)
        dusa.AllMechanics = MySQL.prepare.await('SELECT * FROM dusa_mechanic', {})
    end)
end)

RegisterServerEvent('dusa_mechanic:sv:vault', function(type, data, id)
    local source = source
    local playerMoney = dusa.getMoney(source, 'cash')
    local pJob = dusa.getJob(source)
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            local mechanicTable = json.decode(v.mechanic)
            if type == 'deposit' then
                if tonumber(playerMoney) > tonumber(data.amount) then
                    dusa.removeMoney(source, 'cash', tonumber(data.amount))
                    mechanicTable.vault = mechanicTable.vault + tonumber(data.amount)
                    TriggerClientEvent('dusa_mechanic:cl:updateVault', -1, mechanicTable.vault, pJob.name)
                    v.mechanic = json.encode(mechanicTable)
                    MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                        ['@mechanic'] = json.encode(mechanicTable),
                        ['@m_id'] = id,
                    }, function(rowsChanged) end)
                else
                    TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].notenoughmoney, 'error')
                end
            elseif type == 'withdraw' then
                if tonumber(mechanicTable.vault) >= tonumber(data.amount) then
                    dusa.addMoney(source, 'cash', tonumber(data.amount))
                    mechanicTable.vault = mechanicTable.vault - tonumber(data.amount)
                    TriggerClientEvent('dusa_mechanic:cl:updateVault', -1, mechanicTable.vault, pJob.name)
                    v.mechanic = json.encode(mechanicTable)
                    MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                        ['@mechanic'] = json.encode(mechanicTable),
                        ['@m_id'] = id,
                    }, function(rowsChanged) end)
                else
                    TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].safemoneynotenough, 'error')
                end
            end
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:setFee', function(data, id)
    local source = source
    local pJob = dusa.getJob(source)
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            local mechanicTable = json.decode(v.mechanic)
            -- data.fee = fee amount
            mechanicTable.fee = data.fee
            TriggerClientEvent('dusa_mechanic:cl:updateFee', -1, mechanicTable.fee, pJob.name)
            v.mechanic = json.encode(mechanicTable)
            MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                ['@mechanic'] = json.encode(mechanicTable),
                ['@m_id'] = id,
            }, function(rowsChanged) end)
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:setDiscount', function(data, id)
    local source = source
    local pJob = dusa.getJob(source)
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            local mechanicTable = json.decode(v.mechanic)
            -- data.fee = fee amount
            mechanicTable.discount = data.discount
            TriggerClientEvent('dusa_mechanic:cl:updateDiscount', -1, mechanicTable.discount, pJob.name)
            v.mechanic = json.encode(mechanicTable)
            MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                ['@mechanic'] = json.encode(mechanicTable),
                ['@m_id'] = id,
            }, function(rowsChanged) end)
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:setName', function(data, id)
    local source = source
    local pJob = dusa.getJob(source)
    for _, v in pairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            local mechanicTable = json.decode(v.mechanic)
            -- data.fee = fee amount
            mechanicTable.name = data.name
            TriggerClientEvent('dusa_mechanic:cl:updateName', -1, mechanicTable.name, pJob.name)
            v.mechanic = json.encode(mechanicTable)
            MySQL.Async.execute('UPDATE dusa_mechanic SET mechanic = @mechanic WHERE m_id = @m_id', {
                ['@mechanic'] = json.encode(mechanicTable),
                ['@m_id'] = id,
            }, function(rowsChanged) end)
        end
    end
end)

RegisterServerEvent('dusa_mechanic:sv:kickStaff', function(data, id)
    local source = source
    local tPlayer = dusa.getPlayerFromIdentifier(data.staff.identifier)
    local tSource = dusa.playerSrc(tPlayer)
    local pJob = dusa.getJob(source)
    for _, v in ipairs(dusa.AllMechanics) do
        if tonumber(v.m_id) == tonumber(id) then
            local employeeTable = json.decode(v.employees)
            if tPlayer then
                -- player is active and can be fired
                dusa.setJob(tSource, 'unemployed', 0)
                -- databaseden sil
                for w, kicked in pairs(employeeTable) do
                    if kicked.identifier == data.staff.identifier then
                        table.remove(employeeTable, w)
                    end
                end
                v.employees = json.encode(employeeTable)
                TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, employeeTable, pJob.name)
                MySQL.Async.execute('UPDATE dusa_mechanic SET employees = @employees WHERE m_id = @m_id', {
                    ['@employees'] = json.encode(employeeTable),
                    ['@m_id'] = id,
                }, function(rowsChanged) end)
                -- dbupdate at
            else
                -- player is not active, kick from database
                -- databaseden sil
                -- mesleğini değiştir***
                for _, v in pairs(employeeTable) do
                    employeeTable[#employeeTable-1] = v
                end
                v.employees = json.encode(employeeTable)
                TriggerClientEvent('dusa_mechanic:cl:updateEmployees', -1, employeeTable, pJob.name)
                MySQL.Async.execute('UPDATE dusa_mechanic SET employees = @employees WHERE m_id = @m_id', {
                    ['@employees'] = json.encode(employeeTable),
                    ['@m_id'] = id,
                }, function(rowsChanged) end)
            end
        end
    end
end)

addElement = function(section, data)
    local fitment, tuning
    if not vehData[data.plate] then
        vehData[data.plate] = {}
    end

    if section == "fitment" then
        vehData[data.plate][section] = data.fitment
    elseif section == "tuning" then
        vehData[data.plate][section] = data.tuning
    elseif section == "nitro" then
        vehData[data.plate][section] = data
        -- vehData[data.plate][section].remaining = data.remaining
    elseif data.component.mod == "Stock" then
        vehData[data.plate][section] = nil
    else
        vehData[data.plate][section] = data.component.mod
    end

    if dusa.framework == 'qb' then
        MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE plate = @plate", {
            ["@plate"] = data.plate
        }, function(output)
            if #output > 0 then
                if type(vehData[data.plate]["fitment"]) == 'table' then fitment = json.encode(vehData[data.plate]["fitment"]) else fitment = vehData[data.plate]["fitment"] end
                if type(vehData[data.plate]["tuning"]) == 'table' then tuning = json.encode(vehData[data.plate]["tuning"]) else tuning = vehData[data.plate]["tuning"] end
                MySQL.Async.execute("UPDATE player_vehicles SET fitment = @fitment, tuning = @tuning WHERE plate = @plate",{
                    ["@plate"] = data.plate,
                    ["@fitment"] = fitment,
                    ["@tuning"] = tuning,
                })
            end
        end)
    else
        MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {
            ["@plate"] = data.plate
        }, function(output)
            if #output > 0 then
                if type(vehData[data.plate]["fitment"]) == 'table' then fitment = json.encode(vehData[data.plate]["fitment"]) else fitment = vehData[data.plate]["fitment"] end
                if type(vehData[data.plate]["tuning"]) == 'table' then tuning = json.encode(vehData[data.plate]["tuning"]) else tuning = vehData[data.plate]["tuning"] end
                MySQL.Async.execute("UPDATE owned_vehicles SET fitment = @fitment, tuning = @tuning WHERE plate = @plate",{
                    ["@plate"] = data.plate,
                    ["@fitment"] = fitment,
                    ["@tuning"] = tuning,
                })
            end
        end)
    end

    return TriggerClientEvent("dusa_mechanic:cl:updateVehData", -1, vehData)
end

RegisterServerEvent("dusa_mechanic:sv:addElement", addElement)

RegisterServerEvent("dusa_mechanic:sv:saveModification", function(plate, props)
    if plate and props then
        if dusa.framework == 'qb' then
            MySQL.Async.execute("UPDATE player_vehicles SET mods = @mods WHERE plate = @plate",{
                ["@plate"] = plate,
                ["@mods"] = json.encode(props),
            })
        else
            MySQL.Async.execute("UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate",{
                ["@plate"] = plate,
                ["@vehicle"] = json.encode(props),
            })
        end
    end
end)

getElement = function(plate)
    if not vehData[plate] then
        vehData[plate] = {}
    end

    if dusa.framework == 'qb' then
        MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE plate = @plate", {
            ["@plate"] = plate
        }, function(output)
            if #output > 0 then
                vehData[plate]["fitment"] = output.fitment
                vehData[plate]["tuning"] = output.tuning
            end
        end)
    else
        MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {
            ["@plate"] = plate
        }, function(output)
            if #output > 0 then
                vehData[plate]["fitment"] = output.fitment
                vehData[plate]["tuning"] = output.tuning
            end
        end)
    end

    return TriggerClientEvent("dusa_mechanic:cl:getVehData", -1, vehData)
end

RegisterServerEvent("dusa_mechanic:sv:getVehData", getElement)

RegisterServerEvent("dusa_mechanic:sv:syncFitment", function(vehicleId, fitmentData, plate)
    TriggerClientEvent("dusa_mechanic:cl:syncFitment", -1, vehicleId, fitmentData)
end)

RegisterServerEvent('dusa_mechanic:sv:craftItem', function(data)
    local source = source
    dusa.addItem(source, data.item)
    for k,v in pairs(data.required) do
        dusa.removeItem(source, v.item, v.count)
    end
end)

function LastIndex(table)
    local lastKey = 0
    for key, _ in pairs(table) do
        key = tonumber(key)
        if key and key > lastKey then
            lastKey = key
        end
    end
    return lastKey
end

--------
-- CB
--------

----------
-- CARLIFT
----------
local elevators = {}

RegisterNetEvent('dusa_carlift:server:deleteEntity', function(entity)
    DeleteEntity(entity)
end)

RegisterNetEvent('dusa_carlift:server:update', function(data)
    elevators = data
end)

RegisterNetEvent('dusa_carlift:server:onjoin', function()
    local src = source
    TriggerClientEvent('dusa_carlift:client:spawnElevators', src)
end)

RegisterNetEvent('dusa_carlift:server:use', function(data)
    local src = source
    if data.handle == "up" then TriggerClientEvent('dusa_carlift:client:elevatorUp', src, data) end
    if data.handle == "down" then TriggerClientEvent('dusa_carlift:client:elevatorDown', src, data) end
    if data.handle == "stop" then TriggerClientEvent('dusa_carlift:client:elevatorStop', src, data) end
end)

if Config.TuningAsItem then
    dusa.registerUsableItem('tuningtablet', function(source)
        local tJob = dusa.getJob(source)
        local allJobs = dusa.getJobs()
        for k, v in pairs(allJobs) do
            if k == tJob.name then
                local grade = tJob.grade
                if dusa.framework == 'qb' then grade = tJob.grade.level end
                if grade >= Config.MinimumGrade then 
                    TriggerClientEvent('dusa_mechanic:cl:useTuning', source)
                else
                    TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].notmechanicitem, 'error')
                end
            end
        end
    end)
else
    RegisterCommand(Config.TuningCommand, function(source)
        local tJob = dusa.getJob(source)
        local allJobs = dusa.getJobs()
        for k, v in pairs(allJobs) do
            if k == tJob.name then
                local grade = tJob.grade
                if dusa.framework == 'qb' then grade = tJob.grade.level end
                if grade >= Config.MinimumGrade then 
                    TriggerClientEvent('dusa_mechanic:cl:useTuning', source)
                else
                    TriggerClientEvent('dusa_mechanic:cl:notify', source, Config.Translations[Config.Locale].notmechanic, 'error')
                end
            end
        end
    end)
end

-- SAVE & SYNC STANCER
-- SetStancer = function(entity)
--     if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
--         local plate = GetVehicleNumberPlateText(entity)
--         if vehData[plate] then
--             if vehData[plate]["fitment"] then
--                 Entity(entity).state:set('stancer',vehData[plate]["fitment"],true)
--             end
--         end
--     end
-- end

-- AddStateBagChangeHandler('VehicleProperties' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
-- 	Wait(0)
-- 	local net = tonumber(bagName:gsub('entity:', ''), 10)
-- 	if not value then return end
--     local entity = NetworkGetEntityFromNetworkId(net)
--     Wait(1000)
--     if DoesEntityExist(entity) then
--         SetStancer(entity) -- compatibility with ESX onesync server setter vehicle spawn
--     end
-- end)

-- AddEventHandler('entityCreated', function(entity)
--     local entity = entity
--     Wait(1000)
--     SetStancer(entity)
-- end)

-- AddEventHandler('entityRemoved', function(entity)
--     local entity = entity
--     if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
--         local ent = Entity(entity).state
--         if ent.stancer then
--             local plate = GetVehicleNumberPlateText(entity)
--             local data = {
--                 plate = plate,
--                 fitment = ent.stancer
--             }
--             TriggerEvent("dusa_mechanic:sv:addElement", "fitment", data)
--         end
--     end
-- end)


RegisterServerEvent("dusa_mechanic:server:useNitro", function(vehicleId)
    TriggerClientEvent("dusa_mechanic:client:useNitro", -1, vehicleId)
end)

RegisterServerEvent("dusa_mechanic:sv:syncHeadlight", function(vehicleId, r, g, b)
    TriggerClientEvent("dusa_mechanic:cl:syncHeadlight", -1, vehicleId, r, g, b)
end)

dusa.registerUsableItem(Config.Settings.nitro.item, function(source)
    dusa.removeItem(source, Config.Settings.nitro.item, 1)
    TriggerClientEvent('dusa_mechanic:cl:useNitro', source)
end)