-- local Knit = require(game.ReplicatedStorage.Packages.Knit)
-- local Players = game:GetService("Players")

-- local Store = require(
-- 	game:GetService("StarterPlayer").StarterPlayerScripts.Client.Rodux.Store
-- )
-- local UIActions = require(
-- 	game:GetService("StarterPlayer").StarterPlayerScripts.Client.Rodux.Actions.UIActions
-- )

-- local player = Players.LocalPlayer
-- local character = player.Character or player.CharacterAdded:Wait()
-- local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- local triggerPart = script.Parent
-- local debounce = false

-- triggerPart.Touched:Connect(function(hit)
-- 	if debounce or not ShopService then return end
-- 	if hit ~= humanoidRootPart then return end

-- 	debounce = true

-- 	Store:dispatch(UIActions.SetCurrentUI("Shop"))

-- end)

-- triggerPart.TouchEnded:Connect(function(hit)
-- 	if hit ~= humanoidRootPart then return end

-- 	Store:dispatch(UIActions.ResetCurrentUI())

-- 	task.delay(0.2, function()
-- 		debounce = false
-- 	end)
-- end)