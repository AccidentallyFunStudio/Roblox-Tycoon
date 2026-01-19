-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Knit Packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local CoinService = nil

-- Client
local Client = StarterPlayer.StarterPlayerScripts.Client

-- Rodux
local CoinActions = require(Client.Rodux.Actions.CoinActions)
local Store = require(Client.Rodux.Store)

-- CoinController
local CoinController = Knit.CreateController({
	Name = "CoinController",
})

--|| Local Functions ||--

--|| Functions ||--

function CoinController:KnitStart()
    CoinService = Knit.GetService("CoinService")

    CoinService.CoinsChanged:Connect(function(newCoins)
        print(`[Coin Controller] Received new coins value: {newCoins}`)
        Store:dispatch(CoinActions.setCoins(newCoins))
    end)
end

return CoinController