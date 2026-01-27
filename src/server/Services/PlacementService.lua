-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Configuration
local MAX_SERVER_DIST = 1100 -- Slightly higher than client (100) to account for latency
local BiomesConfig = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

local PlacementService = Knit.CreateService({
	Name = "PlacementService",
	Client = {},
})

-- || Functions || --

function PlacementService:PlaceItem(
	player: Player,
	itemName: string,
	targetCFrame: CFrame,
	targetFloor: Instance
): boolean
	-- Is it actually a floor?
	if not targetFloor:IsA("BasePart") or not targetFloor:HasTag("PlacableFloor") then
		warn(player.Name .. " attempted to place on a non-floor object.")
		return false
	end

	-- Validate the Enclosure
	local enclosure = targetFloor:FindFirstAncestorOfClass("Model")
	if not enclosure then
		warn("Floor part is not inside an Enclosure model")
		return false
	end

	-- Ownership Validation
	local ownerId = enclosure:GetAttribute("OwnerUserId")
	if ownerId ~= player.UserId then
		warn(player.Name .. " tried to place in an enclosure they do not own!")
		return false
	end

	-- Character & Distance Validation
	local character = player.Character
	if not character then
		return false
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not rootPart then
		return false
	end

	-- Check if the placement point is within the allowed distance from the player
	local distance = (rootPart.Position - targetCFrame.Position).Magnitude
	if distance > MAX_SERVER_DIST then
		warn(player.Name .. " attempted to place too far away: " .. math.round(distance) .. " studs")
		return false
	end

	-- Asset Retrieval
	local itemTemplate = game.ServerStorage.Assets.Biomes:FindFirstChild(itemName)
	if not itemTemplate then
		warn("Item " .. itemName .. " does not exist in ServerStorage.Items")
		return false
	end

	-- Placement
	local newItem = itemTemplate:Clone()

	if newItem:IsA("Model") or newItem:IsA("BasePart") then
		newItem:PivotTo(targetCFrame)
	end

	local baseId = itemName:match("(.+)_%d+$") or itemName
	local BiomeData = BiomesConfig[baseId]

	if BiomeData then
		-- Retrieve level from the name suffix to get correct capacity
		local level = tonumber(itemName:match("_(%d+)$")) or 1

		newItem:SetAttribute("Level", level)
		newItem:SetAttribute("MaxCapacity", BiomeData.Capacities[level] or BiomeData.Capacities[1])
		newItem:SetAttribute("AnimalCount", 0)
		print(`[Server] Initialized {itemName} at Level {level}`)
	else
		warn(`[Server] No config found for BaseId: {baseId}`)
	end

	newItem.Parent = enclosure

	local DataService = Knit.GetService("DataService")
    local data = DataService:GetData(player) --
    if data then
        if not data.Placements then data.Placements = {} end --
        
        table.insert(data.Placements, {
            Name = itemName,
            Transform = {targetCFrame:GetComponents()} -- This is safe for DataStores
        })
    end

	return true
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
				local animalTemplate = game.ServerStorage.Items:FindFirstChild(animalId)

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

-- || Client Functions || --

function PlacementService.Client:PlaceItem(
	player: Player,
	itemName: string,
	targetCFrame: CFrame,
	targetFloor: Instance
)
	return self.Server:PlaceItem(player, itemName, targetCFrame, targetFloor)
end

return PlacementService
