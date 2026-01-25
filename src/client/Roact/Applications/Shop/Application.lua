-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Textures = require(ReplicatedStorage.Shared.Data.Textures.UI)
local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals)

-- Components
local CloseButton = require(StarterPlayerScripts.Client.Roact.Components.CloseButton)
local TabButton = require(StarterPlayerScripts.Client.Roact.Components.TabButton)
local ItemCard = require(StarterPlayerScripts.Client.Roact.Components.ItemCard)

-- Shop
local function Shop(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	-- 🔹 Build item cards safely
	local animalCards = {}

	if UIReducer.CurrentTab == "Animals" then
		for _, item in ipairs(Animals) do
			animalCards[item.Id] = Roact.createElement(ItemCard, {
				Id = item.Id,
				Name = item.Name,
				Price = item.Price,
				Rarity = item.Rarity,
			})
		end
	end

	return Roact.createElement("Frame", {
		Visible = UIReducer.CurrentUI == "Shop",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		BackgroundColor3 = ColorPallete.Shop_Background_White,
	}, {
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 6,
			Color = ColorPallete.Shop_Yellow,
		}),

		-- Header
		Header = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundColor3 = ColorPallete.Shop_Yellow,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.new(0, 200, 1, 0),
				Position = UDim2.new(0, 25, 0, 0),
				Text = "Shop",
				Font = Enum.Font.FredokaOne,
				TextSize = 32,
				TextColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			CloseButton = Roact.createElement(CloseButton, {
				Position = UDim2.new(1, -40, 0.5, 0),
				Size = UDim2.fromOffset(30, 30),
				OnClick = function()
					Store:dispatch(UIActions.SetCurrentUI(""))
				end,
			}),
		}),

		-- Tabs
		Tabs = Roact.createElement("Frame", {
			Size = UDim2.new(0, 450, 0, 50),
			Position = UDim2.new(0.5, 0, 0, 80),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 15),
			}),

			AnimalsTab = Roact.createElement(TabButton, {
				Label = "Animals",
				Value = "Animals",
				Active = UIReducer.CurrentTab == "Animals",
				OnClick = function(value)
					Store:dispatch(UIActions.SetCurrentTab(value))
				end,
			}),

			BiomesTab = Roact.createElement(TabButton, {
				Label = "Biomes",
				Value = "Biomes",
				Active = UIReducer.CurrentTab == "Biomes",
				OnClick = function(value)
					Store:dispatch(UIActions.SetCurrentTab(value))
				end,
			}),
		}),

		-- Content
		Content = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 160),
			Size = UDim2.new(1, -60, 1, -190),
			BackgroundTransparency = 1,
		}, {
			ItemsPanel = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageTransparency = 0.9,
				BackgroundTransparency = 1,
			}, {
				Grid = Roact.createElement("UIGridLayout", {
					CellSize = UDim2.fromOffset(180, 220),
					CellPadding = UDim2.fromOffset(16, 16),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				Items = Roact.createFragment(animalCards),
			}),
		}),
	})
end

Shop = RoactHooks.new(Roact)(Shop)
return Shop
