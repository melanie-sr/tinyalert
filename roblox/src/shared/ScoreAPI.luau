local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
local Config = require((Shared:FindFirstChild("Shared") or Shared):WaitForChild("Config"))

local ScoreAPI = {}

local RATE_LIMIT_SEC = 3
local lastSentByUser = {}

local function logUrl(method, route)
	local url = Config.getUrl(route)
	print(("[ScoreAPI] %s %s"):format(method, url))
	return url
end

local function requestJson(method, route, payload)
	if not HttpService.HttpEnabled then
		return false, nil, { status = -1, body = "HttpDisabled" }
	end

	local url = logUrl(method, route)
	local body = payload and HttpService:JSONEncode(payload) or nil
	local headers = {
		["Accept"] = "application/json",
		["ngrok-skip-browser-warning"] = "true",
	}
	if body then headers["Content-Type"] = "application/json" end

	local function doReq()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body,
		})
	end

	for attempt = 1, 2 do
		local ok, res = pcall(doReq)
		if ok and res then
			local data
			if res.Body and #res.Body > 0 then
				pcall(function() data = HttpService:JSONDecode(res.Body) end)
			end
			if res.Success then
				return true, data, { status = res.StatusCode, body = res.Body }
			else
				return false, data, { status = res.StatusCode, body = res.Body }
			end
		end
		if attempt == 1 then task.wait(0.6) end
	end

	return false, nil, { status = 0, body = "RequestFailed" }
end


function ScoreAPI.selfTest()
	if Config.HAS_CONFIG_ENDPOINT then
		local ok, _, meta = requestJson("GET", Config.ROUTES.CONFIG)
		if ok then
			print("[ScoreAPI] API OK via /api/config:", meta.status)
			return true
		end
		if meta.status ~= 404 then
			warn("[ScoreAPI] /api/config KO:", meta.status, meta.body)
		else
			print("[ScoreAPI] /api/config absent (404), fallback leaderboard")
		end
	end

	local ok2, _, meta2 = requestJson("GET", Config.ROUTES.LEADERBOARD)
	if ok2 or (meta2.status == 304 or meta2.status == 204) then
		print("[ScoreAPI] API OK via /api/leaderboard:", meta2.status)
		return true
	end

	warn("[ScoreAPI] API KO:", meta2.status, meta2.body)
	return false
end

local function sameId(a, b)
	if a == nil or b == nil then return false end
	return tostring(a) == tostring(b)
end

local function sameName(a, b)
	if not a or not b then return false end
	return string.lower(tostring(a)) == string.lower(tostring(b))
end

local function findRowForPlayer(list, userId, username, displayName)
	local uid = tostring(userId)
	for _, row in ipairs(list) do
		if sameId(row.userId, uid) or sameId(row.userID, uid) or sameId(row.id, uid) then
			return row
		end
	end
	for _, row in ipairs(list) do
		if sameName(row.username, username) or sameName(row.displayName, displayName) then
			return row
		end
	end
	return nil
end

function ScoreAPI.getLeaderboard()
	local ok, data, meta = requestJson("GET", Config.ROUTES.LEADERBOARD)
	if not ok and not (meta.status == 304 or meta.status == 204) then
		warn("[ScoreAPI] GET /leaderboard:", meta.status, meta.body)
		return {}
	end
	return typeof(data) == "table" and data or {}
end

function ScoreAPI.getPlayerScore(userId, username, displayName)
	local data = ScoreAPI.getLeaderboard()
	local row = findRowForPlayer(data, userId, username, displayName)
	if row then return tonumber(row.score) or 0 end
	return 0
end

function ScoreAPI.updatePlayerScore(player, newScore, opts)
	opts = opts or {}
	local force = opts.force == true

	local now = os.clock()
	local last = lastSentByUser[player.UserId] or 0
	if not force and (now - last) < RATE_LIMIT_SEC then
		return true
	end

	local payload = {
		userId = tostring(player.UserId),
		username = player.Name,
		displayName = player.DisplayName,
		score = tonumber(newScore) or 0,
	}

	local ok, _, meta = requestJson("POST", Config.ROUTES.PLAYER_SCORE, payload)
	if ok then
		lastSentByUser[player.UserId] = now
		print(("[ScoreAPI] POST OK: %s => %d (HTTP %s)"):format(player.Name, payload.score, tostring(meta.status)))
		return true
	else
		warn("[ScoreAPI] POST FAIL:", player.Name, "HTTP", meta.status, meta.body)
		return false
	end
end

return ScoreAPI
