-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService

-- CoinService
local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {
		CoinsChanged = Knit.CreateSignal(),
	},
})

function CoinService:AddCoins(player: Player, amount: number)
	if amount <= 0 then return end

	local data = DataService:GetData(player)
	if not data then return end

	data.Gold += amount
	self.Client.CoinsChanged:Fire(player, data.Gold)

	print(`[CoinService] +{amount} Gold → {player.Name} (Total: {data.Gold})`)
end

function CoinService:GetCoins(player: Player): number
	local data = DataService:GetData(player)
	return data and data.Gold or 0
end

-- || Knit Lifecycle || --

function CoinService:KnitStart()
	DataService = Knit.GetService("DataService")

	print(`[Coin Service] Service started.`)
end

return CoinService
