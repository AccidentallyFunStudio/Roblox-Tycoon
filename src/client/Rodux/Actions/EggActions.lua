local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodux = require(ReplicatedStorage.Packages.Rodux)

return {
	SetEggs = Rodux.makeActionCreator("SetEggs", function(value)
		return { value = value }
	end),

	SetEggCount = Rodux.makeActionCreator("SetEggCount", function(eggId, count)
		return {
			eggId = eggId,
			count = count,
		}
	end),
}
