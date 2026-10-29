--!strict
local Lighting = game:GetService("Lighting")
local Config = require(game.ReplicatedStorage.Shared.Config)
local Net = require(game.ReplicatedStorage.Shared.Net)
local WeatherService = {}; local current = "Clear"; local endsAt = 0; local changed = Net.event("WeatherChanged")
function WeatherService.get(): (string, number) return current, endsAt end
local function apply(name: string)
	current = name; endsAt = os.time() + Config.Weather[name].duration
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
	atmosphere.Color = Config.Weather[name].color; atmosphere.Decay = Config.Weather[name].color; atmosphere.Density = .28; atmosphere.Haze = 1.4
	changed:FireAllClients(name, endsAt)
end
function WeatherService.start()
	task.spawn(function()
		while true do
			apply("Clear"); task.wait(Config.Weather.Clear.duration)
			apply(({"MeteorShower", "PetalRain", "SolarFlare"})[math.random(1, 3)]); task.wait(Config.Weather[current].duration)
		end
	end)
end
return WeatherService
