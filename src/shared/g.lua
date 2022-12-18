local g = {}

if game:GetService("RunService"):IsServer() then
	print("server")
else
	print("client")
end

return g