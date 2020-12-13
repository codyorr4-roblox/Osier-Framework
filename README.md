# Slim-Module for roblox
A very compact module used to simplify Initiation, Datastores and Remotes.

# Pros
* Player Data, Loading, Caching, Autosaving, Data Replication, SessionLock, Leaderboards, and Backups are all handled automatically, just provide Default Data.
* Doesn't use a network request everytime you want to get or set a value from datastores. (because it caches the data)
* Easily reset everyones data, add data or remove data values using a reconcile method.
* Remotes are way more convenient to use and have a faster workflow.


# Initiating the server
## Add a Server script any where you want

```lua
local server = require(game.ReplicatedStorage.Slim)

-- initiate the server and provide some default data for new players. (all loading/autosaving/caching/replication/remote handlers will be started automatically)
local defaultData = { Coins = 0 }
server:Init(defaultData)

-- fires when a player joins
game.Players.PlayerAdded:Connect(function(player)
    -- waits for the players data, remote handler and client to be initiated.
    server:WaitForClient(player)
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
## Add a LocalScript into the "Client" Module (or anywhere you want really)
## The "Client" Module will be cloned into the Player when they join.

```lua
-- require and initiate
local client = require(game.ReplicatedStorage:WaitForChild("Slim"))

-- starts the local remote handler / data receiver
client:Init()

-- wait for the players data / remote handler / server data
client:WaitForServer()

-- fire a remote event. (must be handled on the server first)
client:Fire("ExampleEvent")








```



