local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This now receives the dictionary [Id] = {Data}
local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals)

local AnimalRoller = {}

-- 1. Precompute total weight using pairs for the dictionary
local TotalWeight = 0
for _, animal in pairs(Animals) do
	TotalWeight += animal.Probability
end

function AnimalRoller.RollOne()
	local roll = math.random() * TotalWeight
	local cumulative = 0

	-- 2. Iterate through the dictionary to find the rolled animal
	for _, animal in pairs(Animals) do
		cumulative += animal.Probability
		if roll <= cumulative then
			return animal
		end
	end

	-- 3. Fallback: Since it's a dictionary, we pick an arbitrary key if roll fails
	-- This is a safety measure; under normal math, the loop above will always return.
	local firstKey = next(Animals)
	return Animals[firstKey]
end

function AnimalRoller.RollMany(count)
	local results = {}

	for i = 1, count do
		local animal = AnimalRoller.RollOne()
		-- We use animal.Id as the key for the results table
		results[animal.Id] = (results[animal.Id] or 0) + 1
	end

	return results
end

return AnimalRoller