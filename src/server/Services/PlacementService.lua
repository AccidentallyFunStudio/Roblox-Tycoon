-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Configuration
local MAX_SERVER_DIST = 1100 -- Slightly higher than client (100) to account for latency

local PlacementService = Knit.CreateService {
    Name = "PlacementService",
    Client = {},
}

function PlacementService:PlaceItem(player: Player, itemName: string, targetCFrame: CFrame, targetFloor: Instance): boolean
    -- 1. Validation: Is it actually a floor?
    if not targetFloor:IsA("BasePart") or not targetFloor:HasTag("PlacableFloor") then 
        warn(player.Name .. " attempted to place on a non-floor object.")
        return false 
    end
    
    -- 2. Character & Distance Validation
    local character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
    if not rootPart then return false end
    
    -- Check if the placement point is within the allowed distance from the player
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    if distance > MAX_SERVER_DIST then
        warn(player.Name .. " attempted to place too far away: " .. math.round(distance) .. " studs")
        return false
    end

    -- 3. Asset Retrieval
    local itemTemplate = game.ServerStorage.Items:FindFirstChild(itemName)
    if not itemTemplate then 
        warn("Item " .. itemName .. " does not exist in ServerStorage.Items")
        return false 
    end

    -- 4. Placement Logic
    local newItem = itemTemplate:Clone()
    
    if newItem:IsA("Model") or newItem:IsA("BasePart") then
        newItem:PivotTo(targetCFrame)
    end
    
    -- Organize in Workspace
    local folder = workspace:FindFirstChild("PlacedObjects")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "PlacedObjects"
        folder.Parent = workspace
    end
    
    newItem.Parent = folder
    return true
end

function PlacementService.Client:PlaceItem(player: Player, itemName: string, targetCFrame: CFrame, targetFloor: Instance)
    return self.Server:PlaceItem(player, itemName, targetCFrame, targetFloor)
end

return PlacementService