-- PlayerJoinHandler.lua (CORRECTED VERSION)
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local PlayerDataModule = require(ServerStorage.GameModules.PlayerDataModule)
local GuildModule = require(ServerStorage.GameModules.GuildModule)

-- Remote Events (FIXED: Now using ReplicatedStorage)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GuildSelectionRemote = RemoteEvents:WaitForChild("GuildSelection")
local PlayerSpawnRemote = RemoteEvents:WaitForChild("PlayerSpawn")

-- Player join handling
Players.PlayerAdded:Connect(function(player)
    print("Player joined: " .. player.Name)
    
    -- Load player data
    local playerData = PlayerDataModule.LoadPlayerData(player)
    
    -- Wait for character to spawn
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Give time for character to fully load
        
        if playerData.FirstTime or not playerData.Guild then
            -- First time player - show guild selection
            print("First time player: " .. player.Name)
            ShowGuildSelection(player)
        else
            -- Returning player - assign to guild and spawn
            print("Returning player: " .. player.Name .. " - Guild: " .. playerData.Guild)
            GuildModule.AssignPlayerToGuild(player, playerData.Guild)
            GuildModule.SpawnPlayerInGuild(player, playerData.Guild)
            
            -- Send player data to client
            SendPlayerDataToClient(player)
        end
    end)
    
    -- Handle player leaving
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            PlayerDataModule.CleanupPlayerData(player)
        end
    end)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    PlayerDataModule.CleanupPlayerData(player)
end)

function ShowGuildSelection(player)
    -- Get available guilds
    local availableGuilds = GuildModule.GetAvailableGuilds()
    
    -- Send guild data to client for selection UI
    GuildSelectionRemote:FireClient(player, "ShowSelection", availableGuilds)
end

function SendPlayerDataToClient(player)
    local playerData = PlayerDataModule.GetPlayerData(player)
    if playerData then
        -- Send essential player data to client
        local clientData = {
            Guild = playerData.Guild,
            Level = playerData.Level,
            Coins = playerData.Coins,
            Stats = playerData.Stats,
            Equipment = playerData.Equipment
        }
        PlayerSpawnRemote:FireClient(player, "UpdatePlayerData", clientData)
    end
end

-- Handle guild selection from client
GuildSelectionRemote.OnServerEvent:Connect(function(player, action, guildName)
    if action == "SelectGuild" then
        print("Player " .. player.Name .. " selected guild: " .. guildName)
        
        -- Validate guild selection
        local guildConfig = GuildModule.GetGuildConfig(guildName)
        if not guildConfig then
            warn("Invalid guild selection: " .. tostring(guildName))
            GuildSelectionRemote:FireClient(player, "Error", "Invalid guild selection!")
            return
        end
        
        -- Save guild choice to player data
        if PlayerDataModule.SetPlayerGuild(player, guildName) then
            -- Assign to team
            GuildModule.AssignPlayerToGuild(player, guildName)
            
            -- Spawn player in guild area
            wait(0.5) -- Small delay
            GuildModule.SpawnPlayerInGuild(player, guildName)
            
            -- Send confirmation to client
            GuildSelectionRemote:FireClient(player, "GuildSelected", guildName)
            
            -- Send player data to client
            SendPlayerDataToClient(player)
            
            print("Player " .. player.Name .. " successfully joined " .. guildName)
        else
            GuildSelectionRemote:FireClient(player, "Error", "Failed to save guild selection!")
        end
    end
end)

-- Handle respawn requests
PlayerSpawnRemote.OnServerEvent:Connect(function(player, action)
    if action == "Respawn" then
        local playerData = PlayerDataModule.GetPlayerData(player)
        if playerData and playerData.Guild then
            GuildModule.SpawnPlayerInGuild(player, playerData.Guild)
        end
    elseif action == "RequestPlayerData" then
        SendPlayerDataToClient(player)
    end
end)

print("PlayerJoinHandler loaded successfully!")