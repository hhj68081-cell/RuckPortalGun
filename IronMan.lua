local player = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== ПЕРЕМЕННЫЕ =====
local isActive = false
local highlightObjects = {}
local nameLabels = {}
local screenGui = nil
local radarGui = nil
local dotsContainer = nil
local radarUpdateConnection = nil
local scanGui = nil
local scanFrame = nil
local scanText = nil

-- ===== СОЗДАНИЕ HUD =====
local function createHUD()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IronManHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.DisplayOrder = 999
    screenGui.IgnoreGuiInset = true
    
    local orange = Color3.fromRGB(255, 100, 0)
    local orangeLight = Color3.fromRGB(255, 150, 50)
    
    local corners = {
        {0, 0, 0, 0}, {1, 0, -1, 0}, {0, 1, 0, -1}, {1, 1, -1, -1}
    }
    
    for _, c in ipairs(corners) do
        local x, y, dx, dy = c[1], c[2], c[3], c[4]
        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(0.12, 0, 0, 2)
        hLine.Position = UDim2.new(x == 0 and 0.02 or 0.86, 0, y == 0 and 0.02 or 0.94, 0)
        hLine.BackgroundColor3 = orange
        hLine.BackgroundTransparency = 0.2
        hLine.BorderSizePixel = 0
        hLine.Parent = screenGui
        
        local vLine = Instance.new("Frame")
        vLine.Size = UDim2.new(0, 2, 0.12, 0)
        vLine.Position = UDim2.new(x == 0 and 0.02 or 0.94, 0, y == 0 and 0.02 or 0.86, 0)
        vLine.BackgroundColor3 = orange
        vLine.BackgroundTransparency = 0.2
        vLine.BorderSizePixel = 0
        vLine.Parent = screenGui
    end
    
    for i = 1, 2 do
        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(0.8, 0, 0, 1)
        hLine.Position = UDim2.new(0.1, 0, i/3, 0)
        hLine.BackgroundColor3 = orange
        hLine.BackgroundTransparency = 0.85
        hLine.BorderSizePixel = 0
        hLine.Parent = screenGui
        
        local vLine = Instance.new("Frame")
        vLine.Size = UDim2.new(0, 1, 0.8, 0)
        vLine.Position = UDim2.new(i/3, 0, 0.1, 0)
        vLine.BackgroundColor3 = orange
        vLine.BackgroundTransparency = 0.85
        vLine.BorderSizePixel = 0
        vLine.Parent = screenGui
    end
    
    for i = 0, 1 do
        for j = 0, 1 do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0.05, 0, 0, 1)
            line.Position = UDim2.new(i == 0 and 0.05 or 0.9, 0, j == 0 and 0.05 or 0.9, 0)
            line.BackgroundColor3 = orange
            line.BackgroundTransparency = 0.5
            line.BorderSizePixel = 0
            line.Rotation = i == 0 and 45 or -45
            line.Parent = screenGui
        end
    end
    
    local centerCircle = Instance.new("ImageLabel")
    centerCircle.Size = UDim2.new(0.06, 0, 0.06, 0)
    centerCircle.Position = UDim2.new(0.47, 0, 0.47, 0)
    centerCircle.BackgroundTransparency = 1
    centerCircle.Image = "rbxasset://textures/ui/thumbnails/circle.png"
    centerCircle.ImageColor3 = orange
    centerCircle.ImageTransparency = 0.7
    centerCircle.Parent = screenGui
    
    for i = 0, 3 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.08, 0, 0, 1)
        line.Position = UDim2.new(0.47, 0, 0.47, 0)
        line.BackgroundColor3 = orange
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        line.Rotation = i * 90
        line.Parent = screenGui
    end
    
    local modeText = Instance.new("TextLabel")
    modeText.Size = UDim2.new(0.4, 0, 0.04, 0)
    modeText.Position = UDim2.new(0.3, 0, 0.92, 0)
    modeText.BackgroundTransparency = 1
    modeText.Text = "🔴 IRON MAN MODE"
    modeText.TextColor3 = orange
    modeText.TextSize = 16
    modeText.Font = Enum.Font.GothamBold
    modeText.Parent = screenGui
end

-- ===== РАДАР =====
local function createRadar()
    if radarGui then radarGui:Destroy() end
    
    radarGui = Instance.new("ScreenGui")
    radarGui.Name = "Radar"
    radarGui.ResetOnSpawn = false
    radarGui.Parent = player:WaitForChild("PlayerGui")
    
    local radarFrame = Instance.new("Frame")
    radarFrame.Size = UDim2.new(0, 120, 0, 120)
    radarFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    radarFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    radarFrame.BackgroundTransparency = 0.3
    radarFrame.BorderSizePixel = 2
    radarFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    radarFrame.Parent = radarGui
    
    local outerCircle = Instance.new("ImageLabel")
    outerCircle.Size = UDim2.new(1, 0, 1, 0)
    outerCircle.Position = UDim2.new(0, 0, 0, 0)
    outerCircle.BackgroundTransparency = 1
    outerCircle.Image = "rbxasset://textures/ui/thumbnails/circle.png"
    outerCircle.ImageColor3 = Color3.fromRGB(255, 100, 0)
    outerCircle.ImageTransparency = 0.7
    outerCircle.Parent = radarFrame
    
    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0.08, 0, 0.08, 0)
    centerDot.Position = UDim2.new(0.46, 0, 0.46, 0)
    centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    centerDot.BackgroundTransparency = 0.2
    centerDot.BorderSizePixel = 0
    centerDot.Parent = radarFrame
    
    dotsContainer = Instance.new("Frame")
    dotsContainer.Size = UDim2.new(1, 0, 1, 0)
    dotsContainer.Position = UDim2.new(0, 0, 0, 0)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.Parent = radarFrame
    
    return radarGui
end

local function updateRadar()
    if not dotsContainer then return end
    for _, child in ipairs(dotsContainer:GetChildren()) do child:Destroy() end
    
    local char = player.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local players = game:GetService("Players"):GetPlayers()
    local radarSize = dotsContainer.AbsoluteSize.X or 120
    
    for _, plr in ipairs(players) do
        if plr == player then continue end
        if not plr.Character then continue end
        local plrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
        if not plrRoot then continue end
        
        local delta = (plrRoot.Position - rootPart.Position)
        local distance = delta.Magnitude
        if distance > 50 then continue end
        
        local scale = 40 / 50
        local x = delta.X * scale + radarSize / 2
        local z = delta.Z * scale + radarSize / 2
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0, x - 3, 0, z - 3)
        dot.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        dot.BackgroundTransparency = 0.2
        dot.BorderSizePixel = 0
        dot.Parent = dotsContainer
    end
end

-- ===== ПОДСВЕТКА ИГРОКОВ =====
local function highlightPlayers()
    for _, obj in ipairs(highlightObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    highlightObjects = {}
    for _, label in ipairs(nameLabels) do
        if label and label.Parent then label:Destroy() end
    end
    nameLabels = {}
    
    local players = game:GetService("Players"):GetPlayers()
    for _, plr in ipairs(players) do
        if plr == player then continue end
        if not plr.Character then continue end
        
        local char = plr.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 100, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 150, 50)
        highlight.OutlineTransparency = 0.2
        highlight.Parent = char
        table.insert(highlightObjects, highlight)
        
        local label = Instance.new("BillboardGui")
        label.Size = UDim2.new(0, 200, 0, 60)
        label.StudsOffset = Vector3.new(0, 3.5, 0)
        label.AlwaysOnTop = true
        label.Parent = char
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(1, 0, 1, 0)
        mainFrame.BackgroundTransparency = 1
        mainFrame.Parent = label
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
        nameLabel.TextSize = 15
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = mainFrame
        
        local displayLabel = Instance.new("TextLabel")
        displayLabel.Size = UDim2.new(1, 0, 0.3, 0)
        displayLabel.Position = UDim2.new(0, 0, 0.4, 0)
        displayLabel.BackgroundTransparency = 1
        displayLabel.Text = plr.DisplayName or ""
        displayLabel.TextColor3 = Color3.fromRGB(255, 120, 0)
        displayLabel.TextSize = 12
        displayLabel.Font = Enum.Font.GothamMedium
        displayLabel.Parent = mainFrame
        
        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(1, 0, 0.3, 0)
        idLabel.Position = UDim2.new(0, 0, 0.7, 0)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = "ID: " .. plr.UserId
        idLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        idLabel.TextSize = 11
        idLabel.Font = Enum.Font.GothamMedium
        idLabel.Parent = mainFrame
        
        table.insert(nameLabels, label)
    end
end

-- ===== СКАНИРОВАНИЕ =====
local function createScanUI()
    if scanGui then scanGui:Destroy() end
    
    scanGui = Instance.new("ScreenGui")
    scanGui.Name = "ScanUI"
    scanGui.ResetOnSpawn = false
    scanGui.Parent = player:WaitForChild("PlayerGui")
    scanGui.DisplayOrder = 1000
    
    scanFrame = Instance.new("Frame")
    scanFrame.Size = UDim2.new(0, 280, 0, 150)
    scanFrame.Position = UDim2.new(0.5, -140, 0.5, -75)
    scanFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    scanFrame.BackgroundTransparency = 0.1
    scanFrame.BorderSizePixel = 2
    scanFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    scanFrame.Visible = false
    scanFrame.Parent = scanGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔍 СКАНИРОВАНИЕ"
    title.TextColor3 = Color3.fromRGB(255, 100, 0)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.Parent = scanFrame
    
    scanText = Instance.new("TextLabel")
    scanText.Size = UDim2.new(1, -10, 1, -25)
    scanText.Position = UDim2.new(0, 5, 0, 22)
    scanText.BackgroundTransparency = 1
    scanText.Text = "Наведите на игрока"
    scanText.TextColor3 = Color3.fromRGB(200, 200, 200)
    scanText.TextSize = 12
    scanText.TextXAlignment = Enum.TextXAlignment.Left
    scanText.TextYAlignment = Enum.TextYAlignment.Top
    scanText.Font = Enum.Font.GothamMedium
    scanText.Parent = scanFrame
end

local function updateScan()
    if not isActive then
        if scanFrame then scanFrame.Visible = false end
        return
    end
    
    local char = player.Character
    if not char then
        if scanFrame then scanFrame.Visible = false end
        return
    end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if scanFrame then scanFrame.Visible = false end
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then
        if scanFrame then scanFrame.Visible = false end
        return
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 100, raycastParams)
    
    if result and result.Instance then
        local hit = result.Instance
        local character = hit:FindFirstAncestorOfClass("Model")
        if character then
            local plr = game:GetService("Players"):GetPlayerFromCharacter(character)
            if plr and plr ~= player then
                local plrRoot = character:FindFirstChild("HumanoidRootPart")
                if plrRoot then
                    local distance = (plrRoot.Position - rootPart.Position).Magnitude
                    local humanoid = character:FindFirstChild("Humanoid")
                    local health = humanoid and math.floor((humanoid.Health / humanoid.MaxHealth) * 100) or 0
                    local team = plr.Team and plr.Team.Name or "Нет команды"
                    
                    -- === ИНВЕНТАРЬ ИГРОКА (УНИВЕРСАЛЬНЫЙ) ===
                    local inventory = {}
                    
                    -- 1. Backpack
                    local backpack = plr:FindFirstChild("Backpack")
                    if backpack then
                        for _, child in ipairs(backpack:GetChildren()) do
                            if child:IsA("Tool") then
                                table.insert(inventory, child.Name)
                            end
                        end
                    end
                    
                    -- 2. В руках персонажа
                    for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("Tool") then
                            table.insert(inventory, child.Name)
                        end
                    end
                    
                    -- 3. StarterPack
                    local starterPack = plr:FindFirstChild("StarterPack")
                    if starterPack then
                        for _, child in ipairs(starterPack:GetChildren()) do
                            if child:IsA("Tool") then
                                table.insert(inventory, child.Name)
                            end
                        end
                    end
                    
                    -- Убираем дубликаты
                    local uniqueInventory = {}
                    for _, item in ipairs(inventory) do
                        if not table.find(uniqueInventory, item) then
                            table.insert(uniqueInventory, item)
                        end
                    end
                    
                    local inventoryText = #uniqueInventory > 0 and table.concat(uniqueInventory, ", ") or "Пусто"
                    
                    scanText.Text = "👤 Имя: " .. plr.Name .. "\n"
                    scanText.Text = scanText.Text .. "📛 DisplayName: " .. plr.DisplayName .. "\n"
                    scanText.Text = scanText.Text .. "🆔 ID: " .. plr.UserId .. "\n"
                    scanText.Text = scanText.Text .. "❤️ Здоровье: " .. health .. "%\n"
                    scanText.Text = scanText.Text .. "📏 Расстояние: " .. math.floor(distance) .. " ст.\n"
                    scanText.Text = scanText.Text .. "🔰 Команда: " .. team .. "\n"
                    scanText.Text = scanText.Text .. "🎒 Инвентарь: " .. inventoryText
                    
                    scanFrame.Visible = true
                    return
                end
            end
        end
    end
    
    scanFrame.Visible = false
end

-- ===== ВКЛЮЧЕНИЕ =====
local function toggleMode()
    isActive = not isActive
    
    if isActive then
        createHUD()
        highlightPlayers()
        createRadar()
        updateRadar()
        createScanUI()
        
        if radarUpdateConnection then
            radarUpdateConnection:Disconnect()
        end
        radarUpdateConnection = RunService.RenderStepped:Connect(function()
            updateRadar()
            updateScan()
        end)
        warn("🔴 Режим Железного человека АКТИВИРОВАН!")
    else
        if screenGui then screenGui:Destroy() end
        screenGui = nil
        if radarGui then radarGui:Destroy() end
        radarGui = nil
        if scanGui then scanGui:Destroy() end
        scanGui = nil
        if radarUpdateConnection then
            radarUpdateConnection:Disconnect()
            radarUpdateConnection = nil
        end
        for _, obj in ipairs(highlightObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        highlightObjects = {}
        for _, label in ipairs(nameLabels) do
            if label and label.Parent then label:Destroy() end
        end
        nameLabels = {}
        warn("🔴 Режим Железного человека ДЕАКТИВИРОВАН!")
    end
end

-- ===== КНОПКА =====
local function createToggleButton()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "IronManButton"
    buttonGui.ResetOnSpawn = false
    buttonGui.Parent = player:WaitForChild("PlayerGui")
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 65)
    btn.Position = UDim2.new(0.85, -32.5, 0.15, -32.5)
    btn.Text = "🦾"
    btn.TextSize = 30
    btn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Parent = buttonGui
    
    btn.MouseButton1Click:Connect(function()
        toggleMode()
        btn.Text = isActive and "🦾" or "🦾"
        btn.BackgroundColor3 = isActive and Color3.fromRGB(200, 50, 0) or Color3.fromRGB(255, 100, 0)
    end)
    
    btn.TouchTap:Connect(function()
        toggleMode()
        btn.Text = isActive and "🦾" or "🦾"
        btn.BackgroundColor3 = isActive and Color3.fromRGB(200, 50, 0) or Color3.fromRGB(255, 100, 0)
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
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
    
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newX = startPos.X.Scale + delta.X / buttonGui.AbsoluteSize.X
            local newY = startPos.Y.Scale + delta.Y / buttonGui.AbsoluteSize.Y
            btn.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
end

createToggleButton()

warn("🦾 Нажми на кнопку, чтобы включить режим Железного человека!")
warn("🔍 Наведись на игрока, чтобы отсканировать его инвентарь!")
