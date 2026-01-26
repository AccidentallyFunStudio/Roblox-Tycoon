-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directories
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Actions
local CoinActions = require(Actions.CoinActions)
local EggActions = require(Actions.EggActions)

local DataService

-- DataController
local DataController = Knit.CreateController({
	Name = "DataController",
})

function DataController:KnitStart()
	DataService = Knit.GetService("DataService")

	-- Initial pull
	local success, data = DataService:GetData():await()
	if success and data then
		if data.Gold then
			Store:dispatch(CoinActions.setCoins(data.Gold))
		end

		if data.Eggs then
			Store:dispatch(EggActions.SetEggs(data.Eggs))
		end
	end

	-- Reactive updates
	DataService.DataChanged:Connect(function(payload)
		if payload.Gold ~= nil then
			Store:dispatch(CoinActions.setCoins(payload.Gold))
		end

		if payload.Eggs ~= nil then
			Store:dispatch(EggActions.SetEggs(payload.Eggs))
		end
	end)
end

return DataController