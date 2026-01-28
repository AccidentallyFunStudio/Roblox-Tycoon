local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GoldService = Knit.CreateService({
	Name = "GoldService",
	PendingGold = {}, -- [UserId] = number
	Client = {},
})

local AnimalsData = require(ReplicatedStorage.Shared.Data.Shop.Animals)
local DataService
local EnclosureService

function GoldService:CalculateIncome()
	local players = game.Players:GetPlayers()
    if #players == 0 then return end -- No one to process

	for _, player in ipairs(game.Players:GetPlayers()) do
		local data = DataService:GetData(player)
		if not data then
            warn(`[Gold Service] No data found for {player.Name}`)
            continue
        end

		if not data.Placements or #data.Placements == 0 then
            print(`[Gold Service] {player.Name} has no Placements in data.`)
            continue
        end

		local currentTickIncome = 0
        local totalAnimalsFound = 0
        
        -- Iterate through all biomes (placements)
        for _, placement in ipairs(data.Placements) do
            -- DEBUG POINT 3: Check inside specific placement
            if placement.Animals and #placement.Animals > 0 then
                for _, animalId in ipairs(placement.Animals) do
                    totalAnimalsFound += 1
                    local animalInfo = AnimalsData[animalId]
                    
                    if animalInfo then
                        currentTickIncome += animalInfo.GoldProduction
                    else
                        warn(`[Gold Service] {animalId} not found in AnimalsData table!`)
                    end
                end
            end
        end
        
        -- Update the accumulation
        self.PendingGold[player.UserId] = (self.PendingGold[player.UserId] or 0) + currentTickIncome
        
        -- DEBUG POINT 4: Result of calculation
        print(`[Gold Service] {player.Name}: {totalAnimalsFound} animals -> +{currentTickIncome} Gold. Pending: {self.PendingGold[player.UserId]}`)
	end
end

function GoldService:CollectGold(player: Player)
	local amount = self.PendingGold[player.UserId] or 0
	if amount > 0 then
		local data = DataService:GetData(player)
		data.Gold += amount
		self.PendingGold[player.UserId] = 0
		
		Knit.GetService("QuestService"):CompleteCollectGold()

		DataService.Client.DataChanged:Fire(player, data)
		EnclosureService.Client.GoldCollected:Fire(player)
		
		print(`{player.Name} collected {amount} Gold!`)
	end
end

function GoldService:KnitStart()
	DataService = Knit.GetService("DataService")
	EnclosureService = Knit.GetService("EnclosureService")

	-- Income Loop: Every 1 second
	task.spawn(function()
		while true do
			self:CalculateIncome()
			task.wait(1)
		end
	end)

	print("[Gold Service] Service started.")
end

return GoldService