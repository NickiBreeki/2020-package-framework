return {
	Connections = {};
	
	FirerateTick = tick();
	States = require(script:WaitForChild("States"));

	ItemData = nil;
	ItemModel = nil;

	Viewmodel = nil :: Model;
	ViewmodelJoints = {};

	CurrentRecoil = 0;
	DefaultFOV = workspace.CurrentCamera.FieldOfView;
		
	ViewmodelSwayCF = CFrame.identity;
	ViewmodelOffset = CFrame.identity;
	ViewmodelSprintCF = CFrame.identity;
	ViewmodelWobbleCF = CFrame.identity;
	ViewmodelLandControlCF = CFrame.identity;
	ViewmodelAimDownSightCF = CFrame.identity;
}