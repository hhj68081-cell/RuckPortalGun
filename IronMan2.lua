--==================================================
-- STARK VISION HUD
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local CYAN = Color3.fromRGB(70, 220, 255)
local DARK = Color3.fromRGB(4, 14, 22)
local RED = Color3.fromRGB(255, 70, 70)
local GREY = Color3.fromRGB(100, 140, 150)

local VisionEnabled = false
local CurrentTarget = nil
local Highlights = {}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "StarkVisionHUD"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--==================================================
-- HELPERS
--==================================================

local function NewLabel(parent, text, size, position, textSize)

	local label = Instance.new("TextLabel")

	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position

	label.Text = text
	label.TextColor3 = CYAN
	label.TextSize = textSize
	label.Font = Enum.Font.GothamMedium

	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center

	label.Parent = parent

	return label
end

local function NewPanel(parent, name, size, position)

	local frame = Instance.new("Frame")

	frame.Name = name
	frame.Size = size
	frame.Position = position

	frame.BackgroundColor3 = DARK
	frame.BackgroundTransparency = 0.12

	frame.BorderSizePixel = 0
	frame.Parent = parent

	local stroke = Instance.new("UIStroke")

	stroke.Color = CYAN
	stroke.Thickness = 1
	stroke.Transparency = 0.15

	stroke.Parent = frame

	return frame
end

--==================================================
-- JARVIS
--==================================================

local Jarvis = NewPanel(
	Gui,
	"JARVIS",
	UDim2.fromOffset(520, 65),
	UDim2.new(0.5, -260, 0, 15)
)

local JarvisTitle = NewLabel(
	Jarvis,
	"J.A.R.V.I.S.",
	UDim2.fromOffset(110, 25),
	UDim2.fromOffset(12, 6),
	14
)

local JarvisStatus = NewLabel(
	Jarvis,
	"● ONLINE",
	UDim2.fromOffset(100, 20),
	UDim2.fromOffset(12, 37),
	10
)

local JarvisMessage = NewLabel(
	Jarvis,
	"Система готова.",
	UDim2.new(1, -135, 0, 45),
	UDim2.fromOffset(120, 10),
	15
)

--==================================================
-- JARVIS MESSAGES
--==================================================

local JarvisMessages = {
	"Система полностью активна.",
	"Все системы работают нормально.",
	"Сканирование пространства запущено.",
	"Сэр, я готов к вашим указаниям.",
	"Система наведения активна.",
	"Сенсоры работают корректно.",
	"Телеметрия обновлена.",
	"Система визуального анализа готова.",
	"Обнаружено движение.",
	"Получаю данные о цели.",
	"Идентификация цели завершена.",
	"Проверяю уровень угрозы.",
	"Расстояние до цели рассчитано.",
	"Цель находится под наблюдением.",
	"Тактический анализ завершён.",
	"Сканирование завершено.",
	"Все показатели находятся в пределах нормы.",
	"Сэр, я продолжаю наблюдение."
}

local function JarvisSay(text)

	if not VisionEnabled then
		return
	end

	JarvisMessage.TextTransparency = 1
	JarvisMessage.Text = text

	TweenService:Create(
		JarvisMessage,
		TweenInfo.new(0.2),
		{
			TextTransparency = 0
		}
	):Play()
end

--==================================================
-- PERSONAL STATUS
--==================================================

local MyPanel = NewPanel(
	Gui,
	"MyStats",
	UDim2.fromOffset(235, 205),
	UDim2.new(0, 15, 1, -220)
)

NewLabel(
	MyPanel,
	"PERSONAL STATUS",
	UDim2.fromOffset(210, 25),
	UDim2.fromOffset(10, 8),
	15
)

local MyStats = NewLabel(
	MyPanel,
	"",
	UDim2.fromOffset(210, 140),
	UDim2.fromOffset(10, 40),
	11
)

MyStats.TextYAlignment = Enum.TextYAlignment.Top

local HealthBackground = Instance.new("Frame")

HealthBackground.Size = UDim2.fromOffset(210, 8)
HealthBackground.Position = UDim2.fromOffset(10, 178)

HealthBackground.BackgroundColor3 =
	Color3.fromRGB(15, 30, 38)

HealthBackground.BorderSizePixel = 0
HealthBackground.Parent = MyPanel

local HealthBar = Instance.new("Frame")

HealthBar.Size = UDim2.fromScale(1, 1)

HealthBar.BackgroundColor3 = CYAN
HealthBar.BorderSizePixel = 0

HealthBar.Parent = HealthBackground

local HealthText = NewLabel(
	MyPanel,
	"HEALTH 100%",
	UDim2.fromOffset(210, 18),
	UDim2.fromOffset(10, 185),
	9
)

--==================================================
-- TARGET PANEL
--==================================================

local TargetPanel = NewPanel(
	Gui,
	"TargetAnalysis",
	UDim2.fromOffset(330, 335),
	UDim2.new(1, -350, 0.5, -167)
)

TargetPanel.Visible = false

NewLabel(
	TargetPanel,
	"TARGET ANALYSIS",
	UDim2.fromOffset(300, 30),
	UDim2.fromOffset(12, 10),
	19
)

local TargetName = NewLabel(
	TargetPanel,
	"",
	UDim2.fromOffset(300, 30),
	UDim2.fromOffset(12, 45),
	17
)

local TargetInfo = NewLabel(
	TargetPanel,
	"",
	UDim2.fromOffset(300, 115),
	UDim2.fromOffset(12, 82),
	13
)

TargetInfo.TextYAlignment = Enum.TextYAlignment.Top

NewLabel(
	TargetPanel,
	"VISIBLE INVENTORY",
	UDim2.fromOffset(300, 25),
	UDim2.fromOffset(12, 200),
	13
)

local InventoryText = NewLabel(
	TargetPanel,
	"",
	UDim2.fromOffset(300, 95),
	UDim2.fromOffset(12, 228),
	12
)

InventoryText.TextYAlignment = Enum.TextYAlignment.Top

--==================================================
-- CROSSHAIR
--==================================================

local Crosshair = Instance.new("Frame")

Crosshair.Size = UDim2.fromOffset(70, 70)
Crosshair.Position = UDim2.new(0.5, -35, 0.5, -35)

Crosshair.BackgroundTransparency = 1
Crosshair.Parent = Gui

local function CrossLine(size, position)

	local line = Instance.new("Frame")

	line.Size = size
	line.Position = position

	line.BackgroundColor3 = CYAN
	line.BorderSizePixel = 0

	line.Parent = Crosshair
end

CrossLine(
	UDim2.fromOffset(20, 1),
	UDim2.fromOffset(0, 34)
)

CrossLine(
	UDim2.fromOffset(20, 1),
	UDim2.fromOffset(50, 34)
)

CrossLine(
	UDim2.fromOffset(1, 20),
	UDim2.fromOffset(34, 0)
)

CrossLine(
	UDim2.fromOffset(1, 20),
	UDim2.fromOffset(34, 50)
)

--==================================================
-- INVENTORY
--==================================================

local function GetInventory(target)

	local result = {}

	local backpack =
		target:FindFirstChildOfClass("Backpack")

	if backpack then

		for _, item in ipairs(backpack:GetChildren()) do

			if item:IsA("Tool") then
				table.insert(result, item.Name)
			end

		end
	end

	local character = target.Character

	if character then

		for _, item in ipairs(character:GetChildren()) do

			if item:IsA("Tool") then
				table.insert(result, item.Name)
			end

		end
	end

	if #result == 0 then
		return "EMPTY"
	end

	return table.concat(result, "\n")
end

--==================================================
-- HIGHLIGHT
--==================================================

local function HighlightPlayer(target)

	if target == LocalPlayer then
		return
	end

	if not VisionEnabled then
		return
	end

	local character = target.Character

	if not character then
		return
	end

	if Highlights[target] then
		return
	end

	local highlight = Instance.new("Highlight")

	highlight.Name = "StarkHighlight"
	highlight.Adornee = character

	highlight.FillColor =
		Color3.fromRGB(30, 170, 255)

	highlight.FillTransparency = 0.8

	highlight.OutlineColor = CYAN
	highlight.OutlineTransparency = 0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = character

	Highlights[target] = highlight
end

local function RemoveHighlights()

	for target, highlight in pairs(Highlights) do

		if highlight then
			highlight:Destroy()
		end

		Highlights[target] = nil
	end
end

local function RefreshHighlights()

	if not VisionEnabled then
		RemoveHighlights()
		return
	end

	for _, target in ipairs(Players:GetPlayers()) do

		if target ~= LocalPlayer then
			HighlightPlayer(target)
		end

	end
end

Players.PlayerAdded:Connect(function(target)

	target.CharacterAdded:Connect(function()

		task.wait(0.5)

		if VisionEnabled then
			HighlightPlayer(target)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(target)

	if Highlights[target] then
		Highlights[target]:Destroy()
		Highlights[target] = nil
	end
end)

--==================================================
-- FIND PLAYER
--==================================================

local function GetPlayerFromPart(part)

	if not part then
		return nil
	end

	local character =
		part:FindFirstAncestorOfClass("Model")

	if not character then
		return nil
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

--==================================================
-- TARGET
--==================================================

local function ClearTarget()

	CurrentTarget = nil

	TargetPanel.Visible = false

	TargetName.Text = ""
	TargetInfo.Text = ""
	InventoryText.Text = ""
end

local function ShowTarget(target, distance)

	if not VisionEnabled then
		return
	end

	local character = target.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	CurrentTarget = target

	TargetPanel.Visible = true

	TargetName.Text =
		target.DisplayName

	local team = "NONE"

	if target.Team then
		team = target.Team.Name
	end

	TargetInfo.Text =
		"USERNAME:  " .. target.Name ..
		"\nUSER ID:   " .. tostring(target.UserId) ..
		"\nHEALTH:    " .. math.floor(humanoid.Health) ..
		" / " .. math.floor(humanoid.MaxHealth) ..
		"\nDISTANCE:  " .. math.floor(distance) .. " studs" ..
		"\nTEAM:      " .. team

	InventoryText.Text =
		GetInventory(target)

	JarvisSay(
		"Цель идентифицирована: " ..
		target.DisplayName
	)
end

--==================================================
-- CAMERA SCAN
--==================================================

local function ScanCamera()

	if not VisionEnabled then
		ClearTarget()
		return
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	local ray =
		camera:ViewportPointToRay(
			viewport.X / 2,
			viewport.Y / 2
		)

	local params = RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		LocalPlayer.Character
	}

	local result =
		workspace:Raycast(
			ray.Origin,
			ray.Direction * 1000,
			params
		)

	if not result then
		ClearTarget()
		return
	end

	local target =
		GetPlayerFromPart(result.Instance)

	if not target or target == LocalPlayer then
		ClearTarget()
		return
	end

	local character = target.Character

	if not character then
		ClearTarget()
		return
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		ClearTarget()
		return
	end

	local distance =
		(camera.CFrame.Position - root.Position).Magnitude

	if CurrentTarget ~= target then

		ShowTarget(target, distance)

	else

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then

			local team = "NONE"

			if target.Team then
				team = target.Team.Name
			end

			TargetInfo.Text =
				"USERNAME:  " .. target.Name ..
				"\nUSER ID:   " .. tostring(target.UserId) ..
				"\nHEALTH:    " .. math.floor(humanoid.Health) ..
				" / " .. math.floor(humanoid.MaxHealth) ..
				"\nDISTANCE:  " .. math.floor(distance) .. " studs" ..
				"\nTEAM:      " .. team
		end

		InventoryText.Text =
			GetInventory(target)
	end
end

--==================================================
-- MY STATS
--==================================================

local function UpdateMyStats()

	if not VisionEnabled then
		return
	end

	local character = LocalPlayer.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local health = math.max(0, humanoid.Health)
	local maxHealth = math.max(1, humanoid.MaxHealth)

	local percent =
		math.floor(
			health / maxHealth * 100
		)

	local team = "NONE"

	if LocalPlayer.Team then
		team = LocalPlayer.Team.Name
	end

	local rig = "UNKNOWN"

	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		rig = "R6"
	elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
		rig = "R15"
	end

	MyStats.Text =
		"PLAYER:    " .. LocalPlayer.Name ..
		"\nDISPLAY:   " .. LocalPlayer.DisplayName ..
		"\nUSER ID:   " .. tostring(LocalPlayer.UserId) ..
		"\nHEALTH:    " .. math.floor(health) .. " / " .. math.floor(maxHealth) ..
		"\nSPEED:     " .. math.floor(humanoid.WalkSpeed) ..
		"\nJUMP:      " .. math.floor(humanoid.JumpPower) ..
		"\nTEAM:      " .. team ..
		"\nRIG:       " .. rig ..
		"\nSTATUS:    " .. (health > 0 and "ONLINE" or "OFFLINE")

	HealthText.Text =
		"HEALTH " .. percent .. "%"

	HealthBar.Size =
		UDim2.new(
			math.clamp(health / maxHealth, 0, 1),
			0,
			1,
			0
		)

	if percent <= 25 then
		HealthBar.BackgroundColor3 = RED
	else
		HealthBar.BackgroundColor3 = CYAN
	end
end

--==================================================
-- VISION BUTTON
--==================================================

local VisionButton = Instance.new("TextButton")

VisionButton.Size =
	UDim2.fromOffset(145, 55)

VisionButton.Position =
	UDim2.new(0, 25, 0.5, -27)

VisionButton.BackgroundColor3 =
	Color3.fromRGB(5, 20, 28)

VisionButton.BackgroundTransparency = 0.05

VisionButton.BorderSizePixel = 0

VisionButton.Text =
	"VISION\nOFF"

VisionButton.TextColor3 = GREY
VisionButton.TextSize = 14

VisionButton.Font =
	Enum.Font.GothamBold

VisionButton.Parent = Gui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 7)
ButtonCorner.Parent = VisionButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = GREY
ButtonStroke.Thickness = 1.5
ButtonStroke.Parent = VisionButton

--==================================================
-- BUTTON STATE
--==================================================

local function UpdateButton()

	if VisionEnabled then

		VisionButton.Text =
			"VISION\nONLINE"

		VisionButton.TextColor3 =
			Color3.fromRGB(100, 240, 255)

		ButtonStroke.Color = CYAN

	else

		VisionButton.Text =
			"VISION\nOFF"

		VisionButton.TextColor3 = GREY

		ButtonStroke.Color = GREY
	end
end

--==================================================
-- ENABLE
--==================================================

local function EnableVision()

	if VisionEnabled then
		return
	end

	VisionEnabled = true

	Jarvis.Visible = true
	Crosshair.Visible = true
	MyPanel.Visible = true

	UpdateButton()
	RefreshHighlights()

	JarvisSay(
		"Vision Mode активирован, сэр."
	)
end

--==================================================
-- DISABLE
--==================================================

local function DisableVision()

	if not VisionEnabled then
		return
	end

	VisionEnabled = false

	RemoveHighlights()
	ClearTarget()

	Jarvis.Visible = false
	Crosshair.Visible = false
	MyPanel.Visible = false
	TargetPanel.Visible = false

	UpdateButton()
end

--==================================================
-- TOGGLE
--==================================================

local function ToggleVision()

	if VisionEnabled then
		DisableVision()
	else
		EnableVision()
	end
end

--==================================================
-- DRAG BUTTON
--==================================================

local Dragging = false
local DragStart
local ButtonStart
local TouchStart

VisionButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true

		DragStart = input.Position
		ButtonStart = VisionButton.Position
		TouchStart = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta =
			input.Position - DragStart

		VisionButton.Position =
			UDim2.new(
				ButtonStart.X.Scale,
				ButtonStart.X.Offset + delta.X,
				ButtonStart.Y.Scale,
				ButtonStart.Y.Offset + delta.Y
			)
	end
end)

VisionButton.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false

		local movement =
			(input.Position - TouchStart).Magnitude

		-- Если почти не двигали кнопку = нажатие
		if movement < 10 then
			ToggleVision()
		end
	end
end)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.H then
		ToggleVision()
	end
end)

--==================================================
-- JARVIS RANDOM MESSAGES
--==================================================

task.spawn(function()

	while true do

		task.wait(math.random(6, 10))

		if VisionEnabled then

			local message =
				JarvisMessages[
					math.random(
						1,
						#JarvisMessages
					)
				]

			JarvisSay(message)
		end
	end
end)

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()

	if VisionEnabled then

		UpdateMyStats()
		ScanCamera()

	end
end)

--==================================================
-- INITIAL STATE
--==================================================

Jarvis.Visible = false
Crosshair.Visible = false
MyPanel.Visible = false
TargetPanel.Visible = false

UpdateButton()
