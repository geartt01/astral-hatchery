--!strict
-- No client ever transfers inventory: this holds offers in server memory and verifies ownership at commit.
local Players = game:GetService("Players")
local Data = require(script.Parent.DataService)
local Creatures = require(script.Parent.CreatureService)
local Util = require(script.Parent.Util)
local TradeService = {}; local trades: {[string]: any} = {}; local playerTrade: {[Player]: string} = {}
local function snapshot(t: any) return {id = t.id, a = t.a.Name, b = t.b.Name, aOffer = t.aOffer, bOffer = t.bOffer, aReady = t.aReady, bReady = t.bReady} end
function TradeService.request(a: Player, b: Player): (boolean, string?, any?)
	if a == b or not b.Parent then return false, "Choose another online player." end
	if playerTrade[a] or playerTrade[b] then return false, "One player is already trading." end
	if (a.Character and b.Character and (a.Character:GetPivot().Position - b.Character:GetPivot().Position).Magnitude > 35) then return false, "Move closer to trade." end
	local t = {id = Util.id(), a = a, b = b, aOffer = {}, bOffer = {}, aReady = false, bReady = false, expires = os.clock() + 90}
	trades[t.id] = t; playerTrade[a] = t.id; playerTrade[b] = t.id; return true, "Trade opened.", snapshot(t)
end
function TradeService.get(player: Player): any? local id = playerTrade[player]; return id and trades[id] end
function TradeService.offer(player: Player, creatureId: string): (boolean, string?, any?)
	local t = TradeService.get(player); if not t or os.clock() > t.expires then return false, "Trade expired." end
	local offer = player == t.a and t.aOffer or t.bOffer
	if table.find(offer, creatureId) then table.remove(offer, table.find(offer, creatureId)); t.aReady = false; t.bReady = false; return true, "Removed offer.", snapshot(t) end
	if #offer >= 6 then return false, "Maximum six creatures." end
	if not Creatures.find(player, creatureId) then return false, "You do not own that creature." end
	table.insert(offer, creatureId); t.aReady = false; t.bReady = false; return true, "Added offer.", snapshot(t)
end
local function release(t: any) trades[t.id] = nil; playerTrade[t.a] = nil; playerTrade[t.b] = nil end
function TradeService.confirm(player: Player): (boolean, string?, any?)
	local t = TradeService.get(player); if not t then return false, "No active trade." end
	if player == t.a then t.aReady = true else t.bReady = true end
	if not (t.aReady and t.bReady) then return true, "Waiting for the other player.", snapshot(t) end
	local aData, bData = Data.get(t.a), Data.get(t.b)
	if #aData.creatures - #t.aOffer + #t.bOffer > 250 or #bData.creatures - #t.bOffer + #t.aOffer > 250 then release(t); return false, "A journal is full." end
	for _, id in ipairs(t.aOffer) do if not Creatures.find(t.a, id) then release(t); return false, "Offer changed; trade cancelled." end end
	for _, id in ipairs(t.bOffer) do if not Creatures.find(t.b, id) then release(t); return false, "Offer changed; trade cancelled." end end
	local movedA, movedB = {}, {}; for _, id in ipairs(t.aOffer) do table.insert(movedA, Creatures.remove(t.a, id)) end; for _, id in ipairs(t.bOffer) do table.insert(movedB, Creatures.remove(t.b, id)) end
	for _, c in ipairs(movedA) do Creatures.add(t.b, c) end; for _, c in ipairs(movedB) do Creatures.add(t.a, c) end
	aData.stats.traded += 1; bData.stats.traded += 1; Data.markDirty(t.a); Data.markDirty(t.b)
	local completed = {closed = true, players = {t.a.UserId, t.b.UserId}}; release(t)
	return true, "Trade complete!", completed
end
function TradeService.cancel(player: Player) local t = TradeService.get(player); if t then release(t) end end
Players.PlayerRemoving:Connect(TradeService.cancel)
return TradeService
