local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function ActionButton(props)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, -16, 0, 35),
		Position = UDim2.new(0, 8, 1, -45),
		BackgroundTransparency = 1,
	}, {
		Button = Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = props.Color or ColorPallete.Shop_Yellow,
			[Roact.Event.MouseButton1Click] = props.OnClick,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			Text = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Text = props.Label,
				Font = Enum.Font.FredokaOne,
				TextSize = 18,
				TextColor3 = ColorPallete.Text,
				BackgroundTransparency = 1,
			}),
		}),
	})
end

return ActionButton
