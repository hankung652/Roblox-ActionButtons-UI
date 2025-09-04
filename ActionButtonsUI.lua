-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- สร้าง RemoteEvent สำหรับ R/Y ใน ReplicatedStorage
local remoteNameR = "AutoR"
local remoteNameY = "ManualY"

local autoREvent = ReplicatedStorage:FindFirstChild(remoteNameR)
if not autoREvent then
	autoREvent = Instance.new("RemoteEvent")
	autoREvent.Name = remoteNameR
	autoREvent.Parent = ReplicatedStorage
end

local manualREvent = ReplicatedStorage:FindFirstChild(remoteNameY)
if not manualREvent then
	manualREvent = Instance.new("RemoteEvent")
	manualREvent.Name = remoteNameY
	manualREvent.Parent = ReplicatedStorage
end

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ActionButtonsUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- สร้าง Frame หลัก
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 70)
frame.Position = UDim2.new(0.4, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 12)

-- ปุ่ม Auto R
local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.new(0.48, 0, 0.8, 0)
autoButton.Position = UDim2.new(0.02, 0, 0.1, 0)
autoButton.Text = "Auto R: OFF"
autoButton.TextScaled = true
autoButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoButton.Parent = frame
local autoCorner = Instance.new("UICorner", autoButton)
autoCorner.CornerRadius = UDim.new(0, 8)

-- ปุ่ม Manual Y
local manualButton = Instance.new("TextButton")
manualButton.Size = UDim2.new(0.48, 0, 0.8, 0)
manualButton.Position = UDim2.new(0.5, 0, 0.1, 0)
manualButton.Text = "Press Y"
manualButton.TextScaled = true
manualButton.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
manualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
manualButton.Parent = frame
local manualCorner = Instance.new("UICorner", manualButton)
manualCorner.CornerRadius = UDim.new(0, 8)

-- ระบบ Auto R
local autoEnabled = false
autoButton.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoButton.Text = autoEnabled and "Auto R: ON" or "Auto R: OFF"
end)

-- ระบบ Manual Y
manualButton.MouseButton1Click:Connect(function()
	manualREvent:FireServer() -- ส่งไปแมพของคุณเอง
end)

-- ฟังก์ชัน Auto R
RunService.RenderStepped:Connect(function()
	if autoEnabled and humanoid.Health <= (humanoid.MaxHealth * 0.55) then
		autoREvent:FireServer() -- ส่งไปแมพของคุณเอง
	end
end)
