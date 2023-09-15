local RSGCore = exports['rsg-core']:GetCoreObject()
local globalCooldown = 7200 -- 2 hours in seconds
local lockpickCooldowns = {}
local Robbed_Banks = {}

RegisterNetEvent('cools-robbery:server:sendNotification')
AddEventHandler('cools-robbery:server:sendNotification', function(targetSource, notificationType)
    local notificationMessage = ""

    if notificationType == "success" then
        notificationMessage = "Lockpick successful!"
    elseif notificationType == "unsuccessful" then
        notificationMessage = "Lockpick unsuccessful. Try again."
    elseif notificationType == "no_lockpick" then
        notificationMessage = "You need a lockpick to start the robbery."
    end

    TriggerClientEvent("ak_notification:Left", targetSource, notificationMessage)
end)

RegisterServerEvent('cools-robbery:server:discordAlert')
AddEventHandler('cools-robbery:server:discordAlert', function(message)
    local discordWebhook = Config.webhook

    local headers = {
        ['Content-Type'] = 'application/json'
    }

    local discordMessage = {
        embeds = {
            {
                description = message,
                color = 16711680 -- Red color in decimal (you can use other colors as well)
            }
        }
    }

    PerformHttpRequest(discordWebhook, function(statusCode, response, headers)
        if statusCode ~= 204 then
            print("Discord webhook request failed! Status code: " .. statusCode)
        end
    end, 'POST', json.encode(discordMessage), headers)
end)

RegisterNetEvent('cools-delivery:server:givereward')
AddEventHandler('cools-delivery:server:givereward', function(cashreward)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', cashreward)
end)


RegisterNetEvent('cools-robbery:client:showCooldown')
AddEventHandler('cools-robbery:client:showCooldown', function(remainingTime)
    local src = source
    if not lockpickCooldowns[src] then
        lockpickCooldowns[src] = true
        Citizen.CreateThread(function()
            while remainingTime > 0 do
                RSGCore.Functions.Notify('You must wait ' .. math.floor(remainingTime / 60) .. ' minutes and ' .. (remainingTime % 60) .. ' seconds before starting another robbery.', 'error', 5000, 'top-right')
                Citizen.Wait(60000) -- Wait 1 minute
                remainingTime = remainingTime - 60
            end
            lockpickCooldowns[src] = false
        end)
    end
end)



RegisterServerEvent('cools-robbery:server:startCooldown')
AddEventHandler('cools-robbery:server:startCooldown', function(playerSrc)
    local src = source
    lockpickCooldowns[src] = true
    Citizen.Wait(cooldownDuration * 1000) -- Wait for the cooldown duration (in milliseconds)
    lockpickCooldowns[src] = false

    local remainingTime = 0 -- No remaining time as the cooldown has finished
    SendCooldownNotification(playerSrc, remainingTime)
end)


---store loot---
RegisterServerEvent('cools-robbery:server:rewardloot')
AddEventHandler('cools-robbery:server:rewardloot', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local chance = math.random(1, 100)
    local moneyRewardType = Config.MoneyRewardType 
    local moneyRewardAmount = Config.MoneyRewardAmount 

    -- Add money reward
    Player.Functions.AddMoney(moneyRewardType, moneyRewardAmount, "store-robbery")
    TriggerClientEvent('RSGCore:Notify', src, 'You received ' .. moneyRewardAmount .. ' ' .. moneyRewardType .. ' as a reward!', 'primary')
    Wait(1000) -- Delay to prevent overlapping notifications

    if chance <= 50 then
        -- small reward
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        
        -- add items
        Player.Functions.AddItem(item1, Config.SmallRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")

        TriggerClientEvent('rNotify:NotifyLeft', source, "You Received", "medium loot", "generic_textures", "tick", 4000)

    elseif chance >= 51 and chance <= 80 then
        -- medium reward
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item2 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        
        -- add items
        Player.Functions.AddItem(item1, Config.MediumRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")
        Player.Functions.AddItem(item2, Config.MediumRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item2], "add")

		TriggerClientEvent('rNotify:NotifyLeft', source, "You Received", "medium loot", "generic_textures", "tick", 4000)

    else
        -- large reward
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item2 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item3 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        
        -- add items
        Player.Functions.AddItem(item1, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")
        Player.Functions.AddItem(item2, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item2], "add")
        Player.Functions.AddItem(item3, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item3], "add")

        TriggerClientEvent('rNotify:NotifyLeft', source, "You Received", "medium loot", "generic_textures", "tick", 4000)
    end
end)


RegisterServerEvent('cools-delivery:server:checkLawEnforcement')
AddEventHandler('cools-delivery:server:checkLawEnforcement', function(callback)
    RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
        local currentLawmen = result
        if currentLawmen >= Config.MinimumLawmen then
            -- There are enough law enforcement NPCs on duty, trigger the callback with true
            callback(true)
        else
            -- There are not enough law enforcement NPCs on duty, trigger the callback with false
            callback(false)
        end
    end)
end)



RegisterServerEvent('cools-robbery:server:alertlaw')
AddEventHandler('cools-robbery:server:alertlaw', function(alertMessage)
    TriggerClientEvent('cools-robbery:client:policealert', source, alertMessage)
end)


RegisterNetEvent('cools-robbery:server:removeItem')
AddEventHandler('cools-robbery:server:removeItem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove')
end)

function SendCooldownNotification(playerSrc, remainingTime)
    TriggerClientEvent('cools-robbery:client:showCooldown', playerSrc, remainingTime)
end

function IsPlayerInCooldown(playerSrc)
    local currentTime = os.time()
    if lastRobberyTimestamp[playerSrc] and (currentTime - lastRobberyTimestamp[playerSrc] < globalCooldown) then
        return true, globalCooldown - (currentTime - lastRobberyTimestamp[playerSrc])
    end
    return false, 0
end





exports('IsPlayerInCooldown', IsPlayerInCooldown)

-- sell drugs--
local salesCounter = {}

RegisterNetEvent('cools-outlaw:Sell')
AddEventHandler('cools-outlaw:Sell', function(itemInfo)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    -- Validate the player and the item to be sold
    if not Player or not itemInfo or not itemInfo.item or not itemInfo.amount then
        TriggerClientEvent('ak_notification:Left', src, 'Error', 'Failed to sell item.', 5000, 'error')
        return
    end

    local hasItem = Player.Functions.GetItemByName(itemInfo.item)

    -- Check if the player has the item and the required amount
    if hasItem and hasItem.amount >= itemInfo.amount then
        local price = itemInfo.price * itemInfo.amount

        Player.Functions.RemoveItem(itemInfo.item, itemInfo.amount)
        Player.Functions.AddMoney('cash', price, "sold-item")
        
        TriggerClientEvent('ak_notification:Left', src, 'Offer', 'Offer accepted! Sold ' .. itemInfo.amount .. 'x ' .. itemInfo.item .. ' for $' .. price, 5000, 'success')
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemInfo.item], "remove")

        -- Trigger the sell animation on client side
        TriggerClientEvent('cools-npcsell:animation', src)

        -- Increase the sales counter for the player
        if not salesCounter[src] then
            salesCounter[src] = 0
        end
        salesCounter[src] = salesCounter[src] + 1

        -- Alert the police if the player has made 3 sales
        if salesCounter[src] >= 3 then
            local playerCoords = GetEntityCoords(GetPlayerPed(src))
            TriggerEvent('police:server:policeAlert', 'Someone is selling drugs!', playerCoords)

            -- Notify the player that law enforcement has been alerted
            TriggerClientEvent('ak_notification:Left', src, 'Alert', 'Law enforcement has been notified!', 5000, 'error')

            salesCounter[src] = 0  -- reset the counter
        end
    else
        TriggerClientEvent('ak_notification:Left', src, 'Offer', 'You don\'t have enough of this item to sell.', 5000, 'error')
    end
end)



RegisterNetEvent('cools-outlaw:AlertPolice')
AddEventHandler('cools-outlaw:AlertPolice', function(title, message)
    TriggerServerEvent('police:server:PoliceAlertMessage', title, message)
end)











