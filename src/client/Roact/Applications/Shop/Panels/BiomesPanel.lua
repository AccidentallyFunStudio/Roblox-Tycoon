-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Biomes = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

-- Components
local ItemCard = require(StarterPlayerScripts.Client.Roact.Components.ItemCard)
local BiomeCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.BiomeCard)

function BiomesPanel(props, hooks)
	local biomeList = {}
	for _, biome in pairs(Biomes) do
		table.insert(biomeList, biome)
	end

	table.sort(biomeList, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local biomeCards = {}
	for _, item in ipairs(biomeList) do
		biomeCards[item.Id] = Roact.createElement(BiomeCard, {
			Name = item.Name,
			Description = item.Description,
			Price = item.Upgrades[1].Cost,
            LayoutOrder = item.LayoutOrder,
			Image = item.Image,
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
