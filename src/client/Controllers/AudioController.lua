-- Game Services
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local MusicPlayer : Sound = SoundService:FindFirstChild("Music")
local Music = require(ReplicatedStorage.Shared.Data.Sounds.Music)

-- AudioController
local AudioController = Knit.CreateController({
	Name = "AudioController",
})

--|| Functions ||--

function AudioController:PlayMusic(name : string)
    if not MusicPlayer then return end

    MusicPlayer.SoundId = Music[name]
    MusicPlayer.TimePosition = 0
    MusicPlayer.Volume = 0.25
    MusicPlayer.Looped = true
    MusicPlayer:Play()
end

function AudioController:KnitStart()
    -- self:PlayMusic("Gameplay")
    print("[Audio Controller] Controller started.")
end

return AudioController