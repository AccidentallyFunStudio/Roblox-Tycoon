-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Actions
local UIActions = {
	SetCurrentUI = Rodux.makeActionCreator("SetCurrentUI", function(value)
		return { value = value }
	end),

	ResetCurrentUI = Rodux.makeActionCreator("ResetCurrentUI", function(value)
		return { value = value }
	end),
}

return UIActions
