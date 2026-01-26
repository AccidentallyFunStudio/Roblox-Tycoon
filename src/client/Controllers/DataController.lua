-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directories
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local CoinActions = require(Actions.CoinActions)

local DataService

-- DataController
local DataController = Knit.CreateController({
	Name = "DataController",
})

function DataController:KnitStart()
	DataService = Knit.GetService("DataService")

	-- Initial pull
	local sucess, data = DataService:GetData():await()
	if sucess and data and data.Gold then
		Store:dispatch(CoinActions.setCoins(data.Gold))
	end

	-- -- Reactive updates
	-- DataService.DataChanged:Connect(function(newData)
	-- 	Store:dispatch({
	-- 		type = "SetGold",
	-- 		value = newData.Gold,
	-- 	})
	-- end)
end

return DataController