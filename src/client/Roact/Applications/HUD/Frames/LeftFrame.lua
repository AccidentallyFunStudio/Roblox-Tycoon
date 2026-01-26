-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Textures = require(ReplicatedStorage.Shared.Data.Textures.UI)

-- LeftFrame
function LeftFrame(_, hooks)
	local TeleportController = Knit.GetController("TeleportController")

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0.1, 0, 0.6, 0),
		Position = UDim2.new(0.015, 0, 0.5, 0),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 15),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		
		ShopButton = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 65, 0, 65),
			BackgroundColor3 = ColorPallete.White,
			LayoutOrder = 1,
			[Roact.Event.MouseButton1Click] = function()
				TeleportController:TeleportToShop()
				Store:dispatch(UIActions.SetCurrentUI("Shop"))
				Store:dispatch(UIActions.SetCurrentTab("Eggs"))
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = ColorPallete.Gold,
				Thickness = 4,
			}),
			ShopIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 45, 0, 45),
				Position = UDim2.new(0.5, 0, 0.5, -10),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = Textures["Shop"],
				BackgroundTransparency = 1,
			}),
			ShopLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0.5, 0, 1, -25),
				AnchorPoint = Vector2.new(0.5, 0),
				Text = "Shop",
				TextColor3 = ColorPallete.Gold,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				BackgroundTransparency = 1,
			}),
		}),

		SpinWheelButton = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 65, 0, 65),
			BackgroundColor3 = ColorPallete.White,
			LayoutOrder = 2,
			[Roact.Event.MouseButton1Click] = function()
				print("Spin Wheel Button Clicked!")
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = ColorPallete.Gold,
				Thickness = 4,
			}),
			SpinWheelIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 45, 0, 45),
				Position = UDim2.new(0.5, 0, 0.5, -10),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = Textures["SpinWheel"],
				BackgroundTransparency = 1,
			}),
			SpinWheelLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0.5, 0, 1, -25),
				AnchorPoint = Vector2.new(0.5, 0),
				Text = "Spin",
				TextColor3 = ColorPallete.Gold,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
		}),

		InventoryButton = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 65, 0, 65),
			BackgroundColor3 = ColorPallete.White,
			LayoutOrder = 3,
			[Roact.Event.MouseButton1Click] = function()
				Store:dispatch(UIActions.SetCurrentUI("Inventory"))
				Store:dispatch(UIActions.SetCurrentTab("Animals"))
				print("Inventory Button Clicked!")
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = ColorPallete.Gold,
				Thickness = 4,
			}),
			InventoryIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 45, 0, 45),
				Position = UDim2.new(0.5, 0, 0.5, -7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = Textures.Inventory,
				BackgroundTransparency = 1,
			}),
			InventoryLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0.5, 0, 1, -20),
				AnchorPoint = Vector2.new(0.5, 0),
				Text = "Inventory",
				TextColor3 = ColorPallete.Gold,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				BackgroundTransparency = 1,
			}),
		}),

		MyZooButton = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 65, 0, 65),
			BackgroundColor3 = ColorPallete.White,
			LayoutOrder = 4,
			[Roact.Event.MouseButton1Click] = function()
				TeleportController:TeleportToEnclosure()
				Store:dispatch(UIActions.ResetCurrentUI())
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = ColorPallete.Gold,
				Thickness = 4,
			}),
			MyZooIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 45, 0, 45),
				Position = UDim2.new(0.5, 0, 0.5, -10),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = Textures.Olympus,
				BackgroundTransparency = 1,
			}),
			MyZooLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0.5, 0, 1, -25),
				AnchorPoint = Vector2.new(0.5, 0),
				Text = "My Zoo",
				TextColor3 = ColorPallete.Gold,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				BackgroundTransparency = 1,
			}),
		}),
	})
end

LeftFrame = RoactHooks.new(Roact)(LeftFrame)
return LeftFrame