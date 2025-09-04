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
screenGui.Name = "AutoRManualRYUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame หลัก (UI สวยแบบ King Legacy)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,80)
frame.Position = UDim2.new(0.5,0,0.85,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,12)

-- Gradient + Stroke แบบ King Legacy
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,255,127))
})
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,0,0)
stroke.Thickness = 2

-- ปุ่ม Manual R
local manualRButton = Instance.new("TextButton")
manualRButton.Size = UDim2.new(0.3,0,0.8,0)
manualRButton.Position = UDim2.new(0.05,0,0.1,0)
manualRButton.Text = "Press R"
manualRButton.TextScaled = true
manualRButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
manualRButton.TextColor3 = Color3.fromRGB(255,255,255)
manualRButton.Parent = frame
local rCorner = Instance.new("UICorner", manualRButton)
rCorner.CornerRadius = UDim.new(0,8)

-- ปุ่ม Manual Y
local manualYButton = Instance.new("TextButton")
manualYButton.Size = UDim2.new(0.3,0,0.8,0)
manualYButton.Position = UDim2.new(0.65,0,0.1,0)
manualYButton.Text = "Press Y"
manualYButton.TextScaled = true
manualYButton.BackgroundColor3 = Color3.fromRGB(0,255,127)
manualYButton.TextColor3 = Color3.fromRGB(255,255,255)
manualYButton.Parent = frame
local yCorner = Instance.new("UICorner", manualYButton)
yCorner.CornerRadius = UDim.new(0,8)

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

-- Manual R กดด้วยตัวเอง
manualRButton.MouseButton1Click:Connect(function()
	local vim = game:GetService("VirtualInputManager")
	vim:SendKeyEvent(true, "R", false, game)
	wait(0.05)
	vim:SendKeyEvent(false, "R", false, game)
end)

-- Manual Y กดด้วยตัวเอง
manualYButton.MouseButton1Click:Connect(function()
	local vim = game:GetService("VirtualInputManager")
	vim:SendKeyEvent(true, "Y", false, game)
	wait(0.05)
	vim:SendKeyEvent(false, "Y", false, game)
end)

-- Auto R เปิดอัตโนมัติ (ไม่รบกวนปุ่มเดิน/กระโดด)
RunService.RenderStepped:Connect(function()
	if humanoid.Health <= humanoid.MaxHealth * 0.55 then
		task.spawn(function()
			local vim = game:GetService("VirtualInputManager")
			-- กดปุ่มชั่วคราว
			vim:SendKeyEvent(true, "R", false, game)
			wait(0.03) -- เวลาสั้นมาก → ปุ่มเดิน/กระโดดไม่หาย
			vim:SendKeyEvent(false, "R", false, game)
		end)
	end
end)

-- ระบบกันแบนพื้นฐาน
hookfunction(player.Kick,function() return end)
