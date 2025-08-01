-- GuildSelectionClient.lua
-- Place this in StarterGui (as a LocalScript)

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local RemoteEvents = ServerStorage:WaitForChild("RemoteEvents")
local GuildSelectionRemote = RemoteEvents:WaitForChild("GuildSelection")

-- GUI Variables
local guildSelectionGui = nil
local selectedGuild = nil

-- Create Guild Selection GUI
function CreateGuildSelectionGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GuildSelectionGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Background Frame
    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "Background"
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    backgroundFrame.BackgroundTransparency = 0.3
    backgroundFrame.Parent = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = backgroundFrame
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Choose Your Guild"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    subtitleLabel.Position = UDim2.new(0, 0, 0.15, 0)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "This choice is permanent and will determine your allies and enemies!"
    subtitleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    subtitleLabel.TextScaled = true
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = mainFrame
    
    -- Guilds Container
    local guildsFrame = Instance.new("ScrollingFrame")
    guildsFrame.Name = "GuildsFrame"
    guildsFrame.Size = UDim2.new(1, -40, 0.6, 0)
    guildsFrame.Position = UDim2.new(0, 20, 0.25, 0)
    guildsFrame.BackgroundTransparency = 1
    guildsFrame.ScrollBarThickness = 10
    guildsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    guildsFrame.Parent = mainFrame
    
    -- Grid Layout for guilds
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.45, 0, 0.8, 0)
    gridLayout.CellPadding = UDim2.new(0.05, 0, 0.1, 0)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    gridLayout.Parent = guildsFrame
    
    -- Confirm Button
    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0.3, 0, 0.08, 0)
    confirmButton.Position = UDim2.new(0.35, 0, 0.9, 0)
    confirmButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    confirmButton.Text = "Join Guild"
    confirmButton.TextColor3 = Color3.new(1, 1, 1)
    confirmButton.TextScaled = true
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Visible = false
    confirmButton.Parent = mainFrame
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 10)
    confirmCorner.Parent = confirmButton
    
    guildSelectionGui = screenGui
    return screenGui, guildsFrame, confirmButton
end

function CreateGuildCard(guildData, parent, confirmButton)
    -- Guild Card Frame
    local cardFrame = Instance.new("TextButton")
    cardFrame.Name = guildData.Name
    cardFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    cardFrame.BorderSizePixel = 0
    cardFrame.AutoButtonColor = false
    cardFrame.Text = ""
    cardFrame.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 15)
    cardCorner.Parent = cardFrame
    
    -- Guild Color Border
    local colorBorder = Instance.new("Frame")
    colorBorder.Name = "ColorBorder"
    colorBorder.Size = UDim2.new(1, 0, 0.15, 0)
    colorBorder.Position = UDim2.new(0, 0, 0, 0)
    colorBorder.BackgroundColor3 = guildData.Color
    colorBorder.BorderSizePixel = 0
    colorBorder.Parent = cardFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 15)
    borderCorner.Parent = colorBorder
    
    -- Hide bottom corners of border
    local borderCover = Instance.new("Frame")
    borderCover.Size = UDim2.new(1, 0, 0.5, 0)
    borderCover.Position = UDim2.new(0, 0, 0.5, 0)
    borderCover.BackgroundColor3 = guildData.Color
    borderCover.BorderSizePixel = 0
    borderCover.Parent = colorBorder
    
    -- Guild Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "GuildName"
    nameLabel.Size = UDim2.new(1, -10, 0.2, 0)
    nameLabel.Position = UDim2.new(0, 5, 0.15, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = guildData.DisplayName
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = cardFrame
    
    -- Guild Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -10, 0.25, 0)
    descLabel.Position = UDim2.new(0, 5, 0.35, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = guildData.Description
    descLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    descLabel.TextScaled = true
    descLabel.TextWrapped = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.Parent = cardFrame
    
    -- Benefits List
    local benefitsLabel = Instance.new("TextLabel")
    benefitsLabel.Name = "Benefits"
    benefitsLabel.Size = UDim2.new(1, -10, 0.25, 0)
    benefitsLabel.Position = UDim2.new(0, 5, 0.6, 0)
    benefitsLabel.BackgroundTransparency = 1
    benefitsLabel.Text = "Benefits:\n• " .. table.concat(guildData.Benefits, "\n• ")
    benefitsLabel.TextColor3 = Color3.new(0.6, 1, 0.6)
    benefitsLabel.TextScaled = true
    benefitsLabel.TextWrapped = true
    benefitsLabel.Font = Enum.Font.Gotham
    benefitsLabel.TextXAlignment = Enum.TextXAlignment.Left
    benefitsLabel.Parent = cardFrame
    
    -- Selection indicator
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Name = "SelectionFrame"
    selectionFrame.Size = UDim2.new(1, 4, 1, 4)
    selectionFrame.Position = UDim2.new(0, -2, 0, -2)
    selectionFrame.BackgroundColor3 = Color3.new(1, 1, 0)
    selectionFrame.BorderSizePixel = 0
    selectionFrame.Visible = false
    selectionFrame.Parent = cardFrame
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(0, 17)
    selectionCorner.Parent = selectionFrame
    
    -- Click handling
    cardFrame.MouseButton1Click:Connect(function()
        -- Deselect other cards
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("TextButton") and child ~= cardFrame then
                local otherSelection = child:FindFirstChild("SelectionFrame")
                if otherSelection then
                    otherSelection.Visible = false
                end
            end
        end
        
        -- Select this card
        selectionFrame.Visible = true
        selectedGuild = guildData.Name
        confirmButton.Visible = true
        
        -- Animate selection
        local tween = TweenService:Create(
            cardFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = cardFrame.Size + UDim2.new(0, 0, 0.05, 0)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            local reverseTween = TweenService:Create(
                cardFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = cardFrame.Size - UDim2.new(0, 0, 0.05, 0)}
            )
            reverseTween:Play()
        end)
    end)
end

-- Handle server responses
GuildSelectionRemote.OnClientEvent:Connect(function(action, data)
    if action == "ShowSelection" then
        -- Create GUI
        local screenGui, guildsFrame, confirmButton = CreateGuildSelectionGUI()
        screenGui.Parent = playerGui
        
        -- Create guild cards
        for _, guildData in pairs(data) do
            CreateGuildCard(guildData, guildsFrame, confirmButton)
        end
        
        -- Handle confirm button
        confirmButton.MouseButton1Click:Connect(function()
            if selectedGuild then
                GuildSelectionRemote:FireServer("SelectGuild", selectedGuild)
                confirmButton.Text = "Joining..."
                confirmButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
            end
        end)
        
    elseif action == "GuildSelected" then
        -- Remove selection GUI
        if guildSelectionGui then
            guildSelectionGui:Destroy()
            guildSelectionGui = nil
        end
        
    elseif action == "Error" then
        -- Show error message
        if guildSelectionGui then
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
            errorLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
            errorLabel.BackgroundColor3 = Color3.new(1, 0, 0)
            errorLabel.Text = "Error: " .. data
            errorLabel.TextColor3 = Color3.new(1, 1, 1)
            errorLabel.TextScaled = true
            errorLabel.Font = Enum.Font.GothamBold
            errorLabel.Parent = guildSelectionGui.Background.MainFrame
            
            -- Remove error after 3 seconds
            wait(3)
            errorLabel:Destroy()
        end
    end
end)

print("GuildSelectionClient loaded successfully!")