-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local ButtonPromptActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.ButtonPromptActions)

-- Knit Services
local PlacementService

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

	local itemAsset = Workspace.Assets.Biomes:FindFirstChild(itemName)
	if not itemAsset then
		warn(`[Placement Controller] Item named {itemName} not found in Workspace/Assets/Biomes/`)
		return
	end

	self.CurrentGhost = self:CreateGhost(itemAsset)
	self.CurrentGhost.Name = itemName
	self.CurrentGhost.Parent = workspace
	self.IsPlacing = true

	Store:dispatch(ButtonPromptActions.SetVisibility(true))
end

function PlacementController:StopPlacement()
	self.IsPlacing = false
	if self.CurrentGhost then
		self.CurrentGhost:Destroy()
		self.CurrentGhost = nil
	end

	Store:dispatch(ButtonPromptActions.SetVisibility(false))
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

function PlacementController:GetMouseWorldPosition(): RaycastResult?
	local mousePos = UserInputService:GetMouseLocation()
	local unitRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include -- ONLY hit these items

	-- Get everything tagged as a floor
	local CollectionService = game:GetService("CollectionService")
	params.FilterDescendantsInstances = CollectionService:GetTagged("PlacableFloor")

	return workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_PLACEMENT_DISTANCE, params)
end

function PlacementController:CheckForOverlap(ghost: Instance): boolean
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	-- Ignore the ghost itself and the player
	overlapParams.FilterDescendantsInstances = { ghost, game.Players.LocalPlayer.Character }

	local cframe, size
	if ghost:IsA("Model") then
		cframe, size = ghost:GetBoundingBox()
	else
		cframe, size = ghost.CFrame, ghost.Size
	end

	-- Query the world for any parts inside the ghost's box
	-- We subtract a tiny bit from the size (0.1) to prevent the floor from triggering an overlap
	local partsInBox = workspace:GetPartBoundsInBox(cframe, size - Vector3.new(0.1, 0.1, 0.1), overlapParams)

	-- Filter results: we only care if it hits something that ISN'T a "PlacableFloor"
	for _, part in ipairs(partsInBox) do
		if not part:HasTag("PlacableFloor") then
			return true -- Overlap detected
		end
	end

	return false
end

function PlacementController:TestAnimalPlacement(animalId)
	local player = game.Players.LocalPlayer
	local AnimalsData = require(ReplicatedStorage.Shared.Data.Shop.Animals)
	local animalInfo = AnimalsData[animalId]

	if not animalInfo then
		return
	end

	-- 1. Find the player's enclosure in the workspace
	local enclosuresFolder = workspace.Gameplay.Scripts:FindFirstChild("Enclosures")
	if not enclosuresFolder then
		warn("[Placement Controller] Enclosures folder path not found!")
		return
	end

	local enclosure = nil
	for _, folder in ipairs(enclosuresFolder:GetChildren()) do
		if folder:IsA("Model") and folder:GetAttribute("OwnerUserId") == player.UserId then
			enclosure = folder
			break
		end
	end

	if not enclosure then
		warn("[Placement Controller] Could not find your enclosure!")
		return
	end

	-- 2. Find the specific Biome model that matches the animal's requirement
	local targetBiome = nil
	for _, child in ipairs(enclosure:GetChildren()) do
		-- check attribute OR check if the name contains the requirement (e.g., "Biome_Forest")
		local attrId = child:GetAttribute("BiomeId")
		if child:IsA("Model") and (attrId == animalInfo.Biome or child.Name:match("^Biome_" .. animalInfo.Biome)) then
			targetBiome = child
			break
		end
	end

	if not targetBiome then
		warn("[Placement Controller] You don't have a " .. animalInfo.Biome .. " biome placed yet!")
		return
	end

	-- 3. Call the server service to perform the placement
	local success = PlacementService:PlaceAnimalManual(targetBiome, animalId):await()

	if success then
		print("[Placement Controller] Successfully placed " .. animalInfo.Name)
	else
		warn("[Placement Controller] Failed to place animal. Check capacity!")
	end
end

function PlacementController:KnitStart()
	PlacementService = Knit.GetService("PlacementService")
	local debounce = false

	-- Input Listener for Rotation and Cancellation
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		-- Rotation
		if input.KeyCode == Enum.KeyCode.R and self.IsPlacing then
			self.CurrentRotation = (self.CurrentRotation + 90) % 360
			print("[Placement Controller] Rotation updated: " .. self.CurrentRotation)
		end

		-- Cancellation
		if input.KeyCode == Enum.KeyCode.E and self.IsPlacing then
			self:StopPlacement()
			print("[Placement Controller] Placement Cancelled")
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not self.IsPlacing or not self.CurrentGhost then
			return
		end

		local result = self:GetMouseWorldPosition()
		if result then
			local hitInstance = result.Instance
			local enclosure = hitInstance:FindFirstAncestorOfClass("Model")
			local isOwner = enclosure and enclosure:GetAttribute("OwnerUserId") == game.Players.LocalPlayer.UserId

			if hitInstance:HasTag("PlacableFloor") and isOwner then
				self.CurrentGhost.Parent = workspace
				self:UpdateGhost(self.CurrentGhost, result.Position, result.Normal)

				-- CHECK OVERLAP
				local isOverlapping = self:CheckForOverlap(self.CurrentGhost)

				-- Visual feedback
				local color = if isOverlapping then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(0, 255, 0)
				for _, p in ipairs(self.CurrentGhost:GetDescendants()) do
					if p:IsA("BasePart") then
						p.Color = color
					end
				end

				-- Only allow click if NOT overlapping
				if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					debounce = true

					print(`[Placement Controller] Sending to Server: Name={self.CurrentGhost.Name}, Floor={result.Instance.Name}`)

					PlacementService:PlaceItem(self.CurrentGhost.Name, self.CurrentGhost:GetPivot(), result.Instance)
						:andThen(function(success)
							print(`[Placement Controller] Placement success: {success}`)
							if success then
								self:StopPlacement()
							end
						end)
						:catch(function(err)
							warn(`[Placement Controller] Service Error: {err}`)
						end)
					
					local success, data = Knit.GetService("DataService"):GetData():await()
					if data and data.Tutorial and data.Tutorial.CurrentStep == 4 then
						Knit.GetController("QuestController"):CompletePlaceBiome()
					end

					Store:dispatch(ButtonPromptActions.SetVisibility(false))

					task.wait(0.3)
					debounce = false
				end
				return
			end
		end
		self.CurrentGhost.Parent = nil
	end)
end

return PlacementController
