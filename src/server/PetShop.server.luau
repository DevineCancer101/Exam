--[[
    PetShop.server.luau
    Handles pet shop functionality and purchases
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PetData = require(ReplicatedStorage.Shared.PetData)
local PlayerManager = require(script.Parent.PlayerManager)
local RanchManager = require(script.Parent.RanchManager)

local PetShop = {}

-- Shop inventory (available pets)
PetShop.INVENTORY = {
    -- Fire pets are always available
    FIRE_PET = {
        pet = PetData.PETS.FIRE_PET,
        stock = -1, -- Unlimited
        price = Constants.PET_SHOP_PRICE,
        available = true,
    },
}

-- Purchase a pet
function PetShop.PurchasePet(player, petId)
    print("🛍️ Processing pet purchase for", player.Name, "pet:", petId)
    
    -- Get player data
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then
        print("❌ Player data not found for", player.Name)
        return false, nil
    end
    
    -- Check if pet is available in shop
    local shopItem = PetShop.INVENTORY[petId]
    if not shopItem or not shopItem.available then
        print("❌ Pet not available in shop:", petId)
        return false, nil
    end
    
    -- Check if player has enough coins
    if playerData.coins < shopItem.price then
        print("❌ Insufficient coins for", player.Name, "needs", shopItem.price, "has", playerData.coins)
        return false, nil
    end
    
    -- Check if player has space in ranch
    if not RanchManager.CanPlacePet(player, "pet") then
        print("❌ No space in ranch for", player.Name)
        return false, nil
    end
    
    -- Create new pet instance
    local newPet = PetShop.CreatePetInstance(shopItem.pet)
    if not newPet then
        print("❌ Failed to create pet instance")
        return false, nil
    end
    
    -- Deduct coins
    PlayerManager.UpdateCoins(player, -shopItem.price)
    
    -- Add pet to player inventory
    PlayerManager.AddPet(player, newPet)
    
    -- Place pet in ranch
    local emptySlots = RanchManager.GetEmptySlots(player, "pet")
    if #emptySlots > 0 then
        local slotId = emptySlots[1].id
        RanchManager.PlacePetInSlot(player, newPet, "pet", slotId)
        print("✅ Pet placed in slot", slotId)
    end
    
    print("✅ Pet purchase successful for", player.Name, "pet:", newPet.name)
    return true, newPet
end

-- Create a new pet instance
function PetShop.CreatePetInstance(petTemplate)
    local pet = {
        id = petTemplate.id .. "_" .. tick(), -- Unique ID
        name = petTemplate.name,
        element = petTemplate.element,
        rarity = petTemplate.rarity,
        growthStage = Constants.GROWTH_STAGES.BABY,
        growthStartTime = tick(),
        growthEndTime = tick() + Constants.BABY_TO_MATURE_TIME,
        colors = petTemplate.colors,
        description = petTemplate.description,
        modelName = petTemplate.modelName,
        createdAt = tick(),
    }
    
    return pet
end

-- Get available pets in shop
function PetShop.GetAvailablePets()
    local availablePets = {}
    
    for petId, shopItem in pairs(PetShop.INVENTORY) do
        if shopItem.available then
            table.insert(availablePets, {
                id = petId,
                pet = shopItem.pet,
                price = shopItem.price,
                stock = shopItem.stock,
            })
        end
    end
    
    return availablePets
end

-- Get pet price
function PetShop.GetPetPrice(petId)
    local shopItem = PetShop.INVENTORY[petId]
    if shopItem then
        return shopItem.price
    end
    return nil
end

-- Check if pet is available for purchase
function PetShop.IsPetAvailable(petId)
    local shopItem = PetShop.INVENTORY[petId]
    return shopItem and shopItem.available
end

-- Get shop statistics
function PetShop.GetShopStats()
    local stats = {
        totalItems = 0,
        availableItems = 0,
        totalValue = 0,
    }
    
    for petId, shopItem in pairs(PetShop.INVENTORY) do
        stats.totalItems = stats.totalItems + 1
        if shopItem.available then
            stats.availableItems = stats.availableItems + 1
            stats.totalValue = stats.totalValue + shopItem.price
        end
    end
    
    return stats
end

-- Add pet to shop inventory
function PetShop.AddPetToInventory(petId, pet, price, stock)
    PetShop.INVENTORY[petId] = {
        pet = pet,
        stock = stock or -1, -- -1 for unlimited
        price = price or Constants.PET_SHOP_PRICE,
        available = true,
    }
    
    print("📦 Added pet to shop inventory:", petId)
end

-- Remove pet from shop inventory
function PetShop.RemovePetFromInventory(petId)
    if PetShop.INVENTORY[petId] then
        PetShop.INVENTORY[petId].available = false
        print("📦 Removed pet from shop inventory:", petId)
        return true
    end
    return false
end

-- Update pet price
function PetShop.UpdatePetPrice(petId, newPrice)
    local shopItem = PetShop.INVENTORY[petId]
    if shopItem then
        shopItem.price = newPrice
        print("💰 Updated price for", petId, "to", newPrice)
        return true
    end
    return false
end

-- Get purchase history for player
function PetShop.GetPurchaseHistory(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    -- This would typically be stored in player data
    -- For now, we'll return an empty array
    return {}
end

-- Sell pet back to shop
function PetShop.SellPet(player, petId)
    print("💰 Processing pet sale for", player.Name, "pet:", petId)
    
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    local pet = playerData.pets[petId]
    if not pet then
        print("❌ Pet not found in player inventory")
        return false
    end
    
    -- Calculate sell price
    local sellPrice = PetData.GetPetById(pet.id) and PetData.GetPetById(pet.id).sellPrice or Constants.MATURE_PET_SELL_PRICE
    
    -- Remove pet from player
    PlayerManager.RemovePet(player, petId)
    
    -- Add coins to player
    PlayerManager.UpdateCoins(player, sellPrice)
    
    print("✅ Pet sold for", sellPrice, "coins")
    return true, sellPrice
end

-- Get recommended pets for player
function PetShop.GetRecommendedPets(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    local recommendations = {}
    local playerPets = PlayerManager.GetPets(player)
    
    -- Check what elements the player has
    local ownedElements = {}
    for _, pet in pairs(playerPets) do
        ownedElements[pet.element] = true
    end
    
    -- Recommend pets that can breed with owned pets
    for petId, shopItem in pairs(PetShop.INVENTORY) do
        if shopItem.available then
            local pet = shopItem.pet
            local canBreed = false
            
            -- Check if this pet can breed with any owned pet
            for element, _ in pairs(ownedElements) do
                if PetData.CanBreed(pet, {element = element}) then
                    canBreed = true
                    break
                end
            end
            
            if canBreed then
                table.insert(recommendations, {
                    id = petId,
                    pet = pet,
                    reason = "Can breed with your pets",
                    priority = 1,
                })
            end
        end
    end
    
    -- Sort by priority
    table.sort(recommendations, function(a, b)
        return a.priority > b.priority
    end)
    
    return recommendations
end

-- Initialize shop with default pets
function PetShop.InitializeShop()
    print("🏪 Initializing pet shop...")
    
    -- Add all shop pets to inventory
    local shopPets = PetData.GetShopPets()
    for _, pet in pairs(shopPets) do
        PetShop.AddPetToInventory(pet.id, pet, pet.basePrice)
    end
    
    print("✅ Pet shop initialized with", #shopPets, "pets")
end

-- Initialize shop on module load
PetShop.InitializeShop()

return PetShop