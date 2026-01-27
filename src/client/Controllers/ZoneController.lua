-- Game Services
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

-- Directories
local Packages = ReplicatedStorage.Packages
local Client = StarterPlayer.StarterPlayerScripts.Client

-- Packages
local Knit = require(Packages.Knit)
local Store = require(Client.Rodux.Store)

-- UI
local UIActions = require(Client.Rodux.Actions.UIActions)
local UIReducer = require(Client.Rodux.Reducers.UIReducer)

-- ZoneController
local ZoneController = Knit.CreateController({
	Name = "ZoneController",
})

function ZoneController:KnitStart()
    local ShopEntries = CollectionService:GetTagged("ShopEntry")
    local ShopEntry = ShopEntries[1].PrimaryPart

    ShopEntry.Touched:Connect(function(hit)
        local player = game.Players.LocalPlayer
        if hit.Parent == player.Character then
            Store:dispatch(UIActions.SetCurrentUI("Shop"))
			Store:dispatch(UIActions.SetCurrentTab("Eggs"))
        end
    end)

    ShopEntry.TouchEnded:Connect(function(hit)
        local player = game.Players.LocalPlayer
        if hit.Parent == player.Character then
            Store:dispatch(UIActions.ResetCurrentUI())
        end
    end)

    print("[Zone Controller] Controller started.")
end

return ZoneController