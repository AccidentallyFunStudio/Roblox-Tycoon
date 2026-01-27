-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

local function ButtonPrompt(props, hooks)
	return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 15),
        LayoutOrder = props.LayoutOrder
    }, {
        PromptImage = Roact.createElement("ImageLabel", {
            Size = UDim2.new(0, 50, 0, 50),
            Image = props.Image,
            BackgroundTransparency = 1,
        }),

        PromptText = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 0),
            Size = UDim2.fromOffset(180, 50),
            Font = Enum.Font.FredokaOne,
            Text = props.Text,
            TextColor3 = ColorPallete.Text,
            TextSize = 24,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
end

ButtonPrompt = RoactHooks.new(Roact)(ButtonPrompt)
return ButtonPrompt