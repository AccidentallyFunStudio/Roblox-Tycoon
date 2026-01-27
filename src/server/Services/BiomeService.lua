-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Directories
local BIOMES_ASSETS = Workspace:WaitForChild("Assets"):WaitForChild("Biomes")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService

-- Data
local BiomesData = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

local BiomeService = Knit.CreateService({
	Name = "BiomeService",
	Client = {},
})

--|| Functions ||--

function BiomeService:PurchaseBiome(player: Player, biomeId: string): boolean
	local data = DataService:GetData(player)
	if not data then
		warn("[Biome Service] unable to load Player Data.")
		return false
	end

	local biomeConfig = BiomesData[biomeId]
	if not biomeConfig then
		warn("[Biome Service] Unable to load Biome Data.")
		return false
	end

	local biomeState = data.Biomes[biomeId]
	local cost = biomeConfig.Upgrades[1].Cost

	if biomeState and biomeState.Level > 0 then
		warn(`[Biome Service] {player.Name} wants to purchase already owned Biome {biomeId}`)
		return false
	end

	if data.Gold < cost then
		warn(`[Biome Service] Insufficient Gold to buy a Biome for {player.Name}`)
		return false
	end

	-- Transaction: Deduct Gold and Unlock Biome
	data.Gold -= cost
	data.Biomes[biomeId].Level = 1

	-- In a real scenario, you'd trigger a signal here for the client to refresh UI
	DataService.Client.DataChanged:Fire(player, data)

	print(`{player.Name} purchased {biomeConfig.Name} for {cost} Gold`)
	return true
end

function BiomeService:UpgradeBiome(player: Player, biomeId: string)
	local data = DataService:GetData(player)
	if not data then
		return false
	end

	local biomeConfig = BiomesData[biomeId]
	local biomeState = data.Biomes[biomeId]

	if not biomeState or biomeState.Level == 0 then
		return false
	end
	if biomeState.Level >= biomeConfig.MaxLevel then
		return false
	end

	local nextLevel = biomeState.Level + 1
	local cost = biomeConfig.Upgrades[nextLevel].Cost

	if data.Gold >= cost then
		data.Gold -= cost
        
        -- Identify the pattern to look for in data (e.g., "Biome_Forest")
        local newModelName = string.format("%s_%02d", biomeId, nextLevel)
        
        -- Update the Level State
        biomeState.Level = nextLevel
        
        -- Update the Placements table: find the entry for this biome and update it
        if data.Placements then
            for i, placement in ipairs(data.Placements) do
                -- Check if this placement entry belongs to the biome being upgraded
                if placement.Name:match("^" .. biomeId) then
                    placement.Name = newModelName -- Update the name to the new level
                    break 
                end
            end
        end
        
        -- Refresh the world visual
        local EnclosureService = Knit.GetService("EnclosureService")
        EnclosureService:RefreshPlacedBiome(player, biomeId, nextLevel)
        
        DataService.Client.DataChanged:Fire(player, data)
        return true
	end

	return false
end

function BiomeService:InitBiomes()
	for biomeId, config in pairs(BiomesData) do
		-- We apply attributes to every level suffix (e.g., Biome_Forest_01, _02, _03)
		for level = 1, config.MaxLevel do
			local suffix = string.format("_%02d", level)
			local modelName = biomeId .. suffix

			-- Find models in both locations
			local model = BIOMES_ASSETS:FindFirstChild(modelName)
			if model and model:IsA("Model") then
					-- Set Procedural Attributes from Biomes.lua
					model:SetAttribute("BiomeId", config.Id)
					model:SetAttribute("Level", level)
					model:SetAttribute("MaxLevel", config.MaxLevel)

					-- Add Capacity and Upgrade Cost for the specific level
					local capacity = config.Capacities[level] or 0
					local upgradeCost = (config.Upgrades[level + 1] and config.Upgrades[level + 1].Cost) or 0

					model:SetAttribute("Capacity", capacity)
					model:SetAttribute("NextUpgradeCost", upgradeCost)

					print(`[BiomeService] Applied attributes to {modelName}`)
				else
					warn(`[BiomeService] Model {modelName} not found in Assets.`)
				end
		end
	end
end

--|| Client Functions ||--

function BiomeService.Client:PurchaseBiome(player: Player, biomeId: string)
	return self.Server:PurchaseBiome(player, biomeId)
end

function BiomeService.Client:UpgradeBiome(player: Player, biomeId: string)
	return self.Server:UpgradeBiome(player, biomeId)
end

--|| Knit Lifecycle ||--
function BiomeService:KnitStart()
	DataService = Knit.GetService("DataService")

	self.InitBiomes()
end

return BiomeService
