-- LocalScript ใน StarterPlayerScripts
-- UI ปุ่ม R/Y ใน Frame เดียว ลากได้ทั้ง Frame + บันทึกตำแหน่ง

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local LOW_HEALTH_THRESHOLD = 0.55  -- 55%
local RESET_THRESHOLD      = 0.60  -- 60%
local ACTION_COOLDOWN      = 2     -- วินาทีคูลดาวน์
local SAVE_KEY = "ActionButtonsPosition" -- Key สำหรับ Attribute

-- ===== ฟังก์ชัน Action =====
local isOnCooldown = false
local function doRAction()
	if isOnCooldown then return end
	isOnCooldown = true
	print("[R Action] Triggered")

	-- ตัวอย่าง: FireServer RemoteEvent
	-- game.ReplicatedStorage:WaitForChild("RAction"):FireServer()

	task.delay(ACTION_COOLDOWN, function()
		isOnCooldown = false
	end)
end

local function doYAction()
	print("[Y Action] Triggered")

	-- ตัวอย่าง: FireServer RemoteEvent
	-- game.ReplicatedStorage:WaitForChild("YAction"):FireServer()
end

-- ===== สร้าง UI หลัก =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ActionButtonsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "ButtonsFrame"
frame.Size = UDim2.new(0, 180, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
frame.BackgroundTransparency = 0.2
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.8, 0, 0.7, 0)
frame.Parent = screenGui

-- โหลดตำแหน่งเดิมถ้ามี
local savedPos = playerGui:GetAttribute(SAVE_KEY)
if typeof(savedPos) == "Vector2" then
	frame.Position = UDim2.new(0, savedPos.X, 0, savedPos.Y)
end

-- ===== สร้างปุ่ม R และ Y =====
local function createButton(name, text, offset)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 80, 0, 80)
	btn.Position = UDim2.new(0, offset, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 40
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.AutoButtonColor = true
	btn.Parent = frame
	return btn
end

local rButton = createButton("RButton", "R", 0)
local yButton = createButton("YButton", "Y", 90)

-- ===== ปุ่มกดทำงาน =====
rButton.MouseButton1Click:Connect(doRAction)
yButton.MouseButton1Click:Connect(doYAction)

-- ===== ทำให้ Frame ลากได้ =====
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			frame.Position = newPos
		end
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		-- บันทึกตำแหน่งเป็น Vector2
		playerGui:SetAttribute(SAVE_KEY, Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset))
	end
end)

-- ===== ระบบออโต้ R ตอนเลือดต่ำ =====
local currentHumanoid
local healthTriggered = false

local function onHealthChanged(newHealth)
	if not currentHumanoid then return end
	local maxHealth = math.max(currentHumanoid.MaxHealth, 1)
	local ratio = newHealth / maxHealth

	if ratio <= LOW_HEALTH_THRESHOLD then
		if not healthTriggered then
			healthTriggered = true
			doRAction()
		end
	else
		if ratio >= RESET_THRESHOLD then
			healthTriggered = false
		end
	end
end

local function bindHumanoid(hum)
	currentHumanoid = hum
	healthTriggered = false
	isOnCooldown = false
	hum.HealthChanged:Connect(onHealthChanged)
	onHealthChanged(hum.Health)
end

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		bindHumanoid(hum)
	end
end)

if player.Character and player.Character:FindFirstChild("Humanoid") then
	bindHumanoid(player.Character.Humanoid)
end
