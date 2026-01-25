-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Actions
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local CoinActions = require(Actions.CoinActions)

local function CloseButton(props, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromScale(0.15, 0.15),
		Visible = true,
		ZIndex = 100,
	}, {
		Button = Roact.createElement("ImageButton", {
			BackgroundColor3 = Color3.fromRGB(255, 42, 42),
			Image = "rbxassetid://122895405767584",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0),
			Rotation = 0,
			Size = styles.sizeAlpha:map(function(alpha)
				return UDim2.fromScale(alpha, alpha)
			end),
			[Roact.Event.MouseButton1Click] = function()
				if props.OnClick then
					props.OnClick()
				end
			end,
		}),
	})
end

CloseButton = RoactHooks.new(Roact)(CloseButton)

return CloseButton
