--!strict
local Config = require(game.ReplicatedStorage.Shared.Config)
local Util = require(script.Parent.Util)
local Data = require(script.Parent.DataService)
local CreatureService = {}

function CreatureService.value(creature: any): number
	local base = Config.Rarities[creature.rarity].value
	local mult = 1
	for _, name in ipairs(creature.mutations or {}) do mult *= (Config.Mutations[name] and Config.Mutations[name].multiplier or 1) end
	return math.floor(base * mult * (1 + (creature.generation or 0) * .12))
end
function CreatureService.newFromEgg(eggType: string, weatherMutation: string?): any
	local egg = Config.Eggs[eggType]; local rarity = Util.weighted(egg.odds); local mutations = {}
	for name, info in pairs(Config.Mutations) do if math.random() < info.chance then table.insert(mutations, name) end end
	if weatherMutation and not table.find(mutations, weatherMutation) then table.insert(mutations, weatherMutation) end
	return {id = Util.id(), species = Util.pick(Config.Species[rarity]), rarity = rarity, mutations = mutations, color = Util.pick(Config.Colors), trait = Util.pick(Config.Traits), generation = 0, createdAt = os.time()}
end
function CreatureService.find(player: Player, id: string): any?
	local d = Data.get(player); if not d then return nil end
	for _, creature in ipairs(d.creatures) do if creature.id == id then return creature end end
	return nil
end
function CreatureService.remove(player: Player, id: string): any?
	local d = Data.get(player); if not d then return nil end
	for i, creature in ipairs(d.creatures) do if creature.id == id then table.remove(d.creatures, i); Data.markDirty(player); return creature end end
	return nil
end
function CreatureService.add(player: Player, creature: any): boolean
	local d = Data.get(player); if not d or #d.creatures >= Config.MaxInventory then return false end
	table.insert(d.creatures, creature); d.discovered[creature.species] = true; Data.markDirty(player); return true
end
function CreatureService.breed(player: Player, aId: string, bId: string): (boolean, string?)
	if aId == bId then return false, "Choose two different creatures." end
	local a, b = CreatureService.find(player, aId), CreatureService.find(player, bId)
	if not a or not b then return false, "Creature not found." end
	local cost = math.floor((CreatureService.value(a) + CreatureService.value(b)) * .18); local d = Data.get(player)
	if d.coins < cost then return false, "Not enough Moon Coins." end
	if #d.eggs >= Config.MaxEggs then return false, "Your incubators are full." end
	d.coins -= cost
	table.insert(d.eggs, {id = Util.id(), type = "Dewdrop", readyAt = os.time() + 75, parents = {a.trait, b.trait}, generation = math.max(a.generation or 0, b.generation or 0) + 1})
	d.stats.bred += 1; Data.markDirty(player); return true, "A lineage egg is incubating!"
end
return CreatureService
