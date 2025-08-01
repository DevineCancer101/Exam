-- GameHUDClient.lua (CORRECTED VERSION)
-- Place this in StarterGui (as a LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events (FIXED: Now using ReplicatedStorage)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerSpawnRemote = RemoteEvents:WaitForChild("PlayerSpawn")

-- HUD Variables
local gameHUD = nil
local playerData = {}

-- Create Game HUD
function CreateGameHUD()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0.08, 0)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.new(0, 0, 0)
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.Parent = screenGui
    
    -- Player Info Frame
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Name = "PlayerInfo"
    playerInfoFrame.Size = UDim2.new(0.3, 0, 1, 0)
    playerInfoFrame.Position = UDim2.new(0, 10, 0, 0)
    playerInfoFrame.BackgroundTransparency = 1
    playerInfoFrame.Parent = topBar
    
    -- Player Name
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Name = "PlayerName"
    playerNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    playerNameLabel.Position = UDim2.new(0, 0, 0, 0)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Text = player.Name
    playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
    playerNameLabel.TextScaled = true
    playerNameLabel.Font = Enum.Font.GothamBold
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLabel.Parent = playerInfoFrame
    
    -- Guild Name
    local guildNameLabel = Instance.new("TextLabel")
    guildNameLabel.Name = "GuildName"
    guildNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    guildNameLabel.Position = UDim2.new(0, 0, 0.5, 0)
    guildNameLabel.BackgroundTransparency = 1
    guildNameLabel.Text = "Loading..."
    guildNameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    guildNameLabel.TextScaled = true
    guildNameLabel.Font = Enum.Font.Gotham
    guildNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    guildNameLabel.Parent = playerInfoFrame
    
    -- Coins Frame
    local coinsFrame = Instance.new("Frame")
    coinsFrame.Name = "CoinsFrame"
    coinsFrame.Size = UDim2.new(0.15, 0, 0.7, 0)
    coinsFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
    coinsFrame.BackgroundColor3 = Color3.new(1, 1, 0)
    coinsFrame.BorderSizePixel = 0
    coinsFrame.Parent = topBar
    
    local coinsCorner = Instance.new("UICorner")
    coinsCorner.CornerRadius = UDim.new(0, 10)
    coinsCorner.Parent = coinsFrame
    
    -- Coins Icon
    local coinsIcon = Instance.new("TextLabel")
    coinsIcon.Name = "CoinsIcon"
    coinsIcon.Size = UDim2.new(0.3, 0, 1, 0)
    coinsIcon.Position = UDim2.new(0, 0, 0, 0)
    coinsIcon.BackgroundTransparency = 1
    coinsIcon.Text = "💰"
    coinsIcon.TextColor3 = Color3.new(0, 0, 0)
    coinsIcon.TextScaled = true
    coinsIcon.Font = Enum.Font.Gotham
    coinsIcon.Parent = coinsFrame
    
    -- Coins Amount
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsAmount"
    coinsLabel.Size = UDim2.new(0.7, 0, 1, 0)
    coinsLabel.Position = UDim2.new(0.3, 0, 0, 0)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Text = "0"
    coinsLabel.TextColor3 = Color3.new(0, 0, 0)
    coinsLabel.TextScaled = true
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Parent = coinsFrame
    
    -- Level Frame
    local levelFrame = Instance.new("Frame")
    levelFrame.Name = "LevelFrame"
    levelFrame.Size = UDim2.new(0.1, 0, 0.7, 0)
    levelFrame.Position = UDim2.new(0.52, 0, 0.15, 0)
    levelFrame.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    levelFrame.BorderSizePixel = 0
    levelFrame.Parent = topBar
    
    local levelCorner = Instance.new("UICorner")
    levelCorner.CornerRadius = UDim.new(0, 10)
    levelCorner.Parent = levelFrame
    
    -- Level Label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(1, 0, 1, 0)
    levelLabel.Position = UDim2.new(0, 0, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Lv.1"
    levelLabel.TextColor3 = Color3.new(1, 1, 1)
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Parent = levelFrame
    
    -- Mini-map placeholder (future feature)
    local minimapFrame = Instance.new("Frame")
    minimapFrame.Name = "Minimap"
    minimapFrame.Size = UDim2.new(0.15, 0, 1, 0)
    minimapFrame.Position = UDim2.new(0.85, -10, 0, 0)
    minimapFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    minimapFrame.BackgroundTransparency = 0.2
    minimapFrame.BorderSizePixel = 0
    minimapFrame.Parent = topBar
    
    local minimapCorner = Instance.new("UICorner")
    minimapCorner.CornerRadius = UDim.new(0, 10)
    minimapCorner.Parent = minimapFrame
    
    local minimapLabel = Instance.new("TextLabel")
    minimapLabel.Size = UDim2.new(1, 0, 1, 0)
    minimapLabel.BackgroundTransparency = 1
    minimapLabel.Text = "Map"
    minimapLabel.TextColor3 = Color3.new(1, 1, 1)
    minimapLabel.TextScaled = true
    minimapLabel.Font = Enum.Font.Gotham
    minimapLabel.Parent = minimapFrame
    
    gameHUD = screenGui
    return screenGui
end

function UpdateHUD(data)
    if not gameHUD then return end
    
    playerData = data
    
    -- Update guild name
    local guildNameLabel = gameHUD.TopBar.PlayerInfo.GuildName
    if data.Guild then
        -- Get guild display name (you might want to create a mapping)
        local guildDisplayNames = {
            RedGuild = "Crimson Warriors",
            BlueGuild = "Azure Defenders", 
            GreenGuild = "Emerald Miners",
            YellowGuild = "Golden Merchants"
        }
        guildNameLabel.Text = guildDisplayNames[data.Guild] or data.Guild
        
        -- Set guild color
        local guildColors = {
            RedGuild = Color3.fromRGB(255, 0, 0),
            BlueGuild = Color3.fromRGB(0, 100, 255),
            GreenGuild = Color3.fromRGB(0, 255, 0),
            YellowGuild = Color3.fromRGB(255, 255, 0)
        }
        guildNameLabel.TextColor3 = guildColors[data.Guild] or Color3.new(0.8, 0.8, 0.8)
    end
    
    -- Update coins with animation
    local coinsLabel = gameHUD.TopBar.CoinsFrame.CoinsAmount
    local currentCoins = tonumber(coinsLabel.Text) or 0
    local newCoins = data.Coins or 0
    
    if newCoins ~= currentCoins then
        -- Animate coin change
        local tween = TweenService:Create(
            coinsLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextColor3 = Color3.new(0, 1, 0)}
        )
        tween:Play()
        
        coinsLabel.Text = tostring(newCoins)
        
        tween.Completed:Connect(function()
            local reverseTween = TweenService:Create(
                coinsLabel,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {TextColor3 = Color3.new(0, 0, 0)}
            )
            reverseTween:Play()
        end)
    end
    
    -- Update level
    local levelLabel = gameHUD.TopBar.LevelFrame.LevelLabel
    levelLabel.Text = "Lv." .. (data.Level or 1)
end

-- Handle server updates
PlayerSpawnRemote.OnClientEvent:Connect(function(action, data)
    if action == "UpdatePlayerData" then
        if not gameHUD then
            CreateGameHUD()
            gameHUD.Parent = playerGui
        end
        UpdateHUD(data)
    end
end)

-- Create HUD when player spawns
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(2) -- Wait for other systems to load
    if not gameHUD then
        CreateGameHUD()
        gameHUD.Parent = playerGui
        
        -- Request player data from server
        PlayerSpawnRemote:FireServer("RequestPlayerData")
    end
end)

print("GameHUDClient loaded successfully!")