-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EnclosureService = Knit.CreateService({
	Name = "EnclosureService",
	Client = {
		GoldCollected = Knit.CreateSignal()
	},
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

			local modelTemplate = Workspace.Assets.Biomes:FindFirstChild(placement.Name)
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

							local targetPosition = spot.Position
							local originalRotation = animalTemplate:GetPivot().Rotation
							local finalCFrame = CFrame.new(targetPosition) * originalRotation
							aClone:PivotTo(finalCFrame)
							aClone.Parent = animalsFolder

							local currentCount = clone:GetAttribute("AnimalCount") or 0
							clone:SetAttribute("AnimalCount", currentCount + 1)
						end
					end
					clone:SetAttribute("AnimalCount", #placement.Animals)
				end
			end
		end

		local plate = enclosure:FindFirstChild("Collection Plate")
		if plate then
			plate.Touched:Connect(function(hit)
				local char = hit.Parent
				local player = Players:GetPlayerFromCharacter(char)

				-- Check if the player touching the plate is the actual owner
				if player and enclosure:GetAttribute("OwnerUserId") == player.UserId then
					Knit.GetService("GoldService"):CollectGold(player)
				end
			end)
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

function EnclosureService:RefreshPlacedBiome(player: Player, biomeId: string)
    local data = DataService:GetData(player)
    local enclosure = self:GetPlayerEnclosure(player)
    if not data or not enclosure then return end

    local placement = nil
    for _, p in ipairs(data.Placements) do
        -- Matches "Biome_Forest" against "Biome_Forest_01/02/03"
        if p.Name:match("^" .. biomeId) then
            placement = p
            break
        end
    end

    if placement then
        -- 1. IDENTIFY AND RESCUE LIVE ANIMALS
        local oldBiomeModel = nil
        local rescuedAnimals = {}

        for _, child in ipairs(enclosure:GetChildren()) do
            if child:IsA("Model") and child:GetAttribute("BiomeId") == biomeId then            
                local animalsFolder = child:FindFirstChild("Animals")
                if animalsFolder then
                    -- Parent animals to the enclosure temporarily so they aren't destroyed
                    for _, animal in ipairs(animalsFolder:GetChildren()) do
                        animal.Parent = enclosure
                        table.insert(rescuedAnimals, animal)
                    end
                end
                child:Destroy() -- Safe to destroy the old biome now
                break
            end
        end

        -- 2. SPAWN NEW BIOME TIER
        -- Assets must be in ReplicatedStorage for best results
        local newTemplate = Workspace.Assets.Biomes:FindFirstChild(placement.Name)
        if newTemplate then
            local newClone = newTemplate:Clone()
            newClone:PivotTo(CFrame.new(unpack(placement.Transform)))
            newClone.Parent = enclosure
            
			newClone:SetAttribute("BiomeId", biomeId)
            newClone:SetAttribute("OwnerUserId", player.UserId)
			newClone:SetAttribute("BiomeLocked", true)
            newClone.Parent = enclosure
			
            local animalsFolder = newClone:FindFirstChild("Animals")
            if not animalsFolder then
                animalsFolder = Instance.new("Folder")
                animalsFolder.Name = "Animals"
                animalsFolder.Parent = newClone
            end
            
            local positionsFolder = newClone:FindFirstChild("Positions")

			-- 3. RESTORE ANIMALS TO NEW POSITIONS
			for i, animalModel in ipairs(rescuedAnimals) do
				animalModel.Parent = animalsFolder

				-- Snap to new position if it exists
				local spawnPart = positionsFolder and positionsFolder:FindFirstChild(tostring(i))
				if spawnPart then
					-- Extract original rotation from the animal
					local originalRotation = animalModel:GetPivot().Rotation

					-- Combine new position with old rotation
					local targetCFrame = CFrame.new(spawnPart.Position) * originalRotation

					animalModel:PivotTo(targetCFrame)
				end
			end
            
            newClone:SetAttribute("AnimalCount", #rescuedAnimals)
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
