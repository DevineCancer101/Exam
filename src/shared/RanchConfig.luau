--[[
    RanchConfig.luau
    Defines ranch zones, layouts, and slot management
]]

local Constants = require(script.Parent.Constants)

local RanchConfig = {}

-- Ranch Zone Layout
RanchConfig.ZONES = {
    {
        id = 1,
        name = "Ranch Alpha",
        position = Constants.RANCH_POSITIONS[1],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(255, 200, 200),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
    {
        id = 2,
        name = "Ranch Beta", 
        position = Constants.RANCH_POSITIONS[2],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(200, 255, 200),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
    {
        id = 3,
        name = "Ranch Gamma",
        position = Constants.RANCH_POSITIONS[3],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(200, 200, 255),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
    {
        id = 4,
        name = "Ranch Delta",
        position = Constants.RANCH_POSITIONS[4],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(255, 255, 200),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
    {
        id = 5,
        name = "Ranch Epsilon",
        position = Constants.RANCH_POSITIONS[5],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(255, 200, 255),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
    {
        id = 6,
        name = "Ranch Zeta",
        position = Constants.RANCH_POSITIONS[6],
        size = Constants.RANCH_SIZE,
        color = Color3.fromRGB(200, 255, 255),
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    },
}

-- Slot Positions (relative to ranch center)
RanchConfig.SLOT_POSITIONS = {
    -- Pet Slots (8 slots per ranch)
    petSlots = {
        Vector3.new(-20, 0, -20),
        Vector3.new(0, 0, -20),
        Vector3.new(20, 0, -20),
        Vector3.new(-20, 0, 0),
        Vector3.new(20, 0, 0),
        Vector3.new(-20, 0, 20),
        Vector3.new(0, 0, 20),
        Vector3.new(20, 0, 20),
    },
    
    -- Egg Slots (4 slots per ranch)
    eggSlots = {
        Vector3.new(-15, 0, -15),
        Vector3.new(15, 0, -15),
        Vector3.new(-15, 0, 15),
        Vector3.new(15, 0, 15),
    },
    
    -- Breeding Slots (2 slots per ranch)
    breedingSlots = {
        Vector3.new(-10, 0, 0),
        Vector3.new(10, 0, 0),
    },
}

-- Slot Types
RanchConfig.SLOT_TYPES = {
    PET = "Pet",
    EGG = "Egg", 
    BREEDING = "Breeding",
}

-- Slot States
RanchConfig.SLOT_STATES = {
    EMPTY = "Empty",
    OCCUPIED = "Occupied",
    GROWING = "Growing",
    MATURE = "Mature",
    HATCHING = "Hatching",
    BREEDING = "Breeding",
}

-- Get ranch by ID
function RanchConfig.GetRanchById(id)
    for _, ranch in pairs(RanchConfig.ZONES) do
        if ranch.id == id then
            return ranch
        end
    end
    return nil
end

-- Get available ranch (not assigned to any player)
function RanchConfig.GetAvailableRanch()
    for _, ranch in pairs(RanchConfig.ZONES) do
        if not ranch.assignedTo then
            return ranch
        end
    end
    return nil
end

-- Assign ranch to player
function RanchConfig.AssignRanchToPlayer(ranchId, player)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if ranch and not ranch.assignedTo then
        ranch.assignedTo = player
        return true
    end
    return false
end

-- Get ranch by player
function RanchConfig.GetRanchByPlayer(player)
    for _, ranch in pairs(RanchConfig.ZONES) do
        if ranch.assignedTo == player then
            return ranch
        end
    end
    return nil
end

-- Get slot position in world coordinates
function RanchConfig.GetSlotWorldPosition(ranchId, slotType, slotIndex)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return nil end
    
    local slotPositions = RanchConfig.SLOT_POSITIONS[slotType .. "Slots"]
    if not slotPositions or not slotPositions[slotIndex] then return nil end
    
    return ranch.position + slotPositions[slotIndex]
end

-- Get all slot positions for a ranch
function RanchConfig.GetAllSlotPositions(ranchId)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return nil end
    
    local slots = {
        petSlots = {},
        eggSlots = {},
        breedingSlots = {},
    }
    
    for i, position in pairs(RanchConfig.SLOT_POSITIONS.petSlots) do
        slots.petSlots[i] = ranch.position + position
    end
    
    for i, position in pairs(RanchConfig.SLOT_POSITIONS.eggSlots) do
        slots.eggSlots[i] = ranch.position + position
    end
    
    for i, position in pairs(RanchConfig.SLOT_POSITIONS.breedingSlots) do
        slots.breedingSlots[i] = ranch.position + position
    end
    
    return slots
end

-- Check if position is within ranch bounds
function RanchConfig.IsPositionInRanch(position, ranchId)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return false end
    
    local halfSize = ranch.size / 2
    local minBound = ranch.position - halfSize
    local maxBound = ranch.position + halfSize
    
    return position.X >= minBound.X and position.X <= maxBound.X
        and position.Y >= minBound.Y and position.Y <= maxBound.Y
        and position.Z >= minBound.Z and position.Z <= maxBound.Z
end

-- Get ranch at position
function RanchConfig.GetRanchAtPosition(position)
    for _, ranch in pairs(RanchConfig.ZONES) do
        if RanchConfig.IsPositionInRanch(position, ranch.id) then
            return ranch
        end
    end
    return nil
end

-- Initialize ranch slots
function RanchConfig.InitializeRanchSlots(ranchId)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return end
    
    -- Initialize pet slots
    for i = 1, Constants.PET_SLOTS_PER_RANCH do
        ranch.petSlots[i] = {
            id = i,
            type = RanchConfig.SLOT_TYPES.PET,
            state = RanchConfig.SLOT_STATES.EMPTY,
            pet = nil,
            growthStartTime = nil,
            growthEndTime = nil,
        }
    end
    
    -- Initialize egg slots
    for i = 1, Constants.EGG_SLOTS_PER_RANCH do
        ranch.eggSlots[i] = {
            id = i,
            type = RanchConfig.SLOT_TYPES.EGG,
            state = RanchConfig.SLOT_STATES.EMPTY,
            egg = nil,
            hatchStartTime = nil,
            hatchEndTime = nil,
        }
    end
    
    -- Initialize breeding slots
    for i = 1, Constants.BREEDING_SLOTS_PER_RANCH do
        ranch.breedingSlots[i] = {
            id = i,
            type = RanchConfig.SLOT_TYPES.BREEDING,
            state = RanchConfig.SLOT_STATES.EMPTY,
            pet1 = nil,
            pet2 = nil,
            breedingStartTime = nil,
            breedingEndTime = nil,
        }
    end
end

-- Get empty slot of type
function RanchConfig.GetEmptySlot(ranchId, slotType)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return nil end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots then return nil end
    
    for _, slot in pairs(slots) do
        if slot.state == RanchConfig.SLOT_STATES.EMPTY then
            return slot
        end
    end
    
    return nil
end

-- Get occupied slots of type
function RanchConfig.GetOccupiedSlots(ranchId, slotType)
    local ranch = RanchConfig.GetRanchById(ranchId)
    if not ranch then return {} end
    
    local slots = ranch[slotType .. "Slots"]
    if not slots then return {} end
    
    local occupied = {}
    for _, slot in pairs(slots) do
        if slot.state ~= RanchConfig.SLOT_STATES.EMPTY then
            table.insert(occupied, slot)
        end
    end
    
    return occupied
end

return RanchConfig