-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- UI
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Eggs = require(ReplicatedStorage.Shared.Data.Shop.Eggs)

-- Components
local EggCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.EggCard)

function EggsPanel(props, hooks)
	local EggController = Knit.GetController("EggController")

	local eggList = {}
	for _, egg in pairs(Eggs) do
		table.insert(eggList, egg)
	end

	table.sort(eggList, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local eggsState = RoduxHooks.useSelector(hooks, function(state)
		return state.EggReducer.Eggs
	end)

	local eggCards = {}
	for _, egg in ipairs(eggList) do
		local amountOwned = eggsState[egg.Id] or 0
		local hasEgg = amountOwned > 0

		eggCards[egg.Id] = Roact.createElement(EggCard, {
			Id = egg.Id,
			Name = egg.Name,
			Description = egg.Description,
			Price = egg.Price,
			Image = egg.Image,
			Owned = amountOwned,
			LayoutOrder = egg.LayoutOrder,
			Action = {
				Label = hasEgg and "Hatch" or "Purchase",
				OnClick = function()
					local AudioController = Knit.GetController("AudioController")
					
					if hasEgg then
						EggController:HatchEgg(egg.Id)
						AudioController:PlaySFX("UI_Purchase")

						Knit.GetController("QuestController"):CompleteHatchEgg()
					else
						Store:dispatch(UIActions.SetCurrentUI("Shop"))
						Store:dispatch(UIActions.SetCurrentTab("Eggs"))
						AudioController:PlaySFX("UI_Click")
					end
				end,
			},
		})
	end

	return Roact.createElement("ScrollingFrame", {
		Visible = props.Visible,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarImageTransparency = 0.9,
		BackgroundTransparency = 1,
		BackgroundColor3 = ColorPallete.Shop_Background_White,
		BorderSizePixel = 10,
		BorderColor3 = ColorPallete.Shop_Background_White,
		BorderMode = Enum.BorderMode.Inset,
	}, {
		Grid = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(180, 220),
			CellPadding = UDim2.fromOffset(16, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Items = Roact.createFragment(eggCards),
	})
end

EggsPanel = RoactHooks.new(Roact)(EggsPanel)
return EggsPanel
