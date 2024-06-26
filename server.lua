ESX = exports["es_extended"]:getSharedObject()
local isRestartScheduled = false

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 300 then
        isRestartScheduled = true
    end
end)

RegisterCommand('dealer', function(source, args, rawcommand)
    if isRestartScheduled then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Drugs', description = 'Cannot use dealer command during scheduled restart.', duration = 5000, position = 'center-right', icon = 'pills'})
        return
    end
    xPlayer = ESX.GetPlayerFromId(source)
    drugToSell = {
        type = '',
        label = '',
        count = 0,
        i = 0,
        price = 0,
    }
    for k, v in pairs(Config.drugs) do
        item = xPlayer.getInventoryItem(k)
            
        if item == nil then
            return        
        end
            
        count = item.count
        drugToSell.i = drugToSell.i + 1
        drugToSell.type = k
        drugToSell.label = item.label
        
        if count >= 5 then
            drugToSell.count = math.random(1, 5)
        elseif count > 0 then
            drugToSell.count = math.random(1, count)
        end

        if drugToSell.count ~= 0 then
            drugToSell.price = drugToSell.count * v + math.random(1, 300)
            TriggerClientEvent('stasiek_selldrugsv2:findClient', source, drugToSell)
            break
        end
        
        if ESX.Table.SizeOf(Config.drugs) == drugToSell.i and drugToSell.count == 0 then
            --xPlayer.showNotification(Config.notify.nodrugs, 6)
            TriggerClientEvent('ox_lib:notify', source, {title = 'Drugs', description = Config.notify.nodrugs, duration = 8000, position = 'center-right', icon = 'pills'})
        end
    end
end, false)

RegisterServerEvent('stasiek_selldrugsv2:pay')
AddEventHandler('stasiek_selldrugsv2:pay', function(drugToSell)
    xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(drugToSell.type, drugToSell.count)
    if Config.account == 'money' then
        xPlayer.addMoney(drugToSell.price)
    else
        xPlayer.addAccountMoney(Config.account, drugToSell.price)
    end
end)

--[[RegisterServerEvent('stasiek_selldrugsv2:notifycops')
AddEventHandler('stasiek_selldrugsv2:notifycops', function(drugToSell)
    TriggerClientEvent('stasiek_selldrugsv2:notifyPolice', -1, drugToSell.coords)
end)

ESX.RegisterServerCallback('stasiek_selldrugsv2:getPoliceCount', function(source, cb)
    count = 0

    if Config.requiredCops then 
    for k, v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if xPlayer ~= nil then 
            if xPlayer.job.name == "police" then
                count = count + 1
            end
        end
    end
        cb(count)
    else
        cb(count)
    end
end)]]

RegisterServerEvent('stasiek_selldrugsv2:notifycops')
AddEventHandler('stasiek_selldrugsv2:notifycops', function(drugToSell)
    -- If the player has the police job, continue with the notification.
    TriggerClientEvent('stasiek_selldrugsv2:notifyPolice', -1, drugToSell.coords)
end)

ESX.RegisterServerCallback('stasiek_selldrugsv2:getPoliceCount', function(source, cb)
    local count = 0

    if Config.requiredCops then 
        local xPlayers = ESX.GetExtendedPlayers('job', 'police')

        for _, xPlayer in pairs(xPlayers) do
            count = count + 1
        end
        --print(count)

        cb(count)
    else
        cb(count)
    end
end)
