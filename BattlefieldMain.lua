-- Main Battlefield Initialization Script
-- Combines terrain generation and battlefield environment systems

local BattlefieldMain = {}

-- Import modules
local CentralBattlefield = require(script.Parent.CentralBattlefield_Environment)
local TerrainGenerator = require(script.Parent.BattlefieldTerrainGenerator)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuration
local BATTLEFIELD_SETTINGS = {
    AUTO_GENERATE = true,
    DEBUG_MODE = false,
    MIN_PLAYERS_TO_START = 2,
    BATTLEFIELD_SIZE = 1000
}

-- Battlefield state
local battlefieldState = {
    isInitialized = false,
    activePlayers = {},
    currentGuilds = {},
    resourceNodes = {},
    conflictZones = {},
    safeZones = {}
}

-- Initialize the complete battlefield
function BattlefieldMain:initialize()
    if battlefieldState.isInitialized then
        print("Battlefield already initialized!")
        return
    end
    
    print("=== INITIALIZING CENTRAL BATTLEFIELD ===")
    
    -- Generate terrain first
    print("1. Generating battlefield terrain...")
    TerrainGenerator:generateBattlefield()
    
    -- Initialize battlefield environment
    print("2. Setting up battlefield environment...")
    CentralBattlefield:init()
    
    -- Set up player management
    print("3. Setting up player management...")
    self:setupPlayerManagement()
    
    -- Set up event handlers
    print("4. Setting up event handlers...")
    self:setupEventHandlers()
    
    -- Set up periodic updates
    print("5. Setting up periodic updates...")
    self:setupPeriodicUpdates()
    
    battlefieldState.isInitialized = true
    print("=== BATTLEFIELD INITIALIZATION COMPLETE ===")
end

-- Player Management
function BattlefieldMain:setupPlayerManagement()
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

function BattlefieldMain:onPlayerJoin(player)
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
        spawnPoint = nil,
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

function BattlefieldMain:onPlayerLeave(player)
    print("Player left battlefield: " .. player.Name)
    
    -- Clean up player data
    battlefieldState.activePlayers[player.UserId] = nil
    
    -- Remove from guild counts
    local playerData = battlefieldState.activePlayers[player.UserId]
    if playerData and playerData.guild then
        battlefieldState.currentGuilds[playerData.guild] = (battlefieldState.currentGuilds[playerData.guild] or 0) - 1
    end
end

function BattlefieldMain:setupPlayerCharacter(player, character)
    -- Set player spawn point based on guild
    local playerData = battlefieldState.activePlayers[player.UserId]
    if playerData and playerData.guild then
        local spawnPoint = workspace:FindFirstChild(playerData.guild .. "_Spawn")
        if spawnPoint then
            character:SetPrimaryPartCFrame(CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0)))
        end
    else
        -- Default spawn at center
        character:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
    end
    
    -- Set up player health and respawn
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        self:onPlayerDeath(player)
    end)
    
    -- Add player to guild selection if not already assigned
    if not playerData or not playerData.guild then
        self:showGuildSelection(player)
    end
end

function BattlefieldMain:onPlayerDeath(player)
    print("Player died: " .. player.Name)
    
    -- Respawn player after 5 seconds
    spawn(function()
        wait(5)
        if player.Character then
            local playerData = battlefieldState.activePlayers[player.UserId]
            if playerData and playerData.guild then
                local spawnPoint = workspace:FindFirstChild(playerData.guild .. "_Spawn")
                if spawnPoint then
                    player.Character:SetPrimaryPartCFrame(CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0)))
                end
            end
        end
    end)
end

-- Guild Selection System
function BattlefieldMain:showGuildSelection(player)
    -- Create guild selection UI
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

function BattlefieldMain:assignGuild(player, guildName)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if playerData then
        playerData.guild = guildName
        
        -- Update guild counts
        battlefieldState.currentGuilds[guildName] = (battlefieldState.currentGuilds[guildName] or 0) + 1
        
        -- Set spawn point
        local spawnPoint = workspace:FindFirstChild(guildName .. "_Spawn")
        if spawnPoint and player.Character then
            player.Character:SetPrimaryPartCFrame(CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0)))
        end
        
        print("Player " .. player.Name .. " assigned to " .. guildName .. " guild")
    end
end

-- Event Handlers
function BattlefieldMain:setupEventHandlers()
    -- Handle mining zone interactions
    workspace.ChildAdded:Connect(function(child)
        if child.Name:find("MiningZone") then
            self:setupMiningZone(child)
        end
    end)
    
    -- Handle conflict zone interactions
    workspace.ChildAdded:Connect(function(child)
        if child.Name:find("ConflictZone") then
            self:setupConflictZone(child)
        end
    end)
end

function BattlefieldMain:setupMiningZone(zone)
    local proximityPrompt = zone:FindFirstChild("ProximityPrompt")
    if proximityPrompt then
        proximityPrompt.Triggered:Connect(function(player)
            self:handleMining(player, zone)
        end)
    end
end

function BattlefieldMain:setupConflictZone(zone)
    local proximityPrompt = zone:FindFirstChild("ProximityPrompt")
    if proximityPrompt then
        proximityPrompt.Triggered:Connect(function(player)
            self:handleZoneCapture(player, zone)
        end)
    end
end

function BattlefieldMain:handleMining(player, zone)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if not playerData then return end
    
    -- Check if player can mine
    local currentTime = tick()
    if currentTime - playerData.lastMined < 2 then
        return -- Cooldown
    end
    
    -- Determine resource type from zone
    local resourceType = "Iron" -- Default
    if zone.Name:find("Gold") then
        resourceType = "Gold"
    elseif zone.Name:find("Diamond") then
        resourceType = "Diamond"
    elseif zone.Name:find("Crystal") then
        resourceType = "Crystal"
    end
    
    -- Give resources to player
    playerData.resources[resourceType] = (playerData.resources[resourceType] or 0) + 10
    playerData.lastMined = currentTime
    
    -- Show mining feedback
    self:showMiningFeedback(player, resourceType, 10)
    
    print("Player " .. player.Name .. " mined " .. resourceType .. " (+10)")
end

function BattlefieldMain:handleZoneCapture(player, zone)
    local playerData = battlefieldState.activePlayers[player.UserId]
    if not playerData or not playerData.guild then return end
    
    -- Start capture process
    print("Player " .. player.Name .. " started capturing " .. zone.Name)
    
    -- Visual feedback
    local originalColor = zone.Color
    local tween = game:GetService("TweenService"):Create(zone, TweenInfo.new(2), {Color = Color3.fromRGB(255, 0, 0)})
    tween:Play()
    
    -- Complete capture after 2 seconds
    spawn(function()
        wait(2)
        zone.Color = originalColor
        print("Zone " .. zone.Name .. " captured by " .. playerData.guild .. " guild")
    end)
end

function BattlefieldMain:showMiningFeedback(player, resourceType, amount)
    -- Create floating text
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
        local tween = game:GetService("TweenService"):Create(textLabel, TweenInfo.new(2), {
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

-- Periodic Updates
function BattlefieldMain:setupPeriodicUpdates()
    spawn(function()
        while battlefieldState.isInitialized do
            wait(10) -- Update every 10 seconds
            
            -- Update resource nodes
            self:updateResourceNodes()
            
            -- Update guild statistics
            self:updateGuildStats()
            
            -- Clean up disconnected players
            self:cleanupDisconnectedPlayers()
        end
    end)
end

function BattlefieldMain:updateResourceNodes()
    -- Regenerate depleted mining zones
    for _, zone in pairs(battlefieldState.resourceNodes) do
        if not zone.isActive and tick() - zone.lastMined > zone.respawnTime then
            zone.isActive = true
            print("Resource node " .. zone.name .. " has respawned")
        end
    end
end

function BattlefieldMain:updateGuildStats()
    -- Update guild population and territory control
    for guildName, count in pairs(battlefieldState.currentGuilds) do
        if count > 0 then
            print("Guild " .. guildName .. " has " .. count .. " active members")
        end
    end
end

function BattlefieldMain:cleanupDisconnectedPlayers()
    for userId, playerData in pairs(battlefieldState.activePlayers) do
        if not playerData.player or not playerData.player.Parent then
            battlefieldState.activePlayers[userId] = nil
        end
    end
end

-- Debug Functions
function BattlefieldMain:debugInfo()
    if not BATTLEFIELD_SETTINGS.DEBUG_MODE then return end
    
    print("=== BATTLEFIELD DEBUG INFO ===")
    print("Active Players: " .. #battlefieldState.activePlayers)
    print("Guild Distribution:")
    for guild, count in pairs(battlefieldState.currentGuilds) do
        print("  " .. guild .. ": " .. count)
    end
    print("Resource Nodes: " .. #battlefieldState.resourceNodes)
    print("Conflict Zones: " .. #battlefieldState.conflictZones)
    print("================================")
end

-- Public API
function BattlefieldMain:getPlayerData(player)
    return battlefieldState.activePlayers[player.UserId]
end

function BattlefieldMain:getGuildStats()
    return battlefieldState.currentGuilds
end

function BattlefieldMain:isInitialized()
    return battlefieldState.isInitialized
end

-- Auto-initialize if enabled
if BATTLEFIELD_SETTINGS.AUTO_GENERATE then
    spawn(function()
        wait(1) -- Wait for game to load
        BattlefieldMain:initialize()
    end)
end

return BattlefieldMain