-- Game Services
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Music = require(ReplicatedStorage.Shared.Data.Sounds.Music)
local Sounds = require(ReplicatedStorage.Shared.Data.Sounds.UI)

local MusicPlayer : Sound = SoundService:FindFirstChild("Music")
local SoundPlayer : Sound = SoundService:FindFirstChild("Sound")

-- AudioController
local AudioController = Knit.CreateController({
	Name = "AudioController",
})

--|| Functions ||--

function AudioController:PlayMusic(name : string)
    if not MusicPlayer then return end

    MusicPlayer.SoundId = Music[name]
    MusicPlayer.TimePosition = 0
    MusicPlayer.Volume = 0.01
    MusicPlayer.Looped = true
    MusicPlayer:Play()
end

function AudioController:PlaySFX(name)
    if not SoundPlayer then return end

    SoundPlayer.Volume = 0.1
    SoundPlayer.TimePosition = 0
    SoundPlayer.Looped = false
    SoundPlayer.SoundId = Sounds[name]

    if not SoundPlayer.Playing then
        SoundPlayer:Play()
    end
end

function AudioController:KnitStart()
    self:PlayMusic("Gameplay")
    print("[Audio Controller] Controller started.")
end

return AudioController