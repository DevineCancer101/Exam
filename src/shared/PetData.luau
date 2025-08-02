--[[
    PetData.luau
    Defines all pet types, their properties, and elemental characteristics
]]

local PetData = {}

-- Pet Element Types
PetData.ELEMENTS = {
    FIRE = "Fire",
    WATER = "Water", 
    PLANT = "Plant",
    SMOKE = "Smoke",
    STEAM = "Steam",
    MUD = "Mud",
    ASH = "Ash",
    MIST = "Mist",
}

-- Pet Definitions
PetData.PETS = {
    -- Base Elements (Available in Shop)
    FIRE_PET = {
        id = "fire_pet",
        name = "Fire Pet",
        element = PetData.ELEMENTS.FIRE,
        rarity = "Common",
        basePrice = 200,
        sellPrice = 150,
        growthTime = 300, -- 5 minutes
        description = "A warm and energetic pet that loves heat",
        modelName = "FirePet",
        colors = {
            primary = Color3.fromRGB(255, 100, 100),
            secondary = Color3.fromRGB(255, 150, 150),
        },
        availableInShop = true,
    },
    
    -- Hybrid Elements (Breeding Only)
    SMOKE_PET = {
        id = "smoke_pet", 
        name = "Smoke Pet",
        element = PetData.ELEMENTS.SMOKE,
        rarity = "Uncommon",
        basePrice = 400,
        sellPrice = 300,
        growthTime = 300,
        description = "A mysterious pet born from fire and plant",
        modelName = "SmokePet",
        colors = {
            primary = Color3.fromRGB(150, 150, 150),
            secondary = Color3.fromRGB(200, 200, 200),
        },
        availableInShop = false,
        parents = {PetData.ELEMENTS.FIRE, PetData.ELEMENTS.PLANT},
    },
    
    STEAM_PET = {
        id = "steam_pet",
        name = "Steam Pet", 
        element = PetData.ELEMENTS.STEAM,
        rarity = "Uncommon",
        basePrice = 400,
        sellPrice = 300,
        growthTime = 300,
        description = "A hot and humid pet from fire and water",
        modelName = "SteamPet",
        colors = {
            primary = Color3.fromRGB(200, 200, 255),
            secondary = Color3.fromRGB(220, 220, 255),
        },
        availableInShop = false,
        parents = {PetData.ELEMENTS.FIRE, PetData.ELEMENTS.WATER},
    },
    
    MUD_PET = {
        id = "mud_pet",
        name = "Mud Pet",
        element = PetData.ELEMENTS.MUD, 
        rarity = "Uncommon",
        basePrice = 400,
        sellPrice = 300,
        growthTime = 300,
        description = "A earthy pet from plant and water",
        modelName = "MudPet",
        colors = {
            primary = Color3.fromRGB(139, 69, 19),
            secondary = Color3.fromRGB(160, 82, 45),
        },
        availableInShop = false,
        parents = {PetData.ELEMENTS.PLANT, PetData.ELEMENTS.WATER},
    },
    
    -- Advanced Hybrids
    ASH_PET = {
        id = "ash_pet",
        name = "Ash Pet",
        element = PetData.ELEMENTS.ASH,
        rarity = "Rare", 
        basePrice = 600,
        sellPrice = 450,
        growthTime = 300,
        description = "A rare pet from smoke and steam",
        modelName = "AshPet",
        colors = {
            primary = Color3.fromRGB(100, 100, 100),
            secondary = Color3.fromRGB(150, 150, 150),
        },
        availableInShop = false,
        parents = {PetData.ELEMENTS.SMOKE, PetData.ELEMENTS.STEAM},
    },
    
    MIST_PET = {
        id = "mist_pet",
        name = "Mist Pet",
        element = PetData.ELEMENTS.MIST,
        rarity = "Rare",
        basePrice = 600, 
        sellPrice = 450,
        growthTime = 300,
        description = "A mystical pet from steam and mud",
        modelName = "MistPet",
        colors = {
            primary = Color3.fromRGB(220, 220, 255),
            secondary = Color3.fromRGB(240, 240, 255),
        },
        availableInShop = false,
        parents = {PetData.ELEMENTS.STEAM, PetData.ELEMENTS.MUD},
    },
}

-- Get pet by ID
function PetData.GetPetById(id)
    for _, pet in pairs(PetData.PETS) do
        if pet.id == id then
            return pet
        end
    end
    return nil
end

-- Get pets by element
function PetData.GetPetsByElement(element)
    local pets = {}
    for _, pet in pairs(PetData.PETS) do
        if pet.element == element then
            table.insert(pets, pet)
        end
    end
    return pets
end

-- Get shop pets (available for purchase)
function PetData.GetShopPets()
    local shopPets = {}
    for _, pet in pairs(PetData.PETS) do
        if pet.availableInShop then
            table.insert(shopPets, pet)
        end
    end
    return shopPets
end

-- Get breeding pets (can be used for breeding)
function PetData.GetBreedingPets()
    local breedingPets = {}
    for _, pet in pairs(PetData.PETS) do
        if pet.parents then -- Has parent elements, so it's a breeding result
            table.insert(breedingPets, pet)
        end
    end
    return breedingPets
end

-- Check if two pets can breed
function PetData.CanBreed(pet1, pet2)
    if not pet1 or not pet2 then return false end
    if pet1.element == pet2.element then return false end
    
    -- Check if this combination creates a known hybrid
    for _, hybridPet in pairs(PetData.PETS) do
        if hybridPet.parents then
            local hasElement1 = false
            local hasElement2 = false
            
            for _, parentElement in pairs(hybridPet.parents) do
                if parentElement == pet1.element then
                    hasElement1 = true
                elseif parentElement == pet2.element then
                    hasElement2 = true
                end
            end
            
            if hasElement1 and hasElement2 then
                return true, hybridPet
            end
        end
    end
    
    return false
end

-- Get breeding result for two pets
function PetData.GetBreedingResult(pet1, pet2)
    local canBreed, result = PetData.CanBreed(pet1, pet2)
    if canBreed then
        return result
    end
    return nil
end

return PetData