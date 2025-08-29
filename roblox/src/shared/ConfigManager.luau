--!nocheck

local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local DEFAULT_NGROK_URL = "https://f5468b077a1b.ngrok-free.app" 
local DEFAULT_CONFIG = {
	NGROK_URL = DEFAULT_NGROK_URL,
	API_BASE_URL = DEFAULT_NGROK_URL,
	API_PLAYERS = DEFAULT_NGROK_URL .. "/api/players",
	API_PLAYER_CONNECTED = DEFAULT_NGROK_URL .. "/api/player-connected",
	API_PLAYER_DISCONNECTED = DEFAULT_NGROK_URL .. "/api/player-disconnected",
	API_PLAYER_SCORE = DEFAULT_NGROK_URL .. "/api/player-score",
	API_LEADERBOARD = DEFAULT_NGROK_URL .. "/api/leaderboard",
	API_CONFIG = DEFAULT_NGROK_URL .. "/api/config",
	DISASTER_COUNTDOWN_DURATION = 5,
	DISASTER_ACTIVE_DURATION = 10,
	DISASTER_PAUSE_DURATION = 30
}

local currentConfig = DEFAULT_CONFIG 
local isConfigLoaded = true

local configChangedEvent = Instance.new("BindableEvent")
ConfigManager.ConfigChanged = configChangedEvent.Event

function ConfigManager.new()
	local self = setmetatable({}, ConfigManager)
	return self
end

function ConfigManager:LoadConfigFromAPI(baseUrl)
	baseUrl = baseUrl or DEFAULT_CONFIG.NGROK_URL
	local configUrl = baseUrl .. "/api/config"
	
	
	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = configUrl,
			Method = "GET",
			Headers = {
				["ngrok-skip-browser-warning"] = "true",
				["User-Agent"] = "RobloxStudio/1.0",
				["Accept"] = "application/json"
			}
		})
	end)
	
	if success and result.StatusCode == 200 then
		local configData = HttpService:JSONDecode(result.Body)
		currentConfig = configData
		isConfigLoaded = true
		
		
		configChangedEvent:Fire(currentConfig)
		
		return true, currentConfig
	else
		
		local fallbackSuccess, fallbackResult = pcall(function()
			return HttpService:GetAsync(configUrl)
		end)
		
		if fallbackSuccess then
			local configData = HttpService:JSONDecode(fallbackResult)
			currentConfig = configData
			isConfigLoaded = true
			
			configChangedEvent:Fire(currentConfig)
			
			return true, currentConfig
		else
			
			currentConfig = table.clone(DEFAULT_CONFIG)
			currentConfig.API_BASE_URL = baseUrl
			currentConfig.API_PLAYERS = baseUrl .. "/api/players"
			currentConfig.API_PLAYER_CONNECTED = baseUrl .. "/api/player-connected"
			currentConfig.API_PLAYER_DISCONNECTED = baseUrl .. "/api/player-disconnected"
			currentConfig.API_PLAYER_SCORE = baseUrl .. "/api/player-score"
			currentConfig.API_LEADERBOARD = baseUrl .. "/api/leaderboard"
			currentConfig.API_CONFIG = baseUrl .. "/api/config"
			
			isConfigLoaded = true
			return false, currentConfig
		end
	end
end

function ConfigManager:GetConfig(key)
	if not isConfigLoaded then
		return DEFAULT_CONFIG[key]
	end
	
	return currentConfig and currentConfig[key] or DEFAULT_CONFIG[key]
end

function ConfigManager:GetAllConfig()
	if not isConfigLoaded then
		return DEFAULT_CONFIG
	end
	
	return currentConfig or DEFAULT_CONFIG
end

function ConfigManager:IsConfigLoaded()
	return isConfigLoaded
end

function ConfigManager:ReloadConfig(baseUrl)
	isConfigLoaded = false
	return self:LoadConfigFromAPI(baseUrl)
end

function ConfigManager:GetApiUrl(endpoint)
	local baseUrl = self:GetConfig("NGROK_URL")
	return baseUrl .. endpoint
end

function ConfigManager:GetPlayersUrl()
	return self:GetConfig("API_PLAYERS")
end

function ConfigManager:GetPlayerConnectedUrl()
	return self:GetConfig("API_PLAYER_CONNECTED")
end

function ConfigManager:GetPlayerDisconnectedUrl()
	return self:GetConfig("API_PLAYER_DISCONNECTED")
end

function ConfigManager:GetPlayerScoreUrl()
	return self:GetConfig("API_PLAYER_SCORE")
end

function ConfigManager:GetLeaderboardUrl()
	return self:GetConfig("API_LEADERBOARD")
end

function ConfigManager:GetDisasterCountdownDuration()
	return self:GetConfig("DISASTER_COUNTDOWN_DURATION")
end

function ConfigManager:GetDisasterActiveDuration()
	return self:GetConfig("DISASTER_ACTIVE_DURATION")
end

function ConfigManager:GetDisasterPauseDuration()
	return self:GetConfig("DISASTER_PAUSE_DURATION")
end

local configManagerInstance = ConfigManager.new()


local FALLBACK_URLS = {
	DEFAULT_NGROK_URL, 
	"http://localhost:3000", 
	"https://localhost:3000" 
}

spawn(function()
	for _, url in ipairs(FALLBACK_URLS) do
		local success = configManagerInstance:LoadConfigFromAPI(url)
		if success then
			break
		end
		wait(1) 
	end
	
	if not configManagerInstance:IsConfigLoaded() then
	end
end)

return configManagerInstance