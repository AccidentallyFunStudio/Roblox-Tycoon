-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directories
local Reducers = StarterPlayer.StarterPlayerScripts.Client.Rodux.Reducers
local TemplateReducer = require(Reducers.TemplateReducer)
local CoinReducer = require(Reducers.CoinReducer)
local UIReducer = require(Reducers.UIReducer)
local EggReducer = require(Reducers.EggReducer)
local QuestReducer = require(Reducers.QuestReducer)
local ButtonPromptReducer = require(Reducers.ButtonPromptReducer)

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Store
local StoreReducer = Rodux.combineReducers({
	TemplateReducer = TemplateReducer,
	CoinReducer = CoinReducer,
	UIReducer = UIReducer,
	EggReducer = EggReducer,
	QuestReducer = QuestReducer,
	ButtonPromptReducer = ButtonPromptReducer
})

local Store = Rodux.Store.new(StoreReducer, nil, {})

return Store
