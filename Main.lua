-- LocalScript
-- Place: StarterPlayer > StarterPlayerScripts
-- Строит CombatCoreGUI программно + логика + звук клика

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup
if getgenv().CombatCoreGUI then pcall(function() getgenv().CombatCoreGUI:Destroy() end) end
if getgenv().CombatCore then pcall(function() getgenv().CombatCore:Unload() end) end

local PALETTE = {
	BG       = Color3.fromRGB(26, 26, 36),
	MAIN_BG  = Color3.fromRGB(123, 68, 118),
	ACCENT   = Color3.fromRGB(187, 103, 180),
	TOGGLE   = Color3.fromRGB(131, 72, 126),
	KNOB     = Color3.fromRGB(187, 103, 180),
	CLOSE    = Color3.fromRGB(201, 51, 51),
	CLOSE_H  = Color3.fromRGB(255, 80, 80),
	TEXT     = Color3.fromRGB(221, 221, 221),
	WHITE    = Color3.fromRGB(255, 255, 255),
}

local FONT_TITLE = Font.new("rbxasset://fonts/families/JosefinSans.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local FONT_BODY  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FONT_BOLD  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local FONT_CLOSE = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

-- ======================
-- SCREEN GUI
-- ======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatCoreGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

getgenv().CombatCoreGUI = ScreenGui

-- ======================
-- CLICK SOUND
-- ======================

local ClickSound = Instance.new("Sound")
ClickSound.Name = "ClickSound"
ClickSound.SoundId = "rbxassetid://135201580846609"
ClickSound.Volume = 0.5
ClickSound.Parent = ScreenGui

local function playClickSound()
	if ClickSound then
		ClickSound.TimePosition = 0
		ClickSound:Play()
	end
end

-- ======================
-- HELPERS
-- ======================

local function stroke(parent, color)
	local s = Instance.new("UIStroke", parent)
	s.Thickness = 2
	s.Color = color or PALETTE.ACCENT
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

-- ======================
-- LOGO
-- ======================

local Logo = Instance.new("ImageButton")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 55, 0, 55)
Logo.Position = UDim2.new(0, 20, 0.5, -28)
Logo.BackgroundColor3 = PALETTE.BG
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Image = "rbxassetid://86997852791871"
Logo.Active = true
Logo.Parent = ScreenGui

Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
stroke(Logo)

local LogoScale = Instance.new("UIScale", Logo)
LogoScale.Scale = 1

local LOGO_IDS = {
	"rbxassetid://86997852791871",
	"rbxassetid://112323672996641",
	"rbxassetid://18228412275",
	"rbxassetid://89039412339198",
	"rbxassetid://116569660294918",
}
local li = (os.time() % #LOGO_IDS) + 1
Logo.Image = LOGO_IDS[li]

-- ======================
-- MAIN FRAME
-- ======================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Visible = false
Main.BorderSizePixel = 0
Main.BackgroundColor3 = PALETTE.MAIN_BG
Main.BackgroundTransparency = 0.25
Main.Size = UDim2.new(0, 245, 0, 193)
Main.Position = UDim2.new(0.4208, 0, 0.30804, 0)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
stroke(Main)

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 0.82

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Text = "Dueling Grounds"
Title.TextColor3 = PALETTE.WHITE
Title.FontFace = FONT_TITLE
Title.TextSize = 18
Title.Size = UDim2.new(0.65652, 0, -0.09668, 40)
Title.Position = UDim2.new(0.05475, 0, 0.1011, 0)
Title.Parent = Main

local Title1 = Instance.new("TextLabel")
Title1.Name = "Title1"
Title1.BackgroundTransparency = 1
Title1.Text = "Thanks for using :3"
Title1.TextColor3 = PALETTE.WHITE
Title1.FontFace = FONT_TITLE
Title1.TextSize = 18
Title1.TextScaled = true
Title1.TextWrapped = true
Title1.Size = UDim2.new(0.65652, 0, -0.16302, 40)
Title1.Position = UDim2.new(0.16924, 0, 1.04259, 0)
Title1.Parent = Main

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "close"
CloseBtn.Text = "X"
CloseBtn.TextColor3 = PALETTE.WHITE
CloseBtn.TextSize = 14
CloseBtn.TextScaled = true
CloseBtn.TextWrapped = true
CloseBtn.AutoButtonColor = false
CloseBtn.BackgroundColor3 = PALETTE.CLOSE
CloseBtn.FontFace = FONT_CLOSE
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.98955, -35, 0.03349, 5)
CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
stroke(CloseBtn)

local CloseScale = Instance.new("UIScale", CloseBtn)
CloseScale.Scale = 1

-- ======================
-- TOGGLE FACTORY
-- ======================

local function createToggle(yPos, label, defaultOn, onChanged)
	local frame = Instance.new("Frame")
	frame.Name = label:gsub("%s", "")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, -30, 0, 36)
	frame.Position = UDim2.new(0, 15, 0, yPos)
	frame.Parent = Main

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = PALETTE.TEXT
	lbl.TextSize = 19
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.FontFace = FONT_BODY
	lbl.Size = UDim2.new(0.65, 0, 1, 0)
	lbl.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Name = "toggle"
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = PALETTE.TOGGLE
	btn.Size = UDim2.new(0, 52, 0, 28)
	btn.Position = UDim2.new(1, -52, 0.5, -14)
	btn.Text = ""
	btn.Parent = frame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local st = Instance.new("UIStroke", btn)
	st.Name = "UIStroke1"
	st.Thickness = 2.4
	st.Color = PALETTE.ACCENT
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local knob = Instance.new("Frame", btn)
	knob.BackgroundColor3 = PALETTE.KNOB
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new(0, 3, 0.5, -11)

	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local icon = Instance.new("TextLabel", knob)
	icon.BackgroundTransparency = 1
	icon.Text = ""
	icon.TextSize = 12
	icon.TextColor3 = Color3.fromRGB(231, 231, 231)
	icon.FontFace = FONT_BOLD
	icon.Size = UDim2.new(1, 0, 1, 0)

	local OFF_POS = UDim2.new(0, 3, 0.5, -11)
	local ON_POS  = UDim2.new(1, -25, 0.5, -11)

	local state = defaultOn

	local function render()
		local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if state then
			TweenService:Create(btn, ti, { BackgroundColor3 = Color3.fromRGB(190, 30, 42) }):Play()
			TweenService:Create(st, ti, { Color = Color3.fromRGB(255, 65, 75), Thickness = 2 }):Play()
			TweenService:Create(knob, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = ON_POS, BackgroundColor3 = PALETTE.WHITE }):Play()
			icon.Text = "●"
		else
			TweenService:Create(btn, ti, { BackgroundColor3 = PALETTE.TOGGLE }):Play()
			TweenService:Create(st, ti, { Color = PALETTE.ACCENT, Thickness = 2.4 }):Play()
			TweenService:Create(knob, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = OFF_POS, BackgroundColor3 = PALETTE.KNOB }):Play()
			icon.Text = ""
		end
	end

	render()
	if onChanged then onChanged(state) end

	btn.MouseButton1Click:Connect(function()
		state = not state
		playClickSound()
		TweenService:Create(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 19, 0, 19) }):Play()
		task.delay(0.08, function()
			TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 22, 0, 22) }):Play()
		end)
		render()
		if onChanged then onChanged(state) end
	end)

	return { Frame = frame, Button = btn }
end

-- ======================
-- SIDE TOGGLE
-- ======================

local SideFrame = Instance.new("Frame")
SideFrame.Name = "SideToggle"
SideFrame.Visible = false
SideFrame.BackgroundTransparency = 1
SideFrame.Size = UDim2.new(0, 40, 0, 42)
SideFrame.Position = UDim2.new(1, -170, 0.4, 0)
SideFrame.Parent = ScreenGui

local AutoParryBtn = Instance.new("TextButton")
AutoParryBtn.Name = "Button Auto Parry"
AutoParryBtn.Text = "Auto Parry :3"
AutoParryBtn.TextColor3 = PALETTE.WHITE
AutoParryBtn.TextSize = 14
AutoParryBtn.AutoButtonColor = false
AutoParryBtn.BackgroundColor3 = PALETTE.MAIN_BG
AutoParryBtn.FontFace = FONT_TITLE
AutoParryBtn.Size = UDim2.new(0, 115, 0, 32)
AutoParryBtn.Position = UDim2.new(0, 0, 0, 5)
AutoParryBtn.Visible = false
AutoParryBtn.Parent = SideFrame
AutoParryBtn:SetAttribute("On", false)

Instance.new("UICorner", AutoParryBtn).CornerRadius = UDim.new(0, 4)
stroke(AutoParryBtn)

local ArrowBtn = Instance.new("TextButton")
ArrowBtn.Name = "< and >"
ArrowBtn.Text = "▶"
ArrowBtn.TextColor3 = PALETTE.WHITE
ArrowBtn.TextSize = 14
ArrowBtn.AutoButtonColor = false
ArrowBtn.BackgroundColor3 = PALETTE.MAIN_BG
ArrowBtn.FontFace = FONT_TITLE
ArrowBtn.Size = UDim2.new(0, 32, 0, 32)
ArrowBtn.Position = UDim2.new(0, 120, 0, 5)
ArrowBtn.Parent = SideFrame

Instance.new("UICorner", ArrowBtn)
stroke(ArrowBtn)

local LockBtn = Instance.new("TextButton")
LockBtn.Name = "Lock"
LockBtn.Text = "🔓"
LockBtn.TextColor3 = PALETTE.WHITE
LockBtn.TextSize = 14
LockBtn.BackgroundColor3 = PALETTE.MAIN_BG
LockBtn.FontFace = FONT_TITLE
LockBtn.Size = UDim2.new(0, 32, 0, 32)
LockBtn.Position = UDim2.new(0, 120, 0, 42)
LockBtn.Parent = SideFrame

Instance.new("UICorner", LockBtn)
stroke(LockBtn)

-- ======================
-- COMBAT CORE
-- ======================

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerCharacter = Remotes:WaitForChild("PlayerCharacter")
local ResolveImpact = PlayerCharacter:WaitForChild("Request"):WaitForChild("ResolveImpact")
local RequestHitboxOnImpact = PlayerCharacter.Request:WaitForChild("RequestHitboxOnImpact")

local Core = {
	Alive = true,
	Targeting = false,
	AutoParry = false,
	HitboxReach = true,
	ReachRange = 9,
	CurrentTarget = nil,
	Connections = {},
}
getgenv().CombatCore = Core

local GameManager, TargetLockController, MatchController
local function refreshControllers()
	if GameManager and TargetLockController and MatchController then return true end
	if not GameManager then
		local ok, m = pcall(require, ReplicatedStorage:WaitForChild("GameManager"))
		if ok then GameManager = m end
	end
	if GameManager then
		pcall(function()
			TargetLockController = GameManager:GetController("TargetLockController")
			MatchController = GameManager:GetController("MatchController")
		end)
	end
	return TargetLockController ~= nil
end

local function getRoot()
	local char = LocalPlayer.Character
	return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function isEnemy(model, player)
	if MatchController and type(MatchController.IsCharacterEnemyOfLocalPlayer) == "function" then
		local ok, e = pcall(function() return MatchController:IsCharacterEnemyOfLocalPlayer(model) end)
		if ok then return e == true end
	end
	if player and LocalPlayer.Team and player.Team then return player.Team ~= LocalPlayer.Team end
	return player ~= LocalPlayer
end

local function getClosestEnemy()
	local lr = getRoot()
	if not lr then return nil end
	local closest, minDist = nil, math.huge
	for _, model in CollectionService:GetTagged("CustomCharacter") do
		if model:IsDescendantOf(workspace) and model:GetAttribute("IsDead") ~= true then
			local uid = model:GetAttribute("UserId")
			local plr = uid and Players:GetPlayerByUserId(uid)
			if uid ~= LocalPlayer.UserId and isEnemy(model, plr) then
				local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				local hum = model:FindFirstChildOfClass("Humanoid")
				if part and hum and hum.Health > 0 then
					local d = (part.Position - lr.Position).Magnitude
					if d < minDist then
						minDist = d
						closest = { Part = part, Distance = d }
					end
				end
			end
		end
	end
	return closest
end

local resolutionHookTarget, resolutionHookOriginal, resolutionHookInstalled
local function installImpactHook()
	if resolutionHookInstalled or not Core.AutoParry then return end
	if type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then return end
	local ok, handler = pcall(function()
		return GameManager:GetController("CharacterController"):GetLocalCharacterHandler()
	end)
	local manager = ok and handler and handler.ActionManager
	if not manager or type(manager._computeImpactResolution) ~= "function" then return end

	resolutionHookTarget = manager._computeImpactResolution
	local okHook, original = pcall(hookfunction, resolutionHookTarget, newcclosure(function(self, impactData)
		if not Core.Alive or not Core.AutoParry then return resolutionHookOriginal(self, impactData) end
		local ch = self.CharacterHandler
		local pP, pB = ch.IsParrying, ch.IsBlocking
		ch.IsParrying = true
		ch.IsBlocking = true
		local results = table.pack(resolutionHookOriginal(self, impactData))
		ch.IsParrying = pP
		ch.IsBlocking = pB
		return table.unpack(results, 1, results.n)
	end))

	if okHook then
		resolutionHookOriginal = original
		resolutionHookInstalled = true
	end
end

if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(newcclosure) == "function" then
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()

		if Core.Alive and Core.AutoParry and self == ResolveImpact and method == "FireServer" then
			local args = { ... }
			if args[2] ~= "Parry" and args[2] ~= "Dodge" then
				args[2] = "Parry"
			end
			return oldNamecall(self, table.unpack(args))
		end

		if Core.Alive and Core.HitboxReach and self == RequestHitboxOnImpact and method == "FireServer" then
			local args = { ... }
			local tgt = Core.CurrentTarget
			local lr = getRoot()
			if lr and tgt and tgt.Part and tgt.Part:IsDescendantOf(workspace) and typeof(args[1]) == "CFrame" then
				local off = tgt.Part.Position - lr.Position
				local d = off.Magnitude
				if d > 0.05 and d <= Core.ReachRange then
					local origin = tgt.Part.Position - (off.Unit * 2.75)
					args[1] = CFrame.lookAt(origin, tgt.Part.Position)
					return oldNamecall(self, table.unpack(args))
				end
			end
		end

		return oldNamecall(self, ...)
	end))
end

table.insert(Core.Connections, RunService.Heartbeat:Connect(function()
	if not Core.Alive then return end
	refreshControllers()
	installImpactHook()
	if Core.Targeting then
		local t = getClosestEnemy()
		Core.CurrentTarget = t
		if TargetLockController then
			pcall(function() TargetLockController:SetTarget(t and t.Part or nil) end)
		end
	end
end))

function Core:Unload()
	self.Alive = false
	for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
	if TargetLockController then pcall(function() TargetLockController:SetTarget(nil) end) end
	getgenv().CombatCore = nil
end

-- ======================
-- TOGGLES WIRING
-- ======================

createToggle(55, "Auto Parry", false, function(state)
	Core.AutoParry = state
	AutoParryBtn:SetAttribute("On", state)
	TweenService:Create(AutoParryBtn, TweenInfo.new(0.18), {
		BackgroundColor3 = state and Color3.fromRGB(46, 160, 90) or PALETTE.MAIN_BG
	}):Play()
end)

createToggle(100, "Show Side Toggle", false, function(state)
	SideFrame.Visible = state
end)

createToggle(145, "Targeting", false, function(state)
	Core.Targeting = state
end)

-- ======================
-- SIDE BUTTON LOGIC
-- ======================

AutoParryBtn.MouseButton1Click:Connect(function()
	local on = not (AutoParryBtn:GetAttribute("On") == true)
	AutoParryBtn:SetAttribute("On", on)
	Core.AutoParry = on
	playClickSound()
	TweenService:Create(AutoParryBtn, TweenInfo.new(0.18), {
		BackgroundColor3 = on and Color3.fromRGB(46, 160, 90) or PALETTE.MAIN_BG
	}):Play()
end)

local isExpanded = false
local draggingSide = false

local function setExpanded(state)
	isExpanded = state
	AutoParryBtn.Visible = state
	ArrowBtn.Text = state and "◀" or "▶"
	SideFrame.Size = state and UDim2.new(0, 155, 0, 42) or UDim2.new(0, 40, 0, 42)
end

setExpanded(false)

ArrowBtn.MouseButton1Click:Connect(function()
	if draggingSide then return end
	playClickSound()
	setExpanded(not isExpanded)
end)

-- Lock
local locked = false
LockBtn.MouseButton1Click:Connect(function()
	locked = not locked
	LockBtn.Text = locked and "🔒" or "🔓"
	playClickSound()
end)

-- Drag SideToggle via arrow
local dragStartSide, startPosSide

UserInputService.InputBegan:Connect(function(input)
	if locked then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local ap = ArrowBtn.AbsolutePosition
	local as = ArrowBtn.AbsoluteSize
	local p = input.Position
	if p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y then
		draggingSide = true
		dragStartSide = p
		startPosSide = SideFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not draggingSide or locked then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local d = input.Position - dragStartSide
	SideFrame.Position = UDim2.new(
		startPosSide.X.Scale, startPosSide.X.Offset + d.X,
		startPosSide.Y.Scale, startPosSide.Y.Offset + d.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		if draggingSide then
			task.delay(0.05, function() draggingSide = false end)
		end
	end
end)

-- ======================
-- LOGO HOVER / DRAG / CLICK
-- ======================

local logoHovering = false
local function setLogoHover(state)
	if logoHovering == state then return end
	logoHovering = state
	TweenService:Create(LogoScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = state and 1.15 or 1 }):Play()
end

Logo.MouseEnter:Connect(function() setLogoHover(true) end)
Logo.MouseLeave:Connect(function() setLogoHover(false) end)

local function playLogoClick()
	TweenService:Create(LogoScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = 0.85 }):Play()
	task.delay(0.08, function()
		TweenService:Create(LogoScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = logoHovering and 1.15 or 1 }):Play()
	end)
end

-- === DRAG LOGO ===
local logoDragging = false
local logoDragMoved = false
local logoDragStart, logoStartPos

local DRAG_THRESHOLD = 6

local function pointInLogo(p)
	local lp, ls = Logo.AbsolutePosition, Logo.AbsoluteSize
	return p.X >= lp.X and p.X <= lp.X + ls.X
		and p.Y >= lp.Y and p.Y <= lp.Y + ls.Y
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then return end

	if pointInLogo(input.Position) then
		logoDragging = true
		logoDragMoved = false
		logoDragStart = input.Position
		logoStartPos = Logo.Position
		if input.UserInputType == Enum.UserInputType.Touch then
			setLogoHover(true)
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not logoDragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then return end

	local d = input.Position - logoDragStart
	if not logoDragMoved and math.abs(d.X) + math.abs(d.Y) >= DRAG_THRESHO
