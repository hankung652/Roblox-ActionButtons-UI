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

-- UI หลัก
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ตัวแปรเก็บตำแหน่ง
local savedPositions = {}

-- โหลดตำแหน่งที่เคยบันทึก (Session)
local function loadPosition(name, defaultX)
    if savedPositions[name] then
        return savedPositions[name]
    else
        return UDim2.new(0.5, defaultX, 0.85, 0)
    end
end

local function createButton(name, text, posX, key)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 100, 0, 50)
    btn.Position = loadPosition(name, posX)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.FredokaOne
    btn.TextSize = 28
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
    end)

    -- ✅ ระบบลาก + บันทึกตำแหน่ง
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        btn.Position = newPos
        savedPositions[name] = newPos
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return btn
end

-- สร้างปุ่ม
local btnR = createButton("ButtonR", "R", -110, "R")
local btnY = createButton("ButtonY", "Y", 10, "Y")

-- ฟังก์ชันกดปุ่มผ่านสคริปต์
local function pressKey(key)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
end

-- ป้องกัน Kick
hookfunction(Players.LocalPlayer.Kick, function() return end)

-- ✅ ระบบ Auto-R (ติดตัว)
local lastPress = 0
local cooldownTime = 5 -- ป้องกันกดรัว
local function canPress()
    return tick() - lastPress >= cooldownTime
end

-- ✅ ตรวจว่าปุ่ม R ยังไม่ถูกกด (ป้องกันกดรัวจนปุ่มเดินหาย)
local function isSkillReady()
    return btnR.BackgroundColor3 == Color3.fromRGB(40, 40, 40)
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
