-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local humanoid = nil

-- ฟังก์ชันอัพเดต Humanoid ตอนรีสปอน
local function updateHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        humanoid = player.Character:FindFirstChild("Humanoid")
    end
end

player.CharacterAdded:Connect(function()
    wait(1)
    updateHumanoid()
end)

updateHumanoid()

-- UI ปุ่ม Y (ปุ่ม R ไม่มี UI แล้ว)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local skillBtn = Instance.new("TextButton")
skillBtn.Size = UDim2.new(0, 100, 0, 50)
skillBtn.Position = UDim2.new(0.5, -50, 0.85, 0)
skillBtn.Text = "Y"
skillBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
skillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skillBtn.Font = Enum.Font.FredokaOne
skillBtn.TextSize = 28
skillBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.3, 0)
corner.Parent = skillBtn

-- ปุ่ม Y ทำงานเมื่อกด
skillBtn.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Y", false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Y", false, game)
end)

-- ฟังก์ชันกดปุ่มด้วยคีย์บอร์ด
local function pressKey(key)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
end

-- ป้องกัน Kick
hookfunction(Players.LocalPlayer.Kick, function() return end)

-- ระบบ Auto-R (ติดตัว)
local lastPress = 0
local cooldownTime = 3 -- ป้องกันกดรัว (แก้ Bug ปุ่มหาย)
local function canPress()
    return tick() - lastPress >= cooldownTime
end

RunService.RenderStepped:Connect(function()
    if humanoid and humanoid.Health > 0 then
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
        if healthPercent <= 55 then
            if canPress() then
                pressKey("R")
                lastPress = tick()
            end
        end
    end
end)

-- ผู้เล่นยังสามารถกด R เองได้ปกติ (ไม่บล็อกคีย์บอร์ด)
