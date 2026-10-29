--!strict
-- Responsive, code-generated UI: no image assets are required for a functional first playtest.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer; local gui = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage.Shared.Config)
local net = ReplicatedStorage:WaitForChild("AstralNet"); local action = net:WaitForChild("Action") :: RemoteEvent; local notice = net:WaitForChild("Notice") :: RemoteEvent; local stateChanged = net:WaitForChild("StateChanged") :: RemoteEvent; local getState = net:WaitForChild("GetState") :: RemoteFunction
local state: any = nil; local tab = "Eggs"; local selected: {string} = {}; local followers: {[string]: BasePart} = {}; local tradeState: any = nil; local tabs = {"Eggs", "Creatures", "Quests", "Collection", "Trade", "Prestige"}
local render: () -> ()

local function ui(class: string, props: {[string]: any}, parent: Instance): Instance
	local obj = Instance.new(class); for k, v in pairs(props) do (obj :: any)[k] = v end; obj.Parent = parent; return obj
end
local function corner(parent: Instance, radius: number) ui("UICorner", {CornerRadius = UDim.new(0, radius)}, parent) end
local function stroke(parent: Instance, color: Color3, transparency: number?) ui("UIStroke", {Color = color, Transparency = transparency or 0.4, Thickness = 1}, parent) end
local function text(parent: Instance, value: string, size: number, color: Color3, bold: boolean?): TextLabel
	return ui("TextLabel", {BackgroundTransparency = 1, Text = value, TextColor3 = color, TextSize = size, Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, parent) :: TextLabel
end
local function button(parent: Instance, value: string, color: Color3): TextButton
	local b = ui("TextButton", {AutoButtonColor = false, BackgroundColor3 = color, Text = value, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14}, parent) :: TextButton; corner(b, 10)
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), .14)}):Play() end); b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = color}):Play() end)
	return b
end
local screen = ui("ScreenGui", {Name = "AstralUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, gui) :: ScreenGui
local scale = ui("UIScale", {Scale = 1}, screen) :: UIScale
local root = ui("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, screen)
local top = ui("Frame", {BackgroundColor3 = Color3.fromRGB(17, 23, 43), Size = UDim2.new(1, -32, 0, 64), Position = UDim2.fromOffset(16, 16)}, root); corner(top, 18); stroke(top, Color3.fromRGB(153, 122, 255), .5)
local title = text(top, "✦  ASTRAL HATCHERY", 20, Color3.fromRGB(235, 231, 255), true); title.Size = UDim2.fromOffset(270, 64); title.Position = UDim2.fromOffset(18, 0)
local weatherText = text(top, "☀ Clear", 14, Color3.fromRGB(172, 215, 255), true); weatherText.Size = UDim2.fromOffset(160, 64); weatherText.Position = UDim2.new(.5, -80, 0, 0); weatherText.TextXAlignment = Enum.TextXAlignment.Center
local balance = text(top, "", 15, Color3.fromRGB(255, 219, 124), true); balance.Size = UDim2.fromOffset(260, 64); balance.AnchorPoint = Vector2.new(1, 0); balance.Position = UDim2.new(1, -16, 0, 0); balance.TextXAlignment = Enum.TextXAlignment.Right
local nav = ui("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(106, 365), Position = UDim2.fromOffset(16, 96)}, root)
local layout = ui("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, nav)
local pane = ui("Frame", {BackgroundColor3 = Color3.fromRGB(18, 24, 45), Size = UDim2.new(1, -154, 1, -112), Position = UDim2.fromOffset(138, 96), ClipsDescendants = true}, root); corner(pane, 18); stroke(pane, Color3.fromRGB(129, 132, 214), .55)
local paneTitle = text(pane, "", 23, Color3.fromRGB(247, 244, 255), true); paneTitle.Size = UDim2.new(1, -40, 0, 42); paneTitle.Position = UDim2.fromOffset(22, 16)
local subtitle = text(pane, "", 13, Color3.fromRGB(166, 178, 210), false); subtitle.Size = UDim2.new(1, -40, 0, 28); subtitle.Position = UDim2.fromOffset(22, 53)
local list = ui("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -38, 1, -102), Position = UDim2.fromOffset(20, 88), CanvasSize = UDim2.new(), ScrollBarThickness = 5, ScrollBarImageColor3 = Color3.fromRGB(138, 112, 245)}, pane)
local grid = ui("UIGridLayout", {CellSize = UDim2.fromOffset(220, 174), CellPadding = UDim2.fromOffset(11, 11), SortOrder = Enum.SortOrder.LayoutOrder}, list) :: UIGridLayout
local toast = ui("TextLabel", {Visible = false, AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -22), Size = UDim2.fromOffset(390, 48), BackgroundColor3 = Color3.fromRGB(50, 58, 100), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, TextWrapped = true, ZIndex = 10}, root) :: TextLabel; corner(toast, 14); stroke(toast, Color3.fromRGB(203, 190, 255), .3)
local tutorial = ui("Frame", {Visible = false, BackgroundColor3 = Color3.fromRGB(14, 19, 37), BackgroundTransparency = .05, Size = UDim2.fromScale(1, 1), ZIndex = 20}, root); local tutorialCard = ui("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(450, 260), BackgroundColor3 = Color3.fromRGB(31, 38, 72), ZIndex = 21}, tutorial); corner(tutorialCard, 22); stroke(tutorialCard, Color3.fromRGB(166, 140, 255), 0)
local tutorialText = text(tutorialCard, "WELCOME, HATCHLING\n\nYour magical eggs become companions over time. Buy an egg from a glowing nest, hatch it here when ready, then equip your favorites to follow you.", 17, Color3.fromRGB(240, 240, 255), true); tutorialText.Size = UDim2.new(1, -54, 0, 175); tutorialText.Position = UDim2.fromOffset(27, 25); tutorialText.ZIndex = 22; tutorialText.TextYAlignment = Enum.TextYAlignment.Top
local tutorialButton = button(tutorialCard, "START EXPLORING", Color3.fromRGB(126, 95, 240)); tutorialButton.Size = UDim2.fromOffset(210, 42); tutorialButton.Position = UDim2.new(.5, -105, 1, -63); tutorialButton.ZIndex = 22
local function fitToScreen()
	local camera = workspace.CurrentCamera; if not camera then return end
	-- The desktop composition is 900px wide; scaling preserves every action on portrait phones.
	scale.Scale = math.clamp(camera.ViewportSize.X / 900, .38, 1)
end
fitToScreen(); workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitToScreen)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen) end

local function fire(name: string, payload: any?) action:FireServer(name, payload) end
local function clear()
	for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
end
local function card(titleValue: string, body: string, tint: Color3): Frame
	local f = ui("Frame", {BackgroundColor3 = Color3.fromRGB(31, 38, 69), Size = UDim2.fromOffset(220, 174)}, list) :: Frame; corner(f, 14); stroke(f, tint, .28)
	local bar = ui("Frame", {BackgroundColor3 = tint, Size = UDim2.new(1, 0, 0, 5)}, f); corner(bar, 14)
	local heading = text(f, titleValue, 16, Color3.fromRGB(248, 247, 255), true); heading.Size = UDim2.new(1, -22, 0, 34); heading.Position = UDim2.fromOffset(12, 15)
	local desc = text(f, body, 12, Color3.fromRGB(181, 191, 219), false); desc.Size = UDim2.new(1, -24, 0, 66); desc.Position = UDim2.fromOffset(12, 50); desc.TextYAlignment = Enum.TextYAlignment.Top
	return f
end
local function cardButton(parent: Frame, caption: string, color: Color3): TextButton local b = button(parent, caption, color); b.Size = UDim2.new(1, -24, 0, 33); b.Position = UDim2.new(0, 12, 1, -43); return b end
local function mutationText(c: any): string return #c.mutations > 0 and table.concat(c.mutations, " · ") or "Pure lineage" end
local function creatureTint(c: any): Color3 return Config.Rarities[c.rarity].color end
local function creatureCard(c: any, mode: string?)
	local f = card(c.species .. "  [" .. c.rarity .. "]", c.color .. " · " .. c.trait .. "\n" .. mutationText(c) .. "\nValue: " .. tostring(math.floor(Config.Rarities[c.rarity].value * (1 + (c.generation or 0) * .12))), creatureTint(c))
	local active = table.find(selected, c.id) ~= nil; local caption = mode or (active and "SELECTED" or "SELECT")
	local b = cardButton(f, caption, active and Color3.fromRGB(84, 193, 152) or Color3.fromRGB(92, 103, 175))
	b.Activated:Connect(function()
		if mode == "SELL" then fire("Sell", c.id); return end
		if mode == "OFFER" then fire("TradeOffer", c.id); return end
		local index = table.find(selected, c.id); if index then table.remove(selected, index) elseif #selected < 2 then table.insert(selected, c.id) end; task.defer(function() tab = "Creatures"; end)
		render()
	end)
end
render = function()
	if not state then return end; clear(); selected = selected or {}
	balance.Text = string.format("☾ %s    ✧ %s    ⟡ P%d", state.coins or 0, state.stardust or 0, state.prestige or 0)
	if tab == "Eggs" then
		paneTitle.Text = "Incubator"; subtitle.Text = "Eggs continue hatching even while you are away."
		for _, egg in ipairs(state.eggs or {}) do local remaining = math.max(0, egg.readyAt - os.time()); local f = card(egg.type .. " Egg", remaining == 0 and "It is shimmering with energy!" or "Ready in " .. string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60), Config.Eggs[egg.type].tint); local b = cardButton(f, remaining == 0 and "HATCH" or "INCUBATING", remaining == 0 and Color3.fromRGB(101, 192, 141) or Color3.fromRGB(72, 78, 120)); if remaining == 0 then b.Activated:Connect(function() fire("Hatch", egg.id) end) else b.Active = false end end
		for eggType, info in pairs(Config.Eggs) do local f = card(eggType .. " Egg", "Buy at a nest or here.\nHatches in " .. info.hatchSeconds .. " seconds.", info.tint); cardButton(f, "BUY • " .. info.price, Color3.fromRGB(106, 90, 211)).Activated:Connect(function() fire("BuyEgg", eggType) end) end
	elseif tab == "Creatures" then
		paneTitle.Text = "Creature Journal"; subtitle.Text = "Select up to two for breeding. Equipped: " .. #(state.equipped or {}) .. "/" .. Config.MaxFollowers
		local controls = card("Lineage Lab", #selected == 2 and "Selected pair is ready to breed." or "Select two creatures, then create a lineage egg.", Color3.fromRGB(190, 133, 255)); cardButton(controls, #selected == 2 and "BREED SELECTED" or "SELECT 2 CREATURES", Color3.fromRGB(155, 102, 235)).Activated:Connect(function() if #selected == 2 then fire("Breed", selected); selected = {}; render() end end)
		local equip = card("Follower Circle", "Choose up to three selected companions to orbit you.", Color3.fromRGB(102, 205, 207)); cardButton(equip, "EQUIP SELECTED", Color3.fromRGB(70, 164, 174)).Activated:Connect(function() fire("Equip", selected); selected = {}; render() end)
		for _, c in ipairs(state.creatures or {}) do creatureCard(c) end
	elseif tab == "Quests" then
		paneTitle.Text = "Daily Constellations"; subtitle.Text = "New quests arrive every UTC day."
		for _, q in ipairs(state.quests or {}) do local f = card(q.label, string.format("%d / %d completed\nReward: %d Moon Coins", q.progress, q.target, q.reward), Color3.fromRGB(255, 190, 102)); local b = cardButton(f, q.claimed and "CLAIMED" or (q.progress >= q.target and "CLAIM REWARD" or "IN PROGRESS"), q.progress >= q.target and not q.claimed and Color3.fromRGB(89, 183, 137) or Color3.fromRGB(75, 78, 120)); if q.progress >= q.target and not q.claimed then b.Activated:Connect(function() fire("Quest", q.id) end) else b.Active = false end end
		local d = card("Daily Login", "Current streak: " .. (state.loginStreak or 0) .. "/7\nClaim a Moon Coin gift once per day.", Color3.fromRGB(129, 184, 255)); cardButton(d, "CLAIM DAILY", Color3.fromRGB(85, 126, 220)).Activated:Connect(function() fire("Daily") end)
	elseif tab == "Collection" then
		paneTitle.Text = "Collection Book"; subtitle.Text = "Discover each species to illuminate its constellation."
		for rarity, speciesList in pairs(Config.Species) do for _, species in ipairs(speciesList) do local found = state.discovered and state.discovered[species]; card(found and species or "???", found and (rarity .. " discovered") or (rarity .. " silhouette"), Config.Rarities[rarity].color) end end
	elseif tab == "Trade" then
		paneTitle.Text = "Trade Circle"; subtitle.Text = "Trade only nearby players. Offers are validated by the server."
		if tradeState and not tradeState.closed then
			local ownOffer = tradeState.a == player.Name and tradeState.aOffer or tradeState.bOffer; local otherOffer = tradeState.a == player.Name and tradeState.bOffer or tradeState.aOffer
			local status = card("Trading with " .. (tradeState.a == player.Name and tradeState.b or tradeState.a), "Your offer: " .. #ownOffer .. " companion(s)\nTheir offer: " .. #otherOffer .. " companion(s)", Color3.fromRGB(244, 180, 106)); cardButton(status, "CONFIRM TRADE", Color3.fromRGB(80, 180, 128)).Activated:Connect(function() fire("TradeConfirm") end)
			local cancel = card("Secure trade", "Offers reset confirmation whenever an item changes.", Color3.fromRGB(158, 119, 92)); cardButton(cancel, "CANCEL TRADE", Color3.fromRGB(156, 77, 82)).Activated:Connect(function() tradeState = nil; fire("TradeCancel"); render() end)
			for _, c in ipairs(state.creatures or {}) do creatureCard(c, "OFFER") end
		else
			for _, other in ipairs(Players:GetPlayers()) do if other ~= player then local f = card(other.DisplayName, "Request a creature trade. Both players must confirm.", Color3.fromRGB(244, 180, 106)); cardButton(f, "REQUEST TRADE", Color3.fromRGB(207, 132, 66)).Activated:Connect(function() fire("TradeRequest", other.Name) end) end end
			if #Players:GetPlayers() == 1 then card("No traders nearby", "Invite a friend into the server to trade companions.", Color3.fromRGB(114, 130, 180)) end
		end
	elseif tab == "Prestige" then
		paneTitle.Text = "Astral Attunement"; local need = Config.PrestigeBase * ((state.prestige or 0) + 1); subtitle.Text = "Reset Moon Coins to 750 and earn a permanent Stardust rank."
		local f = card("Prestige " .. ((state.prestige or 0) + 1), "Cost: " .. need .. " Moon Coins\nStardust: " .. (state.stardust or 0), Color3.fromRGB(255, 150, 225)); cardButton(f, "ATTUNE HATCHERY", Color3.fromRGB(212, 92, 167)).Activated:Connect(function() fire("Prestige") end)
	end
	grid.CellSize = UDim2.fromOffset(math.max(190, math.min(245, math.floor((list.AbsoluteSize.X - 22) / math.max(1, math.floor(list.AbsoluteSize.X / 231))))), 174)
	task.defer(function() list.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 12) end)
end
for _, name in ipairs(tabs) do local b = button(nav, name, Color3.fromRGB(38, 47, 84)); b.Size = UDim2.fromOffset(106, 53); b.Activated:Connect(function() tab = name; selected = {}; render() end) end
tutorialButton.Activated:Connect(function() tutorial.Visible = false; fire("TutorialDone") end)
local toastId = 0
notice.OnClientEvent:Connect(function(message: string, good: boolean) toastId += 1; local id = toastId; toast.Text = message; toast.BackgroundColor3 = good and Color3.fromRGB(52, 115, 91) or Color3.fromRGB(148, 72, 83); toast.Visible = true; toast.TextTransparency = 1; TweenService:Create(toast, TweenInfo.new(.2), {TextTransparency = 0}):Play(); task.delay(3, function() if id == toastId then toast.Visible = false end end) end)
stateChanged.OnClientEvent:Connect(function(newState: any, newTradeState: any) if newState then state = newState end; if newTradeState then tradeState = newTradeState.closed and nil or newTradeState end; render() end)
net:WaitForChild("WeatherChanged").OnClientEvent:Connect(function(name: string) weatherText.Text = "✦ " .. name end)
local function makeFollower(c: any): BasePart
	local p = Instance.new("Part"); p.Name = "LocalFollower_" .. c.id; p.Shape = Enum.PartType.Ball; p.Size = Vector3.new(2.2, 2.2, 2.2); p.Anchored = true; p.CanCollide = false; p.CastShadow = false; p.Material = Enum.Material.Neon; p.Color = creatureTint(c); p.Parent = workspace
	local light = Instance.new("PointLight", p); light.Color = p.Color; light.Range = 7; light.Brightness = 1
	return p
end
RunService.RenderStepped:Connect(function()
	if not state then return end; local wanted = {}; for _, id in ipairs(state.equipped or {}) do wanted[id] = true end
	for id, part in pairs(followers) do if not wanted[id] then part:Destroy(); followers[id] = nil end end
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?; if not rootPart then return end
	for i, id in ipairs(state.equipped or {}) do
		if not followers[id] then for _, c in ipairs(state.creatures or {}) do if c.id == id then followers[id] = makeFollower(c) end end end
		local p = followers[id]; if p then local theta = os.clock() * 1.7 + i * math.pi * 2 / math.max(1, #(state.equipped or {})); local target = rootPart.Position + Vector3.new(math.cos(theta) * 4, 2 + math.sin(os.clock() * 2 + i) * .4, math.sin(theta) * 4); p.CFrame = p.CFrame:Lerp(CFrame.new(target), .12) end
	end
end)
task.spawn(function() while not state do local ok, result = pcall(function() return getState:InvokeServer() end); if ok and result then state = result; render(); if state.tutorial == 0 then tutorial.Visible = true end else task.wait(1) end end end)
task.spawn(function() while task.wait(1) do if tab == "Eggs" then render() end end end)
