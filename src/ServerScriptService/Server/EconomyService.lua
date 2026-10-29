--!strict
local Config = require(game.ReplicatedStorage.Shared.Config)
local Util = require(script.Parent.Util)
local Data = require(script.Parent.DataService)
local Creatures = require(script.Parent.CreatureService)
local Weather = require(script.Parent.WeatherService)
local Economy = {}
function Economy.buyEgg(player: Player, eggType: string): (boolean, string?)
	local egg = Config.Eggs[eggType]; local d = Data.get(player)
	if not egg or not d then return false, "That egg does not exist." end
	if #d.eggs >= Config.MaxEggs then return false, "All incubators are busy." end
	if d.coins < egg.price then return false, "Not enough Moon Coins." end
	d.coins -= egg.price; table.insert(d.eggs, {id = Util.id(), type = eggType, readyAt = os.time() + egg.hatchSeconds})
	Data.markDirty(player); return true, eggType .. " egg is incubating."
end
function Economy.hatch(player: Player, eggId: string): (boolean, string?, any?)
	local d = Data.get(player); if not d then return false, "Profile unavailable." end
	for i, egg in ipairs(d.eggs) do if egg.id == eggId then
		if os.time() < egg.readyAt then return false, "This egg is still incubating." end
		if #d.creatures >= Config.MaxInventory then return false, "Creature journal is full." end
		local weather = Weather.get(); local creature = Creatures.newFromEgg(egg.type, Config.Weather[weather].hatchMutation)
		if egg.parents then creature.trait = math.random() < .75 and Util.pick(egg.parents) or creature.trait; creature.generation = egg.generation end
		table.remove(d.eggs, i); Creatures.add(player, creature); d.stats.hatched += 1; Data.markDirty(player)
		return true, creature.species .. " joined your hatchery!", creature
	end end
	return false, "Egg not found."
end
function Economy.sell(player: Player, id: string): (boolean, string?)
	local creature = Creatures.find(player, id); if not creature then return false, "Creature not found." end
	local d = Data.get(player); local payout = Creatures.value(creature); Creatures.remove(player, id); d.coins += payout; Data.markDirty(player)
	return true, string.format("Sold for %s Moon Coins.", payout)
end
function Economy.prestige(player: Player): (boolean, string?)
	local d = Data.get(player); local need = Config.PrestigeBase * (d.prestige + 1)
	if d.coins < need then return false, "You need " .. need .. " Moon Coins to attune." end
	d.coins = 750; d.stardust += 1; d.prestige += 1; Data.markDirty(player); return true, "Your hatchery has attuned!"
end
function Economy.claimDaily(player: Player): (boolean, string?)
	local d = Data.get(player); local day = Util.day(); if d.loginDay == day then return false, "Come back tomorrow." end
	d.loginStreak = d.loginDay == day - 1 and math.min(d.loginStreak + 1, 7) or 1; d.loginDay = day
	local reward = Config.DailyRewards[d.loginStreak]; d.coins += reward; Data.markDirty(player); return true, "+" .. reward .. " Moon Coins (day " .. d.loginStreak .. ")"
end
return Economy
