-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService

-- Data
local DataFolder = ReplicatedStorage.Shared.Data
local Eggs = require(DataFolder.Shop.Eggs)

-- Utils
local AnimalRoller = require(ReplicatedStorage.Shared.Utils.AnimalRoller)
local EggHatchRules = {
	Egg_Small = { Min = 1, Max = 2 },
	Egg_Medium = { Min = 2, Max = 4 },
	Egg_Large = { Min = 4, Max = 6 },
}

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

	-- Deduct Gold
	data.Gold -= price

	-- Add Egg
	data.Eggs[eggType] = (data.Eggs[eggType] or 0) + 1

	-- Notify client
	DataService.Client.DataChanged:Fire(player, {
		Gold = data.Gold,
		Eggs = data.Eggs,
	})

	return true
end

function EggService:HatchEgg(player: Player, eggType: string)
	local data = DataService:GetData(player)

	if not data then
		return false, "NO_DATA"
	end

	if not data.Eggs[eggType] or data.Eggs[eggType] <= 0 then
		return false, "NO_EGG"
	end

	local rule = EggHatchRules[eggType]
	if not rule then
		return false, "INVALID_EGG"
	end

	-- Consume egg
	data.Eggs[eggType] -= 1

	-- Roll amount
	local count = math.random(rule.Min, rule.Max)

	-- Roll animals
	local animals = AnimalRoller.RollMany(count)

	-- Add to inventory
	data.Animals = data.Animals or {}

	for animalId, amount in pairs(animals) do
		data.Animals[animalId] = (data.Animals[animalId] or 0) + amount
	end

	-- Notify client
	DataService.Client.DataChanged:Fire(player, {
		Eggs = data.Eggs,
		Animals = data.Animals,
	})

	return true, animals
end


-- || Client Functions || --

function EggService.Client:BuyEgg(player: Player, id: string)
	return self.Server:BuyEgg(player, id)
end

function EggService.Client:HatchEgg(player: Player, eggType: string)
	return self.Server:HatchEgg(player, eggType)
end

-- || Knit Lifecycle || --

function EggService:KnitStart()
	DataService = Knit.GetService("DataService")

	print(`[Egg Service] Service started.`)
end

return EggService