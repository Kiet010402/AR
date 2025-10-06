-- Load UI Library với error handling
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải UI Library: " .. tostring(err))
    return
end

-- Đợi đến khi Fluent được tải hoàn tất
if not Fluent then
    warn("Không thể tải thư viện Fluent!")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubAnimeCrusaders_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Maps Settings
    SelectedMap = "namek",
    SelectedAct = "Act 1",
    SelectedDifficulty = "normal",
    FriendOnly = false,
    AutoJoin = false,
    AutoMatching = false,
    -- Script Settings
    AntiAFK = false,
    -- Macro Settings
    SelectedMacro = "",
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        print("Đã lưu cấu hình thành công!")
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        ConfigSystem.CurrentConfig = data
        return true
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Biến lưu trạng thái của tab Maps
-- Biến lưu trạng thái cho Story selections và toggles
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "namek"
local selectedAct = ConfigSystem.CurrentConfig.SelectedAct or "Act 1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoin = ConfigSystem.CurrentConfig.AutoJoin or false
local autoMatching = ConfigSystem.CurrentConfig.AutoMatching or false
-- Biến lưu trạng thái cho Script Settings
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFK or false

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | Anime Crusaders",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Hệ thống Tạo Tab

-- Tạo Tab Maps
local MapsTab = Window:AddTab({ Title = "Maps", Icon = "rbxassetid://13311802307" })
-- Tạo Tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311802307" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tab Maps
-- Section Story trong tab Maps
local StorySection = MapsTab:AddSection("Story")

-- Macro helpers
local MacroSystem = {}
MacroSystem.BaseFolder = "HTHubAnimeCrusaders_Macros"

local function ensureMacroFolder()
    pcall(function()
        if not isfolder(MacroSystem.BaseFolder) then
            makefolder(MacroSystem.BaseFolder)
        end
    end)
end

ensureMacroFolder()

local function listMacros()
    local names = {}
    local ok, files = pcall(function()
        return listfiles(MacroSystem.BaseFolder)
    end)
    if ok and files then
        for _, p in ipairs(files) do
            local name = string.match(p, "[^/\\]+$")
            if name then table.insert(names, name) end
        end
    end
    table.sort(names)
    return names
end

local function macroPath(name)
    return MacroSystem.BaseFolder .. "/" .. name
end

local selectedMacro = ConfigSystem.CurrentConfig.SelectedMacro or ""
local pendingMacroName = ""

-- Macro UI
local MacroSection = MacroTab:AddSection("Macro Recorder")

-- Dropdown select macro
local MacroDropdown = MacroSection:AddDropdown("MacroSelect", {
    Title = "Select Macro",
    Description = "Chọn file macro",
    Values = listMacros(),
    Default = selectedMacro ~= "" and selectedMacro or nil,
    Callback = function(val)
        selectedMacro = val
        ConfigSystem.CurrentConfig.SelectedMacro = val
        ConfigSystem.SaveConfig()
    end
})

-- Input macro name
MacroSection:AddInput("MacroNameInput", {
    Title = "Macro name",
    Default = "",
    Placeholder = "vd: my_macro.txt",
    Callback = function(val)
        pendingMacroName = tostring(val or "")
    end
})

-- Create macro button
MacroSection:AddButton({
    Title = "Create Macro",
    Description = "Tạo file macro .txt",
    Callback = function()
        local name = pendingMacroName ~= "" and pendingMacroName or ("macro_" .. os.time() .. ".txt")
        if not string.find(name, "%.") then name = name .. ".txt" end
        local path = macroPath(name)
        local ok, errMsg = pcall(function()
            ensureMacroFolder()
            if not isfile(path) then
                writefile(path, "-- New macro file\n")
            end
        end)
        if ok then
            selectedMacro = name
            ConfigSystem.CurrentConfig.SelectedMacro = name
            ConfigSystem.SaveConfig()
            -- refresh dropdown
            pcall(function()
                MacroDropdown:SetValues(listMacros())
                MacroDropdown:SetValue(selectedMacro)
            end)
            print("Created macro:", name)
        else
            warn("Create macro failed:", errMsg)
        end
    end
})

-- Delete macro button
MacroSection:AddButton({
    Title = "Delete Macro",
    Description = "Xóa file macro đang chọn",
    Callback = function()
        if not selectedMacro or selectedMacro == "" then return end
        local path = macroPath(selectedMacro)
        local ok, errMsg = pcall(function()
            if isfile(path) then delfile(path) end
        end)
        if ok then
            print("Deleted macro:", selectedMacro)
            selectedMacro = ""
            ConfigSystem.CurrentConfig.SelectedMacro = ""
            ConfigSystem.SaveConfig()
            pcall(function()
                MacroDropdown:SetValues(listMacros())
                MacroDropdown:SetValue(nil)
            end)
        else
            warn("Delete macro failed:", errMsg)
        end
    end
})

-- Recorder state
local Recorder = {
    isRecording = false,
    baseTime = 0,
    lastEventTime = 0,
    hasStarted = false,
    pendingAction = nil,
    lastMoney = nil,
    moneyConn = nil,
    buffer = nil,
}

local function appendLine(line)
    if Recorder.buffer then
        Recorder.buffer = Recorder.buffer .. line .. "\n"
    end
end

-- Helpers for serialization and recording
local function vecToStr(v)
    if typeof and typeof(v) == "Vector3" then
        return string.format("vector.create(%f, %f, %f)", v.X, v.Y, v.Z)
    end
    return tostring(v)
end

local function isArray(tbl)
    local n = 0
    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
            return false
        end
        if k > n then n = k end
    end
    for i = 1, n do
        if tbl[i] == nil then return false end
    end
    return true, n
end

local function serialize(val, indent)
    indent = indent or 0
    local pad = string.rep(" ", indent)
    if type(val) == "table" then
        local arr, n = isArray(val)
        local parts = {"{"}
        if arr then
            for i = 1, n do
                local v = val[i]
                local valueStr
                if typeof and typeof(v) == "Vector3" then
                    valueStr = vecToStr(v)
                elseif type(v) == "table" then
                    valueStr = serialize(v, indent + 4)
                elseif type(v) == "string" then
                    valueStr = string.format("\"%s\"", v)
                else
                    valueStr = tostring(v)
                end
                table.insert(parts, string.format("\n%s    %s,", pad, valueStr))
            end
        else
            for k, v in pairs(val) do
                local key = tostring(k)
                local valueStr
                if typeof and typeof(v) == "Vector3" then
                    valueStr = vecToStr(v)
                elseif type(v) == "table" then
                    valueStr = serialize(v, indent + 4)
                elseif type(v) == "string" then
                    valueStr = string.format("\"%s\"", v)
                else
                    valueStr = tostring(v)
                end
                table.insert(parts, string.format("\n%s    %s = %s,", pad, key, valueStr))
            end
        end
        table.insert(parts, string.format("\n%s}", pad))
        return table.concat(parts)
    elseif type(val) == "string" then
        return string.format("\"%s\"", val)
    else
        return tostring(val)
    end
end

local function recordNow(remoteName, args, noteMoney)
    if noteMoney and noteMoney > 0 then
        appendLine(string.format("--note money: %d", noteMoney))
    end
    local okSer, argsStr = pcall(function()
        return serialize(args)
    end)
    appendLine("--call: " .. remoteName)
    if okSer and argsStr then
        appendLine("local args = " .. argsStr)
    else
        appendLine("-- serialize error: " .. tostring(argsStr))
        appendLine("local args = {}")
    end
    appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"endpoints\"):WaitForChild(\"client_to_server\"):WaitForChild(\"" .. remoteName .. "\"):InvokeServer(unpack(args))")
end

-- Install namecall hook (once)
local hookInstalled = false
local oldNamecall
local function installHookOnce()
    if hookInstalled then return end
    hookInstalled = true
    local ok, res = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            if Recorder.isRecording and tostring(method) == "InvokeServer" then
                local args = {...}
                -- Only record whitelisted endpoints
                local remoteName = tostring(self and self.Name or "")
                local allowed = {
                    vote_start = true,
                    spawn_unit = true,
                    upgrade_unit_ingame = true,
                    sell_unit_ingame = true,
                }
                if not allowed[remoteName] then
                    return oldNamecall(self, ...)
                end
                -- Start only when vote_start is seen, also setup watchers
                if not Recorder.hasStarted then
                    if remoteName ~= "vote_start" then
                        return oldNamecall(self, ...)
                    end
                    -- ensure wave exists (non-blocking)
                    pcall(function()
                        workspace:WaitForChild("_wave_num", 5)
                    end)
                    -- money watcher
                    pcall(function()
                        local res = game:GetService("Players").LocalPlayer:WaitForChild("_stats"):WaitForChild("resource")
                        Recorder.lastMoney = tonumber(res.Value)
                        if Recorder.moneyConn then Recorder.moneyConn:Disconnect() Recorder.moneyConn = nil end
                        Recorder.moneyConn = res.Changed:Connect(function(newVal)
                            local current = tonumber(newVal)
                            if Recorder.isRecording and Recorder.hasStarted and type(current) == "number" and type(Recorder.lastMoney) == "number" then
                                if current < Recorder.lastMoney then
                                    local delta = Recorder.lastMoney - current
                                    local action = Recorder.pendingAction
                                    Recorder.pendingAction = nil
                                    if action then
                                        recordNow(action.remote, action.args, delta)
                                    end
                                end
                                Recorder.lastMoney = current
                            end
                        end)
                    end)
                    Recorder.hasStarted = true
                    appendLine("--vote_start")
                    appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"endpoints\"):WaitForChild(\"client_to_server\"):WaitForChild(\"vote_start\"):InvokeServer()")
                    return oldNamecall(self, ...)
                end
                -- Money-gated recording: queue cost actions, immediate for sell
                if remoteName == "spawn_unit" or remoteName == "upgrade_unit_ingame" then
                    Recorder.pendingAction = { remote = remoteName, args = args }
                else
                    recordNow(remoteName, args)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not ok then
        warn("Failed to install hook:", res)
    end
end

-- Toggle record macro
MacroSection:AddToggle("RecordMacroToggle", {
    Title = "Record Macro",
    Description = "Ghi macro và thời gian chờ",
    Default = false,
    Callback = function(enabled)
        if enabled then
            installHookOnce()
            if not selectedMacro or selectedMacro == "" then
                -- auto name
                selectedMacro = "macro_" .. os.time() .. ".txt"
                ConfigSystem.CurrentConfig.SelectedMacro = selectedMacro
                ConfigSystem.SaveConfig()
            end
            local path = macroPath(selectedMacro)
            Recorder.isRecording = true
            Recorder.baseTime = 0
            Recorder.lastEventTime = 0
            Recorder.hasStarted = false
            Recorder.buffer = "-- Macro recorded by HT Hub\nlocal vector = { create = function(x,y,z) return Vector3.new(x,y,z) end }\n"
            print("Recording started ->", selectedMacro)
        else
            if Recorder.isRecording then
                Recorder.isRecording = false
                local path = macroPath(selectedMacro)
                local ok, errMsg = pcall(function()
                    writefile(path, Recorder.buffer or "-- empty macro\n")
                end)
                if ok then
                    print("Recording saved:", selectedMacro)
                    pcall(function()
                        MacroDropdown:SetValues(listMacros())
                        MacroDropdown:SetValue(selectedMacro)
                    end)
                else
                    warn("Save macro failed:", errMsg)
                end
        end
    end
end
})

-- Play macro
local macroPlaying = false
MacroSection:AddToggle("PlayMacroToggle", {
    Title = "Play Macro",
    Description = "Bật/tắt phát macro đang chọn",
    Default = false,
    Callback = function(isOn)
        if isOn then
            if not selectedMacro or selectedMacro == "" then
                warn("Chưa chọn macro để phát")
                return
            end
            local path = macroPath(selectedMacro)
            local ok, content = pcall(function()
                if isfile(path) then return readfile(path) end
                return nil
            end)
            if not (ok and content) then
                warn("Read macro failed")
                return
            end
            _G.__HT_MACRO_PLAYING = true
            macroPlaying = true
            -- thay task.wait bằng SAFE_WAIT để có thể dừng giữa chừng
            local transformed = tostring(content):gsub("task%.wait%(", "SAFE_WAIT(")
            local runnerCode = table.concat({
                "local SAFE_WAIT=function(t) local s=tick() while _G.__HT_MACRO_PLAYING and (tick()-s)<t do task.wait(0.05) end end\n",
                "return function()\n",
                transformed,
                "\nend"
            })
            local loadOk, fnOrErr = pcall(function() return loadstring(runnerCode)() end)
            if loadOk and type(fnOrErr) == "function" then
                task.spawn(function()
                    local runOk, runErr = pcall(fnOrErr)
                    if not runOk then warn("Run macro error:", runErr) end
                    macroPlaying = false
                    _G.__HT_MACRO_PLAYING = false
                    print("Macro finished")
                end)
            else
                warn("Load macro error:", fnOrErr)
            end
        else
            -- turn off
            _G.__HT_MACRO_PLAYING = false
            macroPlaying = false
            print("Macro stopped")
        end
    end
})

-- Hàm Auto Join theo 3 bước
local function executeAutoJoin()
    if not autoJoin then return end
        local success, err = pcall(function()
        -- Bước 1: Join lobby
        local args1 = {"P1"}
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args1))

        wait(1)

        -- Bước 2: Lock level
        local actNumber = string.match(selectedAct, "%d+")
        local levelName
        if selectedMap == "Entertainment_district" then
            levelName = "Entertainment_district_" .. tostring(actNumber)
        else
            levelName = selectedMap .. "_level_" .. tostring(actNumber)
        end

        local difficultyPretty = string.upper(string.sub(selectedDifficulty, 1, 1)) .. string.sub(selectedDifficulty, 2)

        local args2 = {
            "P1",
            levelName,
            friendOnly,
            difficultyPretty
        }
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args2))

        wait(1)

        -- Bước 3: Start game
        local args3 = {"P1"}
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer(unpack(args3))
        end)
        
        if not success then
        warn("Lỗi Auto Join: " .. tostring(err))
        else
        print("Auto Join executed successfully")
    end
end

-- Dropdown Select Map
StorySection:AddDropdown("MapDropdown", {
    Title = "Select Map",
    Description = "Chọn map để chơi",
    Values = {"namek", "marineford", "karakura", "shibuya", "Entertainment_district"},
    Default = ConfigSystem.CurrentConfig.SelectedMap or "namek",
    Callback = function(Value)
        selectedMap = Value
        ConfigSystem.CurrentConfig.SelectedMap = Value
        ConfigSystem.SaveConfig()
    end
})

-- Dropdown Act
StorySection:AddDropdown("ActDropdown", {
    Title = "Act",
    Description = "Chọn act để chơi",
    Values = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"},
    Default = ConfigSystem.CurrentConfig.SelectedAct or "Act 1",
    Callback = function(Value)
        selectedAct = Value
        ConfigSystem.CurrentConfig.SelectedAct = Value
        ConfigSystem.SaveConfig()
    end
})

-- Dropdown Difficulty
StorySection:AddDropdown("DifficultyDropdown", {
    Title = "Difficulty",
    Description = "Chọn độ khó",
    Values = {"normal", "hard"},
    Default = ConfigSystem.CurrentConfig.SelectedDifficulty or "normal",
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()
    end
})

-- Toggle Friend Only
StorySection:AddToggle("FriendOnlyToggle", {
    Title = "Friend Only",
    Description = "Chỉ chơi với bạn bè",
    Default = ConfigSystem.CurrentConfig.FriendOnly or false,
    Callback = function(Value)
        friendOnly = Value
        ConfigSystem.CurrentConfig.FriendOnly = Value
        ConfigSystem.SaveConfig()
        if friendOnly then
            print("Friend Only Enabled - Đã bật chế độ chỉ chơi với bạn bè")
        else
            print("Friend Only Disabled - Đã tắt chế độ chỉ chơi với bạn bè")
        end
    end
})

-- Toggle Auto Join
StorySection:AddToggle("AutoJoinToggle", {
    Title = "Auto Join",
    Description = "Tự động tham gia game theo cài đặt",
    Default = ConfigSystem.CurrentConfig.AutoJoin or false,
    Callback = function(Value)
        autoJoin = Value
        ConfigSystem.CurrentConfig.AutoJoin = Value
        ConfigSystem.SaveConfig()
        if autoJoin then
            print("Auto Join Enabled - Đã bật tự động tham gia game")
            executeAutoJoin()
        else
            print("Auto Join Disabled - Đã tắt tự động tham gia game")
        end
    end
})

-- Hàm Auto Matching theo 2 bước
local function executeAutoMatching()
    if not autoMatching then return end
    local success, err = pcall(function()
        -- Bước 1: Join lobby
        local args1 = {"P1"}
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args1))

        wait(1)

        -- Bước 2: Request matchmaking
        local difficultyPretty = string.upper(string.sub(selectedDifficulty, 1, 1)) .. string.sub(selectedDifficulty, 2)
        local args2 = {
            selectedMap .. "_level_1",
            {
                Difficulty = difficultyPretty
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer(unpack(args2))
    end)

    if not success then
        warn("Lỗi Auto Matching: " .. tostring(err))
    else
        print("Auto Matching executed successfully")
    end
end

-- Toggle Auto Join Matching
StorySection:AddToggle("AutoMatchingToggle", {
    Title = "Auto Join Matching",
    Description = "Tự động tìm kiếm game phù hợp",
    Default = ConfigSystem.CurrentConfig.AutoMatching or false,
    Callback = function(Value)
        autoMatching = Value
        ConfigSystem.CurrentConfig.AutoMatching = Value
        ConfigSystem.SaveConfig()
        if autoMatching then
            print("Auto Matching Enabled - Đã bật tự động tìm kiếm game")
            executeAutoMatching()
        else
            print("Auto Matching Disabled - Đã tắt tự động tìm kiếm game")
        end
    end
})

-- Tab Settings
-- Script Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Anti AFK Toggle và logic
local antiAfkConnection
local function setAntiAFK(enabled)
    if enabled then
        if not antiAfkConnection then
            local VirtualUser = game:GetService("VirtualUser")
            antiAfkConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

SettingsSection:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Description = "Chống out do AFK",
    Default = ConfigSystem.CurrentConfig.AntiAFK or false,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()
        setAntiAFK(antiAFKEnabled)
        if antiAFKEnabled then
            print("Anti AFK Enabled")
        else
            print("Anti AFK Disabled")
        end
    end
})

-- Khởi tạo Anti AFK theo config
setAntiAFK(antiAFKEnabled)

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubAnimeCrusaders")
SaveManager:SetFolder("HTHubAnimeCrusaders/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Auto Save Config
local function AutoSaveConfig()
    spawn(function()
        while wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    for _, tab in pairs({MapsTab, SettingsTab}) do
        if tab and tab._components then
            for _, element in pairs(tab._components) do
                if element and element.OnChanged then
                    element.OnChanged:Connect(function()
                        pcall(function()
                            ConfigSystem.SaveConfig()
                        end)
                    end)
                end
            end
        end
    end
end

-- Thiết lập events
setupSaveEvents()

-- Tạo logo để mở lại UI khi đã minimize
task.spawn(function()
    local success, errorMsg = pcall(function()
        if not getgenv().LoadedMobileUI == true then 
            getgenv().LoadedMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")
            
            -- Kiểm tra môi trường
            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end
            
            OpenUI.Name = "OpenUI"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9,0,0.1,0)
            ImageButton.Size = UDim2.new(0,50,0,50)
            ImageButton.Image = "rbxassetid://13099788281" -- Logo HT Hub
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.LeftControl,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

print("HT Hub Anime Crusaders Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
