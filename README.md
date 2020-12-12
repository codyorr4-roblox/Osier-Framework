# Slim-Framework
A very slim framework used to simplify Initiation, Datastores and Remotes.

# Pros
* Player Data, Loading, Caching, Autosaving and Data Replication are all handled automatically, just provide Default Data.
* Doesn't use a network request everytime you want to get or set a value from datastores. (because it caches the data)
* Easily reset everyones data or add/remove values from players datastores.
* Remotes are way more convenient to use and have a faster workflow.
* Dont have to depend on :WaitForChild() or :Wait() for important things. (because everything is initiated in a specific order)

# Cons
* Have to learn how to use the provided properties/functions
* Have to understand the workflow of libraries/packages to get a decent design going. (especially when initiating things)
* Possible to get Cyclic Table issues using inproper designs.


# Initiating the server
## Add a Server script into the "Server" module. (or anywhere you want really)

```lua
local server = require(script.Parent)
local defaultData = {
    Coins = 0
}
-- starts the remote handler and datastore handler, you just have to provide default player data for the datastore.
server:Init(defaultData)

-- use the provided PlayerAdded event to properly wait for datastore/remote handler to initiate.
server.PlayerAdded:Connect(function(player)
    print(server:GetValue(player, "Coins"))
end)

-- handle a remote function that has a 1 second cooldown.
server:HandleRequest("TestRequest123", 1, function(player, data)
    print(data.Message)
    server:SetValue(player, "Coins", function(oldValue)
        return oldValue + 100
    end)
    return "Hello client"
end)


```

# initiating the Client
## Add a LocalScript into the "Client" Module (or anywhere you want really)
## The "Client" Module will be cloned into the Player when they join.

```lua
-- require and initiate
local client = require(script.Parent)
client:Init()

--grab local data. (this is the data that the server grabbed from the datastore and then replicated to the client)
local data = client:WaitForData()
local coins = data.Coins
print(coins.Value)

--use request (must be handled by the server first)
local reply = client:Request("TestRequest123", {Message = "Hello server"})
print(reply)

-- print value everytime it changes.
client.DataChanged:Connect(function(data)
    if(data.Coins)then
        print("Coins updated to: " .. data.Coins)
    end
end)




```



