-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local CloseButton = require(Components.CloseButton)

function Coin(props, hooks)
    return Roact.createElement("ScreenGui", {
        -- ResetOnSpawn ensures the UI stays or refreshes depending on your needs
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    }, {
        Label = Roact.createElement("TextLabel", {
            -- Positioning and Sizing
            Size = UDim2.new(0, 200, 0, 50),
            Position = props.Position or UDim2.new(0.5, 0, 0.1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            
            -- Styling
            Text = props.Text or "Default HUD Text",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 24,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1, -- Transparent background for HUD feel
            
            -- Adding a shadow for readability
            TextStrokeTransparency = 0.5,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        })
    })
end

Coin = RoactHooks.new(Roact)(Coin)
return Coin