-- Battlefield Terrain Generator
-- Creates the physical environment for the central battlefield

local TerrainGenerator = {}

-- Services
local Terrain = workspace.Terrain
local RunService = game:GetService("RunService")

-- Configuration
local TERRAIN_CONFIG = {
    BATTLEFIELD_SIZE = {
        width = 1000,
        length = 1000,
        height = 100
    },
    
    TERRAIN_FEATURES = {
        -- Central valley (main conflict area)
        centralValley = {
            position = Vector3.new(0, 0, 0),
            size = Vector3.new(400, 50, 400),
            type = "valley"
        },
        
        -- Mountain ranges around the battlefield
        northMountains = {
            position = Vector3.new(0, 0, 300),
            size = Vector3.new(800, 150, 200),
            type = "mountain"
        },
        
        southMountains = {
            position = Vector3.new(0, 0, -300),
            size = Vector3.new(800, 150, 200),
            type = "mountain"
        },
        
        eastMountains = {
            position = Vector3.new(300, 0, 0),
            size = Vector3.new(200, 150, 800),
            type = "mountain"
        },
        
        westMountains = {
            position = Vector3.new(-300, 0, 0),
            size = Vector3.new(200, 150, 800),
            type = "mountain"
        },
        
        -- Strategic high points
        centralPeak = {
            position = Vector3.new(0, 0, 0),
            size = Vector3.new(100, 80, 100),
            type = "peak"
        },
        
        -- Mining areas
        ironValley = {
            position = Vector3.new(0, 0, 0),
            size = Vector3.new(100, 20, 100),
            type = "mining"
        },
        
        goldPeak = {
            position = Vector3.new(150, 0, 0),
            size = Vector3.new(80, 60, 80),
            type = "mining"
        },
        
        diamondCavern = {
            position = Vector3.new(-150, 0, 0),
            size = Vector3.new(60, 40, 60),
            type = "mining"
        },
        
        crystalRidge = {
            position = Vector3.new(0, 0, 150),
            size = Vector3.new(70, 40, 70),
            type = "mining"
        }
    },
    
    MATERIALS = {
        grass = Enum.Material.Grass,
        rock = Enum.Material.Rock,
        sand = Enum.Material.Sand,
        snow = Enum.Material.Snow,
        metal = Enum.Material.Metal,
        concrete = Enum.Material.Concrete
    }
}

-- Terrain Generation Functions
function TerrainGenerator:generateBaseTerrain()
    -- Clear existing terrain
    Terrain:Clear()
    
    -- Set base material
    Terrain.Material = TERRAIN_CONFIG.MATERIALS.grass
    
    -- Create base plane
    local baseSize = TERRAIN_CONFIG.BATTLEFIELD_SIZE
    Terrain:FillBlock(
        CFrame.new(0, 0, 0),
        Vector3.new(baseSize.width, 1, baseSize.length),
        TERRAIN_CONFIG.MATERIALS.grass
    )
end

function TerrainGenerator:generateMountainRange(config)
    local center = config.position
    local size = config.size
    
    -- Create mountain range using multiple peaks
    for i = 1, 5 do
        local peakOffset = Vector3.new(
            (i - 3) * (size.X / 5),
            0,
            math.random(-size.Z/4, size.Z/4)
        )
        
        local peakHeight = size.Y * (0.5 + math.random() * 0.5)
        local peakSize = Vector3.new(
            size.X / 8,
            peakHeight,
            size.Z / 8
        )
        
        Terrain:FillBlock(
            CFrame.new(center + peakOffset),
            peakSize,
            TERRAIN_CONFIG.MATERIALS.rock
        )
    end
end

function TerrainGenerator:generateValley(config)
    local center = config.position
    local size = config.size
    
    -- Create valley by removing terrain
    Terrain:FillBlock(
        CFrame.new(center),
        size,
        Enum.Material.Air
    )
    
    -- Add valley floor
    Terrain:FillBlock(
        CFrame.new(center),
        Vector3.new(size.X, 1, size.Z),
        TERRAIN_CONFIG.MATERIALS.sand
    )
end

function TerrainGenerator:generateMiningArea(config)
    local center = config.position
    local size = config.size
    
    -- Create mining pit
    local pitDepth = size.Y * 0.8
    local pitSize = Vector3.new(size.X * 0.8, pitDepth, size.Z * 0.8)
    
    Terrain:FillBlock(
        CFrame.new(center - Vector3.new(0, pitDepth/2, 0)),
        pitSize,
        Enum.Material.Air
    )
    
    -- Add mining floor
    Terrain:FillBlock(
        CFrame.new(center - Vector3.new(0, pitDepth, 0)),
        Vector3.new(size.X, 1, size.Z),
        TERRAIN_CONFIG.MATERIALS.rock
    )
    
    -- Add mining walls
    local wallThickness = 5
    local wallHeight = pitDepth * 0.7
    
    -- North wall
    Terrain:FillBlock(
        CFrame.new(center + Vector3.new(0, wallHeight/2, size.Z/2)),
        Vector3.new(size.X, wallHeight, wallThickness),
        TERRAIN_CONFIG.MATERIALS.rock
    )
    
    -- South wall
    Terrain:FillBlock(
        CFrame.new(center + Vector3.new(0, wallHeight/2, -size.Z/2)),
        Vector3.new(size.X, wallHeight, wallThickness),
        TERRAIN_CONFIG.MATERIALS.rock
    )
    
    -- East wall
    Terrain:FillBlock(
        CFrame.new(center + Vector3.new(size.X/2, wallHeight/2, 0)),
        Vector3.new(wallThickness, wallHeight, size.Z),
        TERRAIN_CONFIG.MATERIALS.rock
    )
    
    -- West wall
    Terrain:FillBlock(
        CFrame.new(center + Vector3.new(-size.X/2, wallHeight/2, 0)),
        Vector3.new(wallThickness, wallHeight, size.Z),
        TERRAIN_CONFIG.MATERIALS.rock
    )
end

function TerrainGenerator:generateStrategicFeatures()
    -- Create central command post
    local commandPost = Instance.new("Part")
    commandPost.Name = "CommandPost"
    commandPost.Position = Vector3.new(0, 10, 0)
    commandPost.Size = Vector3.new(20, 20, 20)
    commandPost.Anchored = true
    commandPost.Material = TERRAIN_CONFIG.MATERIALS.metal
    commandPost.Color = Color3.fromRGB(100, 100, 100)
    commandPost.Parent = workspace
    
    -- Create watchtowers at strategic points
    local towerPositions = {
        Vector3.new(100, 15, 100),
        Vector3.new(-100, 15, 100),
        Vector3.new(100, 15, -100),
        Vector3.new(-100, 15, -100)
    }
    
    for i, position in ipairs(towerPositions) do
        local tower = Instance.new("Part")
        tower.Name = "Watchtower_" .. i
        tower.Position = position
        tower.Size = Vector3.new(10, 30, 10)
        tower.Anchored = true
        tower.Material = TERRAIN_CONFIG.MATERIALS.concrete
        tower.Color = Color3.fromRGB(80, 80, 80)
        tower.Parent = workspace
        
        -- Add tower platform
        local platform = Instance.new("Part")
        platform.Name = "TowerPlatform_" .. i
        platform.Position = position + Vector3.new(0, 20, 0)
        platform.Size = Vector3.new(15, 2, 15)
        platform.Anchored = true
        platform.Material = TERRAIN_CONFIG.MATERIALS.concrete
        platform.Color = Color3.fromRGB(60, 60, 60)
        platform.Parent = workspace
    end
    
    -- Create supply depots
    local depotPositions = {
        Vector3.new(200, 5, 0),
        Vector3.new(-200, 5, 0),
        Vector3.new(0, 5, 200),
        Vector3.new(0, 5, -200)
    }
    
    for i, position in ipairs(depotPositions) do
        local depot = Instance.new("Part")
        depot.Name = "SupplyDepot_" .. i
        depot.Position = position
        depot.Size = Vector3.new(25, 15, 25)
        depot.Anchored = true
        depot.Material = TERRAIN_CONFIG.MATERIALS.metal
        depot.Color = Color3.fromRGB(120, 120, 120)
        depot.Parent = workspace
        
        -- Add depot roof
        local roof = Instance.new("Part")
        roof.Name = "DepotRoof_" .. i
        roof.Position = position + Vector3.new(0, 10, 0)
        roof.Size = Vector3.new(30, 2, 30)
        roof.Anchored = true
        roof.Material = TERRAIN_CONFIG.MATERIALS.metal
        roof.Color = Color3.fromRGB(100, 100, 100)
        roof.Parent = workspace
    end
end

function TerrainGenerator:generateSafeZones()
    -- Create trading post safe zone
    local tradingPost = Instance.new("Part")
    tradingPost.Name = "TradingPost"
    tradingPost.Position = Vector3.new(300, 5, 0)
    tradingPost.Size = Vector3.new(40, 20, 40)
    tradingPost.Anchored = true
    tradingPost.Material = TERRAIN_CONFIG.MATERIALS.concrete
    tradingPost.Color = Color3.fromRGB(0, 255, 0) -- Green for safe zone
    tradingPost.Transparency = 0.3
    tradingPost.Parent = workspace
    
    -- Create medical bay safe zone
    local medicalBay = Instance.new("Part")
    medicalBay.Name = "MedicalBay"
    medicalBay.Position = Vector3.new(-300, 5, 0)
    medicalBay.Size = Vector3.new(35, 18, 35)
    medicalBay.Anchored = true
    medicalBay.Material = TERRAIN_CONFIG.MATERIALS.concrete
    medicalBay.Color = Color3.fromRGB(0, 255, 0) -- Green for safe zone
    medicalBay.Transparency = 0.3
    medicalBay.Parent = workspace
end

function TerrainGenerator:generateEnvironmentalEffects()
    -- Add atmospheric effects
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = game.Lighting
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(199, 199, 199)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0
    atmosphere.Haze = 0
    
    -- Add fog
    local fog = Instance.new("Fog")
    fog.Parent = game.Lighting
    fog.Color = Color3.fromRGB(150, 150, 150)
    fog.Transparency = 0.5
    fog.Enabled = true
    
    -- Add wind
    local wind = Instance.new("Wind")
    wind.Parent = game.Lighting
    wind.Speed = 5
    wind.WindDirection = Vector3.new(1, 0, 0)
    wind.Enabled = true
end

function TerrainGenerator:generateSpawnPoints()
    -- Create spawn points for each guild
    local guildSpawns = {
        Fire = Vector3.new(50, 10, 50),
        Ice = Vector3.new(-50, 10, 50),
        Nature = Vector3.new(50, 10, -50),
        Tech = Vector3.new(-50, 10, -50),
        Shadow = Vector3.new(0, 10, 0)
    }
    
    for guildName, position in pairs(guildSpawns) do
        local spawnPoint = Instance.new("Part")
        spawnPoint.Name = guildName .. "_Spawn"
        spawnPoint.Position = position
        spawnPoint.Size = Vector3.new(10, 1, 10)
        spawnPoint.Anchored = true
        spawnPoint.Material = TERRAIN_CONFIG.MATERIALS.concrete
        spawnPoint.Color = Color3.fromRGB(255, 255, 255)
        spawnPoint.Parent = workspace
        
        -- Add spawn marker
        local marker = Instance.new("Part")
        marker.Name = guildName .. "_Marker"
        marker.Position = position + Vector3.new(0, 5, 0)
        marker.Size = Vector3.new(2, 10, 2)
        marker.Anchored = true
        marker.Material = TERRAIN_CONFIG.MATERIALS.metal
        marker.Color = Color3.fromRGB(255, 0, 0)
        marker.Parent = workspace
    end
end

-- Main generation function
function TerrainGenerator:generateBattlefield()
    print("Generating battlefield terrain...")
    
    -- Generate base terrain
    self:generateBaseTerrain()
    
    -- Generate mountain ranges
    self:generateMountainRange(TERRAIN_CONFIG.TERRAIN_FEATURES.northMountains)
    self:generateMountainRange(TERRAIN_CONFIG.TERRAIN_FEATURES.southMountains)
    self:generateMountainRange(TERRAIN_CONFIG.TERRAIN_FEATURES.eastMountains)
    self:generateMountainRange(TERRAIN_CONFIG.TERRAIN_FEATURES.westMountains)
    
    -- Generate central valley
    self:generateValley(TERRAIN_CONFIG.TERRAIN_FEATURES.centralValley)
    
    -- Generate mining areas
    self:generateMiningArea(TERRAIN_CONFIG.TERRAIN_FEATURES.ironValley)
    self:generateMiningArea(TERRAIN_CONFIG.TERRAIN_FEATURES.goldPeak)
    self:generateMiningArea(TERRAIN_CONFIG.TERRAIN_FEATURES.diamondCavern)
    self:generateMiningArea(TERRAIN_CONFIG.TERRAIN_FEATURES.crystalRidge)
    
    -- Generate strategic features
    self:generateStrategicFeatures()
    
    -- Generate safe zones
    self:generateSafeZones()
    
    -- Generate spawn points
    self:generateSpawnPoints()
    
    -- Generate environmental effects
    self:generateEnvironmentalEffects()
    
    print("Battlefield terrain generation complete!")
end

return TerrainGenerator