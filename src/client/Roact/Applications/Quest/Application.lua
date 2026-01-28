-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

function Quest(_, hooks)
    local questState = RoduxHooks.useSelector(hooks, function(state)
        return state.QuestReducer
    end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 100),
		Size = UDim2.new(0, 500, 0, 50),
        ZIndex = 1,
        Visible = questState.visible
	}, {
        QuestTextLabel = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundTransparency = 0.50,
            BackgroundColor3 = ColorPallete.DarkBG,
            Size = UDim2.new(1, 0, 1, 0),
            Text = questState.text,
            Font = Enum.Font.FredokaOne,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextColor3 = ColorPallete.Text,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.XY,
            ZIndex = 1,
            Visible = questState.visible
        }, {
            UICorner = Roact.createElement("UICorner", {CornerRadius = UDim.new(0, 5)})
        })
	})
end

Quest = RoactHooks.new(Roact)(Quest)
return Quest