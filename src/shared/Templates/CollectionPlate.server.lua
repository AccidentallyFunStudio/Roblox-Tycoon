local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")

local EnclosureService

-- Wait until Knit is fully started
Knit.OnStart():andThen(function()
    EnclosureService = Knit.GetService("EnclosureService")
end)

local plate = script.Parent
local enclosure = plate.Parent

local debounce = false

plate.Touched:Connect(function(hit)
    if debounce or not EnclosureService then return end

    local character = hit.Parent
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    debounce = true
    EnclosureService:Collect(player, enclosure)

    task.delay(0.5, function()
        debounce = false
    end)
end)