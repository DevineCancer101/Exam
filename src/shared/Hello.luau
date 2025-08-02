--[[
    Hello.luau
    Simple test module for shared functionality
]]

local Hello = {}

Hello.message = "Hello from Pet Ranch Game!"

function Hello.sayHello()
    print("🐾 " .. Hello.message)
    return Hello.message
end

function Hello.getGameInfo()
    return {
        name = "Pet Ranch Breeding Game",
        version = "1.0.0",
        description = "A multiplayer pet breeding game",
        features = {
            "6 Player Multiplayer",
            "Pet Breeding System", 
            "Ranch Management",
            "Shop System",
            "Growth Timers"
        }
    }
end

return Hello