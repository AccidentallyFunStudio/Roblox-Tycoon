local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodux = require(ReplicatedStorage.Packages.Rodux)

return Rodux.createReducer({
	Eggs = {}, -- ["Egg_Small"] = 2
}, {
	SetEggs = function(_, action)
		return {
			Eggs = action.value
		}
	end,

	SetEggCount = function(state, action)
		local eggs = table.clone(state.Eggs)
		eggs[action.eggId] = action.count
		return {
			Eggs = eggs
		}
	end,
})
