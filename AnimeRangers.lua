-- Anime Rangers X Script

-- Kiểm tra Place ID
local currentPlaceId = game.PlaceId
local allowedPlaceId = 72829404259339

if currentPlaceId ~= allowedPlaceId then
    warn("Script này chỉ hoạt động trên game Anime Rangers X (Place ID: " .. tostring(allowedPlaceId) .. ")")
    return
end

-- Tải thư viện Fluent trước để sử dụng GetKey
local Fluent = nil
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
    end)
end

if not Fluent then
    error("Không thể tải thư viện Fluent. Vui lòng kiểm tra kết nối internet hoặc executor.")
    return
end

-- Hệ thống xác thực key
local KeySystem = {}
KeySystem.Keys = {
    "HT_ANIME_RANGERS_ACCESS_5723",  -- Key 1
    "RANGER_PRO_ACCESS_9841",        -- Key 2
    "PREMIUM_ANIME_ACCESS_3619"      -- Key 3
}
KeySystem.KeyFileName = "htkey_anime_rangers.txt"
KeySystem.WebhookURL = "https://discord.com/api/webhooks/your_webhook_url_here" -- Thay bằng webhook của bạn

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
    if KeySystem.WebhookURL == "https://discord.com/api/webhooks/your_webhook_url_here" then
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

-- Sử dụng Fluent:GetKey() thay vì tự tạo UI
KeySystem.CreateKeyUI = function()
    local success, keyValid = KeySystem.CheckSavedKey()
    if success then
        print("HT Hub | Key hợp lệ, đang tải script...")
        KeySystem.SendWebhook(game.Players.LocalPlayer.Name, "Key đã lưu", true)
        return true
    end

    local valid = Fluent:GetKey({
        Title = "HT Hub | Anime Rangers X",
        Subtitle = "Hệ thống xác thực key",
        Note = "Nhập key để sử dụng script",
        FileName = KeySystem.KeyFileName,
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = KeySystem.Keys,
        Actions = {
            [1] = {
                Text = "Lấy key",
                Callback = function()
                    setclipboard("https://link-center.net/ht-hub-key")
                    Fluent:Notify({
                        Title = "HT Hub",
                        Content = "Đã sao chép liên kết lấy key vào clipboard",
                        Duration = 3
                    })
                end
            }
        }
    })

    if valid then
        KeySystem.SendWebhook(game.Players.LocalPlayer.Name, "Key hợp lệ", true)
        Fluent:Notify({
            Title = "Xác thực key",
            Content = "Key hợp lệ! Đang tải script...",
            Duration = 3
        })
        return true
    else
        KeySystem.SendWebhook(game.Players.LocalPlayer.Name, "Key không hợp lệ", false)
        return false
    end
end

-- Khởi chạy hệ thống key
local keyValid = KeySystem.CreateKeyUI()
if not keyValid then
    -- Nếu key không hợp lệ, dừng script
    return
end

-- Delay 30 giây trước khi mở script
print("HT Hub | Anime Rangers X đang khởi động, vui lòng đợi 15 giây...")
wait(15)
print("Đang tải script...")

-- Tải thư viện Fluent từ Arise (không cần tải lại vì đã tải ở trên)
pcall(function()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

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

-- Tạo logo UI để mở lại khi đã thu nhỏ
local function CreateLogoUI()
    local UI = Instance.new("ScreenGui")
    local Button = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")
    
    -- Kiểm tra môi trường
    if syn and syn.protect_gui then
        syn.protect_gui(UI)
        UI.Parent = game:GetService("CoreGui")
    elseif gethui then
        UI.Parent = gethui()
    else
        UI.Parent = game:GetService("CoreGui")
    end
    
    UI.Name = "AnimeRangersLogo"
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.ResetOnSpawn = false
    
    Button.Name = "LogoButton"
    Button.Parent = UI
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.BackgroundTransparency = 0.2
    Button.Position = UDim2.new(0.9, -25, 0.1, 0)
    Button.Size = UDim2.new(0, 50, 0, 50)
    Button.Image = "rbxassetid://90319448802378" -- Sử dụng ID của logo HT Hub
    Button.ImageTransparency = 0.1
    Button.Active = true
    Button.Draggable = true
    
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Button
    
    -- Ẩn logo ban đầu
    UI.Enabled = false
    
    -- Khi click vào logo
    Button.MouseButton1Click:Connect(function()
        -- Ẩn logo
        UI.Enabled = false
        
        -- Cập nhật trạng thái
        isMinimized = false
        
        -- Hiển thị lại UI chính
        pcall(function()
            -- Đảm bảo Window là hợp lệ trước khi gọi
            if Window then
                -- Nếu có hàm Toggle, sử dụng nó thay vì gọi Minimize trực tiếp
                if Window.Toggle then
                    Window.Toggle()
                elseif Window.Minimize then
                    Window.Minimize()
                end
                
                -- Đảm bảo UI chính được hiển thị
                if Window.Frame then
                    Window.Frame.Visible = true
                end
            end
        end)
        
        -- Hiển thị thông báo (debug)
        print("Đã nhấp vào logo, mở lại UI")
    end)
    
    return UI
end

-- Ghi đè hàm minimize mặc định của thư viện
local oldMinimize = Window.Minimize
Window.Minimize = function()
    isMinimized = not isMinimized
    
    -- Đảm bảo logo đã được tạo
    if not OpenUI then
        OpenUI = CreateLogoUI()
    end
    
    -- Hiển thị/ẩn logo dựa vào trạng thái
    if OpenUI then
        OpenUI.Enabled = isMinimized
        
        -- Đảm bảo logo vẫn hiển thị (phòng trường hợp bị ẩn do lỗi)
        if isMinimized then
            spawn(function()
                wait(0.5) -- Đợi một chút để đảm bảo UI đã được cập nhật
                if OpenUI and isMinimized then
                    OpenUI.Enabled = true
                end
            end)
        end
    end
    
    -- Gọi hàm minimize gốc
    pcall(function()
        oldMinimize()
    end)
    
    -- Kiểm tra xem UI đã hiển thị đúng chưa sau khi minimize
    spawn(function()
        wait(0.5)
        if isMinimized and OpenUI then
            -- Đảm bảo logo hiển thị khi UI ẩn
            OpenUI.Enabled = true
        elseif not isMinimized and Window and Window.Frame then
            -- Đảm bảo UI hiển thị khi không minimize
            Window.Frame.Visible = true
        end
    end)
end

-- Thêm phương thức Toggle cho Window nếu chưa có
if not Window.Toggle then
    Window.Toggle = function()
        -- Chuyển đổi trạng thái và gọi hàm minimize đã ghi đè
        Window.Minimize()
    end
end

-- Bắt sự kiện phím để kích hoạt minimize
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        Window.Minimize()
    end
end)

-- Tự động chọn tab Info khi khởi động
Window:SelectTab(1) -- Chọn tab đầu tiên (Info)

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:AddSection("Thông tin")

InfoSection:AddParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 1.0.0\nTrạng thái: Hoạt động"
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
        
        Fluent:Notify({
            Title = "Difficulty Changed",
            Content = "Đã đổi độ khó thành: " .. Value,
            Duration = 2
        })
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
            Fluent:Notify({
                Title = "Friend Only",
                Content = "Đã bật chế độ Friend Only",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Friend Only",
                Content = "Đã tắt chế độ Friend Only",
                Duration = 2
            })
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
                Fluent:Notify({
                    Title = "Auto Join Map",
                    Content = "Đang ở trong map, Auto Join Map sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Join Map",
                    Content = "Auto Join Map đã được bật, sẽ bắt đầu sau " .. storyTimeDelay .. " giây",
                    Duration = 3
                })
                
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
            Fluent:Notify({
                Title = "Auto Join Map",
                Content = "Auto Join Map đã được tắt",
                Duration = 3
            })
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

-- Nút manual summon
SummonSection:AddButton({
    Title = "Summon Once",
    Callback = function()
        performSummon()
        
        Fluent:Notify({
            Title = "Summon",
            Content = "Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner,
            Duration = 2
        })
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
            Fluent:Notify({
                Title = "Auto Summon",
                Content = "Auto Summon đã được bật",
                Duration = 3
            })
            
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
            Fluent:Notify({
                Title = "Auto Summon",
                Content = "Auto Summon đã được tắt",
                Duration = 3
            })
            
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

-- Nút Claim All Quest (manual)
QuestSection:AddButton({
    Title = "Claim All Quests",
    Callback = function()
        claimAllQuests()
        
        Fluent:Notify({
            Title = "Quests",
            Content = "Đã claim tất cả nhiệm vụ",
            Duration = 2
        })
    end
})

-- Toggle Auto Claim All Quest
QuestSection:AddToggle("AutoClaimQuestToggle", {
    Title = "Auto Claim All Quests",
    Default = ConfigSystem.CurrentConfig.AutoClaimQuest or false,
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()
        
        if autoClaimQuestEnabled then
            Fluent:Notify({
                Title = "Auto Claim Quests",
                Content = "Auto Claim Quests đã được bật",
                Duration = 3
            })
            
            -- Tạo vòng lặp Auto Claim Quests
            spawn(function()
                while autoClaimQuestEnabled and wait(30) do -- Claim mỗi 30 giây
                    claimAllQuests()
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Claim Quests",
                Content = "Auto Claim Quests đã được tắt",
                Duration = 3
            })
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
                    wait(5) -- Đợi để xem đã vào map chưa
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Join Ranger
                if autoJoinRangerEnabled and not shouldContinue then
                    cycleRangerStages()
                    wait(5)
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Boss Event
                if autoBossEventEnabled and not shouldContinue then
                joinBossEvent()
                    wait(5)
                    shouldContinue = isPlayerInMap()
    end
    
                -- Kiểm tra Auto Challenge
                if autoChallengeEnabled and not shouldContinue then
                    joinChallenge()
                    wait(5)
                    shouldContinue = isPlayerInMap()
                end
                
                -- Kiểm tra Auto Easter Egg
                if autoJoinEasterEggEnabled and not shouldContinue then
                    joinEasterEggEvent()
                    wait(5)
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

-- Hàm để tự động tham gia Ranger Stage
local function joinRangerStage()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Ranger Stage")
        return false
    end
    
    -- Cập nhật danh sách Acts đã sắp xếp
    updateOrderedActs()
    
    -- Kiểm tra xem có Act nào được chọn không
    if #orderedActs == 0 then
        warn("Không có Act nào được chọn để join Ranger Stage")
        return false
    end
    
    -- Lấy Act hiện tại từ danh sách đã sắp xếp
    local currentAct = orderedActs[currentActIndex]
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để join Ranger Stage")
            return
        end
        
        -- 1. Create
        Event:FireServer("Create")
        wait(0.5)
        
        -- 2. Change Mode to Ranger Stage
        local modeArgs = {
            [1] = "Change-Mode",
            [2] = {
                ["Mode"] = "Ranger Stage"
            }
        }
        Event:FireServer(unpack(modeArgs))
        wait(0.5)
        
        -- 3. Friend Only (nếu được bật)
        if rangerFriendOnly then
            Event:FireServer("Change-FriendOnly")
            wait(0.5)
        end
        
        -- 4. Chọn Map và Act
        -- 4.1 Đổi Map
        local args1 = {
            [1] = "Change-World",
            [2] = {
                ["World"] = selectedRangerMap
            }
        }
        Event:FireServer(unpack(args1))
        wait(0.5)
        
        -- 4.2 Đổi Act - dùng Act hiện tại theo thứ tự luân phiên
        local args2 = {
            [1] = "Change-Chapter",
            [2] = {
                ["Chapter"] = selectedRangerMap .. "_" .. currentAct
            }
        }
        Event:FireServer(unpack(args2))
        wait(0.5)
        
        -- 5. Submit
        Event:FireServer("Submit")
        wait(1)
        
        -- 6. Start
        Event:FireServer("Start")
        
        print("Đã join Ranger Stage: " .. selectedRangerMap .. "_" .. currentAct)
        
        -- Cập nhật index cho lần tiếp theo
        currentActIndex = (currentActIndex % #orderedActs) + 1
    end)
    
    if not success then
        warn("Lỗi khi join Ranger Stage: " .. tostring(err))
        return false
    end
    
    return true
end

-- Hàm để lặp qua các selected Acts
local function cycleRangerStages()
    if not autoJoinRangerEnabled or isPlayerInMap() then
        return
    end
    
    -- Đợi theo time delay 
    wait(rangerTimeDelay)
    
    -- Kiểm tra lại điều kiện sau khi đợi
    if not autoJoinRangerEnabled or isPlayerInMap() then
        return
    end
    
    -- Join Ranger Stage với Act theo thứ tự luân phiên
    joinRangerStage()
end

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
    end
})

-- Dropdown để chọn Map cho Ranger
RangerSection:AddDropdown("RangerMapDropdown", {
    Title = "Choose Map",
    Values = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    Multi = false,
    Default = selectedRangerDisplayMap,
    Callback = function(Value)
        selectedRangerDisplayMap = Value
        selectedRangerMap = mapNameMapping[Value] or "OnePiece"
        ConfigSystem.CurrentConfig.SelectedRangerMap = selectedRangerMap
        ConfigSystem.SaveConfig()
        
        -- Thay đổi map khi người dùng chọn
        changeWorld(Value)
        print("Đã chọn Ranger map: " .. Value .. " (thực tế: " .. selectedRangerMap .. ")")
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
            Fluent:Notify({
                Title = "Acts Selected",
                Content = "Đã chọn: " .. selectedActsText,
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Warning",
                Content = "Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.",
                Duration = 2
            })
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
            Fluent:Notify({
                Title = "Ranger Friend Only",
                Content = "Đã bật chế độ Friend Only cho Ranger Stage",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Ranger Friend Only",
                Content = "Đã tắt chế độ Friend Only cho Ranger Stage",
                Duration = 2
            })
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
    end
})

-- Toggle Auto Join Ranger Stage
RangerSection:AddToggle("AutoJoinRangerToggle", {
    Title = "Auto Join Ranger Stage",
    Default = ConfigSystem.CurrentConfig.AutoJoinRanger or false,
    Callback = function(Value)
        autoJoinRangerEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinRanger = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinRangerEnabled then
            -- Kiểm tra xem có Act nào được chọn không
            local hasSelectedAct = false
            for _, isSelected in pairs(selectedActs) do
                if isSelected then
                    hasSelectedAct = true
                    break
                end
            end
            
            if not hasSelectedAct then
                Fluent:Notify({
                    Title = "Warning",
                    Content = "Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.",
                    Duration = 3
                })
                return
            end
            
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                Fluent:Notify({
                    Title = "Auto Join Ranger Stage",
                    Content = "Đang ở trong map, Auto Join Ranger sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Join Ranger Stage",
                    Content = "Auto Join Ranger Stage đã được bật, sẽ bắt đầu sau " .. rangerTimeDelay .. " giây",
                    Duration = 3
                })
                
                -- Thực hiện join Ranger Stage sau thời gian delay
                spawn(function()
                    wait(rangerTimeDelay)
                    if autoJoinRangerEnabled and not isPlayerInMap() then
                        joinRangerStage()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Ranger Stage
            spawn(function()
                while autoJoinRangerEnabled and wait(10) do -- Thử join map mỗi 10 giây
                    -- Chỉ thực hiện join map nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Gọi hàm cycleRangerStages để luân phiên các Acts
                        cycleRangerStages()
                    else
                        -- Người chơi đang ở trong map, không cần join
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Join Ranger Stage",
                Content = "Auto Join Ranger Stage đã được tắt",
                Duration = 3
            })
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
        Fluent:Notify({
            Title = "Auto Leave",
            Content = "Không tìm thấy kẻ địch và agent trong 10 giây, đang teleport về lobby...",
            Duration = 3
        })
        
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
            Fluent:Notify({
                Title = "Auto Leave",
                Content = "Auto Leave đã được bật. Sẽ tự động rời map nếu không có kẻ địch và agent trong 10 giây",
                Duration = 3
            })
            
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
            Fluent:Notify({
                Title = "Auto Leave",
                Content = "Auto Leave đã được tắt",
                Duration = 3
            })
            
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
                Fluent:Notify({
                    Title = "Auto Boss Event",
                    Content = "Đang ở trong map, Auto Boss Event sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Boss Event",
                    Content = "Auto Boss Event đã được bật, sẽ bắt đầu sau " .. bossEventTimeDelay .. " giây",
                    Duration = 3
                })
                
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
            Fluent:Notify({
                Title = "Auto Boss Event",
                Content = "Auto Boss Event đã được tắt",
                Duration = 3
            })
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
                Fluent:Notify({
                    Title = "Auto Challenge",
                    Content = "Đang ở trong map, Auto Challenge sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Challenge",
                    Content = "Auto Challenge đã được bật, sẽ bắt đầu sau " .. challengeTimeDelay .. " giây",
                    Duration = 3
                })
                
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
            Fluent:Notify({
                Title = "Auto Challenge",
                Content = "Auto Challenge đã được tắt",
                Duration = 3
            })
        end
    end
})

-- Nút Join Challenge (manual)
ChallengeSection:AddButton({
    Title = "Join Challenge Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đã ở trong map
        if isPlayerInMap() then
            Fluent:Notify({
                Title = "Join Challenge",
                Content = "Bạn đang ở trong map, không thể tham gia Challenge mới",
                Duration = 2
            })
            return
        end
        
        local success = joinChallenge()
        
        if success then
            Fluent:Notify({
                Title = "Challenge",
                Content = "Đang tham gia Challenge",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Challenge",
                Content = "Không thể tham gia Challenge. Vui lòng thử lại sau.",
                Duration = 2
            })
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
        Fluent:Notify({
            Title = "Auto TP Lobby",
            Content = "Đang teleport về lobby...",
            Duration = 3
        })
        
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
        
        Fluent:Notify({
            Title = "Auto TP Lobby",
            Content = "Đã đặt thời gian delay: " .. Value .. " phút",
            Duration = 2
        })
        
        print("Đã đặt Auto TP Lobby Delay: " .. Value .. " phút")
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
            Fluent:Notify({
                Title = "Auto TP Lobby",
                Content = "Auto TP Lobby đã được bật, sẽ teleport sau " .. autoTPLobbyDelay .. " phút",
                Duration = 3
            })
            
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
                        Fluent:Notify({
                            Title = "Auto TP Lobby",
                            Content = "Sẽ teleport về lobby trong 1 phút nữa",
                            Duration = 3
                        })
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
            Fluent:Notify({
                Title = "Auto TP Lobby",
                Content = "Auto TP Lobby đã được tắt",
                Duration = 3
            })
            
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
                Fluent:Notify({
                    Title = "Auto Play",
                    Content = "Auto Play đã được bật",
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "Auto Play",
                    Content = "Auto Play đã được tắt",
                    Duration = 2
                })
            end
        else
            Fluent:Notify({
                Title = "Auto Play",
                Content = "Trạng thái Auto Play đã phù hợp (" .. (Value and "bật" or "tắt") .. ")",
                Duration = 2
            })
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
            Fluent:Notify({
                Title = "Auto Retry",
                Content = "Auto Retry đã được bật",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Auto Retry",
                Content = "Auto Retry đã được tắt",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Auto Next",
                Content = "Auto Next đã được bật",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Auto Next",
                Content = "Auto Next đã được tắt",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Auto Vote",
                Content = "Auto Vote đã được bật, sẽ bắt đầu sau 15 giây",
                Duration = 3
            })
            
            -- Hủy vòng lặp cũ nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
            
            -- Tạo vòng lặp mới với 15 giây delay trước khi bắt đầu
            spawn(function()
                -- Chờ 1 giây trước khi bắt đầu Auto Vote
                wait(0.1)
                
                -- Kiểm tra lại nếu toggle vẫn được bật sau khi đợi
                if autoVoteEnabled then
                    -- Thông báo bắt đầu
                    Fluent:Notify({
                        Title = "Auto Vote",
                        Content = "Auto Vote bắt đầu hoạt động",
                        Duration = 2
                    })
                    
                    -- Bắt đầu vòng lặp sau khi delay
                    while autoVoteEnabled and wait(3) do -- Gửi yêu cầu mỗi 3 giây
                        toggleAutoVote()
                    end
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Vote",
                Content = "Auto Vote đã được tắt",
                Duration = 2
            })
            
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
            
            Fluent:Notify({
                Title = "Auto Update",
                Content = "Auto Update đã được bật",
                Duration = 2
            })
            
            -- Hủy vòng lặp cũ nếu có
            if autoUpdateLoop then
                autoUpdateLoop:Disconnect()
                autoUpdateLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateEnabled and wait(2) do -- Cập nhật mỗi 2 giây
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
            Fluent:Notify({
                Title = "Auto Update",
                Content = "Auto Update đã được tắt",
                Duration = 2
            })
            
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
            
            Fluent:Notify({
                Title = "Auto Update Random",
                Content = "Auto Update Random đã được bật",
                Duration = 2
            })
            
            -- Hủy vòng lặp cũ nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateRandomEnabled and wait(2) do -- Cập nhật mỗi 2 giây
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
            Fluent:Notify({
                Title = "Auto Update Random",
                Content = "Auto Update Random đã được tắt",
                Duration = 2
            })
            
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
            
            Fluent:Notify({
                Title = "Auto Join AFK",
                Content = "Auto Join AFK đã được bật",
                Duration = 2
            })
            
            -- Nếu không ở trong AFKWorld, teleport ngay lập tức
            if not isInAFKWorld then
                joinAFKWorld()
            else
                Fluent:Notify({
                    Title = "AFKWorld",
                    Content = "Bạn đã ở trong AFKWorld",
                    Duration = 2
                })
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
            Fluent:Notify({
                Title = "Auto Join AFK",
                Content = "Auto Join AFK đã được tắt",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "AFKWorld",
                Content = "Bạn đã ở trong AFKWorld",
                Duration = 2
            })
            return
        end
        
        joinAFKWorld()
        
        Fluent:Notify({
            Title = "AFKWorld",
            Content = "Đang teleport đến AFKWorld...",
            Duration = 2
        })
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
            Fluent:Notify({
                Title = "Auto Hide UI",
                Content = "Auto Hide UI đã được bật, UI sẽ tự động ẩn sau 5 giây",
                Duration = 3
            })
            
            -- Tạo timer mới để tự động ẩn UI
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
            
            autoHideUITimer = spawn(function()
                wait(5) -- Đợi 5 giây
                if autoHideUIEnabled and not isMinimized then
                    -- Tự động ẩn UI
                    Window.Minimize()
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Hide UI",
                Content = "Auto Hide UI đã được tắt",
                Duration = 3
            })
            
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
        
        Fluent:Notify({
            Title = "Auto Hide UI",
            Content = "UI đã được tự động ẩn. Nhấp vào logo để hiển thị lại.",
            Duration = 3
        })
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
            Fluent:Notify({
                Title = "Remove Animation",
                Content = "Remove Animation đã được bật",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Remove Animation",
                Content = "Remove Animation đã được tắt",
                Duration = 2
            })
            
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
            Fluent:Notify({
                Title = "Merchant",
                Content = "Đã mua item: " .. itemName,
                Duration = 2
            })
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
            Fluent:Notify({
                Title = "Merchant",
                Content = "Không có item nào được chọn để mua",
                Duration = 2
            })
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
                Fluent:Notify({
                    Title = "Auto Merchant Buy",
                    Content = "Auto Buy đã bật nhưng không có item nào được chọn",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Merchant Buy",
                    Content = "Auto Buy đã được bật, sẽ tự động mua items mỗi 2 giây",
                    Duration = 3
                })
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
            Fluent:Notify({
                Title = "Auto Merchant Buy",
                Content = "Auto Buy đã được tắt",
                Duration = 3
            })
            
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
                Fluent:Notify({
                    Title = "Auto Join Easter Egg",
                    Content = "Đang ở trong map, Auto Join Easter Egg sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Join Easter Egg",
                    Content = "Auto Join Easter Egg đã được bật, sẽ bắt đầu sau " .. easterEggTimeDelay .. " giây",
                    Duration = 3
                })
                
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
            Fluent:Notify({
                Title = "Auto Join Easter Egg",
                Content = "Auto Join Easter Egg đã được tắt",
                Duration = 3
            })
            
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
            Fluent:Notify({
                Title = "Join Easter Egg",
                Content = "Bạn đang ở trong map, không thể tham gia Easter Egg Event mới",
                Duration = 3
            })
            return
        end
        
        Fluent:Notify({
            Title = "Easter Egg Event",
            Content = "Đang tham gia Easter Egg Event...",
            Duration = 2
        })
        
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

-- Thêm section Ranger Stage trong tab Play
local RangerSection = PlayTab:AddSection("Ranger Stage")

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
    Fluent:Notify({
        Title = "Phát hiện trạng thái",
        Content = "Bạn đang ở trong map, Auto Join sẽ chỉ hoạt động khi bạn rời khỏi map",
        Duration = 3
    })
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
        
        Fluent:Notify({
            Title = "Webhook URL",
            Content = "Đã cập nhật URL webhook",
            Duration = 2
        })
    end
})

-- Toggle Auto SendWebhook
WebhookSection:AddToggle("AutoSendWebhookToggle", {
    Title = "Auto Send Webhook",
    Default = autoSendWebhookEnabled,
    Callback = function(Value)
        autoSendWebhookEnabled = Value
        ConfigSystem.CurrentConfig.AutoSendWebhook = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra URL webhook
            if webhookURL == "" then
                Fluent:Notify({
                    Title = "Auto Send Webhook",
                    Content = "URL webhook trống! Vui lòng nhập URL webhook trước khi bật tính năng này.",
                    Duration = 3
                })
                return
            end
            
            Fluent:Notify({
                Title = "Auto Send Webhook",
                Content = "Auto Send Webhook đã được bật. Thông tin trận đấu sẽ tự động gửi khi game kết thúc.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Auto Send Webhook",
                Content = "Auto Send Webhook đã được tắt",
                Duration = 3
            })
        end
    end
})

-- Nút Test Webhook
WebhookSection:AddButton({
    Title = "Test Webhook",
    Callback = function()
        -- Kiểm tra URL webhook
        if webhookURL == "" then
            Fluent:Notify({
                Title = "Test Webhook",
                Content = "URL webhook trống! Vui lòng nhập URL webhook trước khi test.",
                Duration = 3
            })
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
            Fluent:Notify({
                Title = "Test Webhook",
                Content = "Đã gửi webhook test thành công!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Test Webhook",
                Content = "Gửi webhook test thất bại! Kiểm tra lại URL và quyền truy cập.",
                Duration = 3
            })
        end
    end
})

-- Khởi động vòng lặp kiểm tra game kết thúc
setupWebhookMonitor()
