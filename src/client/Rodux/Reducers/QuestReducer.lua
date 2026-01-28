-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local QuestReducer = Rodux.createReducer({
    text = "Welcome!",
    visible = false,
}, {
    SetQuestInfo = function(state, action)
        local newState = table.clone(state)
        newState.text = action.text
        newState.visible = action.visible
        return newState
    end,
})

return QuestReducer