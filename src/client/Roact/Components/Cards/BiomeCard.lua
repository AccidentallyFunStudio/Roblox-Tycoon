local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

local BaseCard = require(script.Parent.BaseCard)
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function BiomeCard(props, hooks)
	return Roact.createElement(BaseCard, {
		LayoutOrder = props.LayoutOrder,
	}, {
		Image = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromScale(0.75, 0.55),
			Image = props.Image or "",
			BackgroundTransparency = 1,
		}),

		Name = Roact.createElement("TextLabel", {
			Position = UDim2.new(0, 5, 0.55, 0),
			Size = UDim2.new(1, -12, 0, 28),
			Text = props.Name,
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1,
		}),

		-- Example usage:
		-- Price: 500 Gold
		Subtext = Roact.createElement("TextLabel", {
			Position = UDim2.new(0, 5, 0.65, 0),
			Size = UDim2.new(1, -12, 0, 28),
			Text = props.Subtext,
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1,
		}),

		Button = Roact.createElement("ImageButton", {
			Interactable = props.ButtonClickable,
			Size = UDim2.new(1, -16, 0, 34),
			Position = UDim2.new(0, 8, 1, -42),
			BackgroundColor3 = ColorPallete.Shop_Yellow,
			[Roact.Event.MouseButton1Click] = function()
				props.OnButtonClick()
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			-- Example usage:
			-- Purchase, Upgrade
			ButtonText = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Text = `{props.ButtonText}`,
				Font = Enum.Font.FredokaOne,
				TextSize = 18,
				BackgroundTransparency = 1,
                TextColor3 = ColorPallete.Text
			}),
		}),
	})
end

return RoactHooks.new(Roact)(BiomeCard)
