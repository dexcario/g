local g = require(game.ReplicatedStorage.Common.g)

local testService = g:AddService{
    Name = "testService";
}

function testService:Init()
    print("init A")
end

function testService:Start()
    print("test service has started")
end

return testService