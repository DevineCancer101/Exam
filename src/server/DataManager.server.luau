--[[
    DataManager.server.luau
    Handles saving and loading player data
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PlayerManager = require(script.Parent.PlayerManager)
local RanchManager = require(script.Parent.RanchManager)

local DataManager = {}

-- Data store for player data
local PlayerDataStore = DataStoreService:GetDataStore("PetRanchPlayerData")

-- Save player data
function DataManager.SavePlayerData(player)
    print("💾 Saving data for player:", player.Name)
    
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then
        print("❌ No player data to save for", player.Name)
        return false
    end
    
    -- Get ranch data
    local ranch = RanchManager.GetRanchByPlayer(player)
    local ranchData = nil
    if ranch then
        ranchData = {
            id = ranch.id,
            name = ranch.name,
            petSlots = ranch.petSlots,
            eggSlots = ranch.eggSlots,
            breedingSlots = ranch.breedingSlots,
        }
    end
    
    -- Prepare data for saving
    local saveData = {
        userId = player.UserId,
        name = player.Name,
        coins = playerData.coins,
        pets = playerData.pets,
        ranchLayout = playerData.ranchLayout,
        breedingHistory = playerData.breedingHistory,
        lastDailyReward = playerData.lastDailyReward,
        ranchData = ranchData,
        lastSaveTime = tick(),
        version = "1.0", -- For future data migrations
    }
    
    -- Save to data store
    local success, errorMessage = pcall(function()
        PlayerDataStore:SetAsync(player.UserId, saveData)
    end)
    
    if success then
        print("✅ Data saved successfully for", player.Name)
        return true
    else
        print("❌ Failed to save data for", player.Name, "Error:", errorMessage)
        return false
    end
end

-- Load player data
function DataManager.LoadPlayerData(player)
    print("📂 Loading data for player:", player.Name)
    
    local success, saveData = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)
    
    if not success or not saveData then
        print("📂 No saved data found for", player.Name, "- using defaults")
        return false
    end
    
    -- Validate data structure
    if not DataManager.ValidateSaveData(saveData) then
        print("❌ Invalid save data for", player.Name, "- using defaults")
        return false
    end
    
    -- Update player data with saved data
    local playerData = PlayerManager.GetPlayerData(player)
    if playerData then
        playerData.coins = saveData.coins or Constants.STARTING_COINS
        playerData.pets = saveData.pets or {}
        playerData.ranchLayout = saveData.ranchLayout or playerData.ranchLayout
        playerData.breedingHistory = saveData.breedingHistory or {}
        playerData.lastDailyReward = saveData.lastDailyReward or 0
        
        -- Restore ranch data if available
        if saveData.ranchData then
            local ranch = RanchManager.GetRanchByPlayer(player)
            if ranch then
                ranch.petSlots = saveData.ranchData.petSlots or ranch.petSlots
                ranch.eggSlots = saveData.ranchData.eggSlots or ranch.eggSlots
                ranch.breedingSlots = saveData.ranchData.breedingSlots or ranch.breedingSlots
            end
        end
        
        print("✅ Data loaded successfully for", player.Name)
        return true
    end
    
    print("❌ Failed to load data for", player.Name)
    return false
end

-- Validate save data structure
function DataManager.ValidateSaveData(saveData)
    if not saveData then return false end
    
    -- Check required fields
    local requiredFields = {"userId", "name", "coins"}
    for _, field in pairs(requiredFields) do
        if saveData[field] == nil then
            return false
        end
    end
    
    -- Check data types
    if type(saveData.coins) ~= "number" then
        return false
    end
    
    if type(saveData.pets) ~= "table" then
        return false
    end
    
    return true
end

-- Auto-save player data
function DataManager.AutoSavePlayerData(player)
    spawn(function()
        while player and player.Parent do
            DataManager.SavePlayerData(player)
            wait(300) -- Save every 5 minutes
        end
    end)
end

-- Save all players data
function DataManager.SaveAllPlayersData()
    print("💾 Saving all players data...")
    
    local savedCount = 0
    local failedCount = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        local success = DataManager.SavePlayerData(player)
        if success then
            savedCount = savedCount + 1
        else
            failedCount = failedCount + 1
        end
    end
    
    print("📊 Save complete - Success:", savedCount, "Failed:", failedCount)
end

-- Get player statistics from saved data
function DataManager.GetPlayerStatsFromSave(player)
    local success, saveData = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)
    
    if not success or not saveData then
        return nil
    end
    
    local stats = {
        totalPets = 0,
        maturePets = 0,
        totalBreedings = 0,
        uniquePets = 0,
        coins = saveData.coins or 0,
        lastSaveTime = saveData.lastSaveTime or 0,
        playTime = 0,
    }
    
    -- Count pets
    if saveData.pets then
        local uniquePetTypes = {}
        
        for petId, pet in pairs(saveData.pets) do
            stats.totalPets = stats.totalPets + 1
            
            if pet.growthStage == Constants.GROWTH_STAGES.MATURE then
                stats.maturePets = stats.maturePets + 1
            end
            
            if not uniquePetTypes[pet.element] then
                uniquePetTypes[pet.element] = true
                stats.uniquePets = stats.uniquePets + 1
            end
        end
    end
    
    -- Count breedings
    if saveData.breedingHistory then
        stats.totalBreedings = #saveData.breedingHistory
    end
    
    -- Calculate play time (if available)
    if saveData.lastSaveTime then
        stats.playTime = tick() - saveData.lastSaveTime
    end
    
    return stats
end

-- Export player data (for backup)
function DataManager.ExportPlayerData(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return nil end
    
    local ranch = RanchManager.GetRanchByPlayer(player)
    local ranchData = nil
    if ranch then
        ranchData = {
            id = ranch.id,
            name = ranch.name,
            petSlots = ranch.petSlots,
            eggSlots = ranch.eggSlots,
            breedingSlots = ranch.breedingSlots,
        }
    end
    
    return {
        userId = player.UserId,
        name = player.Name,
        coins = playerData.coins,
        pets = playerData.pets,
        ranchLayout = playerData.ranchLayout,
        breedingHistory = playerData.breedingHistory,
        lastDailyReward = playerData.lastDailyReward,
        ranchData = ranchData,
        exportTime = tick(),
        version = "1.0",
    }
end

-- Import player data (for restore)
function DataManager.ImportPlayerData(player, importData)
    if not DataManager.ValidateSaveData(importData) then
        return false, "Invalid import data"
    end
    
    -- Update player data
    local playerData = PlayerManager.GetPlayerData(player)
    if playerData then
        playerData.coins = importData.coins
        playerData.pets = importData.pets
        playerData.ranchLayout = importData.ranchLayout
        playerData.breedingHistory = importData.breedingHistory
        playerData.lastDailyReward = importData.lastDailyReward
        
        -- Restore ranch data
        if importData.ranchData then
            local ranch = RanchManager.GetRanchByPlayer(player)
            if ranch then
                ranch.petSlots = importData.ranchData.petSlots
                ranch.eggSlots = importData.ranchData.eggSlots
                ranch.breedingSlots = importData.ranchData.breedingSlots
            end
        end
        
        -- Save imported data
        DataManager.SavePlayerData(player)
        
        print("✅ Data imported successfully for", player.Name)
        return true
    end
    
    return false, "Failed to update player data"
end

-- Clear player data (for testing)
function DataManager.ClearPlayerData(player)
    print("🗑️ Clearing data for player:", player.Name)
    
    local success, errorMessage = pcall(function()
        PlayerDataStore:RemoveAsync(player.UserId)
    end)
    
    if success then
        print("✅ Data cleared for", player.Name)
        return true
    else
        print("❌ Failed to clear data for", player.Name, "Error:", errorMessage)
        return false
    end
end

-- Get data store statistics
function DataManager.GetDataStoreStats()
    -- This would require additional DataStore API calls
    -- For now, return basic info
    return {
        totalPlayers = #Players:GetPlayers(),
        dataStoreName = "PetRanchPlayerData",
    }
end

-- Start auto-save for all players
function DataManager.StartAutoSave()
    print("🔄 Starting auto-save system...")
    
    -- Auto-save existing players
    for _, player in pairs(Players:GetPlayers()) do
        DataManager.AutoSavePlayerData(player)
    end
    
    -- Auto-save new players
    Players.PlayerAdded:Connect(function(player)
        DataManager.AutoSavePlayerData(player)
    end)
    
    print("✅ Auto-save system started")
end

-- Initialize data manager
DataManager.StartAutoSave()

return DataManager