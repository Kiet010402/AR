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
ConfigSystem.FileName = "HTHubALS_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
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

-- Biến lưu trạng thái của tab Main (auto features removed)

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | Anime Last Stand",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Hệ thống Tạo Tab

-- Tạo Tab Joiner
local JoinerTab = Window:AddTab({ Title = "Joiner", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://90319448802378" })

-- Tab Joiner
-- Section Auto Play trong tab Joiner
local AutoPlaySection = JoinerTab:AddSection("Auto Play")

-- Tab Macro
-- Macro helpers
local MacroSystem = {}
MacroSystem.BaseFolder = "HTHubALS_Macros"

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
        return string.format("Vector3.new(%f, %f, %f)", v.X, v.Y, v.Z)
    end
    return tostring(v)
end

local function cframeToStr(cf)
    if typeof and typeof(cf) == "CFrame" then
        local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
        local r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        return string.format("CFrame.new(%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)", 
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    end
    return tostring(cf)
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
                elseif typeof and typeof(v) == "CFrame" then
                    valueStr = cframeToStr(v)
                elseif typeof and typeof(v) == "Instance" then
                    -- Special handling for Instance objects (like Tower references)
                    if v.Parent and v.Name then
                        valueStr = string.format("workspace:WaitForChild(\"Towers\"):WaitForChild(\"%s\")", v.Name)
                    else
                        valueStr = tostring(v)
                    end
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
                elseif typeof and typeof(v) == "CFrame" then
                    valueStr = cframeToStr(v)
                elseif typeof and typeof(v) == "Instance" then
                    -- Special handling for Instance objects (like Tower references)
                    if v.Parent and v.Name then
                        valueStr = string.format("workspace:WaitForChild(\"Towers\"):WaitForChild(\"%s\")", v.Name)
                    else
                        valueStr = tostring(v)
                    end
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
    
    -- Sử dụng FireServer cho PlaceTower và PlayerReady, InvokeServer cho Upgrade
    if remoteName == "PlaceTower" or remoteName == "PlayerReady" then
        appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"Remotes\"):WaitForChild(\"" .. remoteName .. "\"):FireServer(unpack(args))")
    else
        appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"Remotes\"):WaitForChild(\"" .. remoteName .. "\"):InvokeServer(unpack(args))")
    end
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
            if Recorder.isRecording and (tostring(method) == "FireServer" or tostring(method) == "InvokeServer") then
                local args = {...}
                -- Only record whitelisted endpoints
                local remoteName = tostring(self and self.Name or "")
                local allowed = {
                    PlaceTower = true,
                    Upgrade = true,
                    PlayerReady = true,
                }
                if not allowed[remoteName] then
                    return oldNamecall(self, ...)
                end
                if not Recorder.hasStarted then
                    return oldNamecall(self, ...)
                end

                -- Money-gated recording: overwrite pending action, immediate for PlayerReady
                if remoteName == "PlaceTower" or remoteName == "Upgrade" then
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
            Recorder.buffer = "-- Macro recorded by HT Hub\n"
            print("Recording started ->", selectedMacro)

            -- Start recording immediately
            Recorder.hasStarted = true
            Recorder.stt = 0
            updateMacroStatus("Recording...")
            print("Recording started ->", selectedMacro)

            -- money watcher
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local cash = player:WaitForChild("Cash", 5)
                if not cash then
                    warn("Could not find Cash value")
                    return
                end
                
                Recorder.lastMoney = tonumber(cash.Value)
                if Recorder.moneyConn then Recorder.moneyConn:Disconnect() Recorder.moneyConn = nil end
                Recorder.moneyConn = cash.Changed:Connect(function(newVal)
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
    local cash = player:WaitForChild("Cash", 5)

    if not cash then
        warn("Không thể tìm thấy tiền của người chơi (Cash). Dừng macro.")
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
            local currentMoney = cash.Value
            print(string.format("Đang đợi đủ tiền cho STT %d: Cần %d, Hiện có %.0f", command.stt, command.money, currentMoney))
            
            while _G.__HT_MACRO_PLAYING and cash.Value < command.money do
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
                    -- Chạy macro ngay lập tức
                    updateMacroStatus("Đang chạy macro...")
                    print("Đang chạy macro...")
                    
                    executeMacro(commands) -- Gọi hàm thực thi mới
                    
                    if not _G.__HT_MACRO_PLAYING then break end

                    updateMacroStatus("Chờ game tiếp theo...")
                    print("Macro đã hoàn thành. Đang chờ game tiếp theo...")

                    -- Đợi Wave về 1 để lặp lại
                    local wave = game:GetService("ReplicatedStorage"):WaitForChild("Wave", 5)
                    if not wave then
                        warn("Không tìm thấy Wave. Tự động lặp lại sẽ không hoạt động.")
                        updateMacroStatus("Lỗi: Không tìm thấy Wave")
                        break -- Thoát khỏi vòng lặp
                    end

                    while _G.__HT_MACRO_PLAYING and wave.Value ~= 1 do
                        task.wait(1)
                    end
                    
                    if _G.__HT_MACRO_PLAYING then
                        print("Wave = 1. Lặp lại macro.")
                        task.wait(2) -- Chờ một chút trước khi lặp lại
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
            updateMacroStatus("Idle")
            print("Macro đã dừng")
        end
    end
})

-- Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubALS")
SaveManager:SetFolder("HTHubALS/" .. playerName)

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
    for _, tab in pairs({JoinerTab, MacroTab, SettingsTab}) do
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
            ImageButton.Image = "rbxassetid://90319448802378" -- Logo HT Hub
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

print("HT Hub Anime Last Stand Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
