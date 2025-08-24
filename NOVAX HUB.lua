-- NOVAX MOBILE MEGA HUB
-- by NOVAX (Ahmed) - NOVAX on TOP
-- All-in-one mobile-friendly tools hub

--== Services ==--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Rep = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local cam = Workspace.CurrentCamera

--== Utils ==--
local function notif(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title;Text=text;Duration=dur or 4})
    end)
end

local function makeCorner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = inst
    return c
end

local function makeStroke(inst, th, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Color = col or Color3.fromRGB(60,60,60)
    s.Transparency = tr or 0
    s.Parent = inst
    return s
end

local function dragify(frame)
    local dragging, dragInput, startPos, startInputPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = "OFF  |  "..text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.AutoButtonColor = true
    makeCorner(btn,10) makeStroke(btn,1.2,Color3.fromRGB(70,70,70))
    btn.Parent = parent
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "ON   |  " or "OFF  |  ")..text
        pcall(callback, state, btn)
    end)
    return btn
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.AutoButtonColor = true
    makeCorner(btn,10) makeStroke(btn,1.2,Color3.fromRGB(80,80,80))
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function() pcall(callback, btn) end)
    return btn
end

local function createRow(parent)
    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1,0,0,48)
    row.Parent = parent
    local ui = Instance.new("UIListLayout", row)
    ui.FillDirection = Enum.FillDirection.Horizontal
    ui.Padding = UDim.new(0,8)
    ui.VerticalAlignment = Enum.VerticalAlignment.Center
    ui.HorizontalAlignment = Enum.HorizontalAlignment.Left
    return row
end

local function miniButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, (parent.AbsoluteSize.X-16-8)/2, 1, -8)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    makeCorner(b,10) makeStroke(b,1,Color3.fromRGB(90,90,90))
    b.Parent = parent
    b.MouseButton1Click:Connect(function() pcall(callback,b) end)
    return b
end

--== GUI ==--
local sg = Instance.new("ScreenGui")
sg.Name = "NOVAX_MOBILE_MEGA_HUB"
sg.ResetOnSpawn = false
sg.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 460)
main.Position = UDim2.new(0.5, -180, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
makeCorner(main,16) makeStroke(main,2,Color3.fromRGB(0,255,128),0.3)
main.Parent = sg
dragify(main)
--== Resize (Bottom-Right, Mobile & PC) ==--
local resizer = Instance.new("Frame")
resizer.Size = UDim2.new(0, 28, 0, 28)              -- كبّر الهاندل عشان اللمس
resizer.Position = UDim2.new(1, -6, 1, -6)          -- على الحافة تماماً
resizer.AnchorPoint = Vector2.new(1,1)
resizer.BackgroundColor3 = Color3.fromRGB(0,255,150)
resizer.BackgroundTransparency = 0.1
resizer.Active = true
resizer.Parent = main
makeCorner(resizer, 10)
makeStroke(resizer, 1.5, Color3.fromRGB(0,120,80))

local resizing = false
local dragInput = nil
local startPos
local startSizePx

local MIN_W, MAX_W = 240, 1200
local MIN_H, MAX_H = 240, 1000

resizer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		startPos = input.Position
		startSizePx = main.AbsoluteSize
		dragInput = input
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
				dragInput = nil
			end
		end)
	end
end)

resizer.InputChanged:Connect(function(input)
	-- اربط نفس اللمسة/الماوس اللي بدأنا بيها
	if input.UserInputType == Enum.UserInputType.MouseMovement 
	or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	-- مهم: نتابع نفس الـ input فقط (عشان الموبايل)
	if resizing and input == dragInput then
		local delta = input.Position - startPos
		local newW = math.clamp(startSizePx.X + delta.X, MIN_W, MAX_W)
		local newH = math.clamp(startSizePx.Y + delta.Y, MIN_H, MAX_H)
		main.Size = UDim2.new(0, newW, 0, newH)
	end
end)
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,56)
header.BackgroundColor3 = Color3.fromRGB(20,20,20)
makeCorner(header,16)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,16,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "NOVAX TOOLS"
title.TextColor3 = Color3.fromRGB(0,255,150)

local hideBtn = Instance.new("TextButton", header)
hideBtn.Size = UDim2.new(0,100,0,36)
hideBtn.Position = UDim2.new(1, -110, 0.5, -18)
hideBtn.Text = "×"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 20
hideBtn.TextColor3 = Color3.fromRGB(10,10,10)
hideBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
makeCorner(hideBtn,12)

local tabsBar = Instance.new("Frame", main)
tabsBar.Size = UDim2.new(1, -25, 0, 35)
tabsBar.Position = UDim2.new(0,10,0,64)
tabsBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
makeCorner(tabsBar,10) makeStroke(tabsBar,1,Color3.fromRGB(60,60,60))

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -64-56-10)
content.Position = UDim2.new(0,10,0,64+38+10)
content.BackgroundColor3 = Color3.fromRGB(20,20,20)
makeCorner(content,12)

local function makeTabButton(text, xOrder)
    local b = Instance.new("TextButton", tabsBar)
    b.Size = UDim2.new(0, math.floor((tabsBar.AbsoluteSize.X-10)/4), 1, 0)
    b.Position = UDim2.new(0, 8 + (xOrder * (math.floor((tabsBar.AbsoluteSize.X-10)/4)+6)), 0, 0)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 16
    b.Font = Enum.Font.Gotham
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    makeCorner(b,8) makeStroke(b,1,Color3.fromRGB(70,70,70))
    return b
end

tabsBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    for _,c in ipairs(tabsBar:GetChildren()) do
        if c:IsA("TextButton") then
            c.Size = UDim2.new(0, math.floor((tabsBar.AbsoluteSize.X-10)/4), 1, 0)
            local idx = c:GetAttribute("Index") or 0
            c.Position = UDim2.new(0, 8 + (idx * (math.floor((tabsBar.AbsoluteSize.X-10)/4)+6)), 0, 0)
        end
    end
end)

local function makeScrollPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.ScrollBarImageTransparency = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Parent = content
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0,8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingLeft = UDim.new(0,8)
    pad.PaddingRight = UDim.new(0,8)
    pad.PaddingTop = UDim.new(0,8)
    pad.PaddingBottom = UDim.new(0,8)
    return page
end

local pages = {
    Movement = makeScrollPage(),
    Visual   = makeScrollPage(),
    Utility  = makeScrollPage(),
    System   = makeScrollPage(),
}

for name,pg in pairs(pages) do pg.Visible = false end

local tabNames = {"Movement","Visual","Utility","System"}
local tabButtons = {}
for i,name in ipairs(tabNames) do
    local b = makeTabButton(name, i-1)
    b:SetAttribute("Index", i-1)
    tabButtons[name] = b
end

local function setTab(name)
    for n,pg in pairs(pages) do pg.Visible = (n==name) end
    for n,btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (n==name) and Color3.fromRGB(0,170,110) or Color3.fromRGB(45,45,45)
    end
end

for n,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() setTab(n) end)
end
setTab("Movement")

-- Hide
hideBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    notif("NOVAX HUB","Tap the icon to show",5)
end)

-- Tiny dot to show again
----------------------------------------------------------------
-- MOVEMENT TAB
----------------------------------------------------------------
local mv = pages.Movement

-- Tap Teleport (toggle)
local tapTPConn
local minPressTime = 0.3 -- مدة الضغط بالثواني المطلوبة قبل النقل

createToggle(mv, "Tap Teleport", function(on)
    if on then
        local pressStart
        tapTPConn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                pressStart = tick() -- وقت بداية الضغط
            end
        end)

        local releaseConn
        releaseConn = UIS.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pressDuration = tick() - (pressStart or tick())
                if pressDuration >= minPressTime then
                    local pos = input.Position
                    local unitRay = cam:ViewportPointToRay(pos.X, pos.Y)
                    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
                    local hit, hitPos = Workspace:FindPartOnRay(ray, char)
                    if hitPos then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = CFrame.new(hitPos + Vector3.new(0,3,0)) end
                    end
                end
            end
        end)

        notif("Tap TP","Long press to teleport",3)

        -- حفظ الاتصال الثاني عشان نفصله بعد كده
        tapTPConn.ReleaseConn = releaseConn
    else
        if tapTPConn then
            tapTPConn:Disconnect()
            if tapTPConn.ReleaseConn then tapTPConn.ReleaseConn:Disconnect() end
        end
    end
end)

-- Fly (mobile buttons)
local flyOn = false
local flyBV
local flySpeed = 50
local flyUp, flyDown

createToggle(mv, "Fly (Mobile Controls)", function(on)
    local hrp = (plr.Character or plr.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
    if on then
        flyOn = true
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBV.Velocity = Vector3.new()
        flyBV.Parent = hrp

        -- إنشاء أزرار الطيران
        flyUp = Instance.new("TextButton", sg)
        flyUp.Size = UDim2.new(0,80,0,80)
        flyUp.Position = UDim2.new(1,-90,1,-180)
        flyUp.Text = "↑"; flyUp.TextScaled = true
        flyUp.BackgroundColor3 = Color3.fromRGB(0,170,110)
        makeCorner(flyUp,12)

        flyDown = Instance.new("TextButton", sg)
        flyDown.Size = UDim2.new(0,80,0,80)
        flyDown.Position = UDim2.new(1,-90,1,-90)
        flyDown.Text = "↓"; flyDown.TextScaled = true
        flyDown.BackgroundColor3 = Color3.fromRGB(0,170,110)
        makeCorner(flyDown,12)

        local upHeld, downHeld = false,false

        local function bindHold(btn, setter)
            btn.MouseButton1Down:Connect(function() setter(true) end)
            btn.MouseButton1Up:Connect(function() setter(false) end)
            btn.TouchLongPress:Connect(function(_,state)
                if state=="End" then setter(false) end
            end)
        end
        bindHold(flyUp,function(v) upHeld=v end)
        bindHold(flyDown,function(v) downHeld=v end)

        local moveConn
        moveConn = RS.RenderStepped:Connect(function()
            if not flyOn then moveConn:Disconnect() return end
            local dir = Vector3.new()
            local camCF = cam.CFrame
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local md = hum.MoveDirection
                local forward = camCF.LookVector
                local right = camCF.RightVector
                dir = (forward * md.Z + right * md.X)
            end
            local y = (upHeld and 1 or 0) + (downHeld and -1 or 0)
            flyBV.Velocity = (dir * flySpeed) + Vector3.new(0,y*flySpeed,0)
        end)

        notif("Fly","Use joystick to move, ↑/↓ to change height",4)
    else
        flyOn = false
        if flyBV then flyBV:Destroy() end
        if flyUp then flyUp:Destroy() end
        if flyDown then flyDown:Destroy() end
    end
end)
-- Noclip
local noclipConn
createToggle(mv, "Noclip", function(on)
    if on then
        noclipConn = RS.Stepped:Connect(function()
            local c = plr.Character
            if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end)

-- Speed & Jump rows
do
    local row = createRow(mv)
    local spd = 16
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then spd = hum.WalkSpeed end
    miniButton(row, "Speed +", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = math.clamp(h.WalkSpeed + 4, 8, 200) notif("Speed","WalkSpeed = "..h.WalkSpeed,2) end
    end)
    miniButton(row, "Speed -", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = math.clamp(h.WalkSpeed - 4, 8, 200) notif("Speed","WalkSpeed = "..h.WalkSpeed,2) end
    end)
end

do
    local row = createRow(mv)
    miniButton(row, "Jump +", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = math.clamp(h.JumpPower + 10, 10, 300) notif("Jump","JumpPower = "..h.JumpPower,2) end
    end)
    miniButton(row, "Jump -", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = math.clamp(h.JumpPower - 10, 10, 300) notif("Jump","JumpPower = "..h.JumpPower,2) end
    end)
end

-- Infinite Jump
local infJumpConn
createToggle(mv, "Infinite Jump", function(on)
    if on then
        infJumpConn = UIS.JumpRequest:Connect(function()
            local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() end
    end
end)

-- Gravity
do
    local row = createRow(mv)
    miniButton(row, "Gravity +", function()
        Workspace.Gravity = math.clamp(Workspace.Gravity + 25, 0, 400)
        notif("Gravity","Gravity = "..math.floor(Workspace.Gravity),2)
    end)
    miniButton(row, "Gravity -", function()
        Workspace.Gravity = math.clamp(Workspace.Gravity - 25, 0, 400)
        notif("Gravity","Gravity = "..math.floor(Workspace.Gravity),2)
    end)
end

----------------------------------------------------------------
-- VISUAL TAB (ESP, etc.)
----------------------------------------------------------------
local vs = pages.Visual

-- Player ESP (Highlight + Billboard name + distance)
local espOn = false
local espFolder = Instance.new("Folder", sg); espFolder.Name = "NOVAX_ESP"
local function clearESP()
    for _,v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end
local function addESPForCharacter(character)
    if not character then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255,80,80)
    hl.OutlineTransparency = 0
    hl.Adornee = character
    hl.Parent = espFolder
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,200,0,40)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 2000
        bb.Adornee = hrp
        bb.Parent = espFolder
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        local function updateText()
            local d = (cam.CFrame.Position - hrp.Position).Magnitude
            local name = character.Name
            lbl.Text = string.format("%s  [%.0f]", name, d)
        end
        RS.RenderStepped:Connect(function()
            if hrp and hrp.Parent then updateText() end
        end)
    end
end

createToggle(vs, "ESP Players", function(on)
    espOn = on
    clearESP()
    if on then
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= plr then
                addESPForCharacter(p.Character or p.CharacterAdded:Wait())
                p.CharacterAdded:Connect(function(ch)
                    if espOn then addESPForCharacter(ch) end
                end)
            end
        end
        notif("ESP","Enabled for players",3)
    else
        clearESP()
    end
end)

-- Tools ESP (highlights Tools in Workspace)
local toolsESPOn = false
local toolsFolder = Instance.new("Folder", sg); toolsFolder.Name="NOVAX_ESP_TOOLS"
local function refreshToolsESP()
    for _,v in ipairs(toolsFolder:GetChildren()) do v:Destroy() end
    for _,d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Tool") and d.Parent == Workspace then
            local handle = d:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0,150,0,30); bb.AlwaysOnTop = true; bb.Adornee = handle; bb.Parent = toolsFolder
                local lb = Instance.new("TextLabel", bb)
                lb.BackgroundTransparency = 1; lb.Size = UDim2.new(1,0,1,0)
                lb.Text = "[TOOL] "..d.Name; lb.TextColor3 = Color3.fromRGB(0,255,170); lb.Font = Enum.Font.GothamBold; lb.TextScaled = true
            end
        end
    end
end
createToggle(vs, "ESP Tools (Workspace)", function(on)
    toolsESPOn = on
    for _,v in ipairs(toolsFolder:GetChildren()) do v:Destroy() end
    if on then
        refreshToolsESP()
        notif("ESP Tools","Scanning workspace for Tools…",3)
    end
end)

-- Night Vision / FullBright
createToggle(vs, "FullBright", function(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
        notif("FullBright","ON",2)
    else
        Lighting.GlobalShadows = true
        -- لا نعيد القيم الأصلية بدقة لتجنب العبث بخريطة؛ فقط إشعار
        notif("FullBright","OFF",2)
    end
end)

----------------------------------------------------------------
-- UTILITY TAB
----------------------------------------------------------------
local ut = pages.Utility

-- Console (Log viewer)
local consoleOpen = false
local consoleFrame, consoleList
createToggle(ut, "Console (logs viewer)", function(on)
    consoleOpen = on
    if on then
        if not consoleFrame then
            consoleFrame = Instance.new("Frame", sg)
            consoleFrame.Size = UDim2.new(0.6,0,0.45,0)
            consoleFrame.Position = UDim2.new(0.2,0,0.05,0)
            consoleFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
            makeCorner(consoleFrame,14) makeStroke(consoleFrame,2,Color3.fromRGB(0,255,150),0.2)
            local title = Instance.new("TextLabel", consoleFrame)
            title.Size = UDim2.new(1,0,0,32); title.BackgroundTransparency = 1
            title.Text = "NOVAX CONSOLE"; title.TextColor3 = Color3.fromRGB(0,255,150)
            title.Font = Enum.Font.GothamBold; title.TextSize = 18
            local scroll = Instance.new("ScrollingFrame", consoleFrame)
            scroll.Size = UDim2.new(1,-10,1,-40); scroll.Position = UDim2.new(0,5,0,36)
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.BackgroundColor3 = Color3.fromRGB(20,20,20)
            makeCorner(scroll,10)
            consoleList = Instance.new("UIListLayout", scroll); consoleList.Padding = UDim.new(0,4)
        end
        consoleFrame.Visible = true
        if not consoleFrame:GetAttribute("Hooked") then
            consoleFrame:SetAttribute("Hooked", true)
            LogService.MessageOut:Connect(function(msg, t)
                if consoleFrame and consoleFrame.Visible then
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, -10, 0, 18); l.BackgroundTransparency = 1
                    l.TextXAlignment = Enum.TextXAlignment.Left
                    l.Text = tostring(msg)
                    l.Font = Enum.Font.Code; l.TextSize = 14
                    l.TextColor3 = t == Enum.MessageType.MessageError and Color3.fromRGB(255,120,120) or Color3.fromRGB(220,220,220)
                    l.Parent = consoleFrame:FindFirstChildOfClass("ScrollingFrame")
                end
            end)
        end
        notif("Console","Open (F9 also shows Roblox console)",3)
    else
        if consoleFrame then consoleFrame.Visible = false end
    end
end)

createButton(ut, "Console: Clear", function()
    if consoleFrame then
        local scroll = consoleFrame:FindFirstChildOfClass("ScrollingFrame")
        if scroll then for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end end
    end
end)

-- Click Delete (client-side)
local clickDelConn
createToggle(ut, "Click Delete", function(on)
    if on then
        clickDelConn = UIS.InputBegan:Connect(function(input,gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position
                local unitRay = cam:ViewportPointToRay(pos.X, pos.Y)
                local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
                local hit = Workspace:FindPartOnRay(ray, char)
                if hit and hit.Parent then
                    hit.Parent:Destroy()
                    notif("Delete","Deleted "..hit.Parent.Name,2)
                end
            end
        end)
        notif("Click Delete","Tap an object to delete (client)",4)
    else
        if clickDelConn then clickDelConn:Disconnect() end
    end
end)

-- Sit / Stand
do
    local row = createRow(ut)
    miniButton(row, "Sit", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.Sit = true end
    end)
    miniButton(row, "Stand", function()
        local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.Sit = false end
    end)
end

-- Spin character (toggle)
local spinConn
createToggle(ut, "Spin Character", function(on)
    if on then
        local hrp = (plr.Character or plr.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        local ang = 0
        spinConn = RS.RenderStepped:Connect(function(dt)
            ang = ang + dt*2
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 2*dt, 0)
        end)
    else
        if spinConn then spinConn:Disconnect() end
    end
end)

-- GodMode (client attempt)
local godConn
createToggle(ut, "GodMode (client)", function(on)
    if on then
        godConn = RS.Heartbeat:Connect(function()
            local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
            if h then h.Health = math.max(h.Health, h.MaxHealth) end
        end)
        notif("GodMode","Client-side, may not bypass server damage",4)
    else
        if godConn then godConn:Disconnect() end
    end
end)

----------------------------------------------------------------
-- SYSTEM TAB (reset, rejoin, hide, about)
----------------------------------------------------------------
local sy = pages.System

createButton(sy, "Hide/Show HUB", function()
    main.Visible = not main.Visible
end)

createButton(sy, "Reset Character", function()
    local h = (plr.Character or plr.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    if h then h.Health = 0 end
end)

createButton(sy, "Rejoin (same place)", function()
    local TeleportService = game:GetService("TeleportService")
    pcall(function() TeleportService:Teleport(game.PlaceId, plr) end)
end)

createButton(sy, "Clear ESP/Tools ESP", function()
    clearESP()
    for _,v in ipairs(toolsFolder:GetChildren()) do v:Destroy() end
end)

createButton(sy, "About", function()
    notif("NOVAX HUB","Mobile Mega Hub • by NOVAX (Ahmed). NOVAX on TOP!",6)
end)

-- Auto refresh hooks
Players.PlayerAdded:Connect(function(p)
    if espOn then
        p.CharacterAdded:Connect(function(ch) addESPForCharacter(ch) end)
    end
end)
Workspace.DescendantAdded:Connect(function(d)
    if toolsESPOn and d:IsA("Tool") and d.Parent == Workspace then
        refreshToolsESP()
    end
end)
Workspace.DescendantRemoving:Connect(function(d)
    if toolsESPOn and d:IsA("Tool") then
        refreshToolsESP()
    end
end)

notif("NOVAX HUB","Loaded ✅  — Tabs: Movement / Visual / Utility / System",6)

----------------------------------------------------------------
--== VIDEO INTRO / THEMES / LANGUAGES / SHORTCUTS / ICON ==--
----------------------------------------------------------------
-- Draggable GUI Icon (floating opener)
do
    local iconBtn = Instance.new("ImageButton")
    iconBtn.Name = "NOVAX_Icon"
    iconBtn.Image = "rbxassetid://119884391866485" -- <<< ضع الـ ID هنا لاحقا
    iconBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    iconBtn.Size = UDim2.new(0,56,0,56)
    iconBtn.Position = UDim2.new(0,20,0,120)
    iconBtn.AutoButtonColor = true
    iconBtn.Parent = sg
    makeCorner(iconBtn, 14) makeStroke(iconBtn, 1.5, Color3.fromRGB(0,255,150), 0.2)

    local dragging, dragInput, startPos, startInputPos
    iconBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = iconBtn.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    iconBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            iconBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    iconBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)
end

-- Close button style helper (red square with × on right + logo on left)
local function buildTopBar(parent, titleText)
    local top = Instance.new("Frame", parent)
    top.Name = "ModalTop"
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = Color3.fromRGB(25,25,25)
    makeCorner(top, 10) makeStroke(top,1.2,Color3.fromRGB(70,70,70),0.2)

    -- Left Logo (same icon as GUI)
    local logo = Instance.new("ImageLabel", top)
    logo.Size = UDim2.new(0,32,0,32)
    logo.Position = UDim2.new(0,8,0.5,-16)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://PUT_UR_ID_HERE"

    -- Title
    local lbl = Instance.new("TextLabel", top)
    lbl.Size = UDim2.new(1,-120,1,0)
    lbl.Position = UDim2.new(0,48,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = Color3.fromRGB(200,255,230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button (red square "×" on right)
    local close = Instance.new("TextButton", top)
    close.Size = UDim2.new(0,36,0,36)
    close.Position = UDim2.new(1,-40,0.5,-18)
    close.Text = "×"
    close.TextScaled = true
    close.BackgroundColor3 = Color3.fromRGB(200,40,40)
    close.TextColor3 = Color3.new(1,1,1)
    makeCorner(close, 6)
    makeStroke(close, 1.2, Color3.fromRGB(120,0,0), 0.1)
    return top, close
end

-- Search bar helper
local function buildSearchBar(parent, placeholder)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1,-16,0,36)
    holder.Position = UDim2.new(0,8,0,48)
    holder.BackgroundColor3 = Color3.fromRGB(30,30,30)
    makeCorner(holder,8) makeStroke(holder,1,Color3.fromRGB(60,60,60),0.2)
    local tb = Instance.new("TextBox", holder)
    tb.Size = UDim2.new(1,-12,1,-8)
    tb.Position = UDim2.new(0,6,0,4)
    tb.BackgroundTransparency = 1
    tb.PlaceholderText = placeholder or "Search..."
    tb.Text = ""
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 16
    tb.TextColor3 = Color3.new(1,1,1)
    tb.ClearTextOnFocus = false
    return tb
end

-- Scroll area helper
local function buildScroll(parent, yStart)
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-16,1,-(yStart or 92))
    scroll.Position = UDim2.new(0,8,0,(yStart or 92))
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    return scroll
end

-- THEME SYSTEM
local Themes = {
    ["Default"] = {
        main = Color3.fromRGB(25,25,25),
        header = Color3.fromRGB(20,20,20),
        accent = Color3.fromRGB(0,255,150),
        tab = Color3.fromRGB(45,45,45),
        content = Color3.fromRGB(20,20,20),
    },
    ["Gold"] = {
        main = Color3.fromRGB(30,24,8),
        header = Color3.fromRGB(26,20,6),
        accent = Color3.fromRGB(212,175,55),
        tab = Color3.fromRGB(55,45,15),
        content = Color3.fromRGB(26,22,10),
    },
    ["Silver"] = {
        main = Color3.fromRGB(36,36,40),
        header = Color3.fromRGB(28,28,32),
        accent = Color3.fromRGB(192,192,192),
        tab = Color3.fromRGB(52,52,58),
        content = Color3.fromRGB(30,30,34),
    },
    ["Copper"] = {
        main = Color3.fromRGB(42,24,16),
        header = Color3.fromRGB(36,20,14),
        accent = Color3.fromRGB(184,115,51),
        tab = Color3.fromRGB(58,38,24),
        content = Color3.fromRGB(40,24,16),
    },
    ["Emerald"] = {
        main = Color3.fromRGB(16,30,24),
        header = Color3.fromRGB(12,24,20),
        accent = Color3.fromRGB(80,200,120),
        tab = Color3.fromRGB(28,48,38),
        content = Color3.fromRGB(14,26,22),
    },
    ["Amethyst"] = {
        main = Color3.fromRGB(28,16,36),
        header = Color3.fromRGB(22,12,30),
        accent = Color3.fromRGB(155,89,182),
        tab = Color3.fromRGB(40,24,52),
        content = Color3.fromRGB(24,14,34),
    },
}

local function applyTheme(t)
    local th = Themes[t] or Themes["Default"]
    main.BackgroundColor3 = th.main
    header.BackgroundColor3 = th.header
    title.TextColor3 = th.accent
    tabsBar.BackgroundColor3 = th.tab
    content.BackgroundColor3 = th.content
    for _,s in ipairs(main:GetDescendants()) do
        if s:IsA("UIStroke") then
            s.Color = th.accent
            s.Transparency = 0.3
        end
    end
    notif("Theme", "Applied: "..t, 3)
end

-- LANGUAGES (EN + AR)
local Lang = "EN"
local Dict = {
    EN = {
        THEMES = "Themes",
        LANGS = "Languages",
        SHORTCUT = "Add Shortcut",
        SEARCH = "Search...",
        NOVAX_TOOLS = "NOVAX TOOLS",
        SYSTEM = "System",
        MOVEMENT = "Movement",
        VISUAL = "Visual",
        UTILITY = "Utility",
    },
    AR = {
        THEMES = "الثيمات",
        LANGS = "اللغات",
        SHORTCUT = "إضافة اختصار",
        SEARCH = "بحث...",
        NOVAX_TOOLS = "NOVAX TOOLS",
        SYSTEM = "النظام",
        MOVEMENT = "الحركة",
        VISUAL = "المرئي",
        UTILITY = "الأدوات",
    }
}

local function setLanguage(l)
    Lang = (l=="AR") and "AR" or "EN"
    title.Text = Dict[Lang].NOVAX_TOOLS
    tabButtons.Movement.Text = Dict[Lang].MOVEMENT
    tabButtons.Visual.Text   = Dict[Lang].VISUAL
    tabButtons.Utility.Text  = Dict[Lang].UTILITY
    tabButtons.System.Text   = Dict[Lang].SYSTEM
    notif("Language","Set to "..Lang,2)
end

-- SHORTCUTS SYSTEM
local shortcutHolder = Instance.new("Folder", sg); shortcutHolder.Name = "NOVAX_Shortcuts"
local function createShortcutFor(buttonText, callback)
    local sc = Instance.new("TextButton", sg)
    sc.Size = UDim2.new(0,120,0,40)
    sc.Position = UDim2.new(0.5, -60, 0.85, 0)
    sc.BackgroundColor3 = Color3.fromRGB(40,40,40)
    sc.Text = buttonText
    sc.TextColor3 = Color3.new(1,1,1)
    sc.Font = Enum.Font.GothamBold
    sc.TextSize = 16
    makeCorner(sc,10) makeStroke(sc,1.2,Color3.fromRGB(80,80,80),0.2)
    dragify(sc)
    sc.MouseButton1Click:Connect(function() pcall(callback, sc) end)
    sc.Parent = shortcutHolder
end

--== THEMES / LANGUAGES / SHORTCUTS MODALS (inside System tab) ==--
do
    -- Themes Button
    local btnThemes = createButton(sy, "Themes", function()
        local dialog = Instance.new("Frame", sg)
        dialog.Size = UDim2.new(0, 340, 0, 420)
        dialog.Position = UDim2.new(0.5,-170, 0.5,-210)
        dialog.BackgroundColor3 = Color3.fromRGB(22,22,22)
        makeCorner(dialog,14) makeStroke(dialog,2,Color3.fromRGB(0,255,150),0.2)

        local top, close = buildTopBar(dialog, Dict[Lang].THEMES)
        local sbox = buildSearchBar(dialog, Dict[Lang].SEARCH)
        local list = buildScroll(dialog, 92)

        local function addThemeItem(name)
            local b = Instance.new("TextButton", list)
            b.Size = UDim2.new(1,-8,0,40)
            b.Text = name
            b.Font = Enum.Font.Gotham
            b.TextSize = 16
            b.BackgroundColor3 = Color3.fromRGB(32,32,32)
            b.TextColor3 = Color3.new(1,1,1)
            makeCorner(b,8) makeStroke(b,1,Color3.fromRGB(70,70,70),0.2)
            b.MouseButton1Click:Connect(function()
                main.Visible = false
                applyTheme(name)
                PlayIntroVideo(INTRO_VIDEO_URL, 5, true)
                dialog:Destroy()
            end)
        end

        for name,_ in pairs(Themes) do addThemeItem(name) end

        sbox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(sbox.Text)
            for _,b in ipairs(list:GetChildren()) do
                if b:IsA("TextButton") then
                    b.Visible = (q=="" or string.find(string.lower(b.Text), q, 1, true) ~= nil)
                end
            end
        end)

        close.MouseButton1Click:Connect(function() dialog:Destroy() end)
    end)
    btnThemes.Text = Dict[Lang].THEMES

    -- Languages Button
    local btnLang = createButton(sy, "Languages", function()
        local dialog = Instance.new("Frame", sg)
        dialog.Size = UDim2.new(0, 340, 0, 420)
        dialog.Position = UDim2.new(0.5,-170, 0.5,-210)
        dialog.BackgroundColor3 = Color3.fromRGB(22,22,22)
        makeCorner(dialog,14) makeStroke(dialog,2,Color3.fromRGB(0,255,150),0.2)

        local top, close = buildTopBar(dialog, Dict[Lang].LANGS)
        local sbox = buildSearchBar(dialog, Dict[Lang].SEARCH)
        local list = buildScroll(dialog, 92)

        local langs = {"EN","AR"}
        for _,ln in ipairs(langs) do
            local b = Instance.new("TextButton", list)
            b.Size = UDim2.new(1,-8,0,44)
            b.Text = ln
            b.Font = Enum.Font.Gotham
            b.TextSize = 18
            b.BackgroundColor3 = Color3.fromRGB(32,32,32)
            b.TextColor3 = Color3.new(1,1,1)
            makeCorner(b,8) makeStroke(b,1,Color3.fromRGB(70,70,70),0.2)
            b.MouseButton1Click:Connect(function()
                main.Visible = false
                setLanguage(ln)
                PlayIntroVideo(INTRO_VIDEO_URL, 5, true)
                dialog:Destroy()
            end)
        end

        sbox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(sbox.Text)
            for _,b in ipairs(list:GetChildren()) do
                if b:IsA("TextButton") then
                    b.Visible = (q=="" or string.find(string.lower(b.Text), q, 1, true) ~= nil)
                end
            end
        end)

        close.MouseButton1Click:Connect(function() dialog:Destroy() end)
    end)
    btnLang.Text = Dict[Lang].LANGS

    -- Shortcuts Button (list all GUI buttons to add shortcut)
    local btnSC = createButton(sy, "Add Shortcut", function()
        local dialog = Instance.new("Frame", sg)
        dialog.Size = UDim2.new(0, 360, 0, 470)
        dialog.Position = UDim2.new(0.5,-180, 0.5,-235)
        dialog.BackgroundColor3 = Color3.fromRGB(22,22,22)
        makeCorner(dialog,14) makeStroke(dialog,2,Color3.fromRGB(0,255,150),0.2)

        local top, close = buildTopBar(dialog, Dict[Lang].SHORTCUT)
        local sbox = buildSearchBar(dialog, Dict[Lang].SEARCH)
        local list = buildScroll(dialog, 92)

        -- نجمع كل الأزرار الموجودة في الـ GUI (داخل الصفحات الأربعة)
        local allButtons = {}
        for _,pg in pairs(pages) do
            for _,inst in ipairs(pg:GetDescendants()) do
                if inst:IsA("TextButton") then
                    table.insert(allButtons, inst)
                end
            end
        end

        local function addBtnItem(btn)
            local item = Instance.new("TextButton", list)
            item.Size = UDim2.new(1,-8,0,40)
            item.Text = btn.Text
            item.Font = Enum.Font.Gotham
            item.TextSize = 16
            item.BackgroundColor3 = Color3.fromRGB(32,32,32)
            item.TextColor3 = Color3.new(1,1,1)
            makeCorner(item,8) makeStroke(item,1,Color3.fromRGB(70,70,70),0.2)
            item.MouseButton1Click:Connect(function()
                -- نعمل اختصار يتحرك بحرية، ينفّذ نفس كولباك الزر الأصلي (بنستدعي MouseButton1Click)
                createShortcutFor(btn.Text, function()
                    btn:Activate()
                    for _,ev in pairs(btn:GetConnectedSignals() or {}) do pcall(function() ev:Fire() end) end
                end)
                notif("Shortcuts","Shortcut added for: "..btn.Text,3)
            end)
        end

        for _,b in ipairs(allButtons) do addBtnItem(b) end

        sbox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(sbox.Text)
            for _,b in ipairs(list:GetChildren()) do
                if b:IsA("TextButton") then
                    b.Visible = (q=="" or string.find(string.lower(b.Text), q, 1, true) ~= nil)
                end
            end
        end)

        close.MouseButton1Click:Connect(function() dialog:Destroy() end)
    end)
    btnSC.Text = Dict[Lang].SHORTCUT
end

-- شغّل فيديو المقدمة 15 مرة ثم أظهر الـ GUI
task.spawn(function()
    PlayIntroVideo(INTRO_VIDEO_URL, 15, true)
end)