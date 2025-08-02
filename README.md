# 🐾 Pet Ranch Breeding Game

A multiplayer Roblox game inspired by Grow a Garden where players manage their own ranch, breed pets, and trade with others.

## 🌟 Features

### 🏠 Multiplayer Ranch System
- **6 Player Support**: Each player gets their own ranch zone
- **Shared World**: Players can see each other's ranches
- **Isolated Breeding**: Players can't interfere with others' pets

### 🛍️ Pet Shop System
- **Elemental Pets**: Start with Fire pets, expand to all elements
- **Currency System**: Buy pets with coins
- **Server Validation**: All purchases verified server-side

### 🧬 Breeding Mechanics
- **Element Combinations**: Fire + Plant = Smoke, Fire + Water = Steam
- **Hybrid Creation**: Generate new pet types through breeding
- **Breeding Chart**: Comprehensive element combination system

### 🐣 Growth & Hatching
- **Growth Timers**: 5-minute maturation cycle
- **Egg System**: Breeding creates eggs with hatching timers
- **Speed Options**: Pay coins to accelerate growth/hatching

### 💾 Data Persistence
- **Player Progress**: Save all pets, ranch layout, coins
- **Breeding History**: Track successful combinations
- **Auto-Save**: Automatic progress saving

## 🏗️ Project Structure

```
src/
├── server/
│   ├── init.server.luau          # Main server script
│   ├── PlayerManager.server.luau  # Player data management
│   ├── RanchManager.server.luau   # Ranch zone assignment
│   ├── PetShop.server.luau       # Shop and purchasing
│   ├── BreedingSystem.server.luau # Breeding mechanics
│   ├── GrowthSystem.server.luau   # Pet growth timers
│   └── DataManager.server.luau    # Save/load system
├── client/
│   ├── init.client.luau          # Main client script
│   ├── UIManager.client.luau     # UI management
│   ├── RanchUI.client.luau       # Ranch interface
│   ├── ShopUI.client.luau        # Shop interface
│   ├── BreedingUI.client.luau    # Breeding interface
│   └── CameraController.client.luau # Camera controls
└── shared/
    ├── PetData.luau              # Pet definitions
    ├── BreedingChart.luau        # Element combinations
    ├── RanchConfig.luau          # Ranch settings
    └── Constants.luau            # Game constants
```

## 🎮 Game Systems

### Ranch Zones
- 6 distinct ranch areas on the map
- Each ranch has: Pet slots, Egg slots, Breeding area
- Automatic assignment on player join

### Pet Elements
- **Fire**: Base element, available in shop
- **Plant**: Grows from Fire + Water breeding
- **Water**: Available through breeding
- **Smoke**: Fire + Plant combination
- **Steam**: Fire + Water combination
- **Mud**: Plant + Water combination

### Breeding Chart
```
Fire + Plant = Smoke
Fire + Water = Steam  
Plant + Water = Mud
Smoke + Steam = Ash
Steam + Mud = Mist
```

### Economy System
- **Daily Rewards**: 100 coins per day
- **Pet Sales**: Sell mature pets for coins
- **Speed Services**: Pay to accelerate timers
- **Shop Purchases**: Buy new pets and items

## 🚀 Getting Started

1. **Clone this repository**
2. **Open in Roblox Studio**
3. **Run the game** to test multiplayer functionality
4. **Use Rojo** for local development:
   ```bash
   rojo serve
   ```

## 📝 Development Notes

- All pet data stored in `PetData.luau`
- Breeding combinations in `BreedingChart.luau`
- UI components in `client/` folder
- Server logic in `server/` folder
- Shared constants in `shared/` folder

## 🎯 Next Steps

- [ ] Implement basic ranch zones
- [ ] Create pet shop UI
- [ ] Add breeding mechanics
- [ ] Set up growth timers
- [ ] Implement save/load system
- [ ] Add visual effects and animations