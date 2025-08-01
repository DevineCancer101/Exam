-- MiningClient.lua
-- Place this in StarterGui (as a LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MiningRemote = RemoteEvents:WaitForChild("ResourceMining")

-- Mining UI Variables
local miningGui = nil
local inventoryGui = nil
local currentMiningSession = nil

-- Create Mining Progress UI
function CreateMiningProgressUI(data)
    -- Remove existing mining GUI
    if miningGui then
        miningGui:Destroy()
    end
    
    -- Create main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MiningProgressGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Mining progress frame
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressFrame"
    progressFrame.Size = UDim2.new(0.3, 0, 0.15, 0)
    progressFrame.Position = UDim2.new(0.35, 0, 0.4, 0)
    progressFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    progressFrame.BorderSizePixel = 0
    progressFrame.Parent = screenGui
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 15)
    progressCorner.Parent = progressFrame
    
    -- Mining title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Mining " .. data.ResourceName
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = progressFrame
    
    -- Progress bar background
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBackground"
    progressBg.Size = UDim2.new(0.9, 0, 0.2, 0)
    progressBg.Position = UDim2.new(0.05, 0, 0.4, 0)
    progressBg.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = progressFrame
    
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.CornerRadius = UDim.new(0, 5)
    progressBgCorner.Parent = progressBg
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 5)
    progressBarCorner.Parent = progressBar
    
    -- Time remaining label
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, 0, 0.3, 0)
    timeLabel.Position = UDim2.new(0, 0, 0.7, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = string.format("%.1fs remaining", data.MiningTime)
    timeLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Parent = progressFrame
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.2, 0, 0.6, 0)
    cancelButton.Position = UDim2.new(1.05, 0, 0.2, 0)
    cancelButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    cancelButton.Text = "✖"
    cancelButton.TextColor3 = Color3.new(1, 1, 1)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = progressFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 10)
    cancelCorner.Parent = cancelButton
    
    -- Cancel button functionality
    cancelButton.MouseButton1Click:Connect(function()
        MiningRemote:FireServer("StopMining")
        StopMiningProgress()
    end)
    
    miningGui = screenGui
    
    -- Start progress animation
    StartMiningProgress(data.MiningTime, progressBar, timeLabel)
end

function StartMiningProgress(totalTime, progressBar, timeLabel)
    currentMiningSession = {
        StartTime = tick(),
        TotalTime = totalTime,
        ProgressBar = progressBar,
        TimeLabel = timeLabel
    }
    
    -- Update progress every frame
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not currentMiningSession then
            connection:Disconnect()
            return
        end
        
        local elapsed = tick() - currentMiningSession.StartTime
        local progress = math.min(elapsed / totalTime, 1)
        local timeRemaining = math.max(totalTime - elapsed, 0)
        
        -- Update progress bar
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        
        -- Update time label
        timeLabel.Text = string.format("%.1fs remaining", timeRemaining)
        
        -- Check if mining is complete
        if progress >= 1 then
            connection:Disconnect()
        end
    end)
end

function StopMiningProgress()
    currentMiningSession = nil
    if miningGui then
        -- Fade out animation
        local tween = TweenService:Create(
            miningGui,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Transparency = 1}
        )
        tween:Play()
        tween.Completed:Connect(function()
            miningGui:Destroy()
            miningGui = nil
        end)
    end
end

-- Create Inventory GUI
function CreateInventoryGUI()
    if inventoryGui then
        inventoryGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Inventory button (top right)
    local inventoryButton = Instance.new("TextButton")
    inventoryButton.Name = "InventoryButton"
    inventoryButton.Size = UDim2.new(0.08, 0, 0.06, 0)
    inventoryButton.Position = UDim2.new(0.92, -10, 0.1, 0)
    inventoryButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    inventoryButton.Text = "🎒"
    inventoryButton.TextColor3 = Color3.new(1, 1, 1)
    inventoryButton.TextScaled = true
    inventoryButton.Font = Enum.Font.Gotham
    inventoryButton.Parent = screenGui
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = inventoryButton
    
    -- Inventory panel (hidden by default)
    local inventoryPanel = Instance.new("Frame")
    inventoryPanel.Name = "InventoryPanel"
    inventoryPanel.Size = UDim2.new(0.4, 0, 0.6, 0)
    inventoryPanel.Position = UDim2.new(0.58, 0, 0.18, 0)
    inventoryPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    inventoryPanel.BorderSizePixel = 0
    inventoryPanel.Visible = false
    inventoryPanel.Parent = screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 15)
    panelCorner.Parent = inventoryPanel
    
    -- Panel title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.12, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Resource Inventory"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = inventoryPanel
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.08, 0, 0.08, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0.02, 0)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "✖"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = inventoryPanel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Inventory scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "InventoryScroll"
    scrollFrame.Size = UDim2.new(1, -20, 0.85, 0)
    scrollFrame.Position = UDim2.new(0, 10, 0.12, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = inventoryPanel
    
    -- Layout for inventory items
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Toggle functionality
    local panelVisible = false
    inventoryButton.MouseButton1Click:Connect(function()
        panelVisible = not panelVisible
        inventoryPanel.Visible = panelVisible
        
        if panelVisible then
            -- Request updated inventory
            MiningRemote:FireServer("GetInventory")
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        panelVisible = false
        inventoryPanel.Visible = false
    end)
    
    inventoryGui = screenGui
    return inventoryPanel
end

function UpdateInventoryDisplay(inventory)
    if not inventoryGui then return end
    
    local inventoryPanel = inventoryGui:FindFirstChild("InventoryPanel")
    local scrollFrame = inventoryPanel and inventoryPanel:FindFirstChild("InventoryScroll")
    if not scrollFrame then return end
    
    -- Clear existing items
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Resource values for display
    local resourceValues = {
        Iron = 5,
        Gold = 15,
        Diamond = 50,
        Crystal = 100
    }
    
    -- Add inventory items
    for resourceType, amount in pairs(inventory) do
        if amount > 0 then
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 50)
            itemFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = scrollFrame
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 8)
            itemCorner.Parent = itemFrame
            
            -- Resource name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = resourceType
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = itemFrame
            
            -- Amount
            local amountLabel = Instance.new("TextLabel")
            amountLabel.Size = UDim2.new(0.2, 0, 1, 0)
            amountLabel.Position = UDim2.new(0.4, 0, 0, 0)
            amountLabel.BackgroundTransparency = 1
            amountLabel.Text = "x" .. amount
            amountLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
            amountLabel.TextScaled = true
            amountLabel.Font = Enum.Font.Gotham
            amountLabel.Parent = itemFrame
            
            -- Sell button
            local sellButton = Instance.new("TextButton")
            sellButton.Size = UDim2.new(0.25, 0, 0.7, 0)
            sellButton.Position = UDim2.new(0.7, 0, 0.15, 0)
            sellButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
            sellButton.Text = "Sell All"
            sellButton.TextColor3 = Color3.new(1, 1, 1)
            sellButton.TextScaled = true
            sellButton.Font = Enum.Font.GothamBold
            sellButton.Parent = itemFrame
            
            local sellCorner = Instance.new("UICorner")
            sellCorner.CornerRadius = UDim.new(0, 5)
            sellCorner.Parent = sellButton
            
            -- Sell functionality
            sellButton.MouseButton1Click:Connect(function()
                MiningRemote:FireServer("SellResource", {
                    ResourceType = resourceType,
                    Amount = amount
                })
            end)
        end
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.UIListLayout.AbsoluteContentSize.Y + 10)
end

function ShowMiningNotification(message, color)
    -- Create notification
    local notification = Instance.new("ScreenGui")
    notification.Name = "MiningNotification"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.08, 0)
    frame.Position = UDim2.new(0.35, 0, 0.2, 0)
    frame.BackgroundColor3 = color or Color3.new(0.2, 0.8, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    -- Animate and remove
    wait(0.5)
    local tween = TweenService:Create(frame, TweenInfo.new(0.5), {Position = frame.Position + UDim2.new(0, 0, -0.1, 0), BackgroundTransparency = 1})
    local labelTween = TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1})
    tween:Play()
    labelTween:Play()
    
    tween.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Handle server events
MiningRemote.OnClientEvent:Connect(function(action, data)
    if action == "StartMining" then
        CreateMiningProgressUI(data)
        
    elseif action == "StopMining" then
        StopMiningProgress()
        
    elseif action == "MiningComplete" then
        StopMiningProgress()
        ShowMiningNotification("Mined 1 " .. data.ResourceName .. "! (+" .. data.Value .. " coin value)", Color3.new(0.2, 0.8, 0.2))
        
    elseif action == "InventoryUpdate" then
        UpdateInventoryDisplay(data)
        
    elseif action == "SaleComplete" then
        ShowMiningNotification("Sold " .. data.Amount .. " " .. data.ResourceType .. " for " .. data.CoinsEarned .. " coins!", Color3.new(1, 0.8, 0))
        -- Request updated inventory
        MiningRemote:FireServer("GetInventory")
        
    elseif action == "SaleError" then
        ShowMiningNotification("Sale failed: " .. data, Color3.new(1, 0.2, 0.2))
    end
end)

-- Initialize inventory GUI when character spawns
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(3) -- Wait for other systems
    CreateInventoryGUI()
end)

-- Create inventory GUI if character already exists
if game.Players.LocalPlayer.Character then
    wait(3)
    CreateInventoryGUI()
end

print("Mining client loaded successfully!")