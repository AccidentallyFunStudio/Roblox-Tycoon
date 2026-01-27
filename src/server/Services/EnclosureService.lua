-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EnclosureService = Knit.CreateService {
    Name = "EnclosureService",
    Client = {},
}

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
        if (enclosure:GetAttribute("OwnerUserId") == 0) then
            return enclosure
        end
    end
end

-- || Server Functions || --

-- Assigns an available Enclosure to a player when they join.
-- Initializes biome state inside the enclosure.
function EnclosureService:AssignEnclosure(player : Player)
    local enclosure = GetFreeEnclosure()
    if not enclosure then return end

    enclosure:SetAttribute("OwnerUserId", player.UserId)
    
    -- Load Placed Biomes from DataService
    local playerData = DataService:GetData(player)
    if playerData and playerData.Placements then
        for _, placement in ipairs(playerData.Placements) do
            local modelTemplate = ReplicatedStorage.Assets.Biomes:FindFirstChild(placement.Name)
            if modelTemplate then
                local clone = modelTemplate:Clone()
                -- Decode the saved CFrame table back into a CFrame object
                clone:PivotTo(CFrame.new(unpack(placement.Transform)))
                clone.Parent = enclosure
                
                -- Initialize production attributes (if applicable)
                clone:SetAttribute("Unlocked", true)
                clone:SetAttribute("StoredCoins", 0)
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
function EnclosureService:Collect(player : Player, enclosure)
    -- Ownership validation to prevent stealing
    if enclosure:GetAttribute("OwnerUserId") ~= player.UserId then return end

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
    if not enclosure then return end

    local oldCFrame = nil
    
    -- 1. Find and Destroy ALL existing versions of this specific biome type
    for _, child in ipairs(enclosure:GetChildren()) do
        -- Use the Attribute "BiomeId" instead of the Name to avoid suffix confusion
        if child:IsA("Model") and child:GetAttribute("BiomeId") == biomeId then
            if not oldCFrame then
                oldCFrame = child:GetPivot() -- Capture the position of the first one we find
            end
            child:Destroy() -- Destroy it
        end
    end

    -- 2. Spawn the new upgraded level at the captured position
    if oldCFrame then
        local newModelName = string.format("%s_%02d", biomeId, newLevel)
        local newTemplate = ReplicatedStorage.Assets.Biomes:FindFirstChild(newModelName)
        
        if newTemplate then
            local newClone = newTemplate:Clone()
            newClone:PivotTo(oldCFrame)
            newClone.Parent = enclosure
            
            -- Ensure attributes are correctly set for the new level
            newClone:SetAttribute("Unlocked", true)
            newClone:SetAttribute("StoredCoins", 0)
            -- Re-apply BiomeId so the NEXT upgrade can find this model
            newClone:SetAttribute("BiomeId", biomeId) 
            
            print(`[Enclosure Service] Replaced {biomeId} with Level {newLevel}`)
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