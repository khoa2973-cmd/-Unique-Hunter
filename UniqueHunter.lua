-- Unique Hunter | Anime Adventures Trait RNG Tracker
-- Manual logging only. This script does not automate rolls, alter RNG, or call game remotes.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end

local DATA_FILE = "UniqueHunter/data.json"
local data = {units = {}, history = {}, selected = nil}

local function loadData()
    if type(readfile) == "function" and type(isfile) == "function" then
        local ok, exists = pcall(isfile, DATA_FILE)
        if ok and exists then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(DATA_FILE))
            end)
            if success and type(decoded) == "table" then
                data.units = type(decoded.units) == "table" and decoded.units or {}
                data.history = type(decoded.history) == "table" and decoded.history or {}
                data.selected = decoded.selected
            end
        end
    end
end

local function saveData()
    if type(writefile) ~= "function" then return false end
    if type(makefolder) == "function" and type(isfolder) == "function" then
        pcall(function()
            if not isfolder("UniqueHunter") then makefolder("UniqueHunter") end
        end)
    end
    return pcall(function()
        writefile(DATA_FILE, HttpService:JSONEncode(data))
    end)
end
loadData()

local gui = Instance.new("ScreenGui")
gui.Name = "UniqueHunter"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local parent
pcall(function() parent = gethui() end)
gui.Parent = parent or player:WaitForChild("PlayerGui")

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function makeLabel(parentObj, text, size, pos, color, fontSize)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Size = size
    l.Position = pos
    l.TextColor3 = color or Color3.fromRGB(235, 238, 245)
    l.Font = Enum.Font.Gotham
    l.TextSize = fontSize or 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parentObj
    return l
end

local function makeButton(parentObj, text, size, pos, callback, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = color or Color3.fromRGB(48, 91, 150)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = parentObj
    round(b, 7)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function makeBox(parentObj, placeholder, size, pos)
    local t = Instance.new("TextBox")
    t.Size = size
    t.Position = pos
    t.BackgroundColor3 = Color3.fromRGB(34, 39, 51)
    t.TextColor3 = Color3.fromRGB(245, 246, 250)
    t.PlaceholderColor3 = Color3.fromRGB(145, 153, 168)
    t.PlaceholderText = placeholder
    t.Text = ""
    t.ClearTextOnFocus = false
    t.Font = Enum.Font.Gotham
    t.TextSize = 12
    t.Parent = parentObj
    round(t, 7)
    return t
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(350, 410)
main.Position = UDim2.new(0.5, -175, 0.5, -205)
main.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
main.BorderSizePixel = 0
main.Parent = gui
round(main, 12)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = Color3.fromRGB(30, 37, 51)
top.BorderSizePixel = 0
top.Parent = main
round(top, 12)
makeLabel(top, "UNIQUE HUNTER", UDim2.new(1, -92, 1, 0), UDim2.fromOffset(14, 0), Color3.fromRGB(115, 190, 255), 15)

local minimized = false
makeButton(top, "—", UDim2.fromOffset(30, 26), UDim2.new(1, -70, 0, 8), function()
    minimized = not minimized
    main.Size = minimized and UDim2.fromOffset(350, 42) or UDim2.fromOffset(350, 410)
end, Color3.fromRGB(65, 75, 95))
makeButton(top, "X", UDim2.fromOffset(28, 26), UDim2.new(1, -34, 0, 8), function()
    gui:Destroy()
end, Color3.fromRGB(145, 55, 65))

-- Drag window with touch or mouse
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

makeLabel(main, "Manual trait-roll log • No RNG prediction", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(14, 48), Color3.fromRGB(160, 170, 188), 11)
local unitBox = makeBox(main, "Unit name (e.g. Unit A)", UDim2.new(1, -112, 0, 32), UDim2.fromOffset(14, 76))
local selectBtn = Instance.new("TextButton")
selectBtn.Size = UDim2.fromOffset(86, 32)
selectBtn.Position = UDim2.new(1, -100, 0, 76)
selectBtn.BackgroundColor3 = Color3.fromRGB(57, 67, 88)
selectBtn.TextColor3 = Color3.new(1, 1, 1)
selectBtn.Font = Enum.Font.GothamSemibold
selectBtn.TextSize = 11
selectBtn.Text = "Select unit"
selectBtn.Parent = main
round(selectBtn, 7)

local beforeBox = makeBox(main, "Trait before roll", UDim2.new(1, -28, 0, 32), UDim2.fromOffset(14, 118))
local afterBox = makeBox(main, "Trait result after roll", UDim2.new(1, -28, 0, 32), UDim2.fromOffset(14, 158))
local status = makeLabel(main, "Selected: none", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 194), Color3.fromRGB(180, 190, 208), 11)
local stats = makeLabel(main, "Rolls: 0    Unique: 0", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 216), Color3.fromRGB(115, 210, 165), 12)
makeLabel(main, "RECENT HISTORY", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 250), Color3.fromRGB(115, 190, 255), 11)

local historyFrame = Instance.new("ScrollingFrame")
historyFrame.Size = UDim2.new(1, -28, 0, 100)
historyFrame.Position = UDim2.fromOffset(14, 274)
historyFrame.BackgroundColor3 = Color3.fromRGB(29, 34, 45)
historyFrame.BorderSizePixel = 0
historyFrame.ScrollBarThickness = 4
historyFrame.CanvasSize = UDim2.fromOffset(0, 0)
historyFrame.Parent = main
round(historyFrame, 7)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = historyFrame
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    historyFrame.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
end)
local footer = makeLabel(main, "Local save depends on executor file API support.", UDim2.new(1, -28, 0, 18), UDim2.fromOffset(14, 382), Color3.fromRGB(130, 140, 158), 9)

local function refresh()
    local uniqueCount = 0
    for _, entry in ipairs(data.history) do
        if string.lower(entry.after or "") == "unique" then uniqueCount += 1 end
    end
    stats.Text = "Rolls: " .. #data.history .. "    Unique: " .. uniqueCount
    status.Text = "Selected: " .. (data.selected or "none")
    selectBtn.Text = data.selected or "Select unit"
    for _, child in ipairs(historyFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for i = math.max(1, #data.history - 5), #data.history do
        local entry = data.history[i]
        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, -10, 0, 22)
        row.BackgroundTransparency = 1
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Font = Enum.Font.Gotham
        row.TextSize = 10
        row.TextColor3 = string.lower(entry.after or "") == "unique" and Color3.fromRGB(115, 230, 165) or Color3.fromRGB(220, 225, 235)
        row.Text = string.format("%s | %s -> %s", entry.unit or "?", entry.before or "?", entry.after or "?")
        row.Parent = historyFrame
    end
end

local function addUnit()
    local name = unitBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then status.Text = "Enter a unit name first"; return end
    for _, unit in ipairs(data.units) do
        if unit.name == name then
            data.selected = name
            refresh()
            saveData()
            return
        end
    end
    table.insert(data.units, {name = name})
    data.selected = name
    unitBox.Text = ""
    refresh()
    saveData()
end

makeButton(main, "Add / select unit", UDim2.fromOffset(155, 30), UDim2.fromOffset(14, 350), addUnit, Color3.fromRGB(47, 119, 92))
makeButton(main, "Save roll result", UDim2.fromOffset(155, 30), UDim2.new(1, -169, 0, 350), function()
    if not data.selected then status.Text = "Add or select a unit first"; return end
    local before = beforeBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    local after = afterBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if before == "" or after == "" then status.Text = "Fill in both trait fields"; return end
    table.insert(data.history, {unit = data.selected, before = before, after = after, time = os.date("%Y-%m-%d %H:%M:%S")})
    beforeBox.Text, afterBox.Text = "", ""
    refresh()
    footer.Text = saveData() and "Saved locally." or "Session only: file API unavailable."
end, Color3.fromRGB(48, 91, 150))

selectBtn.MouseButton1Click:Connect(function()
    if #data.units == 0 then status.Text = "Add a unit first"; return end
    local current = 1
    for i, unit in ipairs(data.units) do
        if unit.name == data.selected then current = i end
    end
    current = current % #data.units + 1
    data.selected = data.units[current].name
    refresh()
    saveData()
end)

refresh()
