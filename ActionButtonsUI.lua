local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local saveEvent = ReplicatedStorage:WaitForChild("SaveUIButtonPosition")

-- โหลดข้อมูลตำแหน่งที่เซฟไว้
local savedPositions = {}
local rawData = player:GetAttribute("UIButtonPositions")
if rawData and rawData ~= "" then
    savedPositions = HttpService:JSONDecode(rawData)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ActionButtonsUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ฟังก์ชันโหลดตำแหน่ง
local function loadPosition(name, defaultX)
    if savedPositions[name] then
        return UDim2.new(savedPositions[name].scaleX, savedPositions[name].offsetX, savedPositions[name].scaleY, savedPositions[name].offsetY)
    else
        return UDim2.new(0.5, defaultX, 0.85, 0)
    end
end

-- ฟังก์ชันเซฟตำแหน่ง
local function savePosition(name, pos)
    savedPositions[name] = {
        scaleX = pos.X.Scale,
        offsetX = pos.X.Offset,
        scaleY = pos.Y.Scale,
        offsetY = pos.Y.Offset
    }
    saveEvent:FireServer(name, savedPositions[name])
end

-- สร้างปุ่ม
local function createButton(name, text, color, defaultX)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 100, 0, 100)
    btn.Position = loadPosition(name, defaultX)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.AutoButtonColor = true
    btn.Parent = screenGui
    btn.ClipsDescendants = true
    btn.ZIndex = 10
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.UICorner = Instance.new("UICorner", btn)
    btn.UICorner.CornerRadius = UDim.new(0, 20)

    -- เพิ่มการลากปุ่ม
    local dragging = false
    local dragInput, dragStart, startPos

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            btn.Position = newPos
            savePosition(name, newPos)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return btn
end

-- สร้างปุ่ม R และ Y
local btnR = createButton("BtnR", "R", Color3.fromRGB(255, 100, 100), -120)
local btnY = createButton("BtnY", "Y", Color3.fromRGB(100, 255, 100), 120)

-- ปุ่ม R กดเอง
btnR.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.R, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.R, false, game)
end)

-- ปุ่ม Y กดเอง
btnY.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

-- ✅ Auto-R ติดตัว (ทำงานเมื่อเลือดต่ำกว่า 55% และไม่กดรัวตอนคูลดาว)
local humanoid
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end
humanoid = getHumanoid()

player.CharacterAdded:Connect(function()
    humanoid = getHumanoid()
end)

local lastPress = 0
RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.Health / humanoid.MaxHealth <= 0.55 then
        if tick() - lastPress > 2 then -- กดทุก 2 วิ เพื่อเลี่ยงบั๊กคูลดาว
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.R, false, game)
            lastPress = tick()
        end
    end
end)
