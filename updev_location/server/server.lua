ESX.RegisterServerCallback("updev:location", function(source, cb, model, price, label, coords, heading, rentTimeInMinutes)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerMoney = xPlayer.getAccount("money").money
    local playerPed = GetPlayerPed(source)
    
    if playerMoney >= price then
        xPlayer.removeMoney(price)
        xPlayer.showNotification(string.format("✅ Vous avez loué le véhicule %s pour ~r~%s$", label, price))

        ESX.OneSync.SpawnVehicle(model, coords, heading, false, function(networkId)
            if networkId then
                local vehicle = NetworkGetEntityFromNetworkId(networkId)
        
                if xRoutingBucket and xRoutingBucket ~= 0 then
                    SetEntityRoutingBucket(vehicle, xRoutingBucket)
                end
        
                for _ = 1, 100 do
                    Wait(0)
                    SetPedIntoVehicle(playerPed, vehicle, -1)
                    if GetVehiclePedIsIn(playerPed, false) == vehicle then
                        cb(true, networkId)
                        break
                    end
                end
        
                if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
                    showError("[^1ERROR^7] The player could not be seated in the vehicle")
                    cb(false)
                    return
                end
        


                SetTimeout(900000, function()
                    if DoesEntityExist(vehicle) then
                        DeleteEntity(vehicle)
                        xPlayer.showNotification("⚠️ Votre véhicule a été supprimé car le temps de location est écoulé.")
                    end
                end)
            else
                cb(false)
            end
        end)
    else
        local missingMoney = price - playerMoney
        xPlayer.showNotification(string.format("❌ Vous n'avez pas assez d'argent, il vous manque ~r~%s$", missingMoney))
        cb(false)
    end
end)