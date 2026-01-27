-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local UIReducer = Rodux.createReducer({
    CurrentUI = "",
    CurrentTab = "Animals",
    NotificationText = nil,
    NotificationTicket = nil,
}, {
    SetCurrentUI = function(state, action)
        local newState = table.clone(state)
        newState.CurrentUI = action.value
        return newState
    end,

    ResetCurrentUI = function(state, action)
        local newState = table.clone(state)
        newState.CurrentUI = ""
        return newState
    end,

    SetCurrentTab = function(state, action)
        local newState = table.clone(state)
        newState.CurrentTab = action.value
        return newState
    end,

    ShowNotification = function(state, action)
        local newState = table.clone(state)
        newState.NotificationText = action.text
        newState.NotificationTicket = action.ticket
        return newState
    end,
})

return UIReducer
