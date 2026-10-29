--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local Util = require(script.Parent.Util)

local DataService = {}
-- Unpublished Studio places cannot open DataStores. Keep gameplay testable with
-- temporary session data until the experience is published and API access is enabled.
local opened, openedStore = pcall(function()
	return DataStoreService:GetDataStore("AstralHatchery_v" .. Config.Version)
end)
local store: any = opened and openedStore or nil
if not store then warn("DataStore unavailable: using temporary Studio session data.") end
local profiles: {[Player]: any} = {}
local dirty: {[Player]: boolean} = {}

local function defaultData()
	return {coins = 750, stardust = 0, prestige = 0, eggs = {}, creatures = {}, equipped = {}, discovered = {}, quests = {}, questDay = 0, loginDay = 0, loginStreak = 0, tutorial = 0, cosmetics = {}, stats = {hatched = 0, traded = 0, bred = 0}, lastSave = os.time()}
end
local function sanitize(data: any): any
	if typeof(data) ~= "table" then return defaultData() end
	local out = defaultData()
	for k, v in pairs(data) do if out[k] ~= nil and typeof(v) == typeof(out[k]) then out[k] = v end end
	out.coins = math.clamp(tonumber(out.coins) or 0, 0, 10^12)
	out.stardust = math.clamp(tonumber(out.stardust) or 0, 0, 10^12)
	out.prestige = math.clamp(tonumber(out.prestige) or 0, 0, 10000)
	return out
end
function DataService.load(player: Player)
	if not store then profiles[player] = defaultData(); dirty[player] = false; return profiles[player] end
	local ok, data = pcall(function() return store:GetAsync("p_" .. player.UserId) end)
	profiles[player] = sanitize(ok and data or nil); dirty[player] = false
	return profiles[player]
end
function DataService.get(player: Player): any return profiles[player] end
function DataService.markDirty(player: Player) dirty[player] = true end
function DataService.public(player: Player): any local d = profiles[player]; return d and Util.copy(d) or nil end
function DataService.save(player: Player): boolean
	local data = profiles[player]; if not data then return true end
	if not store then dirty[player] = false; return true end
	data.lastSave = os.time(); local snapshot = Util.copy(data)
	local ok, err = pcall(function() store:UpdateAsync("p_" .. player.UserId, function() return snapshot end) end)
	if ok then dirty[player] = false else warn("Save failed", player.UserId, err) end
	return ok
end
function DataService.remove(player: Player) DataService.save(player); profiles[player] = nil; dirty[player] = nil end
task.spawn(function() while task.wait(Config.SaveInterval) do for player in pairs(dirty) do if dirty[player] then task.spawn(DataService.save, player) end end end end)
game:BindToClose(function() for _, p in Players:GetPlayers() do DataService.save(p) end end)
return DataService
