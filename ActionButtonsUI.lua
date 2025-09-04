-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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

-- สร้าง UI สำหรับปุ่ม R และ Y
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createButton(text, posX, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 50)
    btn.Position = UDim2.new(0.5, posX, 0.85, 0)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.FredokaOne
    btn.TextSize = 28
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = btn

    -- กดปุ่ม (ส่ง Key Event)
    btn.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
    end)

    -- เพิ่มระบบลากปุ่ม
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return btn
end

local btnR = createButton("R", -110, "R")
local btnY = createButton("Y", 10, "Y")

-- ฟังก์ชันกดปุ่มผ่านสคริปต์
local function pressKey(key)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
end

-- ป้องกัน Kick
hookfunction(Players.LocalPlayer.Kick, function() return end)

-- ระบบ Auto-R (ติดตัว)
local lastPress = 0
local cooldownTime = 5 -- ป้องกันกดรัว (แก้ Bug ปุ่มหาย)
local function canPress()
    return tick() - lastPress >= cooldownTime
end

-- ตรวจว่าสกิล R พร้อม (วิธีง่าย: ตรวจปุ่ม R UI สีปกติ = พร้อม, สีเทา = คูลดาวน์)
local function isSkillReady()
    return btnR.BackgroundColor3 == Color3.fromRGB(40, 40, 40) -- สีปกติ = พร้อมใช้
end

RunService.RenderStepped:Connect(function()
    if humanoid and humanoid.Health > 0 then
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
        if healthPercent <= 55 and canPress() and isSkillReady() then
            pressKey("R")
            lastPress = tick()
        end
    end
end)
