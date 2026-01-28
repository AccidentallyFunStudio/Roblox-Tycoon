-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local ButtonPromptActions = {
	SetVisibility = Rodux.makeActionCreator("SetVisibility", function(value)
        return {
            value = value,
        }
    end),
}

return ButtonPromptActions