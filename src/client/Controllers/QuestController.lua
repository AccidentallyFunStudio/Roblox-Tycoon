-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService") -- Added TweenService

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local QuestActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.QuestActions)

-- Knit Services
local DataService
local QuestService

-- QuestController
local QuestController = Knit.CreateController({
	Name = "QuestController",
})

-- We wait for character inside the logic to avoid Nil errors
local player = Players.LocalPlayer
local arrowTemplate = Workspace.Assets.Props:WaitForChild("QuestArrow")
local TargetQuest = nil
local ArrowInstance = nil
local TutorialFinished = false

local TUTORIAL_TEXT = {
	[1] = "Visit the Shop",
	[2] = "Purchase your first Biome",
	[3] = "Go to your Zoo",
	[4] = "Place a Biome from your Inventory",
	[5] = "Hatch an Egg from your Inventory",
	[6] = "Place an Animal to Biome from your Inventory",
	[7] = "Go to the Yellow Spot in your Zoo to Collect Golds",
	[8] = "Visit the Shop again to upgrade your Biomes",
}

function QuestController:InitArrow()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	ArrowInstance = arrowTemplate:Clone()
	ArrowInstance.Parent = Workspace
	ArrowInstance.Anchored = true
	ArrowInstance.CanCollide = false
	ArrowInstance.CanTouch = false
	ArrowInstance.CanQuery = false
	ArrowInstance.Transparency = 1

	-- Create a "Pulse" effect by tweening the scale
	-- Note: If your arrow is a MeshPart, use 'Size'.
	local originalSize = ArrowInstance.Size
	local targetSize = originalSize * 1.3 -- Grow by 30%

	local tweenInfo = TweenInfo.new(
		0.8, -- Time for one pulse
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1, -- Repeat count (-1 is infinite)
		true -- Reverses (Goes back to original size)
	)

	local pulseTween = TweenService:Create(ArrowInstance, tweenInfo, { Size = targetSize })
	pulseTween:Play()

	-- || MOVEMENT LOGIC || --
	RunService.RenderStepped:Connect(function()
		if not ArrowInstance or typeof(TargetQuest) ~= "Instance" or not root.Parent then
			if ArrowInstance then
				ArrowInstance.Transparency = 1
			end
			return
		end

		-- Safe Position Check
		local success, targetPos = pcall(function()
			return TargetQuest:IsA("Model") and TargetQuest:GetPivot().Position or TargetQuest.Position
		end)

		if not success or not targetPos then
			ArrowInstance.Transparency = 1
			return
		end

		ArrowInstance.Transparency = 0
		local arrowPos = root.Position + Vector3.new(0, 4, 0)
		ArrowInstance.CFrame = CFrame.lookAt(arrowPos, targetPos) * CFrame.Angles(0, math.pi, 0)
	end)
end

function QuestController:UpdateQuestState(data)
	if not data or not data.Tutorial then return end

    local step = data.Tutorial.CurrentStep
    local completed = data.Tutorial.Completed

    self.CurrentStep = step

    if completed then
        self.Store:dispatch(QuestActions.SetQuestInfo("", false))
        TargetQuest = nil
        return
    end

    local text = TUTORIAL_TEXT[step]
	if text then
		self.Store:dispatch(QuestActions.SetQuestInfo(text, true))
	else
		self.Store:dispatch(QuestActions.SetQuestInfo("", false))
	end

	print(`[Quest Controller] Tutorial Step: {self.CurrentStep}`)

	-- Target Assignment
	if self.CurrentStep == 1 or self.CurrentStep == 2 then
		TargetQuest = Workspace.Gameplay.Props:FindFirstChild("Shop_Weapons")
	elseif self.CurrentStep >= 3 and self.CurrentStep <= 6 then
		Knit.GetService("EnclosureService"):GetPlayerEnclosure():andThen(function(enclosure)
			TargetQuest = enclosure
		end)
	else
		TargetQuest = nil
	end

	-- if not data or not data.Tutorial then return end

	-- local step = data.Tutorial.CurrentStep
	-- local EnclosureService = Knit.GetService("EnclosureService")

	-- local text = TUTORIAL_TEXT[step] or "Enjoy your Zoo!"
	-- local isVisible = not data.Tutorial.Completed and step > 0

	-- if self.Store then
	--     self.Store:dispatch(QuestActions.setQuestInfo(text, isVisible))
	-- end

	-- print(`[Quest Controller] Tutorial Step for Player {player} is {step}`)

	-- if step == 1 or step == 2 then
	--     TargetQuest = Workspace.Gameplay.Props:FindFirstChild("Shop_Weapons")
	-- elseif step == 3 or step == 4 or step == 5 or step == 6 then
	--     -- Enclosure might be a promise or a direct call depending on your Service setup
	--     TargetQuest = EnclosureService:GetPlayerEnclosure()
	-- else
	--     TargetQuest = nil
	-- end

	-- -- Toggle visibility based on target existence
	if ArrowInstance then
		ArrowInstance.Transparency = TargetQuest and 0 or 1
	end
end

function QuestController:CompleteVisitShop()
	QuestService:CompleteVisitShop()
end

function QuestController:CompletePurchaseBiome()
	QuestService:CompletePurchaseBiome()
end

function QuestController:CompleteGoToZoo()
	QuestService:CompleteGoToZoo()
end

function QuestController:CompletePlaceBiome()
	QuestService:CompletePlaceBiome()
end

function QuestController:CompleteHatchEgg()
	QuestService:CompleteHatchEgg()
end

function QuestController:CompletePlaceAnimal()
	QuestService:CompletePlaceAnimal()
end

function QuestController:CompleteCollectGold()
	QuestService:CompleteCollectGold()
end

function QuestController:CompleteUpgradeBiome()
	QuestService:CompleteUpgradeBiome()
end

function QuestController:CompleteTutorial()
	QuestService:CompleteTutorial()
end

function QuestController:KnitStart()
	self.Store = Store
	self.CurrentStep = 0

	DataService = Knit.GetService("DataService")
	QuestService = Knit.GetService("QuestService")

	self:InitArrow()

	-- Initial data load
	DataService:GetData():andThen(function(data)
		self:UpdateQuestState(data)
	end)

	-- Listen for data changes
	DataService.DataChanged:Connect(function(data)
		self:UpdateQuestState(data)
	end)

	RunService.Heartbeat:Connect(function()
		if not TargetQuest or not player.Character or not self.CurrentStep then
			return
		end

		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		-- Step 1 & 2: Proximity to Shop
		if self.CurrentStep == 1 or self.CurrentStep == 2 then
			local dist = (root.Position - TargetQuest:GetPivot().Position).Magnitude
			if dist < 30 then
				QuestService:CompleteVisitShop()
			end
		-- Step 3: Proximity to Zoo
		elseif self.CurrentStep == 3 then
			local dist = (root.Position - TargetQuest:GetPivot().Position).Magnitude
			if dist < 30 then
				QuestService:CompleteGoToZoo()
			end
		end
	end)

	print("[Quest Controller] Controller initialized.")
end

return QuestController
