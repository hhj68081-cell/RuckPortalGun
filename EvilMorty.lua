local player = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ===== ТЕКСТУРА ПОРТАЛА =====
local PORTAL_TEXTURE = "rbxassetid://77878374203347"

-- ===== ЖЁЛТЫЙ ЦВЕТ =====
local PORTAL_COLOR = Color3.fromRGB(255, 195, 35)
local PORTAL_COLOR_LIGHT = Color3.fromRGB(255, 225, 90)

-- ===== ПЕРЕМЕННЫЕ ПОРТАЛОВ =====
local portal1 = nil
local portal2 = nil
local isFirstPortal = true
local portalLocked = false
local lastTeleportTime = 0
local teleportCooldown = 2

-- ===== ПЕРЕМЕННЫЕ ДЛЯ ДОЛГОГО НАЖАТИЯ =====
local isHolding = false
local holdStartTime = 0
local HOLD_DURATION = 2

-- ===== МОДЕЛЬ ПОРТАЛЬНОЙ ПУШКИ =====
local PARTS = {
    { Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
        CFrame = CFrame.new(1.11402,1.00547,-10.9034, 1,0,0, 0,0,-1, 0,1,0),
        Color = Color3.fromRGB(99,95,98), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.272445,0.24273,0.454076),
        CFrame = CFrame.new(1.06861,1.119,-11.1986, 1,0,0, 0,0,-1, 0,1,0),
        Color = Color3.fromRGB(213,115,61), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
        CFrame = CFrame.new(1.06861,1.119,-10.6442, 1,0,0, 0,0,-1, 0,1,0),
        Color = Color3.fromRGB(99,95,98), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.454076,2.13416,0.36326),
        CFrame = CFrame.new(1.06861,0.823826,-10.5174, 1,0,0, 0,0,-1, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.590298,0.908151,0.0908151),
        CFrame = CFrame.new(1.06861,1.20982,-10.3371, 0,1,0, 0.707107,0,0.707107, 0.707107,0,-0.707107),
        Color = Color3.fromRGB(213,115,61), Shape = "Cylinder" },
    { Name = "Handle", Size = Vector3.new(0.454076,0.908151,0.454077),
        CFrame = CFrame.new(1.06861,0.454076,-10.8823, 1,0,0, 0,0.707107,-0.707107, 0,0.707107,0.707107),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.23219,0.136223,0.0454076),
        CFrame = CFrame.new(0.932386,0.560068,-10.3782, 0,0,-1, -0.707107,0.707107,0, 0.707107,0.707107,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.908151,0.908151,0.227038),
        CFrame = CFrame.new(1.02154,1.20982,-10.0633, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
        Color = Color3.fromRGB(255,255,0), Shape = "Cylinder" },
    { Name = "Part", Size = Vector3.new(0.0537722,0.908151,0.358481),
        CFrame = CFrame.new(1.02154,1.62249,-10.1739, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
        Color = Color3.fromRGB(255,255,0), Shape = "Cylinder" },
    { Name = "Part", Size = Vector3.new(0.795168,0.726521,0.862743),
        CFrame = CFrame.new(1.06861,0.993849,-9.58647, -0,0,-1, -1,0,0, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
        CFrame = CFrame.new(0.728048,0.993849,-9.54345, 1,0,0, 0,1,0, 0,0,1),
        Color = Color3.fromRGB(13,105,172), Shape = "Ball" },
    { Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
        CFrame = CFrame.new(1.09131,0.993845,-9.2459, 1,0,0, 0,1,0, 0,0,1),
        Color = Color3.fromRGB(255,255,0), Shape = "Ball" },
    { Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
        CFrame = CFrame.new(0.705344,0.993846,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
        CFrame = CFrame.new(1.06873,0.653257,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
        CFrame = CFrame.new(1.43186,0.993846,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
        CFrame = CFrame.new(1.06873,1.33495,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Block" },
    { Name = "Part", Size = Vector3.new(0.454076,0.375442,0.5),
        CFrame = CFrame.new(1.06861,0.817736,-11.8345, 0,0,1, 0,1,0, -1,0,0),
        Color = Color3.fromRGB(255,176,0), Shape = "Wedge" },
}

-- ===== ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ =====
local function makeDraggable(guiObject)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local screenGui = guiObject.Parent
            if screenGui then
                local newX = startPos.X.Scale + delta.X / screenGui.AbsoluteSize.X
                local newY = startPos.Y.Scale + delta.Y / screenGui.AbsoluteSize.Y
                guiObject.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end)
end

-- ===== ФУНКЦИЯ СОЗДАНИЯ ПОРТАЛА =====
local function createPortal(position, normal, isFirst)
    local color = PORTAL_COLOR
    local name = isFirst and "Portal1" or "Portal2"
    
    local portal = Instance.new("Part")
    portal.Name = name
    portal.Size = Vector3.new(0.6, 0.6, 0.6)
    portal.Transparency = 1
    portal.Anchored = true
    portal.CanCollide = false
    portal.CanTouch = true
    portal.CanQuery = false
    portal.CastShadow = false
    portal.CFrame = CFrame.new(position, position + normal)
    portal.Parent = workspace
    
    local surface = Instance.new("Part")
    surface.Name = "PortalTextureSurface"
    surface.Transparency = 1
    surface.Anchored = true
    surface.CanCollide = false
    surface.CanTouch = false
    surface.CanQuery = false
    surface.CastShadow = false
    surface.CFrame = portal.CFrame
    surface.Size = Vector3.new(0.15, 0.15, 0.04)
    surface.Parent = portal
    
    local front = Instance.new("Decal")
    front.Name = "PortalTextureFront"
    front.Face = Enum.NormalId.Front
    front.Texture = PORTAL_TEXTURE
    front.Color3 = color
    front.Transparency = 0
    front.Parent = surface
    
    local back = Instance.new("Decal")
    back.Name = "PortalTextureBack"
    back.Face = Enum.NormalId.Back
    back.Texture = PORTAL_TEXTURE
    back.Color3 = color
    back.Transparency = 0
    back.Parent = surface
    
    local light = Instance.new("PointLight")
    light.Name = "PortalLight"
    light.Color = color
    light.Brightness = 2.5
    light.Range = 10
    light.Shadows = false
    light.Parent = surface
    
    local attachment = Instance.new("Attachment")
    attachment.Name = "PortalAttachment"
    attachment.Parent = surface
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "PortalParticles"
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(color)
    particles.LightEmission = 0.7
    particles.Rate = 0
    particles.Lifetime = NumberRange.new(0.35, 0.7)
    particles.Speed = NumberRange.new(0.3, 0.8)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.10),
        NumberSequenceKeypoint.new(0.5, 0.06),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Parent = attachment
    particles:Emit(24)
    
    local FULL_SIZE = Vector3.new(9.3, 9.3, 0.06)
    local expandTween = TweenService:Create(
        surface,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = FULL_SIZE }
    )
    expandTween:Play()
    particles:Emit(24)
    
    local rotation = 0
    local rotationConnection
    rotationConnection = RunService.RenderStepped:Connect(function(dt)
        if not portal or not portal.Parent then
            if rotationConnection then rotationConnection:Disconnect() end
            return
        end
        rotation = rotation + dt * 0.65
        surface.CFrame = portal.CFrame * CFrame.Angles(0, 0, rotation)
    end)
    
    task.spawn(function()
        local pulseTime = 0
        while portal and portal.Parent do
            pulseTime = pulseTime + 0.08
            local pulse = (math.sin(pulseTime * 2) + 1) / 2
            front.Transparency = 0.02 + pulse * 0.06
            back.Transparency = 0.02 + pulse * 0.06
            light.Brightness = 2.0 + pulse * 0.8
            task.wait(0.08)
        end
    end)
    
    task.wait(0.2)
    TweenService:Create(light, TweenInfo.new(0.3), {
        Brightness = 3.5
    }):Play()
    
    return portal
end

-- ===== ОБРАБОТЧИК ВХОДА В ПОРТАЛ =====
local function onPortalTouched(hit, portal)
    if not portal1 or not portal2 then return end
    if hit.Parent ~= player.Character then return end
    
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        return
    end
    
    local targetPortal = (portal == portal1) and portal2 or portal1
    if targetPortal then
        lastTeleportTime = currentTime
        player.Character:SetPrimaryPartCFrame(CFrame.new(targetPortal.Position + Vector3.new(0, 2, 0)))
    end
end

-- ===== УДАЛЕНИЕ ПОРТАЛОВ =====
local function clearPortals()
    if portal1 then portal1:Destroy() end
    if portal2 then portal2:Destroy() end
    portal1 = nil
    portal2 = nil
    isFirstPortal = true
    portalLocked = false
    print("🧹 Порталы очищены!")
end

-- ===== СОЗДАНИЕ ПОРТАЛЬНОЙ ПУШКИ =====
local function createGun()
    local tool = Instance.new("Tool")
    tool.Name = "EvilMortyPortalGun"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    
    local handleDef
    for _, def in ipairs(PARTS) do
        if def.Name == "Handle" then
            handleDef = def
            break
        end
    end
    
    if not handleDef then
        tool:Destroy()
        return nil
    end
    
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = handleDef.Size
    Handle.CFrame = handleDef.CFrame
    Handle.Color = handleDef.Color
    Handle.Material = Enum.Material.Plastic
    Handle.Shape = Enum.PartType[handleDef.Shape]
    Handle.Anchored = false
    Handle.CanCollide = false
    Handle.CanTouch = false
    Handle.CanQuery = false
    Handle.Massless = true
    Handle.TopSurface = Enum.SurfaceType.Smooth
    Handle.BottomSurface = Enum.SurfaceType.Smooth
    Handle.Parent = tool
    
    for _, def in ipairs(PARTS) do
        if def.Name ~= "Handle" then
            local p = Instance.new("Part")
            p.Name = def.Name
            p.Size = def.Size
            p.CFrame = def.CFrame
            p.Color = def.Color
            p.Material = Enum.Material.Plastic
            p.Shape = Enum.PartType[def.Shape]
            p.Anchored = false
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.Massless = true
            p.TopSurface = Enum.SurfaceType.Smooth
            p.BottomSurface = Enum.SurfaceType.Smooth
            p.Parent = tool
            
            local weld = Instance.new("WeldConstraint")
            weld.Name = "PortalGunWeld"
            weld.Part0 = Handle
            weld.Part1 = p
            weld.Parent = p
        end
    end
    
    tool.Grip = CFrame.new(
        -0.000491312, -0.31704, -0.182152,
        -0.998248, 0, -0.059161,
        0.044804, 0.653046, -0.755992,
        0.038635, -0.757319, -0.651902
    )
    
    return tool
end

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PortalGunGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Кнопка "Получить пушку" (внизу слева)
local giveBtn = Instance.new("TextButton")
giveBtn.Size = UDim2.new(0, 160, 0, 55)
giveBtn.Position = UDim2.new(0.02, 0, 0.85, 0)
giveBtn.Text = "Получить пушку"
giveBtn.TextSize = 16
giveBtn.BackgroundColor3 = Color3.fromRGB(255, 195, 35)
giveBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
giveBtn.BorderSizePixel = 2
giveBtn.BorderColor3 = Color3.fromRGB(255, 150, 0)
giveBtn.Font = Enum.Font.GothamBold
giveBtn.Parent = screenGui

-- Кнопка "Очистить порталы" (внизу справа)
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 130, 0, 55)
clearBtn.Position = UDim2.new(0.72, 0, 0.85, 0)
clearBtn.Text = "🧹 Очистить"
clearBtn.TextSize = 16
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.BorderSizePixel = 2
clearBtn.BorderColor3 = Color3.fromRGB(150, 0, 0)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = screenGui

-- Индикатор удержания
local holdIndicator = Instance.new("Frame")
holdIndicator.Size = UDim2.new(0, 220, 0, 40)
holdIndicator.Position = UDim2.new(0.5, -110, 0.45, 0)
holdIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
holdIndicator.BackgroundTransparency = 0.6
holdIndicator.BorderSizePixel = 2
holdIndicator.BorderColor3 = Color3.fromRGB(255, 195, 35)
holdIndicator.Visible = false
holdIndicator.Parent = screenGui

local holdText = Instance.new("TextLabel")
holdText.Size = UDim2.new(1, 0, 0.6, 0)
holdText.Position = UDim2.new(0, 0, 0, 2)
holdText.BackgroundTransparency = 1
holdText.Text = "Удерживайте 2 сек..."
holdText.TextColor3 = Color3.fromRGB(255, 255, 255)
holdText.TextSize = 14
holdText.Font = Enum.Font.GothamBold
holdText.Parent = holdIndicator

local holdProgress = Instance.new("Frame")
holdProgress.Size = UDim2.new(0, 0, 0, 4)
holdProgress.Position = UDim2.new(0, 0, 1, -4)
holdProgress.BackgroundColor3 = Color3.fromRGB(255, 195, 35)
holdProgress.BorderSizePixel = 0
holdProgress.Parent = holdIndicator

-- ===== ДЕЛАЕМ КНОПКИ ПЕРЕТАСКИВАЕМЫМИ =====
makeDraggable(giveBtn)
makeDraggable(clearBtn)

-- ===== ОБРАБОТЧИК КНОПКИ "Получить пушку" =====
local function giveGun()
    if player.Backpack:FindFirstChild("EvilMortyPortalGun") then
        player.Backpack:FindFirstChild("EvilMortyPortalGun"):Destroy()
    end
    if player.Character then
        local oldGun = player.Character:FindFirstChild("EvilMortyPortalGun")
        if oldGun then oldGun:Destroy() end
    end
    
    local gun = createGun()
    if gun then
        gun.Parent = player.Backpack
        giveBtn.Text = "✅ Пушка в рюкзаке!"
        giveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("🔫 Пушка выдана!")
    else
        giveBtn.Text = "❌ Ошибка!"
        giveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

giveBtn.MouseButton1Click:Connect(giveGun)
giveBtn.TouchTap:Connect(giveGun)

-- ===== ОБРАБОТЧИК КНОПКИ "Очистить" =====
clearBtn.MouseButton1Click:Connect(clearPortals)
clearBtn.TouchTap:Connect(clearPortals)

-- ===== ПОСТАНОВКА ПОРТАЛА =====
local function shootPortal(screenPoint)
    if portalLocked then
        print("⚠️ Порталы уже установлены! Нажми 'Очистить'.")
        return
    end
    
    local char = player.Character
    if not char then return end
    
    local tool = char:FindFirstChild("EvilMortyPortalGun")
    if not tool then
        print("⚠️ Возьми пушку в руки!")
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenX, screenY
    if screenPoint then
        screenX = screenPoint.X
        screenY = screenPoint.Y
    else
        local mouse = player:GetMouse()
        if not mouse then return end
        screenX = mouse.X
        screenY = mouse.Y
    end
    
    local ray = camera:ViewportPointToRay(screenX, screenY)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    if not result then
        print("❌ Наведи на поверхность!")
        return
    end
    
    local pos = result.Position
    local normal = result.Normal
    
    if isFirstPortal then
        if portal1 then portal1:Destroy() end
        portal1 = createPortal(pos, normal, true)
        portal1.Touched:Connect(function(hit)
            onPortalTouched(hit, portal1)
        end)
        isFirstPortal = false
        print("🟡 Портал 1 установлен!")
    else
        if portal2 then portal2:Destroy() end
        portal2 = createPortal(pos, normal, false)
        portal2.Touched:Connect(function(hit)
            onPortalTouched(hit, portal2)
        end)
        isFirstPortal = true
        portalLocked = true
        print("🟡 Портал 2 установлен! Порталы закреплены!")
    end
end

-- ===== ДОЛГОЕ НАЖАТИЕ =====
local function startHold(input)
    if isHolding or portalLocked then return end
    
    local char = player.Character
    if not char then return end
    if not char:FindFirstChild("EvilMortyPortalGun") then
        print("⚠️ Возьми пушку в руки!")
        return
    end
    
    local touchPosition = input.Position
    
    isHolding = true
    holdStartTime = tick()
    holdIndicator.Visible = true
    holdProgress.Size = UDim2.new(0, 0, 0, 4)
    
    local progressConnection
    progressConnection = RunService.RenderStepped:Connect(function()
        if not isHolding then
            progressConnection:Disconnect()
            holdIndicator.Visible = false
            return
        end
        
        local elapsed = tick() - holdStartTime
        local progress = math.min(elapsed / HOLD_DURATION, 1)
        holdProgress.Size = UDim2.new(progress, 0, 0, 4)
        
        if progress >= 1 then
            progressConnection:Disconnect()
            holdIndicator.Visible = false
            isHolding = false
            shootPortal(touchPosition)
        end
    end)
end

local function cancelHold()
    if isHolding then
        isHolding = false
        holdIndicator.Visible = false
    end
end

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startHold(input)
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        cancelHold()
    end
end)

-- ===== КЛАВИША R =====
userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        clearPortals()
    end
end)
--==================================================
-- PLAYER PORTAL PANEL
--==================================================

local Players = game:GetService("Players")

local selectedTargetPlayer = nil
local playerPortal = nil
local playerPortalTouchConnection = nil
local playerPortalTeleportCooldown = false


print("🟡 EVIL MORTY PORTAL GUN!")
print("🔫 Нажми 'Получить пушку', затем зажми на 2 секунды!")
print("🔄 Кнопки можно перетаскивать по экрану!")
