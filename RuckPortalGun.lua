--[[
    ======================================================
    🔹 Teleport Hub — портальная панель для Roblox
    Версия: 1.0
    Автор: sigma_mangocherep
    Описание:
      - Телепорт по ID места
      - Телепорт к игроку через зелёный портал
      - Список игроков с аватарками и DisplayName
      - Перетаскиваемая панель с кнопкой "Скрыть"
    ======================================================
]]

local player = game:GetService("Players").LocalPlayer
local teleportService = game:GetService("TeleportService")

-- ===== НАСТРОЙКИ (ИЗМЕНИ ПОД СЕБЯ) =====
local myUserId = 10851165717 -- ЗАМЕНИ НА СВОЙ USER ID
local myName = "@sigma_mangocherep" -- ЗАМЕНИ НА СВОЙ НИК

-- ===== ТЕЛЕПОРТ ПО ID =====
local function teleportToPlace(placeId)
    if placeId and type(placeId) == "number" then
        teleportService:Teleport(placeId, player)
    else
        warn("Неверный ID")
    end
end

-- ===== ПОЛУЧЕНИЕ СПИСКА ИГРОКОВ =====
local function getPlayers()
    local list = {}
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        table.insert(list, plr.Name)
    end
    return list
end

-- ===== ТЕЛЕПОРТ К ИГРОКУ (С ПОРТАЛОМ) =====
local function teleportToPlayer(target)
    if not target or not target.Character then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local targetPos = target.Character.PrimaryPart.Position
    local portalPart = Instance.new("Part")
    portalPart.Size = Vector3.new(8, 8, 1)
    portalPart.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 4
    portalPart.Anchored = true
    portalPart.CanCollide = false
    portalPart.Transparency = 0.3
    portalPart.BrickColor = BrickColor.new("Bright green")
    portalPart.Material = Enum.Material.Neon
    portalPart.Parent = workspace
    
    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(0, 255, 0)
    glow.Range = 20
    glow.Brightness = 5
    glow.Parent = portalPart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Rate = 200
    particles.VelocityInheritance = 0
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Speed = NumberRange.new(2, 5)
    particles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    particles.Size = NumberSequence.new(0.5)
    particles.Parent = portalPart
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9120387843"
    sound.Volume = 0.5
    sound.Parent = portalPart
    sound:Play()
    
    local touchDebounce = false
    
    local function onTouch(hit)
        if touchDebounce then return end
        if hit.Parent ~= char then return end
        
        touchDebounce = true
        sound:Stop()
        
        local teleportSound = Instance.new("Sound")
        teleportSound.SoundId = "rbxassetid://9120387843"
        teleportSound.Volume = 0.3
        teleportSound.Parent = portalPart
        teleportSound:Play()
        
        wait(0.3)
        char:SetPrimaryPartCFrame(CFrame.new(targetPos))
        
        portalPart:Destroy()
    end
    
    portalPart.Touched:Connect(onTouch)
    
    game:GetService("Debris"):AddItem(portalPart, 5)
end

-- ===== СОЗДАНИЕ GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 420)
frame.Position = UDim2.new(0.5, -150, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

-- Профиль
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(0, 160, 0, 40)
profileFrame.Position = UDim2.new(0, 8, 0, 6)
profileFrame.BackgroundTransparency = 1
profileFrame.Parent = frame

local myAvatar = Instance.new("ImageLabel")
myAvatar.Size = UDim2.new(0, 32, 0, 32)
myAvatar.Position = UDim2.new(0, 0, 0.5, -16)
myAvatar.BackgroundTransparency = 1
myAvatar.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=120&y=120&format=png&userId=" .. myUserId
myAvatar.Parent = profileFrame

local myNameLabel = Instance.new("TextLabel")
myNameLabel.Size = UDim2.new(1, -40, 1, 0)
myNameLabel.Position = UDim2.new(0, 38, 0, 0)
myNameLabel.BackgroundTransparency = 1
myNameLabel.Text = myName
myNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
myNameLabel.TextSize = 11
myNameLabel.TextXAlignment = Enum.TextXAlignment.Left
myNameLabel.Font = Enum.Font.GothamBold
myNameLabel.Parent = profileFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 18)
title.Position = UDim2.new(0, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔹 Телепорт"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Поле ввода ID
local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 28)
input.Position = UDim2.new(0, 10, 0, 72)
input.PlaceholderText = "Введите Place ID"
input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
input.Parent = frame

local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 28)
teleportBtn.Position = UDim2.new(0, 10, 0, 104)
teleportBtn.Text = "Телепорт"
teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Parent = frame
teleportBtn.MouseButton1Click:Connect(function()
    local id = tonumber(input.Text)
    if id then teleportToPlace(id) end
end)

-- Список игроков
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 0, 200)
playerList.Position = UDim2.new(0, 10, 0, 140)
playerList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerList.Parent = frame

local function refreshList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageLabel") then 
            child:Destroy() 
        end
    end
    local players = getPlayers()
    for i, name in ipairs(players) do
        local plr = game:GetService("Players"):FindFirstChild(name)
        if not plr then continue end
        
        local displayName = plr.DisplayName or name
        local userId = plr.UserId
        
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.Position = UDim2.new(0, 0, 0, (i-1)*32)
        row.BackgroundTransparency = 1
        row.Parent = playerList
        
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 24, 0, 24)
        avatar.Position = UDim2.new(0, 2, 0.5, -12)
        avatar.BackgroundTransparency = 1
        avatar.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=50&y=50&format=png&userId=" .. userId
        avatar.Parent = row
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Position = UDim2.new(0, 30, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name .. " (" .. displayName .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = row
        
        btn.MouseButton1Click:Connect(function()
            local target = game:GetService("Players"):FindFirstChild(name)
            teleportToPlayer(target)
        end)
    end
end

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, -20, 0, 30)
refreshBtn.Position = UDim2.new(0, 10, 0, 350)
refreshBtn.Text = "Обновить"
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Parent = frame
refreshBtn.MouseButton1Click:Connect(refreshList)

refreshList()

-- Кнопка "Скрыть" (перетаскиваемая)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -30, 0, 10)
toggleBtn.Text = "Скрыть"
toggleBtn.TextSize = 16
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = screenGui

local panelVisible = true
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newX = startPos.X.Scale + delta.X / screenGui.AbsoluteSize.X
        local newY = startPos.Y.Scale + delta.Y / screenGui.AbsoluteSize.Y
        toggleBtn.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if not dragging then
        panelVisible = not panelVisible
        frame.Visible = panelVisible
        toggleBtn.Text = panelVisible and "Скрыть" or "Показать"
    end
end)

-- ======================================================
--   СКРИПТ УСПЕШНО ЗАГРУЖЕН!
--   Нажми на "Телепорт" чтобы открыть панель.
-- ======================================================
