# 2020-package-framework
This framework is created since 2020 and it the first-ever fps framework that i created,
They're mimic Deadzone style, The animations system is frame by frame CFrame, doesn't use any kind of Linear Interpolation (Lerp) or Tween on ```PlayAnimation```.
<br>

----	
# DETAILS
**Total line:** 537 Lines (not including whitespace/blank and duplicates)<p>
**Total LocalScripts:** 2,  259 Lines<p>
**Total ModuleScripts** 8, 278 Lines<p>
![image](https://github.com/user-attachments/assets/1259cc23-d30c-41eb-b49a-0afdcd3bf680)

# 🛠 Permission
You're free to use this assets for your own game development!
But you can't claimed this framework as your ownselve or Reupload and claimed it as your own, Please leave my name if you're gonna use for the Commercial Purposes!

# 📦 Package Installation
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
yeah forgot, here, don't waste your time...
just.. take it from here..... :trollface:
https://www.roblox.com/games/5204856478/OLD-OPEN-SOURCE-Package-Framework
