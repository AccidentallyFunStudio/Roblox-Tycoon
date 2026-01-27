-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Constants
local MAX_PLACEMENT_DISTANCE = 1000

local PlacementController = Knit.CreateController({
	Name = "PlacementController",
	IsPlacing = false,
	CurrentGhost = nil :: Model?, -- Use optional type
	CurrentRotation = 0,
})

function PlacementController:StartPlacement(itemName: string)
	self:StopPlacement()

	local itemAsset = ReplicatedStorage.Assets:FindFirstChild(itemName)
	if not itemAsset then
		return
	end

	self.CurrentGhost = self:CreateGhost(itemAsset)
	self.CurrentGhost.Name = itemName
	self.CurrentGhost.Parent = workspace
	self.IsPlacing = true
end

function PlacementController:StopPlacement()
	self.IsPlacing = false
	if self.CurrentGhost then
		self.CurrentGhost:Destroy()
		self.CurrentGhost = nil
	end
end

function PlacementController:TogglePlacement(itemName: string)
	if self.IsPlacing then
		self:StopPlacement()
	else
		self:StartPlacement(itemName)
	end
end

function PlacementController:CreateGhost(originalAsset: Instance): Instance
	local ghost = originalAsset:Clone()

	-- Recursive function to strip logic and fix collisions
	local function clean(obj)
		if obj:IsA("BasePart") then
			obj.Transparency = 0.5
			obj.Color = Color3.fromRGB(0, 255, 0)
			obj.CanCollide = false
			obj.CanQuery = false -- Essential for raycasting past the ghost
			obj.CastShadow = false
		elseif obj:IsA("LuaSourceContainer") then
			obj:Destroy()
		end
		for _, child in ipairs(obj:GetChildren()) do
			clean(child)
		end
	end

	clean(ghost)
	return ghost
end

function PlacementController:UpdateGhost(ghost: Instance, hitPosition: Vector3, hitNormal: Vector3)
	-- PivotTo works on both Models and BaseParts
	local upVector = hitNormal
	local forwardVector = Vector3.new(1, 0, 0)
	local rightVector = upVector:Cross(forwardVector).Unit
	local correctedForward = rightVector:Cross(upVector).Unit

	local rotationCFrame = CFrame.fromMatrix(hitPosition, rightVector, upVector, correctedForward)
	local finalCFrame = rotationCFrame * CFrame.Angles(0, math.rad(self.CurrentRotation), 0)

	if ghost:IsA("Model") then
		ghost:PivotTo(finalCFrame)
	elseif ghost:IsA("BasePart") then
		ghost.CFrame = finalCFrame
	end
end

function PlacementController:GetMouseWorldPosition() : RaycastResult?
	local mousePos = UserInputService:GetMouseLocation()
    local unitRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include -- ONLY hit these items
    
    -- Get everything tagged as a floor
    local CollectionService = game:GetService("CollectionService")
    params.FilterDescendantsInstances = CollectionService:GetTagged("PlacableFloor")

    return workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_PLACEMENT_DISTANCE, params)
end

function PlacementController:KnitStart()
	local PlacementService = Knit.GetService("PlacementService")
    local debounce = false

    -- Input Listener for Rotation ('R') and Cancellation (RMB)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Rotation Logic
        if input.KeyCode == Enum.KeyCode.R and self.IsPlacing then
            self.CurrentRotation = (self.CurrentRotation + 90) % 360
            print("Rotation updated: " .. self.CurrentRotation)
        end

        -- Cancellation (RMB)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and self.IsPlacing then
            self:StopPlacement()
            print("Placement Cancelled")
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not self.IsPlacing or not self.CurrentGhost then return end

        local result = self:GetMouseWorldPosition()

        -- FIX: Check if result exists BEFORE indexing .Instance
        if result then
            local hitInstance = result.Instance
            local isFloor = hitInstance:HasTag("PlacableFloor") or (hitInstance.Parent and hitInstance.Parent:HasTag("PlacableFloor"))

            if isFloor then
                self.CurrentGhost.Parent = workspace
                self:UpdateGhost(self.CurrentGhost, result.Position, result.Normal)

                -- Place Item (LMB)
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not debounce then
                    debounce = true
                    -- Note: No 'player' arg passed here; Knit handles it on server
                    PlacementService:PlaceItem(self.CurrentGhost.Name, self.CurrentGhost:GetPivot(), result.Instance)
                    task.wait(0.3)
                    debounce = false
                end
                return -- Exit successfully
            end
        end

        -- Hide ghost if no result or not hitting a floor
        self.CurrentGhost.Parent = nil
    end)
end

return PlacementController
