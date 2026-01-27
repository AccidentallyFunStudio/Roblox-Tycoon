-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Teleport Service
local TeleportService = Knit.CreateService {
    Name = "TeleportService",
    Client = {},
}

-- || Helper Functions || --

local function GetShopEntry()
    local entries = CollectionService:GetTagged("ShopEntry")
    if #entries == 0 then
        warn("No ShopEntry found in the game world.")
        return nil
    end
    return entries[1]
end

local function GetPlayerEnclosure(player: Player)
    for _, enclosure in pairs(CollectionService:GetTagged("Enclosure")) do
        if enclosure:GetAttribute("OwnerUserId") == player.UserId then
            return enclosure
        end
    end

    return nil
end

local function TeleportCharacter(player: Player, targetCFrame: CFrame)
    local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	character:PivotTo(targetCFrame)
end

-- || Server Functions|| --

function TeleportService:TeleportToShop(player: Player)
    local character = player.Character
    if not character then
        warn("Player character not found for teleportation.")
        return
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("HumanoidRootPart not found for player: " .. player.Name)
        return
    end

    local shopEntry = GetShopEntry()
    if not shopEntry or not shopEntry.PrimaryPart then
        return
    end

    local targetCFrame = shopEntry.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
	character:PivotTo(targetCFrame)
end

function TeleportService:TeleportToEnclosure(player: Player)
    local enclosure = GetPlayerEnclosure(player)
    local startLocation = enclosure:FindFirstChild("StartLocation")
	if not enclosure or not startLocation then
		warn("No enclosure found for", player.Name)
		return
	end

	local cf = startLocation.CFrame * CFrame.new(0, 3, 0)
	TeleportCharacter(player, cf)
end

-- || Client Functions || --

function TeleportService.Client:TeleportToShop(player: Player)
    self.Server:TeleportToShop(player)
end

function TeleportService.Client:TeleportToEnclosure(player: Player)
    self.Server:TeleportToEnclosure(player)
end

-- || Knit Lifecycle || --

function TeleportService:KnitStart()
    print("[Teleport Service] Service started.")
end

return TeleportService