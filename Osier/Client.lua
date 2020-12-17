local rs = game:GetService("RunService")
if(rs:IsServer())then error("Cannot use an osier client with a server script") end

local client = {}

client.Data = {}

local player = game.Players.LocalPlayer
local canStart = true 
local started = false
local dataReplicated=false
local events = {}
local eventCooldowns = {}
local dataChangedEvents, dataChangedCount = {}, 0

function start()

	local event = player:WaitForChild("OsierEvent", 24)
	local request = player:WaitForChild("OsierRequest", 24)
	local replicator = player:WaitForChild("DataReplicator", 24)
	
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
			local k,v = data.Key, data.Value
			client.Data[k] = v
			
			for i = 1, dataChangedCount do
				coroutine.wrap(function()
					local eventList = dataChangedEvents[k]
					if(eventList)then
						local event = eventList["Event-"..i]
						if(event)then
							event(v)
						end
					end
				end)()
			end
			
		end
	end)
	
	
	started = true
	client:WaitForStart()
	client:Fire("_OsierClientReady")
end

function client:WaitForStart()
	if(canStart==true)then
		canStart=false
		start()
	end
	if(started and dataReplicated and client.Data)then return end
	
	-- local scripts that dont start the client will depend on the loop below.
	local start = os.time() + 24
	repeat
		if(os.time() >= start)then
			player:Kick("Could not start the client, contact a developer and try again.")
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
	local event = player:WaitForChild("OsierEvent", 24)
	if(event)then
		event:FireServer(name, data)
	else
		player:Kick("Lost connection to the event handler, contact a developer and try again.")
	end
end

function client:Request(name, data)
	local request = player:WaitForChild("OsierRequest", 24)
	if(request)then
		return request:InvokeServer(name,data)
	else
		player:Kick("Lost connection to the request handler, contact a developer and try again.")
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

function client.DataChanged(name)
	if(name==nil or type(name)~="string")then error("Provide a string for the value you want to track.")end
	
	if(dataChangedEvents[name]==nil)then
		dataChangedEvents[name]={}
	end
	
	dataChangedCount+=1
	local id = "Event-"..dataChangedCount
	local signal = {}
	
	function signal:Connect(f)
		dataChangedEvents[name][id]=f
		local connection = {}
		
		function connection:Disconnect()
			dataChangedCount-=1
			
			if(dataChangedCount<=0)then
				dataChangedEvents[name]=nil
			else
				dataChangedEvents[name][id]=nil
			end
		end
	end
	
	return signal
end


return client
