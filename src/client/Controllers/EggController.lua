-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Knit Services
local EggService

-- EggController
local EggController = Knit.CreateController({
	Name = "EggController",
})

--|| Functions ||--

function EggController:BuyEgg(eggType: string)
	EggService = Knit.GetService("EggService")

	local success, result = EggService:BuyEgg(eggType):await()

	if not success then
		warn("Egg purchase failed:", result)
	end
end

function EggController:KnitStart()
	-- EggService.PurchaseResult:Connect(function(success, eggType, goldLeft)
	-- 	if success then
	-- 		print("Purchased:", eggType, "Gold left:", goldLeft)
	-- 	else
	-- 		warn("Egg purchase failed")
	-- 	end
	-- end)
end

return EggController
