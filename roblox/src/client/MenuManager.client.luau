--!nocheck



local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera


local CAMERA_CONFIG = {
	ENABLED   = true,                   
	CENTER    = Vector3.new(274,15,-1089), 
	DISTANCE  = 30,                      
	SPEED     = 0.006,                   
	HEIGHT    = 15,                      
}


local GameControl = ReplicatedStorage:WaitForChild("GameControl")
local CanStartNow = GameControl:WaitForChild("CanStartNow")
local SetHighlightsEnabled = GameControl:WaitForChild("SetHighlightsEnabled")

local GameConfig = ReplicatedStorage:WaitForChild("GameConfig")
local HighlightsEnabled = GameConfig:WaitForChild("HighlightsEnabled")

local DisasterEvents = ReplicatedStorage:WaitForChild("DisasterEvents")
local TimerEvent = DisasterEvents:WaitForChild("TimerEvent")


local disasterUI = playerGui:FindFirstChild("DisasterUI") 
if disasterUI then disasterUI.Enabled = false end

local mainMenuGui = Instance.new("ScreenGui")
mainMenuGui.Name = "MainMenuGui"
mainMenuGui.ResetOnSpawn = false
mainMenuGui.DisplayOrder = 1000
mainMenuGui.Parent = playerGui

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 24
blurEffect.Parent = cam

local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundFrame.BackgroundTransparency = 0.5
backgroundFrame.Parent = mainMenuGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "TINY ALERT"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 90
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0.1, 0, 0.2, 0)
titleLabel.TextStrokeTransparency = 0
titleLabel.Parent = backgroundFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0.4, 0, 0.45, 0)
buttonContainer.Position = UDim2.new(0.3, 0, 0.5, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = backgroundFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Padding = UDim.new(0, 20)
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Parent = buttonContainer

local playButton = Instance.new("TextButton")
playButton.Name = "PlayButton"
playButton.Text = "JOUER"
playButton.Font = Enum.Font.SourceSansBold
playButton.TextSize = 30
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
playButton.Size = UDim2.new(1, 0, 0, 50)
playButton.Parent = buttonContainer
playButton.LayoutOrder = 1

local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Text = "PARAMÈTRES"
settingsButton.Font = Enum.Font.SourceSansBold
settingsButton.TextSize = 30
settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
settingsButton.Size = UDim2.new(1, 0, 0, 50)
settingsButton.Parent = buttonContainer
settingsButton.LayoutOrder = 2

local webButton = Instance.new("TextButton")
webButton.Name = "WebButton"
webButton.Text = "SITE WEB"
webButton.Font = Enum.Font.SourceSansBold
webButton.TextSize = 30
webButton.TextColor3 = Color3.fromRGB(255, 255, 255)
webButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
webButton.Size = UDim2.new(1, 0, 0, 50)
webButton.Parent = buttonContainer
webButton.LayoutOrder = 3

local infoLabel = Instance.new("TextLabel")
infoLabel.BackgroundTransparency = 1
infoLabel.Text = ""
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 18
infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
infoLabel.Size = UDim2.new(1, 0, 0, 28)
infoLabel.Parent = buttonContainer

local webPopup = Instance.new("Frame")
webPopup.Name = "WebPopup"
webPopup.Size = UDim2.new(0.5, 0, 0.3, 0)
webPopup.Position = UDim2.new(0.25, 0, -0.4, 0)
webPopup.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
webPopup.BorderSizePixel = 2
webPopup.BorderColor3 = Color3.fromRGB(255, 255, 255)
webPopup.Parent = mainMenuGui
webPopup.Visible = false

local webPopupTitle = Instance.new("TextLabel")
webPopupTitle.Text = "Visitez notre site !"
webPopupTitle.Font = Enum.Font.SourceSansBold
webPopupTitle.TextSize = 24
webPopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
webPopupTitle.BackgroundTransparency = 1
webPopupTitle.Size = UDim2.new(1, 0, 0.3, 0)
webPopupTitle.Position = UDim2.new(0, 0, 0.1, 0)
webPopupTitle.Parent = webPopup

local webPopupUrl = Instance.new("TextBox")
webPopupUrl.Text = "https://exemple.tld"
webPopupUrl.Font = Enum.Font.SourceSans
webPopupUrl.TextSize = 20
webPopupUrl.TextColor3 = Color3.fromRGB(200, 200, 200)
webPopupUrl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
webPopupUrl.Size = UDim2.new(0.8, 0, 0.2, 0)
webPopupUrl.Position = UDim2.new(0.1, 0, 0.4, 0)
webPopupUrl.ClearTextOnFocus = false
webPopupUrl.Parent = webPopup

local closePopupButton = Instance.new("TextButton")
closePopupButton.Text = "Fermer"
closePopupButton.Font = Enum.Font.SourceSansBold
closePopupButton.TextSize = 20
closePopupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closePopupButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closePopupButton.Size = UDim2.new(0.4, 0, 0.2, 0)
closePopupButton.Position = UDim2.new(0.3, 0, 0.7, 0)
closePopupButton.Parent = webPopup

local settingsPopup = Instance.new("Frame")
settingsPopup.Name = "SettingsPopup"
settingsPopup.Size = UDim2.new(0.5, 0, 0.35, 0)
settingsPopup.Position = UDim2.new(0.25, 0, -0.45, 0)
settingsPopup.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
settingsPopup.BorderSizePixel = 2
settingsPopup.BorderColor3 = Color3.fromRGB(255, 255, 255)
settingsPopup.Parent = mainMenuGui
settingsPopup.Visible = false

local settingsPopupTitle = Instance.new("TextLabel")
settingsPopupTitle.Text = "Paramètres"
settingsPopupTitle.Font = Enum.Font.SourceSansBold
settingsPopupTitle.TextSize = 24
settingsPopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsPopupTitle.BackgroundTransparency = 1
settingsPopupTitle.Size = UDim2.new(1, 0, 0.3, 0)
settingsPopupTitle.Position = UDim2.new(0, 0, 0.05, 0)
settingsPopupTitle.Parent = settingsPopup

local row = Instance.new("Frame")
row.BackgroundTransparency = 1
row.Size = UDim2.new(1, -40, 0, 50)
row.Position = UDim2.new(0, 20, 0.38, 0)
row.Parent = settingsPopup

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.Padding = UDim.new(0, 12)
rowLayout.Parent = row

local hlLabel = Instance.new("TextLabel")
hlLabel.BackgroundTransparency = 1
hlLabel.Text = "Surbrillance bâtiments"
hlLabel.Font = Enum.Font.SourceSansBold
hlLabel.TextSize = 20
hlLabel.TextColor3 = Color3.new(1,1,1)
hlLabel.Size = UDim2.new(0.6, 0, 1, 0)
hlLabel.Parent = row

local hlToggle = Instance.new("TextButton")
hlToggle.Size = UDim2.new(0.4, 0, 1, 0)
hlToggle.Font = Enum.Font.SourceSansBold
hlToggle.TextSize = 18
hlToggle.TextColor3 = Color3.new(1,1,1)
hlToggle.Parent = row

local function updateHLToggleVisual()
	if HighlightsEnabled.Value then
		hlToggle.Text = "ON"
		hlToggle.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
	else
		hlToggle.Text = "OFF"
		hlToggle.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
	end
end
updateHLToggleVisual()
HighlightsEnabled:GetPropertyChangedSignal("Value"):Connect(updateHLToggleVisual)

hlToggle.MouseButton1Click:Connect(function()
	local want = not HighlightsEnabled.Value
	local ok, ret = pcall(function()
		return SetHighlightsEnabled:InvokeServer(want)
	end)
	task.defer(updateHLToggleVisual)
end)

local settingsCloseButton = Instance.new("TextButton")
settingsCloseButton.Text = "Fermer"
settingsCloseButton.Font = Enum.Font.SourceSansBold
settingsCloseButton.TextSize = 20
settingsCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
settingsCloseButton.Size = UDim2.new(0.4, 0, 0.2, 0)
settingsCloseButton.Position = UDim2.new(0.3, 0, 0.7, 0)
settingsCloseButton.Parent = settingsPopup


local cameraConnection : RBXScriptConnection? = nil

local function startMenuCamera()
	if not CAMERA_CONFIG.ENABLED then return end
	cam.CameraType = Enum.CameraType.Scriptable
	local angle = 0
	cameraConnection = RunService.RenderStepped:Connect(function()
		angle += CAMERA_CONFIG.SPEED
		local x = CAMERA_CONFIG.CENTER.X + CAMERA_CONFIG.DISTANCE * math.cos(angle)
		local z = CAMERA_CONFIG.CENTER.Z + CAMERA_CONFIG.DISTANCE * math.sin(angle)
		local y = CAMERA_CONFIG.CENTER.Y + CAMERA_CONFIG.HEIGHT
		cam.CFrame = CFrame.new(Vector3.new(x, y, z), CAMERA_CONFIG.CENTER)
	end)
end

local function stopMenuCamera()
	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")
end


local pendingStart = false

local function closeMenu()
	mainMenuGui.Enabled = false
	blurEffect.Enabled = false
	stopMenuCamera()
	if disasterUI then disasterUI.Enabled = true end
end

playButton.MouseButton1Click:Connect(function()
	local ok, canClose = pcall(function()
		return CanStartNow:InvokeServer()
	end)

	if ok and canClose == true then
		closeMenu()
	else
		pendingStart = true
		infoLabel.Text = "Une catastrophe est en cours… tu entreras au prochain cycle."
		infoLabel.TextTransparency = 0
		TweenService:Create(infoLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
	end
end)

TimerEvent.OnClientEvent:Connect(function(msg)
	if pendingStart and msg == "disaster:end" then
		pendingStart = false
		closeMenu()
	end
end)


settingsButton.MouseButton1Click:Connect(function()
	settingsPopup.Visible = true
	settingsPopup:TweenPosition(
		UDim2.new(0.25, 0, 0.325, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Bounce,
		0.4
	)
end)

settingsCloseButton.MouseButton1Click:Connect(function()
	settingsPopup:TweenPosition(
		UDim2.new(0.25, 0, -0.45, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		0.25
	)
end)

webButton.MouseButton1Click:Connect(function()
	webPopup.Visible = true
	webPopup:TweenPosition(
		UDim2.new(0.25, 0, 0.35, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Bounce,
		0.4
	)
end)

closePopupButton.MouseButton1Click:Connect(function()
	webPopup:TweenPosition(
		UDim2.new(0.25, 0, -0.4, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		0.25
	)
end)

startMenuCamera()
if disasterUI then disasterUI.Enabled = false end
