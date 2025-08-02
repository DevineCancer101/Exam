--[[
    init.server.luau
    Main server script - initializes all game systems
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Shared modules
local Constants = require(ReplicatedStorage.Shared.Constants)
local PetData = require(ReplicatedStorage.Shared.PetData)
local BreedingChart = require(ReplicatedStorage.Shared.BreedingChart)
local RanchConfig = require(ReplicatedStorage.Shared.RanchConfig)

-- Server modules
local PlayerManager = require(script.Parent.PlayerManager)
local RanchManager = require(script.Parent.RanchManager)
local PetShop = require(script.Parent.PetShop)
local BreedingSystem = require(script.Parent.BreedingSystem)
local GrowthSystem = require(script.Parent.GrowthSystem)
local DataManager = require(script.Parent.DataManager)

-- Remote Events
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Create all remote events
for eventName, _ in pairs(Constants.REMOTE_EVENTS) do
    local event = Instance.new("RemoteEvent")
    event.Name = eventName
    event.Parent = RemoteEvents
end

-- Game state
local GameState = {
    players = {},
    ranches = {},
    activeBreedings = {},
    activeGrowths = {},
    activeEggs = {},
}

-- Initialize game systems
local function initializeGame()
    print("🐾 Pet Ranch Breeding Game - Server Starting...")
    
    -- Initialize ranch zones
    for _, ranch in pairs(RanchConfig.ZONES) do
        RanchConfig.InitializeRanchSlots(ranch.id)
        GameState.ranches[ranch.id] = ranch
    end
    
    print("✅ Ranch zones initialized")
    print("✅ Game systems ready")
end

-- Player joining
local function onPlayerAdded(player)
    print("👤 Player joined:", player.Name)
    
    -- Initialize player data
    local playerData = PlayerManager.InitializePlayer(player)
    GameState.players[player.UserId] = playerData
    
    -- Assign ranch to player
    local ranch = RanchManager.AssignRanchToPlayer(player)
    if ranch then
        print("🏠 Assigned ranch", ranch.id, "to player", player.Name)
    else
        print("❌ No available ranches for player", player.Name)
        player:Kick("No available ranches. Please try again later.")
        return
    end
    
    -- Load player data
    DataManager.LoadPlayerData(player)
    
    -- Notify client
    local playerJoinedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.PLAYER_JOINED)
    if playerJoinedEvent then
        playerJoinedEvent:FireClient(player, {
            ranchId = ranch.id,
            ranchName = ranch.name,
            coins = playerData.coins,
        })
    end
    
    print("✅ Player", player.Name, "fully initialized")
end

-- Player leaving
local function onPlayerRemoving(player)
    print("👤 Player leaving:", player.Name)
    
    -- Save player data
    DataManager.SavePlayerData(player)
    
    -- Free up ranch
    local ranch = RanchManager.GetRanchByPlayer(player)
    if ranch then
        ranch.assignedTo = nil
        print("🏠 Freed ranch", ranch.id, "from player", player.Name)
    end
    
    -- Clean up player data
    GameState.players[player.UserId] = nil
    
    print("✅ Player", player.Name, "cleanup complete")
end

-- Handle pet purchase requests
local function onPetPurchaseRequest(player, petId)
    print("🛍️ Pet purchase request from", player.Name, "for pet:", petId)
    
    local success, newPet = PetShop.PurchasePet(player, petId)
    if success then
        print("✅ Pet purchase successful for", player.Name)
        
        -- Notify client
        local petPurchasedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.PET_PURCHASED)
        if petPurchasedEvent then
            petPurchasedEvent:FireClient(player, {
                pet = newPet,
                remainingCoins = GameState.players[player.UserId].coins,
            })
        end
    else
        print("❌ Pet purchase failed for", player.Name)
        
        -- Notify client of failure
        local petPurchasedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.PET_PURCHASED)
        if petPurchasedEvent then
            petPurchasedEvent:FireClient(player, {
                success = false,
                error = "Insufficient coins or pet not available",
            })
        end
    end
end

-- Handle breeding requests
local function onBreedingRequest(player, pet1Id, pet2Id, slotId)
    print("🧬 Breeding request from", player.Name, "pets:", pet1Id, pet2Id)
    
    local success, result = BreedingSystem.StartBreeding(player, pet1Id, pet2Id, slotId)
    if success then
        print("✅ Breeding started for", player.Name)
        
        -- Notify client
        local breedingStartedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.BREEDING_STARTED)
        if breedingStartedEvent then
            breedingStartedEvent:FireClient(player, {
                result = result,
                slotId = slotId,
            })
        end
    else
        print("❌ Breeding failed for", player.Name)
        
        -- Notify client of failure
        local breedingStartedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.BREEDING_STARTED)
        if breedingStartedEvent then
            breedingStartedEvent:FireClient(player, {
                success = false,
                error = "Cannot breed these pets",
            })
        end
    end
end

-- Handle speed-up requests
local function onSpeedUpRequest(player, slotType, slotId)
    print("⚡ Speed-up request from", player.Name, "slot:", slotType, slotId)
    
    local success = GrowthSystem.SpeedUpProcess(player, slotType, slotId)
    if success then
        print("✅ Speed-up successful for", player.Name)
        
        -- Notify client
        local coinsUpdatedEvent = RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.COINS_UPDATED)
        if coinsUpdatedEvent then
            coinsUpdatedEvent:FireClient(player, {
                coins = GameState.players[player.UserId].coins,
            })
        end
    else
        print("❌ Speed-up failed for", player.Name)
    end
end

-- Connect remote events
local function connectRemoteEvents()
    -- Pet purchase
    local petPurchaseEvent = RemoteEvents:FindFirstChild("PetPurchaseRequest")
    if petPurchaseEvent then
        petPurchaseEvent.OnServerEvent:Connect(onPetPurchaseRequest)
    end
    
    -- Breeding request
    local breedingRequestEvent = RemoteEvents:FindFirstChild("BreedingRequest")
    if breedingRequestEvent then
        breedingRequestEvent.OnServerEvent:Connect(onBreedingRequest)
    end
    
    -- Speed-up request
    local speedUpEvent = RemoteEvents:FindFirstChild("SpeedUpRequest")
    if speedUpEvent then
        speedUpEvent.OnServerEvent:Connect(onSpeedUpRequest)
    end
end

-- Start growth timers
local function startGrowthTimers()
    GrowthSystem.StartGrowthTimers(GameState)
end

-- Initialize game
initializeGame()

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
connectRemoteEvents()

-- Start timers
startGrowthTimers()

print("🎮 Pet Ranch Breeding Game server is now running!")
print("📊 Game State:", GameState)