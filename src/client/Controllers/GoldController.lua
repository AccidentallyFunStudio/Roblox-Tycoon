local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GoldController = Knit.CreateController({
    Name = "GoldController"
})

function GoldController:KnitStart()
    local EnclosureService = Knit.GetService("EnclosureService")
    
    EnclosureService.GoldCollected:Connect(function(value)
        Knit.GetController("AudioController"):PlaySFX("UI_Gold")
    end)
    
    print("[Gold Controller] Controller started.")
end

return GoldController