local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnclosuresFolder = workspace:WaitForChild("Gameplay"):WaitForChild("Scripts"):WaitForChild("Enclosures")

local Template = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Templates"):WaitForChild("CollectionPlate")

for _, enclosure in ipairs(EnclosuresFolder:GetChildren()) do
    local plate = enclosure:FindFirstChild("Collection Plate")
    if not plate then continue end

    if plate:FindFirstChild("CollectionPlate.server") then
        continue
    end

    local clone = Template:Clone()
    clone.Parent = plate

    print(`[Bootstrap] Attached Collection Plate script to {plate:GetFullName()}`)
end