-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function ItemCard(props, hooks)
	local children = {}

	children.UICorner = Roact.createElement("UICorner", {
		CornerRadius = UDim.new(0, 12),
	})

	children.UIStroke = Roact.createElement("UIStroke", {
		Color = ColorPallete.Shop_Yellow,
		Thickness = 3,
	})

	children.ImagePlaceholder = Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromScale(0.75, 0.55),
		Image = props.Image or "",
		BackgroundTransparency = 1,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
	})

	children.NameText = Roact.createElement("TextLabel", {
		Size = UDim2.new(1, -12, 0, 28),
		Position = UDim2.new(0, 5, 0.55, 0),
		Text = props.Name,
		Font = Enum.Font.FredokaOne,
		TextSize = 18,
		TextColor3 = ColorPallete.DarkBG,
		BackgroundTransparency = 1,
		TextWrapped = true,
	})

	-- ✅ ONLY render for Animals
	if props.Biome then
		children.BiomeText = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, -12, 0, 24),
			Position = UDim2.new(0, 5, 0.65, 0),
			Text = `Biome: {props.Biome}`,
			Font = Enum.Font.FredokaOne,
			TextSize = 16,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	children.BuyButton = Roact.createElement("ImageButton", {
		Size = UDim2.new(1, -16, 0, 34),
		Position = UDim2.new(0, 8, 1, -42),
		BackgroundColor3 = ColorPallete.Shop_Yellow,

		[Roact.Event.MouseButton1Click] = function()
			if props.OnBuy then
				props.OnBuy(props.Id)
			end
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Text = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			Text = `{props.Price} Golds`,
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.Text,
			BackgroundTransparency = 1,
		}),
	})

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(180, 220),
		BackgroundColor3 = ColorPallete.Shop_Background_White,
		LayoutOrder = props.LayoutOrder or 0,
	}, children)
end

ItemCard = RoactHooks.new(Roact)(ItemCard)
return ItemCard