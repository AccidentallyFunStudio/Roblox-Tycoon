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
    local instructions = [[<font color="#FFA500"><b>INSTRUCTIONS</b></font>

1. Visit <font color="#55FF55"><b>Shop</b></font> to buy Eggs and Biomes
2. Click <font color="#55A9FF"><b>My Zoo</b></font> to teleport back
3. To hatch eggs, open <font color="#FFFF55"><b>Inventory</b></font>
4. To place Biomes, open <font color="#FFFF55"><b>Inventory</b></font>
5. <font color="#FF5555"><b>Placement:</b></font> [<b>LMB</b>] Place, [<b>E</b>] Cancel, [<b>R</b>] Rotate
6. Add Animals via <font color="#FFFF55"><b>Inventory</b></font>]]

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(250, 150),
        ZIndex = -100,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8)
		}),

        TextLabel = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            RichText = true,
            Text = instructions,
            Font = Enum.Font.FredokaOne,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = ColorPallete.Text,
            TextWrapped = true
        })
        -- UIListLayout = Roact.createElement("UIListLayout", {
        --     Padding = UDim.new(0, 30),
        --     SortOrder = Enum.SortOrder.LayoutOrder
        -- }),
        -- PlaceButton = Roact.createElement(ButtonPrompt, {
        --     Image = KeyboardPrompt.LMB,
        --     Text = "Place",
        --     LayoutOrder = 1,
        -- }),
        -- RotateButton = Roact.createElement(ButtonPrompt, {
        --     Image = KeyboardPrompt.R,
        --     Text = "Rotate",
        --     LayoutOrder = 2,
        -- }),
        -- CancelButton = Roact.createElement(ButtonPrompt, {
        --     Image = KeyboardPrompt.E,
        --     Text = "Cancel Placement",
        --     LayoutOrder = 3,
        -- })
	})
end

Prompt = RoactHooks.new(Roact)(Prompt)
return Prompt