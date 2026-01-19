-- Services
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EnclosureService = Knit.CreateService {
    Name = "EnclosureService",
    Client = {},
}

-- Folder containing all Enclosure instances in the world.
local EnclosuresFolder = Workspace:WaitForChild("Gameplay"):WaitForChild("Scripts"):WaitForChild("Enclosures")

-- Reference to CoinService
local CoinService = nil

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
    print(`[Enclosure Service] Assigned Enclosure {enclosure.Name} to Player {player.Name}`)

    -- Initialize Biomes
    for _, biome in ipairs(enclosure:GetChildren()) do
        if biome.Name:match("^Biome_") then
            biome:SetAttribute("Unlocked", biome:GetAttribute("BiomeIndex") == 1)
            biome:SetAttribute("StoredCoins", 0)
        end
    end
end

-- Releases a player's enclosure when they leave the server.
-- This makes the enclosure available for future players.
function EnclosureService:ReleaseEnclosure(player)
    for _, enclosure in ipairs(Enclosures) do
        if enclosure:GetAttribute("OwnerUserId") == player.UserId then
            enclosure:SetAttribute("OwnerUserId", 0)
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

							print(
								string.format(
									"[Enclosure Service] %s | %s +%d (Total: %d)",
									enclosure.Name,
									biome.Name,
									cps,
									newTotal
								)
							)
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

-- || Knit Lifecycle || --

function EnclosureService:KnitStart()
    -- Resolve dependent services
    CoinService = Knit.GetService("CoinService")

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