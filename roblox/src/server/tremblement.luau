--!nocheck

return function()
	local Workspace = game:GetService("Workspace")
	local DebrisService = game:GetService("Debris")
	local RunService = game:GetService("RunService")
	local CollectionService = game:GetService("CollectionService")
	local ServerStorage = game:GetService("ServerStorage")
	local TweenService = game:GetService("TweenService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local CFG = {
		USE_TAGS = true,                TAG = "QuakeDestructible",
		USE_ATTRIBUTE = true,           ATTRIBUTE = "QuakeDestructible",
		NAMES = { "maison", "Montagne" },
		FOLDER_PATH = "Workspace.Destructibles",

		PRE_LOCK_ALL = true,
		UNANCHOR_PROB = 0.45,
		MAX_PARTS = 120,
		CLAMP_SPEED = 70,
		LIFETIME = 20,
		KILL_ON_TOUCH = true,

		USE_HIGHLIGHT = true,
		HIGHLIGHT_COLOR = Color3.fromRGB(80, 255, 120),
		HIGHLIGHT_PULSE = true,

		DURATION = 5,
		REBUILD = true,
		REBUILD_DELAY = 1.0,
	}

	local function highlightsEnabled()
		local gc = ReplicatedStorage:FindFirstChild("GameConfig")
		local v = gc and gc:FindFirstChild("HighlightsEnabled")
		return v and v.Value == true
	end

	local function resolve(path)
		if typeof(path) ~= "string" or path == "" then return nil end
		local node = game
		for seg in string.gmatch(path, "[^%.]+") do
			node = node:FindFirstChild(seg)
			if not node then return nil end
		end
		return node
	end

	local function uniqInsert(set, inst)
		if not inst then return end
		set.__seen = set.__seen or {}
		if set.__seen[inst] then return end
		set.__seen[inst] = true
		table.insert(set, inst)
	end

	local function gatherTargets()
		local models = {}

		if CFG.USE_TAGS and CFG.TAG ~= "" then
			for _, inst in ipairs(CollectionService:GetTagged(CFG.TAG)) do
				local m = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
				if m then uniqInsert(models, m) end
			end
		end

		if CFG.USE_ATTRIBUTE and CFG.ATTRIBUTE ~= "" then
			for _, inst in ipairs(Workspace:GetDescendants()) do
				if inst:IsA("Model") and inst:GetAttribute(CFG.ATTRIBUTE) == true then
					uniqInsert(models, inst)
				end
			end
		end

		if CFG.NAMES and #CFG.NAMES > 0 then
			for _, name in ipairs(CFG.NAMES) do
				for _, inst in ipairs(Workspace:GetDescendants()) do
					if inst:IsA("Model") and inst.Name == name then
						uniqInsert(models, inst)
					end
				end
			end
		end

		local folder = resolve(CFG.FOLDER_PATH)
		if folder then
			for _, m in ipairs(folder:GetChildren()) do
				if m:IsA("Model") then uniqInsert(models, m) end
			end
		end

		models.__seen = nil
		return models
	end

	local debrisFolder = Workspace:FindFirstChild("DebrisFolder")
	if not debrisFolder then
		debrisFolder = Instance.new("Folder")
		debrisFolder.Name = "DebrisFolder"
		debrisFolder.Parent = Workspace
	end
	local cacheFolder = ServerStorage:FindFirstChild("QuakeRebuildCache")
	if not cacheFolder then
		cacheFolder = Instance.new("Folder")
		cacheFolder.Name = "QuakeRebuildCache"
		cacheFolder.Parent = ServerStorage
	end

	local glowCleanups = {}
	local function addHighlightToModel(model)
		local h = Instance.new("Highlight")
		h.Name = "QuakeGlow"
		h.Adornee = model
		h.FillColor = CFG.HIGHLIGHT_COLOR
		h.OutlineColor = CFG.HIGHLIGHT_COLOR
		h.FillTransparency = 0.7
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = Workspace
		local stopped = false
		if CFG.HIGHLIGHT_PULSE then
			task.spawn(function()
				while h and h.Parent and not stopped do
					TweenService:Create(h, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FillTransparency = 0.35}):Play()
					task.wait(0.46)
					TweenService:Create(h, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {FillTransparency = 0.7}):Play()
					task.wait(0.46)
				end
			end)
		end
		return function()
			stopped = true
			if h and h.Parent then h:Destroy() end
		end
	end
	local function clearAllHighlights()
		for _, off in ipairs(glowCleanups) do pcall(off) end
		table.clear(glowCleanups)
		for _, h in ipairs(Workspace:GetChildren()) do
			if h:IsA("Highlight") and h.Name == "QuakeGlow" then h:Destroy() end
		end
	end

	local partCount = 0
	local function onHB(fn)
		local c; c = RunService.Heartbeat:Connect(function(dt)
			if fn(dt) == false then c:Disconnect() end
		end)
		return c
	end

	local function killTouch(p)
		if not CFG.KILL_ON_TOUCH then return nil end
		return p.Touched:Connect(function(hit)
			local mdl = hit:FindFirstAncestorOfClass("Model")
			if not mdl then return end
			local hum = mdl:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then hum.Health = 0 end
		end)
	end

	local function prepDebris(part, sourceName)
		part.Anchored = false
		part.CanCollide = true
		part.CanTouch = true
		part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.5, 0.1, 1, 1)
		part.Parent = debrisFolder
		part:SetAttribute("QuakeSource", sourceName or "")
		pcall(function() part:SetNetworkOwner(nil) end)
	end

	local function addSpin(p, a, t)
		local bav = Instance.new("BodyAngularVelocity")
		bav.AngularVelocity = a
		bav.MaxTorque = t
		bav.Parent = p
		task.delay(3, function() if bav and bav.Parent then bav:Destroy() end end)
	end

	local function clampSpeed(p)
		local v = p.AssemblyLinearVelocity
		if v.Magnitude > CFG.CLAMP_SPEED then
			p.AssemblyLinearVelocity = v.Unit * CFG.CLAMP_SPEED
		end
	end

	local function toss(p, epic)
		local dir = (p.Position - epic)
		if dir.Magnitude < 1 then dir = Vector3.new(0,1,0) end
		local base = 20
		p.AssemblyLinearVelocity = dir.Unit * (base + math.random(-10, 12)) + Vector3.new(0, math.random(4,10), 0)
		addSpin(p, Vector3.new(math.random(-7,7), math.random(-7,7), math.random(-7,7)), Vector3.new(6000,6000,6000))
	end

	local rebuildList = {}
	local function snapshotTarget(model)
		local entry = {
			name = model.Name,
			parent = model.Parent,
			pivot = model:GetPivot(),
			template = model:Clone(),
			originalRef = model,
		}
		entry.template.Name = model.Name
		entry.template.Parent = cacheFolder
		return entry
	end

	local function copyTags(fromInst, toInst)
		for _, tg in ipairs(CollectionService:GetTags(fromInst)) do
			CollectionService:AddTag(toInst, tg)
		end
	end

	local function cleanupSourceDebris(sourceName)
		for _, p in ipairs(debrisFolder:GetChildren()) do
			if p:IsA("BasePart") and p:GetAttribute("QuakeSource") == sourceName then
				p:Destroy()
			end
		end
	end

	local function rebuild()
		if not CFG.REBUILD then return end
		for _, entry in ipairs(rebuildList) do
			if entry.originalRef and entry.originalRef.Parent then
				entry.originalRef:Destroy()
			end
			cleanupSourceDebris(entry.name)
			local clone = entry.template:Clone()
			clone.Name = entry.name
			clone.Parent = entry.parent or Workspace
			clone:PivotTo(entry.pivot)
			copyTags(entry.template, clone)
		end
	end

	local function shatterModel(model, epicenter)
		if CFG.PRE_LOCK_ALL then
			for _, d in ipairs(model:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = true end
			end
		end
		for _, d in ipairs(model:GetDescendants()) do
			if partCount >= CFG.MAX_PARTS then break end
			if d:IsA("BasePart") and d.Name ~= "Baseplate" then
				if d.Anchored and math.random() < CFG.UNANCHOR_PROB then
					prepDebris(d, model.Name)
					toss(d, epicenter)
					local conn = killTouch(d)
					partCount += 1
					DebrisService:AddItem(d, CFG.LIFETIME)
					onHB(function()
						if not d or not d.Parent then if conn then conn:Disconnect() end; return false end
						if d.Position.Y < -100 then d:Destroy() return false end
						clampSpeed(d)
					end)
				end
			end
		end
	end

	local function pulse(epicenter, radius, power)
		for _, part in ipairs(Workspace:GetPartBoundsInRadius(epicenter, radius)) do
			if part:IsA("BasePart") and part.Parent ~= debrisFolder and part.Anchored == false then
				local dir = (part.Position - epicenter)
				if dir.Magnitude < 1 then dir = Vector3.new(0,1,0) end
				part.AssemblyLinearVelocity += dir.Unit * power + Vector3.new(0, math.random(1, 5), 0)
			end
		end
	end

	local targets = gatherTargets()
	if #targets == 0 then
		warn("[tremblement] Aucun modèle ciblé (ajoute un nom/tag/attribut ou un dossier).")
		return
	end

	if CFG.REBUILD then
		rebuildList = {}
		for _, m in ipairs(targets) do
			table.insert(rebuildList, snapshotTarget(m))
		end
	end

	if CFG.USE_HIGHLIGHT and highlightsEnabled() then
		for _, m in ipairs(targets) do
			table.insert(glowCleanups, addHighlightToModel(m))
		end
	end

	local epic = Vector3.new(0, 6, 0)
	local duration = CFG.DURATION
	local t0 = time()

	for _, m in ipairs(targets) do
		shatterModel(m, epic)
		if partCount >= CFG.MAX_PARTS then break end
	end

	onHB(function()
		local t = time() - t0
		if t > duration then
			clearAllHighlights()
			return false
		end

		local phase
		if t < 5 then phase = t/5
		elseif t < 12 then phase = 1
		else phase = math.max(0, 1 - (t-12)/6) end

		local radius = 60 + 40 * phase
		local power  = 18 + 22 * phase

		pulse(epic + Vector3.new(math.sin(t*1.2)*15,0,math.cos(t*0.9)*15), radius, power)
		pulse(epic + Vector3.new(math.cos(t*0.7)*20, 0,math.sin(t*1.1)*20), radius*0.85, power*0.8)

		if partCount < CFG.MAX_PARTS and math.random() < 0.25 then
			for _, m in ipairs(targets) do
				shatterModel(m, epic)
				if partCount >= CFG.MAX_PARTS then break end
			end
		end
	end)

	task.delay(duration + CFG.REBUILD_DELAY, function()
		if CFG.REBUILD then rebuild() end
	end)
end
