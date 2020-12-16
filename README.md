# Osier-Framework
A very small framework used to simplify Initiation, Datastores and Remotes.

_dont forget to report bugs or to provide feedback_

# Why use the osier framework?

## Open source and flexible
* Osier is practically a base for your very own framework
* Developers can easily add extra functionality.
* Compatible with every type of game

## Automatic loading/saving and Remote utilities
* Player Data Loading, Caching and Autosaving are handled automatically, you just provide Default Data for new players
* Player Data is replicated automatically to the client.
* Session Locking is implemented.
* Optimized Backups **[unfinished]**
* Osier doesn't use network request everytime you want to get/update a value from datastores. (because it caches the players data when they join)
* Reset data, add data or remove data easily. (Default data and players data will be reconciled upon joining)
* Add core leaderstats and/or custom leaderboards that automatically update when you change players data. **[unfinished]**
* Remotes are more convenient to setup and faster to use.


***

# Getting Started


## Initiating the server
### Add a Server Script into the _Server Module_ (or anywhere really)

```lua
-- require the Server module.
local server = require(script.Parent)

-- connect to the custom player added event (or utilize :WaitForClient(player) in the normal player added event)
server.PlayerAdded:Connect(function(player,data)
    -- print the players 'Coins' value
    print("Server Coins: "..server:GetValue(player,"Coins"))
	
    -- fire a remote event handled by the players client.
    server:Fire(player, "LocalTest")
end)


-- handle a remote event on the server
server:HandleEvent("Test", 0 , function(player, data)
    print("SERVER TEST EVENT FIRED")
end)

-- start the server and provide DefaultData for the players datastores.
server:Start({
    Coins = 0
})
```

## Initiating the Client
### Add a Local Script into the _Client Module_ (or anywhere really)

```lua
-- require the Client module
local client  = require(script.Parent)

-- wait for the server to initiate and for the client to start.
client:WaitForStart()

-- print some data replicated from the server
print("Local Coins: "..client.Data.Coins)

-- fire a remote event that is handled by the server
client:Fire("Test")

-- handle a remote event on the client.
client:HandleEvent("LocalTest", 0,function(data)
    print("LOCAL TEST EVENT FIRED")
end)
```
