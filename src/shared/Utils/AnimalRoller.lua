local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals)

local AnimalRoller = {}

-- Precompute total weight once
local TotalWeight = 0
for _, animal in ipairs(Animals) do
	TotalWeight += animal.Probability
end

function AnimalRoller.RollOne()
	local roll = math.random() * TotalWeight
	local cumulative = 0

	for _, animal in ipairs(Animals) do
		cumulative += animal.Probability
		if roll <= cumulative then
			return animal
		end
	end

	-- Fallback (should never happen)
	return Animals[#Animals]
end

function AnimalRoller.RollMany(count)
	local results = {}

	for i = 1, count do
		local animal = AnimalRoller.RollOne()
		results[animal.Id] = (results[animal.Id] or 0) + 1
	end

	return results
end

return AnimalRoller
