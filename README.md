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


## Using the Server
### Add a Server Script as a child of the _Server Module_

```lua
-- Require the server and cache any modules needed.
local server= require(script.Parent.Parent)
local remote = server.Remote
local playerData = server.PlayerData


-- Start the player data module.
playerData:Start(
	
	--First argument is a template for new players' data.
	{	
		Coins = 0,
		Inventory = {}
	},
	
	--Second argument is a table that specifies which values can be replicated.
	{
		Coins = true
	}
)


-- Only the server can register remotes, 
-- "true" means it is an async request (a remoteFunction) rather than a RemoteEvent.
remote:Create("Test", true) 



-- Handle a signal for a registered remote.
remote:Handle("Test", 2000, function(player,data, data2)
	-- Print received data.
	print(data)
	print(data2)
	
	
	-- Get a value from the players session data. EX: their "Coins" value.
	print(playerData:Get(player, "Coins"))
	
	
	-- Update a players session data. EX: giving the player 20 Coins.
	playerData:Update(player, "Coins", function(old) 
		return old + 20
	end)
	
	-- Check to see if the value changed
	print(playerData:Get(player, "Coins"))

        return  "Server has finished" -- example of returning a value.
	
end)
```


## Using the Client
### Add a Local Script as a child of the _Client Module_

```lua
-- Require the Client module and cache any other modules needed.
local client = require(script.Parent.Parent)
local remote = client.Remote
local playerData = client.PlayerData


-- Locally print a replicated session data value.
-- The servers playerData:Start() function has arguments for replicating saved values.
print(playerData:Get("Coins"))


-- Locally invoke a remoteFunction that was registered by the server, it will yield and return values.
print(remote:RequestAsync("Test", "Hello from the client!", "Here is a second value"))


-- Check the replicated values again and see if the change replicated.
print(playerData:Get("Coins"))
```
