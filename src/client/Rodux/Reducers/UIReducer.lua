-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local UIReducer = Rodux.createReducer({
	CurrentUI = "",
}, {
	SetCurrentUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentUI = action.value
		return newState
	end,
}, {
    ResetCurrentUI = function(state, action)
        local newState = table.clone(state)
        newState.CurrentUI = ""
        return newState
    end,
})

return UIReducer