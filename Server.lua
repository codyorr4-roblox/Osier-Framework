local ps = game:GetService("Players")
local rs = game:GetService("RunService")
local dss = game:GetService("DataStoreService")

local server = {
	Autosaving = true,
	SaveInterval = rs:IsStudio() and 15 or 30,
	PlayerAdded = {}
}

local canStart=true
local started = false
local defaultData 
local sessionData = {}
local saved = {}
local playerAddedEvents, playerAddedCount = {},0

local events = {}
local requests = {}
local eventCooldowns = {}
local requestCooldowns = {}
local eventConnections = {}
local clientsReady = {}


local function uid(player)
	return "Osier-"..player.UserId
end

local function reconcile(player)
	if(defaultData==nil)then return end
	local id = uid(player)
	local cachedData = sessionData[id]
	for i,v in pairs(defaultData)do
		if(cachedData[i]==nil)then
			sessionData[id][i]=v
		end
	end
	
	for i, v in pairs(cachedData)do
		if(defaultData[i]==nil)then
			cachedData[i]=nil
		end
	end
end

local function load(player)
	local store = dss:GetDataStore(uid(player))
	local loadedData
	local id = uid(player)
	
	local success, err = pcall(function()
		loadedData = store:GetAsync("PlayerSaveData")
	end)
	
	if(success)then
		if(loadedData)then
			if(loadedData._OsierSessionId == "") then
				sessionData[id]=loadedData
				reconcile(player)
			else
				player:Kick("You are logged into another session already, could not load data.")
			end
		else
			sessionData[id]=defaultData
		end
		
		sessionData[id]._OsierSessionId = game.JobId
		
		local savedSuccess, saveErr = pcall(function()
			store:SetAsync("PlayerSaveData", sessionData[id])
		end)
		
		if(savedSuccess)then
			saved[id] = os.time() + server.SaveInterval
		else
			player:Kick("Could not save the current session ID, contact a developer and try again.")
		end
		
	else
		player:Kick("Could not load your data, contact a developer and try again.")
	end
end

local function update(player, leaving)
	local id = uid(player)
	local store = dss:GetDataStore(uid(player))
	local cachedData = sessionData[id]
	local saveCooldown = saved[id]
	if(cachedData==nil)then return end
	if(saveCooldown and os.time() < saveCooldown and leaving == nil)then return end
	saved[id] = os.time() + server.SaveInterval
	
	if(leaving)then
		cachedData._OsierSessionId = ""
	end
	
	local success, err = pcall(function()
		store:UpdateAsync("PlayerSaveData", function(oldData)
			if(oldData)then
				if(cachedData and cachedData._OsierSessionId == game.JobId)then
					return cachedData
				else
					player:Kick("You are logged into another session already, could not save data.")
				end
			end
		end)
	end)
	
	if(success)then
		if(leaving)then
			saved[id]=nil
			sessionData[id]=nil
		else
			saved[id] = os.time() + server.SaveInterval
		end
	else
		player:Kick("Could not save your data, contact a developer and try again.")
	end
end

function startAutoSaving()
	coroutine.wrap(function()
		local i = server.SaveInterval
		local t = os.time() + i
		while(canStart)do
			if(server.Autosaving)then
				if(os.time() >= t)then
					t = os.time() + i
					for _, player in pairs(ps:GetPlayers())do
						coroutine.wrap(function()
							update(player)
						end)()
					end
					print("Saved all players")
				end
				rs.Stepped:Wait()
			else
				wait(2)
			end
		end
	end)()
end

function handleRemotes(player)
	local id = uid(player)
	
	local event = Instance.new("RemoteEvent")
	event.Name = "OsierEvent"
	event.Parent = player
	
	local request = Instance.new("RemoteFunction")
	request.Name = "OsierRequest"
	request.Parent = player
	
	local dataReplicator = Instance.new("RemoteEvent")
	dataReplicator.Name = "DataReplicator"
	dataReplicator.Parent = player
	
	eventCooldowns[id]={}
	requestCooldowns={}
	
	eventConnections[id] = event.OnServerEvent:Connect(function(player, eventId, data)
		local e = events[eventId]
		if(not e)then return end
		
		local cooldown = eventCooldowns[id][eventId]
		if(cooldown and os.time() < cooldown)then return end
		eventCooldowns[id][eventId] = os.time() + e.Cooldown
		
		e.Handle(player, data)
	end)
	
	request.OnServerInvoke = function(player, requestId, data)
		local r = requests[requestId]
		if(not r)then return end

		local cooldown = requestCooldowns[id][requestId]
		if(cooldown and os.time() < cooldown)then return end
		requestCooldowns[id][requestId] = os.time() + r.Cooldown

		return r.Handle(player, data)
	end
	
end
	
	
	

function server:Start(newDefaultData)
	if(canStart==false)then return end
	canStart = false
	

	if(newDefaultData==nil or type(newDefaultData) ~= "table")then 
		error("Please provide a table to represent DefaultData when initiating the server.")
		return
	end
	
	defaultData = newDefaultData
	
	startAutoSaving()
	
	server:HandleEvent("_OsierClientReady", 5, function(player,data)
		clientsReady[uid(player)]=true
	end)

	ps.PlayerAdded:Connect(function(player)
		-- handle respawning
		player.CharacterAdded:Connect(function(character)
			rs.Stepped:Wait()
			local client = script.Parent.Client:Clone()
			client.Parent = player:WaitForChild("PlayerGui")
		end)
		
		-- load data and handle remotes
		load(player)
		handleRemotes(player)
		
		local replicator = player:WaitForChild("DataReplicator", 12)
		if(replicator)then
			replicator:FireClient(player, server:GetData(player))
		else
			player:Kick("Data replicator was destroyed.")
			return
		end

		server:WaitForClient(player)
		
		
		
		-- run all custom player added events when data/remotes are ready.
		for _, playerAdded in pairs(playerAddedEvents)do
			coroutine.wrap(function()
				if(type(playerAdded) == "function")then
					playerAdded(player)
				end
			end)()
		end
		
	end)
	-- dispose of events/cooldowns and update player data.
	ps.PlayerRemoving:Connect(function(player)
		-- dispose of all player related data/events
		local id = uid(player)

		-- update data
		coroutine.wrap(function()
			update(player, true)
		end)()
		
		if(eventConnections[id])then
			eventConnections[id]:Disconnect()
			eventConnections[id]=nil
		end
		if(eventCooldowns[id])then
			eventCooldowns[id] = nil
		end
		if(requestCooldowns[id])then
			requestCooldowns[id] = nil
		end
		if(clientsReady[id])then
			clientsReady[id]=nil
		end
	end)
	
	-- save all data when server shutsdown
	game:BindToClose(function()
		canStart=false
		for _, player in pairs(ps:GetPlayers())do
			coroutine.wrap(function()
				
				update(player, true)
			end)()
		end
	end)
	
	started = true
end



function server:WaitForClient(player)
	local id = uid(player)
	if(clientsReady[id] and sessionData[id] and player:FindFirstChild("OsierEvent") and player:FindFirstChild("OsierRequest") and player:FindFirstChild("DataReplicator"))then
		return
	end
	
	local start = os.time() + 12
	repeat
		if(os.time() >= start)then
			player:Kick("Could not initiate client contact a developer and try again")
			return false
		end
		rs.Stepped:Wait()
	until clientsReady[id] and sessionData[id]~=nil and player:FindFirstChild("OsierEvent") and player:FindFirstChild("OsierRequest") and player:FindFirstChild("DataReplicator")
	
	return true
end

function server:WaitForStart()
	local start = os.time() + 32
	repeat
		if(os.time() >= start)then
			error("Could not start the server")
			return false
		end
		rs.Stepped:Wait()
	until started == true
end



function server:GetData(player)
	return sessionData[uid(player)]
end

function server:GetValue(player, key)
	return sessionData[uid(player)][key]
end

function server:UpdateValue(player, key, value)
	local id = uid(player)
	local cachedData = sessionData[id]
	
	if(cachedData)then
		local oldValue = cachedData[key]

		if(value and oldValue)then
			if(type(value) == "function")then
				value = value(oldValue)
			end
			sessionData[id][key] = value
			
			coroutine.wrap(function()
				local replicator = player:WaitForChild("DataReplicator", 12)
				if(replicator)then
					replicator:FireClient(player, {Key = key, Value = value})
				else
					player:Kick("Data replicator was destroyed.")
					return
				end
			end)()
		end
	end

end



function server:Fire(player, name, data)
	if(not player)then warn("please provide a player to fire the client") end
	local event = player:WaitForChild("OsierEvent", 12)
	if(event)then
		event:FireClient(player, name, data)
	end
end

function server:FireAll(name, data)
	for _, player in pairs(ps:GetPlayers())do
		coroutine.wrap(function()
			server:Fire(player, name, data)
		end)()
	end
end

function server:HandleEvent(name, cooldown, f)
	events[name] = {Cooldown = cooldown, Handle = f}
	local con = {}
	function con:Disconnect()
		events[name]=nil
	end
	return con
end

function server:HandleRequest(name, cooldown, f)
	requests[name] = {Cooldown = cooldown, Handle = f}
	local con = {}
	function con:Disconnect()
		requests[name]=nil
	end
	return con
end



function server.PlayerAdded:Connect(f)
	local id = playerAddedCount+1
	playerAddedCount+=1
	playerAddedEvents["PlayerAdded"..id] = f
	local connection = {}
	function connection:Disconnect()
		playerAddedCount-=1
		playerAddedEvents["PlayerAdded"..id]=nil
	end
	return connection
end

if(rs:IsClient())then error("Cannot use the osier server with a local script.") end
return server
