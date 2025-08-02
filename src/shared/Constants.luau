--[[
    Constants.luau
    Game constants and configuration values
]]

local Constants = {}

-- Ranch Configuration
Constants.RANCH_COUNT = 6
Constants.PET_SLOTS_PER_RANCH = 8
Constants.EGG_SLOTS_PER_RANCH = 4
Constants.BREEDING_SLOTS_PER_RANCH = 2

-- Growth Timers (in seconds)
Constants.BABY_TO_MATURE_TIME = 300 -- 5 minutes
Constants.EGG_HATCH_TIME = 300 -- 5 minutes
Constants.BREEDING_COOLDOWN = 600 -- 10 minutes

-- Economy
Constants.STARTING_COINS = 500
Constants.DAILY_REWARD_COINS = 100
Constants.PET_SHOP_PRICE = 200
Constants.SPEED_UP_COST = 50
Constants.MATURE_PET_SELL_PRICE = 150

-- Ranch Zone Positions (relative to world center)
Constants.RANCH_POSITIONS = {
    Vector3.new(-100, 0, -100), -- Ranch 1
    Vector3.new(100, 0, -100),  -- Ranch 2
    Vector3.new(-100, 0, 100),  -- Ranch 3
    Vector3.new(100, 0, 100),   -- Ranch 4
    Vector3.new(0, 0, -150),    -- Ranch 5
    Vector3.new(0, 0, 150),     -- Ranch 6
}

-- Ranch Zone Size
Constants.RANCH_SIZE = Vector3.new(80, 20, 80)

-- UI Colors
Constants.UI_COLORS = {
    FIRE = Color3.fromRGB(255, 100, 100),
    WATER = Color3.fromRGB(100, 100, 255),
    PLANT = Color3.fromRGB(100, 255, 100),
    SMOKE = Color3.fromRGB(150, 150, 150),
    STEAM = Color3.fromRGB(200, 200, 255),
    MUD = Color3.fromRGB(139, 69, 19),
    ASH = Color3.fromRGB(100, 100, 100),
    MIST = Color3.fromRGB(220, 220, 255),
}

-- Pet Growth Stages
Constants.GROWTH_STAGES = {
    BABY = "Baby",
    GROWING = "Growing",
    MATURE = "Mature",
}

-- Egg States
Constants.EGG_STATES = {
    FERTILIZED = "Fertilized",
    HATCHING = "Hatching",
    HATCHED = "Hatched",
}

-- Data Keys
Constants.DATA_KEYS = {
    COINS = "Coins",
    PETS = "Pets",
    RANCH_LAYOUT = "RanchLayout",
    BREEDING_HISTORY = "BreedingHistory",
    LAST_DAILY_REWARD = "LastDailyReward",
}

-- Remote Event Names
Constants.REMOTE_EVENTS = {
    PLAYER_JOINED = "PlayerJoined",
    PET_PURCHASED = "PetPurchased",
    PET_BRED = "PetBred",
    PET_GROWN = "PetGrown",
    EGG_HATCHED = "EggHatched",
    COINS_UPDATED = "CoinsUpdated",
    RANCH_UPDATED = "RanchUpdated",
    SHOP_OPENED = "ShopOpened",
    BREEDING_STARTED = "BreedingStarted",
}

-- Animation IDs
Constants.ANIMATIONS = {
    PET_IDLE = "rbxassetid://123456789",
    PET_WALK = "rbxassetid://123456790",
    EGG_CRACK = "rbxassetid://123456791",
    BREEDING_SPARKLE = "rbxassetid://123456792",
}

return Constants