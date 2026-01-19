-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local CoinReducer = Rodux.createReducer({
	Coins = 0,
}, {
	setCoins = function(state, action)
		return { Coins = action.value }
	end,
})

return CoinReducer