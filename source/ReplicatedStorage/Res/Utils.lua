-- // AUTHOR: @NICKIBREEKI

local RunService = game:GetService("RunService")

local module = {}

function module.PlayCopyAudio(Audio: Sound, Pitch: Random)
	local newSound = Audio:Clone()
	newSound.Parent = workspace
	newSound.PlaybackSpeed = Pitch or 1
	
	newSound:Play()
	newSound.Ended:Connect(function()
		newSound:Destroy()
	end)
	
	return newSound
end

function module.Lerp(Start: number, End: number, Target: number): number
	return Start + (End - Start) * Target	
end

function module.Sinewave(Intensity: number, Frequency: number): number
	return math.sin(tick() * Intensity * 1.5) * Frequency
end

function module.Vec3Sine(...)
	local Data = {...}
	
	local X = Data[1]
	local Y = Data[2]
	local Z = Data[3]

	return Vector3.new(
		module.Sinewave(X[1], X[2]),
		module.Sinewave(Y[1], Y[2]),
		module.Sinewave(Z[1], Z[2])
	)
end

return module