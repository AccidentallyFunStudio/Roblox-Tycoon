local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local QuestActions = {
    SetQuestInfo = Rodux.makeActionCreator("SetQuestInfo", function(text, visible)
        return {
            text = text,
            visible = visible
        }
    end)
}

return QuestActions