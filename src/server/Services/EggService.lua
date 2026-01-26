-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local CoinService
local DataService

-- Data
local DataFolder = ReplicatedStorage.Shared.Data
local Eggs = require(DataFolder.Shop.Eggs)

-- Egg Service
local EggService = Knit.CreateService({
	Name = "EggService",
	Client = {},
})

-- || Functions || --

function EggService:BuyEgg(player: Player, eggType: string)
	local data = DataService:GetData(player)
	if not data then
		return false, "NO_DATA"
	end

	local eggInfo = Eggs[eggType]
	if not eggInfo then
		return false, "INVALID_EGG"
	end

	local price = eggInfo.Price
	if data.Gold < price then
		return false, "NOT_ENOUGH_GOLD"
	end

	-- 💰 Deduct
	data.Gold -= price

	-- 🥚 Add egg
	data.Eggs[eggType] = (data.Eggs[eggType] or 0) + 1

	-- Notify client
	DataService.Client.DataChanged:Fire(player, {
	Gold = data.Gold,
	Eggs = data.Eggs
})

	return true
end

-- || Client Functions || --

function EggService.Client:BuyEgg(player : Player, id : string)
	return self.Server:BuyEgg(player, id)
end


-- || Knit Lifecycle || --

function EggService:KnitStart()
	CoinService = Knit.GetService("CoinService")
    DataService = Knit.GetService("DataService")
    
	print(`[Egg Service] Service started.`)
end

return EggService