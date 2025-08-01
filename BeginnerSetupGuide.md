# 🎮 Complete Beginner's Guide to Setting Up Your Mining War Game

## 📋 What You'll Need
- Roblox Studio (free download from roblox.com/create)
- A Roblox account
- About 30-45 minutes to complete setup

---

## 🚀 Part 1: Creating Your Game Place

### Step 1: Open Roblox Studio
1. **Download and Install**: Go to roblox.com/create and download Roblox Studio if you haven't already
2. **Open Roblox Studio**: Launch the application
3. **Create New Place**: 
   - Click "New" tab on the left
   - Select "Baseplate" template (this gives you a simple starting world)
   - Click "Create"

### Step 2: Save Your Game
1. **Save Immediately**: Press `Ctrl + S` (or Cmd + S on Mac)
2. **Name Your Game**: Type something like "Mining War Game"
3. **Choose Location**: Save it somewhere you can find it easily
4. **Click Save**

---

## 🗂️ Part 2: Understanding the Roblox Studio Interface

### Important Windows to Know:
1. **Explorer Window** (usually on the right):
   - Shows all objects in your game
   - This is like a file browser for your game
   - If you don't see it: View → Explorer

2. **Properties Window** (usually bottom-right):
   - Shows settings for selected objects
   - If you don't see it: View → Properties

3. **Output Window** (usually at bottom):
   - Shows messages and errors
   - If you don't see it: View → Output

4. **3D Viewport** (center):
   - This is your game world where you build

---

## 📁 Part 3: Creating the Folder Structure

### Step 3: Set Up ServerStorage Folders

1. **Find ServerStorage in Explorer**:
   - Look in the Explorer window on the right
   - You should see "ServerStorage" in the list

2. **Create GameModules Folder**:
   - Right-click on "ServerStorage"
   - Select "Insert Object" → "Folder"
   - A new folder appears - rename it to "GameModules"
   - To rename: right-click the folder → "Rename" → type "GameModules"

3. **Create GameData Folder**:
   - Right-click on "ServerStorage" again
   - Insert Object → Folder
   - Rename it to "GameData"

4. **Create RemoteEvents Folder**:
   - Right-click on "ServerStorage" again
   - Insert Object → Folder
   - Rename it to "RemoteEvents"

### Step 4: Set Up StarterGui Folders

1. **Find StarterGui in Explorer**:
   - Look for "StarterGui" in the Explorer window

2. **Create MainGui Folder**:
   - Right-click on "StarterGui"
   - Insert Object → Folder
   - Rename to "MainGui"

3. **Create LocalScripts Folder**:
   - Right-click on "StarterGui"
   - Insert Object → Folder
   - Rename to "LocalScripts"

---

## 🔗 Part 4: Creating RemoteEvents

RemoteEvents allow your server scripts to talk to client scripts.

### Step 5: Add Required RemoteEvents

1. **Go to ServerStorage → RemoteEvents folder**
2. **Create GuildSelection RemoteEvent**:
   - Right-click on "RemoteEvents" folder
   - Insert Object → "RemoteEvent" (scroll down to find it)
   - Rename it to "GuildSelection"

3. **Repeat for other RemoteEvents**:
   - Create "PlayerSpawn" RemoteEvent
   - Create "ResourceMining" RemoteEvent  
   - Create "Combat" RemoteEvent
   - Create "Shop" RemoteEvent

**Your RemoteEvents folder should now contain:**
- GuildSelection
- PlayerSpawn
- ResourceMining
- Combat
- Shop

---

## 👥 Part 5: Setting Up Teams (Guilds)

### Step 6: Create Guild Teams

1. **Find Teams Service**:
   - In Explorer, look for "Teams"
   - If you don't see it: right-click in empty space in Explorer → Insert Object → "Teams"

2. **Create RedGuild Team**:
   - Right-click on "Teams"
   - Insert Object → "Team"
   - Rename it to "RedGuild"
   - Click on the RedGuild team to select it
   - In Properties window, find "TeamColor"
   - Click the color box and choose "Bright red"

3. **Create Other Guild Teams**:
   - **BlueGuild**: TeamColor = "Bright blue"
   - **GreenGuild**: TeamColor = "Bright green"  
   - **YellowGuild**: TeamColor = "New Yeller"

4. **Set Team Properties** (for each team):
   - Select the team
   - In Properties: set "AutoAssignable" to `false` (uncheck the box)

---

## 🏗️ Part 6: Building Guild Areas in the World

### Step 7: Create Guild Base Areas

1. **Create Guilds Folder in Workspace**:
   - Right-click on "Workspace" in Explorer
   - Insert Object → Folder
   - Rename to "Guilds"

2. **Create RedGuild Area**:
   - Right-click on "Guilds" folder
   - Insert Object → Folder
   - Rename to "RedGuild"

3. **Add a Spawn Platform**:
   - Right-click on "RedGuild" folder
   - Insert Object → "Part"
   - Rename it to "SpawnPart"
   - **Resize the part**:
     - Select the SpawnPart
     - In Properties, find "Size"
     - Change it to `20, 2, 20` (makes a 20x20 platform)
   - **Position the part**:
     - In Properties, find "Position"
     - Change it to `-100, 1, 0` (moves it to the left)
   - **Color the part red**:
     - In Properties, find "BrickColor"
     - Choose "Bright red"

4. **Add Spawn Location**:
   - Right-click on "SpawnPart"
   - Insert Object → "SpawnLocation"
   - The SpawnLocation should appear on top of your red platform
   - **Set spawn properties**:
     - Select the SpawnLocation
     - In Properties: set "TeamColor" to "Bright red"
     - Set "Neutral" to `false` (uncheck)

5. **Create Safe Zone (Invisible Collision)**:
   - Right-click on "RedGuild" folder
   - Insert Object → "Part"
   - Rename to "SafeZone"
   - **Make it invisible**:
     - In Properties: set "Transparency" to `1`
     - Set "CanCollide" to `false`
   - **Size and position**:
     - Size: `50, 20, 50` (large area around spawn)
     - Position: `-100, 10, 0` (same X,Z as spawn, higher Y)

### Step 8: Create Other Guild Areas

**Repeat Step 7 for the other guilds with these positions:**

- **BlueGuild**: 
  - SpawnPart Position: `100, 1, 0`
  - SafeZone Position: `100, 10, 0`
  - BrickColor: "Bright blue"
  - TeamColor: "Bright blue"

- **GreenGuild**:
  - SpawnPart Position: `0, 1, -100`
  - SafeZone Position: `0, 10, -100`
  - BrickColor: "Bright green"
  - TeamColor: "Bright green"

- **YellowGuild**:
  - SpawnPart Position: `0, 1, 100`
  - SafeZone Position: `0, 10, 100`
  - BrickColor: "New Yeller"
  - TeamColor: "New Yeller"

---

## 💻 Part 7: Adding the Scripts

### Step 9: Create Server Scripts

1. **Create PlayerDataModule**:
   - Right-click on "ServerStorage → GameModules"
   - Insert Object → "ModuleScript"
   - Rename to "PlayerDataModule"
   - **Double-click to open the script**
   - **Delete all existing code**
   - **Copy and paste** the entire PlayerDataModule.lua code from the files I created

2. **Create GuildModule**:
   - Right-click on "ServerStorage → GameModules"
   - Insert Object → "ModuleScript"
   - Rename to "GuildModule"
   - Open and replace code with GuildModule.lua

3. **Create PlayerJoinHandler**:
   - Right-click on "ServerScriptService" in Explorer
   - Insert Object → "Script" (NOT LocalScript)
   - Rename to "PlayerJoinHandler"
   - Open and replace code with PlayerJoinHandler.lua

### Step 10: Create Client Scripts (GUI)

1. **Create GuildSelectionClient**:
   - Right-click on "StarterGui → LocalScripts"
   - Insert Object → "LocalScript"
   - Rename to "GuildSelectionClient"
   - Open and replace code with GuildSelectionClient.lua

2. **Create GameHUDClient**:
   - Right-click on "StarterGui → LocalScripts"
   - Insert Object → "LocalScript"
   - Rename to "GameHUDClient"
   - Open and replace code with GameHUDClient.lua

---

## 🧪 Part 8: Testing Your Game

### Step 11: Test in Studio

1. **Click the Play button** (green triangle at top)
2. **What should happen**:
   - You spawn in the world
   - A guild selection screen appears
   - Choose a guild
   - You should spawn in that guild's colored area
   - You should see a HUD at the top with your name, guild, and coins

3. **If something goes wrong**:
   - Check the Output window for error messages (red text)
   - Make sure all scripts are in the correct locations
   - Verify RemoteEvents are properly named

### Step 12: Test with Multiple Players

1. **Click the dropdown arrow next to Play button**
2. **Select "2 Players"** (or more)
3. **Test guild selection with different players**

---

## 🌐 Part 9: Publishing Your Game

### Step 13: Publish to Roblox

1. **File → Publish to Roblox**
2. **Create new game** or update existing
3. **Give it a name and description**
4. **Set it to Public or Friends** (up to you)
5. **Click "Create" or "Update"**

### Step 14: Enable Studio API Services (For DataStore Testing)

1. **File → Game Settings**
2. **Security tab**
3. **Check "Enable Studio Access to API Services"**
4. **Save settings**

---

## ✅ Part 10: Verification Checklist

### Your Explorer Should Look Like This:

```
ServerScriptService/
├── PlayerJoinHandler (Script)

ServerStorage/
├── GameModules/
│   ├── PlayerDataModule (ModuleScript)
│   └── GuildModule (ModuleScript)
└── RemoteEvents/
    ├── GuildSelection (RemoteEvent)
    ├── PlayerSpawn (RemoteEvent)
    ├── ResourceMining (RemoteEvent)
    ├── Combat (RemoteEvent)
    └── Shop (RemoteEvent)

StarterGui/
└── LocalScripts/
    ├── GuildSelectionClient (LocalScript)
    └── GameHUDClient (LocalScript)

Teams/
├── RedGuild (Team)
├── BlueGuild (Team)
├── GreenGuild (Team)
└── YellowGuild (Team)

Workspace/
├── Baseplate (Part)
└── Guilds/
    ├── RedGuild/
    │   ├── SpawnPart (Part with SpawnLocation)
    │   └── SafeZone (Part, invisible)
    ├── BlueGuild/
    ├── GreenGuild/
    └── YellowGuild/
```

---

## 🐛 Common Issues and Solutions

### Issue: "RemoteEvent is not a valid member"
**Solution**: Make sure RemoteEvents are in ServerStorage/RemoteEvents folder with exact names

### Issue: Guild selection UI doesn't appear
**Solution**: Make sure GuildSelectionClient is a LocalScript in StarterGui

### Issue: Players don't spawn in guild areas
**Solution**: Check that SpawnLocation TeamColor matches Team TeamColor exactly

### Issue: Scripts show errors about "module not found"
**Solution**: Verify ModuleScripts are in ServerStorage/GameModules folder

### Issue: DataStore doesn't save
**Solution**: Publish your game to Roblox and test there, or enable Studio API services

---

## 🎉 Congratulations!

You now have a fully functional guild-based game foundation! Players can:
- ✅ Join and select a guild
- ✅ Spawn in their guild's area  
- ✅ See their guild info and stats
- ✅ Have their data saved automatically

## 🚀 What's Next?

Now you can add:
1. **Mining zones** where guilds fight over resources
2. **Combat system** for PvP battles
3. **Economy system** with shops and upgrades
4. **More advanced features** like weapons and abilities

Would you like me to help you add any of these features next?