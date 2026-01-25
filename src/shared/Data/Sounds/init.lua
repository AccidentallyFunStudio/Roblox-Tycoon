local sounds = {}

for _, soundFile in pairs(script:GetDescendants()) do
    local soundsFile = require(soundFile)
    for key, value in pairs(soundsFile) do
        sounds[key] = value
    end
end

return sounds