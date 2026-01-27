-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Modules
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Component
local function Message(props, hooks)
	-- 1. Create a state to control visibility
    local visible, setVisible = hooks.useState(true)

    -- 2. Use useEffect to start a timer whenever the message is created
    hooks.useEffect(function()
        -- setVisible(true) ensures it shows up if the component re-renders with new text
        setVisible(true) 

        -- Wait for the "controllable seconds" (defaults to 3 if not provided)
        local displayTime = props.DisplayTime or 3
        local thread = task.delay(displayTime, function()
            setVisible(false)
        end)

        -- Cleanup function to cancel the timer if the component is destroyed early
        return function()
            if thread then task.cancel(thread) end
        end
    end, {props.MessageText}) -- Only restart the timer if the text actually changes

    -- 3. If not visible, return nothing
    if not visible then
        return nil
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.85, 0),
        Size = UDim2.new(0.5, 0, 0.1, 0),
        Style = Enum.FrameStyle.RobloxRound,
    }, {
        MessageTextLabel = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.FredokaOne,
            TextSize = 20,
            Text = props.MessageText, -- Fixed: removed extra curly braces
        })
    })
end

Message = RoactHooks.new(Roact)(Message)
return Message
