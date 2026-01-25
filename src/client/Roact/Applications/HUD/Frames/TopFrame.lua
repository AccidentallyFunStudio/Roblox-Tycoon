-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Textures = require(ReplicatedStorage.Shared.Data.Textures.UI)

-- TopFrame
function TopFrame(_, hooks)
	local coins = RoduxHooks.useSelector(hooks, function(state)
		return state.CoinReducer.Coins
	end)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 200, 0, 100),
		Position = UDim2.new(0.98, 0, 0.05, 0),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}),
		-- Gold Bar
		GoldDisplay = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0.75, 0, 0.4, 0),
			BackgroundColor3 = ColorPallete["DarkBG"],
			LayoutOrder = 1,
			BackgroundTransparency = 1,
		}, {
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 20) }),
			UIStroke = Roact.createElement("UIStroke", { Color = ColorPallete["Gold"], Thickness = 3 }),
			Icon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(0, 5, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Image = Textures["Gold"],
				BackgroundTransparency = 1,
			}),
			Text = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -45, 1, 0),
				Position = UDim2.new(0, 40, 0, 0),
				Text = `{coins}`,
				TextColor3 = ColorPallete["Text"],
				Font = Enum.Font.GothamBold,
				TextSize = 24,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
	})
end

TopFrame = RoactHooks.new(Roact)(TopFrame)
return TopFrame