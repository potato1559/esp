-- Made by @i_want_tobe_famouse in asu discord server https://discord.gg/VTH8xqf3w7


local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "ESP GUI Loaded!";
    Text = "Made by @i_want_tobe_famouse in asu discord server";
    Duration = 5;
})
print("ESP GUI loaded! Made by @i_want_tobe_famouse in asu discord server")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ESPColors = {
    Color3.fromRGB(255, 0, 0),    -- Red
    Color3.fromRGB(0, 255, 0),    -- Green
    Color3.fromRGB(0, 170, 255),  -- Blue
    Color3.fromRGB(255, 255, 0),  -- Yellow
    Color3.fromRGB(170, 0, 255),  -- Purple
    Color3.fromRGB(255, 255, 255) -- White
}
local ESPColorIndex = 1
local ESPColor = ESPColors[ESPColorIndex]
local FillEnabled = false
local ESPEnabled = true
local ESPConnections = {}
local UserTagsEnabled = false
local UserTagConnections = {}

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

--// ESP Functions
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


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_GUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 290)
Frame.Position = UDim2.new(0.5, -130, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui


local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Frame

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

local Title = Instance.new("TextLabel")
Title.Text = "ESP Control"
Title.Size = UDim2.new(1,0,0,34)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Frame
Title.ZIndex = 2

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "✕"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -38, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = Frame
CloseButton.ZIndex = 3

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "Disable ESP"
ToggleButton.Size = UDim2.new(0.85,0,0,32)
ToggleButton.Position = UDim2.new(0.075,0,0,46)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.Parent = Frame
ToggleButton.ZIndex = 2

local ColorButton = Instance.new("TextButton")
ColorButton.Text = "Change Color"
ColorButton.Size = UDim2.new(0.85,0,0,32)
ColorButton.Position = UDim2.new(0.075,0,0,86)
ColorButton.BackgroundColor3 = ESPColor
ColorButton.TextColor3 = Color3.new(0,0,0)
ColorButton.Font = Enum.Font.GothamBold
ColorButton.TextSize = 18
ColorButton.Parent = Frame
ColorButton.ZIndex = 2

local FillButton = Instance.new("TextButton")
FillButton.Text = "Enable Fill"
FillButton.Size = UDim2.new(0.85,0,0,32)
FillButton.Position = UDim2.new(0.075,0,0,126)
FillButton.BackgroundColor3 = Color3.fromRGB(120,120,120)
FillButton.TextColor3 = Color3.new(1,1,1)
FillButton.Font = Enum.Font.GothamBold
FillButton.TextSize = 18
FillButton.Parent = Frame
FillButton.ZIndex = 2

local UserTagButton = Instance.new("TextButton")
UserTagButton.Text = "Enable Usertags"
UserTagButton.Size = UDim2.new(0.85,0,0,32)
UserTagButton.Position = UDim2.new(0.075,0,0,166)
UserTagButton.BackgroundColor3 = Color3.fromRGB(120,120,200)
UserTagButton.TextColor3 = Color3.new(1,1,1)
UserTagButton.Font = Enum.Font.GothamBold
UserTagButton.TextSize = 18
UserTagButton.Parent = Frame
UserTagButton.ZIndex = 2

local RejoinButton = Instance.new("TextButton")
RejoinButton.Text = "Rejoin Server"
RejoinButton.Size = UDim2.new(0.85,0,0,32)
RejoinButton.Position = UDim2.new(0.075,0,0,206)
RejoinButton.BackgroundColor3 = Color3.fromRGB(50,120,200)
RejoinButton.TextColor3 = Color3.new(1,1,1)
RejoinButton.Font = Enum.Font.GothamBold
RejoinButton.TextSize = 18
RejoinButton.Parent = Frame
RejoinButton.ZIndex = 2

local ServerHopButton = Instance.new("TextButton")
ServerHopButton.Text = "Server Hop"
ServerHopButton.Size = UDim2.new(0.85,0,0,32)
ServerHopButton.Position = UDim2.new(0.075,0,0,246)
ServerHopButton.BackgroundColor3 = Color3.fromRGB(70, 170, 120)
ServerHopButton.TextColor3 = Color3.new(1,1,1)
ServerHopButton.Font = Enum.Font.GothamBold
ServerHopButton.TextSize = 18
ServerHopButton.Parent = Frame
ServerHopButton.ZIndex = 2

local dragging, dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - Frame.AbsolutePosition.Y < 36 then
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

-- Replace with your own raw script URL!
local scriptURL = "https://pastebin.com/raw/xxxxxxxx"

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
