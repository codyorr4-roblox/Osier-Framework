local client = {}

client.Data = {}
client.Player = game.Players.LocalPlayer
client.Character = client.Player.Character or client.Player.CharacterAdded:Wait()
client.Humanoid = client.Character:WaitForChild("Humanoid")

local rs = game:GetService("RunService")
local canStart = true 
local started = false
local dataReplicated=false
local events = {}
local eventCooldowns = {}

function start()

	local event = client.Player:WaitForChild("SlimEvent", 24)
	local request = client.Player:WaitForChild("SlimRequest", 24)
	local replicator = client.Player:WaitForChild("DataReplicator", 24)
	
	event.OnClientEvent:Connect(function(id, data)
		local event = events[id]
		if(not event)then return end
		
		local cooldown = eventCooldowns[id]
		if(cooldown and os.time() < cooldown)then return end
		eventCooldowns[id] = os.time() + event.Cooldown
		
		event.Handle(data)
	end)
	
	replicator.OnClientEvent:Connect(function(data)
		if(not data or type(data)~="table")then return end
		
		if(dataReplicated==false)then
			dataReplicated=true
			client.Data = data
		else
			client.Data[data.Key] = data.Value
		end
	end)
	
	
	started = true
	client:WaitForStart()
	client:Fire("_SlimClientReady")
end

function client:WaitForStart()
	if(canStart==true)then
		canStart=false
		start()
	end
	if(started and dataReplicated and client.Data)then return end
	
	local start = os.time() + 24
	repeat
		if(os.time() >= start)then
			client.Player:Kick("Could not get a response from the server, contact a developer and try again.")
		end
		rs.Stepped:Wait()
	until started and dataReplicated
	
	return true
end

function client:GetData()
	return client.Data
end

function client:GetValue(name)
	return client.Data[name]
end

function client:Fire(name, data)
	local event = client.Player:WaitForChild("SlimEvent", 24)
	if(event)then
		event:FireServer(name, data)
	else
		client.Player:Kick("Lost connection to the event handler, contact a developer and try again.")
	end
end

function client:Request(name, data)
	local request = client.Player:WaitForChild("SlimRequest", 24)
	if(request)then
		return request:InvokeServer(name,data)
	else
		client.Player:Kick("Lost connection to the request handler, contact a developer and try again.")
	end
end

function client:HandleEvent(name, cooldown, f)
	events[name]={Cooldown = cooldown, Handle = f}
	local con = {}
	function con:Disconnect()
		events[name] = nil
	end
	return con
end


return client
