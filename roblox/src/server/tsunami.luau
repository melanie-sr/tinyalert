--!nocheck

return function()
	local TweenService = game:GetService("TweenService")
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local function highlightsEnabled()
		local gc = ReplicatedStorage:FindFirstChild("GameConfig")
		local v = gc and gc:FindFirstChild("HighlightsEnabled")
		return v and v.Value == true
	end

	local TARGET_NAMES = { "Montagne" }
	local HIGHLIGHT_COLOR = Color3.fromRGB(80, 255, 120)
	local HIGHLIGHT_PULSE_TIME = 0.35
	local HIGHLIGHT_DURATION = 5

	local WAVE_LENGTH = 800
	local WAVE_HEIGHT = 140
	local WAVE_THICK  = 80
	local START_Z     = -900
	local END_Z       =  900
	local TRAVEL_TIME = 14
	local KILL_PUSH   = Vector3.new(0, 120, -260)
	local PUSH_PARTS  = 220
	local SCAN_DT     = 0.08

	local function addHighlight(adornee: Instance)
		local h = Instance.new("Highlight")
		h.Name = "TsunamiGlow"
		h.Adornee = adornee
		h.FillColor = HIGHLIGHT_COLOR
		h.OutlineColor = HIGHLIGHT_COLOR
		h.FillTransparency = 0.7
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = Workspace

		local stopped = false
		task.spawn(function()
			while h and h.Parent and not stopped do
				TweenService:Create(h, TweenInfo.new(HIGHLIGHT_PULSE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FillTransparency = 0.35 }):Play()
				task.wait(HIGHLIGHT_PULSE_TIME + 0.01)
				TweenService:Create(h, TweenInfo.new(HIGHLIGHT_PULSE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { FillTransparency = 0.7 }):Play()
				task.wait(HIGHLIGHT_PULSE_TIME + 0.01)
			end
		end)

		return function()
			stopped = true
			if h and h.Parent then h:Destroy() end
		end
	end

	local function findTargetsByName(name: string): {Instance}
		local results, seen = {}, {}
		local function push(x) if x and not seen[x] then seen[x] = true; table.insert(results, x) end end

		for _, inst in ipairs(Workspace:GetDescendants()) do
			if (inst:IsA("Model") or inst:IsA("BasePart")) and inst.Name == name then
				push(inst)
			end
		end
		if #results > 0 then return results end

		local needle = string.lower(name)
		for _, inst in ipairs(Workspace:GetDescendants()) do
			if inst:IsA("Model") or inst:IsA("BasePart") then
				if string.find(string.lower(inst.Name), needle, 1, true) then
					push(inst)
				end
			end
		end
		return results
	end

	local model = Instance.new("Model")
	model.Name = "TSUNAMI"
	model.Parent = Workspace

	local body = Instance.new("Part")
	body.Name = "WaveBody"
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = true
	body.Material = Enum.Material.ForceField
	body.Color = Color3.fromRGB(45, 140, 255)
	body.Transparency = 0.35
	body.Size = Vector3.new(WAVE_LENGTH, WAVE_HEIGHT, WAVE_THICK)
	body.Parent = model

	local crest = Instance.new("WedgePart")
	crest.Name = "Crest"
	crest.Anchored = true
	crest.CanCollide = false
	crest.CanQuery = false
	crest.CanTouch = true
	crest.Material = Enum.Material.ForceField
	crest.Color = Color3.fromRGB(180, 220, 255)
	crest.Transparency = 0.2
	crest.Size = Vector3.new(WAVE_LENGTH, math.max(12, WAVE_HEIGHT*0.18), math.max(20, WAVE_THICK*0.6))
	crest.Parent = model

	do
		local pivot = CFrame.new(0, WAVE_HEIGHT*0.5, START_Z)
		model:PivotTo(pivot)
		crest.CFrame = body.CFrame
			* CFrame.new(0, body.Size.Y/2 - crest.Size.Y/2, -body.Size.Z/2 + crest.Size.Z/2)
			* CFrame.Angles(math.rad(-12), 0, 0)
	end

	model.PrimaryPart = body

	local killed = {}
	local function killCharacter(hit: Instance)
		local mdl = hit:FindFirstAncestorOfClass("Model")
		if not mdl then return end
		local hum = mdl:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		if killed[mdl] then return end
		killed[mdl] = true
		hum.Health = 0
		local hrp = mdl:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity += KILL_PUSH
		end
	end

	local touchCons = {}
	local function bindTouch(p)
		table.insert(touchCons, p.Touched:Connect(killCharacter))
	end
	bindTouch(body); bindTouch(crest)

	local hbConn
	do
		local accum = 0
		hbConn = RunService.Heartbeat:Connect(function(dt)
			accum += dt
			if accum < SCAN_DT then return end
			accum = 0

			local cf = body.CFrame
			local size = body.Size
			for _, part in ipairs(Workspace:GetPartBoundsInBox(cf, size)) do
				if part:IsA("BasePart") then
					killCharacter(part)
					if not part.Anchored then
						local dir = (cf.LookVector * -1)
						local target = dir * PUSH_PARTS + Vector3.new(0, 40, 0)
						if part.AssemblyLinearVelocity.Magnitude < target.Magnitude then
							part.AssemblyLinearVelocity = target
						end
					end
				end
			end
		end)
	end

	local glowCleanups = {}
	local function clearHighlights()
		for _, off in ipairs(glowCleanups) do pcall(off) end
		table.clear(glowCleanups)
	end

	if highlightsEnabled() then
		for _, wanted in ipairs(TARGET_NAMES) do
			local list = findTargetsByName(wanted)
			for _, adornee in ipairs(list) do
				table.insert(glowCleanups, addHighlight(adornee))
			end
		end
		if HIGHLIGHT_DURATION and HIGHLIGHT_DURATION > 0 then
			task.delay(HIGHLIGHT_DURATION, clearHighlights)
		end
	end

	local startCF = CFrame.new(0, WAVE_HEIGHT*0.5, START_Z)
	local endCF   = CFrame.new(0, WAVE_HEIGHT*0.5, END_Z)
	body.CFrame = startCF
	crest.CFrame = body.CFrame
		* CFrame.new(0, body.Size.Y/2 - crest.Size.Y/2, -body.Size.Z/2 + crest.Size.Z/2)
		* CFrame.Angles(math.rad(-12), 0, 0)

	local tween = TweenService:Create(
		body,
		TweenInfo.new(TRAVEL_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ CFrame = endCF }
	)
	tween:Play()

	local followConn = RunService.Heartbeat:Connect(function()
		if not body or not body.Parent then return end
		crest.CFrame = body.CFrame
			* CFrame.new(0, body.Size.Y/2 - crest.Size.Y/2, -body.Size.Z/2 + crest.Size.Z/2)
			* CFrame.Angles(math.rad(-12), 0, 0)
	end)

	local function cleanup()
		if hbConn then hbConn:Disconnect() end
		if followConn then followConn:Disconnect() end
		for _, c in ipairs(touchCons) do pcall(function() c:Disconnect() end) end
		clearHighlights()
		if model and model.Parent then model:Destroy() end
	end

	tween.Completed:Connect(cleanup)
	Debris:AddItem(model, TRAVEL_TIME + 5)
end
