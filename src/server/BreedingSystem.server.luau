--[[
    BreedingSystem.server.luau
    Handles pet breeding mechanics and hybrid creation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PetData = require(ReplicatedStorage.Shared.PetData)
local BreedingChart = require(ReplicatedStorage.Shared.BreedingChart)
local PlayerManager = require(script.Parent.PlayerManager)
local RanchManager = require(script.Parent.RanchManager)

local BreedingSystem = {}

-- Active breeding sessions
local ActiveBreedings = {}

-- Start breeding process
function BreedingSystem.StartBreeding(player, pet1Id, pet2Id, slotId)
    print("🧬 Starting breeding process for", player.Name, "pets:", pet1Id, pet2Id)
    
    -- Get player data
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then
        print("❌ Player data not found")
        return false, nil
    end
    
    -- Get pets from player inventory
    local pet1 = playerData.pets[pet1Id]
    local pet2 = playerData.pets[pet2Id]
    
    if not pet1 or not pet2 then
        print("❌ One or both pets not found")
        return false, nil
    end
    
    -- Check if pets are mature
    if pet1.growthStage ~= Constants.GROWTH_STAGES.MATURE or 
       pet2.growthStage ~= Constants.GROWTH_STAGES.MATURE then
        print("❌ Pets must be mature to breed")
        return false, nil
    end
    
    -- Check if pets can breed
    local canBreed, result = PetData.CanBreed(pet1, pet2)
    if not canBreed then
        print("❌ These pets cannot breed together")
        return false, nil
    end
    
    -- Check if player has space for egg
    if not RanchManager.CanPlacePet(player, "egg") then
        print("❌ No space for egg in ranch")
        return false, nil
    end
    
    -- Calculate breeding cost
    local breedingCost = BreedingChart.GetBreedingCost(pet1.element, pet2.element)
    if playerData.coins < breedingCost then
        print("❌ Insufficient coins for breeding, needs", breedingCost)
        return false, nil
    end
    
    -- Deduct breeding cost
    PlayerManager.UpdateCoins(player, -breedingCost)
    
    -- Get breeding slot
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false, nil end
    
    local breedingSlot = ranch.breedingSlots[slotId]
    if not breedingSlot or breedingSlot.state ~= RanchConfig.SLOT_STATES.EMPTY then
        print("❌ Breeding slot not available")
        return false, nil
    end
    
    -- Start breeding process
    local breedingId = player.UserId .. "_" .. tick()
    local breedingSession = {
        id = breedingId,
        player = player,
        pet1 = pet1,
        pet2 = pet2,
        result = result,
        slotId = slotId,
        startTime = tick(),
        endTime = tick() + Constants.BREEDING_COOLDOWN,
        successRate = BreedingChart.GetSuccessRate(pet1.element, pet2.element),
    }
    
    -- Update breeding slot
    breedingSlot.pet1 = pet1
    breedingSlot.pet2 = pet2
    breedingSlot.state = RanchConfig.SLOT_STATES.BREEDING
    breedingSlot.breedingStartTime = tick()
    breedingSlot.breedingEndTime = tick() + Constants.BREEDING_COOLDOWN
    
    -- Store breeding session
    ActiveBreedings[breedingId] = breedingSession
    
    print("✅ Breeding started for", player.Name, "result:", result.name)
    return true, breedingSession
end

-- Complete breeding process
function BreedingSystem.CompleteBreeding(breedingId)
    local breedingSession = ActiveBreedings[breedingId]
    if not breedingSession then return false end
    
    local player = breedingSession.player
    local pet1 = breedingSession.pet1
    local pet2 = breedingSession.pet2
    local result = breedingSession.result
    
    print("🎉 Completing breeding for", player.Name)
    
    -- Determine if breeding was successful
    local success = math.random() <= breedingSession.successRate
    
    if success then
        -- Create egg
        local egg = BreedingSystem.CreateEgg(result)
        
        -- Place egg in ranch
        local emptyEggSlots = RanchManager.GetEmptySlots(player, "egg")
        if #emptyEggSlots > 0 then
            local slotId = emptyEggSlots[1].id
            local ranch = RanchManager.GetRanchByPlayer(player)
            local eggSlot = ranch.eggSlots[slotId]
            
            eggSlot.egg = egg
            eggSlot.state = Constants.EGG_STATES.FERTILIZED
            eggSlot.hatchStartTime = tick()
            eggSlot.hatchEndTime = tick() + Constants.EGG_HATCH_TIME
            
            print("🥚 Egg created and placed in slot", slotId)
        end
        
        -- Add to breeding history
        PlayerManager.AddBreedingHistory(player, pet1, pet2, result)
        
        print("✅ Breeding successful! Created", result.name)
    else
        print("❌ Breeding failed for", player.Name)
    end
    
    -- Clear breeding slot
    local ranch = RanchManager.GetRanchByPlayer(player)
    local breedingSlot = ranch.breedingSlots[breedingSession.slotId]
    breedingSlot.pet1 = nil
    breedingSlot.pet2 = nil
    breedingSlot.state = RanchConfig.SLOT_STATES.EMPTY
    breedingSlot.breedingStartTime = nil
    breedingSlot.breedingEndTime = nil
    
    -- Remove from active breedings
    ActiveBreedings[breedingId] = nil
    
    return success, result
end

-- Create egg from breeding result
function BreedingSystem.CreateEgg(resultPet)
    local egg = {
        id = "egg_" .. tick(),
        resultPet = resultPet,
        element = resultPet.element,
        rarity = resultPet.rarity,
        hatchStartTime = tick(),
        hatchEndTime = tick() + Constants.EGG_HATCH_TIME,
        state = Constants.EGG_STATES.FERTILIZED,
    }
    
    return egg
end

-- Hatch egg
function BreedingSystem.HatchEgg(player, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local eggSlot = ranch.eggSlots[slotId]
    if not eggSlot or not eggSlot.egg then return false end
    
    local egg = eggSlot.egg
    local resultPet = egg.resultPet
    
    -- Create new pet from egg
    local newPet = BreedingSystem.CreatePetFromEgg(resultPet)
    
    -- Add pet to player inventory
    PlayerManager.AddPet(player, newPet)
    
    -- Place pet in ranch
    local emptyPetSlots = RanchManager.GetEmptySlots(player, "pet")
    if #emptyPetSlots > 0 then
        local petSlotId = emptyPetSlots[1].id
        RanchManager.PlacePetInSlot(player, newPet, "pet", petSlotId)
    end
    
    -- Clear egg slot
    eggSlot.egg = nil
    eggSlot.state = RanchConfig.SLOT_STATES.EMPTY
    eggSlot.hatchStartTime = nil
    eggSlot.hatchEndTime = nil
    
    print("🐣 Egg hatched! New pet:", newPet.name)
    return true, newPet
end

-- Create pet from egg
function BreedingSystem.CreatePetFromEgg(resultPet)
    local pet = {
        id = resultPet.id .. "_" .. tick(),
        name = resultPet.name,
        element = resultPet.element,
        rarity = resultPet.rarity,
        growthStage = Constants.GROWTH_STAGES.BABY,
        growthStartTime = tick(),
        growthEndTime = tick() + Constants.BABY_TO_MATURE_TIME,
        colors = resultPet.colors,
        description = resultPet.description,
        modelName = resultPet.modelName,
        createdAt = tick(),
        isHybrid = true,
    }
    
    return pet
end

-- Get breeding possibilities for player
function BreedingSystem.GetBreedingPossibilities(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return {} end
    
    local maturePets = PlayerManager.GetMaturePets(player)
    local possibilities = {}
    
    -- Check all possible combinations
    for i, pet1 in pairs(maturePets) do
        for j, pet2 in pairs(maturePets) do
            if i ~= j then
                local canBreed, result = PetData.CanBreed(pet1, pet2)
                if canBreed then
                    table.insert(possibilities, {
                        pet1 = pet1,
                        pet2 = pet2,
                        result = result,
                        successRate = BreedingChart.GetSuccessRate(pet1.element, pet2.element),
                        cost = BreedingChart.GetBreedingCost(pet1.element, pet2.element),
                    })
                end
            end
        end
    end
    
    return possibilities
end

-- Get active breeding for player
function BreedingSystem.GetActiveBreeding(player)
    for breedingId, breedingSession in pairs(ActiveBreedings) do
        if breedingSession.player == player then
            return breedingSession
        end
    end
    return nil
end

-- Get breeding progress
function BreedingSystem.GetBreedingProgress(breedingId)
    local breedingSession = ActiveBreedings[breedingId]
    if not breedingSession then return 0 end
    
    local currentTime = tick()
    local startTime = breedingSession.startTime
    local endTime = breedingSession.endTime
    
    local progress = (currentTime - startTime) / (endTime - startTime)
    return math.clamp(progress, 0, 1)
end

-- Check if breeding is complete
function BreedingSystem.IsBreedingComplete(breedingId)
    local breedingSession = ActiveBreedings[breedingId]
    if not breedingSession then return false end
    
    return tick() >= breedingSession.endTime
end

-- Get breeding statistics
function BreedingSystem.GetBreedingStats(player)
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return nil end
    
    local stats = {
        totalBreedings = #playerData.breedingHistory,
        successfulBreedings = 0,
        failedBreedings = 0,
        uniqueHybrids = 0,
        totalSpent = 0,
    }
    
    local uniqueHybrids = {}
    
    for _, breedingRecord in pairs(playerData.breedingHistory) do
        if breedingRecord.result then
            stats.successfulBreedings = stats.successfulBreedings + 1
            uniqueHybrids[breedingRecord.result.element] = true
        else
            stats.failedBreedings = stats.failedBreedings + 1
        end
    end
    
    stats.uniqueHybrids = 0
    for _ in pairs(uniqueHybrids) do
        stats.uniqueHybrids = stats.uniqueHybrids + 1
    end
    
    return stats
end

-- Speed up breeding
function BreedingSystem.SpeedUpBreeding(player, breedingId)
    local breedingSession = ActiveBreedings[breedingId]
    if not breedingSession or breedingSession.player ~= player then
        return false
    end
    
    local playerData = PlayerManager.GetPlayerData(player)
    if playerData.coins < Constants.SPEED_UP_COST then
        return false
    end
    
    -- Deduct coins
    PlayerManager.UpdateCoins(player, -Constants.SPEED_UP_COST)
    
    -- Complete breeding immediately
    BreedingSystem.CompleteBreeding(breedingId)
    
    print("⚡ Breeding speed up for", player.Name)
    return true
end

return BreedingSystem