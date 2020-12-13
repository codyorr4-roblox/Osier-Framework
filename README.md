# SlimService for roblox
A very compact module used to simplify Initiation, Datastores and Remotes.

# Why use slim?

## Datastores utilities
* Player Data Loading, Caching and Autosaving are handled automatically, you just provde Default Data for new players
* Player Data is replicated automatically to the client.
* SessionLocking is implemented and data cannot be overriden with old data and exploiters can't duplicate data.
* Slim doesn't use a network request everytime you want to get/update a value from datastores. (because it caches the players data)
* Easily reset data, add data or remove data using a reconcile method.
* Easily add CORE leaderstats that automatically update when you update players data.
* Easily add CUSTOM leaderbards that automatically update when you update players data.

## Remote utilities
* Remote are way more convenient to use and have a faster workflow.
* Never have to worry about type errors
* Never have to worry about exploiters breaking your remotes/server.
* Never have to worry about adding debounces/cooldowns to every single remote.
  just provide the cooldown argument in HandleEvent() and HandleRequest() function. (compatible with milliseconds)


# Initiating the server
## Add a Server script any where you need

```lua
local server = require(game.ReplicatedStorage.Slim)

-- initiate the server and provide some default data for new players. (all loading/autosaving/caching/replication/remote handlers will be started automatically)
local defaultData = { Coins = 0 }
server:Init(defaultData)

-- fires when a player joins
game.Players.PlayerAdded:Connect(function(player)
    -- wait for the players data, remote handler and client to be initiated.
    server:WaitForClient(player)
    
    -- grab the players 'coins' value.
    local coins = server:GetValue(player, "Coins")
    print(coins)
end)

-- handle an event with a specified cooldown 
server:HandleEvent("ExampleEvent", 0.5, function(player,data)
    server:SetValue(player, "Coins", function(old)
        return old+100
    end)
end)

```

# Initiating the Client
## Add a Local Script anywhere you need.

```lua
-- require and initiate
local client = require(game.ReplicatedStorage:WaitForChild("Slim"))

-- starts the local remote handler / data receiver
client:Init()

-- wait for the players replicated data, remote handler and server.
client:WaitForServer()

-- grabs the data that was replicated from the server.
local data = client:GetData() 

print(data.Coins)

-- fire a remote event. (must be handled on the server first)
client:Fire("ExampleEvent")



```



