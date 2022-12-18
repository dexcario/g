local g = require(game.ReplicatedStorage.Common.g)

for _, s in ipairs(script:GetChildren()) do
    require(s)
end

g.DataTemplate = {
    Coins = 3;
    Gems = 2;
    MyTable = {
        A = 1;
        B = 2;
        C = 3;
    }
}

g:Start()