--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
-- The Server folder is a sibling of this Script under ServerScriptService.
local Server = script.Parent:WaitForChild("Server")
local Data = require(Server.DataService)
local Economy = require(Server.EconomyService)
local Creatures = require(Server.CreatureService)
local Quests = require(Server.QuestService)
local Trades = require(Server.TradeService)
local Weather = require(Server.WeatherService)
local Util = require(Server.Util)

local action = Net.event("Action"); local stateChanged = Net.event("StateChanged"); local notice = Net.event("Notice")
local getState = Net.func("GetState"); local throttles: {[Player]: number} = {}
local leaderboardDirty = true

local function push(player: Player, text: string, good: boolean?) notice:FireClient(player, text, good ~= false) end
local function sync(player: Player)
	local d = Data.get(player); if not d then return end
	local ls = player:FindFirstChild("leaderstats"); if ls then (ls.Coins :: IntValue).Value = d.coins; (ls.Prestige :: IntValue).Value = d.prestige end
	stateChanged:FireClient(player, Data.public(player))
	leaderboardDirty = true
end
local function award(player: Player, badgeId: number)
	if badgeId <= 0 then return end
	task.spawn(function() pcall(function() if not BadgeService:UserHasBadgeAsync(player.UserId, badgeId) then BadgeService:AwardBadge(player.UserId, badgeId) end end) end)
end
getState.OnServerInvoke = function(player) return Data.public(player) end

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part"); p.Name = name; p.Anchored = true; p.CanCollide = true; p.Size = size; p.Position = pos; p.Color = color; p.Material = material; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth; p.Parent = parent; return p
end
local function label(parent: Instance, text: string, offset: Vector3)
	local gui = Instance.new("BillboardGui"); gui.Size = UDim2.fromOffset(220, 55); gui.StudsOffset = offset; gui.AlwaysOnTop = true; gui.Parent = parent
	local l = Instance.new("TextLabel"); l.Size = UDim2.fromScale(1, 1); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Color3.new(1, 1, 1); l.TextStrokeTransparency = .45; l.Font = Enum.Font.GothamBold; l.TextSize = 17; l.Parent = gui
end
local function buildWorld()
	if workspace:FindFirstChild("AstralHatcheryWorld") then return end
	workspace.FallenPartsDestroyHeight = -80; local world = Instance.new("Folder", workspace); world.Name = "AstralHatcheryWorld"
	part(world, "Meadow", Vector3.new(420, 3, 420), Vector3.new(0, -2, 0), Color3.fromRGB(68, 132, 94), Enum.Material.Grass)
	part(world, "Plaza", Vector3.new(85, 2, 85), Vector3.new(0, 0, 0), Color3.fromRGB(210, 224, 255), Enum.Material.Slate)
	for i = 1, 22 do
		local theta = i / 22 * math.pi * 2; local r = 76 + (i % 3) * 22; local x, z = math.cos(theta) * r, math.sin(theta) * r
		local trunk = part(world, "MoonTree", Vector3.new(3, 18 + i % 4 * 3, 3), Vector3.new(x, 8, z), Color3.fromRGB(71, 69, 100), Enum.Material.Wood)
		local crown = part(world, "GlowBloom", Vector3.new(15, 10, 15), Vector3.new(x, 21 + i % 4 * 3, z), Color3.fromRGB(122, 213, 176), Enum.Material.Neon); crown.Shape = Enum.PartType.Ball
	end
	local spawn = Instance.new("SpawnLocation", world); spawn.Name = "ArrivalPortal"; spawn.Size = Vector3.new(12, 1, 12); spawn.Position = Vector3.new(0, 2, 0); spawn.Neutral = true; spawn.Color = Color3.fromRGB(150, 109, 255); spawn.Material = Enum.Material.Neon
	label(spawn, "✦ ASTRAL HATCHERY ✦", Vector3.new(0, 5, 0))
	local stationInfo = {{"Dewdrop", Vector3.new(-24, 4, -10)}, {"Ember", Vector3.new(0, 4, -25)}, {"Nebula", Vector3.new(24, 4, -10)}}
	for _, info in ipairs(stationInfo) do
		local name, pos = info[1], info[2]; local egg = Config.Eggs[name]; local stand = part(world, name .. "Nest", Vector3.new(10, 7, 10), pos, Color3.fromRGB(44, 55, 80), Enum.Material.Slate)
		local orb = part(world, name .. "Egg", Vector3.new(5, 6, 5), pos + Vector3.new(0, 6, 0), egg.tint, Enum.Material.Neon); orb.Shape = Enum.PartType.Ball
		local emitter = Instance.new("ParticleEmitter", orb); emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"; emitter.Rate = 8; emitter.Lifetime = NumberRange.new(.6, 1.1); emitter.Speed = NumberRange.new(1, 2); emitter.Color = ColorSequence.new(egg.tint); emitter.LightEmission = .8
		label(orb, name .. " Egg\n" .. egg.price .. " Moon Coins", Vector3.new(0, 5, 0))
		local prompt = Instance.new("ProximityPrompt", orb); prompt.ActionText = "Incubate"; prompt.ObjectText = name .. " Egg"; prompt.HoldDuration = .25; prompt.MaxActivationDistance = 12
		prompt.Triggered:Connect(function(player) local ok, msg = Economy.buyEgg(player, name); push(player, msg or "", ok); sync(player) end)
		TweenService:Create(orb, TweenInfo.new(1.8 + math.random(), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = orb.Position + Vector3.new(0, 1.5, 0)}):Play()
	end
	local board = part(world, "QuestConstellation", Vector3.new(18, 12, 2), Vector3.new(-42, 7, 22), Color3.fromRGB(47, 50, 94), Enum.Material.Neon); label(board, "DAILY CONSTELLATIONS\nOpen Quests from the menu", Vector3.new(0, 4, 0))
	local trade = part(world, "TradeMoon", Vector3.new(12, 1, 12), Vector3.new(42, 1, 22), Color3.fromRGB(255, 190, 94), Enum.Material.Neon); label(trade, "TRADE CIRCLE\nStand near a player, then use Trade", Vector3.new(0, 4, 0))
	local light = Instance.new("PointLight", spawn); light.Range = 30; light.Brightness = 3; light.Color = Color3.fromRGB(177, 145, 255)
end
buildWorld(); Weather.start()

local function setEquipped(player: Player, ids: any): (boolean, string?)
	if typeof(ids) ~= "table" or #ids > Config.MaxFollowers then return false, "Invalid companion selection." end
	local seen = {}; for _, id in ipairs(ids) do if typeof(id) ~= "string" or seen[id] or not Creatures.find(player, id) then return false, "Invalid creature." end; seen[id] = true end
	Data.get(player).equipped = ids; Data.markDirty(player); return true, "Companions updated."
end
local function handle(player: Player, name: any, payload: any)
	if typeof(name) ~= "string" then return end
	local now = os.clock(); if (throttles[player] or 0) + Config.ActionCooldown > now then return end; throttles[player] = now
	local ok, msg, extra = false, "Unknown action."
	if name == "BuyEgg" then ok, msg = Economy.buyEgg(player, Util.clampString(payload, 16) or "")
	elseif name == "Hatch" then ok, msg, extra = Economy.hatch(player, Util.clampString(payload, 64) or ""); if ok then Quests.progress(player, "hatch"); award(player, Config.Badges.FirstHatch); local d = Data.get(player); if d.stats.hatched >= 25 then award(player, Config.Badges.Collector25) end; end
	elseif name == "Sell" then ok, msg = Economy.sell(player, Util.clampString(payload, 64) or ""); if ok then Quests.progress(player, "sell") end
	elseif name == "Breed" and typeof(payload) == "table" then ok, msg = Creatures.breed(player, Util.clampString(payload[1], 64) or "", Util.clampString(payload[2], 64) or ""); if ok then Quests.progress(player, "breed") end
	elseif name == "Equip" then ok, msg = setEquipped(player, payload)
	elseif name == "Daily" then ok, msg = Economy.claimDaily(player)
	elseif name == "Quest" then ok, msg = Quests.claim(player, Util.clampString(payload, 32) or "")
	elseif name == "Prestige" then ok, msg = Economy.prestige(player); if ok then award(player, Config.Badges.Prestige) end
	elseif name == "TutorialDone" then local d = Data.get(player); d.tutorial = 1; Data.markDirty(player); ok, msg = true, "Welcome to the Hatchery!"
	elseif name == "TradeRequest" then
		local target = Players:FindFirstChild(Util.clampString(payload, 20) or "")
		if target then ok, msg, extra = Trades.request(player, target) else ok, msg = false, "Player unavailable." end
	elseif name == "TradeOffer" then ok, msg, extra = Trades.offer(player, Util.clampString(payload, 64) or "")
	elseif name == "TradeConfirm" then ok, msg, extra = Trades.confirm(player)
	elseif name == "TradeCancel" then Trades.cancel(player); ok, msg = true, "Trade cancelled."
	end
	push(player, msg or "", ok); sync(player)
	if extra then
		if extra.closed and extra.players then
			for _, userId in ipairs(extra.players) do local participant = Players:GetPlayerByUserId(userId); if participant then sync(participant); stateChanged:FireClient(participant, Data.public(participant), extra); push(participant, "Trade complete!", true) end end
		else
			local trade = Trades.get(player)
			if trade then stateChanged:FireClient(trade.a, Data.public(trade.a), extra); stateChanged:FireClient(trade.b, Data.public(trade.b), extra) else stateChanged:FireClient(player, Data.public(player), extra) end
		end
	end
end
action.OnServerEvent:Connect(handle)

Players.PlayerAdded:Connect(function(player)
	Data.load(player); Quests.ensure(player)
	local stats = Instance.new("Folder", player); stats.Name = "leaderstats"; local coins = Instance.new("IntValue", stats); coins.Name = "Coins"; local prestige = Instance.new("IntValue", stats); prestige.Name = "Prestige"; sync(player)
	task.delay(2, function() if player.Parent then sync(player) end end)
	for cosmetic, passId in pairs(Config.Gamepasses) do if passId > 0 then task.spawn(function() local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, passId); if ok and owns then Data.get(player).cosmetics[cosmetic] = true; sync(player) end end) end end
end)
Players.PlayerRemoving:Connect(function(player) throttles[player] = nil; Data.remove(player) end)
MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId); if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	for cosmetic, productId in pairs(Config.DevProducts) do if productId > 0 and productId == receipt.ProductId then Data.get(player).cosmetics[cosmetic] = true; Data.markDirty(player); sync(player); return Enum.ProductPurchaseDecision.PurchaseGranted end end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
