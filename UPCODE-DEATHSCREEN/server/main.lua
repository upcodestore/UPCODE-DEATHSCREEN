RegisterServerEvent('UPCODE:hideUI')
AddEventHandler('UPCODE:hideUI', function(player, player2)
    TriggerClientEvent('UPCODE:hide',player)
end)