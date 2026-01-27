-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EnclosureService = Knit.CreateService({
	Name = "EnclosureService",
	Client = {},
})

-- Folder containing all Enclosure instances in the world.
local EnclosuresFolder = Workspace:WaitForChild("Gameplay"):WaitForChild("Scripts"):WaitForChild("Enclosures")

-- Knit Services
local CoinService = nil
local DataService = nil

-- Cached list of Enclosures for faster iteration.
-- This avoids repeated calls to GetChildren during runtime loops.
local Enclosures = {} -- array of Enclosure instances

-- || Utility Functions || --

-- Returns the first Enclosure that is not currently owned by any player.
-- Ownership is determined via the OwnerUserId attribute.
local function GetFreeEnclosure()
	for _, enclosure in ipairs(Enclosures) do
		if enclosure:GetAttribute("OwnerUserId") == 0 then
			return enclosure
		end
	end
end

-- || Server Functions || --

-- Assigns an available Enclosure to a player when they join.
-- Initializes biome state inside the enclosure.
function EnclosureService:AssignEnclosure(player: Player)
	local enclosure = GetFreeEnclosure()
	if not enclosure then
		return
	end

	enclosure:SetAttribute("OwnerUserId", player.UserId)

	-- Load Placed Biomes from DataService
	local playerData = DataService:GetData(player)
	if playerData and playerData.Placements then
		local spawnedBaseIds = {} -- Safeguard against old duplicate data

		for _, placement in ipairs(playerData.Placements) do
			local baseId = placement.Name:match("(.+)_%d+$") or placement.Name
			if spawnedBaseIds[baseId] then
				continue
			end -- Skip if already spawned
			spawnedBaseIds[baseId] = true

			local modelTemplate = ReplicatedStorage.Assets.Biomes:FindFirstChild(placement.Name)
			if modelTemplate then
				local clone = modelTemplate:Clone()
				clone:PivotTo(CFrame.new(unpack(placement.Transform)))
				clone:SetAttribute("BiomeId", baseId)
				clone.Parent = enclosure

				-- Load Animals
				if placement.Animals then
					local animalsFolder = clone:FindFirstChild("Animals") or Instance.new("Folder", clone)
					animalsFolder.Name = "Animals"
					local positions = clone:FindFirstChild("Positions")

					for i, animalId in ipairs(placement.Animals) do
						local animalTemplate = workspace.Assets.Animals:FindFirstChild(animalId)
						local spot = positions and positions:FindFirstChild(tostring(i))
						if animalTemplate and spot then
							local aClone = animalTemplate:Clone()
							aClone:PivotTo(spot.CFrame)
							aClone.Parent = animalsFolder

							local currentCount = clone:GetAttribute("AnimalCount") or 0
							clone:SetAttribute("AnimalCount", currentCount + 1)
						end
					end
					clone:SetAttribute("AnimalCount", #placement.Animals)
				end
			end
		end
	end

	print(`[Enclosure Service] Assigned and Loaded {enclosure.Name} for {player.Name}`)
end

-- Releases a player's enclosure when they leave the server.
-- This makes the enclosure available for future players.
function EnclosureService:ReleaseEnclosure(player)
	for _, enclosure in ipairs(Enclosures) do
		if enclosure:GetAttribute("OwnerUserId") == player.UserId then
			-- Clean up all placed biomes
			for _, child in ipairs(enclosure:GetChildren()) do
				-- Ensure we don't destroy the floor or the enclosure itself
				if child:IsA("Model") and child.Name:match("^Biome_") then
					child:Destroy()
				end
			end

			enclosure:SetAttribute("OwnerUserId", 0)
			print(`[Enclosure Service] Cleared and Released {enclosure.Name}`)
		end
	end
end

-- Starts the coin production loop.
-- Runs once and ticks every second.
-- For each owned enclosure, all unlocked biomes produce coins.
function EnclosureService:StartProduction()
	task.spawn(function()
		while true do
			task.wait(1)

			for _, enclosure in ipairs(Enclosures) do
				-- Skip unowned enclosures
				if enclosure:GetAttribute("OwnerUserId") ~= 0 then
					for _, biome in ipairs(enclosure:GetChildren()) do
						if biome:GetAttribute("Unlocked") then
							local current = biome:GetAttribute("StoredCoins")
							local cps = biome:GetAttribute("CoinsPerSecond")
							local newTotal = current + cps

							biome:SetAttribute("StoredCoins", newTotal)

							-- print(
							-- 	string.format(
							-- 		"[Enclosure Service] %s | %s +%d (Total: %d)",
							-- 		enclosure.Name,
							-- 		biome.Name,
							-- 		cps,
							-- 		newTotal
							-- 	)
							-- )
						end
					end
				end
			end
		end
	end)
end

-- Collects all stored coins from every unlocked biome in the enclosure.
-- This function is intended to be called by the Collection Plate logic.
function EnclosureService:Collect(player: Player, enclosure)
	-- Ownership validation to prevent stealing
	if enclosure:GetAttribute("OwnerUserId") ~= player.UserId then
		return
	end

	local total = 0

	-- Aggregate coins from all unlocked biomes
	for _, biome in ipairs(enclosure:GetChildren()) do
		if biome:GetAttribute("Unlocked") then
			local stored = biome:GetAttribute("StoredCoins")
			total += stored
			biome:SetAttribute("StoredCoins", 0)
		end
	end

	-- Add coins to player currency if any were collected
	if total > 0 then
		CoinService:AddCoins(player, total)
		print(`[Enclosure Service] Collected {total} coins for Player {player.Name}`)
	end
end

function EnclosureService:GetPlayerEnclosure(player: Player)
	for _, enclosure in ipairs(Enclosures) do
		if enclosure:GetAttribute("OwnerUserId") == player.UserId then
			return enclosure
		end
	end
	return nil
end

function EnclosureService:RefreshPlacedBiome(player: Player, biomeId: string, newLevel: number)
	local enclosure = self:GetPlayerEnclosure(player)
	if not enclosure then
		return
	end

	local oldCFrame = nil
	local storedAnimals = {} -- Temporary list to hold animal IDs

	-- 1. Find the old biome and gather existing animals
	for _, child in ipairs(enclosure:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("BiomeId") == biomeId then
			oldCFrame = child:GetPivot()

			-- Grab IDs of animals currently in the biome
			local animalsFolder = child:FindFirstChild("Animals")
			if animalsFolder then
				for _, animal in ipairs(animalsFolder:GetChildren()) do
					-- Assuming animal model name matches its ID
					table.insert(storedAnimals, animal.Name)
				end
			end

			child:Destroy()
			break
		end
	end

	-- 2. Spawn the new upgraded level
	if oldCFrame then
		local newModelName = string.format("%s_%02d", biomeId, newLevel)
		local newTemplate = ReplicatedStorage.Assets.Biomes:FindFirstChild(newModelName)

		if newTemplate then
			local newClone = newTemplate:Clone()
			newClone:PivotTo(oldCFrame)
			newClone.Parent = enclosure

			-- Re-apply identifying attributes
			newClone:SetAttribute("BiomeId", biomeId)
			newClone:SetAttribute("Unlocked", true)

			-- 3. Restore the animals into the new model's positions
			if #storedAnimals > 0 then
				local animalsFolder = Instance.new("Folder", newClone)
				animalsFolder.Name = "Animals"
				local positionsFolder = newClone:FindFirstChild("Positions")

				for i, animalId in ipairs(storedAnimals) do
					local animalTemplate = game.Workspace.Assets.Animals:FindFirstChild(animalId)
					local spawnPart = positionsFolder and positionsFolder:FindFirstChild(tostring(i))

					if animalTemplate and spawnPart then
						local animalClone = animalTemplate:Clone()
						animalClone:PivotTo(spawnPart.CFrame)
						animalClone.Parent = animalsFolder
					end
				end
				newClone:SetAttribute("AnimalCount", #storedAnimals)
			end
		end
	end
end

-- || Knit Lifecycle || --

function EnclosureService:KnitStart()
	CoinService = Knit.GetService("CoinService")
	DataService = Knit.GetService("DataService")

	-- Cache all enclosures present in the world
	for _, enclosure in ipairs(EnclosuresFolder:GetChildren()) do
		table.insert(Enclosures, enclosure)
	end

	-- Assign enclosure on player join
	Players.PlayerAdded:Connect(function(player)
		self:AssignEnclosure(player)
	end)

	-- Release enclosure on player leave
	Players.PlayerRemoving:Connect(function(player)
		self:ReleaseEnclosure(player)
	end)

	-- Start biome production loop
	self:StartProduction()

	print(`[Enclosure Service] Service started.`)
end

return EnclosureService
