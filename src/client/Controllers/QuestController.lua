-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService") -- Added TweenService

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

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
            if ArrowInstance then ArrowInstance.Transparency = 1 end
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

        -- if not ArrowInstance or not TargetQuest or not root.Parent then
        --     warn(`[Quest Controller] Unable to set Arrow Quest for Player {player}.`)
        -- end

        -- local targetPosition = TargetQuest:IsA("Model") and TargetQuest:GetPivot().Position or TargetQuest.Position
		-- local arrowPosition = root.Position + Vector3.new(0, 4, 0)

        -- ArrowInstance.CFrame = CFrame.lookAt(arrowPosition, targetPosition) * CFrame.Angles(0, math.pi, 0)
		-- -- Create the LookAt CFrame and flip it 180 (math.pi) so the tip points forward
		-- local baseCFrame = CFrame.lookAt(arrowPos, target)
		-- QuestArrow.CFrame = baseCFrame * CFrame.Angles(0, math.pi, 0)
	end)
end

function QuestController:UpdateQuestState(data)
    if not data or not data.Tutorial then return end
    
    local step = data.Tutorial.CurrentStep
    local EnclosureService = Knit.GetService("EnclosureService")

    print(`[Quest Controller] Tutorial Step for Player {player} is {step}`)

    if step == 1 or step == 2 then
        TargetQuest = Workspace.Gameplay.Props:FindFirstChild("Shop_Weapons")
    elseif step == 3 or step == 4 or step == 5 or step == 6 then
        -- Enclosure might be a promise or a direct call depending on your Service setup
        EnclosureService:GetPlayerEnclosure():andThen(function(enclosure)
            TargetQuest = enclosure
        end)
    else
        TargetQuest = nil
    end

    -- Toggle visibility based on target existence
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

function QuestController:KnitStart()
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
        if not TargetQuest or not player.Character then return end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local success, data = DataService:GetData():await()
        if not success then return end
        if not data then return end

        if data.Tutorial.CurrentStep == 1 or data.Tutorial.CurrentStep == 2 then
            local dist = (root.Position - TargetQuest:GetPivot().Position).Magnitude
            if dist < 30 then
                QuestService:CompleteVisitShop()
            end
        elseif data.Tutorial.CurrentStep == 3 then
            local dist = (root.Position - TargetQuest:GetPivot().Position).Magnitude
            if (dist) < 30 then
                QuestService:CompleteGoToZoo()
            end
        end

		-- local success, data = DataService:GetData():await()
		-- if not success then
		-- 	return
		-- end
		-- -- print(`[Quest Controller] Current Step for {player} is {data.Tutorial.CurrentStep}`)

		-- -- Only run if we are on Step 1: "Visit the Shop"
		-- if data and data.Tutorial then
		-- 	if data.Tutorial.CurrentStep == 1 then
		-- 		local shop = Workspace.Gameplay.Props:FindFirstChild("Shop_Weapons")
		-- 		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		-- 		TargetQuest = shop

		-- 		if root and shop then
		-- 			local distance = (root.Position - shop.PrimaryPart.Position).Magnitude
		-- 			-- print(`[Quest Controller] Distance from Player {player} to Shop is {distance}`)
		-- 			if distance < 30 then
		-- 				QuestService:CompleteVisitShop()
		-- 			end
		-- 		end
		-- 	elseif data.Tutorial.CurrentStep == 3 then
		-- 		local EnclosureService = Knit.GetService("EnclosureService")
		-- 		local enclosure = EnclosureService.GetPlayerEnclosure()
		-- 		TargetQuest = enclosure
		-- 	end
		-- end
	end)

	print("[Quest Controller] Controller initialized.")
end

return QuestController
