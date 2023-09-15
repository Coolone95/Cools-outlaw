local RSGCore = exports['rsg-core']:GetCoreObject()
local storeRobbed = false
local robberyStarted = false
local lockpickCooldownActive = false
local lockpickCooldowns = {}
local carthash = nil
local cargohash = nil
local lighthash = nil
local distance = nil
local bwvault1 = false
local bwdvault2 = false
local wagonSpawned = false
local spawnedPeds = {}
local isDropOffTextVisible = false
local isTimerRunning = false

---robplayer--
CreateThread(function()
    exports['rsg-target']:AddPlayer({
        options = {
            { 
                type = "client",
                event = "police:client:RobPlayer",
                icon = "fas fa-money",
                label = "Rob Player",
            },
        },
        distance = 3.0 
    })
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

-- Helper function to check if the player has enough moonshine in their inventory
function HasEnoughMoonshine(item, amount)
    return RSGCore.Functions.HasItem(item, amount)
end

function EnoughLawmenOnDuty(callback)
    local requiredLawmen = Config.MinimumLawmen -- Adjust the required number of lawmen if needed

    RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
        local currentLawmen = result
        if currentLawmen >= requiredLawmen then
            callback(true) -- There are enough lawmen, trigger the callback with true
        else
            callback(false) -- There are not enough lawmen, trigger the callback with false
        end
    end)
end

-- prompts and blips
Citizen.CreateThread(function()
    for delivery, v in pairs(Config.DeliveryLocations) do
        exports['rsg-core']:createPrompt(v.deliveryid, v.startcoords, RSGCore.Shared.Keybinds['J'], v.name, {
            type = 'client',
            event = 'cools-delivery:client:vehiclespawn',
            args = { v.deliveryid, v.cart, v.cartspawn, v.cargo, v.light, v.endcoords, v.showgps },
        })
        if v.showblip == true then
            local DeliveryBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.startcoords)
            SetBlipSprite(DeliveryBlip, GetHashKey(Config.Blip.blipSprite), true)
            SetBlipScale(DeliveryBlip, Config.Blip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, DeliveryBlip, Config.Blip.blipName)
        end
    end
end)


-- Function to show 3D text
function ShowDropOffText(coords, text)
    if not isDropOffTextVisible then
        DrawText3D(coords.x, coords.y, coords.z + 0.98, text)
        isDropOffTextVisible = true
    end
end

-- Function to hide 3D text
function HideDropOffText()
    if isDropOffTextVisible then
        isDropOffTextVisible = false
    end
end

-- Function to handle the timer
Citizen.CreateThread(function()
    while wagonSpawned do
        Citizen.Wait(0)
        local vehpos = GetEntityCoords(vehicle, true)

        if #(vehpos - endcoords) < 250.0 and deliveryLocation.showDropOffText and showDropOffText then
            DrawText3D(endcoords.x, endcoords.y, endcoords.z + 0.98, deliveryLocation.dropofftext)
        end

        if #(vehpos - endcoords) < 3.0 then
            if showgps == true then
                ClearGpsMultiRoute(endcoords)
            end
            endcoords = nil
            DeleteVehicle(vehicle)
            TriggerServerEvent('cools-robbery:server:removeItem', requiredItem, requiredMoonshineAmount)
            TriggerServerEvent('cools-delivery:server:givereward', cashreward)
            wagonSpawned = false
            showDropOffText = false
            exports['rsg-core']:HideText()
        end
    end

    if isTimerRunning then
        isTimerRunning = false
        exports['rsg-core']:HideText() -- Hide the timer text
    end
end)

RegisterNetEvent('cools-delivery:client:vehiclespawn')
AddEventHandler('cools-delivery:client:vehiclespawn', function(deliveryid, cart, cartspawn, cargo, light, endcoords, showgps)
    local deliveryLocation = nil
    for _, location in ipairs(Config.DeliveryLocations) do
        if location.deliveryid == deliveryid then
            deliveryLocation = location
            break
        end
    end

    if not deliveryLocation then
        print('Error: No delivery location found for the specified delivery ID')
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerInVehicle = IsPedInAnyVehicle(playerPed)

    local requiredMoonshineAmount = deliveryLocation.itemamount
    local requiredItem = deliveryLocation.sellItem
    local hasEnoughItem = HasEnoughMoonshine(requiredItem, requiredMoonshineAmount)

    if hasEnoughItem and not playerInVehicle then
        local alertMessage = deliveryLocation.notify
        TriggerServerEvent('cools-robbery:server:alertlaw', alertMessage)
        TriggerServerEvent('police:server:policeAlert', deliveryLocation.lawalert)

        local playerData = RSGCore.Functions.GetPlayerData()

        if playerData and playerData.charinfo.firstname and playerData.charinfo.lastname and playerData.citizenid then
            local playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
            local playerCID = playerData.citizenid
            local soldItem = deliveryLocation.sellItem or "Unknown Item"
            local locationName = deliveryLocation.name
            local webhookTitle = Config.webhooktitle

            local discordMessage = string.format("%s\nPlayer: %s (CID: %s)\nItem Sold: %s\nLocation: %s",
                webhookTitle, playerName, playerCID, soldItem, locationName)

            TriggerServerEvent('cools-robbery:server:discordAlert', discordMessage)
        else
            print("Error: Missing required fields in player data")
        end

        local carthash = GetHashKey(cart)
        local cargohash = GetHashKey(cargo)
        local lighthash = GetHashKey(light)
        local cashreward = deliveryLocation.price

        RequestModel(carthash, cargohash, lighthash)
        while not HasModelLoaded(carthash, cargohash, lighthash) do
            RequestModel(carthash, cargohash, lighthash)
            Citizen.Wait(0)
        end

        local coords = vector3(cartspawn.x, cartspawn.y, cartspawn.z)
        local heading = cartspawn.w
        local vehicle = CreateVehicle(carthash, coords, heading, true, false)
        SetVehicleOnGroundProperly(vehicle)
        Wait(200)
        SetModelAsNoLongerNeeded(carthash)
        Citizen.InvokeNative(0xD80FAF919A2E56EA, vehicle, cargohash)
        Citizen.InvokeNative(0xC0F0417A90402742, vehicle, lighthash)
        TaskEnterVehicle(playerPed, vehicle, 10000, -1, 1.0, 1, 0)

        local randomIndex = math.random(#Config.DeliveryLocations) -- Choose a random index
        local randomEndCoords = Config.DeliveryLocations[randomIndex].endcoords -- Use the randomly selected endcoords

        if showgps == true then
            StartGpsMultiRoute(GetHashKey("COLOR_RED"), true, true)
            AddPointToGpsMultiRoute(randomEndCoords)
            SetGpsMultiRouteRender(true)
        end

        local wagonSpawned = true
        local timer = deliveryLocation.deliveryTime * 60
        local countdownInterval = 60
        local remainingMinutes = 0
        local timerActive = true
        local showDropOffText = true
        local isTimerRunning = false -- Add this line to track if the timer is running

        Citizen.CreateThread(function()
            while timer > 0 do
                Citizen.Wait(1000)
                timer = timer - 1

                local remainingDisplay = ""

                if timer % countdownInterval == 0 then
                    remainingMinutes = math.floor(timer / 60)
                    remainingDisplay = remainingMinutes .. ' mins'

                    if remainingMinutes == 1 then
                        remainingDisplay = timer .. ' secs'
                    end

                    if deliveryLocation.showtimer then
                        exports['rsg-core']:DrawText('Time remaining ' .. remainingDisplay .. '!', deliveryLocation.timerplacement)
                    end
                elseif timer <= 60 then
                    remainingDisplay = timer .. ' secs'

                    if deliveryLocation.showtimer then
                        exports['rsg-core']:DrawText('Time remaining ' .. remainingDisplay .. '!', deliveryLocation.timerplacement)
                    end
                end
            end

            if wagonSpawned then
                if showgps == true then
                    ClearGpsMultiRoute(randomEndCoords) -- Use the randomly selected endcoords
                end
                randomEndCoords = nil
                DeleteVehicle(vehicle)
                TriggerServerEvent('cools-robbery:server:removeItem', requiredItem, requiredMoonshineAmount)
                RSGCore.Functions.Notify(deliveryLocation.deliveryfailalert, 'error', 5000, 'top-right')
                exports['rsg-core']:HideText()
            end

            isTimerRunning = false -- Set the timer flag to false when the timer ends
        end)

        Citizen.CreateThread(function()
            while wagonSpawned do
                Citizen.Wait(0)
                local vehpos = GetEntityCoords(vehicle, true)

                if #(vehpos - randomEndCoords) < 250.0 and deliveryLocation.showDropOffText and showDropOffText then
                    DrawText3D(randomEndCoords.x, randomEndCoords.y, randomEndCoords.z + 0.98, deliveryLocation.dropofftext) -- Use randomEndCoords for positioning
                end

                if #(vehpos - randomEndCoords) < 3.0 then
                    if showgps == true then
                        ClearGpsMultiRoute(randomEndCoords)
                    end
                    randomEndCoords = nil
                    DeleteVehicle(vehicle)
                    TriggerServerEvent('cools-robbery:server:removeItem', requiredItem, requiredMoonshineAmount)
                    TriggerServerEvent('cools-delivery:server:givereward', cashreward)
					TriggerServerEvent('police:server:policeAlert1', 'Delivery completed!')
                    wagonSpawned = false
                    showDropOffText = false
                    isTimerRunning = false -- Set the timer flag to false when the delivery is completed
                    exports['rsg-core']:HideText()
                end
            end
        end)

    else
        RSGCore.Functions.Notify(deliveryLocation.alert, 'error', 5000, 'top-right')
    end
end)




for _, registerModel in ipairs(Config.register) do
    exports['rsg-target']:AddTargetModel(registerModel, {
        options = {
            {
                icon = '',
                label = Config.label1,
                targeticon = 'fas fa-eye',
                action = function()
                    if not lockpickCooldownActive then
                        RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
                            local currentLawmen = result
                            if currentLawmen >= Config.MinimumLawmen then
                                TriggerEvent('cools-robbery:server:startrobbery')
                            else
                                RSGCore.Functions.Notify('Not enough law enforcement officers on duty to proceed with the robbery.', 'error', 5000, 'top-right')
                            end
                        end)
                    else
                        RSGCore.Functions.Notify('Lockpick is on cooldown. Wait for the cooldown to finish before attempting again.', 'error', 5000, 'top-right')
                    end
                end
            },
        }
    })
end


local lastRobberyTimestamp = {}

local lastRobberyTimestamp = {} -- Table to store the last robbery time for each player
local globalCooldown = 2 * 60 * 60 -- 2 hours in seconds

RegisterNetEvent('cools-robbery:server:startrobbery')
AddEventHandler('cools-robbery:server:startrobbery', function()
    local src = source

    local hasLockpick = RSGCore.Functions.HasItem('lockpick', 1)

    if hasLockpick then
        -- Check if the player's cooldown has expired
        if lastRobberyTimestamp[src] ~= nil then
            local currentTime = os.time()
            local timeSinceLastRobbery = currentTime - lastRobberyTimestamp[src]

            if timeSinceLastRobbery < globalCooldown then
                local remainingTime = globalCooldown - timeSinceLastRobbery
                TriggerClientEvent('cools-robbery:client:showCooldown', src, remainingTime)
                return
            end
        end

        TriggerEvent('cools-robbery:client:startlockpick', src)
        TriggerServerEvent('cools-robbery:server:removeItem', 'lockpick', 1)

        RegisterNetEvent('cools-robbery:client:lockpickFinish')
        AddEventHandler('cools-robbery:client:lockpickFinish', function(success)
            if success then
                local storeName = "Store" 
                local alertMessage = "Someone is robbing the Store!"
                TriggerServerEvent('cools-robbery:server:alertlaw', alertMessage)
                TriggerServerEvent('police:server:policeAlert', 'A store is being robbed!')
                SendDiscordNotification(alertMessage) -- Send Discord notification


                lastRobberyTimestamp[source] = os.time()

                RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
                    CurrentLawmen = result
                    if CurrentLawmen >= Config.MinimumLawmen then
                        TriggerEvent('cools-robbery:client:policealert', alertMessage)

                        
                    else
                        
                    end
                end)

                TriggerEvent('cools-robbery:client:startCooldown', source)
            else

                RSGCore.Functions.Notify('Lockpick unsuccessful. Try again.', 'error', 5000, 'top-right')
            end
        end)
    else
        RSGCore.Functions.Notify('You need a lockpick to start the robbery.', 'error', 5000, 'top-right')
    end
end)




local lockpickCooldowns = {} -- Table to store player cooldown timestamps
local globalCooldown = 60 -- Cooldown time in seconds

RegisterNetEvent('cools-robbery:client:startlockpick')
AddEventHandler('cools-robbery:client:startlockpick', function()
    local _source = source
    local playerPed = PlayerPedId()

    local playerCoords = GetEntityCoords(playerPed)
    local isRobberyInProgress = true

    TriggerEvent('rsg-lockpick:client:openLockpick', function(success) -- Added callback function
        if success then
            if not lockpickCooldowns[_source] or (GetGameTimer() - lockpickCooldowns[_source]) > globalCooldown * 1000 then
                lockpickCooldowns[_source] = GetGameTimer() -- Set cooldown timestamp

                -- Get player data
                local playerData = RSGCore.Functions.GetPlayerData()
                if not playerData then
                    return
                end

                -- Construct player's name and CID
                local playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
                local playerCID = playerData.citizenid

                -- Construct the alert message
                local alertMessage = string.format("Player: %s (CID: %s) is attempting to rob a store!", playerName, playerCID)

                -- Trigger the server event to send the Discord alert
                TriggerServerEvent('cools-robbery:server:discordAlert', alertMessage)
                TriggerServerEvent('police:server:policeAlert', 'A store is being robbed!')

                if Config.movement then
                -- Freeze the player's position during the animation
                FreezeEntityPosition(playerPed, true)

                -- Start the animation with the progress bar
                RequestAnimDict("mech_pickup@loot@cash_register@open")
                while not HasAnimDictLoaded("mech_pickup@loot@cash_register@open") do
                    Wait(0)
                end
                TaskPlayAnim(playerPed, "mech_pickup@loot@cash_register@open", "rifle_grab_open_base", 8.0, -8.0, -1, 1, 0, false, false, false)

                -- Start the progress bar for robbery
                RSGCore.Functions.Progressbar("rob_register", Config.progress, Config.timer * 60 * 1000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Completion Callback
                    -- Stop the animation and unfreeze the player when the progress bar completes
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)


                    if isRobberyInProgress then
                        TriggerServerEvent('cools-robbery:server:rewardloot')
                    end
                end)

                Citizen.CreateThread(function()
                    while isRobberyInProgress do
                        Citizen.Wait(1000)
                        local newCoords = GetEntityCoords(playerPed)
                        local distance = #(newCoords - playerCoords)

                        if distance > 10.0 then
                            isRobberyInProgress = false
                            ClearPedTasks(playerPed)
                            FreezeEntityPosition(playerPed, false)
                            SetEntityCoordsNoOffset(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
                            break
                        end
                    end
                end)
            else
                -- No animation, players can move around freely
                RSGCore.Functions.Progressbar("rob_register", Config.progress, Config.timer * 60 * 1000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function() -- Completion Callback
                    if isRobberyInProgress then
                        TriggerServerEvent('cools-robbery:server:rewardloot')
                    end
                end)
            end
        else
            -- Display a notification to the player indicating lockpicking was unsuccessful
             local remainingCooldown = math.ceil((lockpickCooldowns[_source] + globalCooldown * 1000 - GetGameTimer()) / 1000)
                RSGCore.Functions.Notify('Lockpick is on cooldown. Wait ' .. remainingCooldown .. ' seconds before attempting again.', 'error', 5000, 'top-right')
            end
        else
            -- Display a notification to the player indicating lockpicking was unsuccessful
            RSGCore.Functions.Notify('Lockpicking was unsuccessful.', 'error', 5000, 'top-right')
        end
    end)
end)


function lockpickFinish(success)
    if success then
		RSGCore.Functions.Notify('lockpick successful', 'success')
		Citizen.InvokeNative(0x6BAB9442830C7F53, 2117902999, 0)
		lockpicked = true
		robberystarted = true
		handleLockdown()
		lockdownactive = true
    else
        RSGCore.Functions.Notify('lockpick unsuccessful', 'error')
    end
end

-- Display a notification when the police are alerted
RegisterNetEvent('cools-robbery:client:policealert')
AddEventHandler('cools-robbery:client:policealert', function(alertMessage)
    RSGCore.Functions.Notify(alertMessage, 'error', 5000, 'top-right')
	
end)

-- Callback to get the number of law enforcement NPCs
RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
    CurrentLawmen = result
    if CurrentLawmen >= Config.MinimumLawmen then
        -- There are enough law enforcement NPCs to trigger the police alert
        -- Implement the logic to alert the law
        TriggerEvent('cools-robbery:client:policealert')

        -- You can also add code here to increase the player's wanted level or spawn police NPCs, depending on your game mode's mechanics.
    else
        -- There are not enough law enforcement NPCs, so you can decide to handle the situation differently (optional).
    end
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

---peds--

Citizen.CreateThread(function()
    for _, deliveryLocation in pairs(Config.DeliveryLocations) do
        if deliveryLocation.model and deliveryLocation.coords then
            local spawnedPed = NearPed(deliveryLocation.model, deliveryLocation.coords)
        end
    end
end)

function NearPed(model, coords)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(50)
    end
    local spawnedPed = CreatePed(model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    Citizen.InvokeNative(0x283978A15512B2FE, spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    Citizen.InvokeNative(0xC80A74AC829DDD92, spawnedPed, GetPedRelationshipGroupHash(spawnedPed))
    Citizen.InvokeNative(0xBF25EB89375A37AD, 1, GetPedRelationshipGroupHash(spawnedPed), `PLAYER`)
    if Config.Debug then
        local relationship = Citizen.InvokeNative(0x9E6B70061662AE5C, GetPedRelationshipGroupHash(spawnedPed), `PLAYER`)
        print(relationship)
    end
    if Config.FadeIn then
        for i = 0, 255, 51 do
            Citizen.Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end
    return spawnedPed
end


--- npc drug---
local group
local promptActive = false
local SellableItems = Config.Sellable

function Sell()
    local str = 'Try to sell Drugs'
    sellprompt = PromptRegisterBegin()
    PromptSetControlAction(sellprompt, 0x2CD5343E)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(sellprompt, str)
    PromptSetEnabled(sellprompt, true)
    PromptSetVisible(sellprompt, true)
    PromptSetHoldMode(sellprompt, true)
    PromptSetGroup(sellprompt, group)
    PromptRegisterEnd(sellprompt)
    promptActive = true
end

local selling = false
local active = false
local cooldown = 0
local oldped = 0
local target = 0
local currpos = 0

function startCooldown()
    if cooldown > 0 then
        Citizen.CreateThread(function()
            while cooldown > 0 do
                Wait(0)
                cooldown = cooldown - 1
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(10)
        local id, id2 = GetPlayerTargetEntity(PlayerId())
        if id2 ~= 0 and id2 ~= nil then
            target = id2

            if active == false and
                not IsPedAPlayer(target) and
                IsPedOnMount(PlayerPedId()) == false and
                DoesEntityExist(target) and
                IsPedOnMount(target) == false and
                Vdist(GetEntityCoords(PlayerPedId()), GetEntityCoords(target), true) < 1.5 and
                IsPedHuman(target) and
                IsPedDeadOrDying(target) == false and
                target ~= oldped and
                cooldown == 0 and
                not promptActive then

                group = PromptGetGroupIdForTargetEntity(target)

                Sell()  -- Call the function to create the prompt

                active = true
            end

            if PromptHasHoldModeCompleted(sellprompt) then
                PromptDelete(sellprompt)
                Wait(500)

                local sellableKeys = {}
                for key, _ in pairs(Config.Sellable) do
                    table.insert(sellableKeys, key)
                end
                local randomItemIndex = math.random(1, #sellableKeys)
                local itemName = sellableKeys[randomItemIndex]

                local itemInfo = {
                    item = itemName,
                    label = Config.Sellable[itemName].label,
                    price = Config.Sellable[itemName].price,
                    amount = 1
                }

                local playerCoords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('cools-outlaw:Sell', itemInfo, playerCoords)

                oldped = target
                promptActive = false
                active = false
                cooldown = 400
                startCooldown()
            end
        else
            Wait(200)
            if promptActive then
                PromptDelete(sellprompt)
                promptActive = false
            end
            active = false
        end
    end
end)

RegisterNetEvent('cools-outlaw:AlertPolice')
AddEventHandler('cools-outlaw:AlertPolice', function(title, message)
    TriggerServerEvent('police:server:PoliceAlertMessage', title, message)
end)

RegisterNetEvent('cools-npcsell:animation')
AddEventHandler('cools-npcsell:animation', function()
    local pid = PlayerPedId()
    RequestAnimDict("script_rc@chrb@ig1_visit_clerk")
    while not HasAnimDictLoaded("script_rc@chrb@ig1_visit_clerk") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(pid, "script_rc@chrb@ig1_visit_clerk", "arthur_gives_money_player", 1.0, 8.0, -1, 1, 0, false, false, false)
    Wait(2000)
    ClearPedTasks(pid)
end)












