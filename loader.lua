-- =========================
-- UniScript BETA — Safe Load Version
-- =========================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Ensure PlayerGui is ready
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- Settings Table
-- =========================
local Settings = {
    ESPEnabled = false,
    AimlockEnabled = false,
    AimlockPrediction = 0.18,
    WallbangEnabled = false,
    MeleeAuraEnabled = false,
    MeleeReach = 10,
    NoClipEnabled = false,
    InfiniteSprint = false,
    PlayerFOV = Camera.FieldOfView or 70
}

-- =========================
-- Create UI
-- =========================
local function make(parent, class, props)
    local obj = Instance.new(class)
    if props then for k,v in pairs(props) do obj[k] = v end end
    obj.Parent = parent
    return obj
end

local screenGui = make(PlayerGui, "ScreenGui", {Name="UniScriptGUI", ResetOnSpawn=false})

-- Main Window
local window = make(screenGui,"Frame",{Size=UDim2.new(0,580,0,380), Position=UDim2.new(0.06,0,0.12,0), BackgroundColor3=Color3.fromRGB(18,18,20), BorderSizePixel=0})
make(window,"UICorner",{CornerRadius=UDim.new(0,8)})

-- Title Bar
local titleBar = make(window,"Frame",{Size=UDim2.new(1,0,0,44), BackgroundColor3=Color3.fromRGB(12,12,14), BorderSizePixel=0})
make(titleBar,"TextLabel",{Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,20,0,0), BackgroundTransparency=1, Text="Criminality Enhancer — UniScript BETA", TextColor3=Color3.fromRGB(230,230,230), Font=Enum.Font.SourceSansBold, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left})
make(titleBar,"TextLabel",{Size=UDim2.new(0,260,1,0), Position=UDim2.new(1,-260,0,0), BackgroundTransparency=1, Text="UniScript is loading... | By Ryan", TextColor3=Color3.fromRGB(160,160,160), Font=Enum.Font.SourceSans, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right})

-- Sidebar
local sidebar = make(window,"Frame",{Size=UDim2.new(0,170,1,-44), Position=UDim2.new(0,0,0,44), BackgroundColor3=Color3.fromRGB(24,24,28), BorderSizePixel=0})
make(sidebar,"UICorner",{CornerRadius=UDim.new(0,6)})
make(sidebar,"UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})

-- Content Pages
local content = make(window,"Frame",{Size=UDim2.new(1,-180,1,-54), Position=UDim2.new(0,180,0,50), BackgroundTransparency=1})
local pages = {}
local function makePage()
    local p = make(content,"ScrollingFrame",{Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0), BackgroundTransparency=1, Visible=false, ScrollBarThickness=6})
    local layout = make(p,"UIListLayout",{Padding=UDim.new(0,8)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
    end)
    pages[#pages+1]=p
    return p
end
local combatPage = makePage(); combatPage.Visible=true
local miscPage = makePage()
local extrasPage = makePage()

-- Tab Buttons
local function makeTabButton(text,page)
    local btn = make(sidebar,"TextButton",{Size=UDim2.new(1,-16,0,44), BackgroundColor3=Color3.fromRGB(28,28,32), BorderSizePixel=0, Text=text, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.SourceSansBold, TextSize=15})
    make(btn,"UICorner",{CornerRadius=UDim.new(0,6)})
    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible=false end
        for _,b in pairs(sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(28,28,32) end end
        btn.BackgroundColor3=Color3.fromRGB(40,40,46)
        page.Visible=true
    end)
    return btn
end
makeTabButton("Combat",combatPage).BackgroundColor3=Color3.fromRGB(40,40,46)
makeTabButton("Misc",miscPage)
makeTabButton("Extras",extrasPage)

-- UI Helpers
local function addToggle(parent,text,callback)
    local btn = make(parent,"TextButton",{Size=UDim2.new(1,-10,0,32), BackgroundColor3=Color3.fromRGB(32,32,36), Text=text.." [OFF]", TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.SourceSans, TextSize=15})
    make(btn,"UICorner",{CornerRadius=UDim.new(0,6)})
    local state=false
    btn.MouseButton1Click:Connect(function()
        state=not state
        btn.Text=text..(state and " [ON]" or " [OFF]")
        callback(state)
    end)
end

local function addSlider(parent,text,min,max,default,callback)
    local frame = make(parent,"Frame",{Size=UDim2.new(1,-10,0,50), BackgroundTransparency=1})
    local label = make(frame,"TextLabel",{Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=text..": "..default, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.SourceSans, TextSize=14})
    local bar = make(frame,"Frame",{Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,0,28), BackgroundColor3=Color3.fromRGB(50,50,55)})
    make(bar,"UICorner",{CornerRadius=UDim.new(0,4)})
    local fill = make(bar,"Frame",{Size=UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3=Color3.fromRGB(100,150,255)})
    make(fill,"UICorner",{CornerRadius=UDim.new(0,4)})
    local dragging=false
    local function update(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local val=math.floor(min+rel*(max-min))
        fill.Size=UDim2.new(rel,0,1,0)
        label.Text=text..": "..val
        callback(val)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true update(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

-- Populate UI
addToggle(combatPage,"Aimlock",function(v) Settings.AimlockEnabled=v end)
addSlider(combatPage,"Prediction",0,100,Settings.AimlockPrediction*100,function(v) Settings.AimlockPrediction=v/100 end)
addToggle(combatPage,"Wallbang",function(v) Settings.WallbangEnabled=v end)
addToggle(combatPage,"Melee Aura",function(v) Settings.MeleeAuraEnabled=v end)
addSlider(combatPage,"Melee Reach",1,30,Settings.MeleeReach,function(v) Settings.MeleeReach=v end)

addToggle(miscPage,"NoClip",function(v) Settings.NoClipEnabled=v end)
addToggle(miscPage,"Infinite Sprint",function(v) Settings.InfiniteSprint=v end)
addSlider(miscPage,"Player FOV",70,120,Settings.PlayerFOV,function(v) Settings.PlayerFOV=v Camera.FieldOfView=v end)
addToggle(miscPage,"ESP",function(v) Settings.ESPEnabled=v end)

-- Extras
local copyBtn = make(extrasPage,"TextButton",{Size=UDim2.new(0,240,0,34), BackgroundColor3=Color3.fromRGB(60,60,70), Text="Copy Discord", TextColor3=Color3.fromRGB(230,230,230)})
make(copyBtn,"UICorner",{CornerRadius=UDim.new(0,6)})
copyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard("https://discord.gg/dJEM47ZtGa") end) end)

local unloadBtn = make(extrasPage,"TextButton",{Size=UDim2.new(0,240,0,34), BackgroundColor3=Color3.fromRGB(165,65,65), Text="Unload Script", TextColor3=Color3.fromRGB(240,240,240)})
make(unloadBtn,"UICorner",{CornerRadius=UDim.new(0,6)})
unloadBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Draggable Window
do
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=i.Position
            startPos=window.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=i.Position-dragStart
            window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
end

-- =========================
-- Features Wiring
-- =========================
local Character, Humanoid, RootPart
local function getHumanoid()
    Character=LocalPlayer.Character
    if Character then
        Humanoid=Character:FindFirstChildWhichIsA("Humanoid")
        RootPart=Character:FindFirstChild("HumanoidRootPart")
    end
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1) getHumanoid() end)
getHumanoid()

-- Infinite Sprint
task.spawn(function()
    while task.wait(0.1) do
        if Settings.InfiniteSprint and Humanoid then
            for _,tbl in pairs(getgc(true)) do
                if type(tbl)=="table" and rawget(tbl,"S") then
                    rawset(tbl,"S",100)
                end
            end
        end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if Settings.NoClipEnabled and Character then
        for _,part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide=false end
        end
    end
end)

-- =========================
-- ESP (Boxes + Names + Distances)
-- =========================
local ESPBoxes = {}
local ESPNames = {}
local ESPDistances = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    ESPBoxes[player] = box

    local nameTag = Drawing.new("Text")
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Size = 14
    ESPNames[player] = nameTag

    local distanceTag = Drawing.new("Text")
    distanceTag.Color = Color3.fromRGB(255, 255, 0)
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.Size = 14
    ESPDistances[player] = distanceTag
end

local function removeESP(player)
    if ESPBoxes[player] then ESPBoxes[player]:Remove() ESPBoxes[player] = nil end
    if ESPNames[player] then ESPNames[player]:Remove() ESPNames[player] = nil end
    if ESPDistances[player] then ESPDistances[player]:Remove() ESPDistances[player] = nil end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, p in pairs(Players:GetPlayers()) do createESP(p) end

RunService.RenderStepped:Connect(function()
    for player, box in pairs(ESPBoxes) do
        if Settings.ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local topPos = root.Position + Vector3.new(0, 3, 0)
            local bottomPos = root.Position - Vector3.new(0, 3, 0)

            local topScreen, topVis = Camera:WorldToViewportPoint(topPos)
            local bottomScreen, bottomVis = Camera:WorldToViewportPoint(bottomPos)

            if topVis or bottomVis then
                local height = (topScreen.Y - bottomScreen.Y)
                local width = height / 2
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(topScreen.X - width / 2, topScreen.Y)
                box.Visible = true

                local nameTag = ESPNames[player]
                nameTag.Text = player.Name
                nameTag.Position = Vector2.new(topScreen.X, topScreen.Y - 10)
                nameTag.Visible = true

                local distanceTag = ESPDistances[player]
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                distanceTag.Text = string.format("%.0f studs", dist)
                distanceTag.Position = Vector2.new(topScreen.X, topScreen.Y - 25)
                distanceTag.Visible = true
            else
                box.Visible = false
                ESPNames[player].Visible = false
                ESPDistances[player].Visible = false
            end
        else
            box.Visible = false
            if ESPNames[player] then ESPNames[player].Visible = false end
            if ESPDistances[player] then ESPDistances[player].Visible = false end
        end
    end
end)

-- =========================
-- Aimlock (Right Mouse Button)
-- =========================
local function getClosestTarget()
    local closest
    local shortest = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, vis = Camera:WorldToViewportPoint(root.Position)
            if vis then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = root
                end
            end
        end
    end
    return closest
end

local aiming = false
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.AimlockEnabled and aiming then
        local target = getClosestTarget()
        if target and RootPart then
            local predictedPos = target.Position + (target.Velocity * Settings.AimlockPrediction)
            local camCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = camCFrame
        end
    end
end)

-- =========================
print("✅ UniScript BETA: Full Features Loaded Safely")
