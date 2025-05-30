--[[
    ESP GUI Script for Roblox
    Features:
      ESP (Highlight) toggle, color changer, fill toggle
      Usertag toggle (shows names above heads)
      Rejoin and Server Hop (auto-reexecutes script)
      FPS and Ping displays with color coding
      Draggable, modern GUI with close/minimize
      Credits pop-up (light blue text, always visible)
      Speed changer (slider 0-500 + ON/OFF + precise input)
      User-selectable GUI size (5 presets, smooth transitions, including full screen)
      Made by @i_want_tobe_famouse in asu discord server
--]]

local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ESP GUI Loaded!";
        Text = "Made by @i_want_tobe_famouse in asu discord server";
        Duration = 5;
    })
end)
print("ESP GUI loaded! Made by @i_want_tobe_famouse in asu discord server")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESPColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 170, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(170, 0, 255),
    Color3.fromRGB(255, 255, 255)
}
local ESPColorIndex = 1
local ESPColor = ESPColors[ESPColorIndex]
local FillEnabled = false
local ESPEnabled = true
local ESPConnections = {}
local UserTagsEnabled = false
local UserTagConnections = {}

local GUISizes = {
    {name="Small",  size=UDim2.new(0, 260, 0, 300), btn=32, font=16, title=18, credits=16},
    {name="Medium", size=UDim2.new(0, 320, 0, 400), btn=40, font=20, title=24, credits=20},
    {name="Large",  size=UDim2.new(0, 420, 0, 520), btn=50, font=24, title=30, credits=24},
    {name="Huge",   size=UDim2.new(0, 540, 0, 670), btn=65, font=28, title=38, credits=28},
    {name="Full Screen", size=UDim2.new(1, 0, 1, 0), btn=80, font=36, title=44, credits=34},
}
local CurrentSizeIndex = 2 -- Medium

-- --- UserTag, ESP, and player functions ---
local function addUserTag(player)
    if player == LocalPlayer then return end
    local function onChar(char)
        if not char or char:FindFirstChild("UserTag") then return end
        if not UserTagsEnabled then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tag = Instance.new("BillboardGui")
        tag.Name = "UserTag"
        tag.Adornee = hrp
        tag.Size = UDim2.new(0, 100, 0, 30)
        tag.StudsOffset = Vector3.new(0, 3, 0)
        tag.AlwaysOnTop = true
        tag.Parent = char

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName or player.Name
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.Parent = tag
    end
    if player.Character then onChar(player.Character) end
    UserTagConnections[player] = player.CharacterAdded:Connect(onChar)
end

local function removeUserTag(player)
    if player.Character and player.Character:FindFirstChild("UserTag") then
        player.Character.UserTag:Destroy()
    end
    if UserTagConnections[player] then
        UserTagConnections[player]:Disconnect()
        UserTagConnections[player] = nil
    end
end

local function enableUserTags()
    UserTagsEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addUserTag(player)
        end
    end
end

local function disableUserTags()
    UserTagsEnabled = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            removeUserTag(player)
        end
    end
end

local function updateAllUserTags()
    if UserTagsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("UserTag") then
                addUserTag(player)
            end
        end
    end
end

local function updateESP(char)
    local highlight = char:FindFirstChild("Highlight")
    if highlight then
        highlight.OutlineColor = ESPColor
        highlight.FillColor = ESPColor
        highlight.FillTransparency = FillEnabled and 0.6 or 1
        highlight.OutlineTransparency = 0
    end
end

local function addESP(player)
    if player == LocalPlayer then return end
    local function onChar(char)
        if not char or char:FindFirstChild("Highlight") then return end
        if not ESPEnabled then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.FillColor = ESPColor
        highlight.OutlineColor = ESPColor
        highlight.FillTransparency = FillEnabled and 0.6 or 1
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    end
    if player.Character then onChar(player.Character) end
    ESPConnections[player] = player.CharacterAdded:Connect(onChar)
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("Highlight") then
        player.Character.Highlight:Destroy()
    end
    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end
end

local function enableESP()
    ESPEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addESP(player)
        end
    end
end

local function disableESP()
    ESPEnabled = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            removeESP(player)
        end
    end
end

local function updateAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            updateESP(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    addESP(player)
    if UserTagsEnabled then
        addUserTag(player)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    removeUserTag(player)
end)

-- --- GUI Construction ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_GUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = GUISizes[CurrentSizeIndex].size
Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.22, 0)
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Frame

-- === NOTE AT TOP ===
local Note = Instance.new("TextLabel")
Note.Name = "Note"
Note.Size = UDim2.new(1, 0, 0, 28)
Note.Position = UDim2.new(0, 0, 0, 0)
Note.BackgroundTransparency = 1
Note.TextColor3 = Color3.fromRGB(173,216,230)
Note.Font = Enum.Font.GothamBold
Note.TextSize = 18
Note.Text = "ESP GUI made by @i_want_tobe_famouse in asu discord server"
Note.TextWrapped = true
Note.Parent = Frame
Note.ZIndex = 10

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Size = UDim2.new(1, 16, 1, 16)
Shadow.Position = UDim2.new(0, -8, 0, -8)
Shadow.BackgroundTransparency = 1
Shadow.ZIndex = 0
Shadow.Parent = Frame

local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(1, 0, 0, 28)
StatsBar.Position = UDim2.new(0,0,0,28)
StatsBar.BackgroundTransparency = 1
StatsBar.Parent = Frame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 1, 0)
StatsLabel.Position = UDim2.new(0, 10, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(200,255,100)
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextSize = 18
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Text = "FPS: 0  |  Ping: 0ms"
StatsLabel.RichText = true
StatsLabel.Parent = StatsBar

local Title = Instance.new("TextLabel")
Title.Text = "ESP Control"
Title.Size = UDim2.new(1,0,0,34)
Title.Position = UDim2.new(0,0,0,56)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = GUISizes[CurrentSizeIndex].title
Title.Parent = Frame
Title.ZIndex = 2

-- === MINIMIZE AND CLOSE BUTTONS (RIGHT ALIGNED) ===
local buttonPad = 8
local buttonSize = 36

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "✕"
CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
CloseButton.AnchorPoint = Vector2.new(1,0)
CloseButton.Position = UDim2.new(1, -buttonPad, 0, buttonPad)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 22
CloseButton.Parent = Frame
CloseButton.ZIndex = 3

local MinButton = Instance.new("TextButton")
MinButton.Text = "🗕"
MinButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
MinButton.AnchorPoint = Vector2.new(1,0)
MinButton.Position = UDim2.new(1, -(buttonSize+buttonPad*2), 0, buttonPad)
MinButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinButton.TextColor3 = Color3.new(1,1,1)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 22
MinButton.Parent = Frame
MinButton.ZIndex = 3

local function updateTopButtons()
    local btn = GUISizes[CurrentSizeIndex].btn
    local pad = math.max(8, math.floor(btn/5))
    local size = math.max(28, math.floor(btn*0.9))
    CloseButton.Size = UDim2.new(0, size, 0, size)
    CloseButton.Position = UDim2.new(1, -pad, 0, pad)
    MinButton.Size = UDim2.new(0, size, 0, size)
    MinButton.Position = UDim2.new(1, -(size+pad*2), 0, pad)
end

-- === BUTTONS SCROLLING FRAME ===
local ButtonsScroll = Instance.new("ScrollingFrame")
ButtonsScroll.Size = UDim2.new(1, -20, 1, -160)
ButtonsScroll.Position = UDim2.new(0, 10, 0, 110)
ButtonsScroll.BackgroundTransparency = 1
ButtonsScroll.BorderSizePixel = 0
ButtonsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonsScroll.ScrollBarThickness = 6
ButtonsScroll.ScrollBarImageColor3 = Color3.fromRGB(120,180,240)
ButtonsScroll.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Parent = ButtonsScroll

local function updateButtonsCanvas()
    ButtonsScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 8)
end
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateButtonsCanvas)

local AllButtons = {}

local function makeButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, 0, 0, GUISizes[CurrentSizeIndex].btn)
    btn.BackgroundColor3 = color or Color3.fromRGB(120,120,120)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = GUISizes[CurrentSizeIndex].font
    btn.ZIndex = 2
    table.insert(AllButtons, btn)
    return btn
end

-- === SIZE DROPDOWN BUTTON INSIDE SCROLLING FRAME (TOP) ===
local SizeDropdown = Instance.new("Frame")
SizeDropdown.Name = "SizeDropdown"
SizeDropdown.Size = UDim2.new(1, 0, 0, GUISizes[CurrentSizeIndex].btn)
SizeDropdown.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
SizeDropdown.ZIndex = 20
SizeDropdown.Parent = ButtonsScroll
SizeDropdown.LayoutOrder = 0

local SizeDropdownCorner = Instance.new("UICorner", SizeDropdown)
SizeDropdownCorner.CornerRadius = UDim.new(0, 8)

local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(1, -36, 1, 0)
SizeLabel.Position = UDim2.new(0, 8, 0, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Size: "..GUISizes[CurrentSizeIndex].name
SizeLabel.TextColor3 = Color3.fromRGB(173,216,230)
SizeLabel.Font = Enum.Font.GothamBold
SizeLabel.TextSize = GUISizes[CurrentSizeIndex].font
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = SizeDropdown
SizeLabel.ZIndex = 21

local SizeArrow = Instance.new("TextButton")
SizeArrow.Size = UDim2.new(0, 28, 1, 0)
SizeArrow.Position = UDim2.new(1, -28, 0, 0)
SizeArrow.BackgroundTransparency = 1
SizeArrow.Text = "▼"
SizeArrow.TextColor3 = Color3.fromRGB(173,216,230)
SizeArrow.Font = Enum.Font.GothamBold
SizeArrow.TextSize = GUISizes[CurrentSizeIndex].font
SizeArrow.Parent = SizeDropdown
SizeArrow.ZIndex = 21

-- SPEED FRAME (below size dropdown)
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, 0, 0, GUISizes[CurrentSizeIndex].btn + 20)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.ZIndex = 2
SpeedFrame.Parent = ButtonsScroll
SpeedFrame.LayoutOrder = 1

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.35, 0, 0, GUISizes[CurrentSizeIndex].btn - 16)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(200,255,100)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = GUISizes[CurrentSizeIndex].font
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 60, 0, GUISizes[CurrentSizeIndex].btn - 16)
SpeedInput.Position = UDim2.new(0.38, 0, 0, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SpeedInput.Text = tostring(16)
SpeedInput.TextColor3 = Color3.fromRGB(255,255,255)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = GUISizes[CurrentSizeIndex].font - 2
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = SpeedFrame

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0, 70, 0, GUISizes[CurrentSizeIndex].btn - 16)
SpeedToggle.Position = UDim2.new(1, -75, 0, 0)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(220, 120, 80)
SpeedToggle.Text = "OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255,255,255)
SpeedToggle.Font = Enum.Font.GothamBold
SpeedToggle.TextSize = GUISizes[CurrentSizeIndex].font - 2
SpeedToggle.Parent = SpeedFrame

local SpeedSliderBG = Instance.new("Frame")
SpeedSliderBG.Size = UDim2.new(1, -10, 0, 16)
SpeedSliderBG.Position = UDim2.new(0, 5, 0, GUISizes[CurrentSizeIndex].btn)
SpeedSliderBG.BackgroundColor3 = Color3.fromRGB(60,60,80)
SpeedSliderBG.BorderSizePixel = 0
SpeedSliderBG.Parent = SpeedFrame

local SpeedSliderBar = Instance.new("Frame")
SpeedSliderBar.Size = UDim2.new(16/500, 0, 1, 0)
SpeedSliderBar.BackgroundColor3 = Color3.fromRGB(120, 180, 240)
SpeedSliderBar.BorderSizePixel = 0
SpeedSliderBar.Parent = SpeedSliderBG

local SpeedSliderKnob = Instance.new("Frame")
SpeedSliderKnob.Size = UDim2.new(0, 16, 1, 0)
SpeedSliderKnob.Position = UDim2.new(16/500, -8, 0, 0)
SpeedSliderKnob.BackgroundColor3 = Color3.fromRGB(80, 160, 220)
SpeedSliderKnob.BorderSizePixel = 0
SpeedSliderKnob.Parent = SpeedSliderBG

local SpeedKnobCorner = Instance.new("UICorner", SpeedSliderKnob)
SpeedKnobCorner.CornerRadius = UDim.new(1, 0)

local draggingSlider = false
local speedEnabled = false
local desiredSpeed = 16
local charConn

local function setSpeedValue(x)
    x = math.clamp(x, 0, 1)
    desiredSpeed = math.floor(x * 500 + 0.5)
    SpeedLabel.Text = "Speed: "..desiredSpeed
    SpeedInput.Text = tostring(desiredSpeed)
    SpeedSliderBar.Size = UDim2.new(x, 0, 1, 0)
    SpeedSliderKnob.Position = UDim2.new(x, -8, 0, 0)
    if speedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = desiredSpeed end
    end
end

SpeedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)
SpeedSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        local x = math.clamp((input.Position.X - SpeedSliderBG.AbsolutePosition.X) / SpeedSliderBG.AbsoluteSize.X, 0, 1)
        setSpeedValue(x)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp((input.Position.X - SpeedSliderBG.AbsolutePosition.X) / SpeedSliderBG.AbsoluteSize.X, 0, 1)
        setSpeedValue(x)
    end
end)

SpeedInput.FocusLost:Connect(function(enter)
    local n = tonumber(SpeedInput.Text)
    if n then
        n = math.clamp(math.floor(n + 0.5), 0, 500)
        desiredSpeed = n
        SpeedLabel.Text = "Speed: "..desiredSpeed
        local x = desiredSpeed / 500
        SpeedSliderBar.Size = UDim2.new(x, 0, 1, 0)
        SpeedSliderKnob.Position = UDim2.new(x, -8, 0, 0)
        SpeedInput.Text = tostring(desiredSpeed)
        if speedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = desiredSpeed end
        end
    else
        SpeedInput.Text = tostring(desiredSpeed)
    end
end)

local function applySpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and desiredSpeed or 16
    end
end

SpeedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    SpeedToggle.Text = speedEnabled and "ON" or "OFF"
    SpeedToggle.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(220, 120, 80)
    applySpeed()
end)

local function onChar(char)
    if charConn then charConn:Disconnect() end
    charConn = nil
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and desiredSpeed or 16
    end
    charConn = char.ChildAdded:Connect(function(child)
        if child:IsA("Humanoid") then
            child.WalkSpeed = speedEnabled and desiredSpeed or 16
        end
    end)
end

if LocalPlayer.Character then onChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onChar)

-- === SIZE DROPDOWN LIST (FLOATING, ALWAYS ON TOP) ===
local function getAbsolutePosition(gui)
    local absPos = gui.AbsolutePosition
    local parent = gui.Parent
    while parent and parent ~= game:GetService("CoreGui") and parent ~= game:GetService("Players").LocalPlayer.PlayerGui and parent ~= ScreenGui do
        absPos = absPos + (parent.AbsolutePosition or Vector2.new())
        parent = parent.Parent
    end
    return absPos
end

local SizeList = Instance.new("Frame")
SizeList.Size = UDim2.new(1, 0, 0, #GUISizes*GUISizes[CurrentSizeIndex].btn)
SizeList.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
SizeList.Visible = false
SizeList.Parent = ScreenGui
SizeList.ZIndex = 9999

local SizeListCorner = Instance.new("UICorner", SizeList)
SizeListCorner.CornerRadius = UDim.new(0, 8)
local SizeListLayout = Instance.new("UIListLayout", SizeList)
SizeListLayout.Padding = UDim.new(0, 2)
SizeListLayout.FillDirection = Enum.FillDirection.Vertical
SizeListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateSizeListPosition()
    local absPos = getAbsolutePosition(SizeDropdown)
    SizeList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + SizeDropdown.AbsoluteSize.Y)
    SizeList.Size = UDim2.new(0, SizeDropdown.AbsoluteSize.X, 0, #GUISizes*GUISizes[CurrentSizeIndex].btn)
end

local function updateButtonSizes()
    local btnHeight = GUISizes[CurrentSizeIndex].btn
    local btnFont = GUISizes[CurrentSizeIndex].font
    for _,btn in ipairs(AllButtons) do
        btn.TextSize = btnFont
        btn.Size = UDim2.new(1, 0, 0, btnHeight)
    end
    SpeedFrame.Size = UDim2.new(1, 0, 0, btnHeight + 20)
    SpeedLabel.Size = UDim2.new(0.35, 0, 0, btnHeight - 16)
    SpeedInput.Size = UDim2.new(0, 60, 0, btnHeight - 16)
    SpeedToggle.Size = UDim2.new(0, 70, 0, btnHeight - 16)
    SpeedLabel.TextSize = btnFont
    SpeedInput.TextSize = btnFont - 2
    SpeedToggle.TextSize = btnFont - 2
    SizeDropdown.Size = UDim2.new(1, 0, 0, btnHeight)
    SizeLabel.TextSize = btnFont
    SizeArrow.TextSize = btnFont
    SizeList.Size = UDim2.new(0, SizeDropdown.AbsoluteSize.X, 0, #GUISizes*btnHeight)
    updateSizeListPosition()
end

local function setGuiSize(index)
    CurrentSizeIndex = index
    local newSize = GUISizes[index].size
    SizeLabel.Text = "Size: "..GUISizes[index].name
    TweenService:Create(Frame, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = newSize}):Play()
    task.spawn(function()
        wait(0.37)
        if GUISizes[index].name == "Full Screen" then
            Frame.Position = UDim2.new(0, 0, 0, 0)
        else
            Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset/2, 0.22, 0)
        end
        updateTopButtons()
        updateSizeListPosition()
    end)
    -- Credits popup
    local csize = GUISizes[index].name == "Full Screen"
        and UDim2.new(1, 0, 1, 0)
        or UDim2.new(newSize.X.Scale, math.floor(newSize.X.Offset*1.1), newSize.Y.Scale, math.floor(newSize.Y.Offset*0.7))
    TweenService:Create(CreditsPopup, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = csize}):Play()
    task.spawn(function()
        wait(0.37)
        if GUISizes[index].name == "Full Screen" then
            CreditsPopup.Position = UDim2.new(0, 0, 0, 0)
        else
            CreditsPopup.Position = UDim2.new(0.5, -CreditsPopup.Size.X.Offset/2, 0.22, 0)
        end
    end)
    CreditsText.Size = UDim2.new(0.9, 0, 0.7, 0)
    CreditsText.TextSize = GUISizes[index].credits
    Title.TextSize = GUISizes[index].title
    CreditsOK.TextSize = GUISizes[index].font
    updateButtonSizes()
    updateTopButtons()
end

for _,child in ipairs(SizeList:GetChildren()) do
    if child:IsA("TextButton") then child:Destroy() end
end

for i, sz in ipairs(GUISizes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, GUISizes[CurrentSizeIndex].btn)
    btn.Position = UDim2.new(0, 4, 0, (i-1)*GUISizes[CurrentSizeIndex].btn)
    btn.BackgroundColor3 = i==CurrentSizeIndex and Color3.fromRGB(80,160,220) or Color3.fromRGB(60,80,120)
    btn.Text = sz.name
    btn.TextColor3 = Color3.fromRGB(173,216,230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = GUISizes[CurrentSizeIndex].font
    btn.ZIndex = 10000
    btn.Parent = SizeList
    btn.MouseButton1Click:Connect(function()
        setGuiSize(i)
        SizeList.Visible = false
        for _,b in ipairs(SizeList:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(60,80,120)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(80,160,220)
    end)
end

SizeArrow.MouseButton1Click:Connect(function()
    SizeList.Visible = not SizeList.Visible
    updateSizeListPosition()
end)
SizeDropdown:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateSizeListPosition)
SizeDropdown:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizeListPosition)
Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateSizeListPosition)
Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizeListPosition)

UserInputService.InputBegan:Connect(function(input)
    if SizeList.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = UserInputService:GetMouseLocation()
        local absPos = SizeList.AbsolutePosition
        local absSize = SizeList.AbsoluteSize
        if not (mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y) then
            SizeList.Visible = false
        end
    end
end)


local CreditsPopup = Instance.new("Frame")
CreditsPopup.Name = "CreditsPopup"
CreditsPopup.Size = UDim2.new(GUISizes[CurrentSizeIndex].size.X.Scale, math.floor(GUISizes[CurrentSizeIndex].size.X.Offset*1.1), GUISizes[CurrentSizeIndex].size.Y.Scale, math.floor(GUISizes[CurrentSizeIndex].size.Y.Offset*0.7))
CreditsPopup.Position = UDim2.new(0.5, -CreditsPopup.Size.X.Offset/2, 0.22, 0)
CreditsPopup.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CreditsPopup.Visible = false
CreditsPopup.Parent = ScreenGui
CreditsPopup.ZIndex = 1000

local CreditsCorner = Instance.new("UICorner", CreditsPopup)
CreditsCorner.CornerRadius = UDim.new(0, 18)

local CreditsText = Instance.new("TextLabel")
CreditsText.Name = "CreditsText"
CreditsText.Parent = CreditsPopup
CreditsText.Size = UDim2.new(0.9, 0, 0.7, 0)
CreditsText.Position = UDim2.new(0.05, 0, 0.05, 0)
CreditsText.BackgroundTransparency = 1
CreditsText.TextColor3 = Color3.fromRGB(173, 216, 230)
CreditsText.Font = Enum.Font.GothamBold
CreditsText.TextSize = GUISizes[CurrentSizeIndex].credits
CreditsText.TextWrapped = true
CreditsText.TextYAlignment = Enum.TextYAlignment.Top
CreditsText.TextXAlignment = Enum.TextXAlignment.Center
CreditsText.ZIndex = 1001
CreditsText.Text = [[
ESP GUI made by @i_want_tobe_famouse in asu discord server

Features:
ESP (Highlight), Color/Fill, Usertags, Server Hop, Rejoin, FPS/Ping, Draggable GUI, Scrollable panels, Speed Changer, and more!

Fun facts:
This script is free and always will be.
If you use this for your own project, please give credit!

Contact:
Discord: @i_want_tobe_famouse
Github: potato1559/
ASU's Discord: https://discord.gg/VTH8xqf3w7

Enjoy and have fun!
]]

local CreditsOK = Instance.new("TextButton")
CreditsOK.Size = UDim2.new(0, 100, 0, 38)
CreditsOK.Position = UDim2.new(0.5, -50, 0.85, 0)
CreditsOK.BackgroundColor3 = Color3.fromRGB(80, 160, 220)
CreditsOK.Text = "OK"
CreditsOK.TextColor3 = Color3.fromRGB(255,255,255)
CreditsOK.Font = Enum.Font.GothamBold
CreditsOK.TextSize = GUISizes[CurrentSizeIndex].font
CreditsOK.Parent = CreditsPopup
CreditsOK.ZIndex = 1001

local CreditsOKCorner = Instance.new("UICorner", CreditsOK)
CreditsOKCorner.CornerRadius = UDim.new(0, 12)

CreditsButton.MouseButton1Click:Connect(function()
    CreditsPopup.Visible = true
    CreditsPopup.ZIndex = 1000
end)
CreditsOK.MouseButton1Click:Connect(function()
    CreditsPopup.Visible = false
end)

local draggingCredits, dragInputCredits, dragStartCredits, startPosCredits
CreditsPopup.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingCredits = true
        dragStartCredits = input.Position
        startPosCredits = CreditsPopup.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingCredits = false
            end
        end)
    end
end)
CreditsPopup.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputCredits = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputCredits and draggingCredits then
        local delta = input.Position - dragStartCredits
        CreditsPopup.Position = UDim2.new(startPosCredits.X.Scale, startPosCredits.X.Offset + delta.X, startPosCredits.Y.Scale, startPosCredits.Y.Offset + delta.Y)
    end
end)

local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - Frame.AbsolutePosition.Y < 40 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local minimized = false
local fullSize = GUISizes[CurrentSizeIndex].size
local minSize = UDim2.new(0, 320, 0, 70)
local function setMinimized(state)
    minimized = state
    local targetSize = minimized and minSize or GUISizes[CurrentSizeIndex].size
    local step = 0
    local startSize = Frame.Size
    while step < 1 do
        step = math.min(step + RunService.RenderStepped:Wait() * 8, 1)
        Frame.Size = UDim2.new(
            startSize.X.Scale + (targetSize.X.Scale - startSize.X.Scale) * step,
            startSize.X.Offset + (targetSize.X.Offset - startSize.X.Offset) * step,
            startSize.Y.Scale + (targetSize.Y.Scale - startSize.Y.Scale) * step,
            startSize.Y.Offset + (targetSize.Y.Offset - startSize.Y.Offset) * step
        )
    end
    Frame.Size = targetSize
    ButtonsScroll.Visible = not minimized
end

MinButton.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

ToggleButton.MouseButton1Click:Connect(function()
    if ESPEnabled then
        disableESP()
        ToggleButton.Text = "Enable ESP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
    else
        enableESP()
        ToggleButton.Text = "Disable ESP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
    end
end)

ColorButton.MouseButton1Click:Connect(function()
    ESPColorIndex = ESPColorIndex % #ESPColors + 1
    ESPColor = ESPColors[ESPColorIndex]
    ColorButton.BackgroundColor3 = ESPColor
    updateAllESP()
end)

FillButton.MouseButton1Click:Connect(function()
    FillEnabled = not FillEnabled
    FillButton.Text = FillEnabled and "Disable Fill" or "Enable Fill"
    FillButton.BackgroundColor3 = FillEnabled and Color3.fromRGB(50,200,50) or Color3.fromRGB(120,120,120)
    updateAllESP()
end)

UserTagButton.MouseButton1Click:Connect(function()
    if UserTagsEnabled then
        disableUserTags()
        UserTagButton.Text = "Enable Usertags"
        UserTagButton.BackgroundColor3 = Color3.fromRGB(120,120,200)
    else
        enableUserTags()
        UserTagButton.Text = "Disable Usertags"
        UserTagButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
    end
end)

local scriptURL = "https://raw.githubusercontent.com/potato1559/esp/refs/heads/main/esp.lua"

RejoinButton.MouseButton1Click:Connect(function()
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("'..scriptURL..'"))()')
    end
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

ServerHopButton.MouseButton1Click:Connect(function()
    local function serverHop()
        local req = syn and syn.request or http_request or request
        local cursor = ""
        local found = false
        local currentJobId = game.JobId
        while not found do
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=2&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
            local response = req({Url = url, Method = "GET"})
            local data = HttpService:JSONDecode(response.Body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= currentJobId then
                    found = true
                    if queue_on_teleport then
                        queue_on_teleport('loadstring(game:HttpGet("'..scriptURL..'"))()')
                    end
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            if data.nextPageCursor then
                cursor = data.nextPageCursor
            else
                break
            end
        end
        if queue_on_teleport then
            queue_on_teleport('loadstring(game:HttpGet("'..scriptURL..'"))()')
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
    task.spawn(serverHop)
end)

CloseButton.MouseButton1Click:Connect(function()
    disableESP()
    disableUserTags()
    ScreenGui:Destroy()
end)

enableESP()

task.spawn(function()
    while ScreenGui.Parent do
        updateAllESP()
        updateAllUserTags()
        task.wait(1)
    end
end)

task.spawn(function()
    local last = tick()
    local frames = 0
    local fps = 0
    local lastPingUpdate = 0
    local ping = 0
    local pingColor = Color3.fromRGB(50, 255, 50)
    while ScreenGui.Parent do
        RunService.RenderStepped:Wait()
        frames += 1
        if tick() - last >= 0.2 then
            fps = math.floor(frames / (tick() - last) + 0.5)
            StatsLabel.Text = "FPS: "..fps
            last = tick()
            frames = 0
        end
        if tick() - lastPingUpdate >= 1 then
            ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            lastPingUpdate = tick()
        end
    end
end)
