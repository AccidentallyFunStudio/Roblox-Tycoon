-- Game Services
local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local Animals = require(ReplicatedStorage.Shared.Data.Shop.Animals)
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)

-- Components
local AnimalCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.AnimalCard)

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

function AnimalsPanel(props, hooks)
	local data, setData = hooks.useState(nil)
	local dispatch = RoduxHooks.useDispatch(hooks)

	hooks.useEffect(function()
		local DataService = Knit.GetService("DataService")

		-- 1. Initial Fetch
		DataService.GetData():andThen(function(playerData)
			if playerData then
				setData(playerData)
			end
		end)

		-- 2. Listen for Live Updates (Hatching, Upgrading, etc.)
		local connection = DataService.DataChanged:Connect(function(newData)
			-- This updates the local 'data' state, triggering a re-render
			setData(newData)
		end)

		-- 3. Cleanup connection when panel closes
		return function()
			connection:Disconnect()
		end
	end, {})

	-- Loading state while waiting for DataService
	if not data then
		return Roact.createElement("TextLabel", {
			Text = "Loading Animals...",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			TextSize = 24,
		})
	end

	local animalCards = {}
	for _, animal in ipairs(Animals) do
		local amountOwned = (data.Animals and data.Animals[animal.Id]) or 0
		animalCards[animal.Id] = Roact.createElement(AnimalCard, {
			Id = animal.Id,
			Name = animal.Name,
			Price = animal.Price,
			Biome = animal.Biome,
			Image = animal.Image,
			Amount = amountOwned,
			ButtonText = amountOwned > 0 and "Add to Biome" or "Hatch Egg",
			OnButtonClick = function(value)
				if data.Animals[animal.Id] ~= nil then
					-- Store:dispatch(UIActions.ShowNotification(`Adding {animal.Name} to Biome!`))
				else
					-- Store:dispatch(UIActions.ShowNotification("You need to hatch an egg first!"))
					Store:dispatch(UIActions.SetCurrentTab("Eggs"))
				end
			end,
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
		}),

		Items = Roact.createFragment(animalCards),
	})
end

AnimalsPanel = RoactHooks.new(Roact)(AnimalsPanel)
return AnimalsPanel
