

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "CoordsHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2000
gui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "CoordsLabel"
label.AnchorPoint = Vector2.new(1, 0)
label.Position = UDim2.new(1, -12, 0, 12)
label.Size = UDim2.fromOffset(160, 28)
label.AutomaticSize = Enum.AutomaticSize.XY
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.25
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.5
label.Font = Enum.Font.Code
label.TextSize = 16
label.TextXAlignment = Enum.TextXAlignment.Right
label.TextYAlignment = Enum.TextYAlignment.Center
label.Text = "X: 0.0  Y: 0.0  Z: 0.0"
label.Parent = gui

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = label

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = label

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart")
end

local accum = 0
RunService.Heartbeat:Connect(function(dt)
	accum += dt
	if accum < 0.1 then return end 
	accum = 0

	local hrp = getHRP()
	if hrp then
		local p = hrp.Position
		label.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
	else
		label.Text = "X: …  Y: …  Z: …"
	end
end)
