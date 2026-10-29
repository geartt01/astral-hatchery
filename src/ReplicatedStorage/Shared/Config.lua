--!strict
local Config = {}

Config.Version = 1
Config.MaxFollowers = 3
Config.MaxInventory = 250
Config.MaxEggs = 18
Config.HatchPollSeconds = 1
Config.SaveInterval = 90
Config.ActionCooldown = 0.18
Config.DailyResetUTC = 24 * 60 * 60

Config.Eggs = {
	Dewdrop = {price = 120, hatchSeconds = 35, tint = Color3.fromRGB(110, 236, 193), odds = {Common = 66, Uncommon = 25, Rare = 8, Epic = 1}},
	Ember = {price = 680, hatchSeconds = 90, tint = Color3.fromRGB(255, 150, 89), odds = {Common = 35, Uncommon = 42, Rare = 18, Epic = 4, Legendary = 1}},
	Nebula = {price = 3200, hatchSeconds = 240, tint = Color3.fromRGB(169, 127, 255), odds = {Uncommon = 42, Rare = 38, Epic = 16, Legendary = 3.5, Mythic = .5}},
}

Config.Rarities = {
	Common = {weight = 1, value = 70, color = Color3.fromRGB(174, 194, 192)},
	Uncommon = {weight = 1.5, value = 180, color = Color3.fromRGB(120, 226, 158)},
	Rare = {weight = 2.8, value = 550, color = Color3.fromRGB(106, 183, 255)},
	Epic = {weight = 5.5, value = 1750, color = Color3.fromRGB(194, 125, 255)},
	Legendary = {weight = 12, value = 7000, color = Color3.fromRGB(255, 191, 88)},
	Mythic = {weight = 35, value = 30000, color = Color3.fromRGB(255, 97, 183)},
}

Config.Species = {
	Common = {"Mossling", "Pebblepup", "Puddlefin"},
	Uncommon = {"Glimmerfox", "Breezebeetle", "Fernhopper"},
	Rare = {"Moonmoth", "Coralynx", "Thunderbun"},
	Epic = {"Aurorowl", "Crystalcap", "Cinderdrake"},
	Legendary = {"Starwhale", "Solstice Stag", "Cloudwyrm"},
	Mythic = {"Celestara"},
}

Config.Mutations = {
	Blooming = {chance = .19, multiplier = 1.25, color = Color3.fromRGB(110, 255, 178)},
	Prismatic = {chance = .035, multiplier = 3.5, color = Color3.fromRGB(255, 112, 230)},
	Starlit = {chance = .075, multiplier = 1.8, color = Color3.fromRGB(156, 186, 255)},
	Gilded = {chance = .015, multiplier = 6, color = Color3.fromRGB(255, 210, 80)},
}

Config.Weather = {
	Clear = {duration = 600, color = Color3.fromRGB(151, 220, 255), hatchMutation = nil},
	MeteorShower = {duration = 180, color = Color3.fromRGB(88, 91, 168), hatchMutation = "Starlit"},
	PetalRain = {duration = 180, color = Color3.fromRGB(255, 178, 223), hatchMutation = "Blooming"},
	SolarFlare = {duration = 120, color = Color3.fromRGB(255, 176, 82), hatchMutation = "Gilded"},
}

Config.Traits = {"Swift", "Cuddly", "Curious", "Brave", "Dreamy", "Mischievous", "Luminous", "Gentle"}
Config.Colors = {"Mint", "Rose", "Ocean", "Honey", "Lilac", "Midnight", "Coral", "Cloud"}
Config.DailyRewards = {150, 250, 400, 600, 900, 1400, 2500}
Config.PrestigeBase = 25000
Config.Badges = {FirstHatch = 0, Collector25 = 0, Prestige = 0} -- Replace IDs before release.
Config.Gamepasses = {Halo = 0, Trail = 0} -- Cosmetic only.
Config.DevProducts = {Confetti = 0, NameSparkle = 0} -- Cosmetic only.

return Config
