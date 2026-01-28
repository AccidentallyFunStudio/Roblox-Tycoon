-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService

-- Configuration
local MAX_SERVER_DIST = 1100 -- Slightly higher than client (100) to account for latency

-- Data
local AnimalsData = require(ReplicatedStorage.Shared.Data.Shop.Animals)
local BiomesData = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

local PlacementService = Knit.CreateService({
	Name = "PlacementService",
	Client = {},
})

-- || Functions || --

-- PlacementService.lua

function PlacementService:PlaceItem(
	player: Player,
	itemName: string,
	targetCFrame: CFrame,
	targetFloor: Instance
): boolean
	if not targetFloor:IsA("BasePart") or not targetFloor:HasTag("PlacableFloor") then
		return false
	end

	local enclosure = targetFloor:FindFirstAncestorOfClass("Model")
	if not enclosure or enclosure:GetAttribute("OwnerUserId") ~= player.UserId then
		return false
	end

	-- Ownership Check
	local data = DataService:GetData(player)
	local baseId = itemName:match("(.+)_%d+$") or itemName

	if data then
		if not data.Placements then
			data.Placements = {}
		end

		-- Check if this biome type is ALREADY placed
		for _, p in ipairs(data.Placements) do
			local pBaseId = p.Name:match("(.+)_%d+$") or p.Name
			if pBaseId == baseId then
				warn(`[PlacementService] {player.Name} already has a {baseId} placed. Moving is disabled.`)
				return false -- BLOCK the placement
			end
		end

		local itemTemplate = Workspace.Assets.Biomes:FindFirstChild(itemName) 
		if not itemTemplate then 
            warn(`[PlacementService] Asset {itemName} not found in ReplicatedStorage!`)
            return false 
        end

		local newItem = itemTemplate:Clone()
		newItem:PivotTo(targetCFrame)
		newItem:SetAttribute("BiomeId", baseId)
		newItem:SetAttribute("OwnerUserId", player.UserId)
		newItem.Parent = enclosure

        -- -- Ensure physics and visibility replicate immediately
        -- for _, part in ipairs(newItem:GetDescendants()) do
        --     if part:IsA("BasePart") then
        --         part:SetNetworkOwner(player)
        --     end
        -- end

		-- If we reached here, no existing biome was found, so we can place a new one
		local placementEntry = {
			Name = itemName,
			Transform = { targetCFrame:GetComponents() },
			Animals = {},
		}

		table.insert(data.Placements, placementEntry)
		DataService.Client.DataChanged:Fire(player, data) -- Notify client of update
	end

	return true
end

function PlacementService:PlaceAnimalManual(player: Player, biomeModel: Model, animalId: string): boolean
	local animalData = AnimalsData[animalId]
	if not animalData then
		return false
	end

	-- 1. Setup Folders
	local animalsFolder = biomeModel:FindFirstChild("Animals") or Instance.new("Folder", biomeModel)
	animalsFolder.Name = "Animals"

	local positionsFolder = biomeModel:FindFirstChild("Positions")
	if not positionsFolder then
		warn("No Positions folder found in " .. biomeModel.Name)
		return false
	end

	-- 2. Determine Position based on current count
	local currentCount = #animalsFolder:GetChildren()
	local maxCapacity = biomeModel:GetAttribute("Capacity") or 5

	if currentCount >= maxCapacity then
		warn("Biome is full!")
		return false
	end

	-- Find the part named after the next index (e.g., "1", "2")
	local spawnPart = positionsFolder:FindFirstChild(tostring(currentCount + 1))
	if not spawnPart then
		-- Fallback: just pick any child if naming is off
		spawnPart = positionsFolder:GetChildren()[currentCount + 1]
	end

	-- 3. Clone and Parent
	local asset = workspace.Assets.Animals:FindFirstChild(animalId)
	if asset and spawnPart then
		local clone = asset:Clone()

		-- 1. Extract components safely
		local targetPosition = spawnPart.Position -- Get world position from part
		local originalRotation = asset:GetPivot().Rotation -- Get rotation-only CFrame from asset

		-- 2. Combine them: Translation * Rotation
		local finalCFrame = CFrame.new(targetPosition) * originalRotation

		clone:PivotTo(finalCFrame)
		clone.Parent = animalsFolder

		-- Update attribute for the UI/Service to read later
		biomeModel:SetAttribute("AnimalCount", #animalsFolder:GetChildren())

		local data = DataService:GetData(player)
		if data and data.Placements and data.Animals then
			-- We need to find the specific biome entry in the data table
			-- Ensure BiomeId attribute was set on the model during placement or init
			local targetBiomeId = biomeModel:GetAttribute("BiomeId")
			local ownedCount = data.Animals[animalId] or 0
			if ownedCount <= 0 then
				warn(`[Placement Service] {player.Name} tried to place {animalId} but owns 0.`)
				return false
			end

			data.Animals[animalId] = ownedCount - 1
			print(`[Placement Service] {player.Name} inventory for {animalId} decreased to {data.Animals[animalId]}`)

			for _, placement in ipairs(data.Placements) do
				-- We match based on the BiomeId or Name
				if placement.Name == biomeModel.Name or placement.BiomeId == targetBiomeId then
					placement.Animals = placement.Animals or {}
					table.insert(placement.Animals, animalId)

					DataService.Client.DataChanged:Fire(player, data)

					print(`[Placement Service] Saved {animalId} to Data for {player.Name}`)
					break
				end
			end
		end

		print(`[Placement Service] {animalId} placed at position {currentCount + 1}`)
		return true
	end

	return false
end

function PlacementService:AutoPlaceAnimal(player: Player, animalId: string): boolean
	local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals) --
	local BiomesConfig = require(ReplicatedStorage.Shared.Data.Shop.Biomes) --

	-- Find the Animal Data
	local animalData = nil
	for _, animal in ipairs(Animals) do
		if animal.Id == animalId then
			animalData = animal
			break
		end
	end
	if not animalData then
		return false
	end

	-- Find the Player's Enclosure
	local enclosure = nil
	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("OwnerUserId") == player.UserId then
			enclosure = model
			break
		end
	end
	if not enclosure then
		return false
	end

	-- Search for a valid Biome with capacity
	for _, item in ipairs(enclosure:GetChildren()) do
		-- Check if this child is a Biome that matches the animal's required Biome type
		if item:IsA("Model") and item.Name == "Biome_" .. animalData.Biome then
			local positions = item:FindFirstChild("Positions")
			local animalsFolder = item:FindFirstChild("Animals") or Instance.new("Folder", item)
			animalsFolder.Name = "Animals"

			-- Check capacity (Assuming Level 1 for now, or you can read an attribute)
			local maxCapacity = BiomesConfig[item.Name].Capacities[1]
			local currentCount = #animalsFolder:GetChildren()

			if currentCount < maxCapacity then
				-- 4. Place Animal at the next available position
				local spawnPart = positions:GetChildren()[currentCount + 1]
				local animalTemplate = game.Workspace.Assets.Animals:FindFirstChild(animalId)

				if spawnPart and animalTemplate then
					local newAnimal = animalTemplate:Clone()
					newAnimal:PivotTo(spawnPart.CFrame)
					newAnimal.Parent = animalsFolder
					return true
				end
			end
		end
	end

	warn("No available biome space for " .. animalData.Name)
	return false
end

function PlacementService:TestAnimalPlacement(player: Player, animalId: string, targetBiomeModel: Model)
	-- 1. Retrieve Animal Data by Id (using our new dictionary structure)
	local animalData = AnimalsData[animalId]
	if not animalData then
		warn(`[Test] Animal ID {animalId} not found.`)
		return false
	end

	-- 2. Verify Biome Type Match
	-- Assuming the Biome model has the "BiomeId" attribute set by BiomeService:InitBiomes
	local targetBiomeId = targetBiomeModel:GetAttribute("BiomeId")
	if targetBiomeId ~= animalData.Biome then
		warn(`[Test] {animalData.Name} requires {animalData.Biome} biome, but target is {targetBiomeId}.`)
		return false
	end

	-- 3. Check Capacity
	-- Capacity is applied as an attribute during BiomeService:InitBiomes
	local currentCount = #(targetBiomeModel:FindFirstChild("Animals"):GetChildren())
	local maxCapacity = targetBiomeModel:GetAttribute("Capacity") or 0

	if currentCount >= maxCapacity then
		warn("[Test] Biome is at maximum capacity.")
		return false
	end

	print(`[Test] Success! {animalData.Name} can be placed in {targetBiomeId}.`)
	return true
end

-- || Client Functions || --

function PlacementService.Client:PlaceItem(
	player: Player,
	itemName: string,
	targetCFrame: CFrame,
	targetFloor: Instance
)
	return self.Server:PlaceItem(player, itemName, targetCFrame, targetFloor)
end

function PlacementService.Client:TestAnimalPlacement(player: Player, animalId: string, targetBiomeModel: Model)
	return self.Server:TestAnimalPlacement(player, animalId, targetBiomeModel)
end

function PlacementService.Client:PlaceAnimalManual(player: Player, biomeModel: Model, animalId: string)
	return self.Server:PlaceAnimalManual(player, biomeModel, animalId)
end

-- || Knit Lifecycle || --

function PlacementService:KnitStart()
	DataService = Knit.GetService("DataService")

	print("[Placement Service] Service started.")
end

return PlacementService
