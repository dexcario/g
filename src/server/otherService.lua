local g = require(game.ReplicatedStorage.Common.g)

local otherService = g:AddService{
    Name = "otherService";
}

function otherService:Init()
    for i = 10, 1, -1 do
        task.wait(1)
        print("other service counting", i)
    end
end

function otherService:Start()
    print("time service finished loading")
end

return otherService