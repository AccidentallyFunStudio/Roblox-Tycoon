-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function ItemCard(props, hooks)
	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(180, 220),
		BackgroundColor3 = ColorPallete.Shop_Background_White,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = ColorPallete.Shop_Yellow,
			Thickness = 3,
		}),

		ImagePlaceholder = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.55),
			BackgroundColor3 = ColorPallete.Shop_InactiveTab,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),

		Name = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, -12, 0, 28),
			Position = UDim2.new(0, 6, 0.6, 0),
			Text = props.Name,
			Font = Enum.Font.FredokaOne,
			TextSize = 20,
			TextColor3 = ColorPallete.DarkBG,
			BackgroundTransparency = 1,
			TextWrapped = true,
		}),

		Price = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, -12, 0, 24),
			Position = UDim2.new(0, 6, 0.75, 0),
			Text = tostring(props.Price) .. " Coins",
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.Shop_Price,
			BackgroundTransparency = 1,
		}),

		BuyButton = Roact.createElement("TextButton", {
			Size = UDim2.new(1, -16, 0, 34),
			Position = UDim2.new(0, 8, 1, -42),
			BackgroundColor3 = ColorPallete.Shop_Yellow,
			Text = "Buy",
			Font = Enum.Font.FredokaOne,
			TextSize = 18,
			TextColor3 = ColorPallete.White,

			[Roact.Event.MouseButton1Click] = function()
				if props.OnBuy then
					props.OnBuy(props.Id)
				end
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
	})
end

ItemCard = RoactHooks.new(Roact)(ItemCard)
return ItemCard