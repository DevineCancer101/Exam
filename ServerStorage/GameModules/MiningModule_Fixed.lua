-- MiningModule.lua (FIXED VERSION WITH BETTER PICKAXE)
-- Replace your existing MiningModule with this version

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MiningModule = {}

-- Mining configuration
local ResourceConfigs = {
    Iron = {
        Name = "Iron Ore",
        Value = 5, -- Coins per unit
        MiningTime = 3, -- Seconds to mine one unit
        MaxNodes = 15, -- Maximum nodes on map
        RespawnTime = 30, -- Seconds to respawn after depletion
        Color = Color3.fromRGB(100, 100, 100),
        Amount = {10, 25}, -- Min, Max amount per node
        Rarity = 0.7 -- Higher = more common
    },
    Gold = {
        Name = "Gold Ore",
        Value = 15,
        MiningTime = 5,
        MaxNodes = 10,
        RespawnTime = 45,
        Color = Color3.fromRGB(255, 215, 0),
        Amount = {5, 15},
        Rarity = 0.5
    },
    Diamond = {
        Name = "Diamond",
        Value = 50,
        MiningTime = 8,
        MaxNodes = 5,
        RespawnTime = 60,
        Color = Color3.fromRGB(185, 242, 255),
        Amount = {2, 8},
        Rarity = 0.3
    },
    Crystal = {
        Name = "Rare Crystal",
        Value = 100,
        MiningTime = 12,
        MaxNodes = 3,
        RespawnTime = 120,
        Color = Color3.fromRGB(255, 0, 255),
        Amount = {1, 5},
        Rarity = 0.1
    }
}

-- Active mining sessions and resource nodes
local ActiveNodes = {}
local MiningSessions = {}
local NodeControllers = {} -- Which guild controls each mining zone

-- Mining zone locations (spread around the map)
local MiningZoneLocations = {
    {Position = Vector3.new(50, 5, 50), Radius = 30, ZoneName = "Eastern Mine"},
    {Position = Vector3.new(-50, 5, 50), Radius = 30, ZoneName = "Western Mine"},
    {Position = Vector3.new(50, 5, -50), Radius = 30, ZoneName = "Northern Mine"},
    {Position = Vector3.new(-50, 5, -50), Radius = 30, ZoneName = "Southern Mine"},
    {Position = Vector3.new(0, 5, 0), Radius = 40, ZoneName = "Central Mine"} -- Contested zone
}

function MiningModule.Initialize()
    -- Create mining zones folder
    local miningZones = Workspace:FindFirstChild("MiningZones")
    if not miningZones then
        miningZones = Instance.new("Folder")
        miningZones.Name = "MiningZones"
        miningZones.Parent = Workspace
    end
    
    -- Generate initial resource nodes
    MiningModule.GenerateResourceNodes()
    
    -- Start respawn system
    MiningModule.StartRespawnSystem()
    
    print("Mining system initialized with " .. #ActiveNodes .. " resource nodes")
end

function MiningModule.CreatePickaxe(player)
    -- Remove existing pickaxe
    MiningModule.RemovePickaxe(player)
    
    -- Create pickaxe tool
    local tool = Instance.new("Tool")
    tool.Name = "Mining Pickaxe"
    tool.RequiresHandle = true
    tool.CanBeDropped = false -- Prevent dropping
    
    -- Create handle (wooden shaft)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.3, 4, 0.3)
    handle.Material = Enum.Material.Wood
    handle.BrickColor = BrickColor.new("Brown")
    handle.CanCollide = false
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = tool
    
    -- Add wood texture
    local handleMesh = Instance.new("CylinderMesh")
    handleMesh.Parent = handle
    
    -- Create pickaxe head (main part)
    local head = Instance.new("Part")
    head.Name = "PickaxeHead"
    head.Size = Vector3.new(2.5, 0.5, 0.8)
    head.Material = Enum.Material.Metal
    head.BrickColor = BrickColor.new("Dark stone grey")
    head.CanCollide = false
    head.TopSurface = Enum.SurfaceType.Smooth
    head.BottomSurface = Enum.SurfaceType.Smooth
    head.Parent = tool
    
    -- Create sharp point 1
    local point1 = Instance.new("WedgePart")
    point1.Name = "Point1"
    point1.Size = Vector3.new(0.3, 0.8, 0.8)
    point1.Material = Enum.Material.Metal
    point1.BrickColor = BrickColor.new("Dark stone grey")
    point1.CanCollide = false
    point1.TopSurface = Enum.SurfaceType.Smooth
    point1.BottomSurface = Enum.SurfaceType.Smooth
    point1.Parent = tool
    
    -- Create sharp point 2 (opposite side)
    local point2 = Instance.new("WedgePart")
    point2.Name = "Point2" 
    point2.Size = Vector3.new(0.3, 0.8, 0.8)
    point2.Material = Enum.Material.Metal
    point2.BrickColor = BrickColor.new("Dark stone grey")
    point2.CanCollide = false
    point2.TopSurface = Enum.SurfaceType.Smooth
    point2.BottomSurface = Enum.SurfaceType.Smooth
    point2.Parent = tool
    
    -- Create connecting part for handle
    local connector = Instance.new("Part")
    connector.Name = "Connector"
    connector.Size = Vector3.new(0.5, 0.3, 0.5)
    connector.Material = Enum.Material.Metal
    connector.BrickColor = BrickColor.new("Really black")
    connector.CanCollide = false
    connector.Shape = Enum.PartType.Cylinder
    connector.TopSurface = Enum.SurfaceType.Smooth
    connector.BottomSurface = Enum.SurfaceType.Smooth
    connector.Parent = tool
    
    -- Weld all parts together
    local welds = {}
    
    -- Weld head to handle
    local weld1 = Instance.new("WeldConstraint")
    weld1.Part0 = handle
    weld1.Part1 = head
    weld1.Parent = handle
    table.insert(welds, weld1)
    
    -- Weld connector to handle
    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = handle
    weld2.Part1 = connector
    weld2.Parent = handle
    table.insert(welds, weld2)
    
    -- Weld point1 to head
    local weld3 = Instance.new("WeldConstraint")
    weld3.Part0 = head
    weld3.Part1 = point1
    weld3.Parent = head
    table.insert(welds, weld3)
    
    -- Weld point2 to head
    local weld4 = Instance.new("WeldConstraint")
    weld4.Part0 = head
    weld4.Part1 = point2
    weld4.Parent = head
    table.insert(welds, weld4)
    
    -- Position parts relative to handle
    local handleCFrame = handle.CFrame
    head.CFrame = handleCFrame * CFrame.new(0, 1.5, 0)
    connector.CFrame = handleCFrame * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, 0, math.rad(90))
    point1.CFrame = head.CFrame * CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
    point2.CFrame = head.CFrame * CFrame.new(-1.2, 0, 0) * CFrame.Angles(0, math.rad(180), math.rad(90))
    
    -- Add mining sounds
    local miningSound = Instance.new("Sound")
    miningSound.Name = "MiningSound"
    miningSound.SoundId = "rbxasset://sounds/impact_wood.mp3"
    miningSound.Volume = 0.7
    miningSound.Pitch = 0.8
    miningSound.Parent = handle
    
    local hitSound = Instance.new("Sound")
    hitSound.Name = "HitSound" 
    hitSound.SoundId = "rbxasset://sounds/metal_hit.mp3"
    hitSound.Volume = 0.5
    hitSound.Pitch = 1.2
    hitSound.Parent = handle
    
    -- Add sparkle effect
    local attachment = Instance.new("Attachment")
    attachment.Name = "PickaxeAttachment"
    attachment.Parent = head
    
    -- Auto-equip the tool when created
    tool.Parent = player.Backpack
    
    -- Force equip the tool
    spawn(function()
        wait(0.1)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:EquipTool(tool)
        end
    end)
    
    print("Gave enhanced pickaxe to player: " .. player.Name)
    return tool
end

function MiningModule.RemovePickaxe(player)
    -- Remove from backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local existingTool = backpack:FindFirstChild("Mining Pickaxe")
        if existingTool then
            existingTool:Destroy()
        end
    end
    
    -- Remove from character if equipped
    local character = player.Character
    if character then
        local equippedTool = character:FindFirstChild("Mining Pickaxe")
        if equippedTool then
            equippedTool:Destroy()
        end
    end
end

function MiningModule.PlayMiningAnimation(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Create mining animation
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    -- Load default mining animation
    local animationId = "rbxassetid://507770677" -- Default digging animation
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    
    local animTrack = animator:LoadAnimation(animation)
    animTrack.Looped = true
    animTrack:Play()
    
    return animTrack
end

function MiningModule.StopMiningAnimation(player, animTrack)
    if animTrack then
        animTrack:Stop()
    end
end

function MiningModule.PlayPickaxeAnimation(player)
    local character = player.Character
    if not character then return end
    
    local tool = character:FindFirstChild("Mining Pickaxe")
    if not tool then return end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    -- Create swinging animation for pickaxe
    local swingTween = TweenService:Create(
        tool.Grip,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {C0 = tool.Grip.C0 * CFrame.Angles(math.rad(-45), 0, 0)}
    )
    
    swingTween:Play()
    
    -- Play mining sounds alternately
    spawn(function()
        while swingTween.PlaybackState == Enum.PlaybackState.Playing do
            local miningSound = handle:FindFirstChild("MiningSound")
            if miningSound then
                miningSound:Play()
            end
            wait(0.5)
            local hitSound = handle:FindFirstChild("HitSound")
            if hitSound then
                hitSound:Play() 
            end
            wait(0.5)
        end
    end)
    
    return swingTween
end

function MiningModule.StopPickaxeAnimation(swingTween)
    if swingTween then
        swingTween:Cancel()
    end
end

function MiningModule.StartMining(player, node, resourceType)
    local config = ResourceConfigs[resourceType]
    if not config then return end
    
    -- Check if node is already being mined
    local nodeData = MiningModule.GetNodeData(node)
    if not nodeData or nodeData.Depleted then
        return
    end
    
    -- Check if player is already mining
    if MiningSessions[player.UserId] then
        MiningModule.StopMining(player)
    end
    
    -- Check distance
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local distance = (player.Character.HumanoidRootPart.Position - node.Position).Magnitude
    if distance > 20 then
        return
    end
    
    -- FIXED: Always give and auto-equip pickaxe before mining
    MiningModule.CreatePickaxe(player)
    wait(0.2) -- Give time for tool to equip
    
    -- Apply guild mining speed bonus
    local guildModule = require(script.Parent.GuildModule)
    local playerGuild = guildModule.GetPlayerGuild(player)
    local miningTime = config.MiningTime
    
    if playerGuild == "GreenGuild" then
        miningTime = miningTime * 0.75 -- 25% faster for Emerald Miners
    end
    
    -- Start animations
    local miningAnim = MiningModule.PlayMiningAnimation(player)
    local pickaxeAnim = MiningModule.PlayPickaxeAnimation(player)
    
    -- Start mining session
    MiningSessions[player.UserId] = {
        Node = node,
        ResourceType = resourceType,
        StartTime = tick(),
        MiningTime = miningTime,
        Position = player.Character.HumanoidRootPart.Position,
        MiningAnimation = miningAnim,
        PickaxeAnimation = pickaxeAnim
    }
    
    -- Notify client to start mining UI
    local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
    local miningRemote = remoteEvents:WaitForChild("ResourceMining")
    miningRemote:FireClient(player, "StartMining", {
        ResourceType = resourceType,
        ResourceName = config.Name,
        MiningTime = miningTime,
        NodePosition = node.Position
    })
    
    print("Player " .. player.Name .. " started mining " .. resourceType .. " with enhanced pickaxe!")
end

function MiningModule.StopMining(player)
    local session = MiningSessions[player.UserId]
    if session then
        -- Stop animations
        MiningModule.StopMiningAnimation(player, session.MiningAnimation)
        MiningModule.StopPickaxeAnimation(session.PickaxeAnimation)
        
        MiningSessions[player.UserId] = nil
        
        -- Notify client
        local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
        local miningRemote = remoteEvents:WaitForChild("ResourceMining")
        miningRemote:FireClient(player, "StopMining")
    end
end

function MiningModule.GenerateResourceNodes()
    -- Clear existing nodes
    local miningZones = Workspace:FindFirstChild("MiningZones")
    if miningZones then
        miningZones:ClearAllChildren()
    end
    
    ActiveNodes = {}
    
    for _, zone in pairs(MiningZoneLocations) do
        local zoneFolder = Instance.new("Folder")
        zoneFolder.Name = zone.ZoneName
        zoneFolder.Parent = miningZones
        
        -- Generate nodes for this zone
        local nodesInZone = math.random(3, 8)
        for i = 1, nodesInZone do
            local resourceType = MiningModule.SelectRandomResource()
            local node = MiningModule.CreateResourceNode(resourceType, zone, zoneFolder)
            if node then
                table.insert(ActiveNodes, {
                    Node = node,
                    ResourceType = resourceType,
                    Zone = zone.ZoneName,
                    Amount = math.random(ResourceConfigs[resourceType].Amount[1], ResourceConfigs[resourceType].Amount[2]),
                    Depleted = false
                })
            end
        end
    end
end

function MiningModule.SelectRandomResource()
    local totalWeight = 0
    for _, config in pairs(ResourceConfigs) do
        totalWeight = totalWeight + config.Rarity
    end
    
    local random = math.random() * totalWeight
    local currentWeight = 0
    
    for resourceType, config in pairs(ResourceConfigs) do
        currentWeight = currentWeight + config.Rarity
        if random <= currentWeight then
            return resourceType
        end
    end
    
    return "Iron" -- Fallback
end

function MiningModule.CreateResourceNode(resourceType, zone, parent)
    local config = ResourceConfigs[resourceType]
    if not config then return nil end
    
    -- Create the resource node part
    local node = Instance.new("Part")
    node.Name = resourceType .. "Node"
    node.Size = Vector3.new(4, 6, 4)
    node.Material = Enum.Material.Rock
    node.BrickColor = BrickColor.new(config.Color)
    node.Anchored = true
    node.CanCollide = true
    
    -- Position randomly within the zone
    local angle = math.random() * math.pi * 2
    local distance = math.random(5, zone.Radius - 5)
    local x = zone.Position.X + math.cos(angle) * distance
    local z = zone.Position.Z + math.sin(angle) * distance
    local y = zone.Position.Y + node.Size.Y / 2
    
    node.Position = Vector3.new(x, y, z)
    node.Parent = parent
    
    -- Add visual effects
    local pointLight = Instance.new("PointLight")
    pointLight.Color = config.Color
    pointLight.Brightness = 1
    pointLight.Range = 10
    pointLight.Parent = node
    
    -- Add selection box for visibility
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = node
    selectionBox.Color3 = config.Color
    selectionBox.LineThickness = 0.2
    selectionBox.Transparency = 0.5
    selectionBox.Parent = node
    
    -- Add GUI for resource info
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 1, 0)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = node
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = config.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = billboardGui
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = config.Value .. " coins/unit"
    valueLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextStrokeTransparency = 0
    valueLabel.Parent = billboardGui
    
    -- Add click detector for mining
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = node
    
    -- Handle mining clicks
    clickDetector.MouseClick:Connect(function(player)
        MiningModule.StartMining(player, node, resourceType)
    end)
    
    return node
end

function MiningModule.UpdateMiningSessions()
    for playerId, session in pairs(MiningSessions) do
        local player = Players:GetPlayerByUserId(playerId)
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            MiningSessions[playerId] = nil
            continue
        end
        
        -- Check if player moved too far
        local currentPosition = player.Character.HumanoidRootPart.Position
        local distance = (currentPosition - session.Position).Magnitude
        if distance > 5 then
            MiningModule.StopMining(player)
            continue
        end
        
        -- Check if mining time completed
        local elapsed = tick() - session.StartTime
        if elapsed >= session.MiningTime then
            MiningModule.CompleteMining(player, session)
        end
    end
end

function MiningModule.CompleteMining(player, session)
    local nodeData = MiningModule.GetNodeData(session.Node)
    if not nodeData or nodeData.Depleted then
        MiningModule.StopMining(player)
        return
    end
    
    local config = ResourceConfigs[session.ResourceType]
    local playerDataModule = require(script.Parent.PlayerDataModule)
    
    -- Give player the resource
    local success = playerDataModule.AddToInventory(player, session.ResourceType, 1)
    if success then
        -- Reduce node amount
        nodeData.Amount = nodeData.Amount - 1
        
        -- Update node display
        MiningModule.UpdateNodeDisplay(session.Node, nodeData)
        
        -- Check if node is depleted
        if nodeData.Amount <= 0 then
            MiningModule.DepleteNode(nodeData)
        end
        
        -- Notify client of successful mining
        local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
        local miningRemote = remoteEvents:WaitForChild("ResourceMining")
        miningRemote:FireClient(player, "MiningComplete", {
            ResourceType = session.ResourceType,
            ResourceName = config.Name,
            Value = config.Value
        })
        
        print("Player " .. player.Name .. " mined 1 " .. session.ResourceType)
    end
    
    MiningModule.StopMining(player)
end

function MiningModule.GetNodeData(node)
    for _, nodeData in pairs(ActiveNodes) do
        if nodeData.Node == node then
            return nodeData
        end
    end
    return nil
end

function MiningModule.UpdateNodeDisplay(node, nodeData)
    local billboardGui = node:FindFirstChild("BillboardGui")
    if billboardGui then
        local valueLabel = billboardGui:FindFirstChild("TextLabel")
        if valueLabel and valueLabel.Name ~= "TextLabel" then
            valueLabel = billboardGui:GetChildren()[2]
        end
        if valueLabel then
            local config = ResourceConfigs[nodeData.ResourceType]
            valueLabel.Text = nodeData.Amount .. " left • " .. config.Value .. " coins/unit"
        end
    end
end

function MiningModule.DepleteNode(nodeData)
    nodeData.Depleted = true
    nodeData.DepletedTime = tick()
    
    -- Visual indication of depletion
    local node = nodeData.Node
    node.Transparency = 0.7
    node.CanCollide = false
    
    local clickDetector = node:FindFirstChild("ClickDetector")
    if clickDetector then
        clickDetector.MaxActivationDistance = 0
    end
    
    local billboardGui = node:FindFirstChild("BillboardGui")
    if billboardGui then
        local nameLabel = billboardGui:GetChildren()[1]
        if nameLabel then
            nameLabel.Text = "DEPLETED"
            nameLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end
    
    print("Resource node depleted: " .. nodeData.ResourceType .. " in " .. nodeData.Zone)
end

function MiningModule.StartRespawnSystem()
    RunService.Heartbeat:Connect(function()
        MiningModule.UpdateMiningSessions()
        MiningModule.CheckNodeRespawns()
    end)
end

function MiningModule.CheckNodeRespawns()
    for i, nodeData in pairs(ActiveNodes) do
        if nodeData.Depleted and nodeData.DepletedTime then
            local config = ResourceConfigs[nodeData.ResourceType]
            local elapsed = tick() - nodeData.DepletedTime
            
            if elapsed >= config.RespawnTime then
                MiningModule.RespawnNode(nodeData, i)
            end
        end
    end
end

function MiningModule.RespawnNode(nodeData, index)
    -- Remove old node
    if nodeData.Node and nodeData.Node.Parent then
        nodeData.Node:Destroy()
    end
    
    -- Find the zone
    local zone = nil
    for _, z in pairs(MiningZoneLocations) do
        if z.ZoneName == nodeData.Zone then
            zone = z
            break
        end
    end
    
    if zone then
        -- Create new node
        local miningZones = Workspace:FindFirstChild("MiningZones")
        local zoneFolder = miningZones and miningZones:FindFirstChild(zone.ZoneName)
        
        if zoneFolder then
            local newResourceType = MiningModule.SelectRandomResource()
            local newNode = MiningModule.CreateResourceNode(newResourceType, zone, zoneFolder)
            
            if newNode then
                -- Update node data
                ActiveNodes[index] = {
                    Node = newNode,
                    ResourceType = newResourceType,
                    Zone = zone.ZoneName,
                    Amount = math.random(ResourceConfigs[newResourceType].Amount[1], ResourceConfigs[newResourceType].Amount[2]),
                    Depleted = false
                }
                
                print("Respawned " .. newResourceType .. " node in " .. zone.ZoneName)
            end
        end
    end
end

function MiningModule.GetPlayerInventory(player)
    local playerDataModule = require(script.Parent.PlayerDataModule)
    local playerData = playerDataModule.GetPlayerData(player)
    return playerData and playerData.Inventory or {}
end

function MiningModule.SellResources(player, resourceType, amount)
    local config = ResourceConfigs[resourceType]
    if not config then return false end
    
    local playerDataModule = require(script.Parent.PlayerDataModule)
    local guildModule = require(script.Parent.GuildModule)
    
    -- Check if player has enough resources
    local inventory = MiningModule.GetPlayerInventory(player)
    if not inventory[resourceType] or inventory[resourceType] < amount then
        return false
    end
    
    -- Calculate value with guild bonus
    local totalValue = config.Value * amount
    local playerGuild = guildModule.GetPlayerGuild(player)
    
    if playerGuild == "YellowGuild" then
        totalValue = math.floor(totalValue * 1.2) -- 20% bonus for Golden Merchants
    end
    
    -- Remove resources and add coins
    if playerDataModule.RemoveFromInventory(player, resourceType, amount) then
        playerDataModule.AddCoins(player, totalValue)
        return totalValue
    end
    
    return false
end

-- Give pickaxe to players when they join their guild
function MiningModule.GiveStarterPickaxe(player)
    wait(2) -- Wait for player to fully load
    MiningModule.CreatePickaxe(player)
end

return MiningModule