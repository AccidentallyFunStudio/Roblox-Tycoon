-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService

-- Data
local DataFolder = ReplicatedStorage.Shared.Data
local Eggs = DataFolder.Shop.Eggs

-- Egg Service
local EggService = Knit.CreateService({
	Name = "EggService",
	Client = {
        BuyEgg = Knit.CreateSignal();
    },
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

	-- Notify data change
	DataService.DataChanged:Fire(player, "Gold", data.Gold)
	DataService.DataChanged:Fire(player, "Eggs", eggType)

	return true
end


-- || Knit Lifecycle || --

function EggService:KnitStart()
    DataService = Knit.GetService("DataService")
    
	print(`[Egg Service] Service started.`)
end

return EggService