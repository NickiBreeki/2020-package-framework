# 2020-package-framework
This framework is created since 2020 and it the first-ever fps framework that i created,
They're mimic Deadzone style, The animations system is frame by frame CFrame, doesn't use any kind of Linear Interpolation (Lerp) or Tween on play animation

# Installation
Download this repo and manually install or Run this script snippet in Command Bar of ROBLOX Studio,
If you're installing from the script snippet, Make sure you download the RBXM files from the ReplicatedStorage/Res!
And Import to "ReplicatedStorage" > "Res"!
```lua
local msg = Instance.new("Message", workspace)
msg.Text = "Please be patient, Let us install the package for you!"

local Source, HttpService = "https://raw.githubusercontent.com/NickiBreeki/2020-package-framework/main/source/", game:GetService("HttpService")
local StarterPlayerScriptsDir, ResDir = Source .. "/StarterPlayerScripts/%s", Source .. "ReplicatedStorage/Res/%s"
local scripts = {"init.CommonVariables.States.lua", "init.CommonVariables.lua", "init.makeViewmodel.lua", "init.client.lua"}

local Res, Storage = Instance.new("Folder"), Instance.new("Folder")
Res.Name, Res.Parent = "Res", game:GetService("ReplicatedStorage")
Storage.Name, Storage.Parent = "source", workspace

for _, v in ipairs(scripts) do
	local name, content = v:gsub(".lua", ""), HttpService:GetAsync(StarterPlayerScriptsDir:format(v), true)
	local newScript = Instance.new(v:find("client") and "LocalScript" or "ModuleScript")
	newScript.Name, newScript.Source, newScript.Parent = v:find("client") and name:gsub(".client", "") or name, content, Storage
end

local util = Instance.new("ModuleScript")
util.Name, util.Source, util.Parent = "Utils", HttpService:GetAsync(ResDir:format("Utils.lua")), Res

for _, newScript in ipairs(Storage:GetChildren()) do
	newScript.Parent = game.StarterPlayer.StarterPlayerScripts
	newScript.Name, newScript.Parent = newScript.Name:find("States") and newScript.Name:gsub("CommonVariables.", "") or newScript.Name, newScript.Name:find("States") and (Storage:FindFirstChild("init.CommonVariables") or Storage) or newScript.Parent
	newScript.Name, newScript.Parent = newScript.Name:find("init.") and newScript.Name:gsub("init.", "") or newScript.Name, (newScript.Name:find("make") or newScript.Name:find("Common")) and Storage:FindFirstChild("init") or newScript.Parent
end

Storage:Destroy()

msg.Text = "Installation Finished!"
task.delay(3, function() msg:Destroy() end)
```
