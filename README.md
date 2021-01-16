# Osier-Framework
A very small framework used to simplify Initiation, Datastores and Remotes.

[Roblox Devforum release](https://devforum.roblox.com/t/osier-framework-simplified-datastores-and-remotes-for-simplified-projects/927569)

_dont forget to report bugs or to provide feedback_

# Why use the osier framework?

## Open-source and flexible
* Osier is practically a blank framework that can be used for your very own framework
* Developers can easily add extra functionality.
* Compatible with every type of game

## Automatic loading/saving + Remote utilities
* Player Data Loading, Caching and Autosaving are handled automatically, you just provide Default Data for new players
* Player Data is replicated automatically to the client.
* Session Locking is implemented.
* Osier doesn't use network request everytime you want to get/update a value from datastores. (because it caches the players data when they join)
* Reset data, add data or remove data easily. (Default data and players data will be reconciled upon joining)
* Remotes are more convenient to setup and faster to use.


***

# Getting Started


## Starting the Server
### Add a Server Script as a child of the _Server Module_

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

## Using the Server
### Add another Server Script as a child of the _Server Module_

```lua
-- require the Server module.
local server = require(script.Parent)

-- wait for the server to start
server:WaitForStart()

-- do what you gotta do after server starts
server:HandleEvent("Sell", 1, function(player, data)
    -- update the players 'Coins' value. it'll be autosaved. (it'll also save when they leave or if the server closes)
    server:UpdateValue(player, "Coins", function(oldValue)
    	return oldValue+100
    end)
end)
```

## Using the Client
### Add a Local Script as a child of the _Client Module_

```lua
-- require the Client module
local client  = require(script.Parent)

-- wait for the server and client to start.
client:WaitForStart()

-- print some data replicated from the server
print("Local Coins: "..client.Data.Coins)

-- fire a remote event that is handled by the server
client:Fire("Test")

-- handle a remote event on the client.
client:HandleEvent("LocalTest", 0,function(data)
    print("LOCAL TEST EVENT FIRED")
end)

-- check to see if certain data changes
client.DataChanged("Coins"):Connect(function(value)
    print("LOCAL COINS CHANGED TO: "..value)
end)
```
