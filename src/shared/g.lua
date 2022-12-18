local g = {
	Services = {};
	Started = false;
	Scope = if game:GetService("RunService"):IsServer() then "Server" else "Client";
	DataStore = "gStore";
}

local mt = {}

function mt.__index(key)
	if g.Services[key] then
		return g.Services[key]
	end
end

setmetatable(g, mt)

function g:AddService(service)
	
	g.Services[service.Name] = service

	return service

end

if g.Scope == "Server" then

	g.DB = game:GetService("DataStoreService"):GetDataStore(g.DataStore)
	g.DataFiles = {};

	function g:GetData(player, waitFor)
		if waitFor then
			while not g.DataFiles[player] do
				task.wait()
			end
		end

		return g.DataFiles[player]
	end

	local gDataServer = g:AddService({
		Name = "gDataServer";
	})

	function g.DeepClone(myTable)
		local newTable = {}

		for key, value in next, myTable do
			if type(value) == "table" then
				newTable[key] = g.DeepClone(value)
			else
				newTable[key] = value
			end
		end

		return newTable
	end

	function gDataServer:PlayerAdded(player)
		
		local dataTable = g.DeepClone(g.DataTemplate or {})
		
		local loaded = g.DB:GetAsync("Player_" .. player.UserId)
		if loaded then
			for key, value in next, loaded do
				dataTable[key] = value
			end
		end

		g.DataFiles[player] = dataTable
		print("Loaded Data for", player)

	end

	function gDataServer:Save(player)
		if not g.DataFiles[player] then
			return
		end

		g.DB:SetAsync("Player_" .. player.UserId, g.DataFiles[player])
		print(player, "Saved")
	end

	function gDataServer:Start()

		game.Players.PlayerRemoving:Connect(function (player)
			gDataServer:Save(player)
			g.DataFiles[player] = nil
		end)

		game.Players.PlayerAdded:Connect(function (player)
			gDataServer:PlayerAdded(player)
		end)
		for _, player in ipairs(game.Players:GetPlayers()) do
			task.spawn(function ()
				gDataServer:PlayerAdded(player)
			end)
		end

		while true do

			for _, player in ipairs(game.Players:GetPlayers()) do
				local playerData = g.DataFiles[player]

				if playerData then
					gDataServer:Save(player)
				end
			end

			task.wait(30)
		end
	end

	game:BindToClose(function ()
		for _, player in ipairs(game.Players:GetPlayers()) do
			gDataServer:Save(player)
		end
		print("Bind to close finished")
	end)

elseif g.Scope == "Client" then

	g.Data = {};

	function g:GetData(player, waitFor)
		if waitFor then
			while not g.Data[player] do
				task.wait()
			end
		end

		return g.Data[player]
	end

	local gDataClient = g:AddService({
		Name = "gDataClient";
	})

	function gDataClient:Start()
		while true do
			task.wait(3)
			--print("gDataClient")
		end
	end

end

function g:Start()

	local servicesLoading = {}

	for serviceName, service in pairs(g.Services) do
		service.Name = service.Name or "service" .. math.random(1, 9999999999999)
		
		if service.Init then
			servicesLoading[serviceName] = true

			task.spawn(function ()
				service:Init()
				servicesLoading[serviceName] = nil
			end)
		end

	end

	local servicesLoadingCount
	repeat
		task.wait()
		servicesLoadingCount = 0
		for serviceName, service in pairs(servicesLoading) do
			servicesLoadingCount += 1
		end
	until servicesLoadingCount == 0

	g.Started = true

	print("g running on", g.Scope)

	for serviceName, service in pairs(g.Services) do
		if service.Start then
			task.spawn(function ()
				service:Start()
			end)
		end
	end

end

-- Yeild until g has started and then return g, use for misc scripts and add :Get() on the end of the require.
function g:Get()
	while g.Started == false do
		task.wait()
	end
	return g
end

return g