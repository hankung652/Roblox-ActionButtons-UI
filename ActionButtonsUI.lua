-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local humanoid = nil

-- ป้องกัน Kick เบื้องต้น
hookfunction(player.Kick, function() return end)

-- สร้าง UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSystemUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ปุ่ม Y สำหรับกดด้วยตัวเอง
local yButton = Instance.new("TextButton")
yButton.Size = UDim2.new(0, 100, 0, 50)
yButton.Position = UDim2.new(0.5, -50, 0.85, 0)
yButton.Text = "Y"
yButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
yButton.TextColor3 = Color3.fromRGB(255, 255, 0)
yButton.Font = Enum.Font.GothamBold
yButton.TextSize = 28
yButton.Parent = screenGui

local yCorner = Instance.new("UICorner")
yCorner.CornerRadius = UDim.new(0.3, 0)
yCorner.Parent = yButton

-- Drag UI
local dragging = false
local dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    yButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

yButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = yButton.Position
    end
end)

yButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then updateDrag(input) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ฟังก์ชันกดปุ่ม Y ด้วยตนเอง
yButton.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, "Y", false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, "Y", false, game)
end)

-- รอ Humanoid
player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
end)
if player.Character then
    humanoid = player.Character:WaitForChild("Humanoid")
end

-- ฟังก์ชันกด R
local function pressR()
    VirtualInputManager:SendKeyEvent(true, "R", false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, "R", false, game)
end

-- Auto-R ทำงานทันทีเมื่อรันสคริปต์
local autoRCooldown = false
RunService.RenderStepped:Connect(function()
    if humanoid and humanoid.Health > 0 then
        if humanoid.Health <= humanoid.MaxHealth * 0.55 and not autoRCooldown then
            autoRCooldown = true
            pressR()

            -- ตรวจจับคูลดาวน์แบบอิสระ
            task.spawn(function()
                repeat
                    task.wait(0.7) -- ลองเช็คทุก 0.7 วินาที
                    local before = humanoid.Health
                    pressR()
                    task.wait(0.1)
                    local after = humanoid.Health
                    if before ~= after then
                        -- สกิลทำงาน = พร้อมใช้งานใหม่
                        break
                    end
                until false
                autoRCooldown = false
            end)
        end
    end
end)
