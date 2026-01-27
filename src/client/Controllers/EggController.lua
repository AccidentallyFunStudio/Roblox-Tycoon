-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService
local EggService

-- EggController
local EggController = Knit.CreateController({
	Name = "EggController",
})

--|| Functions ||--

function EggController:BuyEgg(eggType: string)
	if not EggService then
		EggService = Knit.GetService("EggService")
	end

	local success, result = EggService:BuyEgg(eggType):await()
	if not success then
		warn(`[Egg Controller] Egg purchase failed: {result}`)
	end
end

function EggController:HatchEgg(eggtype: string)
	if not EggService then
		EggService = Knit.GetService("EggService")
	end

	if not DataService then
		DataService = Knit.GetService("DataService")
	end

	local pSuccess, fSuccess, animalsHatched = EggService:HatchEgg(eggtype):await()
	if pSuccess and fSuccess then
		print(`[Egg Controller] Successfully hatched: {animalsHatched}`)

		local success, updatedData = DataService:GetData():await()
		if success and updatedData.Animals then
			print(`[Egg Controller] Updated Animal Inventory: {updatedData.Animals}`)
		end
	else
		warn(`[Egg Controller] Hatch failed or encountered an error`)
	end
end

function EggController:KnitStart()
	DataService = Knit.GetService("DataService")
	EggService = Knit.GetService("EggService")

	print(`[Egg Controller] Controller started.`)
end

return EggController