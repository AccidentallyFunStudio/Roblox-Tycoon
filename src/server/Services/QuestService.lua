-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit Services
local DataService

local QuestService = Knit.CreateService({
	Name = "QuestService",
	Client = {},
})

--|| Functions ||--

-- Function to test that Player has data
function QuestService:VerifyTutorialStep(player: Player)
    local data = DataService:GetData(player)
    if not data then return end

    print(`[Quest Service] Player {player.Name} CurrentStep is {data.Tutorial.CurrentStep}`)
end

-- Increment tutorial step here
function QuestService:UpdateTutorialStep(player : Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data.Tutorial.CurrentStep < #data.Tutorial.Steps then
        data.Tutorial.CurrentStep += 1

        if data.Tutorial.CurrentStep == #data.Tutorial.Steps then
            -- Check logic for the final step here
        end

        -- Sync the data back to client
        DataService:UpdatePlayerData(player, data)
        print(`[Quest Service] {player.Name} moved to Step {data.Tutorial.CurrentStep}`)
    end
end

-- Mark Visit the Shop Tutorial as Complete
function QuestService:CompleteVisitShop(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 1 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

-- Mark Purchase a Biome Tutorial as Complete
function QuestService:CompletePurchaseBiome(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 2 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompleteGoToZoo(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 3 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompletePlaceBiome(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 4 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompleteHatchEgg(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 5 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompletePlaceAnimal(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 6 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompleteCollectGold(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 7 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompleteUpgradeBiome(player: Player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial and data.Tutorial.CurrentStep == 8 then
        data.Tutorial.CurrentStep += 1
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Next quest for Player {player} is {data.Tutorial[data.Tutorial.CurrentStep]}`)
    end
end

function QuestService:CompleteTutorial(player)
    local data = DataService:GetData(player)
    if not data then
        warn(`[Quest Service] Unable to load data for Player {player}`)
    end

    if data and data.Tutorial then
        data.Tutorial.Completed = true
        DataService.Client.DataChanged:Fire(player, data)

        print(`[Quest Service] Player {player} has completed tutorial {data.Tutorial.Completed}`)
    end
end

--|| Client Functions ||--

function QuestService.Client:VerifyTutorialStep(player: Player)
	return self.Server:VerifyTutorialStep(player)
end

function QuestService.Client:UpdateTutorialStep(player: Player)
    return self.Server:UpdateTutorialStep(player)
end

function QuestService.Client:CompleteVisitShop(player: Player)
    return self.Server:CompleteVisitShop(player)
end

function QuestService.Client:CompletePurchaseBiome(player: Player)
    return self.Server:CompletePurchaseBiome(player)
end

function QuestService.Client:CompleteGoToZoo(player: Player)
    return self.Server:CompleteGoToZoo(player)
end

function QuestService.Client:CompletePlaceBiome(player: Player)
    return self.Server:CompletePlaceBiome(player)
end

function QuestService.Client:CompleteHatchEgg(player: Player)
    return self.Server:CompleteHatchEgg(player)
end

function QuestService.Client:CompletePlaceAnimal(player: Player)
    return self.Server:CompletePlaceAnimal(player)
end

function QuestService.Client:CompleteCollectGold(player: Player)
    return self.Server:CompleteCollectGold(player)
end

function QuestService.Client:CompleteUpgradeBiome(player: Player)
    return self.Server:CompleteUpgradeBiome(player)
end

function QuestService.Client:CompleteTutorial(player: Player)
    return self.Server:CompleteTutorial(player)
end

--|| Knit Lifecycle ||--

function QuestService:KnitStart()
	DataService = Knit.GetService("DataService")

	print("[Quest Service] Service started.")
end

return QuestService