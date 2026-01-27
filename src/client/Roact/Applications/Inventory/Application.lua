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

-- Components
local CloseButton = require(StarterPlayerScripts.Client.Roact.Components.CloseButton)
local TabButton = require(StarterPlayerScripts.Client.Roact.Components.TabButton)

-- Panels
local AnimalsPanel = require(StarterPlayerScripts.Client.Roact.Applications.Inventory.Panels.AnimalsPanel)
local BiomesPanel = require(StarterPlayerScripts.Client.Roact.Applications.Inventory.Panels.BiomesPanel)
local EggsPanel = require(StarterPlayerScripts.Client.Roact.Applications.Inventory.Panels.EggsPanel)

-- Inventory
local function Inventory(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	return Roact.createElement("Frame", {
		Visible = UIReducer.CurrentUI == "Inventory",
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
			BorderSizePixel = 0,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.new(0, 200, 1, 0),
				Position = UDim2.new(0, 25, 0, 0),
				Text = "Inventory",
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
			Position = UDim2.new(0.5, 0, 0, 83),
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
					Knit.GetController("AudioController"):PlaySFX("UI_Click")
				end,
			}),

			EggsTab = Roact.createElement(TabButton, {
				Label = "Eggs",
				Value = "Eggs",
				Active = UIReducer.CurrentTab == "Eggs",
				OnClick = function(value)
					Store:dispatch(UIActions.SetCurrentTab(value))
					Knit.GetController("AudioController"):PlaySFX("UI_Click")
				end
			}),

			BiomesTab = Roact.createElement(TabButton, {
				Label = "Biomes",
				Value = "Biomes",
				Active = UIReducer.CurrentTab == "Biomes",
				OnClick = function(value)
					Store:dispatch(UIActions.SetCurrentTab(value))
					Knit.GetController("AudioController"):PlaySFX("UI_Click")
				end
			})
		}),

		-- Content
		Content = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 140),
			Size = UDim2.new(1, -60, 1, -140),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			AnimalsPanel = Roact.createElement(AnimalsPanel, {
				Visible = UIReducer.CurrentTab == "Animals",
			}),

			EggsPanel = Roact.createElement(EggsPanel, {
				Visible = UIReducer.CurrentTab == "Eggs"
			}),

			BiomesPanel = Roact.createElement(BiomesPanel, {
				Visible = UIReducer.CurrentTab == "Biomes"
			})
		}),
	})
end

Inventory = RoactHooks.new(Roact)(Inventory)
return Inventory