-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Knit Services
local TeleportService = nil

-- Teleport Controller
local TeleportController = Knit.CreateController({
	Name = "TeleportController",
})

--|| Functions ||--

function TeleportController:TeleportToShop()
	TeleportService:TeleportToShop()
end

function TeleportController:TeleportToEnclosure()
	TeleportService:TeleportToEnclosure()
end

function TeleportController:KnitStart() 
    TeleportService = Knit.GetService("TeleportService")
    print("[Teleport Controller] Controller started.")
end

return TeleportController