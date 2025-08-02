--[[
    init.server.luau
    Main server script - simplified version for testing
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Game state
local GameState = {
    players = {},
    ranches = {},
}

-- Constants
local RANCH_COUNT = 6
local STARTING_COINS = 500
local PET_SHOP_PRICE = 200

-- Remote Events
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Create basic remote events
local events = {
    "PlayerJoined",
    "PetPurchased", 
    "PetBred",
    "PetGrown",
    "EggHatched",
    "CoinsUpdated",
    "RanchUpdated",
    "ShopOpened",
    "BreedingStarted",
}

for _, eventName in pairs(events) do
    local event = Instance.new("RemoteEvent")
    event.Name = eventName
    event.Parent = RemoteEvents
end

-- Initialize ranch zones
local function initializeRanchZones()
    print("🏠 Initializing ranch zones...")
    
    for i = 1, RANCH_COUNT do
        GameState.ranches[i] = {
            id = i,
            name = "Ranch " .. i,
            assignedTo = nil,
            petSlots = {},
            eggSlots = {},
            breedingSlots = {},
        }
        
        -- Initialize slots
        for j = 1, 8 do
            GameState.ranches[i].petSlots[j] = {
                id = j,
                state = "Empty",
                pet = nil,
            }
        end
        
        for j = 1, 4 do
            GameState.ranches[i].eggSlots[j] = {
                id = j,
                state = "Empty",
                egg = nil,
            }
        end
        
        for j = 1, 2 do
            GameState.ranches[i].breedingSlots[j] = {
                id = j,
                state = "Empty",
                pet1 = nil,
                pet2 = nil,
            }
        end
    end
    
    print("✅ Ranch zones initialized")
end

-- Initialize player data
local function initializePlayer(player)
    print("👤 Initializing player:", player.Name)
    
    local playerData = {
        userId = player.UserId,
        name = player.Name,
        coins = STARTING_COINS,
        pets = {},
        ranchId = nil,
    }
    
    GameState.players[player.UserId] = playerData
    
    -- Assign ranch
    for i = 1, RANCH_COUNT do
        if not GameState.ranches[i].assignedTo then
            GameState.ranches[i].assignedTo = player
            playerData.ranchId = i
            print("🏠 Assigned ranch", i, "to player", player.Name)
            break
        end
    end
    
    if not playerData.ranchId then
        print("❌ No available ranches for", player.Name)
        player:Kick("No available ranches. Please try again later.")
        return
    end
    
    -- Notify client
    local playerJoinedEvent = RemoteEvents:FindFirstChild("PlayerJoined")
    if playerJoinedEvent then
        playerJoinedEvent:FireClient(player, {
            ranchId = playerData.ranchId,
            ranchName = GameState.ranches[playerData.ranchId].name,
            coins = playerData.coins,
        })
    end
    
    print("✅ Player", player.Name, "initialized")
end

-- Player joining
local function onPlayerAdded(player)
    initializePlayer(player)
end

-- Player leaving
local function onPlayerRemoving(player)
    print("👤 Player leaving:", player.Name)
    
    local playerData = GameState.players[player.UserId]
    if playerData and playerData.ranchId then
        GameState.ranches[playerData.ranchId].assignedTo = nil
        print("🏠 Freed ranch", playerData.ranchId, "from player", player.Name)
    end
    
    GameState.players[player.UserId] = nil
    print("✅ Player", player.Name, "cleanup complete")
end

-- Handle pet purchase
local function onPetPurchaseRequest(player, petId)
    print("🛍️ Pet purchase request from", player.Name, "for pet:", petId)
    
    local playerData = GameState.players[player.UserId]
    if not playerData then
        print("❌ Player data not found")
        return
    end
    
    if playerData.coins < PET_SHOP_PRICE then
        print("❌ Insufficient coins for", player.Name)
        return
    end
    
    -- Create new pet
    local newPet = {
        id = petId .. "_" .. tick(),
        name = "Fire Pet",
        element = "Fire",
        growthStage = "Baby",
        createdAt = tick(),
    }
    
    -- Deduct coins
    playerData.coins = playerData.coins - PET_SHOP_PRICE
    
    -- Add pet to player
    playerData.pets[newPet.id] = newPet
    
    print("✅ Pet purchase successful for", player.Name)
    
    -- Notify client
    local petPurchasedEvent = RemoteEvents:FindFirstChild("PetPurchased")
    if petPurchasedEvent then
        petPurchasedEvent:FireClient(player, {
            pet = newPet,
            remainingCoins = playerData.coins,
        })
    end
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Connect remote events
local petPurchaseEvent = RemoteEvents:FindFirstChild("PetPurchaseRequest")
if petPurchaseEvent then
    petPurchaseEvent.OnServerEvent:Connect(onPetPurchaseRequest)
end

-- Initialize game
initializeRanchZones()

print("🎮 Pet Ranch Breeding Game server is now running!")
print("📊 Game State:", GameState)