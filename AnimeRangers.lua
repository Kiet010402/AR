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
local macroStatusParagraph
local function updateMacroStatus(content)
    if macroStatusParagraph and macroStatusParagraph.SetDesc then
        pcall(function()
            macroStatusParagraph:SetDesc(content)
        end)
    end
end

macroStatusParagraph = MacroTab:AddParagraph({
    Title = "Status",
    Content = "Idle"
})

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
    stt = 0, -- Sequence number
    hasStarted = false,
    pendingAction = nil, -- Store only the latest action
    lastMoney = nil,
    lastMoneyRecordTime = 0, -- Debounce timer
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
    if not Recorder.isRecording or not Recorder.hasStarted then return end

    Recorder.stt = Recorder.stt + 1

    -- Cập nhật trạng thái (STT / Type / Money)
    local statusContent = string.format("-STT: %d\n-Type: %s\n-Money: %d", Recorder.stt, tostring(remoteName), tonumber(noteMoney) or 0)
    updateMacroStatus(statusContent)

    appendLine(string.format("--STT: %d", Recorder.stt))
    
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
                if not Recorder.hasStarted then
                    return oldNamecall(self, ...)
                end

                -- Money-gated recording: overwrite pending action, immediate for sell
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
            
            Recorder.isRecording = true
            Recorder.hasStarted = false
            Recorder.pendingAction = nil
            Recorder.buffer = "-- Macro recorded by HT Hub\nlocal vector = { create = function(x,y,z) return Vector3.new(x,y,z) end }\n"
            print("Recording armed. Waiting for game to start...")

            -- Wait for game to start before actually recording
            task.spawn(function()
                local gameStarted = workspace:WaitForChild("_DATA", 5) and workspace._DATA:WaitForChild("GameStarted", 5)
                if not gameStarted then
                    warn("Could not find GameStarted value. Recording will not start.")
                    return
                        updateMacroStatus("Record Completed")
                end

                while Recorder.isRecording and not gameStarted.Value do
                    task.wait(0.5)
                end

                if not Recorder.isRecording then return end -- Canceled before game started

                print("Game started! Recording has begun ->", selectedMacro)
                
                -- Start counter
                Recorder.hasStarted = true
                Recorder.stt = 0
                updateMacroStatus("Recording...")

                -- money watcher
                pcall(function()
                    local res = game:GetService("Players").LocalPlayer:WaitForChild("_stats"):WaitForChild("resource")
                    Recorder.lastMoney = tonumber(res.Value)
                    if Recorder.moneyConn then Recorder.moneyConn:Disconnect() Recorder.moneyConn = nil end
                    Recorder.moneyConn = res.Changed:Connect(function(newVal)
                        local current = tonumber(newVal)
                        if Recorder.isRecording and Recorder.hasStarted and type(current) == "number" and type(Recorder.lastMoney) == "number" then
                            if current < Recorder.lastMoney then
                                local now = tick()
                                if now - Recorder.lastMoneyRecordTime > 0.1 then
                                    Recorder.lastMoneyRecordTime = now
                                    local delta = Recorder.lastMoney - current
                                    local action = Recorder.pendingAction
                                    Recorder.pendingAction = nil
                                    if action then
                                        recordNow(action.remote, action.args, delta)
                                    end
                                end
                            end
                            Recorder.lastMoney = current
                        end
                    end)
                end)
            end)
        else
            if Recorder.isRecording then
                Recorder.isRecording = false
                if Recorder.moneyConn then
                    Recorder.moneyConn:Disconnect()
                    Recorder.moneyConn = nil
                end
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

-- Hàm mới để phân tích nội dung macro thành các lệnh có thể thực thi
local function parseMacro(content)
    local commands = {}
    -- Tách các khối lệnh bằng --STT:
    local blocks = {}
    local lastPos = 1
    for pos, stt in content:gmatch("()--STT:%s*(%d+)") do
        if #blocks > 0 then
            blocks[#blocks].text = content:sub(lastPos, pos - 1)
        end
        table.insert(blocks, {stt = tonumber(stt)})
        lastPos = pos
    end
    if #blocks > 0 then
        blocks[#blocks].text = content:sub(lastPos)
    end

    for _, block in ipairs(blocks) do
        if block.text then
            local moneyMatch = block.text:match("--note money:%s*(%d+)")
            local money = moneyMatch and tonumber(moneyMatch) or 0
            
            local code = ""
            for line in block.text:gmatch("[^\r\n]+") do
                -- Chỉ bao gồm các dòng code có thể thực thi, loại bỏ các comment và task.wait
                if not line:match("^%s*--STT") and not line:match("^%s*--note money") and not line:match("^%s*task%.wait") then
                    code = code .. line .. "\n"
                end
            end

            if code ~= "" then
                table.insert(commands, {
                    stt = block.stt,
                    money = money,
                    code = code
                })
            end
        end
    end
    
    return commands
end

-- Hàm mới để thực thi các lệnh đã phân tích
local function executeMacro(commands)
    local player = game:GetService("Players").LocalPlayer
    local resource = player:WaitForChild("_stats", 5) and player._stats:WaitForChild("resource", 5)

    if not resource then
        warn("Không thể tìm thấy tiền của người chơi (resource). Dừng macro.")
        updateMacroStatus("Lỗi: Không tìm thấy tiền người chơi.")
        return
    end

    for i, command in ipairs(commands) do
        if not _G.__HT_MACRO_PLAYING then break end

        -- Cập nhật trạng thái cho hành động tiếp theo
        -- Hiển thị STT hiện tại / tổng
        local total = #commands
        updateMacroStatus(string.format("-STT: %d/%d", i, total))

        local nextCommand = commands[i]
        if nextCommand then
            local nextType = "N/A"
            local callMatch = nextCommand.code:match("--call:%s*([%w_]+)")
            if callMatch then
                nextType = callMatch
            end
            updateMacroStatus(string.format("-STT: %d/%d\n-Next Type: %s\n-Next Money: %d", i, total, nextType, nextCommand.money))
        end

        -- Đợi đủ tiền cho các lệnh có yêu cầu tiền
        if command.money > 0 then
            -- Cập nhật print để hiển thị cả tiền hiện có
            local currentMoney = resource.Value
            print(string.format("Đang đợi đủ tiền cho STT %d: Cần %d, Hiện có %.0f", command.stt, command.money, currentMoney))
            
            while _G.__HT_MACRO_PLAYING and resource.Value < command.money do
                task.wait(0.2)
            end
        end
        
        if not _G.__HT_MACRO_PLAYING then break end

        print(string.format("Thực thi STT %d (Yêu cầu tiền: %d)", command.stt, command.money))
        
        local loadOk, fnOrErr = pcall(function() return loadstring(command.code) end)
        if loadOk and type(fnOrErr) == "function" then
            local runOk, runErr = pcall(fnOrErr)
            if not runOk then
                warn(string.format("Lỗi khi chạy STT %d: %s", command.stt, tostring(runErr)))
            end
        else
            warn(string.format("Lỗi khi tải code cho STT %d: %s", command.stt, tostring(fnOrErr)))
        end
        
        task.wait(0.1) -- Thêm một khoảng chờ nhỏ giữa các lệnh để tránh quá tải
    end
    -- Hoàn tất macro
    updateMacroStatus("Macro Completed")
end

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
                warn("Đọc file macro thất bại")
                return
            end

            -- Phân tích macro một lần
            local commands = parseMacro(content)
            if #commands == 0 then
                warn("Macro rỗng hoặc không hợp lệ. Không có lệnh nào để thực thi.")
                return
            end

            _G.__HT_MACRO_PLAYING = true
            macroPlaying = true
            
            task.spawn(function()
                while _G.__HT_MACRO_PLAYING do
                    -- Đợi game bắt đầu trước khi chơi
                    updateMacroStatus("Chờ game bắt đầu...")
                    print("Macro đã sẵn sàng. Đang chờ game bắt đầu...")
                    local gameStarted = workspace:WaitForChild("_DATA", 5) and workspace._DATA:WaitForChild("GameStarted", 5)
                    if not gameStarted then
                        warn("Không tìm thấy giá trị GameStarted. Macro sẽ không chạy.")
                        updateMacroStatus("Lỗi: Không tìm thấy GameStarted")
                        _G.__HT_MACRO_PLAYING = false
                        macroPlaying = false
                        return
                    end

                    while _G.__HT_MACRO_PLAYING and not gameStarted.Value do
                        task.wait(0.2)
                    end

                    if not _G.__HT_MACRO_PLAYING then break end -- Bị hủy trước khi game bắt đầu

                    print("Game đã bắt đầu! Đang chạy macro...")
                    executeMacro(commands) -- Gọi hàm thực thi mới
                    
                    if not _G.__HT_MACRO_PLAYING then break end

                    updateMacroStatus("Chờ game tiếp theo...")
                    print("Macro đã hoàn thành. Đang chờ game tiếp theo...")

                    -- Đợi game kết thúc (wave_num về 0)
                    local waveNum = workspace:WaitForChild("_wave_num", 5)
                    if not waveNum then
                        warn("Không tìm thấy _wave_num. Tự động lặp lại sẽ không hoạt động.")
                        updateMacroStatus("Lỗi: Không tìm thấy _wave_num")
                        break -- Thoát khỏi vòng lặp
                    end

                    while _G.__HT_MACRO_PLAYING and waveNum.Value ~= 0 do
                        task.wait(1)
                    end
                    
                    if _G.__HT_MACRO_PLAYING then
                        print("Game đã kết thúc. Đọc lại và phân tích macro từ đầu...")
                        task.wait(2) -- Chờ một chút trước khi lặp lại
                        
                        -- Đọc và phân tích lại file macro
                        local ok, content = pcall(function()
                            if isfile(path) then return readfile(path) end
                            return nil
                        end)
                        if ok and content then
                            commands = parseMacro(content) -- Cập nhật lại danh sách lệnh
                            if #commands == 0 then
                                warn("Macro rỗng hoặc không hợp lệ sau khi đọc lại.")
                                break
                            end
                            print("Đã phân tích lại macro thành công, tiếp tục vòng lặp mới.")
                        else
                            warn("Không thể đọc lại file macro.")
                            break
                        end
                    end
                end
                
                macroPlaying = false
                _G.__HT_MACRO_PLAYING = false
                updateMacroStatus("Idle")
                print("Vòng lặp macro đã dừng.")
            end)
        else
            -- Tắt
            _G.__HT_MACRO_PLAYING = false
            macroPlaying = false
            updateMacroStatus("Record Completed")
            print("Macro đã dừng")
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
