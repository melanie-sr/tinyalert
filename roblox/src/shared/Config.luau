local Config = {}

Config.API_BASE_URL = "https://f5468b077a1b.ngrok-free.app"

Config.HAS_CONFIG_ENDPOINT = false

Config.ROUTES = {
	PLAYER_SCORE = "/api/player-score",
	LEADERBOARD  = "/api/leaderboard",
	CONFIG       = "/api/config",
}

local function ensureSlash(path)
	if typeof(path) ~= "string" then return "" end
	if string.sub(path, 1, 1) ~= "/" then
		return "/" .. path
	end
	return path
end

function Config.getUrl(route)
	local base = tostring(Config.API_BASE_URL or "")
	local path = ensureSlash(route)
	return (base .. path):gsub("([^:])//+", "%1/")
end

return Config
