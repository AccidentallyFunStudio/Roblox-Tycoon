-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

function PlacementService:PlaceItem(player: Player, itemName: string, targetCFrame: CFrame, targetFloor: Instance): boolean
	-- Validation
	if not targetFloor:IsA("BasePart") or not targetFloor:HasTag("PlacableFloor") then return false end
	local enclosure = targetFloor:FindFirstAncestorOfClass("Model")
	if not enclosure or enclosure:GetAttribute("OwnerUserId") ~= player.UserId then return false end

	-- Distance Check
	local char = player.Character
	if not char or (char:GetPivot().Position - targetCFrame.Position).Magnitude > 110 then return false end

	-- 1. Physical Placement
	local itemTemplate = ReplicatedStorage.Assets.Biomes:FindFirstChild(itemName)
	if not itemTemplate then return false end

	-- Cleanup existing physical biome of same type before placing new one
	local baseId = itemName:match("(.+)_%d+$") or itemName
	for _, child in ipairs(enclosure:GetChildren()) do
		if child:IsA("Model") and (child:GetAttribute("BiomeId") == baseId or child.Name:match("^"..baseId)) then
			child:Destroy()
		end
	end

	local newItem = itemTemplate:Clone()
	newItem:PivotTo(targetCFrame)
	newItem:SetAttribute("BiomeId", baseId) -- Critical for identification
	newItem:SetAttribute("OwnerUserId", player.UserId)
	newItem.Parent = enclosure

	-- 2. Data Persistence (The Fix for Duplication)
	local data = DataService:GetData(player)
	if data then
		if not data.Placements then data.Placements = {} end
		
		local existingIndex = nil
		for i, p in ipairs(data.Placements) do
			local pBaseId = p.Name:match("(.+)_%d+$") or p.Name
			if pBaseId == baseId then
				existingIndex = i
				break
			end
		end

		local placementEntry = {
			Name = itemName,
			Transform = {targetCFrame:GetComponents()},
			Animals = (existingIndex and data.Placements[existingIndex].Animals) or {}
		}

		if existingIndex then
			data.Placements[existingIndex] = placementEntry
		else
			table.insert(data.Placements, placementEntry)
		end
	end

	return true
end

function PlacementService:PlaceAnimalManual(player: Player, biomeModel: Model, animalId: string): boolean
    -- 1. Validate Biome Ownership
    local enclosure = biomeModel:FindFirstAncestorOfClass("Model")
    if not enclosure or enclosure:GetAttribute("OwnerUserId") ~= player.UserId then
        warn("[PlacementService] Player does not own this enclosure.")
        return false
    end

    -- 2. Capacity Check using Procedural Attributes
    local currentCount = biomeModel:GetAttribute("AnimalCount") or 0
    local maxCapacity = biomeModel:GetAttribute("Capacity") or 0 -- Set in BiomeService:InitBiomes

    if currentCount >= maxCapacity then
        warn("[PlacementService] Biome is at max capacity!")
        return false
    end

    -- 3. Locate Folders
    local positionsFolder = biomeModel:FindFirstChild("Positions")
    local animalsFolder = biomeModel:FindFirstChild("Animals") or Instance.new("Folder", biomeModel)
    animalsFolder.Name = "Animals"

    -- 4. Spawn Animal from Workspace/Assets/Animals/
    local animalTemplate = game.Workspace.Assets.Animals:FindFirstChild(animalId)
    local spawnPart = positionsFolder and positionsFolder:FindFirstChild(tostring(currentCount + 1))

    if animalTemplate and spawnPart then
        local newAnimal = animalTemplate:Clone()
        newAnimal:PivotTo(spawnPart.CFrame)
        newAnimal.Parent = animalsFolder
        
        -- Update Attribute for tracking
        biomeModel:SetAttribute("AnimalCount", currentCount + 1)
        
        -- 5. Save to Data for Persistence
        local DataService = Knit.GetService("DataService")
        local data = DataService:GetData(player)
        if data and data.Placements then
            for _, placement in ipairs(data.Placements) do
                -- Find the specific placement entry by matching the biome instance name
                if placement.InstanceName == biomeModel.Name then
                    placement.Animals = placement.Animals or {}
                    table.insert(placement.Animals, animalId)
                    break
                end
            end
        end
        
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

-- || Knit Lifecycle || --

function PlacementService:KnitStart()
	DataService = Knit.GetService("DataService")

	print("[Placement Service] Service started.")
end

return PlacementService