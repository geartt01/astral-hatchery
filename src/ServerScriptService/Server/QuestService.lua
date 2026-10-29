--!strict
local Util = require(script.Parent.Util)
local Data = require(script.Parent.DataService)
local QuestService = {}
local templates = {{id = "hatch", label = "Hatch 3 creatures", target = 3, reward = 250}, {id = "sell", label = "Sell 2 creatures", target = 2, reward = 180}, {id = "breed", label = "Breed a lineage egg", target = 1, reward = 320}}
function QuestService.ensure(player: Player)
	local d = Data.get(player); local today = Util.day(); if d.questDay == today then return end
	d.questDay = today; d.quests = {}
	for _, t in ipairs(templates) do table.insert(d.quests, {id = t.id, label = t.label, target = t.target, reward = t.reward, progress = 0, claimed = false}) end
	Data.markDirty(player)
end
function QuestService.progress(player: Player, id: string)
	QuestService.ensure(player); local d = Data.get(player)
	for _, q in ipairs(d.quests) do if q.id == id and not q.claimed then q.progress = math.min(q.target, q.progress + 1); Data.markDirty(player) end end
end
function QuestService.claim(player: Player, id: string): (boolean, string?)
	local d = Data.get(player); QuestService.ensure(player)
	for _, q in ipairs(d.quests) do if q.id == id then
		if q.claimed or q.progress < q.target then return false, "Quest is not complete." end
		q.claimed = true; d.coins += q.reward; Data.markDirty(player); return true, "+" .. q.reward .. " Moon Coins"
	end end
	return false, "Quest not found."
end
return QuestService
