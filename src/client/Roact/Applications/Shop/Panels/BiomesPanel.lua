-- Game Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- Data
local ColorPallete = require(ReplicatedStorage.Shared.Data.ColorPallete)
local Biomes = require(ReplicatedStorage.Shared.Data.Shop.Biomes)

-- Components
local BiomeCard = require(StarterPlayerScripts.Client.Roact.Components.Cards.BiomeCard)

function BiomesPanel(props, hooks)
	local data, setData = hooks.useState(nil)
	local dispatch = RoduxHooks.useDispatch(hooks)

	hooks.useEffect(function()
		local DataService = Knit.GetService("DataService")

		-- Initial fetch
		DataService.GetData():andThen(function(playerData)
			if playerData then
				setData(playerData)
			end
		end)

		-- Listen for real time updates
		local connection = DataService.DataChanged:Connect(function(newData)
			setData(newData) -- This triggers the Roact re-render
		end)

		return function()
			connection:Disconnect() -- Cleanup
		end
	end, {})

	-- Loading state while waiting for DataService
	if not data then
		return Roact.createElement("TextLabel", {
			Text = "Loading Biomes...",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			TextSize = 24,
		})
	end

	local biomeList = {}
	for _, biome in pairs(Biomes) do
		table.insert(biomeList, biome)
	end

	table.sort(biomeList, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local biomeCards = {}
	for _, biome in ipairs(biomeList) do
		local biomeState = data and data.Biomes and data.Biomes[biome.Id]
		local currentLevel = biomeState and biomeState.Level or 0
		local isMaxed = currentLevel >= biome.MaxLevel

		local buttonText = "Purchase"
		local subtext = `Price: {biome.Upgrades[1].Cost} Gold`
		local canClick = true -- Default state

		if currentLevel > 0 then
			if isMaxed then
				buttonText = "Maxed"
				subtext = "Level: MAX"
				canClick = false -- Disable clicking when maxed
			else
				local nextLevel = currentLevel + 1
				buttonText = "Upgrade"
				subtext = `Cost: {biome.Upgrades[nextLevel].Cost} Gold`
				canClick = true
			end
		end

		biomeCards[biome.Id] = Roact.createElement(BiomeCard, {
			Name = biome.Name,
			Image = biome.Image,
			LayoutOrder = biome.LayoutOrder,
			ButtonText = buttonText,
			Subtext = subtext,
			ShowSubtext = true,
			ButtonClickable = canClick, -- Passes the disabled state to the component
			OnButtonClick = function()
				-- Only execute if the button is not maxed/clickable
				if not canClick or isMaxed then
					return
				end

				if currentLevel == 0 then
					Knit.GetService("BiomeService"):PurchaseBiome(biome.Id)
				elseif not isMaxed then
					Knit.GetService("BiomeService"):UpgradeBiome(biome.Id)
				end

				Knit.GetController("AudioController"):PlaySFX("UI_Purchase")
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
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Items = Roact.createFragment(biomeCards),
	})
end

BiomesPanel = RoactHooks.new(Roact)(BiomesPanel)
return BiomesPanel
