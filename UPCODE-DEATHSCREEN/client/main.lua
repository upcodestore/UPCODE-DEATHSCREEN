local countdownMinutes = 1
local countdownSeconds = countdownMinutes * 60
local maxCountdownSeconds = countdownSeconds
local isDead = false  
local closetplayer = false 
local CamActive = false
local camactiveNumber = 1
local pause = false
local timeexpired = false
local isUIVisible = false

if Configuration.Framework == 'esx' then 
    ESX = exports[Configuration.trigger]:getSharedObject()

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        ESX.PlayerData = xPlayer
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        ESX.PlayerData.job = job
    end)

else
    QBCore = exports[Configuration.trigger]:GetCoreObject()

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function(xPlayer)
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

end


Citizen.CreateThread(function()
    while true do
        if Configuration.Framework == 'esx' then 
            playerJobName = ESX.PlayerData.job.name
        else
            playerJobName = PlayerData.job.name
        end

        if playerJobName == "ambulance" then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            for i = 1, 255, 1 do
                if GetPlayerServerId(PlayerId()) ~= GetPlayerServerId(i) then
                    if NetworkIsPlayerActive(i) then
                        local coords = GetEntityCoords(GetPlayerPed(i))
                        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true) <= 2 then
                            if GetEntityHealth(GetPlayerPed(i)) <= 0 then
                                sleep = 2000
                                hintToDisplay("[E] - HELP", vec3(coords.x, coords.y, coords.z)) 
                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent("UPCODE:hideUI", GetPlayerServerId(i),GetPlayerServerId(PlayerId()))
                                end
                                sleep = 1 
                            else
                                sleep = 5000
                            end
                        end    
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if isDead then
            countdownSeconds = countdownSeconds - 1
        else
            countdownSeconds = countdownMinutes * 60
        end
    end
end)

CreateThread(function()
    while true do
        if CamActive then
            SetUseHiDof()
        else
            Wait(1000)
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if not pause then
            local minutes = math.floor(countdownSeconds / 60)
            local seconds = countdownSeconds % 60
            
            progress = (countdownSeconds / maxCountdownSeconds) * 100

            if GetEntityHealth(PlayerPedId()) == 0 and countdownSeconds ~= 0 then 
                if camactiveNumber == 1 then
                    camactiveNumber = 0
                    CreateCam()
                end
                local PedKiller = GetPedSourceOfDeath(PlayerPedId())
                local killerid = NetworkGetPlayerIndexFromPed(PedKiller)
        
                if IsEntityAVehicle(PedKiller) and IsEntityAPed(GetVehiclePedIsIn(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
                    killerid = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
                end
                
                if (killerid == -1) then
                    reasons = 'suicide'
                elseif (killerid == nil) then
                    reasons = 'unkown'
                elseif (killerid ~= -1) then       
                    reasons = GetPlayerName(killerid)
                end
                SetNuiFocus(true, false)
                SendNUIMessage({status = true, time = minutes, time2 = seconds, progress = progress, reason = reasons})
                isDead = true
                if Configuration.HideMinimap then DisplayRadar(false) end
            end
        end
        Citizen.Wait(1000)
    end
end)

CreateThread(function()
    while true do
        if countdownSeconds <= 0 then
            countdownSeconds = countdownMinutes * 60
            timeexpired = true
            TriggerEvent('UPCODE:REVIVE')
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('UPCODE:REVIVE', function()
    camactiveNumber = 1
    RenderScriptCams(false, true, 500, 1, 0)
    DestroyCam(CamHandle, false)
    CamHandle = nil
    isDead = false
    if not isUIVisible then
        pause = false
    end
    SetNuiFocus(false, false)
    SendNUIMessage({status = false, time = 0})
    if Configuration.HideMinimap then DisplayRadar(true) end
    if timeexpired or surrender then
        TriggerEvent('UPCODE:revive')
        timeexpired = false
        surrender = false
    end
end)


RegisterNetEvent('UPCODE:hide')
AddEventHandler('UPCODE:hide', function() 
    Notify("info", "Alguien te esta ayudando.", time)
    isUIVisible = true
    if isUIVisible then
        pause = true
        isUIVisible = false
    end
    SetNuiFocus(false, false)
    SendNUIMessage({status = false, time = 0})
end)

RegisterNUICallback('press', function(data)

    if data.action == 'call' then
        if not again then
            again = true
            Call()
            Wait(Configuration.AgainCallTime)  
            again = false
        end

    elseif data.action == 'surrender' then
        surrender = true
        TriggerEvent('UPCODE:REVIVE')
    end

end)

CreateCam = function()
    Wait(2000)
    local playerPed = PlayerPedId()
    local pedHeading = GetEntityHeading(playerPed) + 180.0
    local camCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.5, 0.0, 0.0)
    camHandle = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', camCoords.x, camCoords.y, camCoords.z + 2.5, -87.5, 0.0, 100.0, 80.0, false, 0)
    SetCamUseShallowDofMode(camHandle, true)
    SetCamNearDof(camHandle, 0.2)
    SetCamFarDof(camHandle, 5.0)
    SetCamDofStrength(camHandle, 1.0)
    SetCamActive(camHandle, true)
    RenderScriptCams(true, true, 500, true, true)
    CamActive = true
end

Notify = function(type, text, time)

    -- time = 10000
    -- if type == 'success' then
    --     exports["Venice-Notification"]:Notify(text, time, "check", options)
    -- elseif type == 'error' then
    --     exports["Venice-Notification"]:Notify(text, time, "error", options)
    -- elseif type == 'info' then
    --     exports["Venice-Notification"]:Notify(text, time, "info", options)
    -- end


    if Configuration.Framework == 'esx' then 

        ESX.ShowNotification(text)
    
    else
        QBCore.Functions.Notify(text)
    end
end

hintToDisplay = function(text,coords)
	local dist = Vdist(coords.x,coords.y,coords.z,GetEntityCoords(PlayerPedId(-1)))
    if dist < 1.5 then
        DrawText3Ds(coords.x,coords.y,coords.z + 1.05,text, 0, 0.1, 0.1,255)
    else
        DrawText3Ds(coords.x,coords.y,coords.z + 1.05,text, 0, 0.1, 0.1,100)
    end
end

DrawText3Ds = function (x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end