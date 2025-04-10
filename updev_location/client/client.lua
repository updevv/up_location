local openmenu = false
local locationBlips = {}
local rentedVehicles = {}

function OpenLocationMenu(coords, heading)
    local menuPrincipal = RageUI.CreateMenu(nil, "Gérer les shops", nil, nil)

    if openmenu then
        openmenu = false
        RageUI.Visible(menuPrincipal, false)
    else
        openmenu = true
        RageUI.Visible(menuPrincipal, true)
        CreateThread(function()
            while openmenu do
                RageUI.IsVisible(menuPrincipal, function()
                    RageUI.Separator("Location de véhicule")
                    RageUI.Line()
                    for _, v in pairs(Config.LocationVehicle) do
                        RageUI.Button(v.label, "Appuyez sur le bouton pour louer le véhicule", { RightLabel = v.price .. "$" }, true, {
                            onSelected = function()
                                local alert = lib.alertDialog({
                                    header = 'Confirmer la location',
                                    content = 'Voulez-vous vraiment louer ce véhicule ?',
                                    centered = true,
                                    cancel = true
                                })
                                if alert == "confirm" then
                                    ESX.TriggerServerCallback("updev:location", function(success, vehicleId)
                                        if success then
                                            RageUI.CloseAll()
                                            openmenu = false
                                    
                                            local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
                                            rentedVehicles[vehicleId] = {
                                                vehicle = vehicleId,
                                                rentTime = GetGameTimer()
                                            }
                                            
                                            CreateThread(function()
                                                while rentedVehicles[vehicleId] do
                                                    Wait(0)
                                                    local playerPed = PlayerPedId()
                                                    local playerVeh = GetVehiclePedIsIn(playerPed, false)
                                                    
                                                    if DoesEntityExist(vehicle) and playerVeh == vehicle then
                                                        local remainingTime = 900000 - (GetGameTimer() - rentedVehicles[vehicleId].rentTime)
                                                        
                                                        if remainingTime <= 0 then
                                                            ESX.ShowNotification("⏰ Le temps de location est écoulé. Le véhicule va être supprimé.")
                                                            if DoesEntityExist(vehicle) then
                                                                DeleteEntity(vehicle)
                                                            end
                                                            rentedVehicles[vehicleId] = nil
                                                            break
                                                        else
                                                            local minutes = math.floor(remainingTime / 60000)
                                                            local seconds = math.floor((remainingTime % 60000) / 1000)
                                                            local timeText = ("~HUD_COLOUR_PM_WEAPONS_PURCHASABLE~Temps restant: %02d:%02d"):format(minutes, seconds)
                                                            DrawTextFixed(0.9, 0.82, timeText)
                                                        end
                                                    elseif not DoesEntityExist(vehicle) then
                                                        rentedVehicles[vehicleId] = nil
                                                        break
                                                    end
                                                end
                                            end)
                                        end
                                    end, v.model, v.price, v.label, coords, heading, Config.LocationTime)
                                end
                            end
                        })
                    end
                end)

                Wait(0)
            end
        end)
    end
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local sleepTime = 500
        for _, location in pairs(Config.LocationCoords) do

            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, 280)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.5)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("Location de véhicule")
            EndTextCommandSetBlipName(blip)

            local distCloak = #(playerPos - location.coords)
            
            if distCloak <= 6.0 then
                sleepTime = 0
                if distCloak <= 1.5 then
                    DrawInstructionBarNotification(location.coords.x, location.coords.y, location.coords.z - 0.15, 'Appuyez sur [ ~g~E~w~ ] pour intéragir')
                    if IsControlJustPressed(0, 38) then
                        OpenLocationMenu(location.coordspawn, location.heading)
                    end
                    sleepTime = 0
                end
                
                DrawMarker(25, location.coords.x, location.coords.y, location.coords.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.55, 0.55, 0.55, 0, 0, 255, 100, false, true, 2, false, nil, nil, false)
            end
        end
        Wait(sleepTime)
    end
end)

function DrawTextFixed(x, y, text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end