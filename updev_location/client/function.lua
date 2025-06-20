function DrawInstructionBarNotification(x, y, z, text)
	local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))

	local distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, false)

	if distance <= 6 then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(true)
		AddTextComponentString(text)
		SetDrawOrigin(x,y,z, 0)
		DrawText(0.0, 0.0)
		local factor = (string.len(text)) / 370
		DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
		ClearDrawOrigin()
	end
end

function CreatePedOnPos(name, ped, x,y,z, heading, scenario, call)
    name = name or ""

    local hash = GetHashKey(ped)

    RequestModel(hash)

    while not HasModelLoaded(hash) do Wait(5) RequestModel(hash) end

    ped = CreatePed(1, ped, x, y, z, heading, false, true)

    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    if (scenario) then
        TaskStartScenarioInPlace(ped, scenario, 0, false)
    end

    if call then
        call(ped)
    end
end