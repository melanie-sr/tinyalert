--!nocheck
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local sprint = false
local WS_NORMAL, WS_SPRINT = 16, 32
local function applyWS()
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then hum.WalkSpeed = sprint and WS_SPRINT or WS_NORMAL end
end
UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.LeftShift or i.KeyCode==Enum.KeyCode.RightShift then sprint=true; applyWS() end end)
UserInputService.InputEnded:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.LeftShift or i.KeyCode==Enum.KeyCode.RightShift then sprint=false; applyWS() end end)
player.CharacterAdded:Connect(function(c) local h=c:WaitForChild("Humanoid"); h.WalkSpeed=WS_NORMAL end)

local events = ReplicatedStorage:WaitForChild("DisasterEvents")
local TimerEvent = events:WaitForChild("TimerEvent")
local TremblementEvent = events:WaitForChild("TremblementEvent")
local AnnouncementEvent = events:FindFirstChild("AnnouncementEvent")

local pg = player:WaitForChild("PlayerGui")
local gui = pg:FindFirstChild("DisasterUI") or Instance.new("ScreenGui"); gui.Name="DisasterUI"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=1000; gui.Parent=pg

local card = Instance.new("Frame")
card.Name="NotifyCard"
card.Size = UDim2.fromOffset(420, 118)
card.Position = UDim2.new(0.5, 0, 0.18, 0)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.BackgroundColor3 = Color3.fromRGB(40,40,40)
card.BackgroundTransparency = 0
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 14); corner.Parent = card
local stroke = Instance.new("UIStroke"); stroke.Thickness=1.5; stroke.Transparency=0.4; stroke.Color=Color3.fromRGB(255,255,255); stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=card
local grad = Instance.new("UIGradient"); grad.Rotation=90; grad.Color = ColorSequence.new(Color3.fromRGB(35,35,45), Color3.fromRGB(55,55,65)); grad.Parent = card
local scale = Instance.new("UIScale"); scale.Scale=0.9; scale.Parent = card

local iconCircle = Instance.new("Frame")
iconCircle.Name="IconCircle"
iconCircle.Size = UDim2.fromOffset(48,48)
iconCircle.Position = UDim2.new(0, 14, 0, 14)
iconCircle.BackgroundColor3 = Color3.fromRGB(80,80,90)
iconCircle.BackgroundTransparency = 0
iconCircle.Parent = card
local iconCorner = Instance.new("UICorner"); iconCorner.CornerRadius = UDim.new(1,0); iconCorner.Parent = iconCircle

local iconDot = Instance.new("Frame")
iconDot.Name="Dot"
iconDot.Size = UDim2.fromOffset(14,14)
iconDot.AnchorPoint = Vector2.new(0.5,0.5)
iconDot.Position = UDim2.fromScale(0.5,0.5)
iconDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
iconDot.Parent = iconCircle
local iconDotCorner = Instance.new("UICorner"); iconDotCorner.CornerRadius = UDim.new(1,0); iconDotCorner.Parent = iconDot

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -90, 0, 42)
title.Position = UDim2.new(0, 84, 0, 12)
title.Font = Enum.Font.GothamSemibold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(252,252,255)
title.Text = ""
title.Parent = card

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Size = UDim2.new(1, -90, 0, 28)
sub.Position = UDim2.new(0, 84, 0, 60)
sub.Font = Enum.Font.Gotham
sub.TextScaled = true
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextColor3 = Color3.fromRGB(230,233,238)
sub.TextTransparency = 0.1
sub.Text = ""
sub.Parent = card

local progressBG = Instance.new("Frame")
progressBG.Size = UDim2.new(1, -24, 0, 6)
progressBG.Position = UDim2.new(0, 12, 1, -12)
progressBG.BackgroundColor3 = Color3.fromRGB(255,255,255)
progressBG.BackgroundTransparency = 0.85
progressBG.BorderSizePixel = 0
progressBG.Parent = card
local pbgCorner = Instance.new("UICorner"); pbgCorner.CornerRadius = UDim.new(0, 4); pbgCorner.Parent = progressBG

local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 0, 1, 0)
progress.Position = UDim2.new(0, 0, 0, 0)
progress.BackgroundColor3 = Color3.fromRGB(255,255,255)
progress.BackgroundTransparency = 0
progress.BorderSizePixel = 0
progress.Parent = progressBG
local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0,4); pCorner.Parent = progress
local pGrad = Instance.new("UIGradient"); pGrad.Rotation=0; pGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)); pGrad.Parent = progress

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1,1)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BackgroundTransparency = 1
overlay.ZIndex = 2000
overlay.Visible = false
overlay.Parent = gui

local big = Instance.new("TextLabel")
big.Size = UDim2.fromScale(1,0.28)
big.Position = UDim2.fromScale(0,0.36)
big.BackgroundTransparency = 1
big.TextScaled = true
big.Font = Enum.Font.GothamBlack
big.TextColor3 = Color3.fromRGB(255,255,255)
big.TextStrokeTransparency = 0.2
big.ZIndex = 2001
big.Text = ""
big.Parent = overlay

local function CS(a,b) return ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)}) end
local THEMES = {
	countdown = { grad=CS(Color3.fromRGB(34,34,48), Color3.fromRGB(60,60,90)), title=Color3.fromRGB(252,252,255), sub=Color3.fromRGB(214,211,209), icon=Color3.fromRGB(251,191,36), bar=CS(Color3.fromRGB(253,230,138), Color3.fromRGB(245,158,11)) },
	start = {
		earthquake = { grad=CS(Color3.fromRGB(62,21,28), Color3.fromRGB(120,30,45)), title=Color3.fromRGB(255,240,240), sub=Color3.fromRGB(255,220,220), icon=Color3.fromRGB(239,68,68), bar=CS(Color3.fromRGB(248,113,113), Color3.fromRGB(190,18,60)) },
		tsunami    = { grad=CS(Color3.fromRGB(20,34,58), Color3.fromRGB(20,63,120)), title=Color3.fromRGB(235,245,255), sub=Color3.fromRGB(210,230,255), icon=Color3.fromRGB(59,130,246), bar=CS(Color3.fromRGB(147,197,253), Color3.fromRGB(29,78,216)) },
		default    = { grad=CS(Color3.fromRGB(40,24,66), Color3.fromRGB(76,29,149)), title=Color3.fromRGB(245,240,255), sub=Color3.fromRGB(225,215,250), icon=Color3.fromRGB(168,85,247), bar=CS(Color3.fromRGB(196,181,253), Color3.fromRGB(124,58,237)) },
	},
	pause = { grad=CS(Color3.fromRGB(25,32,45), Color3.fromRGB(45,55,72)), title=Color3.fromRGB(235,240,245), sub=Color3.fromRGB(199,210,221), icon=Color3.fromRGB(148,163,184), bar=CS(Color3.fromRGB(203,213,225), Color3.fromRGB(148,163,184)) },
	done  = { grad=CS(Color3.fromRGB(7,47,34), Color3.fromRGB(4,120,87)), title=Color3.fromRGB(235,255,245), sub=Color3.fromRGB(209,250,229), icon=Color3.fromRGB(16,185,129), bar=CS(Color3.fromRGB(110,231,183), Color3.fromRGB(16,185,129)) },
}

local names = { earthquake="Tremblement de terre", tsunami="Tsunami" }

local function themeCard(mode, dtype)
	if mode=="countdown" then grad.Color=THEMES.countdown.grad; title.TextColor3=THEMES.countdown.title; sub.TextColor3=THEMES.countdown.sub; iconCircle.BackgroundColor3=THEMES.countdown.icon; pGrad.Color=THEMES.countdown.bar
	elseif mode=="pause" then grad.Color=THEMES.pause.grad; title.TextColor3=THEMES.pause.title; sub.TextColor3=THEMES.pause.sub; iconCircle.BackgroundColor3=THEMES.pause.icon; pGrad.Color=THEMES.pause.bar
	elseif mode=="done" then grad.Color=THEMES.done.grad; title.TextColor3=THEMES.done.title; sub.TextColor3=THEMES.done.sub; iconCircle.BackgroundColor3=THEMES.done.icon; pGrad.Color=THEMES.done.bar
	elseif mode=="start" then
		local t=THEMES.start[dtype] or THEMES.start.default
		grad.Color=t.grad; title.TextColor3=t.title; sub.TextColor3=t.sub; iconCircle.BackgroundColor3=t.icon; pGrad.Color=t.bar
	end
end

local cardVisible = false
local currentTween
local function showCard()
	if cardVisible then return end
	cardVisible=true
	card.Visible=true
	if currentTween then currentTween:Cancel() end
	scale.Scale=0.9; card.BackgroundTransparency=0.2; stroke.Transparency=0.7; card.Position=UDim2.new(0.5,0,0.2,0)
	currentTween = TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1})
	currentTween:Play()
	TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency=0, Position=UDim2.new(0.5,0,0.18,0)}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.18), {Transparency=0.4}):Play()
end

local function bump()
	TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1.03}):Play()
	task.delay(0.1, function() TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=1}):Play() end)
end

local hideDebounce=false
local function hideCard()
	if not cardVisible or hideDebounce then return end
	hideDebounce=true
	local t1 = TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency=0.2, Position=UDim2.new(0.5,0,0.2,0)})
	local t2 = TweenService:Create(stroke, TweenInfo.new(0.18), {Transparency=0.8})
	local t3 = TweenService:Create(scale, TweenInfo.new(0.18), {Scale=0.95})
	t1:Play(); t2:Play(); t3:Play()
	t1.Completed:Connect(function() card.Visible=false; cardVisible=false; hideDebounce=false end)
end

local function setProgress01(alpha)
	alpha = math.clamp(alpha or 0, 0, 1)
	TweenService:Create(progress, TweenInfo.new(0.12, Enum.EasingStyle.Linear), { Size = UDim2.new(alpha, 0, 1, 0) }):Play()
end

local function showOverlay(titleText, fg, bg, dur)
	big.Text = titleText
	big.TextColor3 = Color3.fromRGB(fg[1],fg[2],fg[3])
	overlay.BackgroundColor3 = Color3.fromRGB(bg[1],bg[2],bg[3])
	overlay.Visible=true
	overlay.BackgroundTransparency=0.45
	big.TextTransparency=1
	big.Position = UDim2.fromScale(0,0.4)
	big.Size = UDim2.fromScale(1,0.22)
	TweenService:Create(big, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0, Position=UDim2.fromScale(0,0.36), Size=UDim2.fromScale(1,0.28)}):Play()
	task.delay(0.32, function()
		local reps = math.max(0, math.floor((dur or 3)/0.5))
		TweenService:Create(big, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, reps, true), {TextStrokeTransparency=0.5}):Play()
	end)
	task.delay(dur or 3, function()
		TweenService:Create(big, TweenInfo.new(0.4), {TextTransparency=1}):Play()
		TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play()
		task.wait(0.4)
		overlay.Visible=false
	end)
end

local disasterTotal, pauseTotal = nil, nil

local shaking=false
local shakeEnd=0
local cfg = {duration=5,intensity=0.7,frequency=6,rot=1.1,pos=0.55}
local seeds={x=math.random(0,1e4),y=math.random(0,1e4),z=math.random(0,1e4),rx=math.random(0,1e4),ry=math.random(0,1e4),rz=math.random(0,1e4)}
local function now() return time() end
RunService:BindToRenderStep("CineShake", Enum.RenderPriority.Camera.Value+1, function()
	if not shaking then return end
	local t = now()
	if t>=shakeEnd then shaking=false return end
	local ft=t*cfg.frequency
	local fall=(shakeEnd-t)/cfg.duration; fall = math.clamp(fall,0,1); fall = (1-fall); fall=fall*fall
	local nx,ny,nz = math.noise(seeds.x,ft), math.noise(seeds.y,ft+14), math.noise(seeds.z,ft+27)
	local rx,ry,rz = math.noise(seeds.rx,ft+41), math.noise(seeds.ry,ft+56), math.noise(seeds.rz,ft+69)
	local posAmp=cfg.pos*cfg.intensity*fall; local rotAmp=cfg.rot*cfg.intensity*fall
	cam.CFrame = cam.CFrame * (CFrame.new(Vector3.new(nx,ny,nz)*posAmp) * CFrame.Angles(rx*rotAmp*0.04, ry*rotAmp*0.03, rz*rotAmp*0.06))
end)

TremblementEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload)=="table" and payload.active==true then
		cfg.duration=tonumber(payload.duration) or cfg.duration
		cfg.intensity=tonumber(payload.intensity) or cfg.intensity
		cfg.frequency=tonumber(payload.frequency) or cfg.frequency
		cfg.rot=tonumber(payload.rot) or cfg.rot
		cfg.pos=tonumber(payload.pos) or cfg.pos
		shakeEnd = now()+cfg.duration
		shaking=true
	elseif payload==true then
		shakeEnd = now()+cfg.duration
		shaking=true
	else
		shaking=false
	end
end)

if AnnouncementEvent then
	AnnouncementEvent.OnClientEvent:Connect(function(p)
		if typeof(p)=="table" then
			showOverlay(tostring(p.title or ""), p.color or {255,255,255}, p.bg or {0,0,0}, tonumber(p.duration) or 3)
		end
	end)
end

local names = { earthquake="Tremblement de terre", tsunami="Tsunami" }

local function themeCard(mode, dtype)
	-- (inchangé) thèmes déjà définis au-dessus
end

TimerEvent.OnClientEvent:Connect(function(message)
	if string.sub(message,1,10)=="countdown:" then
		local parts = string.split(message, ":"); local left = tonumber(parts[2]); local dtype=parts[3] or "earthquake"
		local name = names[dtype] or "Catastrophe"
		title.Text = (dtype=="tsunami" and "Une " or "Un ")..name.." approche"
		sub.Text = "Début dans ".. left .."s"
		themeCard("countdown", dtype)
		showCard()

	elseif string.sub(message,1,15)=="disaster:start:" then
		local parts = string.split(message, ":"); local dtype=parts[3] or "earthquake"
		local name = names[dtype] or "Catastrophe"
		title.Text = name.." en cours"
		sub.Text = "Survis pour gagner des points"
		themeCard("start", dtype)
		showCard()

	elseif message=="disaster:end" then
		title.Text = "Catastrophe terminée"
		sub.Text = "Prépare-toi pour la suivante"
		themeCard("done")
		showCard()
		task.delay(2.2, hideCard)

	elseif string.sub(message,1,6)=="pause:" then
		local left = tonumber(string.sub(message,7))
		title.Text = "Pause"
		sub.Text = "Prochaine catastrophe dans ".. left .."s"
		themeCard("pause")
		showCard()
	end
end)
