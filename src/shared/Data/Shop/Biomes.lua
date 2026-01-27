return table.freeze({
	Biome_Forest = {
		Id = "Biome_Forest",
		Name = "Forest",
		Description = "A lush biome filled with trees and wildlife.",
		Image = "rbxassetid://101435195916935",
		LayoutOrder = 1,
		MaxLevel = 3,
		Upgrades = {
			[1] = { Cost = 500, ProductionMultiplier = 1 }, -- First Purchase will use this Cost
			[2] = { Cost = 175, ProductionMultiplier = 1.5 },
			[3] = { Cost = 200, ProductionMultiplier = 3 },
		},
	},
	Biome_Prehistoric = {
		Id = "Biome_Prehistoric",
		Name = "Prehistoric",
		Description = "Step back in time to an era of dinosaurs and ancient flora.",
		Image = "rbxassetid://85850101367340",
		LayoutOrder = 2,
		MaxLevel = 3,
		Upgrades = {
			[1] = { Cost = 750, ProductionMultiplier = 1 }, -- First Purchase will use this Cost
			[2] = { Cost = 200, ProductionMultiplier = 1.5 },
			[3] = { Cost = 225, ProductionMultiplier = 3 },
		},
	},
	Biome_Olympus = {
		Id = "Biome_Olympus",
		Name = "Olympus",
		Description = "A mythical biome inspired by ancient Greek legends.",
		Image = "rbxassetid://76900210326782",
		LayoutOrder = 3,
		MaxLevel = 3,
		Upgrades = {
			[1] = { Cost = 1000, ProductionMultiplier = 1 }, -- First Purchase will use this Cost
			[2] = { Cost = 300, ProductionMultiplier = 1.5 },
			[3] = { Cost = 350, ProductionMultiplier = 3 },
		},
	},
})
