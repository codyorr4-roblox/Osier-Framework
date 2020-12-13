local rs = game:GetService("RunService")
if(rs:IsServer())then
	local server = {}

	local players = game:GetService("Players")
	local dss = game:GetService("DataStoreService")
	local orderedDatastores = {}

	local initiated = false
	local saveInterval = rs:IsStudio() and 15 or 30
	local saved = {}
	local sessionData = {}
	local defaultData = {}
	local events = {}
	local requests = {}
	local eventCooldowns = {}
	local requestCooldowns = {}


	local function reconcile(player)
		local id = "Slim-"..player.UserId
		local data = sessionData[id]
		for i, v in pairs(defaultData)do
			if(not data[i])then
				data[i] = v
			end
		end
		for i, v in pairs(data)do
			if(not defaultData[i])then
				data[i] = nil
			end
		end
	end

	local function load(player)
		local id = "Slim-"..player.UserId
		if(sessionData[id])then return end

		local store = dss:GetDataStore(id)
		local data
		local success, err = pcall(function()
			data  = store:GetAsync("playerdata2")
		end)

		if(success)then
			if(data and type(data) == "table")then
				sessionData[id] = data
				reconcile(player)
			else
				sessionData[id] = defaultData
			end

			sessionData[id].SessionId = game.JobId

			local s, e = pcall(function()
				store:SetAsync("playerdata2", sessionData[id])
			end)

			if(s)then
				saved[id] = os.time() + saveInterval
			else
				player:Kick(e)
			end
		else
			player:Kick(err)
		end
	end

	local function update(player, urgent)
		local id = "Slim-"..player.UserId
		if(saved[id] and os.time() < saved[id] and urgent == nil)then return end
		saved[id]=os.time() + saveInterval

		local store = dss:GetDataStore(id)
		local success, err = pcall(function()
			store:UpdateAsync("playerdata2", function()
				local cachedData = sessionData[id]
				if(cachedData and type(cachedData)=="table" and cachedData.SessionId == game.JobId)then
					return cachedData
				end
			end)
		end)

		if(success)then
			saved[id]=os.time() + saveInterval
		else
			player:Kick(err)
		end
	end

	local function startAutosaving()
		print("Started saving at "..saveInterval.." second intervals")
		local i = os.time()+saveInterval
		coroutine.wrap(function()
			while(initiated)do
				if(os.time()  >= i)then
					for _, player  in pairs(players:GetPlayers()) do
						coroutine.wrap(function()
							update(player)
						end)()
					end
					print("Saved all players")
					i=os.time()+saveInterval
				end
				rs.Stepped:Wait()
			end
		end)()
	end

	local function startListening(player)
		local id = "Slim-"..player.UserId
		
		local slimEvent = Instance.new("RemoteEvent")
		slimEvent.Name = "SlimEvent"
		slimEvent.Parent = player

		local slimFunction = Instance.new("RemoteFunction")
		slimFunction.Name = "SlimRequest"
		slimFunction.Parent = player
		
		eventCooldowns[id]={}	
		requestCooldowns[id] = {}

		eventCooldowns[id]._SlimEventConnection = slimEvent.OnServerEvent:Connect(function(player, eventId, data)
			local event = events[eventId]
			if(not event)then return end

			local cooldown = eventCooldowns[id][eventId]
			if(cooldown and os.clock() < cooldown)then 
				return 
			end

			event.Handle(player, data)
			eventCooldowns[id][eventId] = os.clock() + event.Cooldown
		end)

		slimFunction.OnServerInvoke = function(player, requestId, data)
			local request = requests[requestId]
			if(not request)then return end

			local cooldown = requestCooldowns[id][requestId]
			if(cooldown and os.clock() < cooldown)then 
				return 
			end
			requestCooldowns[id][requestId] = os.clock() + request.Cooldown

			local value = request.Handle(player, data)
			requestCooldowns[id][requestId] = os.clock() + request.Cooldown
			return value
		end
	end



	--[[
	    Start the server
	]]

	function server:Init(newDefaultData)
		if(initiated)then return end
		initiated=true
		
		defaultData=newDefaultData
		startAutosaving()
		
		local readyPlayers = {}
		server:HandleRequest("_RequestReadiness", 0, function(player, data)
			return readyPlayers[player.Name]
		end)
		
		players.PlayerAdded:Connect(function(player)
			load(player)
			startListening(player)
			server:WaitForClient(player)
			local dataReady = false
			repeat
				rs.Stepped:Wait()
				dataReady = server:Request(player, "_SlimDataReplicate", server:GetData(player))
			until dataReady == true
			readyPlayers[player.Name]=true
		end)

		local removingCon = players.PlayerRemoving:Connect(function(player)
			local id = "Slim-"..player.UserId
			eventCooldowns[id]._SlimEventConnection:Disconnect()
			eventCooldowns[id]=nil
			requestCooldowns[id]=nil
			for i, v in pairs(orderedDatastores)do
				coroutine.wrap(function()
					local s,e = pcall(function()
						v:SetAsync(player.Name, sessionData[id][i])
					end)
				end)()
			end
			update(player)
			sessionData[id]=nil
		end)

		game:BindToClose(function()
			initiated=false
			removingCon:Disconnect()
			for _, player  in pairs(players:GetPlayers()) do
				coroutine.wrap(function()
					if(sessionData["Slim-"..player.UserId])then
						update(player, true)
					end
				end)()
			end
		end)
		
		return self
	end




	--[[
	   Wait functions
	]]
	function server:WaitForClient(player)
		local id = "Slim-"..player.UserId
		local event = player:FindFirstChild("SlimEvent")
		local request = player:FindFirstChild("SlimRequest")
		repeat rs.Stepped:Wait() until event~=nil and request~=nil and eventCooldowns[id]~=nil and requestCooldowns[id]~=nil and sessionData[id]~=nil
		return true
	end




	--[[
	    Custom Leaderboards and Core leaderstat menu.
	]]

	function server:AddCoreStat(player, name)
		local value = sessionData["Slim-"..player.UserId][name]
		if(not value)then return end

		if(not player:FindFirstChild("leaderstats"))then
			local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player
		end

		if(not player.leaderstats:FindFirstChild(name))then
			local instance
			local t = type(value) 
			if(t==nil or t=="table" or t=="function")then return end

			if(t == "boolean")then
				instance = Instance.new("BoolValue")
			elseif(t == "string")then
				instance = Instance.new("StringValue")
			elseif(t == "number")then
				instance = Instance.new("NumberValue")
			end
			instance.Name = name
			instance.Value = value
			instance.Parent = player.leaderstats
		end
	end

	function server:AddLeaderboard(name, isAscending, pageSize)
		local ods = dss:GetOrderedDataStore(name)
		local pagesObject = {}

		local success, pages = pcall(function()
			return ods:GetSortedAsync(isAscending, pageSize)
		end)

		if(success)then
			function pagesObject:NextPage()
				local s,e = pcall(function()
					pages:AdvanceToNextPageAsync()
				end)
				return s,e
			end

			function pagesObject:Read(f)
				if(type(f)=="function")then
					local page = pages:GetCurrentPage()
					for rank, data in ipairs(page)do
						f(rank, data.key, data.value)
					end
				end
			end

			orderedDatastores[name]=ods

			return pagesObject
		else
			warn("Could not load leaderboard for the value called ".. name)
		end
	end

	function server:GetValue(player, name)
		return sessionData["Slim-"..player.UserId][name]
	end

	function server:GetData(player)
		return sessionData["Slim-"..player.UserId]
	end

	function server:SetValue(player, name, value)
		local id = "Slim-"..player.UserId
		local oldValue = sessionData[id][name]
		value =  type(value) == "function" and value(oldValue) or value
		sessionData[id][name] = value
		
		coroutine.wrap(function()
			server:Request("_SlimDataReplicate", {[""..name] = value})
			local leaderstats = player:FindFirstChild("leaderstats")
			if(leaderstats)then
				local valueInstance = leaderstats:FindFirstChild(name)
				if(valueInstance)then
					valueInstance.Value = value
				end
			end
		end)()
	end




	--[[
	    Remote event and Request functions
	]]

	function server:HandleEvent(name, cooldown, f)
		events[name]={Cooldown = cooldown}
		events[name].Handle = f
	end

	function server:HandleRequest(name, cooldown, f)
		requests[name]={Cooldown = cooldown}
		requests[name].Handle = f
	end

	function server:Fire(player, name, data)
		local event = player:FindFirstChild("SlimEvent")
		if(event)then
			event:FireClient(player, name, data)
		end
	end

	function server:FireAll(name, data)
		for _, player in pairs(players:GetPlayers())do
			coroutine.wrap(function()
				local event = player:FindFirstChild("SlimEvent")
				if(event)then
					event:FireClient(player, name, data)
				end
			end)()
		end
	end

	function server:Request(player, name, data)
		local request = player:FindFirstChild("SlimRequest")
		if(request)then
			return request:InvokeClient(player, name, data)
		end
	end

	function server:RequestAll(name, data)
		local returnedValues = {}
		for _, player in pairs(players:GetPlayers()) do
			local request = player:FindFirstChild("SlimRequest")
			if(request)then
				returnedValues[player.Name] = request:InvokeClient(player, name, data)
			end
		end

		return returnedValues
	end


	return server




elseif(rs:IsClient())then	
	local client = {}
	
	local rs = game:GetService("RunService")
	
	local initiated=false
	local player = game.Players.LocalPlayer
	local events = {}
	local requests = {}
	local eventCooldowns = {}
	local requestCooldowns = {}
	local data
	local slimEvent = player:WaitForChild("SlimEvent")
	local slimRequest = player:WaitForChild("SlimRequest")

	local function startListening()
		slimEvent.OnClientEvent:Connect(function(eventId, data)
			local event = events[eventId]
			if(not event)then return end

			local cooldown = eventCooldowns[eventId]
			if(cooldown and os.clock() < cooldown)then 
				return 
			end

			event.Handle(data)
			eventCooldowns[eventId] = os.clock() + event.Cooldown
		end)

		slimRequest.OnClientInvoke = function(requestId, data)
			local request = requests[requestId]
			if(not request)then return end

			local cooldown = requestCooldowns[requestId]
			if(cooldown and os.clock() < cooldown)then 
				return 
			end
			
			local value = request.Handle(data)
			requestCooldowns[requestId] = os.clock() + request.Cooldown

			return value
		end
	end
	
	
	
	
	
	--[[
	   Client Initiation
	]]
	function client:Init()
		if(initiated)then return end
		initiated=true
		
		startListening()
		
		--data replication
		client:HandleRequest("_SlimDataReplicate", 0.1, function(replicatedData)
			if(not data)then
				data = replicatedData
			else
				for i, v in pairs(replicatedData)do
					data[i]=v
				end
			end
			return true
		end)
		
		return self
	end
	
	
	
	--[[
	   Wait functions
	]]
	function client:WaitForServer()
		local ready = false
		repeat rs.Stepped:Wait()
			local s,e = pcall(function()
				ready = client:Request("_RequestReadiness")
			end)
		until ready == true and data~=nil
		return ready
	end
	
	
	
	
	--[[
	   Replicated Data function
	]]
	function client:GetData()
		return data
	end
	
	function client:GetValue(name)
		return data[name]
	end
	
	
	

	--[[
	   Remote functions
	]]
	function client:HandleEvent(name, cooldown, f)
		events[name]={Cooldown = cooldown, Handle = f}
	end

	function client:HandleRequest(name, cooldown, f)
		requests[name]={Cooldown = cooldown, Handle = f}
	end

	function client:Fire(name, data)
		local event = player:FindFirstChild("SlimEvent")
		if(event)then
			event:FireServer(name, data)
		end
	end

	function client:Request(name, data)
		local request = player:FindFirstChild("SlimRequest")
		if(request)then
			return request:InvokeServer(name, data)
		end
	end


	return client	
end
