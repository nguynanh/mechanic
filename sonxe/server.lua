-- server.lua
RegisterNetEvent('bryan_paintjob:server:setLocationBusy', function(pos, value)
    TriggerClientEvent('bryan_paintjob:client:setLocationBusy', -1, pos, value)
end)

-- CẬP NHẬT LẠI HOÀN TOÀN HÀM NÀY
RegisterNetEvent('bryan_paintjob:server:initalizePaint', function(id, vehicle, p)
    TriggerClientEvent('bryan_paintjob:client:initalizePaint', -1, id, vehicle, p)
end)

RegisterNetEvent('bryan_paintjob:server:stopPaint', function(id)
    TriggerClientEvent('bryan_paintjob:client:stopPaint', -1, id)
end)


RegisterNetEvent('bryan_paintjob:server:saveVehiclePaint', function(vehiclePlate, paintData)
    -- Kiểm tra xem vehiclePlate có hợp lệ không
    if not vehiclePlate or vehiclePlate == '' then
        print('^1[bryan_paintjob] Cảnh báo: Không thể lưu sơn cho xe không có biển số.^7')
        return
    end

    local primaryColorStr = string.format('%d,%d,%d', paintData.primary.r, paintData.primary.g, paintData.primary.b)
    local secondaryColorStr = string.format('%d,%d,%d', paintData.secondary.r, paintData.secondary.g, paintData.secondary.b)

    exports.oxmysql:execute('UPDATE player_vehicles SET primary_color = ?, secondary_color = ?, pearlescent_color = ?, livery = ?, mod_livery = ? WHERE plate = ?', {
        primaryColorStr,
        secondaryColorStr,
        paintData.pearlescent,
        paintData.livery,
        paintData.modLivery,
        vehiclePlate
    }, function(rowsAffected)
        if rowsAffected > 0 then
            print(string.format('^2[bryan_paintjob] Đã lưu sơn cho xe có biển số: %s^7', vehiclePlate))
        else
            print(string.format('^1[bryan_paintjob] Lỗi: Không tìm thấy xe có biển số %s trong database để cập nhật.^7', vehiclePlate))
        end
    end)
end)