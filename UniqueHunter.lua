-- Unique Hunter v2 | Anime Adventures Trait Tracker
-- Manual tracker only: no automated rolls, RNG manipulation, or game remote calls.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end

local FILE = "UniqueHunter/data.json"
local data = {units = {}, history = {}, selected = nil}

local function saveData()
    if type(writefile) ~= "function" then return false end
    if type(makefolder) == "function" and type(isfolder) == "function" then
        pcall(function() if not isfolder("UniqueHunter") then makefolder("UniqueHunter") end end)
    end
    return pcall(function() writefile(FILE, HttpService:JSONEncode(data)) end)
end
local function loadData()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    local ok, exists = pcall(isfile, FILE)
    if not ok or not exists then return end
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE)) end)
    if success and type(decoded) == "table" then
        data.units = type(decoded.units) == "table" and decoded.units or {}
        data.history = type(decoded.history) == "table" and decoded.history or {}
        data.selected = decoded.selected
    end
end
loadData()

local old = (function() local p; pcall(function() p = gethui() end); return p end)()
old = old or player:WaitForChild("PlayerGui")
pcall(function() local previous = old:FindFirstChild("UniqueHunterV2"); if previous then previous:Destroy() end end)
local gui = Instance.new("ScreenGui")
gui.Name = "UniqueHunterV2"; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = old

local function round(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o end
local function label(parent, text, size, pos, color, font, align)
    local x = Instance.new("TextLabel"); x.BackgroundTransparency = 1; x.Text = text; x.Size = size; x.Position = pos
    x.TextColor3 = color or Color3.fromRGB(235,238,245); x.Font = font or Enum.Font.Gotham; x.TextSize = 11
    x.TextXAlignment = align or Enum.TextXAlignment.Left; x.TextYAlignment = Enum.TextYAlignment.Center; x.Parent = parent; return x
end
local function button(parent, text, size, pos, fn, color)
    local b = Instance.new("TextButton"); b.Size = size; b.Position = pos; b.BackgroundColor3 = color or Color3.fromRGB(48,91,150)
    b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 11; b.Parent = parent; round(b,7); b.MouseButton1Click:Connect(fn); return b
end
local function box(parent, hint, size, pos)
    local t = Instance.new("TextBox"); t.Size = size; t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(34,39,51)
    t.TextColor3 = Color3.fromRGB(245,246,250); t.PlaceholderColor3 = Color3.fromRGB(145,153,168); t.PlaceholderText = hint
    t.Text = ""; t.ClearTextOnFocus = false; t.Font = Enum.Font.Gotham; t.TextSize = 11; t.Parent = parent; round(t,7); return t
end

local main = Instance.new("Frame"); main.Size = UDim2.fromOffset(360,500); main.Position = UDim2.new(0.5,-180,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(22,26,35); main.BorderSizePixel = 0; main.Parent = gui; round(main,12)
local top = Instance.new("Frame"); top.Size = UDim2.new(1,0,0,42); top.BackgroundColor3 = Color3.fromRGB(30,37,51); top.BorderSizePixel = 0; top.Parent = main; round(top,12)
label(top,"UNIQUE HUNTER  /  V2",UDim2.new(1,-90,1,0),UDim2.fromOffset(13,0),Color3.fromRGB(115,190,255),Enum.Font.GothamBold)
local minimized = false
button(top,"—",UDim2.fromOffset(28,25),UDim2.new(1,-64,0,8),function() minimized = not minimized; main.Size = minimized and UDim2.fromOffset(360,42) or UDim2.fromOffset(360,500) end,Color3.fromRGB(65,75,95))
button(top,"X",UDim2.fromOffset(25,25),UDim2.new(1,-31,0,8),function() gui:Destroy() end,Color3.fromRGB(145,55,65))
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging,dragStart,startPos = true,input.Position,main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position-dragStart; main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

label(main,"UNIT MANAGER",UDim2.new(1,-24,0,18),UDim2.fromOffset(13,48),Color3.fromRGB(115,190,255),Enum.Font.GothamBold)
local unitBox = box(main,"Enter unit name (e.g. Speedwagon)",UDim2.new(1,-116,0,30),UDim2.fromOffset(13,69))
local addBtn = button(main,"+ ADD",UDim2.fromOffset(92,30),UDim2.new(1,-105,0,69),function() end,Color3.fromRGB(47,119,92))
local unitPicker = button(main,"No unit selected  •  tap to switch",UDim2.new(1,-26,0,29),UDim2.fromOffset(13,105),function() end,Color3.fromRGB(57,67,88))
local unitStats = label(main,"This unit: 0 rolls  |  0 Unique",UDim2.new(1,-26,0,19),UDim2.fromOffset(13,137),Color3.fromRGB(115,210,165))
label(main,"ROLL LOG  (enter the result yourself)",UDim2.new(1,-26,0,18),UDim2.fromOffset(13,160),Color3.fromRGB(115,190,255),Enum.Font.GothamBold)
local beforeBox = box(main,"Trait BEFORE roll",UDim2.new(1,-26,0,30),UDim2.fromOffset(13,181))
local afterBox = box(main,"Trait AFTER roll",UDim2.new(1,-26,0,30),UDim2.fromOffset(13,216))
local saveBtn = button(main,"SAVE THIS ROLL",UDim2.new(1,-26,0,30),UDim2.fromOffset(13,251),function() end,Color3.fromRGB(48,91,150))
local overall = label(main,"Overall: 0 rolls  |  0 Unique  |  0.00%",UDim2.new(1,-26,0,20),UDim2.fromOffset(13,286),Color3.fromRGB(225,205,130))
label(main,"SELECTED UNIT HISTORY",UDim2.new(1,-26,0,18),UDim2.fromOffset(13,309),Color3.fromRGB(115,190,255),Enum.Font.GothamBold)
local history = Instance.new("ScrollingFrame"); history.Size = UDim2.new(1,-26,0,105); history.Position = UDim2.fromOffset(13,330)
history.BackgroundColor3 = Color3.fromRGB(29,34,45); history.BorderSizePixel = 0; history.ScrollBarThickness = 4; history.CanvasSize = UDim2.fromOffset(0,0); history.Parent = main; round(history,7)
local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0,3); list.Parent = history
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() history.CanvasSize = UDim2.fromOffset(0,list.AbsoluteContentSize.Y+6) end)
local status = label(main,"Ready. Data saves locally if Delta supports file APIs.",UDim2.new(1,-26,0,17),UDim2.fromOffset(13,439),Color3.fromRGB(145,155,175))
local deleteButton = button(main,"DELETE UNIT HISTORY",UDim2.fromOffset(158,27),UDim2.fromOffset(13,463),function() end,Color3.fromRGB(130,65,65))
local exportButton = button(main,"EXPORT DATA",UDim2.fromOffset(158,27),UDim2.new(1,-171,0,463),function() end,Color3.fromRGB(65,85,110))

local function counts(unitName)
    local rolls, uniques = 0,0
    for _,e in ipairs(data.history) do
        if not unitName or e.unit == unitName then rolls += 1; if string.lower(e.after or "") == "unique" then uniques += 1 end end
    end
    return rolls,uniques
end
local function refresh()
    local rolls, uniques = counts(data.selected)
    unitStats.Text = "This unit: "..rolls.." rolls  |  "..uniques.." Unique"
    local total, rare = counts(nil); local rate = total > 0 and (rare/total*100) or 0
    overall.Text = string.format("Overall: %d rolls  |  %d Unique  |  %.2f%%",total,rare,rate)
    unitPicker.Text = data.selected and ("Selected: "..data.selected.."  •  tap to switch") or "No unit selected  •  tap to switch"
    for _,child in ipairs(history:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
    local shown = 0
    for i = #data.history,1,-1 do
        local e = data.history[i]
        if e.unit == data.selected and shown < 20 then
            shown += 1
            local row = Instance.new("TextLabel"); row.Size = UDim2.new(1,-8,0,20); row.BackgroundTransparency = 1
            row.TextXAlignment = Enum.TextXAlignment.Left; row.Font = Enum.Font.Gotham; row.TextSize = 10
            local isUnique = string.lower(e.after or "") == "unique"
            row.TextColor3 = isUnique and Color3.fromRGB(115,230,165) or Color3.fromRGB(220,225,235)
            row.Text = string.format("#%d  %s  →  %s",i,e.before or "?",e.after or "?"); row.Parent = history
        end
    end
    if shown == 0 then local empty = label(history,"No rolls recorded for this unit yet.",UDim2.new(1,-8,0,24),UDim2.fromOffset(5,0),Color3.fromRGB(145,155,175)); empty.TextSize = 10 end
end

addBtn.MouseButton1Click:Connect(function()
    local name = unitBox.Text:gsub("^%s+"," "):gsub("%s+$","")
    if name == "" then status.Text = "Type a unit name first."; return end
    for _,u in ipairs(data.units) do if u.name == name then data.selected = name; unitBox.Text = ""; refresh(); saveData(); status.Text = "Selected existing unit."; return end end
    table.insert(data.units,{name=name}); data.selected = name; unitBox.Text = ""; refresh(); saveData(); status.Text = "Unit added."
end)
unitPicker.MouseButton1Click:Connect(function()
    if #data.units == 0 then status.Text = "Add your first unit above."; return end
    local index = 0; for i,u in ipairs(data.units) do if u.name == data.selected then index = i end end
    index = index % #data.units + 1; data.selected = data.units[index].name; refresh(); saveData()
end)
saveBtn.MouseButton1Click:Connect(function()
    if not data.selected then status.Text = "Add/select a unit first."; return end
    local before = beforeBox.Text:gsub("^%s+"," "):gsub("%s+$","")
    local after = afterBox.Text:gsub("^%s+"," "):gsub("%s+$","")
    if before == "" or after == "" then status.Text = "Fill both trait fields."; return end
    table.insert(data.history,{unit=data.selected,before=before,after=after,time=os.date("%Y-%m-%d %H:%M:%S")})
    beforeBox.Text = ""; afterBox.Text = ""; refresh()
    status.Text = saveData() and "Roll saved locally." or "Saved this session only (file API unavailable)."
end)
deleteButton.MouseButton1Click:Connect(function()
    if not data.selected then status.Text = "No unit selected."; return end
    for i = #data.history,1,-1 do if data.history[i].unit == data.selected then table.remove(data.history,i) end end
    refresh(); saveData(); status.Text = "History cleared for "..data.selected.."."
end)
exportButton.MouseButton1Click:Connect(function()
    local encoded = HttpService:JSONEncode(data)
    if type(setclipboard) == "function" then local ok = pcall(setclipboard,encoded); status.Text = ok and "JSON copied to clipboard." or "Clipboard export failed." else status.Text = "Clipboard API unavailable in this executor." end
end)
refresh()
