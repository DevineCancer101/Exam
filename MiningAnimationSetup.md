# ⛏️ Mining Animation & Pickaxe Setup Guide

## 🎯 **What You're Adding**

Amazing new features that make mining feel immersive:
- ⛏️ **Pickaxe Tool** - Automatically given to players when they join a guild
- 🎭 **Mining Animation** - Player character performs digging animation
- 🔨 **Pickaxe Swinging** - Tool swings rhythmically while mining
- 🔊 **Mining Sounds** - Audio feedback during mining
- ✨ **Auto-Equipment** - Pickaxe appears when mining starts

## 📋 **Setup Steps**

### Step 1: Update MiningModule
1. **Go to ServerStorage → GameModules → MiningModule**
2. **Select all existing code** and delete it
3. **Copy and paste** the entire content from `MiningModule_WithAnimations.lua`

### Step 2: Update PlayerJoinHandler  
1. **Go to ServerScriptService → PlayerJoinHandler**
2. **Select all existing code** and delete it
3. **Copy and paste** the entire content from `PlayerJoinHandler_WithPickaxe.lua`

### Step 3: Test Your New System!
1. **Click Play** in Roblox Studio
2. **Join a guild** (or respawn if you already have one)
3. **Check your hotbar** - you should see a "Mining Pickaxe" tool!
4. **Walk to a resource node** and click it
5. **Watch the magic happen**:
   - Your character starts digging animation
   - Pickaxe swings automatically
   - Mining sounds play
   - Progress bar shows with animation

## 🎮 **New Features in Action**

### **Pickaxe Tool Features:**
- 🛠️ **Automatic Delivery** - Given when joining guild or respawning
- 🎨 **Custom Design** - Brown wooden handle with metal head
- 🔊 **Mining Sounds** - Realistic digging audio
- ⚙️ **Auto-Equip** - Appears in inventory when needed

### **Animation System:**
- 🎭 **Player Animation** - Character performs digging motion
- 🔨 **Tool Animation** - Pickaxe swings in rhythm
- ⏱️ **Synchronized** - Animations match mining timer perfectly
- 🛑 **Auto-Stop** - Animations end when mining completes

### **Enhanced Mining Experience:**
1. **Approach resource node** → Pickaxe appears if missing
2. **Click to mine** → Character starts digging animation
3. **Progress bar appears** → Pickaxe swings with sound effects
4. **Mining completes** → Animations stop, resource collected
5. **Visual feedback** → Success notification and inventory update

## 🎯 **Guild Bonuses Still Work!**

Your **Emerald Miners** guild still gets:
- ⚡ **25% faster mining** (shorter animation time)
- 💚 **Same great benefits** with new visual appeal
- 🏆 **Competitive advantage** with style!

## 🔧 **Technical Details**

### **Pickaxe Construction:**
```
Mining Pickaxe Tool:
├── Handle (Brown wooden shaft)
├── PickaxeHead (Metal head with mesh)
├── WeldConstraint (Connects parts)
├── MiningSound (Audio effect)
└── Tool Logic (Auto-equip system)
```

### **Animation System:**
- **Player Animation**: Uses Roblox's built-in digging animation
- **Tool Animation**: Custom TweenService swinging motion
- **Sound Effects**: Mining impact sounds
- **Synchronization**: All animations match mining timer

### **Smart Features:**
- 🔄 **Auto-Replace** - New pickaxe if lost
- 🎒 **Inventory Management** - Goes to backpack when not mining
- 🚀 **Performance Optimized** - Animations only during mining
- 🛡️ **Error Handling** - Works even if animations fail

## 🎉 **What You'll Experience**

### **Before:**
- Click node → Progress bar appears → Get resource

### **After:**
- Click node → Character starts digging → Pickaxe swings → Mining sounds → Progress bar fills → Animations stop → Get resource!

### **Visual Polish:**
- ✅ **Immersive mining experience**
- ✅ **Professional tool system**
- ✅ **Realistic animations**
- ✅ **Audio feedback**
- ✅ **Smooth automation**

## 🚀 **Ready to Test!**

After updating both scripts:
1. **Start your game**
2. **Look for the pickaxe in your hotbar** (appears automatically)
3. **Find a resource node and start mining**
4. **Enjoy the enhanced mining experience!**

### **Expected Output:**
```
"Gave pickaxe to player: YourName"
"Player YourName started mining Gold with animations!"
"Player YourName mined 1 Gold"
```

## 🎯 **Pro Tips**

- **Equip the pickaxe manually** for the full effect (click it in hotbar)
- **Try different resources** - animations work for all types
- **Stay close to nodes** - moving cancels mining and animations
- **Listen for sounds** - audio cues enhance the experience

**Your mining game just became 10x more immersive!** ⛏️🎮✨