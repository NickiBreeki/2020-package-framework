-- // AUTHOR: @NICKIBREEKI

-- // SERVICES
local Players = game:GetService("Players")

-- // LOCALS
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

return function()
	local Data = {}
	Data.Model = nil
	Data.Joints = {}

	local Model = Instance.new("Model", workspace)	
	local RootPart = Instance.new("Part", Model)

	local LeftArm = Instance.new("Part", Model)
	local RightArm = Instance.new("Part", Model)
	
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	
	Model.Name = "_viewmodel"
	
	local Bodyparts = {}
	RootPart.Name = "RootPart"
	LeftArm.Name = "LeftArm"
	RightArm.Name = "RightArm"

	Bodyparts[RootPart.Name] = RootPart
	Bodyparts[LeftArm.Name] = LeftArm
	Bodyparts[RightArm.Name] = RightArm

	RootPart.Transparency = 1
	Model.PrimaryPart = RootPart

	RootPart.Size = Vector3.new(1,1,1)
	LeftArm.Size = Vector3.new(1, 1, 3)
	RightArm.Size = LeftArm.Size	

	for _,v in pairs(Bodyparts) do		
		v.CanCollide = false
		v.Anchored = (v.Name == RootPart.Name)

		v.TopSurface = Enum.SurfaceType.Smooth
		v.BottomSurface = Enum.SurfaceType.Smooth

		if v.Name ~= RootPart.Name then
			local Weld = Instance.new("Weld")
			Weld.Parent = RootPart
			Weld.Name = v.Name

			Weld.Part0 = RootPart
			Weld.Part1 = v

			if v.Name:find("Left") or v.Name:find("Right") then
				local BodyColors = Humanoid:FindFirstChildOfClass("BodyColors")
				if BodyColors then
					v.Color = BodyColors.LeftArmColor3
				end
				v.Transparency = 0.25

				local DefaultCF = Instance.new("CFrameValue", Weld)
				DefaultCF.Name = "DefaultCFrame"
				DefaultCF.Value = CFrame.new((v.Name:find("Left") and -2 or 2), -1, -2)

				Weld.C0 = DefaultCF.Value				
			end

			Data.Joints[Weld.Name] = Weld
		end
	end
	Data.Model = Model
	
	return Data
end