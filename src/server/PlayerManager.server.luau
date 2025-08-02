--[[
    PlayerManager.server.luau
    Manages player data and initialization
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PetData = require(ReplicatedStorage.Shared.PetData)

local PlayerManager = {}

-- Player data cache
local PlayerData = {}

-- Initialize a new player
function PlayerManager.InitializePlayer(player)
    print("🔄 Initializing player:", player.Name)
    
    local playerData = {
        userId = player.UserId,
        name = player.Name,
        coins = Constants.STARTING_COINS,
        pets = {},
        ranchLayout = {
            petSlots = {},
            eggSlots = {},
            breedingSlots = {},
        },
        breedingHistory = {},
        lastDailyReward = 0,
        joinTime = tick(),
    }
    
    -- Initialize ranch layout
    for i = 1, Constants.PET_SLOTS_PER_RANCH do
        playerData.ranchLayout.petSlots[i] = {
            id = i,
            pet = nil,
            state = Constants.GROWTH_STAGES.EMPTY,
            growthStartTime = nil,
            growthEndTime = nil,
        }
    end
    
    for i = 1, Constants.EGG_SLOTS_PER_RANCH do
        playerData.ranchLayout.eggSlots[i] = {
            id = i,
            egg = nil,
            state = Constants.EGG_STATES.EMPTY,
            hatchStartTime = nil,
            hatchEndTime = nil,
        }
    end
    
    for i = 1, Constants.BREEDING_SLOTS_PER_RANCH do
        playerData.ranchLayout.breedingSlots[i] = {
            id = i,
            pet1 = nil,
            pet2 = nil,
            state = "Empty",
            breedingStartTime = nil,
            breedingEndTime = nil,
        }
    end
    
    -- Store player data
    PlayerData[player.UserId] = playerData
    
    print("✅ Player initialized:", player.Name)
    return playerData
end

-- Get player data
function PlayerManager.GetPlayerData(player)
    return PlayerData[player.UserId]
end

-- Update player coins
function PlayerManager.UpdateCoins(player, amount)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    playerData.coins = playerData.coins + amount
    if playerData.coins < 0 then
        playerData.coins = 0
    end
    
    print("💰 Updated coins for", player.Name, "to", playerData.coins)
    return true
end

-- Get player coins
function PlayerManager.GetCoins(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return 0 end
    
    return playerData.coins
end

-- Add pet to player
function PlayerManager.AddPet(player, pet)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    local petId = pet.id or pet.name
    playerData.pets[petId] = pet
    
    print("🐾 Added pet", petId, "to player", player.Name)
    return true
end

-- Remove pet from player
function PlayerManager.RemovePet(player, petId)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    if playerData.pets[petId] then
        playerData.pets[petId] = nil
        print("🗑️ Removed pet", petId, "from player", player.Name)
        return true
    end
    
    return false
end

-- Get player pets
function PlayerManager.GetPets(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    return playerData.pets
end

-- Get mature pets for breeding
function PlayerManager.GetMaturePets(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    local maturePets = {}
    for petId, pet in pairs(playerData.pets) do
        if pet.growthStage == Constants.GROWTH_STAGES.MATURE then
            table.insert(maturePets, pet)
        end
    end
    
    return maturePets
end

-- Update ranch layout
function PlayerManager.UpdateRanchLayout(player, ranchLayout)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    playerData.ranchLayout = ranchLayout
    print("🏠 Updated ranch layout for", player.Name)
    return true
end

-- Get ranch layout
function PlayerManager.GetRanchLayout(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return nil end
    
    return playerData.ranchLayout
end

-- Add breeding history
function PlayerManager.AddBreedingHistory(player, pet1, pet2, result)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    local breedingRecord = {
        timestamp = tick(),
        pet1 = pet1,
        pet2 = pet2,
        result = result,
    }
    
    table.insert(playerData.breedingHistory, breedingRecord)
    print("📝 Added breeding history for", player.Name)
    return true
end

-- Get breeding history
function PlayerManager.GetBreedingHistory(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    return playerData.breedingHistory
end

-- Check daily reward eligibility
function PlayerManager.CanClaimDailyReward(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    local currentTime = tick()
    local lastRewardTime = playerData.lastDailyReward
    local dayInSeconds = 86400 -- 24 hours
    
    return (currentTime - lastRewardTime) >= dayInSeconds
end

-- Claim daily reward
function PlayerManager.ClaimDailyReward(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    if PlayerManager.CanClaimDailyReward(player) then
        playerData.lastDailyReward = tick()
        PlayerManager.UpdateCoins(player, Constants.DAILY_REWARD_COINS)
        print("🎁 Daily reward claimed for", player.Name)
        return true
    end
    
    return false
end

-- Get player statistics
function PlayerManager.GetPlayerStats(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return nil end
    
    local stats = {
        totalPets = 0,
        maturePets = 0,
        totalBreedings = 0,
        uniquePets = 0,
        coins = playerData.coins,
    }
    
    local uniquePetTypes = {}
    
    for petId, pet in pairs(playerData.pets) do
        stats.totalPets = stats.totalPets + 1
        
        if pet.growthStage == Constants.GROWTH_STAGES.MATURE then
            stats.maturePets = stats.maturePets + 1
        end
        
        if not uniquePetTypes[pet.element] then
            uniquePetTypes[pet.element] = true
            stats.uniquePets = stats.uniquePets + 1
        end
    end
    
    stats.totalBreedings = #playerData.breedingHistory
    
    return stats
end

-- Clean up player data
function PlayerManager.CleanupPlayer(player)
    local userId = player.UserId
    if PlayerData[userId] then
        PlayerData[userId] = nil
        print("🧹 Cleaned up data for player:", player.Name)
    end
end

-- Get all player data (for debugging)
function PlayerManager.GetAllPlayerData()
    return PlayerData
end

return PlayerManager