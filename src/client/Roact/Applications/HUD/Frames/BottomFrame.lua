-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Textures = require(ReplicatedStorage.Shared.Data.Textures.UI)

function BottomFrame(props, hooks)
    local onBuildClick = function()
        local PlacementController = Knit.GetController("PlacementController")
        PlacementController:StartPlacement("Biome_Forest_01")
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(120, 120, 120),
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.5, 0, 1, -50),
        Size = UDim2.fromOffset(75, 75),
        ZIndex = -1
    }, {
        ItemButton = Roact.createElement("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            Text = "Build",
            [Roact.Event.MouseButton1Click] = onBuildClick
        })
    })
end

return RoactHooks.new(Roact)(BottomFrame)