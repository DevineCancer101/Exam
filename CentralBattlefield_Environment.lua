-- Central Battlefield Environment for Mining/Faction War Game
-- This script manages the main conflict area with mining zones and strategic gameplay

local CentralBattlefield = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

-- Mining Zone Class
local MiningZone = {}
MiningZone.__index = MiningZone

function MiningZone.new(config)
    local self = setmetatable({}, MiningZone)
    
    self.name = config.name
    self.position = config.position
    self.size = config.size
    self.resourceType = config.resourceType
    self.resourceYield = config.resourceYield
    self.respawnTime = config.respawnTime
    self.difficulty = config.difficulty
    
    self.isActive = true
    self.currentMiners = {}
    self.lastMined = 0
    self.zoneModel = nil
    
    return self
end

function MiningZone:createZoneModel()
    -- Create the mining zone visual
    local zone = Instance.new("Part")
    zone.Name = self.name
    zone.Position = self.position
    zone.Size = self.size
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
    zone.Color = colors[self.resourceType] or Color3.fromRGB(128, 128, 128)
    
    -- Add mining particles
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = zone
    particleEmitter.Rate = 5
    particleEmitter.Speed = NumberRange.new(2, 5)
    particleEmitter.Lifetime = NumberRange.new(1, 3)
    particleEmitter.SpreadAngle = Vector2.new(45, 45)
    particleEmitter.Color = ColorSequence.new(zone.Color)
    
    -- Add mining prompt
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = zone
    proximityPrompt.ActionText = "Mine " .. self.resourceType
    proximityPrompt.ObjectText = self.name
    proximityPrompt.HoldDuration = 2
    proximityPrompt.MaxActivationDistance = 10
    
    self.zoneModel = zone
    return zone
end

function MiningZone:startMining(player)
    if not self.isActive then
        return false, "Zone is depleted"
    end
    
    if #self.currentMiners >= 3 then
        return false, "Zone is full"
    end
    
    table.insert(self.currentMiners, player)
    
    -- Calculate mining time based on difficulty
    local miningTime = 5 + (self.difficulty * 2)
    
    -- Start mining process
    local miningProgress = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        miningProgress = miningProgress + deltaTime
        
        if miningProgress >= miningTime then
            -- Mining complete
            self:completeMining(player)
            connection:Disconnect()
        end
    end)
    
    return true, "Mining started"
end

function MiningZone:completeMining(player)
    -- Remove player from miners
    for i, miner in ipairs(self.currentMiners) do
        if miner == player then
            table.remove(self.currentMiners, i)
            break
        end
    end
    
    -- Give resources to player
    local playerData = self:getPlayerData(player)
    if playerData then
        playerData.resources[self.resourceType] = (playerData.resources[self.resourceType] or 0) + self.resourceYield
        self:updatePlayerUI(player)
    end
    
    -- Check if zone should be depleted
    if #self.currentMiners == 0 then
        self:depleteZone()
    end
end

function MiningZone:depleteZone()
    self.isActive = false
    self.lastMined = tick()
    
    -- Visual feedback
    if self.zoneModel then
        local tween = TweenService:Create(self.zoneModel, TweenInfo.new(1), {Transparency = 0.95})
        tween:Play()
    end
    
    -- Respawn timer
    spawn(function()
        wait(self.respawnTime)
        self:respawnZone()
    end)
end

function MiningZone:respawnZone()
    self.isActive = true
    
    if self.zoneModel then
        local tween = TweenService:Create(self.zoneModel, TweenInfo.new(1), {Transparency = 0.8})
        tween:Play()
    end
end

-- Conflict Zone Class
local ConflictZone = {}
ConflictZone.__index = ConflictZone

function ConflictZone.new(config)
    local self = setmetatable({}, ConflictZone)
    
    self.name = config.name
    self.position = config.position
    self.size = config.size
    self.captureTime = config.captureTime
    self.bonusMultiplier = config.bonusMultiplier
    
    self.controllingGuild = nil
    self.captureProgress = 0
    self.zoneModel = nil
    
    return self
end

function ConflictZone:createZoneModel()
    local zone = Instance.new("Part")
    zone.Name = self.name
    zone.Position = self.position
    zone.Size = self.size
    zone.Anchored = true
    zone.CanCollide = false
    zone.Transparency = 0.7
    zone.Color = Color3.fromRGB(255, 255, 255) -- Neutral color
    
    -- Add capture prompt
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = zone
    proximityPrompt.ActionText = "Capture Zone"
    proximityPrompt.ObjectText = self.name
    proximityPrompt.HoldDuration = 1
    proximityPrompt.MaxActivationDistance = 15
    
    self.zoneModel = zone
    return zone
end

function ConflictZone:startCapture(player)
    local playerGuild = self:getPlayerGuild(player)
    if not playerGuild then
        return false, "No guild affiliation"
    end
    
    if self.controllingGuild == playerGuild then
        return false, "Already controlled by your guild"
    end
    
    -- Start capture process
    self.captureProgress = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        self.captureProgress = self.captureProgress + deltaTime
        
        -- Update visual feedback
        if self.zoneModel then
            local progressColor = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(255, 0, 0), self.captureProgress / self.captureTime)
            self.zoneModel.Color = progressColor
        end
        
        if self.captureProgress >= self.captureTime then
            -- Capture complete
            self:completeCapture(playerGuild)
            connection:Disconnect()
        end
    end)
    
    return true, "Capture started"
end

function ConflictZone:completeCapture(guild)
    self.controllingGuild = guild
    self.captureProgress = 0
    
    -- Visual feedback
    if self.zoneModel then
        local guildColors = {
            Fire = Color3.fromRGB(255, 69, 0),
            Ice = Color3.fromRGB(135, 206, 235),
            Nature = Color3.fromRGB(34, 139, 34),
            Tech = Color3.fromRGB(0, 191, 255),
            Shadow = Color3.fromRGB(75, 0, 130)
        }
        
        local tween = TweenService:Create(self.zoneModel, TweenInfo.new(1), {Color = guildColors[guild] or Color3.fromRGB(255, 0, 0)})
        tween:Play()
    end
    
    -- Apply bonus multiplier to guild members
    self:applyGuildBonus(guild)
end

-- Neutral Zone Class
local NeutralZone = {}
NeutralZone.__index = NeutralZone

function NeutralZone.new(config)
    local self = setmetatable({}, NeutralZone)
    
    self.name = config.name
    self.position = config.position
    self.size = config.size
    self.safeZone = config.safeZone
    
    self.zoneModel = nil
    
    return self
end

function NeutralZone:createZoneModel()
    local zone = Instance.new("Part")
    zone.Name = self.name
    zone.Position = self.position
    zone.Size = self.size
    zone.Anchored = true
    zone.CanCollide = false
    zone.Transparency = 0.6
    zone.Color = Color3.fromRGB(0, 255, 0) -- Green for safe zones
    
    -- Add safe zone forcefield effect
    local forcefield = Instance.new("Part")
    forcefield.Name = "Forcefield"
    forcefield.Position = self.position
    forcefield.Size = self.size + Vector3.new(5, 5, 5)
    forcefield.Anchored = true
    forcefield.CanCollide = false
    forcefield.Transparency = 0.9
    forcefield.Color = Color3.fromRGB(0, 255, 0)
    forcefield.Parent = zone
    
    self.zoneModel = zone
    return zone
end

-- Battlefield Manager
local BattlefieldManager = {}

function BattlefieldManager:initialize()
    self.miningZones = {}
    self.conflictZones = {}
    self.neutralZones = {}
    
    -- Create all zones
    for _, config in ipairs(BATTLEFIELD_CONFIG.MINING_ZONES) do
        local zone = MiningZone.new(config)
        zone:createZoneModel()
        table.insert(self.miningZones, zone)
    end
    
    for _, config in ipairs(BATTLEFIELD_CONFIG.CONFLICT_ZONES) do
        local zone = ConflictZone.new(config)
        zone:createZoneModel()
        table.insert(self.conflictZones, zone)
    end
    
    for _, config in ipairs(BATTLEFIELD_CONFIG.NEUTRAL_ZONES) do
        local zone = NeutralZone.new(config)
        zone:createZoneModel()
        table.insert(self.neutralZones, zone)
    end
    
    -- Set up event handlers
    self:setupEventHandlers()
end

function BattlefieldManager:setupEventHandlers()
    -- Handle mining zone interactions
    for _, zone in ipairs(self.miningZones) do
        if zone.zoneModel then
            local proximityPrompt = zone.zoneModel:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                proximityPrompt.Triggered:Connect(function(player)
                    zone:startMining(player)
                end)
            end
        end
    end
    
    -- Handle conflict zone interactions
    for _, zone in ipairs(self.conflictZones) do
        if zone.zoneModel then
            local proximityPrompt = zone.zoneModel:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                proximityPrompt.Triggered:Connect(function(player)
                    zone:startCapture(player)
                end)
            end
        end
    end
end

-- Utility functions
function CentralBattlefield:getPlayerData(player)
    -- This would integrate with your existing player data system
    return {
        resources = {
            Iron = 0,
            Gold = 0,
            Diamond = 0,
            Crystal = 0
        },
        coins = 0,
        guild = "Fire" -- Default guild
    }
end

function CentralBattlefield:getPlayerGuild(player)
    local playerData = self:getPlayerData(player)
    return playerData.guild
end

function CentralBattlefield:updatePlayerUI(player)
    -- Update player's UI with new resource counts
    -- This would integrate with your existing UI system
end

function CentralBattlefield:applyGuildBonus(guild)
    -- Apply bonus multiplier to all guild members in the zone
    -- This would integrate with your existing guild system
end

-- Initialize the battlefield
function CentralBattlefield:init()
    BattlefieldManager:initialize()
    print("Central Battlefield Environment initialized!")
end

return CentralBattlefield