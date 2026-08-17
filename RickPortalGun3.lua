local player = game:GetService("Players").LocalPlayer
local teleportService = game:GetService("TeleportService")
local userInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local myUserId = 10851165717
local myName = "@sigma_mangocherep"

-- ===== ПЕРЕМЕННЫЕ ДЛЯ ПОРТАЛОВ =====
local portal1 = nil
local portal2 = nil
local isPlacingPortals = false
local isGreen = true
local portalLocked = false
local lastTeleportTime = 0
local teleportCooldown = 3

-- ===== ФУНКЦИЯ СОЗДАНИЯ ВЫСОКОЙ ПЛОСКОЙ ПЛАСТИНЫ =====
local function createPortal(position, normal, isGreen)
    local color = isGreen and BrickColor.new("Bright green") or BrickColor.new("Bright blue")
    local color3 = isGreen and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 150, 255)
    
    local portal = Instance.new("Part")
    portal.Name = isGreen and "Portal1" or "Portal2"
    portal.Size = Vector3.new(0.5, 0.5, 0.5)
    portal.Transparency = 1
    portal.Anchored = true
    portal.CanCollide = false
    portal.CanTouch = true
    portal.CanQuery = false
    portal.CastShadow = false
    
    local center = position + normal * 0.06
    portal.CFrame = CFrame.lookAt(center, center + normal)
    portal.Parent = workspace
    
    local mainRing = Instance.new("Part")
    mainRing.Name = "MainRing"
    mainRing.Size = Vector3.new(3.5, 4.5, 0.1)
    mainRing.CFrame = portal.CFrame * CFrame.new(0, 0, 0.002)
    mainRing.Anchored = true
    mainRing.CanCollide = false
    mainRing.CanTouch = false
    mainRing.CanQuery = false
    mainRing.CastShadow = false
    mainRing.BrickColor = BrickColor.new("White")
    mainRing.Material = Enum.Material.SmoothPlastic
    mainRing.Transparency = 0.05
    mainRing.Parent = portal
    
    local glowRing = Instance.new("Part")
    glowRing.Name = "GlowRing"
    glowRing.Size = Vector3.new(3.3, 4.3, 0.08)
    glowRing.CFrame = portal.CFrame * CFrame.new(0, 0, 0.003)
    glowRing.Anchored = true
    glowRing.CanCollide = false
    glowRing.CanTouch = false
    glowRing.CanQuery = false
    glowRing.CastShadow = false
    glowRing.BrickColor = color
    glowRing.Material = Enum.Material.Neon
    glowRing.Transparency = 0.2
    glowRing.Parent = portal
    
    local innerGlow = Instance.new("Part")
    innerGlow.Name = "InnerGlow"
    innerGlow.Size = Vector3.new(2.8, 3.8, 0.06)
    innerGlow.CFrame = portal.CFrame * CFrame.new(0, 0, 0.004)
    innerGlow.Anchored = true
    innerGlow.CanCollide = false
    innerGlow.CanTouch = false
    innerGlow.CanQuery = false
    innerGlow.CastShadow = false
    innerGlow.BrickColor = color
    innerGlow.Material = Enum.Material.Neon
    innerGlow.Transparency = 0.4
    innerGlow.Parent = portal
    
    local light = Instance.new("PointLight")
    light.Name = "PortalLight"
    light.Color = color3
    light.Brightness = 3.5
    light.Range = 12
    light.Shadows = false
    light.Parent = mainRing
    
    local attachment = Instance.new("Attachment")
    attachment.Name = "PortalAttachment"
    attachment.Parent = mainRing
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "PortalParticles"
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(color3)
    particles.LightEmission = 0.8
    particles.Rate = 12
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Speed = NumberRange.new(0.5, 1.2)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Parent = attachment
    particles:Emit(40)
    
    local rotation = 0
    local rotationConnection
    rotationConnection = RunService.RenderStepped:Connect(function(dt)
        if not portal or not portal.Parent then
            if rotationConnection then rotationConnection:Disconnect() end
            return
        end
        rotation += dt * 0.5
        local rotCFrame = CFrame.Angles(0, 0, rotation)
        mainRing.CFrame = portal.CFrame * rotCFrame * CFrame.new(0, 0, 0.002)
        glowRing.CFrame = portal.CFrame * rotCFrame * CFrame.new(0, 0, 0.003)
        innerGlow.CFrame = portal.CFrame * rotCFrame * CFrame.new(0, 0, 0.004)
    end)
    
    return portal
end

-- ===== ОБРАБОТЧИК ВХОДА В ПОРТАЛ =====
local function onPortalTouched(hit, portal)
    if not portal1 or not portal2 then return end
    if hit.Parent ~= player.Character then return end
    
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        warn("Подожди " .. teleportCooldown .. " секунд!")
        return
    end
    
    local targetPortal = (portal == portal1) and portal2 or portal1
    if targetPortal then
        lastTeleportTime = currentTime
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120387843"
        sound.Volume = 0.6
        sound.Parent = targetPortal
        sound:Play()
        
        player.Character:SetPrimaryPartCFrame(CFrame.new(targetPortal.Position + Vector3.new(0, 2, 0)))
    end
end

-- ===== УДАЛЕНИЕ ПОРТАЛОВ =====
local function clearPortals()
    if portal1 then portal1:Destroy() end
    if portal2 then portal2:Destroy() end
    portal1 = nil
    portal2 = nil
    isGreen = true
    portalLocked = false
    warn("Все порталы удалены")
end

-- ===== ОСТАЛЬНЫЕ ФУНКЦИИ =====
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

-- ===== СОЗДАНИЕ GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 520)
frame.Position = UDim2.new(0.5, -170, 0.5, -260)
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local background = Instance.new("ImageLabel")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundTransparency = 1
background.Image = "rbxassetid://116260253802011"
background.ScaleType = Enum.ScaleType.Fit
background.Parent = frame

-- === ЗАГОЛОВОК ===
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 25)
title.Position = UDim2.new(0, 10, 0, 15)
title.BackgroundTransparency = 1
title.Text = "🔹 Телепорт"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- === ФОН ДЛЯ КНОПОК (полупрозрачный чёрный) ===
local btnBackground = Instance.new("Frame")
btnBackground.Size = UDim2.new(0.8, -10, 0, 40)
btnBackground.Position = UDim2.new(0.1, 0, 0, 48)
btnBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btnBackground.BackgroundTransparency = 0.5
btnBackground.BorderSizePixel = 0
btnBackground.Parent = frame

-- === КНОПКИ ДЛЯ ПОРТАЛОВ ===
local portalModeBtn = Instance.new("TextButton")
portalModeBtn.Size = UDim2.new(0.5, -5, 0, 30)
portalModeBtn.Position = UDim2.new(0, 5, 0, 5)
portalModeBtn.Text = "🌀 Порталы"
portalModeBtn.TextSize = 14
portalModeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
portalModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
portalModeBtn.Font = Enum.Font.GothamBold
portalModeBtn.Parent = btnBackground

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.3, -5, 0, 30)
clearBtn.Position = UDim2.new(0.6, 5, 0, 5)
clearBtn.Text = "🗑️"
clearBtn.TextSize = 16
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = btnBackground
clearBtn.MouseButton1Click:Connect(clearPortals)

portalModeBtn.MouseButton1Click:Connect(function()
    if portalLocked then
        warn("Порталы закреплены! Нажми '🗑️' чтобы переставить.")
        return
    end
    isPlacingPortals = not isPlacingPortals
    if isPlacingPortals then
        portalModeBtn.Text = "🌀 Нажми на карту (1)"
        portalModeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        isGreen = true
        warn("Режим порталов включён. Нажми на карту для установки портала 1.")
    else
        portalModeBtn.Text = "🌀 Порталы"
        portalModeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        warn("Режим порталов выключен")
    end
end)

-- === ЗАГОЛОВОК СПИСКА ===
local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -20, 0, 20)
listTitle.Position = UDim2.new(0, 10, 0, 95)
listTitle.BackgroundTransparency = 1
listTitle.Text = "👥 Игроки на сервере"
listTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
listTitle.TextSize = 14
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Font = Enum.Font.GothamBold
listTitle.Parent = frame

-- === СПИСОК ИГРОКОВ ===
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 0, 230)
playerList.Position = UDim2.new(0, 10, 0, 120)
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

-- === ПАНЕЛЬ С ТВОИМ ПРОФИЛЕМ ===
local profileBar = Instance.new("Frame")
profileBar.Size = UDim2.new(1, -20, 0, 50)
profileBar.Position = UDim2.new(0, 10, 0, 365)
profileBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
profileBar.BackgroundTransparency = 0.3
profileBar.BorderSizePixel = 0
profileBar.Parent = frame

local myAvatarSmall = Instance.new("ImageLabel")
myAvatarSmall.Size = UDim2.new(0, 36, 0, 36)
myAvatarSmall.Position = UDim2.new(0, 5, 0.5, -18)
myAvatarSmall.BackgroundTransparency = 1
myAvatarSmall.Image = "https://www.roblox.com/Thumbs/Avatar.ashx?x=120&y=120&format=png&userId=" .. myUserId
myAvatarSmall.Parent = profileBar

local myNameLabelSmall = Instance.new("TextLabel")
myNameLabelSmall.Size = UDim2.new(0.5, -10, 1, 0)
myNameLabelSmall.Position = UDim2.new(0, 46, 0, 0)
myNameLabelSmall.BackgroundTransparency = 1
myNameLabelSmall.Text = myName
myNameLabelSmall.TextColor3 = Color3.fromRGB(255, 255, 255)
myNameLabelSmall.TextSize = 14
myNameLabelSmall.TextXAlignment = Enum.TextXAlignment.Left
myNameLabelSmall.Font = Enum.Font.GothamBold
myNameLabelSmall.Parent = profileBar

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.35, -10, 0, 34)
refreshBtn.Position = UDim2.new(0.65, 5, 0.5, -17)
refreshBtn.Text = "Обновить"
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.TextSize = 13
refreshBtn.Parent = profileBar
refreshBtn.MouseButton1Click:Connect(refreshList)

-- ===== КНОПКА СКРЫТЬ (ОТДЕЛЬНЫЙ SCREENGUI) =====
local toggleScreenGui = Instance.new("ScreenGui")
toggleScreenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 70, 0, 35)
toggleBtn.Position = UDim2.new(0.5, -35, 0, 10)
toggleBtn.Text = "📦 Скрыть"
toggleBtn.TextSize = 16
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = toggleScreenGui

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

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newX = startPos.X.Scale + delta.X / toggleScreenGui.AbsoluteSize.X
        local newY = startPos.Y.Scale + delta.Y / toggleScreenGui.AbsoluteSize.Y
        toggleBtn.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if not dragging then
        panelVisible = not panelVisible
        frame.Visible = panelVisible
        toggleBtn.Text = panelVisible and "📦 Скрыть" or "📦 Показать"
    end
end)

-- ===== УПРАВЛЕНИЕ ПОРТАЛАМИ (КЛИК ПО КАРТЕ) =====
userInputService.InputBegan:Connect(function(input)
    if not isPlacingPortals then return end
    if portalLocked then
        warn("Порталы закреплены! Нажми '🗑️' чтобы переставить.")
        return
    end
    
    -- Игнорируем касания по GUI
    if input.UserInputType == Enum.UserInputType.Touch then
        local guiObjects = screenGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        if #guiObjects > 0 then
            return
        end
    end
    
    local mouse = player:GetMouse()
    if not mouse then return end
    
    local screenPoint
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        screenPoint = Vector2.new(mouse.X, mouse.Y)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        screenPoint = input.Position
    else
        return
    end
    
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(screenPoint.X, screenPoint.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    
    if not result then
        warn("Наведи на поверхность (пол, стену, объект)")
        return
    end
    
    local targetPos = result.Position
    local normal = result.Normal
    
    if isGreen then
        if portal1 then portal1:Destroy() end
        portal1 = createPortal(targetPos, normal, true)
        portal1.Touched:Connect(function(hit)
            onPortalTouched(hit, portal1)
        end)
        isGreen = false
        portalModeBtn.Text = "🌀 Нажми на карту (2)"
        portalModeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        warn("Портал 1 (зелёный) установлен. Теперь поставь портал 2.")
    else
        if portal2 then portal2:Destroy() end
        portal2 = createPortal(targetPos, normal, false)
        portal2.Touched:Connect(function(hit)
            onPortalTouched(hit, portal2)
        end)
        isGreen = true
        portalModeBtn.Text = "🌀 Порталы закреплены"
        portalModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        portalLocked = true
        isPlacingPortals = false
        warn("Портал 2 (синий) установлен. Зелёный портал закреплён! Чтобы переставить, нажми '🗑️'.")
    end
end)
