-- LocalScript (ใส่ใน StarterPlayerScripts)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoRManualYUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame หลัก
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,70)
frame.Position = UDim2.new(0.5,0,0.85,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,12)

-- ปุ่ม Auto R
local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.new(0.48,0,0.8,0)
autoButton.Position = UDim2.new(0.02,0,0.1,0)
autoButton.Text = "Auto R: OFF"
autoButton.TextScaled = true
autoButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
autoButton.TextColor3 = Color3.fromRGB(255,255,255)
autoButton.Parent = frame
local autoCorner = Instance.new("UICorner", autoButton)
autoCorner.CornerRadius = UDim.new(0,8)

-- ปุ่ม Manual Y
local manualButton = Instance.new("TextButton")
manualButton.Size = UDim2.new(0.48,0,0.8,0)
manualButton.Position = UDim2.new(0.5,0,0.1,0)
manualButton.Text = "Press Y"
manualButton.TextScaled = true
manualButton.BackgroundColor3 = Color3.fromRGB(0,255,127)
manualButton.TextColor3 = Color3.fromRGB(255,255,255)
manualButton.Parent = frame
local manualCorner = Instance.new("UICorner", manualButton)
manualCorner.CornerRadius = UDim.new(0,8)

-- ระบบลาก Frame
local dragging = false
local dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
frame.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		update(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ตัวแปร Auto
local autoEnabled = false
autoButton.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoButton.Text = autoEnabled and "Auto R: ON" or "Auto R: OFF"
end)

-- Manual Y
manualButton.MouseButton1Click:Connect(function()
	game:GetService("VirtualInputManager"):SendKeyEvent(true, "Y", false, game)
	wait(0.1)
	game:GetService("VirtualInputManager"):SendKeyEvent(false, "Y", false, game)
end)

-- Auto R แบบกันตาย (กดเหมือนกดคีย์บอร์ด)
RunService.RenderStepped:Connect(function()
	if autoEnabled and humanoid.Health <= humanoid.MaxHealth * 0.55 then
		game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false, game)
		wait(0.1)
		game:GetService("VirtualInputManager"):SendKeyEvent(false, "R", false, game)
	end
end)

-- ระบบกันแบน
hookfunction(player.Kick,function() return end)
