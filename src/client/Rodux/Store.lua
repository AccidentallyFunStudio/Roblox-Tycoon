-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directories
local Reducers = StarterPlayer.StarterPlayerScripts.Client.Rodux.Reducers
local TemplateReducer = require(Reducers.TemplateReducer)
local CoinReducer = require(Reducers.CoinReducer)
local UIReducer = require(Reducers.UIReducer)
local EggReducer = require(Reducers.EggReducer)

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Store
local StoreReducer = Rodux.combineReducers({
	TemplateReducer = TemplateReducer,
	CoinReducer = CoinReducer,
	UIReducer = UIReducer,
	EggReducer = EggReducer
})

local Store = Rodux.Store.new(StoreReducer, nil, {})

return Store
