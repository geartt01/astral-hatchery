--!strict
-- Creates the shared remote container in a way that works both with Rojo and Studio.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = ReplicatedStorage:FindFirstChild("AstralNet") or Instance.new("Folder")
folder.Name = "AstralNet"
folder.Parent = ReplicatedStorage

local Net = {}
function Net.event(name: string): RemoteEvent
	local remote = folder:FindFirstChild(name) or Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote :: RemoteEvent
end
function Net.func(name: string): RemoteFunction
	local remote = folder:FindFirstChild(name) or Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = folder
	return remote :: RemoteFunction
end
return Net
