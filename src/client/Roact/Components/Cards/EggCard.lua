local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local BaseCard = require(script.Parent.BaseCard)
local ActionButton = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Components.Buttons.ActionButton)

local function EggCard(props)
	return Roact.createElement(BaseCard, nil, {
		Image = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromScale(0.75, 0.55),
			Image = props.Image or "",
			BackgroundTransparency = 1,
		}),

		NameText = Roact.createElement("TextLabel", {
			Position = UDim2.new(0, 5, 0.55, 0),
			Size = UDim2.new(1, -12, 0, 28),
			Text = props.Name,
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1,
		}),

		OwnedText = Roact.createElement("TextLabel", {
			Position = UDim2.new(0, 5, 0.65, 0),
			Size = UDim2.new(1, -12, 0, 28),
			Text = `Owned: {props.Owned or 0}`,
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1
		}),

		Action = props.Action and Roact.createElement(ActionButton, props.Action),
	})
end

return RoactHooks.new(Roact)(EggCard)
