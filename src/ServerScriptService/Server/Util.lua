--!strict
local HttpService = game:GetService("HttpService")
local Util = {}
function Util.id(): string return HttpService:GenerateGUID(false) end
function Util.day(): number return math.floor(os.time() / 86400) end
function Util.pick<T>(list: {T}): T return list[math.random(1, #list)] end
function Util.clampString(value: any, max: number): string? if typeof(value) ~= "string" or #value > max then return nil end return value end
function Util.copy<T>(value: T): T
	if typeof(value) ~= "table" then return value end
	local result = {}
	for k, v in pairs(value :: any) do (result :: any)[k] = Util.copy(v) end
	return result :: any
end
function Util.weighted(weights: {[string]: number}): string
	local total = 0; for _, n in pairs(weights) do total += n end
	local roll = math.random() * total; local sum = 0
	for key, n in pairs(weights) do sum += n; if roll <= sum then return key end end
	return next(weights) :: string
end
return Util
