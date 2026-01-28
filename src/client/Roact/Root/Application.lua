--[=[
	Owner: CategoryTheory
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directions
local Applications = StarterPlayer.StarterPlayerScripts.Client.Roact.Applications
local Contexts = StarterPlayer.StarterPlayerScripts.Client.Roact.Contexts
local AllowedApplicationsContext = require(Contexts.AllowedApplicationsContext)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local Contexts = StarterPlayer.StarterPlayerScripts.Client.Roact.Contexts
local ContextStack = require(Contexts.ContextStack)

-- Modules
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

local HUD = require(Applications.HUD.Application)
local Shop = require(Applications.Shop.Application)
local Inventory = require(Applications.Inventory.Application)
local Prompt = require(Applications.Prompt.Application)
local Quest = require(Applications.Quest.Application)

--local GlobalHoveredFrame = require(Applications.GlobalHoveredFrame.Application)

local function Root(props, hooks)
	return Roact.createElement(ContextStack, {
		providers = {
			AllowedApplicationsContext.Provider,
		},
	}, Roact.createFragment(props[Roact.Children]))
end
Root = RoactHooks.new(Roact)(Root)

-- Component
local function GameFrame(props)
	return Roact.createElement(Root, {}, {
		GameScreenGui = Roact.createElement("ScreenGui", {
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			ResetOnSpawn = false,
		}, {
			HUD = Roact.createElement(HUD),
			Shop = Roact.createElement(Shop),
			Inventory = Roact.createElement(Inventory),
			Prompt = Roact.createElement(Prompt),
			Quest = Roact.createElement(Quest)
		}),
	})
end

return {
	Game = GameFrame,
}