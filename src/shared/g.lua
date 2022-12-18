local g = {
	Services = {};
	Started = false;
	Scope = if game:GetService("RunService"):IsServer() then "Server" else "Client"
}

local m = {}

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