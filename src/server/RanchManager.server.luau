--[[
    RanchManager.server.luau
    Manages ranch assignment and ranch-related operations
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local RanchConfig = require(ReplicatedStorage.Shared.RanchConfig)

local RanchManager = {}

-- Ranch assignments (player -> ranch)
local RanchAssignments = {}

-- Assign a ranch to a player
function RanchManager.AssignRanchToPlayer(player)
    print("🏠 Attempting to assign ranch to player:", player.Name)
    
    -- Check if player already has a ranch
    if RanchAssignments[player.UserId] then
        local existingRanch = RanchConfig.GetRanchById(RanchAssignments[player.UserId])
        print("✅ Player already has ranch:", existingRanch.id)
        return existingRanch
    end
    
    -- Find available ranch
    local availableRanch = RanchConfig.GetAvailableRanch()
    if not availableRanch then
        print("❌ No available ranches")
        return nil
    end
    
    -- Assign ranch to player
    RanchAssignments[player.UserId] = availableRanch.id
    availableRanch.assignedTo = player
    
    print("✅ Assigned ranch", availableRanch.id, "to player", player.Name)
    return availableRanch
end

-- Get ranch assigned to player
function RanchManager.GetRanchByPlayer(player)
    local ranchId = RanchAssignments[player.UserId]
    if not ranchId then return nil end
    
    return RanchConfig.GetRanchById(ranchId)
end

-- Get player assigned to ranch
function RanchManager.GetPlayerByRanch(ranchId)
    for userId, assignedRanchId in pairs(RanchAssignments) do
        if assignedRanchId == ranchId then
            return Players:GetPlayerByUserId(userId)
        end
    end
    return nil
end

-- Free ranch when player leaves
function RanchManager.FreeRanch(player)
    local ranchId = RanchAssignments[player.UserId]
    if not ranchId then return false end
    
    local ranch = RanchConfig.GetRanchById(ranchId)
    if ranch then
        ranch.assignedTo = nil
        RanchAssignments[player.UserId] = nil
        print("🏠 Freed ranch", ranchId, "from player", player.Name)
        return true
    end
    
    return false
end

-- Get all ranch assignments
function RanchManager.GetAllAssignments()
    return RanchAssignments
end

-- Get available ranch count
function RanchManager.GetAvailableRanchCount()
    local availableCount = 0
    for _, ranch in pairs(RanchConfig.ZONES) do
        if not ranch.assignedTo then
            availableCount = availableCount + 1
        end
    end
    return availableCount
end

-- Get occupied ranch count
function RanchManager.GetOccupiedRanchCount()
    return Constants.RANCH_COUNT - RanchManager.GetAvailableRanchCount()
end

-- Check if ranch is available
function RanchManager.IsRanchAvailable(ranchId)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return false end
    
    return ranch.assignedTo == nil
end

-- Get ranch status
function RanchManager.GetRanchStatus(ranchId)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return "Invalid" end
    
    if ranch.assignedTo then
        return "Occupied by " .. ranch.assignedTo.Name
    else
        return "Available"
    end
end

-- Get all ranch statuses
function RanchManager.GetAllRanchStatuses()
    local statuses = {}
    for _, ranch in pairs(RanchConfig.ZONES) do
        statuses[ranch.id] = {
            name = ranch.name,
            status = RanchManager.GetRanchStatus(ranch.id),
            position = ranch.position,
            color = ranch.color,
        }
    end
    return statuses
end

-- Place pet in ranch slot
function RanchManager.PlacePetInSlot(player, pet, slotType, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots or not slots[slotId] then return false end
    
    local slot = slots[slotId]
    if slot.state ~= RanchConfig.SLOT_STATES.EMPTY then return false end
    
    -- Place pet in slot
    slot.pet = pet
    slot.state = RanchConfig.SLOT_STATES.OCCUPIED
    slot.growthStartTime = tick()
    slot.growthEndTime = tick() + Constants.BABY_TO_MATURE_TIME
    
    print("🐾 Placed pet", pet.name, "in", slotType, "slot", slotId, "for player", player.Name)
    return true
end

-- Remove pet from ranch slot
function RanchManager.RemovePetFromSlot(player, slotType, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return false end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots or not slots[slotId] then return false end
    
    local slot = slots[slotId]
    if slot.state == RanchConfig.SLOT_STATES.EMPTY then return false end
    
    local pet = slot.pet
    slot.pet = nil
    slot.state = RanchConfig.SLOT_STATES.EMPTY
    slot.growthStartTime = nil
    slot.growthEndTime = nil
    
    print("🗑️ Removed pet from", slotType, "slot", slotId, "for player", player.Name)
    return pet
end

-- Get ranch slot info
function RanchManager.GetSlotInfo(player, slotType, slotId)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return nil end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots or not slots[slotId] then return nil end
    
    return slots[slotId]
end

-- Get all slots for player's ranch
function RanchManager.GetAllSlots(player)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return nil end
    
    return {
        petSlots = ranch.petSlots,
        eggSlots = ranch.eggSlots,
        breedingSlots = ranch.breedingSlots,
    }
end

-- Get empty slots of type
function RanchManager.GetEmptySlots(player, slotType)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return {} end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots then return {} end
    
    local emptySlots = {}
    for slotId, slot in pairs(slots) do
        if slot.state == RanchConfig.SLOT_STATES.EMPTY then
            table.insert(emptySlots, {
                id = slotId,
                slot = slot,
            })
        end
    end
    
    return emptySlots
end

-- Get occupied slots of type
function RanchManager.GetOccupiedSlots(player, slotType)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return {} end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots then return {} end
    
    local occupiedSlots = {}
    for slotId, slot in pairs(slots) do
        if slot.state ~= RanchConfig.SLOT_STATES.EMPTY then
            table.insert(occupiedSlots, {
                id = slotId,
                slot = slot,
            })
        end
    end
    
    return occupiedSlots
end

-- Check if player can place pet
function RanchManager.CanPlacePet(player, slotType)
    local emptySlots = RanchManager.GetEmptySlots(player, slotType)
    return #emptySlots > 0
end

-- Get ranch statistics
function RanchManager.GetRanchStats(player)
    local ranch = RanchManager.GetRanchByPlayer(player)
    if not ranch then return nil end
    
    local stats = {
        totalPets = 0,
        maturePets = 0,
        growingPets = 0,
        eggs = 0,
        breedingPairs = 0,
        emptyPetSlots = 0,
        emptyEggSlots = 0,
        emptyBreedingSlots = 0,
    }
    
    -- Count pet slots
    for _, slot in pairs(ranch.petSlots) do
        if slot.state == RanchConfig.SLOT_STATES.EMPTY then
            stats.emptyPetSlots = stats.emptyPetSlots + 1
        else
            stats.totalPets = stats.totalPets + 1
            if slot.pet and slot.pet.growthStage == Constants.GROWTH_STAGES.MATURE then
                stats.maturePets = stats.maturePets + 1
            elseif slot.pet and slot.pet.growthStage == Constants.GROWTH_STAGES.GROWING then
                stats.growingPets = stats.growingPets + 1
            end
        end
    end
    
    -- Count egg slots
    for _, slot in pairs(ranch.eggSlots) do
        if slot.state == RanchConfig.SLOT_STATES.EMPTY then
            stats.emptyEggSlots = stats.emptyEggSlots + 1
        else
            stats.eggs = stats.eggs + 1
        end
    end
    
    -- Count breeding slots
    for _, slot in pairs(ranch.breedingSlots) do
        if slot.state == RanchConfig.SLOT_STATES.EMPTY then
            stats.emptyBreedingSlots = stats.emptyBreedingSlots + 1
        else
            stats.breedingPairs = stats.breedingPairs + 1
        end
    end
    
    return stats
end

return RanchManager