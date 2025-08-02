-- MiningHandler.lua (UPDATED VERSION)
-- Replace your existing MiningHandler in ServerScriptService

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import mining module
local MiningModule = require(ServerStorage.GameModules.MiningModule)

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MiningRemote = RemoteEvents:WaitForChild("ResourceMining")

-- Initialize mining system
MiningModule.Initialize()

-- Handle mining-related remote events
MiningRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "SellResource" then
        local resourceType = data.ResourceType
        local amount = data.Amount or 1
        
        local coinsEarned = MiningModule.SellResources(player, resourceType, amount)
        if coinsEarned then
            -- Notify client of successful sale
            MiningRemote:FireClient(player, "SaleComplete", {
                ResourceType = resourceType,
                Amount = amount,
                CoinsEarned = coinsEarned
            })
            
            -- Update player HUD
            local PlayerSpawnRemote = RemoteEvents:WaitForChild("PlayerSpawn")
            local PlayerDataModule = require(ServerStorage.GameModules.PlayerDataModule)
            local playerData = PlayerDataModule.GetPlayerData(player)
            if playerData then
                local clientData = {
                    Guild = playerData.Guild,
                    Level = playerData.Level,
                    Coins = playerData.Coins,
                    Stats = playerData.Stats,
                    Equipment = playerData.Equipment
                }
                PlayerSpawnRemote:FireClient(player, "UpdatePlayerData", clientData)
            end
            
            print("Player " .. player.Name .. " sold " .. amount .. " " .. resourceType .. " for " .. coinsEarned .. " coins")
        else
            MiningRemote:FireClient(player, "SaleError", "Not enough resources or invalid sale")
        end
        
    elseif action == "GetInventory" then
        local inventory = MiningModule.GetPlayerInventory(player)
        MiningRemote:FireClient(player, "InventoryUpdate", inventory)
        
    elseif action == "StopMining" then
        MiningModule.StopMining(player)
    end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    -- Stop any active mining sessions
    MiningModule.StopMining(player)
end)

print("Mining system handler loaded successfully!")