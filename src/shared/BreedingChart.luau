--[[
    BreedingChart.luau
    Defines all possible breeding combinations and their results
]]

local PetData = require(script.Parent.PetData)

local BreedingChart = {}

-- Breeding Combinations
BreedingChart.COMBINATIONS = {
    -- Fire + Plant = Smoke
    {
        elements = {PetData.ELEMENTS.FIRE, PetData.ELEMENTS.PLANT},
        result = PetData.PETS.SMOKE_PET,
        successRate = 0.8, -- 80% success rate
        description = "Fire and Plant create a mysterious Smoke pet",
    },
    
    -- Fire + Water = Steam
    {
        elements = {PetData.ELEMENTS.FIRE, PetData.ELEMENTS.WATER},
        result = PetData.PETS.STEAM_PET,
        successRate = 0.8,
        description = "Fire and Water create a hot and humid Steam pet",
    },
    
    -- Plant + Water = Mud
    {
        elements = {PetData.ELEMENTS.PLANT, PetData.ELEMENTS.WATER},
        result = PetData.PETS.MUD_PET,
        successRate = 0.8,
        description = "Plant and Water create an earthy Mud pet",
    },
    
    -- Smoke + Steam = Ash
    {
        elements = {PetData.ELEMENTS.SMOKE, PetData.ELEMENTS.STEAM},
        result = PetData.PETS.ASH_PET,
        successRate = 0.6, -- Lower success rate for advanced hybrids
        description = "Smoke and Steam create a rare Ash pet",
    },
    
    -- Steam + Mud = Mist
    {
        elements = {PetData.ELEMENTS.STEAM, PetData.ELEMENTS.MUD},
        result = PetData.PETS.MIST_PET,
        successRate = 0.6,
        description = "Steam and Mud create a mystical Mist pet",
    },
}

-- Get breeding result for two elements
function BreedingChart.GetBreedingResult(element1, element2)
    for _, combination in pairs(BreedingChart.COMBINATIONS) do
        local hasElement1 = false
        local hasElement2 = false
        
        for _, element in pairs(combination.elements) do
            if element == element1 then
                hasElement1 = true
            elseif element == element2 then
                hasElement2 = true
            end
        end
        
        if hasElement1 and hasElement2 then
            return combination
        end
    end
    
    return nil
end

-- Check if two elements can breed
function BreedingChart.CanBreed(element1, element2)
    return BreedingChart.GetBreedingResult(element1, element2) ~= nil
end

-- Get all possible breeding combinations
function BreedingChart.GetAllCombinations()
    return BreedingChart.COMBINATIONS
end

-- Get combinations by rarity
function BreedingChart.GetCombinationsByRarity(rarity)
    local combinations = {}
    for _, combination in pairs(BreedingChart.COMBINATIONS) do
        if combination.result.rarity == rarity then
            table.insert(combinations, combination)
        end
    end
    return combinations
end

-- Get success rate for a breeding combination
function BreedingChart.GetSuccessRate(element1, element2)
    local combination = BreedingChart.GetBreedingResult(element1, element2)
    if combination then
        return combination.successRate
    end
    return 0
end

-- Get description for a breeding combination
function BreedingChart.GetDescription(element1, element2)
    local combination = BreedingChart.GetBreedingResult(element1, element2)
    if combination then
        return combination.description
    end
    return "These elements cannot breed together."
end

-- Get all possible results from a given element
function BreedingChart.GetPossibleResults(element)
    local results = {}
    for _, combination in pairs(BreedingChart.COMBINATIONS) do
        for _, comboElement in pairs(combination.elements) do
            if comboElement == element then
                table.insert(results, combination.result)
                break
            end
        end
    end
    return results
end

-- Get breeding difficulty (based on success rate)
function BreedingChart.GetBreedingDifficulty(element1, element2)
    local successRate = BreedingChart.GetSuccessRate(element1, element2)
    
    if successRate >= 0.8 then
        return "Easy"
    elseif successRate >= 0.6 then
        return "Medium"
    elseif successRate > 0 then
        return "Hard"
    else
        return "Impossible"
    end
end

-- Get breeding cost (based on difficulty)
function BreedingChart.GetBreedingCost(element1, element2)
    local difficulty = BreedingChart.GetBreedingDifficulty(element1, element2)
    
    if difficulty == "Easy" then
        return 50
    elseif difficulty == "Medium" then
        return 100
    elseif difficulty == "Hard" then
        return 200
    else
        return 0
    end
end

return BreedingChart