--[[
    GrowthSystem.server.luau
    Handles pet growth timers and maturation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PlayerManager = require(script.Parent.PlayerManager)
local RanchManager = require(script.Parent.RanchManager)

local GrowthSystem = {}

-- Active growth timers
local ActiveGrowths = {}
local ActiveEggs = {}

-- Start growth timers
function GrowthSystem.StartGrowthTimers(gameState)
    print("🌱 Starting growth timers...")
    
    -- Start a timer that checks all growth processes every second
    spawn(function()
        while true do
            GrowthSystem.UpdateGrowthTimers()
            wait(1) -- Check every second
        end
    end)
    
    print("✅ Growth timers started")
end

-- Update all growth timers
function GrowthSystem.UpdateGrowthTimers()
    local currentTime = tick()
    
    -- Check pet growth
    for playerId, playerData in pairs(gameState.players or {}) do
        local player = Players:GetPlayerByUserId(playerId)
        if player then
            GrowthSystem.CheckPetGrowth(player, currentTime)
            GrowthSystem.CheckEggHatching(player, currentTime)
        end
    end
end

-- Check pet growth for a player
function GrowthSystem.CheckPetGrowth(player, currentTime)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return end
    
    -- Check pet slots
    for slotId, slot in pairs(ranch.petSlots) do
        if slot.state == RanchConfig.SLOT_STATES.OCCUPIED and slot.pet then
            if currentTime >= slot.growthEndTime then
                GrowthSystem.MaturePet(player, slotId)
            end
        end
    end
end

-- Check egg hatching for a player
function GrowthSystem.CheckEggHatching(player, currentTime)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return end
    
    -- Check egg slots
    for slotId, slot in pairs(ranch.eggSlots) do
        if slot.state == Constants.EGG_STATES.FERTILIZED and slot.egg then
            if currentTime >= slot.hatchEndTime then
                GrowthSystem.HatchEgg(player, slotId)
            end
        end
    end
end

-- Mature a pet
function GrowthSystem.MaturePet(player, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local slot = ranch.petSlots[slotId]
    if not slot or not slot.pet then return false end
    
    local pet = slot.pet
    pet.growthStage = Constants.GROWTH_STAGES.MATURE
    
    -- Update player data
    local playerData = PlayerManager.GetPlayerData(player)
    if playerData and playerData.pets[pet.id] then
        playerData.pets[pet.id].growthStage = Constants.GROWTH_STAGES.MATURE
    end
    
    print("🎉 Pet matured:", pet.name, "for player", player.Name)
    
    -- Notify client
    local petGrownEvent = ReplicatedStorage.RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.PET_GROWN)
    if petGrownEvent then
        petGrownEvent:FireClient(player, {
            petId = pet.id,
            slotId = slotId,
            pet = pet,
        })
    end
    
    return true
end

-- Hatch an egg
function GrowthSystem.HatchEgg(player, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local slot = ranch.eggSlots[slotId]
    if not slot or not slot.egg then return false end
    
    local egg = slot.egg
    local resultPet = egg.resultPet
    
    -- Create new pet from egg
    local newPet = GrowthSystem.CreatePetFromEgg(resultPet)
    
    -- Add pet to player inventory
    PlayerManager.AddPet(player, newPet)
    
    -- Place pet in ranch
    local emptyPetSlots = RanchManager.GetEmptySlots(player, "pet")
    if #emptyPetSlots > 0 then
        local petSlotId = emptyPetSlots[1].id
        RanchManager.PlacePetInSlot(player, newPet, "pet", petSlotId)
    end
    
    -- Clear egg slot
    slot.egg = nil
    slot.state = RanchConfig.SLOT_STATES.EMPTY
    slot.hatchStartTime = nil
    slot.hatchEndTime = nil
    
    print("🐣 Egg hatched! New pet:", newPet.name, "for player", player.Name)
    
    -- Notify client
    local eggHatchedEvent = ReplicatedStorage.RemoteEvents:FindFirstChild(Constants.REMOTE_EVENTS.EGG_HATCHED)
    if eggHatchedEvent then
        eggHatchedEvent:FireClient(player, {
            slotId = slotId,
            newPet = newPet,
        })
    end
    
    return true, newPet
end

-- Create pet from egg
function GrowthSystem.CreatePetFromEgg(resultPet)
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

-- Speed up growth process
function GrowthSystem.SpeedUpProcess(player, slotType, slotId)
    print("⚡ Speed-up request for", player.Name, "slot:", slotType, slotId)
    
    local playerData = PlayerManager.GetPlayerData(player)
    if not playerData then return false end
    
    -- Check if player has enough coins
    if playerData.coins < Constants.SPEED_UP_COST then
        print("❌ Insufficient coins for speed-up")
        return false
    end
    
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local slot = ranch[slotType .. "Slots"][slotId]
    if not slot then return false end
    
    local success = false
    
    if slotType == "pet" and slot.state == RanchConfig.SLOT_STATES.OCCUPIED then
        -- Speed up pet growth
        slot.growthEndTime = tick()
        success = GrowthSystem.MaturePet(player, slotId)
        
    elseif slotType == "egg" and slot.state == Constants.EGG_STATES.FERTILIZED then
        -- Speed up egg hatching
        slot.hatchEndTime = tick()
        success = GrowthSystem.HatchEgg(player, slotId)
        
    else
        print("❌ Cannot speed up this process")
        return false
    end
    
    if success then
        -- Deduct coins
        PlayerManager.UpdateCoins(player, -Constants.SPEED_UP_COST)
        print("✅ Speed-up successful for", player.Name)
        return true
    end
    
    return false
end

-- Get growth progress for a slot
function GrowthSystem.GetGrowthProgress(player, slotType, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return 0 end
    
    local slot = ranch[slotType .. "Slots"][slotId]
    if not slot then return 0 end
    
    local currentTime = tick()
    local startTime, endTime
    
    if slotType == "pet" and slot.growthStartTime then
        startTime = slot.growthStartTime
        endTime = slot.growthEndTime
    elseif slotType == "egg" and slot.hatchStartTime then
        startTime = slot.hatchStartTime
        endTime = slot.hatchEndTime
    else
        return 0
    end
    
    if not startTime or not endTime then return 0 end
    
    local progress = (currentTime - startTime) / (endTime - startTime)
    return math.clamp(progress, 0, 1)
end

-- Get time remaining for a slot
function GrowthSystem.GetTimeRemaining(player, slotType, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return 0 end
    
    local slot = ranch[slotType .. "Slots"][slotId]
    if not slot then return 0 end
    
    local currentTime = tick()
    local endTime
    
    if slotType == "pet" and slot.growthEndTime then
        endTime = slot.growthEndTime
    elseif slotType == "egg" and slot.hatchEndTime then
        endTime = slot.hatchEndTime
    else
        return 0
    end
    
    if not endTime then return 0 end
    
    local remaining = endTime - currentTime
    return math.max(remaining, 0)
end

-- Get all active growths for a player
function GrowthSystem.GetActiveGrowths(player)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return {} end
    
    local activeGrowths = {
        pets = {},
        eggs = {},
    }
    
    -- Check pet slots
    for slotId, slot in pairs(ranch.petSlots) do
        if slot.state == RanchConfig.SLOT_STATES.OCCUPIED and slot.pet then
            local progress = GrowthSystem.GetGrowthProgress(player, "pet", slotId)
            local timeRemaining = GrowthSystem.GetTimeRemaining(player, "pet", slotId)
            
            if progress < 1 then
                table.insert(activeGrowths.pets, {
                    slotId = slotId,
                    pet = slot.pet,
                    progress = progress,
                    timeRemaining = timeRemaining,
                })
            end
        end
    end
    
    -- Check egg slots
    for slotId, slot in pairs(ranch.eggSlots) do
        if slot.state == Constants.EGG_STATES.FERTILIZED and slot.egg then
            local progress = GrowthSystem.GetGrowthProgress(player, "egg", slotId)
            local timeRemaining = GrowthSystem.GetTimeRemaining(player, "egg", slotId)
            
            if progress < 1 then
                table.insert(activeGrowths.eggs, {
                    slotId = slotId,
                    egg = slot.egg,
                    progress = progress,
                    timeRemaining = timeRemaining,
                })
            end
        end
    end
    
    return activeGrowths
end

-- Get growth statistics for a player
function GrowthSystem.GetGrowthStats(player)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return nil end
    
    local stats = {
        totalPets = 0,
        maturePets = 0,
        growingPets = 0,
        totalEggs = 0,
        hatchingEggs = 0,
        averageGrowthTime = 0,
    }
    
    local totalGrowthTime = 0
    local growthCount = 0
    
    -- Count pet slots
    for _, slot in pairs(ranch.petSlots) do
        if slot.state ~= RanchConfig.SLOT_STATES.EMPTY then
            stats.totalPets = stats.totalPets + 1
            
            if slot.pet then
                if slot.pet.growthStage == Constants.GROWTH_STAGES.MATURE then
                    stats.maturePets = stats.maturePets + 1
                elseif slot.pet.growthStage == Constants.GROWTH_STAGES.GROWING then
                    stats.growingPets = stats.growingPets + 1
                end
                
                if slot.growthStartTime and slot.growthEndTime then
                    totalGrowthTime = totalGrowthTime + (slot.growthEndTime - slot.growthStartTime)
                    growthCount = growthCount + 1
                end
            end
        end
    end
    
    -- Count egg slots
    for _, slot in pairs(ranch.eggSlots) do
        if slot.state ~= RanchConfig.SLOT_STATES.EMPTY then
            stats.totalEggs = stats.totalEggs + 1
            
            if slot.state == Constants.EGG_STATES.FERTILIZED then
                stats.hatchingEggs = stats.hatchingEggs + 1
            end
        end
    end
    
    -- Calculate average growth time
    if growthCount > 0 then
        stats.averageGrowthTime = totalGrowthTime / growthCount
    end
    
    return stats
end

return GrowthSystem