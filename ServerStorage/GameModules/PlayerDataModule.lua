-- PlayerDataModule.lua
-- Place this in ServerStorage/GameModules/

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

local PlayerDataModule = {}

-- Default player data structure
local DefaultPlayerData = {
    Guild = nil,
    Level = 1,
    Coins = 0,
    Inventory = {},
    Stats = {
        CombatLevel = 1,
        MiningLevel = 1,
        Experience = 0
    },
    Equipment = {
        Weapon = nil,
        Armor = nil,
        Tool = "BasicPickaxe"
    },
    FirstTime = true
}

-- Active player data cache
local PlayerDataCache = {}

function PlayerDataModule.LoadPlayerData(player)
    local success, playerData = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)
    
    if success and playerData then
        -- Merge with default data to add any new fields
        for key, value in pairs(DefaultPlayerData) do
            if playerData[key] == nil then
                playerData[key] = value
            end
        end
        PlayerDataCache[player.UserId] = playerData
        return playerData
    else
        -- Return default data for new players
        local newData = {}
        for key, value in pairs(DefaultPlayerData) do
            if type(value) == "table" then
                newData[key] = {}
                for subKey, subValue in pairs(value) do
                    newData[key][subKey] = subValue
                end
            else
                newData[key] = value
            end
        end
        PlayerDataCache[player.UserId] = newData
        return newData
    end
end

function PlayerDataModule.SavePlayerData(player)
    local playerData = PlayerDataCache[player.UserId]
    if not playerData then return false end
    
    local success = pcall(function()
        PlayerDataStore:SetAsync(player.UserId, playerData)
    end)
    
    return success
end

function PlayerDataModule.GetPlayerData(player)
    return PlayerDataCache[player.UserId]
end

function PlayerDataModule.SetPlayerGuild(player, guildName)
    local playerData = PlayerDataCache[player.UserId]
    if playerData then
        playerData.Guild = guildName
        playerData.FirstTime = false
        return true
    end
    return false
end

function PlayerDataModule.AddCoins(player, amount)
    local playerData = PlayerDataCache[player.UserId]
    if playerData then
        playerData.Coins = playerData.Coins + amount
        return true
    end
    return false
end

function PlayerDataModule.SpendCoins(player, amount)
    local playerData = PlayerDataCache[player.UserId]
    if playerData and playerData.Coins >= amount then
        playerData.Coins = playerData.Coins - amount
        return true
    end
    return false
end

function PlayerDataModule.AddToInventory(player, itemName, quantity)
    local playerData = PlayerDataCache[player.UserId]
    if playerData then
        if playerData.Inventory[itemName] then
            playerData.Inventory[itemName] = playerData.Inventory[itemName] + quantity
        else
            playerData.Inventory[itemName] = quantity
        end
        return true
    end
    return false
end

function PlayerDataModule.RemoveFromInventory(player, itemName, quantity)
    local playerData = PlayerDataCache[player.UserId]
    if playerData and playerData.Inventory[itemName] and playerData.Inventory[itemName] >= quantity then
        playerData.Inventory[itemName] = playerData.Inventory[itemName] - quantity
        if playerData.Inventory[itemName] <= 0 then
            playerData.Inventory[itemName] = nil
        end
        return true
    end
    return false
end

function PlayerDataModule.CleanupPlayerData(player)
    -- Save data before removing from cache
    PlayerDataModule.SavePlayerData(player)
    PlayerDataCache[player.UserId] = nil
end

return PlayerDataModule