local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function BaseCard(props)
	local children = {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = ColorPallete.Shop_Yellow,
			Thickness = 3,
		}),
	}

	for key, child in pairs(props[Roact.Children] or {}) do
		children[key] = child
	end

	return Roact.createElement("Frame", {
		Size = props.Size or UDim2.fromOffset(180, 220),
		BackgroundColor3 = ColorPallete.Shop_Background_White,
		LayoutOrder = props.LayoutOrder or 0,
	}, children)
end

return BaseCard
