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

	SetCurrentTab = Rodux.makeActionCreator("SetCurrentTab", function(value)
		return { value = value }
	end),

	ShowNotification = Rodux.makeActionCreator("ShowNotification", function(text)
        return { 
            text = text,
            ticket = os.clock() -- Used as a unique key to reset the pop-up timer
        }
    end),
}

return UIActions
