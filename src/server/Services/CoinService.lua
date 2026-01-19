local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CoinService = Knit.CreateService({
    Name = "CoinService",
    Client = {
        CoinsChanged = Knit.CreateSignal(),
    },
})

local playerCoins = {}

function CoinService:AddCoins(player : Player, amount : number)
    local userId = player.UserId
    playerCoins[userId] = (playerCoins[userId] or 0) + amount
    self.Client.CoinsChanged:Fire(player, playerCoins[userId])

    print(`[Coin Service] Added {amount} coins to Player {player.Name}. Total now: {playerCoins[userId]}`)
end

function CoinService:GetCoins(player : Player) : number
    return playerCoins[player.UserId] or 0
end

-- || Knit Lifecycle || --

function CoinService:KnitStart()
   game.Players.PlayerRemoving:Connect(function(player)
       playerCoins[player.UserId] = nil
   end) 

   print(`[Coin Service] Service started.`)
end

return CoinService