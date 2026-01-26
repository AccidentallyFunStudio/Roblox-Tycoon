-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local CollectionService = game:GetService("CollectionService")

-- local Template = require(ReplicatedStorage.Shared.Templates.ShopTrigger)

-- for _, model in ipairs(CollectionService:GetTagged("ShopEntry")) do
-- 	local trigger = model:FindFirstChildWhichIsA("BasePart")
-- 	if not trigger then continue end

-- 	if trigger:FindFirstChild("ShopTrigger") then
-- 		continue
-- 	end

-- 	local clone = Template:Clone()
-- 	clone.Parent = trigger

-- 	print(`[Bootstrap] Attached ShopTrigger to {trigger:GetFullName()}`)
-- end