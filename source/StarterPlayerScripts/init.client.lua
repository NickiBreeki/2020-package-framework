-- // AUTHOR: @NICKIBREEKI
-- https://www.roblox.com/games/5204856478/OLD-OPEN-SOURCE-Package-Framework

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // LOCALS
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character and Character:WaitForChild("Humanoid")

-- // RESOURCES
local Resources = ReplicatedStorage:WaitForChild("Res")

-- // LIBRARIES
local Utilities = require(Resources.Utils)
local MakeViewmodel: {Model: Model, Joints: {}} = require(script:WaitForChild("makeViewmodel"))

local Lerp = Utilities.Lerp
local Vec3Sine = Utilities.Vec3Sine
local PlayAudio = Utilities.PlayCopyAudio

-- // COMMON VARIABLES
local HumanoidStateConnection: RBXScriptConnection
local CommonVariables = require(script:WaitForChild("CommonVariables"))

-- // FUNCTIONS
local function HumanoidStateHandler(Previous_State: Enum.HumanoidStateType, Latest_State: Enum.HumanoidStateType)
	if Previous_State == Enum.HumanoidStateType.Running and Latest_State == Enum.HumanoidStateType.Freefall then
		CommonVariables.States.Jumped = true
		CommonVariables.States.Landed = false
	elseif Previous_State == Enum.HumanoidStateType.Freefall and Latest_State == Enum.HumanoidStateType.Landed then
		CommonVariables.States.Jumped = false
		CommonVariables.States.Landed = true
	end
end

local function LocalVariablesUpdater(newCharacter: Model)
	Humanoid = newCharacter:WaitForChild("Humanoid")
	Character = newCharacter
	
	if HumanoidStateConnection then
		HumanoidStateConnection:Disconnect()
		HumanoidStateConnection = nil
	end
	
	HumanoidStateConnection = Humanoid.StateChanged:Connect(HumanoidStateHandler)
end

local function IsActorMove(): boolean
	return Humanoid and ((Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid.MoveDirection ~= Vector3.new(0, 0, 0)))
end
local function IsActorDied(): boolean
	return Humanoid and Humanoid.Health <= 0
end

local function TriggerSound(Keyframe: number)
	for i,v in pairs(CommonVariables.ItemData["SoundEffects"]) do
		if v["Keyframe"] == Keyframe and v["TriggeredByKeyframe"] then
			PlayAudio(Resources["Sounds"][CommonVariables.ItemModel.Name][i])
		end
	end
end

local function makeViewmodel()
	MakeViewmodel = MakeViewmodel()
	
	CommonVariables.Viewmodel = MakeViewmodel.Model
	CommonVariables.ViewmodelJoints = MakeViewmodel.Joints
end

local function PlayAnimation(AnimationName: string)
	local CheckGunType = CommonVariables.ItemData["ItemType"]
	local Animations = CommonVariables.ItemData["Animations"]
	
	if CheckGunType == "Handgun" then
		local AnimationExist = Animations[AnimationName]
		if AnimationExist then			
			if not AnimationExist["PoseOnly"] then
				if not CommonVariables.States.Reloading and AnimationName == "Reload" then
					CommonVariables.States.Reloading = true
				end
				
				for keyframe = 1, #AnimationExist["Keyframes"] do
					local keyframeData = AnimationExist["Keyframes"][keyframe]
					for jointName, cframeValue in pairs(keyframeData) do
						local FoundJoint = CommonVariables.ViewmodelJoints[jointName]
						local DefaultCFrame = FoundJoint and FoundJoint:FindFirstChild("DefaultCFrame")

						if FoundJoint and DefaultCFrame then
							FoundJoint.C0 = DefaultCFrame.Value * cframeValue
						else
							if jointName == "ViewmodelOffset" then
								CommonVariables.ViewmodelOffset = AnimationExist["Keyframes"][keyframe]["ViewmodelOffset"]
							end
						end
					end
					TriggerSound(keyframe)
					wait(0.05)
				end
				
				if CommonVariables.States.Reloading and AnimationName == "Reload" then
					CommonVariables.States.Reloading = false
				end
			else
				CommonVariables.ViewmodelOffset = AnimationExist["Keyframes"][1]["ViewmodelOffset"]
				for jointName, cframeValue in pairs(AnimationExist["Keyframes"][1]) do
					local FoundJoint = CommonVariables.ViewmodelJoints[jointName]
					local DefaultCFrame = FoundJoint and FoundJoint:FindFirstChild("DefaultCFrame")

					if FoundJoint and DefaultCFrame then
						FoundJoint.C0 = DefaultCFrame.Value * cframeValue
					end
				end
			end
		else
			
		end
	end	
end

local function Fire()
	if (tick() - CommonVariables.FirerateTick) > CommonVariables.ItemData["Firerate"] and not CommonVariables.States.Sprinting and not CommonVariables.States.Reloading then		
		CommonVariables.CurrentRecoil += CommonVariables.ItemData["RecoilIntensity"]
		CommonVariables.ItemData["SlideComponent"].C0 *= CommonVariables.ItemData["SlideOffset"]

		local FireSFX_Dir = Resources["Sounds"][CommonVariables.ItemModel.Name]["Fire"]
		
		PlayAudio(
			FireSFX_Dir:GetChildren()[math.random(1, #FireSFX_Dir:GetChildren())],
			Random.new():NextNumber(0.98,1.12)
		)

		delay(.025, function()
			CommonVariables.ItemData["SlideComponent"].C0 = CommonVariables.ItemData["SlideComponent"].C0 * CommonVariables.ItemData["SlideOffset"]:Inverse()

			delay(.025, function()
				CommonVariables.CurrentRecoil -= CommonVariables.ItemData["RecoilIntensity"] / 1.25
			end)			
		end)		

		CommonVariables.FirerateTick = tick()
	end
end

local function EquipData(ItemName: string)
	local DoesGunExist = Resources.GunModel:FindFirstChild(ItemName)
	if DoesGunExist then
		local newGunModel = DoesGunExist:Clone()
		local GunModelWeld = Instance.new("Weld", newGunModel)
		GunModelWeld.Name = "Main"
		
		CommonVariables.ItemData = require(newGunModel.Data)
		CommonVariables.ItemModel = newGunModel
		
		newGunModel.Parent = CommonVariables.Viewmodel
		
		GunModelWeld.Parent = newGunModel
		GunModelWeld.Part0 = CommonVariables.Viewmodel["RightArm"]
		GunModelWeld.Part1 = newGunModel.Body.Main
		GunModelWeld.C0 *= CommonVariables.ItemData["GunOffset"]
		
		CommonVariables.ViewmodelOffset = CommonVariables.ItemData["ViewmodelOffset"]
		
		PlayAnimation("Idle")
	end
end

local function InputBegan(InputObject: InputObject, BackgroundProcess: boolean)
	if BackgroundProcess then return end
	
	local KeyCode = InputObject.KeyCode
	local UserInputType = InputObject.UserInputType
	
	if UserInputType == Enum.UserInputType.MouseButton1 then
		if not CommonVariables.States.Reloading and not CommonVariables.States.Sprinting then
			Fire()
		end
		CommonVariables.States.Holding = true	
	elseif UserInputType == Enum.UserInputType.MouseButton2 then
		if not CommonVariables.States.Reloading and not CommonVariables.States.Sprinting then
			CommonVariables.States.Aimming = true
		end
	end
	
	if KeyCode == Enum.KeyCode.R then
		if not CommonVariables.States.Reloading and not CommonVariables.States.Aimming then
			PlayAnimation("Reload")
		end
	elseif KeyCode == Enum.KeyCode.LeftShift then
		if not CommonVariables.States.Reloading and not CommonVariables.States.Aimming then
			CommonVariables.States.Sprinting = true
		end
	end
end

local function InputEnded(InputObject: InputObject, BackgroundProcess: boolean)
	if BackgroundProcess then return end

	local KeyCode = InputObject.KeyCode
	local UserInputType = InputObject.UserInputType

	if UserInputType == Enum.UserInputType.MouseButton1 then
		CommonVariables.States.Holding = false	
	elseif UserInputType == Enum.UserInputType.MouseButton2 then
		CommonVariables.States.Aimming = false
	end
	
	if KeyCode == Enum.KeyCode.LeftShift then
		CommonVariables.States.Sprinting = false
	end
end

local function RenderStepped(Deltatime: number)
	local cap_deltatime = math.min(Deltatime, 1/60)
	
	if not CommonVariables.Viewmodel then return end
	if IsActorDied() then return end
	
	local Wobble
	if CommonVariables.States.Aimming then
		Wobble = Vec3Sine({3, 2}, {3, 2}, {3, 2})
	else
		if CommonVariables.States.Sprinting then
			Wobble = Vec3Sine({6, 4}, {6, 4}, {6, 4})
		else
			Wobble = Vec3Sine({5, 2}, {5, 2}, {5, 2})
		end
	end
	if IsActorMove() then
		CommonVariables.ViewmodelWobbleCF = CommonVariables.ViewmodelWobbleCF:Lerp(CFrame.new(Vector3.new(Wobble.X / 4, -math.abs(Wobble.Y) * 0.162, 0) * (CommonVariables.States.Aimming and 0.25 or 1)), 0.0725 * (cap_deltatime * 60))
		
		if CommonVariables.States.Sprinting then
			CommonVariables.ViewmodelSprintCF = CommonVariables.ViewmodelSprintCF:Lerp(CommonVariables.ItemData["SprintingOffset"], 0.1 * (cap_deltatime * 60))
		else
			CommonVariables.ViewmodelSprintCF = CommonVariables.ViewmodelSprintCF:Lerp(CFrame.identity, 0.1 * (cap_deltatime * 60))
		end	
	else
		CommonVariables.ViewmodelSprintCF = CommonVariables.ViewmodelSprintCF:Lerp(CFrame.identity, 0.1 * (cap_deltatime * 60))
		CommonVariables.ViewmodelWobbleCF = CommonVariables.ViewmodelWobbleCF:Lerp(CFrame.identity, 0.0725 * (cap_deltatime * 60))
	end
	
	local MouseDelta = UserInputService:GetMouseDelta() * (CommonVariables.States.Aimming and 0.0025 or 0.01)
	MouseDelta = CFrame.new(Vector3.new(MouseDelta.X * 5, MouseDelta.Y * 5, 0)) * CFrame.Angles(MouseDelta.Y / 4, MouseDelta.X, 0)
	
	if CommonVariables.States.Jumped or Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		CommonVariables.ViewmodelLandControlCF = CommonVariables.ViewmodelLandControlCF:Lerp(CFrame.new(0, -1 / (CommonVariables.States.Aimming and 4 or 1), 0), 0.025 * (cap_deltatime * 60))
	else
		if CommonVariables.States.Landed then
			CommonVariables.ViewmodelLandControlCF = CommonVariables.ViewmodelLandControlCF:Lerp(CFrame.identity, 0.05 * (cap_deltatime * 60))
		end		
	end
	
	CommonVariables.ViewmodelSwayCF = CommonVariables.ViewmodelSwayCF:Lerp(MouseDelta, 0.072 * (cap_deltatime * 60))
	CommonVariables.ViewmodelLandControlCF = CommonVariables.ViewmodelLandControlCF:Lerp(CFrame.identity, 0.05 * (cap_deltatime * 60))
	
	CommonVariables.CurrentRecoil = Lerp(CommonVariables.CurrentRecoil, 0, 0.1 * (cap_deltatime * 60))
	
	if CommonVariables.States.Aimming then
		if not CommonVariables.States.Reloading then			
			CommonVariables.ViewmodelAimDownSightCF = CommonVariables.ViewmodelAimDownSightCF:Lerp(
				CommonVariables.ItemData["AimOffset"],
				CommonVariables.ItemData["AimDownSightSpeed"] * 1.5 * (cap_deltatime * 60)
			)
			
			Camera.FieldOfView = Lerp(Camera.FieldOfView, CommonVariables.ItemData["AimDownSightFieldOfView"], CommonVariables.ItemData["AimDownSightSpeed"] * (cap_deltatime * 60))
		end
	else
		Camera.FieldOfView = Lerp(Camera.FieldOfView, CommonVariables.DefaultFOV, CommonVariables.ItemData["AimDownSightSpeed"] * (cap_deltatime * 60))

		CommonVariables.ViewmodelAimDownSightCF = CommonVariables.ViewmodelAimDownSightCF:Lerp(
			CFrame.identity,
			CommonVariables.ItemData["AimDownSightSpeed"] * (cap_deltatime * 60)
		)
	end
	
	if CommonVariables.States.Holding and CommonVariables.ItemData["Automatic"] and not CommonVariables.States.Sprinting then
		Fire()
	end
	
	local FinalViewmodelCF = Camera.CFrame * CommonVariables.ViewmodelLandControlCF * CommonVariables.ViewmodelSprintCF * CommonVariables.ViewmodelWobbleCF * CommonVariables.ViewmodelSwayCF * CommonVariables.ViewmodelOffset * CommonVariables.ViewmodelAimDownSightCF
	local FincalCameraCF = CFrame.Angles(math.rad(CommonVariables.CurrentRecoil), 0, 0)
	
	CommonVariables.Viewmodel:SetPrimaryPartCFrame(FinalViewmodelCF)
	Camera.CFrame = Camera.CFrame * FincalCameraCF
end    

local function Init()
	table.insert(CommonVariables.Connections, UserInputService.InputBegan:Connect(InputBegan))
	table.insert(CommonVariables.Connections, UserInputService.InputEnded:Connect(InputEnded))
	
	HumanoidStateConnection = Humanoid.StateChanged:Connect(HumanoidStateHandler)
	
	RunService:BindToRenderStep(
		"_viewmodel",
		(Enum.RenderPriority.Camera.Value + 1),
		RenderStepped
	)
end

makeViewmodel()
EquipData("Pistol")

-- // CONNECTIONS
Init()
Player.CharacterAdded:Connect(LocalVariablesUpdater)