# Roblox Studio Setup Guide - Mining War Game

## Folder Structure in Roblox Studio

### 1. ServerStorage Structure
```
ServerStorage/
├── GameModules/
│   ├── PlayerDataModule
│   ├── GuildModule
│   ├── CombatModule
│   ├── MiningModule
│   └── EconomyModule
├── GameData/
│   ├── GuildConfigs
│   ├── WeaponConfigs
│   ├── ResourceConfigs
│   └── ShopConfigs
└── RemoteEvents/
    ├── GuildSelection
    ├── PlayerSpawn
    ├── ResourceMining
    ├── Combat
    └── Shop
```

### 2. ServerScriptService Structure
```
ServerScriptService/
├── MainGameServer
├── PlayerJoinHandler
├── GuildManager
├── CombatHandler
├── MiningHandler
└── EconomyHandler
```

### 3. StarterGui Structure
```
StarterGui/
├── MainGui/
│   ├── GuildSelectionFrame
│   ├── GameHUD
│   ├── InventoryGui
│   └── ShopGui
└── LocalScripts/
    ├── GuildSelectionClient
    ├── GameHUDClient
    ├── CombatClient
    └── MiningClient
```

### 4. Workspace Structure
```
Workspace/
├── Guilds/
│   ├── RedGuild/
│   │   ├── SpawnPart
│   │   ├── SafeZone (Invisible part for collision detection)
│   │   └── Buildings/
│   ├── BlueGuild/
│   ├── GreenGuild/
│   └── YellowGuild/
├── MiningZones/
│   ├── IronMine/
│   ├── GoldMine/
│   ├── DiamondMine/
│   └── CrystalMine/
├── NeutralZones/
└── Lighting (for different zone atmospheres)
```

## Setup Steps in Roblox Studio

### Step 1: Enable Required Services
1. Open your place in Roblox Studio
2. Make sure these services are available:
   - DataStoreService (for saving player data)
   - TeleportService (if using multiple places)
   - Teams (for guild management)

### Step 2: Create Teams for Guilds
1. In Explorer, find the "Teams" service
2. Create 4 Team objects:
   - RedGuild (TeamColor: Bright red)
   - BlueGuild (TeamColor: Bright blue)
   - GreenGuild (TeamColor: Bright green)
   - YellowGuild (TeamColor: New Yeller)

### Step 3: Set Up RemoteEvents
1. In ServerStorage, create a folder called "RemoteEvents"
2. Add these RemoteEvent objects:
   - GuildSelection
   - PlayerSpawn
   - ResourceMining
   - Combat
   - Shop

### Step 4: Create Spawn Areas
1. In Workspace, create guild base areas
2. For each guild area:
   - Create a large Part for the spawn platform
   - Add a SpawnLocation object
   - Set SpawnLocation.TeamColor to match guild
   - Create invisible collision parts for safe zone detection

### Step 5: Set Up Mining Zones
1. Create mining areas in Workspace
2. Add resource nodes (Parts with different materials/colors)
3. Create collision detection areas around each mine

## Script Installation Order

### Phase 1: Core Systems
1. Install PlayerDataModule (ServerStorage)
2. Install GuildModule (ServerStorage)
3. Install MainGameServer (ServerScriptService)
4. Install PlayerJoinHandler (ServerScriptService)

### Phase 2: Game Mechanics
1. Install CombatModule and CombatHandler
2. Install MiningModule and MiningHandler
3. Install EconomyModule and EconomyHandler

### Phase 3: User Interface
1. Install Guild Selection GUI
2. Install Game HUD
3. Install LocalScript handlers

## Testing Checklist

### Basic Functionality Test:
- [ ] Player joins and sees guild selection
- [ ] Guild selection saves and persists
- [ ] Player spawns in correct guild area
- [ ] Guild areas are safe zones
- [ ] Basic movement and interaction works

### Advanced Features Test:
- [ ] Mining system works
- [ ] Combat between different guilds
- [ ] Economy system (sell resources, buy items)
- [ ] Data persistence across sessions

## Common Issues and Solutions

### Issue: Players don't see GUI
**Solution**: Make sure LocalScripts are in StarterGui, not ServerScriptService

### Issue: DataStore errors
**Solution**: Test in published game, not Studio (or enable API services in Studio)

### Issue: RemoteEvents not firing
**Solution**: Check that RemoteEvents are in ServerStorage and properly referenced

### Issue: Players spawn in wrong location
**Solution**: Verify Team assignments and SpawnLocation TeamColor properties

## Performance Considerations

1. Use region-based updates for mining zones
2. Limit RemoteEvent firing frequency
3. Use magnitude checks for proximity detection
4. Implement proper cleanup for disconnected players
5. Use efficient data structures for player inventories

## Security Notes

1. Always validate inputs on server side
2. Use RemoteEvents for client-server communication
3. Store sensitive data (coins, inventory) on server only
4. Implement anti-exploit measures for mining and combat
5. Rate limit RemoteEvent calls to prevent spam