local player = game:GetService("Players").LocalPlayer
local teleportService = game:GetService("TeleportService")

local myUserId = 10851165717
local myName = "@sigma_mangocherep"

local function getPlayers()
    local list = {}
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        table.insert(list, plr.Name)
    end
    return list
end

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

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 480)
frame.Position = UDim2.new(0.5, -160, 0.5, -240)
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local background = Instance.new("ImageLabel")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundTransparency = 1
background.Image = "rbxassetid://116260253802011"
background.ScaleType = Enum.ScaleType.Fit
background.Parent = frame

-- === ВЕРХНЯЯ ПАНЕЛЬ ===
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 65)
topBar.Position = UDim2.new(0, 10, 0, 15)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BackgroundTransparency = 0.3
topBar.BorderSizePixel = 0
topBar.Parent = frame

-- Аватар
local myAvatar = Instance.new("ImageLabel")
myAvatar.Size = UDim2.new(0, 48, 0, 48)
myAvatar.Position = UDim2.new(0, 5, 0.5, -24)
myAvatar.BackgroundTransparency = 1
myAvatar.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=120&y=120&format=png&userId=" .. myUserId
myAvatar.Parent = topBar

-- Ник
local myNameLabel = Instance.new("TextLabel")
myNameLabel.Size = UDim2.new(0, 130, 1, 0)
myNameLabel.Position = UDim2.new(0, 43, 0, 0)
myNameLabel.BackgroundTransparency = 1
myNameLabel.Text = myName
myNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
myNameLabel.TextSize = 16
myNameLabel.TextXAlignment = Enum.TextXAlignment.Left
myNameLabel.Font = Enum.Font.GothamBold
myNameLabel.Parent = topBar

-- Кнопка обновить
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 80, 0, 34)
refreshBtn.Position = UDim2.new(1, -90, 0.5, -17)
refreshBtn.Text = "Обновить"
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.TextSize = 13
refreshBtn.Parent = topBar
refreshBtn.MouseButton1Click:Connect(refreshList)

-- === СПИСОК ИГРОКОВ ===
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 0, 290)
playerList.Position = UDim2.new(0, 10, 0, 95)
playerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerList.BackgroundTransparency = 0.4
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 8
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = frame

local function refreshList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageLabel") then 
            child:Destroy() 
        end
    end
    local players = getPlayers()
    local canvasHeight = #players * 28 + 10
    playerList.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    for i, name in ipairs(players) do
        local plr = game:GetService("Players"):FindFirstChild(name)
        if not plr then continue end
        
        local displayName = plr.DisplayName or name
        local userId = plr.UserId
        
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.Position = UDim2.new(0, 0, 0, (i-1)*28 + 4)
        row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.Parent = playerList
        
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 20, 0, 20)
        avatar.Position = UDim2.new(0, 4, 0.5, -10)
        avatar.BackgroundTransparency = 1
        avatar.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=50&y=50&format=png&userId=" .. userId
        avatar.Parent = row
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 1, 0)
        btn.Position = UDim2.new(0, 28, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name .. " (" .. displayName .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = row
        
        btn.MouseButton1Click:Connect(function()
            local target = game:GetService("Players"):FindFirstChild(name)
            teleportToPlayer(target)
        end)
    end
end

refreshList()

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
