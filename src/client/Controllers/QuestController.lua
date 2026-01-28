-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService") -- Added TweenService

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- QuestController
local QuestController = Knit.CreateController({
	Name = "QuestController",
})

-- We wait for character inside the logic to avoid Nil errors
local player = Players.LocalPlayer
local arrowTemplate = Workspace.Assets.Props:WaitForChild("QuestArrow")

function QuestController:InitArrow()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	local QuestArrow = arrowTemplate:Clone()
	QuestArrow.Parent = Workspace
	QuestArrow.Anchored = true
	QuestArrow.CanCollide = false

	-- || JUICY TWEEN LOGIC || --
	-- Create a "Pulse" effect by tweening the scale
	-- Note: If your arrow is a MeshPart, use 'Size'.
	local originalSize = QuestArrow.Size
	local targetSize = originalSize * 1.3 -- Grow by 30%

	local tweenInfo = TweenInfo.new(
		0.8, -- Time for one pulse
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1, -- Repeat count (-1 is infinite)
		true -- Reverses (Goes back to original size)
	)

	local pulseTween = TweenService:Create(QuestArrow, tweenInfo, { Size = targetSize })
	pulseTween:Play()

	-- || MOVEMENT LOGIC || --
	RunService.RenderStepped:Connect(function()
		local shop = Workspace.Gameplay.Props:FindFirstChild("Shop_Weapons")
		if not root or not root.Parent or not shop then
			return
		end

		local shopPos = shop.PrimaryPart and shop.PrimaryPart.Position or shop:GetPivot().Position

		-- Position 4 studs above head to clear the hat/hair
		local arrowPos = root.Position + Vector3.new(0, 4, 0)

		-- Create the LookAt CFrame and flip it 180 (math.pi) so the tip points forward
		local baseCFrame = CFrame.lookAt(arrowPos, shopPos)
		QuestArrow.CFrame = baseCFrame * CFrame.Angles(0, math.pi, 0)
	end)
end

function QuestController:KnitStart()
	-- Ensure character is ready before starting
	task.spawn(function()
		self:InitArrow()
	end)

	print("[Quest Controller] Juicy Arrow initialized.")
end

return QuestController
