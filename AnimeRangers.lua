-- Anime Rangers X Script

-- Kiểm tra Place ID
local currentPlaceId = game.PlaceId
local allowedPlaceId = 72829404259339

if currentPlaceId ~= allowedPlaceId then
    warn("Script này chỉ hoạt động trên game Anime Rangers X (Place ID: " .. tostring(allowedPlaceId) .. ")")
    return
end

-- Phiên bản thay thế cho Fluent:Notify
local Fluent = {}
Fluent.Notify = function(options)
    local title = options.Title or ""
    local content = options.Content or ""
    local duration = options.Duration or 3
    
    -- In thông báo ra console thay vì hiển thị UI
    print("[" .. title .. "] " .. content)
    
    -- Có thể thêm logic thông báo khác tại đây nếu cần
    return {
        -- Giả lập các phương thức của đối tượng thông báo Fluent nếu cần
        Destroy = function() end
    }
end

-- Hệ thống xác thực key
local KeySystem = {}
KeySystem.Keys = {
    "HT_ANIME_RANGERS_ACCESS_5723",  -- Key 1
    "RANGER_PRO_ACCESS_9841",        -- Key 2
    "PREMIUM_ANIME_ACCESS_3619"      -- Key 3
}
KeySystem.KeyFileName = "htkey_anime_rangers.txt"
KeySystem.WebhookURL = "https://discord.com/api/webhooks/1348673902506934384/ZRMIlRzlQq9Hfnjgpu96GGF7jCG8mG1qqfya3ErW9YvbuIKOaXVomOgjg4tM_Xk57yAK" -- Thay bằng webhook của bạn

-- Hàm kiểm tra key đã lưu
KeySystem.CheckSavedKey = function()
    if not isfile then
        return false, "Executor của bạn không hỗ trợ isfile/readfile"
    end
    
    if isfile(KeySystem.KeyFileName) then
        local savedKey = readfile(KeySystem.KeyFileName)
        for _, validKey in ipairs(KeySystem.Keys) do
            if savedKey == validKey then
                return true, "Key hợp lệ"
            end
        end
        -- Nếu key không hợp lệ, xóa file
        delfile(KeySystem.KeyFileName)
    end
    
    return false, "Key không hợp lệ hoặc chưa được lưu"
end

-- Hàm lưu key
KeySystem.SaveKey = function(key)
    if not writefile then
        return false, "Executor của bạn không hỗ trợ writefile"
    end
    
    writefile(KeySystem.KeyFileName, key)
    return true, "Đã lưu key"
end

-- Hàm gửi log đến webhook Discord
KeySystem.SendWebhook = function(username, key, status)
    if KeySystem.WebhookURL == "https://discord.com/api/webhooks/1348673902506934384/ZRMIlRzlQq9Hfnjgpu96GGF7jCG8mG1qqfya3ErW9YvbuIKOaXVomOgjg4tM_Xk57yAK" then
        return -- Bỏ qua nếu webhook chưa được cấu hình
    end
    
    local HttpService = game:GetService("HttpService")
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "Anime Rangers X Script - Key Log",
            ["description"] = "Người dùng đã sử dụng script",
            ["type"] = "rich",
            ["color"] = status and 65280 or 16711680,
            ["fields"] = {
                {
                    ["name"] = "Username",
                    ["value"] = username,
                    ["inline"] = true
                },
                {
                    ["name"] = "Key Status",
                    ["value"] = status and "Hợp lệ" or "Không hợp lệ",
                    ["inline"] = true
                },
                {
                    ["name"] = "Key Used",
                    ["value"] = key ~= "" and key or "N/A",
                    ["inline"] = true
                }
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, _ = pcall(function()
        HttpService:PostAsync(KeySystem.WebhookURL, HttpService:JSONEncode(data))
    end)
    
    return success
end

-- Tạo UI nhập key
KeySystem.CreateKeyUI = function()
    local success, keyValid = KeySystem.CheckSavedKey()
    if success then
        print("HT Hub | Key hợp lệ, đang tải script...")
        KeySystem.SendWebhook(game.Players.LocalPlayer.Name, "Key đã lưu", true)
        return true
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local Description = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local UICorner_2 = Instance.new("UICorner")
    local SubmitButton = Instance.new("TextButton")
    local UICorner_3 = Instance.new("UICorner")
    local GetKeyButton = Instance.new("TextButton")
    local UICorner_4 = Instance.new("UICorner")
    local StatusLabel = Instance.new("TextLabel")
    
    -- Thiết lập UI
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    ScreenGui.Name = "HTHubKeySystem"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.Position = UDim2.new(0.5, -175, 0.5, -125)
    Main.Size = UDim2.new(0, 350, 0, 250)
    
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Main
    
    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "HT Hub | Anime Rangers X"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20.000
    
    Description.Name = "Description"
    Description.Parent = Main
    Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Description.BackgroundTransparency = 1.000
    Description.Position = UDim2.new(0, 0, 0, 45)
    Description.Size = UDim2.new(1, 0, 0, 40)
    Description.Font = Enum.Font.Gotham
    Description.Text = "Nhập key để sử dụng script"
    Description.TextColor3 = Color3.fromRGB(200, 200, 200)
    Description.TextSize = 14.000
    
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = Main
    KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    KeyInput.Position = UDim2.new(0.5, -125, 0, 100)
    KeyInput.Size = UDim2.new(0, 250, 0, 40)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Nhập key vào đây..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    
    UICorner_2.CornerRadius = UDim.new(0, 6)
    UICorner_2.Parent = KeyInput
    
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = Main
    SubmitButton.BackgroundColor3 = Color3.fromRGB(90, 90, 255)
    SubmitButton.Position = UDim2.new(0.5, -60, 0, 155)
    SubmitButton.Size = UDim2.new(0, 120, 0, 35)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Text = "Xác nhận"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    
    UICorner_3.CornerRadius = UDim.new(0, 6)
    UICorner_3.Parent = SubmitButton
    
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = Main
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    GetKeyButton.Position = UDim2.new(0.5, -75, 0, 200)
    GetKeyButton.Size = UDim2.new(0, 150, 0, 35)
    GetKeyButton.Font = Enum.Font.GothamBold
    GetKeyButton.Text = "Lấy key tại discord"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    
    UICorner_4.CornerRadius = UDim.new(0, 6)
    UICorner_4.Parent = GetKeyButton
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = Main
    StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.BackgroundTransparency = 1.000
    StatusLabel.Position = UDim2.new(0, 0, 0, 240)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 12.000
    
    -- Biến để theo dõi trạng thái xác thực
    local keyAuthenticated = false
    
    -- Hàm xác thực key
    local function checkKey(key)
        for _, validKey in ipairs(KeySystem.Keys) do
            if key == validKey then
                return true
            end
        end
        return false
    end
    
    -- Xử lý sự kiện nút Submit
    SubmitButton.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text
        
        if inputKey == "" then
            StatusLabel.Text = "Vui lòng nhập key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        local isKeyValid = checkKey(inputKey)
        
        if isKeyValid then
            StatusLabel.Text = "Key hợp lệ! Đang tải script..."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- Lưu key
            KeySystem.SaveKey(inputKey)
            
            -- Gửi log
            KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, true)
            
            -- Đánh dấu đã xác thực thành công
            keyAuthenticated = true
            
            -- Xóa UI sau 1 giây
            wait(1)
            ScreenGui:Destroy()
        else
            StatusLabel.Text = "Key không hợp lệ, vui lòng thử lại"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- Gửi log
            KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, false)
        end
    end)
    
    -- Xử lý sự kiện nút Get Key
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/6WXu2zZC3d")
        StatusLabel.Text = "Đã sao chép liên kết vào clipboard"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    -- Đợi cho đến khi xác thực thành công hoặc đóng UI
    local startTime = tick()
    local timeout = 300 -- 5 phút timeout
    
    repeat
        wait(0.1)
    until keyAuthenticated or (tick() - startTime > timeout)
    
    if keyAuthenticated then
        return true
    else
        -- Nếu hết thời gian chờ mà không xác thực, đóng UI và trả về false
        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy() 
        end
        return false
    end
end

-- Khởi chạy hệ thống key
local keyValid = KeySystem.CreateKeyUI()
if not keyValid then
    -- Nếu key không hợp lệ, dừng script
    warn("Key không hợp lệ hoặc đã hết thời gian chờ. Script sẽ dừng.")
    return
end

-- Delay 30 giây trước khi mở script
print("HT Hub | Anime Rangers X đang khởi động, vui lòng đợi 15 giây...")
wait(15)
print("Đang tải script...")

-- Tải thư viện Fluent
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

if not Fluent then
    error("Không thể tải thư viện Fluent. Vui lòng kiểm tra kết nối internet hoặc executor.")
    return
end

-- Utility function để kiểm tra và lấy service/object một cách an toàn
local function safeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Utility function để kiểm tra và lấy child một cách an toàn
local function safeGetChild(parent, childName, waitTime)
    if not parent then return nil end
    
    local child = parent:FindFirstChild(childName)
    
    -- Chỉ sử dụng WaitForChild nếu thực sự cần thiết
    if not child and waitTime and waitTime > 0 then
        local success, result = pcall(function()
            return parent:WaitForChild(childName, waitTime)
        end)
        if success then child = result end
    end
    
    return child
end

-- Utility function để lấy đường dẫn đầy đủ một cách an toàn
local function safeGetPath(startPoint, path, waitTime)
    if not startPoint then return nil end
    waitTime = waitTime or 0.5 -- Giảm thời gian chờ mặc định xuống 0.5 giây
    
    local current = startPoint
    for _, name in ipairs(path) do
        if not current then return nil end
        current = safeGetChild(current, name, waitTime)
    end
    
    return current
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubARConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Các cài đặt mặc định
    UITheme = "Amethyst",
    
    -- Cài đặt Shop/Summon
    SummonAmount = "x1",
    SummonBanner = "Standard",
    AutoSummon = false,
    
    -- Cài đặt Quest
    AutoClaimQuest = false,
    
    -- Cài đặt Story
    SelectedMap = "OnePiece",
    SelectedChapter = "Chapter1",
    SelectedDifficulty = "Normal",
    FriendOnly = false,
    AutoJoinMap = false,
    StoryTimeDelay = 5,
    
    -- Cài đặt Ranger Stage
    SelectedRangerMap = "OnePiece",
    SelectedRangerMaps = {}, -- Thêm cấu hình mặc định cho map đã chọn (ban đầu rỗng hoặc chỉ có map default)
    SelectedActs = {RangerStage1 = true},
    RangerFriendOnly = false,
    AutoJoinRanger = false,
    RangerTimeDelay = 5,
    
    -- Cài đặt Boss Event
    AutoBossEvent = false,
    BossEventTimeDelay = 5,
    
    -- Cài đặt Challenge
    AutoChallenge = false,
    ChallengeTimeDelay = 5,
    
    -- Cài đặt In-Game
    AutoPlay = false,
    AutoRetry = false,
    AutoNext = false,
    AutoVote = false,
    RemoveAnimation = true,
    
    -- Cài đặt Update Units
    AutoUpdate = false,
    AutoUpdateRandom = false,
    Slot1Level = 0,
    Slot2Level = 0,
    Slot3Level = 0,
    Slot4Level = 0,
    Slot5Level = 0,
    Slot6Level = 0,
    
    -- Cài đặt AFK
    AutoJoinAFK = false,
    
    -- Cài đặt UI
    AutoHideUI = false,
    
    -- Cài đặt Merchant
    SelectedMerchantItems = {},
    AutoMerchantBuy = false,
    
    -- Cài đặt Auto TP Lobby
    AutoTPLobby = false,
    AutoTPLobbyDelay = 10, -- Mặc định 10 phút
    
    -- Cài đặt Auto Scan Units
    AutoScanUnits = true, -- Mặc định bật
    
    -- Cài đặt Easter Egg
    AutoJoinEasterEgg = false,
    EasterEggTimeDelay = 5,
    
    -- Cài đặt Anti AFK
    AntiAFK = true, -- Mặc định bật
    
    -- Cài đặt Auto Leave
    AutoLeave = false,
    
    -- Cài đặt Webhook
    WebhookURL = "",
    AutoSendWebhook = false,
}
ConfigSystem.CurrentConfig = {}

-- Cache cho ConfigSystem để giảm lượng I/O
ConfigSystem.LastSaveTime = 0
ConfigSystem.SaveCooldown = 2 -- 2 giây giữa các lần lưu
ConfigSystem.PendingSave = false

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    -- Kiểm tra thời gian từ lần lưu cuối
    local currentTime = os.time()
    if currentTime - ConfigSystem.LastSaveTime < ConfigSystem.SaveCooldown then
        -- Đã lưu gần đây, đánh dấu để lưu sau
        ConfigSystem.PendingSave = true
        return
    end
    
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        writefile(ConfigSystem.FileName, HttpService:JSONEncode(ConfigSystem.CurrentConfig))
    end)
    
    if success then
        ConfigSystem.LastSaveTime = currentTime
        ConfigSystem.PendingSave = false
        -- Không cần in thông báo mỗi lần lưu để giảm spam
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
        local success2, data = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONDecode(content)
        end)
        
        if success2 and data then
            -- Merge with default config to ensure all settings exist
            for key, value in pairs(ConfigSystem.DefaultConfig) do
                if data[key] == nil then
                    data[key] = value
                end
            end
            
        ConfigSystem.CurrentConfig = data
        return true
        end
    end
    
    -- Nếu tải thất bại, sử dụng cấu hình mặc định
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end

-- Thiết lập timer để lưu định kỳ nếu có thay đổi chưa lưu
spawn(function()
    while wait(5) do
        if ConfigSystem.PendingSave then
            ConfigSystem.SaveConfig()
        end
end
end)

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Biến toàn cục để theo dõi UI
local OpenUI = nil
local isMinimized = false

-- Biến lưu trạng thái Summon
local selectedSummonAmount = ConfigSystem.CurrentConfig.SummonAmount or "x1"
local selectedSummonBanner = ConfigSystem.CurrentConfig.SummonBanner or "Standard"
local autoSummonEnabled = ConfigSystem.CurrentConfig.AutoSummon or false
local autoSummonLoop = nil

-- Biến lưu trạng thái Quest
local autoClaimQuestEnabled = ConfigSystem.CurrentConfig.AutoClaimQuest or false
local autoClaimQuestLoop = nil

-- Mapping giữa tên hiển thị và tên thật của map
local mapNameMapping = {
    ["Voocha Village"] = "OnePiece",
    ["Green Planet"] = "Namek",
    ["Demon Forest"] = "DemonSlayer",
    ["Leaf Village"] = "Naruto",
    ["Z City"] = "OPM"
}

-- Mapping ngược lại để hiển thị tên cho người dùng
local reverseMapNameMapping = {}
for display, real in pairs(mapNameMapping) do
    reverseMapNameMapping[real] = display
end

-- Biến lưu trạng thái Story
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "OnePiece"
local selectedDisplayMap = reverseMapNameMapping[selectedMap] or "Voocha Village"
local selectedChapter = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoinMapEnabled = ConfigSystem.CurrentConfig.AutoJoinMap or false
local autoJoinMapLoop = nil

-- Biến lưu trạng thái Ranger Stage
local selectedRangerMap = ConfigSystem.CurrentConfig.SelectedRangerMap or "OnePiece"
local selectedRangerDisplayMap = reverseMapNameMapping[selectedRangerMap] or "Voocha Village"
-- Thêm biến lưu các map đã chọn
local selectedRangerMaps = ConfigSystem.CurrentConfig.SelectedRangerMaps or { [selectedRangerMap] = true } -- Lưu dạng table {MapName = true}
local selectedActs = ConfigSystem.CurrentConfig.SelectedActs or {RangerStage1 = true}
local currentActIndex = 1  -- Lưu trữ index của Act hiện tại đang được sử dụng
local orderedActs = {}     -- Lưu trữ danh sách các Acts theo thứ tự
local rangerFriendOnly = ConfigSystem.CurrentConfig.RangerFriendOnly or false
local autoJoinRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinRanger or false
local autoJoinRangerLoop = nil

-- Biến lưu trạng thái Boss Event
local autoBossEventEnabled = ConfigSystem.CurrentConfig.AutoBossEvent or false
local autoBossEventLoop = nil

-- Biến lưu trạng thái Challenge
local autoChallengeEnabled = ConfigSystem.CurrentConfig.AutoChallenge or false
local autoChallengeLoop = nil
local challengeTimeDelay = ConfigSystem.CurrentConfig.ChallengeTimeDelay or 5

-- Biến lưu trạng thái In-Game
local autoPlayEnabled = ConfigSystem.CurrentConfig.AutoPlay or false
local autoRetryEnabled = ConfigSystem.CurrentConfig.AutoRetry or false
local autoNextEnabled = ConfigSystem.CurrentConfig.AutoNext or false
local autoVoteEnabled = ConfigSystem.CurrentConfig.AutoVote or false
local removeAnimationEnabled = ConfigSystem.CurrentConfig.RemoveAnimation or true
local autoRetryLoop = nil
local autoNextLoop = nil
local autoVoteLoop = nil
local removeAnimationLoop = nil

-- Biến lưu trạng thái Update Units
local autoUpdateEnabled = ConfigSystem.CurrentConfig.AutoUpdate or false
local autoUpdateRandomEnabled = ConfigSystem.CurrentConfig.AutoUpdateRandom or false
local autoUpdateLoop = nil
local autoUpdateRandomLoop = nil
local unitSlotLevels = {
    ConfigSystem.CurrentConfig.Slot1Level or 0,
    ConfigSystem.CurrentConfig.Slot2Level or 0,
    ConfigSystem.CurrentConfig.Slot3Level or 0,
    ConfigSystem.CurrentConfig.Slot4Level or 0,
    ConfigSystem.CurrentConfig.Slot5Level or 0,
    ConfigSystem.CurrentConfig.Slot6Level or 0
}
local unitSlots = {}

-- Biến lưu trạng thái Time Delay
local storyTimeDelay = ConfigSystem.CurrentConfig.StoryTimeDelay or 5
local rangerTimeDelay = ConfigSystem.CurrentConfig.RangerTimeDelay or 5
local bossEventTimeDelay = ConfigSystem.CurrentConfig.BossEventTimeDelay or 5

-- Biến lưu trạng thái AFK
local autoJoinAFKEnabled = ConfigSystem.CurrentConfig.AutoJoinAFK or false
local autoJoinAFKLoop = nil

-- Biến lưu trạng thái Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUI or false
local autoHideUITimer = nil

-- Thông tin người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Tạo Window
local Window = Fluent:CreateWindow({
    Title = "HT Hub | Anime Rangers X",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = ConfigSystem.CurrentConfig.UITheme or "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo tab Info
local InfoTab = Window:AddTab({
    Title = "Info",
    Icon = "rbxassetid://7733964719"
})

-- Tạo tab Play
local PlayTab = Window:AddTab({
    Title = "Play",
    Icon = "rbxassetid://7743871480"
})

-- Tạo tab Event
local EventTab = Window:AddTab({
    Title = "Event",
    Icon = "rbxassetid://8997385940"
})

-- Tạo tab In-Game
local InGameTab = Window:AddTab({
    Title = "In-Game",
    Icon = "rbxassetid://7733799901"
})

-- Tạo tab Shop
local ShopTab = Window:AddTab({
    Title = "Shop",
    Icon = "rbxassetid://7734056747"
})

-- Tạo tab Settings
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "rbxassetid://6031280882"
})

-- Tạo tab Webhook
local WebhookTab = Window:AddTab({
    Title = "Webhook",
    Icon = "rbxassetid://7734058803"
})

-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://90319448802378" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl" -- Phím để bật/tắt giao diện

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
            ImageButton.Image = getgenv().Image
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,getgenv().ToggleUI,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

-- Tự động chọn tab Info khi khởi động
Window:SelectTab(1) -- Chọn tab đầu tiên (Info)

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:AddSection("Thông tin")

InfoSection:AddParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 0.2 Beta\nTrạng thái: Hoạt động"
})

InfoSection:AddParagraph({
    Title = "Người phát triển",
    Content = "Script được phát triển bởi Dương Tuấn và ghjiukliop"
})

-- Kiểm tra xem người chơi đã ở trong map chưa
local function isPlayerInMap()
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end
    
    -- Kiểm tra UnitsFolder một cách hiệu quả
    return player:FindFirstChild("UnitsFolder") ~= nil
end

-- Thêm section Story trong tab Play
local StorySection = PlayTab:AddSection("Story")

-- Hàm để thay đổi map
local function changeWorld(worldDisplay)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            -- Chuyển đổi từ tên hiển thị sang tên thật
            local worldReal = mapNameMapping[worldDisplay] or "OnePiece"
            
            local args = {
                [1] = "Change-World",
                [2] = {
                    ["World"] = worldReal
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi map: " .. worldDisplay .. " (thực tế: " .. worldReal .. ")")
        else
            warn("Không tìm thấy Event để đổi map")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi map: " .. tostring(err))
    end
end

-- Hàm để thay đổi chapter
local function changeChapter(map, chapter)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-Chapter",
                [2] = {
                    ["Chapter"] = map .. "_" .. chapter
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi chapter: " .. map .. "_" .. chapter)
        else
            warn("Không tìm thấy Event để đổi chapter")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi chapter: " .. tostring(err))
    end
end

-- Hàm để thay đổi difficulty
local function changeDifficulty(difficulty)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-Difficulty",
                [2] = {
                    ["Difficulty"] = difficulty
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi difficulty: " .. difficulty)
        else
            warn("Không tìm thấy Event để đổi difficulty")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi difficulty: " .. tostring(err))
    end
end

-- Hàm để toggle Friend Only
local function toggleFriendOnly()
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-FriendOnly"
            }
            
            Event:FireServer(unpack(args))
            print("Đã toggle Friend Only")
        else
            warn("Không tìm thấy Event để toggle Friend Only")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Friend Only: " .. tostring(err))
    end
end

-- Hàm để tự động tham gia map
local function joinMap()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join map")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để join map")
            return
        end
        
        -- 1. Create
        Event:FireServer("Create")
        wait(0.5)
        
        -- 2. Friend Only (nếu được bật)
        if friendOnly then
            Event:FireServer("Change-FriendOnly")
            wait(0.5)
        end
        
        -- 3. Chọn Map và Chapter
        -- 3.1 Đổi Map
        local args1 = {
            [1] = "Change-World",
            [2] = {
                ["World"] = selectedMap
            }
        }
        Event:FireServer(unpack(args1))
        wait(0.5)
        
        -- 3.2 Đổi Chapter
        local args2 = {
            [1] = "Change-Chapter",
            [2] = {
                ["Chapter"] = selectedMap .. "_" .. selectedChapter
            }
        }
        Event:FireServer(unpack(args2))
        wait(0.5)
        
        -- 3.3 Đổi Difficulty
        local args3 = {
            [1] = "Change-Difficulty",
            [2] = {
                ["Difficulty"] = selectedDifficulty
            }
        }
        Event:FireServer(unpack(args3))
        wait(0.5)
        
        -- 4. Submit
        Event:FireServer("Submit")
        wait(1)
        
        -- 5. Start
        Event:FireServer("Start")
        
        print("Đã join map: " .. selectedMap .. "_" .. selectedChapter .. " với độ khó " .. selectedDifficulty)
    end)
    
    if not success then
        warn("Lỗi khi join map: " .. tostring(err))
        return false
    end
    
    return true
end

-- Dropdown để chọn Map
StorySection:AddDropdown("MapDropdown", {
    Title = "Choose Map",
    Values = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    Multi = false,
    Default = selectedDisplayMap,
    Callback = function(Value)
        selectedDisplayMap = Value
        selectedMap = mapNameMapping[Value] or "OnePiece"
        ConfigSystem.CurrentConfig.SelectedMap = selectedMap
        ConfigSystem.SaveConfig()
        
        -- Thay đổi map khi người dùng chọn
        changeWorld(Value)
        print("Đã chọn map: " .. Value .. " (thực tế: " .. selectedMap .. ")")
    end
})

-- Dropdown để chọn Chapter
StorySection:AddDropdown("ChapterDropdown", {
    Title = "Choose Chapter",
    Values = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1",
    Callback = function(Value)
        selectedChapter = Value
        ConfigSystem.CurrentConfig.SelectedChapter = Value
        ConfigSystem.SaveConfig()
        
        -- Thay đổi chapter khi người dùng chọn
        changeChapter(selectedMap, Value)
        print("Đã chọn chapter: " .. Value)
    end
})

-- Dropdown để chọn Difficulty
StorySection:AddDropdown("DifficultyDropdown", {
    Title = "Choose Difficulty",
    Values = {"Normal", "Hard", "Nightmare"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal",
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()
        
        -- Thay đổi difficulty khi người dùng chọn
        changeDifficulty(Value)
        print("Đã chọn difficulty: " .. Value)
        
    end
})

-- Toggle Friend Only
StorySection:AddToggle("FriendOnlyToggle", {
    Title = "Friend Only",
    Default = ConfigSystem.CurrentConfig.FriendOnly or false,
    Callback = function(Value)
        friendOnly = Value
        ConfigSystem.CurrentConfig.FriendOnly = Value
        ConfigSystem.SaveConfig()
        
        -- Toggle Friend Only khi người dùng thay đổi
        toggleFriendOnly()
        
        if Value then
            print("Đã bật chế độ Friend Only")
        else
            print("Đã tắt chế độ Friend Only")
        end
    end
})

-- Toggle Auto Join Map
StorySection:AddToggle("AutoJoinMapToggle", {
    Title = "Auto Join Map",
    Default = ConfigSystem.CurrentConfig.AutoJoinMap or false,
    Callback = function(Value)
        autoJoinMapEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinMap = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinMapEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Join Map sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Join Map đã được bật, sẽ bắt đầu sau " .. storyTimeDelay .. " giây")
                
                -- Thực hiện join map sau thời gian delay
                spawn(function()
                    wait(storyTimeDelay) -- Chờ theo time delay đã đặt
                    if autoJoinMapEnabled and not isPlayerInMap() then
                        joinMap()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Map
            spawn(function()
                while autoJoinMapEnabled and wait(10) do -- Thử join map mỗi 10 giây
                    -- Chỉ thực hiện join map nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Áp dụng time delay
                        print("Đợi " .. storyTimeDelay .. " giây trước khi join map")
                        wait(storyTimeDelay)
                        
                        -- Kiểm tra lại sau khi delay
                        if autoJoinMapEnabled and not isPlayerInMap() then
                            joinMap()
                        end
                    else
                        -- Người chơi đang ở trong map, không cần join
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            print("Auto Join Map đã được tắt")
        end
    end
})


-- Hiển thị trạng thái trong game
StorySection:AddParagraph({
    Title = "Trạng thái",
    Content = "Nhấn nút bên dưới để cập nhật trạng thái"
})

-- Thêm nút cập nhật trạng thái
StorySection:AddButton({
    Title = "Cập nhật trạng thái",
    Callback = function()
        local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
        
        -- Hiển thị thông báo với trạng thái hiện tại
        Fluent:Notify({
            Title = "Trạng thái hiện tại",
            Content = statusText,
            Duration = 3
        })
        
        print("Trạng thái: " .. statusText)
    end
})

-- Thêm section Summon trong tab Shop
local SummonSection = ShopTab:AddSection("Summon")

-- Hàm thực hiện summon
local function performSummon()
    -- An toàn kiểm tra Remote có tồn tại không
    local success, err = pcall(function()
        local Remote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Gambling", "UnitsGacha"}, 2)
        
        if Remote then
            local args = {
                [1] = selectedSummonAmount,
                [2] = selectedSummonBanner,
                [3] = {}
            }
            
            Remote:FireServer(unpack(args))
            print("Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner)
        else
            warn("Không tìm thấy Remote UnitsGacha")
        end
    end)
    
    if not success then
        warn("Lỗi khi summon: " .. tostring(err))
    end
end

-- Dropdown để chọn số lượng summon
SummonSection:AddDropdown("SummonAmountDropdown", {
    Title = "Choose Summon Amount",
    Values = {"x1", "x10"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SummonAmount or "x1",
    Callback = function(Value)
        selectedSummonAmount = Value
        ConfigSystem.CurrentConfig.SummonAmount = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn summon amount: " .. Value)
    end
})

-- Dropdown để chọn banner
SummonSection:AddDropdown("SummonBannerDropdown", {
    Title = "Choose Banner",
    Values = {"Standard", "Rate-Up"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SummonBanner or "Standard",
    Callback = function(Value)
        selectedSummonBanner = Value
        ConfigSystem.CurrentConfig.SummonBanner = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn banner: " .. Value)
    end
})

-- Toggle Auto Summon
SummonSection:AddToggle("AutoSummonToggle", {
    Title = "Auto Summon",
    Default = ConfigSystem.CurrentConfig.AutoSummon or false,
    Callback = function(Value)
        autoSummonEnabled = Value
        ConfigSystem.CurrentConfig.AutoSummon = Value
        ConfigSystem.SaveConfig()
        
        if autoSummonEnabled then
            print("Auto Summon đã được bật")
            
            -- Tạo vòng lặp Auto Summon
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end
            
            -- Sử dụng spawn thay vì coroutine
            spawn(function()
                while autoSummonEnabled and wait(2) do -- Summon mỗi 2 giây
                    performSummon()
                end
            end)
            
        else
            print("Auto Summon đã được tắt")
            
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end
        end
    end
})

-- Thêm section Quest trong tab Shop
local QuestSection = ShopTab:AddSection("Quest")

-- Hàm để nhận tất cả nhiệm vụ
local function claimAllQuests()
    local success, err = pcall(function()
        -- Kiểm tra an toàn đường dẫn PlayerData
        local ReplicatedStorage = safeGetService("ReplicatedStorage")
        if not ReplicatedStorage then
            warn("Không tìm thấy ReplicatedStorage")
            return
        end
        
        local PlayerData = safeGetChild(ReplicatedStorage, "Player_Data", 2)
        if not PlayerData then
            warn("Không tìm thấy Player_Data")
            return
        end
        
        local PlayerFolder = safeGetChild(PlayerData, playerName, 2)
        if not PlayerFolder then
            warn("Không tìm thấy dữ liệu người chơi: " .. playerName)
            return
        end
        
        local DailyQuest = safeGetChild(PlayerFolder, "DailyQuest", 2)
        if not DailyQuest then
            warn("Không tìm thấy DailyQuest")
            return
        end
        
        -- Lấy đường dẫn đến QuestEvent
        local QuestEvent = safeGetPath(ReplicatedStorage, {"Remote", "Server", "Gameplay", "QuestEvent"}, 2)
        if not QuestEvent then
            warn("Không tìm thấy QuestEvent")
            return
        end
        
        -- Tìm tất cả nhiệm vụ có thể nhận
        for _, quest in pairs(DailyQuest:GetChildren()) do
            if quest then
                local args = {
                    [1] = "ClaimAll",
                    [2] = quest
                }
                
                QuestEvent:FireServer(unpack(args))
                wait(0.2) -- Chờ một chút giữa các lần claim để tránh lag
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi claim quest: " .. tostring(err))
    end
end

-- Toggle Auto Claim All Quest
QuestSection:AddToggle("AutoClaimQuestToggle", {
    Title = "Auto Claim All Quests",
    Default = ConfigSystem.CurrentConfig.AutoClaimQuest or false,
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()
        
        if autoClaimQuestEnabled then
            print("Auto Claim Quests đã được bật")
            
            -- Tạo vòng lặp Auto Claim Quests
            spawn(function()
                while autoClaimQuestEnabled and wait(1) do -- Claim mỗi 30 giây
                    claimAllQuests()
                end
            end)
        else
            print("Auto Claim Quests đã được tắt")
        end
    end
})

-- Thêm section thiết lập trong tab Settings
local SettingsSection = SettingsTab:AddSection("Thiết lập")

-- Dropdown chọn theme
SettingsSection:AddDropdown("ThemeDropdown", {
    Title = "Chọn Theme",
    Values = {"Dark", "Light", "Darker", "Aqua", "Amethyst"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.UITheme or "Dark",
    Callback = function(Value)
        ConfigSystem.CurrentConfig.UITheme = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn theme: " .. Value)
    end
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

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    for _, tab in pairs({InfoTab, PlayTab, ShopTab, SettingsTab}) do
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

-- Tích hợp với SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubAR")
SaveManager:SetFolder("HTHubAR/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Thiết lập events
setupSaveEvents()

-- Khởi tạo các vòng lặp tối ưu
local function setupOptimizedLoops()
    -- Vòng lặp kiểm tra Auto Scan Units - sử dụng lại cho nhiều tính năng
        spawn(function()
        while wait(3) do
            -- Scan units nếu đang trong map và tính năng Auto Scan được bật
            if autoScanUnitsEnabled and isPlayerInMap() then
                scanUnits()
    end
    
            -- Kiểm tra và lưu cấu hình nếu có thay đổi
            if ConfigSystem.PendingSave then
                ConfigSystem.SaveConfig()
            end
        end
    end)
    
    -- Vòng lặp quản lý tham gia map và events
        spawn(function()
        -- Đợi một chút để script khởi động hoàn tất
        wait(5)
        
        while wait(5) do
            -- Chỉ thực hiện nếu không ở trong map
            if not isPlayerInMap() then
                local shouldContinue = false
                
                -- Kiểm tra Auto Join Map
                if autoJoinMapEnabled and not shouldContinue then
                    joinMap()
                    wait(1) -- Đợi để xem đã vào map chưa
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Join Ranger
                if autoJoinRangerEnabled and not shouldContinue then
                    cycleRangerStages()
                    wait(1)
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Boss Event
                if autoBossEventEnabled and not shouldContinue then
                joinBossEvent()
                    wait(1)
                    shouldContinue = isPlayerInMap()
    end
    
                -- Kiểm tra Auto Challenge
                if autoChallengeEnabled and not shouldContinue then
                    joinChallenge()
                    wait(1)
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Easter Egg
                if autoJoinEasterEggEnabled and not shouldContinue then
                    joinEasterEggEvent()
                    wait(1)
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Join AFK nếu không áp dụng các tính năng trên
                if autoJoinAFKEnabled and not shouldContinue and not isPlayerInMap() then
                    joinAFKWorld()
            end
            else
                -- Đang ở trong map, kiểm tra tính năng Auto Update Units
                if autoUpdateEnabled then
                    for i = 1, 6 do
                        if unitSlots[i] and unitSlotLevels[i] > 0 then
                            upgradeUnit(unitSlots[i])
                            wait(0.1)
                        end
                    end
                elseif autoUpdateRandomEnabled and #unitSlots > 0 then
                    -- Chọn ngẫu nhiên một slot để nâng cấp
                    local randomIndex = math.random(1, #unitSlots)
                    if unitSlots[randomIndex] then
                        upgradeUnit(unitSlots[randomIndex])
                    end
                end
            end
        end
    end)
end

-- Thêm section Ranger Stage trong tab Play
local RangerSection = PlayTab:AddSection("Ranger Stage")

-- Hàm để thay đổi act
local function changeAct(map, act)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-Chapter",
                [2] = {
                    ["Chapter"] = map .. "_" .. act
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi act: " .. map .. "_" .. act)
        else
            warn("Không tìm thấy Event để đổi act")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi act: " .. tostring(err))
    end
end

-- Hàm để toggle Friend Only cho Ranger
local function toggleRangerFriendOnly()
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-FriendOnly"
            }
            
            Event:FireServer(unpack(args))
            print("Đã toggle Friend Only cho Ranger")
        else
            warn("Không tìm thấy Event để toggle Friend Only")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Friend Only: " .. tostring(err))
    end
end

-- Hàm để cập nhật danh sách Acts đã sắp xếp
local function updateOrderedActs()
    orderedActs = {}
    for act, isSelected in pairs(selectedActs) do
        if isSelected then
            table.insert(orderedActs, act)
        end
    end
    
    -- Đảm bảo currentActIndex không vượt quá số lượng acts
    if #orderedActs > 0 then
        currentActIndex = ((currentActIndex - 1) % #orderedActs) + 1
    else
        currentActIndex = 1
    end
end

-- Hàm để tự động tham gia Ranger Stage (Sửa đổi để nhận map và act)
local function joinRangerStage(mapToJoin, actToJoin)
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Ranger Stage")
        return false
    end

    -- Nếu không có map/act cụ thể được cung cấp, dùng giá trị từ UI
    if not mapToJoin or not actToJoin then
        updateOrderedActs()
        if #orderedActs == 0 then
            warn("Không có Act nào được chọn để join Ranger Stage (UI)")
            return false
        end
        mapToJoin = selectedRangerMap -- Lấy từ UI
        actToJoin = orderedActs[currentActIndex] -- Lấy từ UI
    end

    -- Kiểm tra lại nếu map/act vẫn nil
    if not mapToJoin or not actToJoin then
        warn("Map hoặc Act không hợp lệ để join Ranger Stage")
        return false
    end

    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        if not Event then warn("Không tìm thấy Event để join Ranger Stage"); return end

        -- 1. Create
        Event:FireServer("Create")
        wait(0.5)

        -- 2. Change Mode to Ranger Stage
        local modeArgs = { [1] = "Change-Mode", [2] = { ["Mode"] = "Ranger Stage" } }
        Event:FireServer(unpack(modeArgs))
        wait(0.5)

        -- 3. Friend Only (sử dụng cài đặt global)
        if rangerFriendOnly then
            Event:FireServer("Change-FriendOnly")
            wait(0.5)
        end

        -- 4. Chọn Map và Act (sử dụng tham số đầu vào)
        -- 4.1 Đổi Map
        local args1 = { [1] = "Change-World", [2] = { ["World"] = mapToJoin } }
        Event:FireServer(unpack(args1))
        wait(0.5)

        -- 4.2 Đổi Act
        local args2 = { [1] = "Change-Chapter", [2] = { ["Chapter"] = mapToJoin .. "_" .. actToJoin } }
        Event:FireServer(unpack(args2))
        wait(0.5)

        -- 5. Submit
        Event:FireServer("Submit")
        wait(0.5)

        -- 6. Start
        Event:FireServer("Start")

        print("Đã join Ranger Stage: " .. mapToJoin .. "_" .. actToJoin)

        -- Cập nhật index cho lần tiếp theo chỉ khi dùng giá trị từ UI
        if not mapToJoin or not actToJoin then
            currentActIndex = (currentActIndex % #orderedActs) + 1
        end
    end)

    if not success then
        warn("Lỗi khi join Ranger Stage: " .. tostring(err))
        return false
    end

    return true
end

-- Hàm để lặp qua các selected Acts (Sửa đổi để không cần thiết nữa nếu chỉ dùng cho Auto Join All)
-- local function cycleRangerStages() ... end -- Có thể xóa hoặc giữ lại nếu vẫn cần Auto Join Ranger theo UI

-- Time Delay slider cho Story
StorySection:AddSlider("StoryTimeDelaySlider", {
    Title = "Time Delay (giây)",
    Default = storyTimeDelay,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        storyTimeDelay = Value
        ConfigSystem.CurrentConfig.StoryTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Story Time Delay: " .. Value .. " giây")
        -- Cập nhật Input khi Slider thay đổi
        local input = StorySection:GetComponent("StoryTimeDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Story Time Delay
StorySection:AddInput("StoryTimeDelayInput", {
    Title = "", -- Để trống Title cho gọn
    Placeholder = "Nhập delay",
    Default = tostring(storyTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            storyTimeDelay = numValue
            ConfigSystem.CurrentConfig.StoryTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Story Time Delay (Input): " .. numValue .. " giây")
            -- Cập nhật Slider khi Input thay đổi
            local slider = StorySection:GetComponent("StoryTimeDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            -- Reset Input về giá trị cũ nếu không hợp lệ
            local input = StorySection:GetComponent("StoryTimeDelayInput")
            if input and input.Set then input:Set(tostring(storyTimeDelay)) end
        end
    end
})

-- Dropdown để chọn Map cho Ranger
RangerSection:AddDropdown("RangerMapDropdown", {
    Title = "Choose Map(s)", -- Sửa tiêu đề
    Values = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    Multi = true, -- Cho phép chọn nhiều
    Default = (function() -- Khôi phục trạng thái đã chọn từ config
        local defaults = {}
        for mapName, isSelected in pairs(selectedRangerMaps) do
            local displayMap = reverseMapNameMapping[mapName]
            if displayMap and isSelected then
                defaults[displayMap] = true
            end
        end
        -- Đảm bảo luôn có ít nhất 1 map được chọn ban đầu nếu config rỗng
         if next(defaults) == nil and reverseMapNameMapping[selectedRangerMap] then
             defaults[reverseMapNameMapping[selectedRangerMap]] = true
         end
        return defaults
    end)(),
    Callback = function(Values)
        selectedRangerMaps = {} -- Reset trước khi cập nhật
        local firstSelectedMap = nil
        local firstSelectedDisplayMap = nil
        for displayMap, isSelected in pairs(Values) do
            local realMap = mapNameMapping[displayMap]
            if realMap and isSelected then
                selectedRangerMaps[realMap] = true
                if not firstSelectedMap then
                    firstSelectedMap = realMap
                    firstSelectedDisplayMap = displayMap
                end
                print("Đã chọn Ranger map: " .. displayMap .. " (thực tế: " .. realMap .. ")")
            end
        end
        -- Cập nhật selectedRangerMap (dùng cho các chức năng khác nếu cần) thành map đầu tiên được chọn
        selectedRangerMap = firstSelectedMap or "OnePiece"
        selectedRangerDisplayMap = firstSelectedDisplayMap or "Voocha Village"

        ConfigSystem.CurrentConfig.SelectedRangerMaps = selectedRangerMaps
        ConfigSystem.CurrentConfig.SelectedRangerMap = selectedRangerMap -- Lưu map đầu tiên làm map chính (nếu cần)
        ConfigSystem.SaveConfig()

        -- Thông báo (có thể bỏ nếu không muốn)
        local selectedMapsText = ""
        for map, isSelected in pairs(selectedRangerMaps) do
             if isSelected then selectedMapsText = selectedMapsText .. (reverseMapNameMapping[map] or map) .. ", " end
        end
        if selectedMapsText ~= "" then
             selectedMapsText = selectedMapsText:sub(1, -3)
             print("Các map Ranger đã chọn: " .. selectedMapsText)
        else
             print("Chưa chọn map Ranger nào.")
        end
    end
})

-- Dropdown để chọn Act
RangerSection:AddDropdown("ActDropdown", {
    Title = "Choose Act",
    Values = {"RangerStage1", "RangerStage2", "RangerStage3"},
    Multi = true,
    Default = ConfigSystem.CurrentConfig.SelectedActs or {RangerStage1 = true},
    Callback = function(Values)
        selectedActs = Values
        ConfigSystem.CurrentConfig.SelectedActs = Values
        ConfigSystem.SaveConfig()
        
        -- Cập nhật danh sách Acts đã sắp xếp
        updateOrderedActs()
        
        -- Hiển thị thông báo khi người dùng chọn act
        local selectedActsText = ""
        for act, isSelected in pairs(Values) do
            if isSelected then
                selectedActsText = selectedActsText .. act .. ", "
        
        -- Thay đổi act khi người dùng chọn
                changeAct(selectedRangerMap, act)
                print("Đã chọn act: " .. act)
                wait(0.5) -- Đợi 0.5 giây giữa các lần gửi để tránh lỗi
            end
        end
        
        if selectedActsText ~= "" then
            selectedActsText = selectedActsText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            print("Đã chọn act: " .. selectedActsText)
        else
            print("Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.")
        end
    end
})

-- Toggle Friend Only cho Ranger
RangerSection:AddToggle("RangerFriendOnlyToggle", {
    Title = "Friend Only",
    Default = ConfigSystem.CurrentConfig.RangerFriendOnly or false,
    Callback = function(Value)
        rangerFriendOnly = Value
        ConfigSystem.CurrentConfig.RangerFriendOnly = Value
        ConfigSystem.SaveConfig()
        
        -- Toggle Friend Only khi người dùng thay đổi
        toggleRangerFriendOnly()
        
        if Value then
            print("Đã bật chế độ Friend Only cho Ranger Stage")
        else
            print("Đã tắt chế độ Friend Only cho Ranger Stage")
        end
    end
})

-- Time Delay slider cho Ranger
RangerSection:AddSlider("RangerTimeDelaySlider", {
    Title = "Time Delay (giây)",
    Default = rangerTimeDelay,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        rangerTimeDelay = Value
        ConfigSystem.CurrentConfig.RangerTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Ranger Time Delay: " .. Value .. " giây")
        -- Cập nhật Input khi Slider thay đổi
        local input = RangerSection:GetComponent("RangerTimeDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Ranger Time Delay
RangerSection:AddInput("RangerTimeDelayInput", {
    Title = "",
    Placeholder = "Nhập delay",
    Default = tostring(rangerTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            rangerTimeDelay = numValue
            ConfigSystem.CurrentConfig.RangerTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Ranger Time Delay (Input): " .. numValue .. " giây")
            -- Cập nhật Slider khi Input thay đổi
            local slider = RangerSection:GetComponent("RangerTimeDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            local input = RangerSection:GetComponent("RangerTimeDelayInput")
            if input and input.Set then input:Set(tostring(rangerTimeDelay)) end
        end
    end
})

-- Toggle Auto Join Ranger Stage
RangerSection:AddToggle("AutoJoinRangerToggle", {
    Title = "Auto Join Selected Stage", -- Đổi tên cho rõ nghĩa
    Default = ConfigSystem.CurrentConfig.AutoJoinRanger or false,
    Callback = function(Value)
        autoJoinRangerEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinRanger = Value
        ConfigSystem.SaveConfig()

        if autoJoinRangerEnabled then
            -- Kiểm tra xem có Map nào được chọn không
            local hasSelectedMap = false
            for _, isSelected in pairs(selectedRangerMaps) do if isSelected then hasSelectedMap = true; break; end end
            if not hasSelectedMap then print("Chưa chọn map nào trong Ranger Stage!"); return end

            -- Kiểm tra xem có Act nào được chọn không
            local hasSelectedAct = false
            for _, isSelected in pairs(selectedActs) do if isSelected then hasSelectedAct = true; break; end end
            if not hasSelectedAct then print("Chưa chọn act nào trong Ranger Stage!"); return end

            print("Auto Join Selected Ranger Stage đã được bật")
            if autoJoinRangerLoop then autoJoinRangerLoop:Disconnect(); autoJoinRangerLoop = nil; end

            autoJoinRangerLoop = spawn(function()
                while autoJoinRangerEnabled do
                    local didJoin = false
                    -- Lặp qua các map đã chọn
                    for map, mapSelected in pairs(selectedRangerMaps) do
                        if mapSelected then
                            -- Lặp qua các act đã chọn
                            for act, actSelected in pairs(selectedActs) do
                                if actSelected then
                                    if not autoJoinRangerEnabled then return end -- Thoát nếu bị tắt giữa chừng
                                    if not isPlayerInMap() then
                                        print("Chuẩn bị join: " .. map .. " - " .. act)
                                        joinRangerStage(map, act) -- Gọi join với map và act cụ thể
                                        didJoin = true
                                        -- Đợi vào map hoặc timeout
                                        local t = 0
                                        while not isPlayerInMap() and t < 10 and autoJoinRangerEnabled do wait(0.5); t = t + 0.5; end
                                        -- Nếu đã vào map, đợi delay
                                        if isPlayerInMap() and autoJoinRangerEnabled then
                                             print("Đã vào map, đợi " .. rangerTimeDelay .. " giây...")
                                             wait(rangerTimeDelay)
                                        end
                                    else
                                        -- Nếu đang trong map, đợi ra khỏi map
                                        print("Đang ở trong map, đợi thoát...")
                                        while isPlayerInMap() and autoJoinRangerEnabled do wait(1) end
                                    end
                                    -- Thêm delay nhỏ nếu join lỗi/không vào map và vẫn đang bật
                                    if not isPlayerInMap() and autoJoinRangerEnabled then wait(1) end
                                end
                            end
                        end
                    end
                    -- Nếu không join được map nào trong vòng lặp (ví dụ: đang ở trong map suốt), thì đợi 1 chút
                    if not didJoin and autoJoinRangerEnabled then
                         print("Không thể join map nào, kiểm tra lại sau 5 giây...")
                         wait(5)
                    end
                    -- Lặp lại nếu vẫn đang bật
                    if autoJoinRangerEnabled then print("Hoàn thành vòng lặp Auto Join Selected, bắt đầu lại..."); wait(1); end
                end
            end)
        else
            print("Auto Join Selected Ranger Stage đã được tắt")
            if autoJoinRangerLoop then autoJoinRangerLoop:Disconnect(); autoJoinRangerLoop = nil; end
        end
    end
})

-- Biến lưu trạng thái Auto Leave
local autoLeaveEnabled = ConfigSystem.CurrentConfig.AutoLeave or false
local autoLeaveLoop = nil

-- Hàm teleport về lobby (dùng cho Auto Leave)
local function leaveMap()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        
        -- Hiển thị thông báo trước khi teleport
        print("Không tìm thấy kẻ địch và agent trong 10 giây, đang teleport về lobby...")
        
        -- Thực hiện teleport tất cả người chơi
        for _, player in pairs(Players:GetPlayers()) do
            TeleportService:Teleport(game.PlaceId, player)
        end
    end)
    
    if not success then
        warn("Lỗi khi teleport về lobby: " .. tostring(err))
    end
end

-- Hàm kiểm tra EnemyT folder và Agent folder
local function checkEnemyFolder()
    -- Kiểm tra thật nhanh trước với pcall để tránh lỗi
    if not workspace:FindFirstChild("Agent") then
        return true
    end
    
    local enemyFolder = workspace.Agent:FindFirstChild("EnemyT")
    local agentFolder = workspace.Agent:FindFirstChild("Agent")
    
    -- Nếu không tìm thấy cả hai folder, coi như trống
    if not enemyFolder and not agentFolder then
        return true
    end
    
    -- Kiểm tra folder EnemyT có trống không
    local isEnemyTEmpty = not enemyFolder or #enemyFolder:GetChildren() == 0
    
    -- Kiểm tra folder Agent có trống không
    local isAgentEmpty = not agentFolder or #agentFolder:GetChildren() == 0
    
    -- Chỉ trả về true nếu cả hai folder đều trống
    return isEnemyTEmpty and isAgentEmpty
end

-- Toggle Auto Leave với tối ưu hiệu suất
RangerSection:AddToggle("AutoLeaveToggle", {
    Title = "Auto Leave",
    Default = ConfigSystem.CurrentConfig.AutoLeave or false,
    Callback = function(Value)
        autoLeaveEnabled = Value
        ConfigSystem.CurrentConfig.AutoLeave = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Leave đã được bật. Sẽ tự động rời map nếu không có kẻ địch và agent trong 10 giây")
            
            -- Hủy vòng lặp cũ nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end
            
            -- Tạo vòng lặp tối ưu để kiểm tra folders
            autoLeaveLoop = spawn(function()
                local checkInterval = 1 -- Kiểm tra mỗi 1 giây
                local maxEmptyTime = 10 -- Thời gian tối đa folder trống trước khi leave
                local emptyTime = 0
                
                while autoLeaveEnabled do
                    -- Chỉ kiểm tra nếu đang ở trong map
                    if isPlayerInMap() then
                        local areEmpty = checkEnemyFolder()
                        
                        if areEmpty then
                            emptyTime = emptyTime + checkInterval
                            if emptyTime >= maxEmptyTime then
                                leaveMap()
                                break -- Thoát vòng lặp sau khi leave
                            end
                            print("EnemyT và Agent folder trống: " .. emptyTime .. "/" .. maxEmptyTime .. " giây")
                        else
                            -- Reset counter nếu folders không trống
                            if emptyTime > 0 then
                                emptyTime = 0
                                print("Folders không còn trống, reset bộ đếm")
                            end
                        end
                    else
                        -- Reset counter khi không ở trong map
                        emptyTime = 0
                    end
                    
                    wait(checkInterval)
                    
                    -- Thoát vòng lặp nếu Auto Leave bị tắt
                    if not autoLeaveEnabled then
                        break
                    end
                end
            end)
        else
            print("Auto Leave đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end
        end
    end
})

-- Thêm section Boss Event trong tab Play
local BossEventSection = PlayTab:AddSection("Boss Event")

-- Hàm để tham gia Boss Event
local function joinBossEvent()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Boss Event")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để tham gia Boss Event")
            return
        end
        
        -- Gọi Boss Event
        local args = {
            [1] = "Boss-Event"
        }
        
        Event:FireServer(unpack(args))
        print("Đã gửi yêu cầu tham gia Boss Event")
    end)
    
    if not success then
        warn("Lỗi khi tham gia Boss Event: " .. tostring(err))
        return false
    end
    
    return true
end

-- Time Delay slider cho Boss Event
BossEventSection:AddSlider("BossEventTimeDelaySlider", {
    Title = "Time Delay (giây)",
    Default = bossEventTimeDelay,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        bossEventTimeDelay = Value
        ConfigSystem.CurrentConfig.BossEventTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Boss Event Time Delay: " .. Value .. " giây")
        -- Cập nhật Input khi Slider thay đổi
        local input = BossEventSection:GetComponent("BossEventTimeDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Boss Event Time Delay
BossEventSection:AddInput("BossEventTimeDelayInput", {
    Title = "",
    Placeholder = "Nhập delay",
    Default = tostring(bossEventTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            bossEventTimeDelay = numValue
            ConfigSystem.CurrentConfig.BossEventTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Boss Event Time Delay (Input): " .. numValue .. " giây")
            -- Cập nhật Slider khi Input thay đổi
            local slider = BossEventSection:GetComponent("BossEventTimeDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            local input = BossEventSection:GetComponent("BossEventTimeDelayInput")
            if input and input.Set then input:Set(tostring(bossEventTimeDelay)) end
        end
    end
})

-- Toggle Auto Join Boss Event
BossEventSection:AddToggle("AutoJoinBossEventToggle", {
    Title = "Auto Boss Event",
    Default = ConfigSystem.CurrentConfig.AutoBossEvent or false,
    Callback = function(Value)
        autoBossEventEnabled = Value
        ConfigSystem.CurrentConfig.AutoBossEvent = Value
        ConfigSystem.SaveConfig()
        
        if autoBossEventEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Boss Event sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Boss Event đã được bật, sẽ bắt đầu sau " .. bossEventTimeDelay .. " giây")
                
                -- Thực hiện tham gia Boss Event sau thời gian delay
                spawn(function()
                    wait(bossEventTimeDelay)
                    if autoBossEventEnabled and not isPlayerInMap() then
                        joinBossEvent()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Boss Event
            spawn(function()
                while autoBossEventEnabled and wait(30) do -- Thử join boss event mỗi 30 giây
                    -- Chỉ thực hiện tham gia nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Áp dụng time delay
                        print("Đợi " .. bossEventTimeDelay .. " giây trước khi tham gia Boss Event")
                        wait(bossEventTimeDelay)
                        
                        -- Kiểm tra lại sau khi delay
                        if autoBossEventEnabled and not isPlayerInMap() then
                            joinBossEvent()
                        end
                    else
                        -- Người chơi đang ở trong map, không cần tham gia
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            print("Auto Boss Event đã được tắt")
        end
    end
})

-- Thêm section Challenge trong tab Play
local ChallengeSection = PlayTab:AddSection("Challenge")

-- Hàm để tham gia Challenge
local function joinChallenge()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Challenge")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để join Challenge")
            return
        end
        
        -- 1. Create Challenge Room
        local args1 = {
            [1] = "Create",
            [2] = {
                ["CreateChallengeRoom"] = true
            }
        }
        Event:FireServer(unpack(args1))
        print("Đã tạo Challenge Room")
        wait(1) -- Đợi 1 giây
        
        -- 2. Start Challenge
        local args2 = {
            [1] = "Start"
        }
        Event:FireServer(unpack(args2))
        print("Đã bắt đầu Challenge")
    end)
    
    if not success then
        warn("Lỗi khi join Challenge: " .. tostring(err))
        return false
    end
    
    return true
end

-- Time Delay slider cho Challenge
ChallengeSection:AddSlider("ChallengeTimeDelaySlider", {
    Title = "Time Delay (giây)",
    Default = challengeTimeDelay,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        challengeTimeDelay = Value
        ConfigSystem.CurrentConfig.ChallengeTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Challenge Time Delay: " .. Value .. " giây")
        -- Cập nhật Input khi Slider thay đổi
        local input = ChallengeSection:GetComponent("ChallengeTimeDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Challenge Time Delay
ChallengeSection:AddInput("ChallengeTimeDelayInput", {
    Title = "",
    Placeholder = "Nhập delay",
    Default = tostring(challengeTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            challengeTimeDelay = numValue
            ConfigSystem.CurrentConfig.ChallengeTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Challenge Time Delay (Input): " .. numValue .. " giây")
            -- Cập nhật Slider khi Input thay đổi
            local slider = ChallengeSection:GetComponent("ChallengeTimeDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            local input = ChallengeSection:GetComponent("ChallengeTimeDelayInput")
            if input and input.Set then input:Set(tostring(challengeTimeDelay)) end
        end
    end
})

-- Toggle Auto Challenge
ChallengeSection:AddToggle("AutoChallengeToggle", {
    Title = "Auto Challenge",
    Default = ConfigSystem.CurrentConfig.AutoChallenge or false,
    Callback = function(Value)
        autoChallengeEnabled = Value
        ConfigSystem.CurrentConfig.AutoChallenge = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Challenge sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Challenge đã được bật, sẽ bắt đầu sau " .. challengeTimeDelay .. " giây")
                
                -- Thực hiện join Challenge sau thời gian delay
                spawn(function()
                    wait(challengeTimeDelay)
                    if autoChallengeEnabled and not isPlayerInMap() then
                        joinChallenge()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Challenge
            spawn(function()
                while autoChallengeEnabled and wait(10) do -- Thử join challenge mỗi 10 giây
                    -- Chỉ thực hiện join challenge nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Áp dụng time delay
                        print("Đợi " .. challengeTimeDelay .. " giây trước khi join Challenge")
                        wait(challengeTimeDelay)
                        
                        -- Kiểm tra lại sau khi delay
                        if autoChallengeEnabled and not isPlayerInMap() then
                            joinChallenge()
                        end
                    else
                        -- Người chơi đang ở trong map, không cần join
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            print("Auto Challenge đã được tắt")
        end
    end
})

-- Nút Join Challenge (manual)
ChallengeSection:AddButton({
    Title = "Join Challenge Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đã ở trong map
        if isPlayerInMap() then
            print("Bạn đang ở trong map, không thể tham gia Challenge mới")
            return
        end
        
        local success = joinChallenge()
        
        if success then
            print("Đang tham gia Challenge")
        else
            print("Không thể tham gia Challenge. Vui lòng thử lại sau.")
        end
    end
})

-- Thêm section In-Game Controls
local InGameSection = InGameTab:AddSection("Game Controls")

-- Thêm biến lưu trạng thái Auto TP Lobby
local autoTPLobbyEnabled = ConfigSystem.CurrentConfig.AutoTPLobby or false
local autoTPLobbyDelay = ConfigSystem.CurrentConfig.AutoTPLobbyDelay or 10 -- Mặc định 10 phút
local autoTPLobbyLoop = nil

-- Hàm để teleport về lobby
local function teleportToLobby()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        
        -- Hiển thị thông báo trước khi teleport
        print("Đang teleport về lobby...")
        
        -- Thực hiện teleport
        for _, player in pairs(Players:GetPlayers()) do
            if player == game:GetService("Players").LocalPlayer then
                TeleportService:Teleport(game.PlaceId, player)
                break -- Chỉ teleport người chơi hiện tại
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi teleport về lobby: " .. tostring(err))
    end
end

-- Slider điều chỉnh thời gian delay cho Auto TP Lobby
InGameSection:AddSlider("AutoTPLobbyDelaySlider", {
    Title = "Auto TP Lobby Delay (phút)",
    Default = autoTPLobbyDelay,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Callback = function(Value)
        autoTPLobbyDelay = Value
        ConfigSystem.CurrentConfig.AutoTPLobbyDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Auto TP Lobby Delay: " .. Value .. " phút")
        -- Cập nhật Input khi Slider thay đổi
        local input = InGameSection:GetComponent("AutoTPLobbyDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Auto TP Lobby Delay
InGameSection:AddInput("AutoTPLobbyDelayInput", {
    Title = "",
    Placeholder = "Nhập phút",
    Default = tostring(autoTPLobbyDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 60 then
            autoTPLobbyDelay = numValue
            ConfigSystem.CurrentConfig.AutoTPLobbyDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Auto TP Lobby Delay (Input): " .. numValue .. " phút")
            -- Cập nhật Slider khi Input thay đổi
            local slider = InGameSection:GetComponent("AutoTPLobbyDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-60 phút)")
            local input = InGameSection:GetComponent("AutoTPLobbyDelayInput")
            if input and input.Set then input:Set(tostring(autoTPLobbyDelay)) end
        end
    end
})

-- Toggle Auto TP Lobby
InGameSection:AddToggle("AutoTPLobbyToggle", {
    Title = "Auto TP Lobby",
    Default = autoTPLobbyEnabled,
    Callback = function(Value)
        autoTPLobbyEnabled = Value
        ConfigSystem.CurrentConfig.AutoTPLobby = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto TP Lobby đã được bật, sẽ teleport sau " .. autoTPLobbyDelay .. " phút")
            
            -- Hủy vòng lặp cũ nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                local timeRemaining = autoTPLobbyDelay * 60 -- Chuyển đổi thành giây
                
                while autoTPLobbyEnabled and wait(1) do -- Đếm ngược mỗi giây
                    timeRemaining = timeRemaining - 1
                    
                    -- Hiển thị thông báo khi còn 1 phút
                    if timeRemaining == 60 then
                        print("Sẽ teleport về lobby trong 1 phút nữa")
                    end
                    
                    -- Khi hết thời gian, thực hiện teleport
                    if timeRemaining <= 0 then
                        if autoTPLobbyEnabled then
                            teleportToLobby()
                        end
                        
                        -- Reset thời gian đếm ngược
                        timeRemaining = autoTPLobbyDelay * 60
                    end
                end
            end)
        else
            print("Auto TP Lobby đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end
        end
    end
})

-- Nút TP Lobby ngay lập tức
InGameSection:AddButton({
    Title = "TP Lobby Now",
    Callback = function()
        teleportToLobby()
    end
})

-- Hàm để kiểm tra trạng thái AutoPlay thực tế trong game
local function checkActualAutoPlayState()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end
        
        local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")
        if not playerData then return false end
        
        local playerFolder = playerData:FindFirstChild(player.Name)
        if not playerFolder then return false end
        
        local dataFolder = playerFolder:FindFirstChild("Data")
        if not dataFolder then return false end
        
        local autoPlayValue = dataFolder:FindFirstChild("AutoPlay")
        if not autoPlayValue then return false end
        
        return autoPlayValue.Value
    end)
    
    if not success then
        warn("Lỗi khi kiểm tra trạng thái AutoPlay: " .. tostring(result))
        return false
    end
    
    return result
end

-- Hàm để bật/tắt Auto Play
local function toggleAutoPlay()
    local success, err = pcall(function()
        local AutoPlayRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Units", "AutoPlay"}, 2)
        
        if AutoPlayRemote then
            AutoPlayRemote:FireServer()
            print("Đã toggle Auto Play")
        else
            warn("Không tìm thấy Remote AutoPlay")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Play: " .. tostring(err))
    end
end

-- Toggle Auto Play
InGameSection:AddToggle("AutoPlayToggle", {
    Title = "Auto Play",
    Default = ConfigSystem.CurrentConfig.AutoPlay or false,
    Callback = function(Value)
        -- Cập nhật cấu hình
        autoPlayEnabled = Value
        ConfigSystem.CurrentConfig.AutoPlay = Value
        ConfigSystem.SaveConfig()
        
        -- Kiểm tra trạng thái thực tế của AutoPlay
        local actualState = checkActualAutoPlayState()
        
        -- Chỉ toggle khi trạng thái mong muốn khác với trạng thái hiện tại
        if Value ~= actualState then
            toggleAutoPlay()
            
            if Value then
                print("Auto Play đã được bật")
            else
                print("Auto Play đã được tắt")
            end
        else
            print("Trạng thái Auto Play đã phù hợp (" .. (Value and "bật" or "tắt") .. ")")
        end
    end
})

-- Hàm để bật/tắt Auto Retry
local function toggleAutoRetry()
    local success, err = pcall(function()
        local AutoRetryRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "OnGame", "Voting", "VoteRetry"}, 2)
        
        if AutoRetryRemote then
            AutoRetryRemote:FireServer()
            print("Đã toggle Auto Retry")
        else
            warn("Không tìm thấy Remote VoteRetry")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Retry: " .. tostring(err))
    end
end

-- Hàm để bật/tắt Auto Next
local function toggleAutoNext()
    local success, err = pcall(function()
        local AutoNextRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "OnGame", "Voting", "VoteNext"}, 2)
        
        if AutoNextRemote then
            AutoNextRemote:FireServer()
            print("Đã toggle Auto Next")
        else
            warn("Không tìm thấy Remote VoteNext")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Next: " .. tostring(err))
    end
end

-- Hàm để bật/tắt Auto Vote
local function toggleAutoVote()
    local success, err = pcall(function()
        local AutoVoteRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "OnGame", "Voting", "VotePlaying"}, 2)
        
        if AutoVoteRemote then
            AutoVoteRemote:FireServer()
            print("Đã toggle Auto Vote")
        else
            warn("Không tìm thấy Remote VotePlaying")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Vote: " .. tostring(err))
    end
end

-- Toggle Auto Retry
InGameSection:AddToggle("AutoRetryToggle", {
    Title = "Auto Retry",
    Default = ConfigSystem.CurrentConfig.AutoRetry or false,
    Callback = function(Value)
        autoRetryEnabled = Value
        ConfigSystem.CurrentConfig.AutoRetry = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Retry đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoRetryLoop then
                autoRetryLoop:Disconnect()
                autoRetryLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoRetryEnabled and wait(3) do -- Gửi yêu cầu mỗi 3 giây
                    toggleAutoRetry()
                end
            end)
        else
            print("Auto Retry đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoRetryLoop then
                autoRetryLoop:Disconnect()
                autoRetryLoop = nil
            end
        end
    end
})

-- Toggle Auto Next
InGameSection:AddToggle("AutoNextToggle", {
    Title = "Auto Next",
    Default = ConfigSystem.CurrentConfig.AutoNext or false,
    Callback = function(Value)
        autoNextEnabled = Value
        ConfigSystem.CurrentConfig.AutoNext = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Next đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoNextLoop then
                autoNextLoop:Disconnect()
                autoNextLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoNextEnabled and wait(3) do -- Gửi yêu cầu mỗi 3 giây
                    toggleAutoNext()
                end
            end)
        else
            print("Auto Next đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoNextLoop then
                autoNextLoop:Disconnect()
                autoNextLoop = nil
            end
        end
    end
})

-- Toggle Auto Vote
InGameSection:AddToggle("AutoVoteToggle", {
    Title = "Auto Vote",
    Default = ConfigSystem.CurrentConfig.AutoVote or false,
    Callback = function(Value)
        autoVoteEnabled = Value
        ConfigSystem.CurrentConfig.AutoVote = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Vote đã được bật, sẽ bắt đầu ngay lập tức")
            -- Hủy vòng lặp cũ nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
            -- Gửi vote ngay lập tức
            toggleAutoVote()
            -- Tạo vòng lặp mới
            spawn(function()
                while autoVoteEnabled and wait(0.5) do -- Gửi yêu cầu mỗi 0.5 giây
                    toggleAutoVote()
                end
            end)
        else
            print("Auto Vote đã được tắt")
            -- Hủy vòng lặp nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
        end
    end
})

-- Hàm để scan unit trong UnitsFolder
local function scanUnits()
        -- Lấy UnitsFolder
        local player = game:GetService("Players").LocalPlayer
        if not player then
        return false
        end
        
        local unitsFolder = player:FindFirstChild("UnitsFolder")
        if not unitsFolder then
        return false
        end
        
        -- Lấy danh sách unit theo thứ tự
        unitSlots = {}
    local children = unitsFolder:GetChildren()
    for i, unit in ipairs(children) do
        if (unit:IsA("Folder") or unit:IsA("Model")) and i <= 6 then -- Giới hạn 6 slot
                unitSlots[i] = unit
            -- Không in log để giảm spam
            end
        end
        
        return #unitSlots > 0
    end
    
-- Hàm để nâng cấp unit tối ưu
local function upgradeUnit(unit)
    if not unit then
        return false
    end
    
    local upgradeRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Units", "Upgrade"}, 0.5)
    if not upgradeRemote then
        return false
    end
    
    upgradeRemote:FireServer(unit)
    return true
end

-- Thêm section Units Update trong tab In-Game
local UnitsUpdateSection = InGameTab:AddSection("Units Update")

-- Tạo 6 dropdown cho 6 slot
for i = 1, 6 do
    UnitsUpdateSection:AddDropdown("Slot" .. i .. "LevelDropdown", {
        Title = "Slot " .. i .. " Level",
        Values = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
        Multi = false,
        Default = tostring(unitSlotLevels[i]),
        Callback = function(Value)
            -- Chuyển đổi giá trị thành số
            local numberValue = tonumber(Value)
            if not numberValue then
                numberValue = 0
            end
            
            unitSlotLevels[i] = numberValue
            ConfigSystem.CurrentConfig["Slot" .. i .. "Level"] = numberValue
            ConfigSystem.SaveConfig()
            
            print("Đã đặt cấp độ slot " .. i .. " thành: " .. numberValue)
        end
    })
end

-- Toggle Auto Update
UnitsUpdateSection:AddToggle("AutoUpdateToggle", {
    Title = "Auto Update",
    Default = ConfigSystem.CurrentConfig.AutoUpdate or false,
    Callback = function(Value)
        autoUpdateEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdate = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()
            
            print("Auto Update đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoUpdateLoop then
                autoUpdateLoop:Disconnect()
                autoUpdateLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateEnabled and wait(0.1) do -- Cập nhật mỗi 0.1 giây
                    -- Kiểm tra xem có trong map không
                    if isPlayerInMap() then
                        -- Lặp qua từng slot và nâng cấp theo cấp độ đã chọn
                        for i = 1, 6 do
                            if unitSlots[i] and unitSlotLevels[i] > 0 then
                                for j = 1, unitSlotLevels[i] do
                                    upgradeUnit(unitSlots[i])
                                    wait(0.1) -- Chờ một chút giữa các lần nâng cấp
                                end
                            end
                        end
                    else
                        -- Người chơi không ở trong map, thử scan lại
                        scanUnits()
                    end
                end
            end)
        else
            print("Auto Update đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoUpdateLoop then
                autoUpdateLoop:Disconnect()
                autoUpdateLoop = nil
            end
        end
    end
})

-- Toggle Auto Update Random
UnitsUpdateSection:AddToggle("AutoUpdateRandomToggle", {
    Title = "Auto Update Random",
    Default = ConfigSystem.CurrentConfig.AutoUpdateRandom or false,
    Callback = function(Value)
        autoUpdateRandomEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdateRandom = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()
            
            print("Auto Update Random đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateRandomEnabled and wait(0.1) do -- Cập nhật mỗi 0.1 giây
                    -- Kiểm tra xem có trong map không
                    if isPlayerInMap() and #unitSlots > 0 then
                        -- Chọn ngẫu nhiên một slot để nâng cấp
                        local randomIndex = math.random(1, #unitSlots)
                        if unitSlots[randomIndex] then
                            upgradeUnit(unitSlots[randomIndex])
                        end
                    else
                        -- Người chơi không ở trong map, thử scan lại
                        scanUnits()
                    end
                end
            end)
        else
            print("Auto Update Random đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end
        end
    end
})

-- Hàm để kiểm tra trạng thái AFKWorld
local function checkAFKWorldState()
    local success, result = pcall(function()
        local afkWorldValue = game:GetService("ReplicatedStorage"):WaitForChild("Values", 1):WaitForChild("AFKWorld", 1)
        if afkWorldValue then
            return afkWorldValue.Value
        end
        return false
    end)
    
    if not success then
        warn("Lỗi khi kiểm tra trạng thái AFKWorld: " .. tostring(result))
        return false
    end
    
    return result
end

-- Tối ưu hóa hàm tham gia AFK World
local function joinAFKWorld()
        -- Kiểm tra nếu người chơi đã ở AFKWorld
        if checkAFKWorldState() then
        return true
        end
        
    -- Lấy remote và gửi yêu cầu
    local afkTeleportRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Lobby", "AFKWorldTeleport"}, 0.5)
    if not afkTeleportRemote then
            warn("Không tìm thấy Remote AFKWorldTeleport")
        return false
        end
    
    afkTeleportRemote:FireServer()
    return true
end

-- Thêm section AFK vào tab Settings
local AFKSection = SettingsTab:AddSection("AFK Settings")

-- Biến lưu trạng thái Anti AFK
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFK or true -- Mặc định bật
local antiAFKConnection = nil -- Kết nối sự kiện

-- Tối ưu hệ thống Anti AFK
local function setupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Ngắt kết nối cũ nếu có
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    -- Tạo kết nối mới nếu được bật
    if antiAFKEnabled and LocalPlayer then
        antiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5) -- Giảm thời gian chờ xuống 0.5 giây
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end

-- Toggle Anti AFK
AFKSection:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = antiAFKEnabled,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Fluent:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được bật",
                Duration = 2
            })
            setupAntiAFK()
        else
            Fluent:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được tắt",
                Duration = 2
            })
            -- Ngắt kết nối nếu có
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})

-- Toggle Auto Join AFK
AFKSection:AddToggle("AutoJoinAFKToggle", {
    Title = "Auto Join AFK",
    Default = ConfigSystem.CurrentConfig.AutoJoinAFK or false,
    Callback = function(Value)
        autoJoinAFKEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAFK = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra trạng thái AFKWorld
            local isInAFKWorld = checkAFKWorldState()

            print("Auto Join AFK đã được bật")
            
            -- Nếu không ở trong AFKWorld, teleport ngay lập tức
            if not isInAFKWorld then
                joinAFKWorld()
            else
                print("Bạn đã ở trong AFKWorld")
            end
            
            -- Hủy vòng lặp cũ nếu có
            if autoJoinAFKLoop then
                autoJoinAFKLoop:Disconnect()
                autoJoinAFKLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoJoinAFKEnabled and wait(60) do -- Kiểm tra mỗi 60 giây
                    -- Chỉ teleport nếu không ở trong AFKWorld
                    if not checkAFKWorldState() then
                        joinAFKWorld()
                    end
                end
            end)
        else
            print("Auto Join AFK đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoJoinAFKLoop then
                autoJoinAFKLoop:Disconnect()
                autoJoinAFKLoop = nil
            end
        end
    end
})

-- Nút Join AFK Now
AFKSection:AddButton({
    Title = "Join AFK Now",
    Callback = function()
        local isInAFKWorld = checkAFKWorldState()
        
        if isInAFKWorld then
            print("Bạn đã ở trong AFKWorld")
            return
        end
        
        joinAFKWorld()
        
        print("Đang teleport đến AFKWorld...")
    end
})

-- Tự động đồng bộ trạng thái từ game khi khởi động
spawn(function()
    wait(3) -- Đợi game load
    
    -- Khởi tạo danh sách Acts khi script khởi động
    updateOrderedActs()
    
    -- Kiểm tra nếu người chơi đã ở trong AFKWorld
    local isInAFKWorld = checkAFKWorldState()
    
    -- Nếu Auto Join AFK được bật và người chơi không ở trong AFKWorld
    if autoJoinAFKEnabled and not isInAFKWorld then
        joinAFKWorld()
    end
end)

-- Thêm section UI Settings vào tab Settings
local UISettingsSection = SettingsTab:AddSection("UI Settings")

-- Toggle Auto Hide UI
UISettingsSection:AddToggle("AutoHideUIToggle", {
    Title = "Auto Hide UI",
    Default = ConfigSystem.CurrentConfig.AutoHideUI or false,
    Callback = function(Value)
        autoHideUIEnabled = Value
        ConfigSystem.CurrentConfig.AutoHideUI = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Hide UI đã được bật, UI sẽ tự động ẩn sau 1 giây")
            
            -- Tạo timer mới để tự động ẩn UI
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
            
            autoHideUITimer = spawn(function()
                wait(1) -- Đợi 1 giây
                if autoHideUIEnabled and not isMinimized then
                    -- Tự động ẩn UI
                    Window.Minimize()
                end
            end)
        else
            print("Auto Hide UI đã được tắt")
            
            -- Hủy timer nếu có
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
        end
    end
})

-- Tự động ẩn UI nếu tính năng được bật
spawn(function()
    wait(1) -- Đợi script khởi động hoàn tất
    
    -- Nếu Auto Hide UI được bật và UI không ở trạng thái ẩn
    if autoHideUIEnabled and not isMinimized then
        -- Tự động ẩn UI
        Window.Minimize()
        
        print("UI đã được tự động ẩn. Nhấp vào logo để hiển thị lại.")
    end
end)

-- Hàm để xóa animations
local function removeAnimations()
    if not isPlayerInMap() then
        return false
    end
    
    local success, err = pcall(function()
        -- Xóa UIS.Packages.Transition.Flash từ ReplicatedStorage
        local uis = game:GetService("ReplicatedStorage"):FindFirstChild("UIS")
            if uis then
                local packages = uis:FindFirstChild("Packages")
                if packages then
                    local transition = packages:FindFirstChild("Transition")
                    if transition then
                    local flash = transition:FindFirstChild("Flash")
                    if flash then
                        flash:Destroy()
                        print("Đã xóa ReplicatedStorage.UIS.Packages.Transition.Flash")
                    end
                end
            end
            
            -- Xóa RewardsUI
            local rewardsUI = uis:FindFirstChild("RewardsUI")
            if rewardsUI then
                rewardsUI:Destroy()
                print("Đã xóa ReplicatedStorage.UIS.RewardsUI")
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi xóa animations: " .. tostring(err))
        return false
    end
    
    return true
end

-- Thêm Toggle Remove Animation
InGameSection:AddToggle("RemoveAnimationToggle", {
    Title = "Remove Animation",
    Default = ConfigSystem.CurrentConfig.RemoveAnimation or true,
    Callback = function(Value)
        removeAnimationEnabled = Value
        ConfigSystem.CurrentConfig.RemoveAnimation = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Remove Animation đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if removeAnimationLoop then
                removeAnimationLoop:Disconnect()
                removeAnimationLoop = nil
            end
            
            -- Thử xóa animations ngay lập tức nếu đang trong map
            if isPlayerInMap() then
                removeAnimations()
            else
                print("Không ở trong map, sẽ xóa animations khi vào map")
            end
            
            -- Tạo vòng lặp mới để xóa animations định kỳ
            spawn(function()
                while removeAnimationEnabled and wait(3) do
                    if isPlayerInMap() then
                        removeAnimations()
                    end
                end
            end)
        else
            print("Remove Animation đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if removeAnimationLoop then
                removeAnimationLoop:Disconnect()
                removeAnimationLoop = nil
            end
        end
    end
})

-- Tự động xóa animations khi khởi động script nếu tính năng được bật và đang ở trong map
spawn(function()
    wait(3) -- Đợi game load
    
    if removeAnimationEnabled and isPlayerInMap() then
        removeAnimations()
        
        -- Tạo vòng lặp để tiếp tục xóa animations định kỳ
        spawn(function()
            while removeAnimationEnabled and wait(3) do
                if isPlayerInMap() then
                    removeAnimations()
                end
            end
        end)
    end
end)

-- Thêm section Merchant trong tab Shop
local MerchantSection = ShopTab:AddSection("Merchant")

-- Biến lưu trạng thái Merchant
local selectedMerchantItems = ConfigSystem.CurrentConfig.SelectedMerchantItems or {}
local autoMerchantBuyEnabled = ConfigSystem.CurrentConfig.AutoMerchantBuy or false
local autoMerchantBuyLoop = nil

-- Danh sách các item có thể mua từ Merchant
local merchantItems = {
    "Green Bean",
    "Onigiri",
    "Dr. Megga Punk", 
    "Cursed Finger",
    "Stats Key",
    "French Fries",
    "Trait Reroll",
    "Ranger Crystal",
    "Rubber Fruit"
}

-- Hàm để mua item từ Merchant
local function buyMerchantItem(itemName)
    local success, err = pcall(function()
        local merchantRemote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Gameplay", "Merchant"}, 2)
        
        if merchantRemote then
            local args = {
                [1] = itemName,
                [2] = 1
            }
            
            merchantRemote:FireServer(unpack(args))
            print("Đã mua item: " .. itemName)
            
            -- Hiển thị thông báo
            print("Đã mua item: " .. itemName)
        else
            warn("Không tìm thấy Remote Merchant")
        end
    end)
    
    if not success then
        warn("Lỗi khi mua item từ Merchant: " .. tostring(err))
    end
end

-- Dropdown để chọn nhiều items
MerchantSection:AddDropdown("MerchantItemsDropdown", {
    Title = "Select Items",
    Values = merchantItems,
    Multi = true,
    Default = selectedMerchantItems,
    Callback = function(Values)
        selectedMerchantItems = Values
        ConfigSystem.CurrentConfig.SelectedMerchantItems = Values
        ConfigSystem.SaveConfig()
        
        local selectedItemsText = ""
        -- Sửa cách xử lý Values để tránh lỗi
        if type(Values) == "table" then
            for item, isSelected in pairs(Values) do
                if isSelected then
                    selectedItemsText = selectedItemsText .. item .. ", "
                end
            end
        end
        
        if selectedItemsText ~= "" then
            selectedItemsText = selectedItemsText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            print("Đã chọn items: " .. selectedItemsText)
        else
            print("Không có item nào được chọn")
        end
    end
})

-- Nút Buy Selected Item (mua thủ công)
MerchantSection:AddButton({
    Title = "Buy Selected Items",
    Callback = function()
        local selectedItemsCount = 0
        -- Sửa cách duyệt qua selectedMerchantItems
        for item, isSelected in pairs(selectedMerchantItems) do
            if isSelected then
                selectedItemsCount = selectedItemsCount + 1
                buyMerchantItem(item)
                wait(0.5) -- Chờ 0.5 giây giữa các lần mua
            end
        end
        
        if selectedItemsCount == 0 then
            print("Không có item nào được chọn để mua")
        end
    end
})

-- Toggle Auto Buy
MerchantSection:AddToggle("AutoMerchantBuyToggle", {
    Title = "Auto Buy",
    Default = ConfigSystem.CurrentConfig.AutoMerchantBuy or false,
    Callback = function(Value)
        autoMerchantBuyEnabled = Value
        ConfigSystem.CurrentConfig.AutoMerchantBuy = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            local selectedItemsCount = 0
            for item, isSelected in pairs(selectedMerchantItems) do
                if isSelected then
                    selectedItemsCount = selectedItemsCount + 1
                end
            end
            
            if selectedItemsCount == 0 then
                print("Auto Buy đã bật nhưng không có item nào được chọn")
            else
                print("Auto Buy đã được bật, sẽ tự động mua items mỗi 2 giây")
            end
            
            -- Hủy vòng lặp cũ nếu có
            if autoMerchantBuyLoop then
                autoMerchantBuyLoop:Disconnect()
                autoMerchantBuyLoop = nil
            end
            
            -- Tạo vòng lặp mới để tự động mua
            spawn(function()
                while autoMerchantBuyEnabled and wait(2) do -- Mua mỗi 2 giây
                    for item, isSelected in pairs(selectedMerchantItems) do
                        if isSelected then
                            buyMerchantItem(item)
                            wait(0.5) -- Chờ 0.5 giây giữa các lần mua
                        end
                    end
                end
            end)
        else
            print("Auto Buy đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoMerchantBuyLoop then
                autoMerchantBuyLoop:Disconnect()
                autoMerchantBuyLoop = nil
            end
        end
    end
})

-- Biến lưu trạng thái Auto Scan Units
local autoScanUnitsEnabled = ConfigSystem.CurrentConfig.AutoScanUnits or true
local autoScanUnitsLoop = nil

-- Tự động scan unit khi bắt đầu
spawn(function()
    wait(5) -- Đợi 5 giây để game load
    scanUnits()
    
    -- Bắt đầu vòng lặp auto scan nếu đã bật
    if autoScanUnitsEnabled then
        spawn(function()
            while autoScanUnitsEnabled and wait(3) do
                if isPlayerInMap() then
                    local success = scanUnits()
                    if success then
                        print("Auto Scan: Phát hiện " .. #unitSlots .. " unit")
                    end
                end
            end
        end)
    end
end)

-- Tự động cập nhật trạng thái từ game khi khởi động
spawn(function()
    wait(3) -- Đợi game load
    local actualState = checkActualAutoPlayState()
    
    -- Cập nhật cấu hình nếu trạng thái thực tế khác với cấu hình
    if autoPlayEnabled ~= actualState then
        autoPlayEnabled = actualState
        ConfigSystem.CurrentConfig.AutoPlay = actualState
        ConfigSystem.SaveConfig()
        
        -- Cập nhật UI nếu cần
        local autoPlayToggle = InGameSection:GetComponent("AutoPlayToggle")
        if autoPlayToggle and autoPlayToggle.Set then
            autoPlayToggle:Set(actualState)
        end
        
        print("Đã cập nhật trạng thái Auto Play từ game: " .. (actualState and "bật" or "tắt"))
    end
end)

-- Thêm section Easter Egg - Event trong tab Event
local EasterEggSection = EventTab:AddSection("Easter Egg - Event")

-- Biến lưu trạng thái Easter Egg
local autoJoinEasterEggEnabled = ConfigSystem.CurrentConfig.AutoJoinEasterEgg or false
local easterEggTimeDelay = ConfigSystem.CurrentConfig.EasterEggTimeDelay or 5
local autoJoinEasterEggLoop = nil

-- Hàm để tham gia Easter Egg Event
local function joinEasterEggEvent()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Easter Egg Event")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để join Easter Egg Event")
            return
        end
        
        -- 1. Gửi lệnh Easter-Event
        local args1 = {
            [1] = "Easter-Event"
        }
        Event:FireServer(unpack(args1))
        print("Đã gửi lệnh Easter-Event")
        wait(1) -- Đợi 1 giây
        
        -- 2. Gửi lệnh Start
        local args2 = {
            [1] = "Start"
        }
        Event:FireServer(unpack(args2))
        print("Đã gửi lệnh Start cho Easter Egg Event")
    end)
    
    if not success then
        warn("Lỗi khi tham gia Easter Egg Event: " .. tostring(err))
        return false
    end
    
    return true
end

-- Time Delay slider cho Easter Egg
EasterEggSection:AddSlider("EasterEggTimeDelaySlider", {
    Title = "Time Delay (giây)",
    Default = easterEggTimeDelay,
    Min = 1,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        easterEggTimeDelay = Value
        ConfigSystem.CurrentConfig.EasterEggTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Easter Egg Time Delay: " .. Value .. " giây")
        -- Cập nhật Input khi Slider thay đổi
        local input = EasterEggSection:GetComponent("EasterEggTimeDelayInput")
        if input and input.Set then input:Set(tostring(Value)) end
    end
})

-- Input cho Easter Egg Time Delay
EasterEggSection:AddInput("EasterEggTimeDelayInput", {
    Title = "",
    Placeholder = "Nhập delay",
    Default = tostring(easterEggTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 60 then
            easterEggTimeDelay = numValue
            ConfigSystem.CurrentConfig.EasterEggTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Easter Egg Time Delay (Input): " .. numValue .. " giây")
            -- Cập nhật Slider khi Input thay đổi
            local slider = EasterEggSection:GetComponent("EasterEggTimeDelaySlider")
            if slider and slider.Set then slider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-60)")
            local input = EasterEggSection:GetComponent("EasterEggTimeDelayInput")
            if input and input.Set then input:Set(tostring(easterEggTimeDelay)) end
        end
    end
})

-- Toggle Auto Join Easter Egg
EasterEggSection:AddToggle("AutoJoinEasterEggToggle", {
    Title = "Auto Join Easter Egg",
    Default = ConfigSystem.CurrentConfig.AutoJoinEasterEgg or false,
    Callback = function(Value)
        autoJoinEasterEggEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinEasterEgg = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Join Easter Egg sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Join Easter Egg đã được bật, sẽ bắt đầu sau " .. easterEggTimeDelay .. " giây")
                
                -- Thực hiện join Easter Egg Event sau thời gian delay
                spawn(function()
                    wait(easterEggTimeDelay)
                    if autoJoinEasterEggEnabled and not isPlayerInMap() then
                        joinEasterEggEvent()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Easter Egg Event
            spawn(function()
                while autoJoinEasterEggEnabled and wait(10) do -- Thử join mỗi 10 giây
                    -- Chỉ thực hiện join nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Áp dụng time delay
                        print("Đợi " .. easterEggTimeDelay .. " giây trước khi join Easter Egg Event")
                        wait(easterEggTimeDelay)
                        
                        -- Kiểm tra lại sau khi delay
                        if autoJoinEasterEggEnabled and not isPlayerInMap() then
                            joinEasterEggEvent()
                        end
                    else
                        -- Người chơi đang ở trong map, không cần join
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            print("Auto Join Easter Egg đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoJoinEasterEggLoop then
                autoJoinEasterEggLoop:Disconnect()
                autoJoinEasterEggLoop = nil
            end
        end
    end
})

-- Nút Join Easter Egg Now (thủ công)
EasterEggSection:AddButton({
    Title = "Join Easter Egg Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đang ở trong map
        if isPlayerInMap() then
        print("Bạn đang ở trong map, không thể tham gia Easter Egg Event mới")
            return
        end
        
        print("Đang tham gia Easter Egg Event...")
        
        joinEasterEggEvent()
    end
})

-- Khởi tạo Anti AFK khi script khởi động
spawn(function()
    -- Đợi một chút để script khởi động hoàn tất
    wait(3)
    
    -- Nếu Anti AFK được bật, thiết lập nó
    if antiAFKEnabled then
        setupAntiAFK()
        print("Đã tự động thiết lập Anti AFK khi khởi động script")
    end
end)

-- Tự động xóa animations khi khởi động script nếu tính năng được bật và đang ở trong map
spawn(function()
    wait(3) -- Đợi game load
    
    if removeAnimationEnabled and isPlayerInMap() then
        removeAnimations()
        
        -- Tạo vòng lặp để tiếp tục xóa animations định kỳ
        spawn(function()
            while removeAnimationEnabled and wait(3) do
                if isPlayerInMap() then
                    removeAnimations()
                end
            end
        end)
    end
end)

-- Khởi động các vòng lặp tối ưu
setupOptimizedLoops()

-- Kiểm tra trạng thái người chơi khi script khởi động
if isPlayerInMap() then
    print("Bạn đang ở trong map, Auto Join sẽ chỉ hoạt động khi bạn rời khỏi map")
end

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "HT Hub | Anime Rangers X",
    Content = "Script đã tải thành công! Đã tối ưu hóa cho trải nghiệm mượt mà.",
    Duration = 3
})

print("Anime Rangers X Script has been loaded and optimized!")

-- Biến lưu trạng thái Webhook
local webhookURL = ConfigSystem.CurrentConfig.WebhookURL or ""
local autoSendWebhookEnabled = ConfigSystem.CurrentConfig.AutoSendWebhook or false
local webhookSentLog = {} -- Lưu trữ log các lần đã gửi để tránh gửi lặp lại

-- Hàm lấy thông tin phần thưởng
local function getRewards()
    local player = game:GetService("Players").LocalPlayer
    local rewardsShow = player:FindFirstChild("RewardsShow")
    local result = {}
    
    if rewardsShow then
        for _, folder in ipairs(rewardsShow:GetChildren()) do
            local amount = folder:FindFirstChild("Amount")
            table.insert(result, {
                Name = folder.Name,
                Amount = (amount and amount.Value) or 0
            })
        end
    end
    
    return result
end

-- Hàm lấy số lượng tài nguyên hiện tại
local function getCurrentResources()
    local player = game:GetService("Players").LocalPlayer
    local playerName = player.Name
    local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")
    
    if not playerData then
        return {}
    end
    
    local playerFolder = playerData:FindFirstChild(playerName)
    if not playerFolder then
        return {}
    end
    
    local dataFolder = playerFolder:FindFirstChild("Data")
    if not dataFolder then
        return {}
    end
    
    local resources = {}
    
    -- Lấy số lượng các tài nguyên phổ biến
    local commonResources = {"Gold", "Gem", "EXP", "Rubber Fruit"}
    for _, resourceName in ipairs(commonResources) do
        local resourceValue = dataFolder:FindFirstChild(resourceName)
        if resourceValue then
            resources[resourceName] = resourceValue.Value
        end
    end
    
    -- Kiểm tra thêm các tài nguyên khác trong Data folder
    for _, child in pairs(dataFolder:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            resources[child.Name] = child.Value
        end
    end
    
    return resources
end

-- Hàm tính tổng tài nguyên sau khi nhận phần thưởng
local function calculateTotalResources(rewards)
    local currentResources = getCurrentResources()
    local totalResources = {}
    
    -- Tính tổng cho mỗi loại tài nguyên
    for _, reward in ipairs(rewards) do
        local resourceName = reward.Name
        local currentAmount = currentResources[resourceName] or 0
        totalResources[resourceName] = currentAmount + reward.Amount
    end
    
    return totalResources
end

-- Hàm lấy thông tin trận đấu
local function getGameInfoText()
    local player = game:GetService("Players").LocalPlayer
    local rewardsUI = player:WaitForChild("PlayerGui", 1):FindFirstChild("RewardsUI")
    local infoLines = {}
    
    if rewardsUI then
        local leftSide = rewardsUI:FindFirstChild("Main") and rewardsUI.Main:FindFirstChild("LeftSide")
        if leftSide then
            local labels = {
                "GameStatus",
                "Mode",
                "World",
                "Chapter",
                "Difficulty",
                "TotalTime"
            }
            
            for _, labelName in ipairs(labels) do
                local label = leftSide:FindFirstChild(labelName)
                if label and label:IsA("TextLabel") then
                    table.insert(infoLines, "- " .. labelName .. ": " .. label.Text)
                end
            end
        end
    end
    
    return table.concat(infoLines, "\n")
end

-- Hàm tạo nội dung embed
local function createEmbed(rewards, gameInfo)
    local fields = {}
    
    -- Thêm trường phần thưởng
    local rewardText = ""
    for _, r in ipairs(rewards) do
        rewardText = rewardText .. "- " .. r.Name .. ": +" .. r.Amount .. "\n"
    end
    
    if rewardText ~= "" then
        table.insert(fields, {
            name = "📦 Phần thưởng vừa nhận",
            value = rewardText,
            inline = false
        })
    end
    
    -- Lấy và hiển thị thông tin tài nguyên người chơi
    local playerResources = getCurrentResources()
    local statsText = ""
    
    -- Thêm tên người chơi
    local playerName = game:GetService("Players").LocalPlayer.Name
    statsText = "- Name: " .. playerName .. "\n"
    
    -- Luôn hiển thị các tài nguyên chính: Level, Gem, Gold, Egg
    local mainResources = {"Level", "Gem", "Gold", "Egg"}
    for _, resourceName in ipairs(mainResources) do
        local value = playerResources[resourceName] or 0
        statsText = statsText .. "- " .. resourceName .. ": " .. value .. "\n"
    end
    
    table.insert(fields, {
        name = "👤 Account",
        value = statsText,
        inline = false
    })
    
    -- Thêm trường thông tin trận đấu
    if gameInfo ~= "" then
        table.insert(fields, {
            name = "📝 Thông tin trận đấu",
            value = gameInfo,
            inline = false
        })
    end
    
    -- Tạo embed
    local embed = {
        title = "Anime Rangers X - Kết quả trận đấu",
        description = "Thông tin về trận đấu vừa kết thúc",
        color = 5793266, -- Màu tím
        fields = fields,
        thumbnail = {
            url = "https://media.discordapp.net/attachments/1321403790343274597/1364864770699821056/HT_HUB.png?ex=680b38df&is=6809e75f&hm=8a8272215b54db14974319f1745680390342942777e2fc291e38a4be4edf6fda&=&format=webp&quality=lossless&width=930&height=930" -- Logo HT Hub
        },
        footer = {
            text = "HT Hub | Anime Rangers X • " .. os.date("%x %X"),
            icon_url = "https://media.discordapp.net/attachments/1321403790343274597/1364864770699821056/HT_HUB.png?ex=680b38df&is=6809e75f&hm=8a8272215b54db14974319f1745680390342942777e2fc291e38a4be4edf6fda&=&format=webp&quality=lossless&width=930&height=930"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    return embed
end

-- Hàm gửi webhook
local function sendWebhook(rewards)
    -- Kiểm tra URL webhook
    if webhookURL == "" then
        warn("URL webhook trống, không thể gửi thông tin")
        return false
    end
    
    -- Tạo ID cho lần gửi này
    local gameId = os.time() .. "_" .. math.random(1000, 9999)
    
    -- Kiểm tra nếu đã gửi trước đó
    if webhookSentLog[gameId] then
        return false
    end
    
    -- Lấy thông tin trận đấu
    local gameInfo = getGameInfoText()
    
    -- Sử dụng embed
    local embed = createEmbed(rewards, gameInfo)
    local payload = game:GetService("HttpService"):JSONEncode({
        embeds = {embed}
    })
    
    -- Gửi request
    local httpRequest = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or HttpPost
    if not httpRequest then
        warn("Không tìm thấy hàm gửi HTTP request tương thích.")
        return false
    end
    
    local success, response = pcall(function()
        return httpRequest({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)
    
    if success then
        print("Đã gửi phần thưởng và thông tin game qua webhook!")
        webhookSentLog[gameId] = true
        return true
    else
        warn("Gửi webhook thất bại:", response)
        return false
    end
end

-- Thiết lập vòng lặp kiểm tra game kết thúc và gửi webhook
local function setupWebhookMonitor()
    spawn(function()
        while wait(2) do
            if not autoSendWebhookEnabled then
                wait(1)
            else
                -- Chỉ kiểm tra nếu đang ở trong map
                if isPlayerInMap() then
                    local player = game:GetService("Players").LocalPlayer
                    local agentFolder = workspace:FindFirstChild("Agent") and workspace.Agent:FindFirstChild("Agent")
                    local rewardsShow = player:FindFirstChild("RewardsShow")
                    
                    -- Kiểm tra điều kiện kết thúc game
                    if agentFolder and #agentFolder:GetChildren() == 0 and rewardsShow then
                        local rewards = getRewards()
                        if #rewards > 0 then
                            sendWebhook(rewards)
                            -- Đợi một thời gian để không gửi lặp lại
                            wait(10)
                        end
                    end
                end
            end
        end
    end)
end

-- Thêm section Webhook trong tab Webhook
local WebhookSection = WebhookTab:AddSection("Discord Webhook")

-- Thêm input để nhập URL webhook
WebhookSection:AddInput("WebhookURLInput", {
    Title = "Webhook URL",
    Default = webhookURL,
    Placeholder = "Nhập URL webhook Discord của bạn",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        webhookURL = Value
        ConfigSystem.CurrentConfig.WebhookURL = Value
        ConfigSystem.SaveConfig()
        
        print("Đã cập nhật URL webhook")
    end
})

-- Toggle Auto SendWebhook
WebhookSection:AddToggle("AutoSendWebhookToggle", {
    Title = "Auto Send Webhook",
    Default = autoSendWebhookEnabled,
    Callback = function(Value)
        if Value then
            -- Kiểm tra URL webhook
            if webhookURL == "" then
                print("URL webhook trống! Vui lòng nhập URL webhook trước khi bật tính năng này.")
                return
            end
            -- Kiểm tra có đang ở trong map không
            if not isPlayerInMap() then
                print("Bạn chỉ có thể bật Auto Send Webhook khi đang ở trong map!")
                return
            end
            autoSendWebhookEnabled = true
            ConfigSystem.CurrentConfig.AutoSendWebhook = true
            ConfigSystem.SaveConfig()
            print("Auto Send Webhook đã được bật. Thông tin trận đấu sẽ tự động gửi khi game kết thúc.")
        else
            autoSendWebhookEnabled = false
            ConfigSystem.CurrentConfig.AutoSendWebhook = false
            ConfigSystem.SaveConfig()
            print("Auto Send Webhook đã được tắt")
        end
    end
})

-- Nút Test Webhook
WebhookSection:AddButton({
    Title = "Test Webhook",
    Callback = function()
        -- Kiểm tra URL webhook
        if webhookURL == "" then
            print("URL webhook trống! Vui lòng nhập URL webhook trước khi test.")
            return
        end
        
        -- Tạo dữ liệu test
        local testRewards = {
            {Name = "Gem", Amount = 100},
            {Name = "Gold", Amount = 1000},
            {Name = "EXP", Amount = 500}
        }
        
        -- Gửi webhook test
        local success = sendWebhook(testRewards)
        
        if success then
            print("Đã gửi webhook test thành công!")
        else
            print("Gửi webhook test thất bại! Kiểm tra lại URL và quyền truy cập.")
        end
    end
})

-- Khởi động vòng lặp kiểm tra game kết thúc
setupWebhookMonitor()

-- Thêm section Egg Event trong tab Shop
local EggEventSection = ShopTab:AddSection("Egg Event")

-- Biến lưu trạng thái Auto Buy Egg
local autoBuyEggEnabled = ConfigSystem.CurrentConfig.AutoBuyEgg or false
local autoBuyEggLoop = nil

-- Biến lưu trạng thái Auto Open Egg
local autoOpenEggEnabled = ConfigSystem.CurrentConfig.AutoOpenEgg or false
local autoOpenEggLoop = nil

-- Toggle Auto Buy Egg
EggEventSection:AddToggle("AutoBuyEggToggle", {
    Title = "Auto Buy Egg",
    Default = autoBuyEggEnabled,
    Callback = function(Value)
        autoBuyEggEnabled = Value
        ConfigSystem.CurrentConfig.AutoBuyEgg = Value
        ConfigSystem.SaveConfig()
        if Value then
            print("Auto Buy Egg đã được bật")
            if autoBuyEggLoop then
                autoBuyEggLoop:Disconnect()
                autoBuyEggLoop = nil
            end
            spawn(function()
                while autoBuyEggEnabled do
                    local args = {"Egg Capsule", 1}
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("EasterEgg"):FireServer(unpack(args))
                    end)
                    if not success then
                        warn("Lỗi khi Auto Buy Egg: " .. tostring(err))
                    end
                    wait(0.5)
                end
            end)
        else
            print("Auto Buy Egg đã được tắt")
            if autoBuyEggLoop then
                autoBuyEggLoop:Disconnect()
                autoBuyEggLoop = nil
            end
        end
    end
})

-- Toggle Auto Open Egg
EggEventSection:AddToggle("AutoOpenEggToggle", {
    Title = "Auto Open Egg",
    Default = autoOpenEggEnabled,
    Callback = function(Value)
        autoOpenEggEnabled = Value
        ConfigSystem.CurrentConfig.AutoOpenEgg = Value
        ConfigSystem.SaveConfig()
        if Value then
            print("Auto Open Egg đã được bật")
            if autoOpenEggLoop then
                autoOpenEggLoop:Disconnect()
                autoOpenEggLoop = nil
            end
            spawn(function()
                while autoOpenEggEnabled do
                    local playerName = game:GetService("Players").LocalPlayer.Name
                    local eggItem = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(playerName):WaitForChild("Items"):FindFirstChild("Egg Capsule")
                    if eggItem then
                        local args = {eggItem, {SummonAmount = 1}}
                        local success, err = pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("ItemUse"):FireServer(unpack(args))
                        end)
                        if not success then
                            warn("Lỗi khi Auto Open Egg: " .. tostring(err))
                        end
                    else
                        warn("Không tìm thấy Egg Capsule trong Items!")
                    end
                    wait(0.5)
                end
            end)
        else
            print("Auto Open Egg đã được tắt")
            if autoOpenEggLoop then
                autoOpenEggLoop:Disconnect()
                autoOpenEggLoop = nil
            end
        end
    end
})

-- Toggle Auto Join All (Ranger)
local autoJoinAllRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinAllRanger or false
local autoJoinAllRangerLoop = nil

RangerSection:AddToggle("AutoJoinAllRangerToggle", {
    Title = "Auto Join All",
    Default = autoJoinAllRangerEnabled,
    Callback = function(Value)
        autoJoinAllRangerEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAllRanger = Value
        ConfigSystem.SaveConfig()
        if Value then
            print("Auto Join All Ranger đã được bật")
            if autoJoinAllRangerLoop then
                autoJoinAllRangerLoop:Disconnect()
                autoJoinAllRangerLoop = nil
            end
            spawn(function()
                local allMaps = {"OnePiece", "Namek", "DemonSlayer", "Naruto", "OPM"}
                local allActs = {"RangerStage1", "RangerStage2", "RangerStage3"}
                while autoJoinAllRangerEnabled do
                    for _, map in ipairs(allMaps) do
                        for _, act in ipairs(allActs) do
                            if not autoJoinAllRangerEnabled then return end
                            if not isPlayerInMap() then
                                -- Đổi map và act không cần thiết nữa vì joinRangerStage đã xử lý
                                -- local displayMap = reverseMapNameMapping[map] or map
                                -- changeWorld(displayMap)
                                -- wait(0.5)
                                -- changeAct(map, act)
                                -- wait(0.5)
                                
                                -- Join Ranger Stage với map và act cụ thể
                                joinRangerStage(map, act) -- << Truyền map và act vào đây
                                
                                print("Đã yêu cầu join: " .. map .. " - " .. act)
                                
                                -- Đợi cho đến khi vào map hoặc hết delay
                                local t = 0
                                while not isPlayerInMap() and t < 10 and autoJoinAllRangerEnabled do wait(0.5) t = t + 0.5 end
                                
                                -- Đợi delay giữa các lần join (nếu còn bật)
                                if autoJoinAllRangerEnabled then wait(rangerTimeDelay) end
                            else
                                -- Nếu đang ở trong map thì đợi ra khỏi map
                                while isPlayerInMap() and autoJoinAllRangerEnabled do wait(0.5) end
                            end
                            -- Thêm delay nhỏ để tránh spam quá nhanh nếu lỗi join
                            if not isPlayerInMap() and autoJoinAllRangerEnabled then wait(0.5) end 
                        end
                    end
                    -- Lặp lại từ đầu sau khi hết các map/act
                    print("Đã hoàn thành vòng lặp Auto Join All, bắt đầu lại...")
                    wait(0.5)
                end
            end)
        else
            print("Auto Join All Ranger đã được tắt")
            if autoJoinAllRangerLoop then
                autoJoinAllRangerLoop:Disconnect()
                autoJoinAllRangerLoop = nil
            end
        end
    end
})
