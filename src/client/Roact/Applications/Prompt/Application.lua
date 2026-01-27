-- Game Services
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Components
local ButtonPrompt = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Components.ButtomPrompt)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local KeyboardPrompt = require(ReplicatedStorage.Shared.Data.Textures.KeyboardPrompt)

local function Prompt(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.75,
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(250, 150),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8)
		}),
        UIListLayout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0, 30),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        PlaceButton = Roact.createElement(ButtonPrompt, {
            Image = KeyboardPrompt.LMB,
            Text = "Place",
            LayoutOrder = 1,
        }),
        RotateButton = Roact.createElement(ButtonPrompt, {
            Image = KeyboardPrompt.R,
            Text = "Rotate",
            LayoutOrder = 2,
        }),
        CancelButton = Roact.createElement(ButtonPrompt, {
            Image = KeyboardPrompt.E,
            Text = "Cancel Placement",
            LayoutOrder = 3,
        })
	})
end

Prompt = RoactHooks.new(Roact)(Prompt)
return Prompt