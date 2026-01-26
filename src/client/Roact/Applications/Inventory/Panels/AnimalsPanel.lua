-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals)

-- Components
local ItemCard = require(StarterPlayerScripts.Client.Roact.Components.ItemCard)
local AnimalCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.AnimalCard)

function AnimalsPanel(props, hooks)
	local animalCards = {}

	for _, animal in ipairs(Animals) do
		animalCards[animal.Id] = Roact.createElement(AnimalCard, {
			Id = animal.Id,
			Name = animal.Name,
			Price = animal.Price,
			Biome = animal.Biome,
            Image = animal.Image,
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
                    }),
    
                    Items = Roact.createFragment(animalCards),
                })
end

AnimalsPanel = RoactHooks.new(Roact)(AnimalsPanel)
return AnimalsPanel