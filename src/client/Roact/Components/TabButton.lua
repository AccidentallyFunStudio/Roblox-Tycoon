-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function TabButton(props, hooks)
	return Roact.createElement("ImageButton", {
		Size = props.Size or UDim2.fromScale(0.25, 1),
		BackgroundColor3 = props.Active and ColorPallete.Shop_Tab_Active_BG or ColorPallete.Shop_Tab_Inactive_BG,
		[Roact.Event.MouseButton1Click] = function()
			props.OnClick(props.Value)
		end,
	}, {
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
        UIStroke = Roact.createElement("UIStroke",
        { 
            Color = ColorPallete.Shop_Yellow,
            Thickness = 3,
            ZIndex = 1,
         }),
        TextLabel = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = props.Label,
            Font = Enum.Font.FredokaOne,
            TextSize = 24,
            TextColor3 = props.Active and ColorPallete.Shop_Tab_Active_Text or ColorPallete.Shop_Tab_Inactive_Text,
        }),
	})
end

TabButton = RoactHooks.new(Roact)(TabButton)
return TabButton