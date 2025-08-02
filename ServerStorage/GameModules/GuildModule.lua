-- GuildModule.lua
-- Place this in ServerStorage/GameModules/

local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local GuildModule = {}

-- Guild configuration
local GuildConfigs = {
    RedGuild = {
        Name = "Crimson Warriors",
        Color = Color3.fromRGB(255, 0, 0),
        TeamColor = BrickColor.new("Bright red"),
        SpawnLocation = Vector3.new(-100, 10, 0),
        Description = "Fierce fighters who value strength and honor in battle.",
        Benefits = {"+ 10% Combat Damage", "Heavy Armor Specialization"}
    },
    BlueGuild = {
        Name = "Azure Defenders",
        Color = Color3.fromRGB(0, 100, 255),
        TeamColor = BrickColor.new("Bright blue"),
        SpawnLocation = Vector3.new(100, 10, 0),
        Description = "Strategic defenders who excel at protecting their allies.",
        Benefits = {"+ 15% Defense", "Shield Mastery"}
    },
    GreenGuild = {
        Name = "Emerald Miners",
        Color = Color3.fromRGB(0, 255, 0),
        TeamColor = BrickColor.new("Bright green"),
        SpawnLocation = Vector3.new(0, 10, -100),
        Description = "Master miners who can extract resources faster than anyone.",
        Benefits = {"+ 25% Mining Speed", "Resource Detection"}
    },
    YellowGuild = {
        Name = "Golden Merchants",
        Color = Color3.fromRGB(255, 255, 0),
        TeamColor = BrickColor.new("New Yeller"),
        SpawnLocation = Vector3.new(0, 10, 100),
        Description = "Wealthy traders who get better prices for their goods.",
        Benefits = {"+ 20% Coin Gain", "Better Shop Prices"}
    }
}

function GuildModule.GetGuildConfigs()
    return GuildConfigs
end

function GuildModule.GetGuildConfig(guildName)
    return GuildConfigs[guildName]
end

function GuildModule.GetAvailableGuilds()
    local guilds = {}
    for guildName, config in pairs(GuildConfigs) do
        table.insert(guilds, {
            Name = guildName,
            DisplayName = config.Name,
            Description = config.Description,
            Benefits = config.Benefits,
            Color = config.Color
        })
    end
    return guilds
end

function GuildModule.AssignPlayerToGuild(player, guildName)
    local guildConfig = GuildConfigs[guildName]
    if not guildConfig then
        warn("Invalid guild name: " .. tostring(guildName))
        return false
    end
    
    -- Find or create the team
    local team = Teams:FindFirstChild(guildName)
    if not team then
        team = Instance.new("Team")
        team.Name = guildName
        team.TeamColor = guildConfig.TeamColor
        team.AutoAssignable = false
        team.Parent = Teams
    end
    
    -- Assign player to team
    player.Team = team
    player.TeamColor = guildConfig.TeamColor
    
    return true
end

function GuildModule.GetPlayerGuild(player)
    if player.Team then
        return player.Team.Name
    end
    return nil
end

function GuildModule.GetGuildSpawnLocation(guildName)
    local guildConfig = GuildConfigs[guildName]
    if guildConfig then
        return guildConfig.SpawnLocation
    end
    return Vector3.new(0, 10, 0) -- Default spawn
end

function GuildModule.SpawnPlayerInGuild(player, guildName)
    local guildConfig = GuildConfigs[guildName]
    if not guildConfig then return false end
    
    -- Wait for character to load
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        player.CharacterAdded:Wait()
        wait(0.1) -- Small delay for character to fully load
    end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Try to find the guild spawn location in workspace first
        local guildFolder = Workspace:FindFirstChild("Guilds")
        local specificGuildFolder = guildFolder and guildFolder:FindFirstChild(guildName)
        local spawnPart = specificGuildFolder and specificGuildFolder:FindFirstChild("SpawnPart")
        
        if spawnPart then
            -- Use the physical spawn part location
            humanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
        else
            -- Use configured spawn location
            humanoidRootPart.CFrame = CFrame.new(guildConfig.SpawnLocation)
        end
        return true
    end
    
    return false
end

function GuildModule.IsPlayerInSafeZone(player, position)
    local guildName = GuildModule.GetPlayerGuild(player)
    if not guildName then return false end
    
    local guildFolder = Workspace:FindFirstChild("Guilds")
    local specificGuildFolder = guildFolder and guildFolder:FindFirstChild(guildName)
    local safeZone = specificGuildFolder and specificGuildFolder:FindFirstChild("SafeZone")
    
    if safeZone then
        -- Check if position is within the safe zone
        local distance = (position - safeZone.Position).Magnitude
        local safeRadius = math.max(safeZone.Size.X, safeZone.Size.Z) / 2
        return distance <= safeRadius
    end
    
    return false
end

function GuildModule.GetGuildMembers(guildName)
    local members = {}
    local team = Teams:FindFirstChild(guildName)
    if team then
        for _, player in pairs(team:GetPlayers()) do
            table.insert(members, player)
        end
    end
    return members
end

function GuildModule.GetGuildMemberCount(guildName)
    local team = Teams:FindFirstChild(guildName)
    if team then
        return #team:GetPlayers()
    end
    return 0
end

function GuildModule.ArePlayersEnemies(player1, player2)
    if not player1.Team or not player2.Team then
        return true -- Players without teams are considered enemies
    end
    
    return player1.Team ~= player2.Team
end

return GuildModule