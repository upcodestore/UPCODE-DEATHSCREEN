if Configuration.Framework == 'esx' then

    RegisterNetEvent('UPCODE:revive')
    AddEventHandler('UPCODE:revive', function()
        local ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, Configuration.RespawnCoords.x, Configuration.RespawnCoords.y, Configuration.RespawnCoords.z, false, false, false)
        NetworkResurrectLocalPlayer(Configuration.RespawnCoords.x, Configuration.RespawnCoords.y, Configuration.RespawnCoords.z, Configuration.RespawnCoords[4], true, false)
        SetPlayerInvincible(ped, false)
        ClearPedBloodDamage(ped)
      
        TriggerEvent('esx_basicneeds:resetStatus')
        TriggerServerEvent('esx:onPlayerSpawn')
        TriggerEvent('esx:onPlayerSpawn')
        TriggerEvent('playerSpawned')
        TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
    end)

else

end


Call = function()
    print(GetEntityCoords(PlayerPedId()))
    print("ALERT AMBULANCE")
end