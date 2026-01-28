-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local ButtonPromptReducer = Rodux.createReducer({
    Visibility = false
}, {
	SetVisibility = function(state, action)
        local newState = table.clone(state)
        newState.Visibility = action.someData
        return newState
    end,
})

return ButtonPromptReducer