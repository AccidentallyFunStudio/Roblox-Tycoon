-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Eggs = require(ReplicatedStorage.Shared.Data.Shop.Eggs)

-- Components
local ItemCard = require(StarterPlayerScripts.Client.Roact.Components.ItemCard)

function EggsPanel(props, hooks)
	local eggsCards = {}

	for _, item in ipairs(Eggs) do
		eggsCards[item.Id] = Roact.createElement(ItemCard, {
			Name = item.Name,
			Description = item.Description,
			Price = item.Price,
            Image = item.Image,
            LayoutOrder = item.LayoutOrder,
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

		Items = Roact.createFragment(eggsCards),
	})
end

EggsPanel = RoactHooks.new(Roact)(EggsPanel)
return EggsPanel