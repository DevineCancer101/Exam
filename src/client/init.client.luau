--[[
    init.client.luau
    Main client script - simplified version for testing
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetRanchUI"
screenGui.Parent = player.PlayerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Pet Ranch Game"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Coins display
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(1, 0, 0, 25)
coinsLabel.Position = UDim2.new(0, 0, 0, 35)
coinsLabel.BackgroundTransparency = 1
coinsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
coinsLabel.Text = "Coins: 500"
coinsLabel.TextScaled = true
coinsLabel.Font = Enum.Font.SourceSans
coinsLabel.Parent = mainFrame

-- Ranch info
local ranchLabel = Instance.new("TextLabel")
ranchLabel.Name = "RanchLabel"
ranchLabel.Size = UDim2.new(1, 0, 0, 25)
ranchLabel.Position = UDim2.new(0, 0, 0, 65)
ranchLabel.BackgroundTransparency = 1
ranchLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
ranchLabel.Text = "Ranch: None"
ranchLabel.TextScaled = true
ranchLabel.Font = Enum.Font.SourceSans
ranchLabel.Parent = mainFrame

-- Buy pet button
local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.Size = UDim2.new(0.8, 0, 0, 40)
buyButton.Position = UDim2.new(0.1, 0, 0, 100)
buyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.Text = "Buy Fire Pet (200 coins)"
buyButton.TextScaled = true
buyButton.Font = Enum.Font.SourceSansBold
buyButton.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Text = "Ready to play!"
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Handle player joined
local function onPlayerJoined(data)
    print("🎮 Player joined with data:", data)
    
    if data.ranchId then
        ranchLabel.Text = "Ranch: " .. data.ranchName
    end
    
    if data.coins then
        coinsLabel.Text = "Coins: " .. data.coins
    end
    
    statusLabel.Text = "Welcome to your ranch!"
end

-- Handle pet purchased
local function onPetPurchased(data)
    print("🐾 Pet purchased:", data)
    
    if data.pet then
        statusLabel.Text = "Pet purchased: " .. data.pet.name
    end
    
    if data.remainingCoins then
        coinsLabel.Text = "Coins: " .. data.remainingCoins
    end
end

-- Buy pet function
local function buyPet()
    print("🛍️ Attempting to buy pet...")
    
    local petPurchaseEvent = RemoteEvents:FindFirstChild("PetPurchaseRequest")
    if petPurchaseEvent then
        petPurchaseEvent:FireServer("FIRE_PET")
        statusLabel.Text = "Requesting pet purchase..."
    else
        statusLabel.Text = "Error: Pet shop not available"
    end
end

-- Connect remote events
local playerJoinedEvent = RemoteEvents:FindFirstChild("PlayerJoined")
if playerJoinedEvent then
    playerJoinedEvent.OnClientEvent:Connect(onPlayerJoined)
end

local petPurchasedEvent = RemoteEvents:FindFirstChild("PetPurchased")
if petPurchasedEvent then
    petPurchasedEvent.OnClientEvent:Connect(onPetPurchased)
end

-- Connect button
buyButton.MouseButton1Click:Connect(buyPet)

print("🎮 Pet Ranch client initialized!")
print("👤 Player:", player.Name)