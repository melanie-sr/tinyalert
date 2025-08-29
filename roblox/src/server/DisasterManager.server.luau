--!nocheck


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local API_BASE = "https://f5468b077a1b.ngrok-free.app"
local API_URL_POST   = API_BASE .. "/api/player-score"
local API_URL_LEADER = API_BASE .. "/api/leaderboard"

local COUNTDOWN_SECONDS = 5
local DISASTER_SECONDS  = 5
local PAUSE_SECONDS     = 5
local OUTCOME_SECONDS   = 5   

local remFolder = ReplicatedStorage:FindFirstChild("DisasterEvents")
if not remFolder then
	remFolder = Instance.new("Folder")
	remFolder.Name = "DisasterEvents"
	remFolder.Parent = ReplicatedStorage
end

local function getOrMakeEvent(name)
	local r = remFolder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remFolder
	end
	return r
end

local TimerEvent        = getOrMakeEvent("TimerEvent")
local TremblementEvent  = getOrMakeEvent("TremblementEvent")
local AnnouncementEvent = getOrMakeEvent("AnnouncementEvent")

local gameControl = ReplicatedStorage:FindFirstChild("GameControl")
if not gameControl then
	gameControl = Instance.new("Folder")
	gameControl.Name = "GameControl"
	gameControl.Parent = ReplicatedStorage
end

local CanStartNow = gameControl:FindFirstChild("CanStartNow")
if not CanStartNow then
	CanStartNow = Instance.new("RemoteFunction")
	CanStartNow.Name = "CanStartNow"
	CanStartNow.Parent = gameControl
end

local configFolder = ReplicatedStorage:FindFirstChild("GameConfig")
if not configFolder then
	configFolder = Instance.new("Folder")
	configFolder.Name = "GameConfig"
	configFolder.Parent = ReplicatedStorage
end

local HighlightsEnabled = configFolder:FindFirstChild("HighlightsEnabled")
if not HighlightsEnabled then
	HighlightsEnabled = Instance.new("BoolValue")
	HighlightsEnabled.Name = "HighlightsEnabled"
	HighlightsEnabled.Value = true 
	HighlightsEnabled.Parent = configFolder
end

local SetHighlightsEnabled = gameControl:FindFirstChild("SetHighlightsEnabled")
if not SetHighlightsEnabled then
	SetHighlightsEnabled = Instance.new("RemoteFunction")
	SetHighlightsEnabled.Name = "SetHighlightsEnabled"
	SetHighlightsEnabled.Parent = gameControl
end
SetHighlightsEnabled.OnServerInvoke = function(player, newValue)
	if typeof(newValue) == "boolean" then
		HighlightsEnabled.Value = newValue
	end
	return HighlightsEnabled.Value
end

local function requestJson(method, url, payload)
	if not HttpService.HttpEnabled then
		return false, nil, { status = -1, body = "HttpDisabled" }
	end
	local body = payload and HttpService:JSONEncode(payload) or nil
	local headers = { ["Accept"] = "application/json", ["ngrok-skip-browser-warning"] = "true" }
	if body then headers["Content-Type"] = "application/json" end

	local function doReq()
		return HttpService:RequestAsync({ Url = url, Method = method, Headers = headers, Body = body })
	end

	for attempt = 1, 2 do
		local ok, res = pcall(doReq)
		if ok and res then
			local data
			if res.Body and #res.Body > 0 then pcall(function() data = HttpService:JSONDecode(res.Body) end) end
			if res.Success then
				return true, data, { status = res.StatusCode, body = res.Body }
			else
				return false, data, { status = res.StatusCode, body = res.Body }
			end
		end
		if attempt == 1 then task.wait(0.4) end
	end
	return false, nil, { status = 0, body = "RequestFailed" }
end

local function getExistingScore(player)
	local ok, data, meta = requestJson("GET", API_URL_LEADER)
	if not ok then
		warn("[DM] GET leaderboard KO:", meta.status)
		return 0
	end
	if typeof(data) ~= "table" then return 0 end
	local uid = tostring(player.UserId)
	for _, row in ipairs(data) do
		if tostring(row.userId) == uid then
			return tonumber(row.score) or 0
		end
		if tostring(row.username or ""):lower() == player.Name:lower() then
			return tonumber(row.score) or 0
		end
	end
	return 0
end

local lastSentByUser = {}
local RATE_LIMIT_SEC = 3
local function sendScore(player, score, force)
	local now = os.clock()
	local last = lastSentByUser[player.UserId] or 0
	if not force and (now - last) < RATE_LIMIT_SEC then return true end

	local payload = { userId = tostring(player.UserId), username = player.Name, score = tonumber(score) or 0 }
	local ok = requestJson("POST", API_URL_POST, payload)
	if ok then
		lastSentByUser[player.UserId] = now
		return true
	else
		return false
	end
end

local function ensureLeaderstats(p)
	local ls = p:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder"); ls.Name="leaderstats"; ls.Parent=p
	end
	local pts = ls:FindFirstChild("Points")
	if not pts then
		pts = Instance.new("IntValue"); pts.Name="Points"; pts.Value=0; pts.Parent=ls
	end
	return pts
end

local function initPlayerPoints(p)
	local pts = ensureLeaderstats(p)
	local serverScore = getExistingScore(p)
	if type(serverScore) == "number" and serverScore > pts.Value then
		pts.Value = serverScore
	end
	sendScore(p, pts.Value, true) 
	pts.Changed:Connect(function()
		sendScore(p, pts.Value, false)
	end)
end

local function safeRequire(mod)
	if not mod then return nil end
	local ok, res = pcall(require, mod)
	if not ok then warn("[DM] require échoué:", mod and mod.Name or "?", res) return nil end
	if typeof(res) == "function" then return res end
	if typeof(res) == "table" and typeof(res.run) == "function" then return res.run end
	return nil
end

local tremFn = safeRequire(script.Parent:FindFirstChild("tremblement"))
local tsuFn  = safeRequire(script.Parent:FindFirstChild("tsunami"))

local disasters = {}
if tremFn then table.insert(disasters, { key="earthquake", run=tremFn, theme={title="TREMBLEMENT DE TERRE", color={255,70,70}, bg={20,0,0}} }) end
if tsuFn  then table.insert(disasters, { key="tsunami",    run=tsuFn,  theme={title="TSUNAMI",              color={60,160,255}, bg={0,10,20}} }) end

local started = false           
local loopRunning = false
local disasterActive = false
local playersAlive = {}        

local function awardPointsLoop()
	while disasterActive do
		for _, p in ipairs(Players:GetPlayers()) do
			if playersAlive[p.UserId] then
				local pts = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Points")
				if pts then pts.Value += 1 end
			end
		end
		task.wait(1)
	end
end

local function announceStart(entry)
	if AnnouncementEvent then
		AnnouncementEvent:FireAllClients({
			title = entry.theme.title, color = entry.theme.color, bg = entry.theme.bg, duration = 3
		})
	end
	TimerEvent:FireAllClients("disaster:start:" .. entry.key)
	if entry.key == "earthquake" then
		TremblementEvent:FireAllClients({ active=true, duration=DISASTER_SECONDS, intensity=1.0, frequency=6, rot=1.2, pos=0.6 })
	end
end

local function announceEnd(entry)
	TimerEvent:FireAllClients("disaster:end")
	if entry.key == "earthquake" then
		TremblementEvent:FireAllClients({ active=false })
	end
end

local GREEN    = {46,204,113}
local GREEN_BG = { 8, 70, 44}
local RED      = {231, 76, 60}
local RED_BG   = {74, 15, 15}

local function sendOutcomeMessages(entry, seconds)
	for _, p in ipairs(Players:GetPlayers()) do
		local alive = playersAlive[p.UserId] ~= false
		local title, color, bg

		if entry.key == "tsunami" then
			if alive then
				title = "Bravo ! Tu as eu le bon réflexe."
				color, bg = GREEN, GREEN_BG
			else
				title = "Tu es mort. Le bon réflexe était d'aller en hauteur."
				color, bg = RED, RED_BG
			end
		elseif entry.key == "earthquake" then
			if alive then
				title = "Bravo ! Tu as eu le bon réflexe."
				color, bg = GREEN, GREEN_BG
			else
				title = "Tu es mort. Le bon réflexe était de te cacher sous une table."
				color, bg = RED, RED_BG
			end
		else
			if alive then
				title = "Bravo ! Bien joué."
				color, bg = GREEN, GREEN_BG
			else
				title = "Tu es mort."
				color, bg = RED, RED_BG
			end
		end

		if AnnouncementEvent then
			AnnouncementEvent:FireClient(p, {
				title = title,
				color = color,
				bg    = bg,
				duration = seconds or OUTCOME_SECONDS
			})
		end
	end
end

local function gameLoop()
	loopRunning = true
	while true do
		while not started do task.wait(0.2) end

		for i = PAUSE_SECONDS, 1, -1 do
			TimerEvent:FireAllClients("pause:" .. i)
			task.wait(1)
		end

		local entry = (#disasters > 0) and disasters[math.random(1, #disasters)]
			or { key="none", run=function() task.wait(DISASTER_SECONDS) end, theme={title="CATASTROPHE", color={255,255,255}, bg={0,0,0}} }

		for i = COUNTDOWN_SECONDS, 1, -1 do
			TimerEvent:FireAllClients("countdown:" .. i .. ":" .. entry.key)
			task.wait(1)
		end

		disasterActive = true
		playersAlive = {}
		for _, p in ipairs(Players:GetPlayers()) do playersAlive[p.UserId] = true end

		announceStart(entry)

		task.spawn(awardPointsLoop)
		pcall(function() if entry.run then entry.run() end end)
		task.wait(DISASTER_SECONDS)

		disasterActive = false
		announceEnd(entry)

		task.wait(2.3)

		sendOutcomeMessages(entry, OUTCOME_SECONDS)
		task.wait(OUTCOME_SECONDS)

		for _, p in ipairs(Players:GetPlayers()) do
			local pts = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Points")
			if pts then sendScore(p, pts.Value, true) end
		end
	end
end

CanStartNow.OnServerInvoke = function(player)
	if not started then
		started = true
		if not loopRunning then task.spawn(gameLoop) end
	end
	return not disasterActive
end

Players.PlayerAdded:Connect(function(p)
	task.spawn(function()
		if not p.Character then p.CharacterAdded:Wait() end
		initPlayerPoints(p)
	end)
	p.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			if disasterActive then playersAlive[p.UserId] = false end
		end)
	end)
end)

for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		if not p.Character then p.CharacterAdded:Wait() end
		initPlayerPoints(p)
	end)
end

Players.PlayerRemoving:Connect(function(p)
	local pts = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Points")
	if pts then sendScore(p, pts.Value, true) end
end)

print("[DM] Prêt : API + points + annonces + outcome + toggle Highlights serveur. Démarrage après clic 'JOUER'.")
