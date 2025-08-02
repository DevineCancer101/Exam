-- Standalone Battlefield Environment
-- Works with existing mining system without requiring other files

local StandaloneBattlefield = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Terrain = workspace.Terrain

-- Configuration
local BATTLEFIELD_CONFIG = {
    MINING_ZONES = {
        {
            name = "Iron Valley",
            position = Vector3.new(0, 5, 0),
            size = Vector3.new(100, 20, 100),
            resourceType = "Iron",
            resourceYield = 50,
            respawnTime = 30,
            difficulty = 1
        },
        {
            name = "Gold Peak",
            position = Vector3.new(150, 10, 0),
            size = Vector3.new(80, 25, 80),
            resourceType = "Gold",
            resourceYield = 100,
            respawnTime = 45,
            difficulty = 2
        },
        {
            name = "Diamond Cavern",
            position = Vector3.new(-150, -5, 0),
            size = Vector3.new(60, 30, 60),
            resourceType = "Diamond",
            resourceYield = 200,
            respawnTime = 60,
            difficulty = 3
        },
        {
            name = "Crystal Ridge",
            position = Vector3.new(0, 15, 150),
            size = Vector3.new(70, 20, 70),
            resourceType = "Crystal",
            resourceYield = 150,
            respawnTime = 40,
            difficulty = 2
        }
    },
    
    CONFLICT_ZONES = {
        {
            name = "Central Outpost",
            position = Vector3.new(0, 8, 0),
            size = Vector3.new(40, 15, 40),
            captureTime = 30,
            bonusMultiplier = 1.5
        },
        {
            name = "High Ground",
            position = Vector3.new(100, 20, 100),
            size = Vector3.new(30, 10, 30),
            captureTime = 20,
            bonusMultiplier = 1.3
        },
        {
            name = "Supply Depot",
            position = Vector3.new(-100, 5, -100),
            size = Vector3.new(35, 12, 35),
            captureTime = 25,
            bonusMultiplier = 1.4
        }
    },
    
    NEUTRAL_ZONES = {
        {
            name = "Trading Post",
            position = Vector3.new(200, 5, 0),
            size = Vector3.new(50, 10, 50),
            safeZone = true
        },
        {
            name = "Medical Bay",
            position = Vector3.new(-200, 5, 0),
            size = Vector3.new(40, 10, 40),
            safeZone = true
        }
    }
}

-- Battlefield state
local battlefieldState = {
    isInitialized = false,
    activePlayers = {},
    currentGuilds = {},
    miningZones = {},
    conflictZones = {},
    neutralZones = {}
}

-- Initialize the battlefield
function StandaloneBattlefield:initialize()
    if battlefieldState.isInitialized then
        print("Battlefield already initialized!")
        return
    end
    
    print("=== INITIALIZING STANDALONE BATTLEFIELD ===")
    
    -- Generate terrain
    print("1. Generating battlefield terrain...")
    self:generateTerrain()
    
    -- Create mining zones
    print("2. Creating mining zones...")
    self:createMiningZones()
    
    -- Create conflict zones
    print("3. Creating conflict zones...")
    self:createConflictZones()
    
    -- Create neutral zones
    print("4. Creating neutral zones...")
    self:createNeutralZones()
    
    -- Set up player management
    print("5. Setting up player management...")
    self:setupPlayerManagement()
    
    battlefieldState.isInitialized = true
    print("=== BATTLEFIELD INITIALIZATION COMPLETE ===")
end

-- Terrain Generation
function StandaloneBattlefield:generateTerrain()
    -- Clear existing terrain
    Terrain:Clear()
    
    -- Create base plane
    Terrain:FillBlock(
        CFrame.new(0, 0, 0),
        Vector3.new(1000, 1, 1000),
        Enum.Material.Grass
    )
    
    -- Create mountain ranges
    local mountainPositions = {
        Vector3.new(0, 0, 300),
        Vector3.new(0, 0, -300),
        Vector3.new(300, 0, 0),
        Vector3.new(-300, 0, 0)
    }
    
    for _, position in ipairs(mountainPositions) do
        Terrain:FillBlock(
            CFrame.new(position),
            Vector3.new(200, 100, 200),
            Enum.Material.Rock
        )
    end
    
    -- Create central valley
    Terrain:FillBlock(
        CFrame.new(0, 0, 0),
        Vector3.new(400, 50, 400),
        Enum.Material.Air
    )
    
    -- Add valley floor
    Terrain:FillBlock(
        CFrame.new(0, 0, 0),
        Vector3.new(400, 1, 400),
        Enum.Material.Sand
    )
end

-- Create Mining Zones
function StandaloneBattlefield:createMiningZones()
    for _, config in ipairs(BATTLEFIELD_CONFIG.MINING_ZONES) do
        local zone = Instance.new("Part")
        zone.Name = "MiningZone_" .. config.name
        zone.Position = config.position
        zone.Size = config.size
        zone.Anchored = true
        zone.CanCollide = false
        zone.Transparency = 0.8
        
        -- Color based on resource type
        local colors = {
            Iron = Color3.fromRGB(128, 128, 128),
            Gold = Color3.fromRGB(255, 215, 0),
            Diamond = Color3.fromRGB(185, 242, 255),
            Crystal = Color3.fromRGB(138, 43, 226)
        }
        zone.Color = colors[config.resourceType] or Color3.fromRGB(128, 128, 128)
        
        -- Add mining prompt
        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.Parent = zone
        proximityPrompt.ActionText = "Mine " .. config.resourceType
        proximityPrompt.ObjectText = config.name
        proximityPrompt.HoldDuration = 2
        proximityPrompt.MaxActivationDistance = 10
        
        -- Handle mining
        proximityPrompt.Triggered:Connect(function(player)
            self:handleMining(player, config)
        end)
        
        zone.Parent = workspace
        table.insert(battlefieldState.miningZones, zone)
    end
end

-- Create Conflict Zones
function StandaloneBattlefield:createConflictZones()
    for _, config in ipairs(BATTLEFIELD_CONFIG.CONFLICT_ZONES) do
        local zone = Instance.new("Part")
        zone.Name = "ConflictZone_" .. config.name
        zone.Position = config.position
        zone.Size = config.size
        zone.Anchored = true
        zone.CanCollide = false
        zone.Transparency = 0.7
        zone.Color = Color3.fromRGB(255, 255, 255) -- Neutral color
        
        -- Add capture prompt
        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.Parent = zone
        proximityPrompt.ActionText = "Capture Zone"
        proximityPrompt.ObjectText = config.name
        proximityPrompt.HoldDuration = 1
        proximityPrompt.MaxActivationDistance = 15
        
        -- Handle capture
        proximityPrompt.Triggered:Connect(function(player)
            self:handleZoneCapture(player, config)
        end)
        
        zone.Parent = workspace
        table.insert(battlefieldState.conflictZones, zone)
    end
end

-- Create Neutral Zones
function StandaloneBattlefield:createNeutralZones()
    for _, config in ipairs(BATTLEFIELD_CONFIG.NEUTRAL_ZONES) do
        local zone = Instance.new("Part")
        zone.Name = "NeutralZone_" .. config.name
        zone.Position = config.position
        zone.Size = config.size
        zone.Anchored = true
        zone.CanCollide = false
        zone.Transparency = 0.6
        zone.Color = Color3.fromRGB(0, 255, 0) -- Green for safe zones
        
        -- Add safe zone forcefield effect
        local forcefield = Instance.new("Part")
        forcefield.Name = "Forcefield"
        forcefield.Position = config.position
        forcefield.Size = config.size + Vector3.new(5, 5, 5)
        forcefield.Anchored = true
        forcefield.CanCollide = false
        forcefield.Transparency = 0.9
        forcefield.Color = Color3.fromRGB(0, 255, 0)
        forcefield.Parent = zone
        
        zone.Parent = workspace
        table.insert(battlefieldState.neutralZones, zone)
    end
end

-- Player Management
function StandaloneBattlefield:setupPlayerManagement()
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        self:onPlayerJoin(player)
    end)
    
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        self:onPlayerLeave(player)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:onPlayerJoin(player)
    end
end

function StandaloneBattlefield:onPlayerJoin(player)
    print("Player joined battlefield: " .. player.Name)
    
    -- Initialize player data
    battlefieldState.activePlayers[player.UserId] = {
        player = player,
        guild = nil,
        resources = {
            Iron = 0,
            Gold = 0,
            Diamond = 0,
            Crystal = 0
        },
        coins = 0,
        lastMined = 0
    }
    
    -- Set up player character
    player.CharacterAdded:Connect(function(character)
        self:setupPlayerCharacter(player, character)
    end)
    
    -- If player already has character
    if player.Character then
        self:setupPlayerCharacter(player, player.Character)
    end
end

function StandaloneBattlefield:onPlayerLeave(player)
    print("Player left battlefield: " .. player.Name)
    battlefieldState.activePlayers[player.UserId] = nil
end

function StandaloneBattlefield:setupPlayerCharacter(player, character)
    -- Set default spawn point
    character:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
    
    -- Set up player health and respawn
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        self:onPlayerDeath(player)
    end)
    
    -- Show guild selection if not assigned
    local playerData = battlefieldState.activePlayers[player.UserId]
    if not playerData or not playerData.guild then
        self:showGuildSelection(player)
    end
end

function StandaloneBattlefield:onPlayerDeath(player)
    print("Player died: " .. player.Name)
    
    -- Respawn player after 5 seconds
    spawn(function()
        wait(5)
        if player.Character then
            player.Character:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
        end
    end)
end

-- Guild Selection
function StandaloneBattlefield:showGuildSelection(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GuildSelection"
    screenGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "SelectionFrame"
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Choose Your Guild"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local guilds = {"Fire", "Ice", "Nature", "Tech", "Shadow"}
    local guildColors = {
        Fire = Color3.fromRGB(255, 69, 0),
        Ice = Color3.fromRGB(135, 206, 235),
        Nature = Color3.fromRGB(34, 139, 34),
        Tech = Color3.fromRGB(0, 191, 255),
        Shadow = Color3.fromRGB(75, 0, 130)
    }
    
    for i, guildName in ipairs(guilds) do
        local button = Instance.new("TextButton")
        button.Name = guildName .. "Button"
        button.Size = UDim2.new(0.15, 0, 0.2, 0)
        button.Position = UDim2.new(0.1 + (i-1) * 0.18, 0, 0.3, 0)
        button.BackgroundColor3 = guildColors[guildName]
        button.Text = guildName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            self:assignGuild(player, guildName)
            screenGui:Destroy()
        end)
    end
end

function StandaloneBattlefield:assignGuild(player, guildName)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if playerData then
        playerData.guild = guildName
        battlefieldState.currentGuilds[guildName] = (battlefieldState.currentGuilds[guildName] or 0) + 1
        print("Player " .. player.Name .. " assigned to " .. guildName .. " guild")
    end
end

-- Mining Handler
function StandaloneBattlefield:handleMining(player, config)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if not playerData then return end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - playerData.lastMined < 2 then
        return
    end
    
    -- Give resources to player
    playerData.resources[config.resourceType] = (playerData.resources[config.resourceType] or 0) + config.resourceYield
    playerData.lastMined = currentTime
    
    -- Show mining feedback
    self:showMiningFeedback(player, config.resourceType, config.resourceYield)
    
    print("Player " .. player.Name .. " mined " .. config.resourceType .. " (+" .. config.resourceYield .. ")")
end

-- Zone Capture Handler
function StandaloneBattlefield:handleZoneCapture(player, config)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if not playerData or not playerData.guild then return end
    
    print("Player " .. player.Name .. " started capturing " .. config.name)
    
    -- Find the zone in workspace
    local zone = workspace:FindFirstChild("ConflictZone_" .. config.name)
    if zone then
        -- Visual feedback
        local originalColor = zone.Color
        local tween = TweenService:Create(zone, TweenInfo.new(2), {Color = Color3.fromRGB(255, 0, 0)})
        tween:Play()
        
        -- Complete capture after 2 seconds
        spawn(function()
            wait(2)
            zone.Color = originalColor
            print("Zone " .. config.name .. " captured by " .. playerData.guild .. " guild")
        end)
    end
end

-- Mining Feedback
function StandaloneBattlefield:showMiningFeedback(player, resourceType, amount)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.Parent = player.Character.HumanoidRootPart
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "+" .. amount .. " " .. resourceType
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboardGui
        
        -- Animate text
        local tween = TweenService:Create(textLabel, TweenInfo.new(2), {
            Position = UDim2.new(0, 0, -1, 0),
            TextTransparency = 1
        })
        tween:Play()
        
        -- Remove after animation
        spawn(function()
            wait(2)
            billboardGui:Destroy()
        end)
    end
end

-- Public API
function StandaloneBattlefield:getPlayerData(player)
    return battlefieldState.activePlayers[player.UserId]
end

function StandaloneBattlefield:getGuildStats()
    return battlefieldState.currentGuilds
end

function StandaloneBattlefield:isInitialized()
    return battlefieldState.isInitialized
end

-- Auto-initialize
spawn(function()
    wait(1) -- Wait for game to load
    StandaloneBattlefield:initialize()
end)

return StandaloneBattlefield