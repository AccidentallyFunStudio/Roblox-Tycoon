--[=[
    Owner: Yokhaii
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)


-- Component
local function HUD(_, hooks)
    local coins = RoduxHooks.useSelector(hooks, function(state)
        return state.CoinReducer.Coins
    end)

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    },
    {
        CoinLabel = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0,
            Position = UDim2.fromScale(0.5, 0.05),
            Size = UDim2.fromOffset(100, 50),
            ZIndex = 100,
            FontFace = Font.fromEnum(Enum.Font.Highway),
            Text = `{coins}`,
            TextColor3 = Color3.fromRGB(255, 200, 0),
            TextScaled = true,
    }, 
    { 
        BottomFrame = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.965),
            Size = UDim2.fromScale(1, 0.13),
            ZIndex = 1,
            Name = "Bottom",
        }, {

            Button = Roact.createElement("TextButton", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(175, 175, 175),
                BackgroundTransparency = 0.5,
                Size = UDim2.fromScale(0.18, 0.7),
                ZIndex = 1,
                Text = "CLICK", -- Added text to see the button
                LayoutOrder = 1,
                [Roact.Event.MouseButton1Click] = function()
                    print("Button Clicked!")
                end,
            }),

            UIListLayout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0.03, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 4.5,
                AspectType = Enum.AspectType.FitWithinMaxSize,
                DominantAxis = Enum.DominantAxis.Width,
            })
        }),
    })
})
end

HUD = RoactHooks.new(Roact)(HUD)
return HUD