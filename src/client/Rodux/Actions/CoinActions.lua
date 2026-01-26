-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local CoinActions = {
	setCoins = Rodux.makeActionCreator("setCoins", function(value : number)
        return {
            value = value,
        }
    end),
}

return CoinActions