-- Game Services
local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)
local Store = require(StarterPlayerScripts.Client.Rodux.Store)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Biomes = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

-- Components
local BiomeCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.BiomeCard)

function BiomesPanel(props, hooks)
	local PlacementController = Knit.GetController("PlacementController")
	local data, setData = hooks.useState(nil)

	hooks.useEffect(function()
		Knit.OnStart():andThen(function()
			local DataService = Knit.GetService("DataService")
			-- Initial fetch
			DataService.GetData():andThen(function(playerData)
				if playerData then
					setData(playerData)
				end
			end)
			-- Listen for live updates so UI refreshes when you buy/upgrade
			local connection = DataService.DataChanged:Connect(function(newData)
				setData(newData)
			end)
			return function()
				connection:Disconnect()
			end
		end)
	end, {})

	if not data then
		return nil
	end

	local biomeList = {}
	for _, biome in pairs(Biomes) do
		table.insert(biomeList, biome)
	end

	table.sort(biomeList, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local biomeCards = {}
	for _, item in ipairs(biomeList) do
		local biomeData = data.Biomes and data.Biomes[item.Id]
		local currentLevel = biomeData and biomeData.Level or 0
		local buttonText = "Purchase"
		local isClickable = true

		if currentLevel > 0 then
			-- For this prototype, we assume "Place" is the default action for owned biomes
			buttonText = "Place"
			isClickable = true
		else
			isClickable = false -- Cannot place what you don't own
		end

		biomeCards[item.Id] = Roact.createElement(BiomeCard, {
			Name = item.Name,
			LayoutOrder = item.LayoutOrder,
			Image = item.Image,
			ButtonText = buttonText,
			ButtonClickable = isClickable,
			Subtext = "",
			OnButtonClick = function()
				if currentLevel > 0 then
					local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)
					Store:dispatch(UIActions.ResetCurrentUI())

					-- Tiered Placement Logic
					-- Formats name to: Biome_Forest_01, Biome_Forest_02, etc.
					local modelName = string.format("Biome_%s_%02d", item.Name, currentLevel)
					PlacementController:StartPlacement(modelName)
				end
			end,
		})
	end

	return Roact.createElement("ScrollingFrame", {
		Visible = props.Visible,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarImageTransparency = 0.9,
		BackgroundTransparency = 1,
		BackgroundColor3 = ColorPallete.Shop_Background_White,
		BorderSizePixel = 10,
		BorderColor3 = ColorPallete.Shop_Background_White,
		BorderMode = Enum.BorderMode.Inset,
	}, {
		Grid = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(180, 220),
			CellPadding = UDim2.fromOffset(16, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Items = Roact.createFragment(biomeCards),
	})
end

BiomesPanel = RoactHooks.new(Roact)(BiomesPanel)
return BiomesPanel
