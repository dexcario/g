local g = require(game.ReplicatedStorage.Common.g)

for _, s in ipairs(script:GetChildren()) do
    require(s)
end

g:Start()