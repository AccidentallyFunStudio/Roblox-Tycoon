local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local UserInputController = Knit.CreateController({
    Name = "UserInputController"
})

function UserInputController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.P then
            local DataService = Knit.GetService("DataService")
            local success, data = DataService.GetData():await()
            
            print(data)
        end 
    end)
end

return UserInputController