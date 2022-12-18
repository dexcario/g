local g = require(game.ReplicatedStorage.Common.g)

local testService = g:AddService{
    Name = "testService";
}

function testService:Init()
    print("init A")
end

function testService:Start()
    print("test service has started")

    while true do
        for _, player in ipairs(game.Players:GetPlayers()) do
            local playerData = g:GetData(player)
            if playerData then
                playerData.Coins += 1
                print(playerData)
            end
        end

        task.wait(2)
    end
end

return testService