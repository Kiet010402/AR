-- Anime Rangers X Script (Rayfield Edition)

-- Kiểm tra Place ID
local currentPlaceId = game.PlaceId
local allowedPlaceId = 72829404259339

if currentPlaceId ~= allowedPlaceId then
    warn("Script này chỉ hoạt động trên game Anime Rangers X (Place ID: " .. tostring(allowedPlaceId) .. ")")
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

-- Kiểm tra key
local function checkKey()
    local success, message = KeySystem.CheckSavedKey()
    if success then
        print("HT Hub | Key hợp lệ, đang tải script...")
        KeySystem.SendWebhook(game:GetService("Players").LocalPlayer.Name, "Key đã lưu", true)
        return true
    end
    
    -- Nếu không có key hợp lệ, hiển thị UI nhập key
    local keyValid = false
    
    -- Tải Rayfield
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    -- Tạo Key System UI với Rayfield
    local KeyWindow = Rayfield:CreateWindow({
        Name = "HT Hub | Anime Rangers X - Xác thực Key",
        LoadingTitle = "HT Hub",
        LoadingSubtitle = "by Dương Tuấn",
        ConfigurationSaving = {
            Enabled = false,
            FolderName = nil,
            FileName = nil
        },
        KeySystem = true,
        KeySettings = {
            Title = "HT Hub | Anime Rangers X",
            Subtitle = "Nhập key để sử dụng script",
            Note = "Liên hệ admin để lấy key",
            FileName = KeySystem.KeyFileName,
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = KeySystem.Keys
        }
    })
    
    -- Nếu đến được đây, key đã được xác thực thành công
    keyValid = true
    KeySystem.SendWebhook(game:GetService("Players").LocalPlayer.Name, "Key đã nhập", true)
    
    -- Đóng cửa sổ key
    Rayfield:Destroy()
    
    return keyValid
end

-- Xác thực key trước khi tải script
if not checkKey() then
    warn("Key không hợp lệ hoặc đã hết thời gian chờ. Script sẽ dừng.")
    return
end

-- Delay trước khi mở script
print("HT Hub | Anime Rangers X đang khởi động, vui lòng đợi 5 giây...")
wait(5)
print("Đang tải script...")

-- Tải thư viện Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
    UITheme = "Default",
    
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

-- Tạo Window với Rayfield
local Window = Rayfield:CreateWindow({
    Name = "HT Hub | Anime Rangers X",
    LoadingTitle = "HT Hub",
    LoadingSubtitle = "by Dương Tuấn",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HTHubAR",
        FileName = game:GetService("Players").LocalPlayer.Name
    },
})

-- Biến toàn cục để theo dõi UI
local isMinimized = false

-- Biến lưu trạng thái Story
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "OnePiece"
local selectedDisplayMap = reverseMapNameMapping[selectedMap] or "Voocha Village"
local selectedChapter = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoinMapEnabled = ConfigSystem.CurrentConfig.AutoJoinMap or false
local autoJoinMapLoop = nil
local storyTimeDelay = ConfigSystem.CurrentConfig.StoryTimeDelay or 5

-- Kiểm tra xem người chơi đã ở trong map chưa
local function isPlayerInMap()
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end
    
    -- Kiểm tra UnitsFolder một cách hiệu quả
    return player:FindFirstChild("UnitsFolder") ~= nil
end

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

-- Tạo tab Info
local InfoTab = Window:CreateTab("Info", 7733964719) -- Icon ID

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:CreateSection("Thông tin")

-- Thêm thông tin vào tab Info
local InfoText = InfoTab:CreateParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 2.0.0\nTrạng thái: Hoạt động\n\nScript được phát triển bởi Dương Tuấn và ghjiukliop"
})

-- Tạo tab Play
local PlayTab = Window:CreateTab("Play", 7743871480) -- Icon ID

-- Thêm section Story trong tab Play
local StorySection = PlayTab:CreateSection("Story")

-- Dropdown để chọn Map
local MapDropdown = PlayTab:CreateDropdown({
    Name = "Choose Map",
    Options = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    CurrentOption = selectedDisplayMap,
    Flag = "SelectedMap",
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
local ChapterDropdown = PlayTab:CreateDropdown({
    Name = "Choose Chapter",
    Options = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    CurrentOption = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1",
    Flag = "SelectedChapter",
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
local DifficultyDropdown = PlayTab:CreateDropdown({
    Name = "Choose Difficulty",
    Options = {"Normal", "Hard", "Nightmare"},
    CurrentOption = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal",
    Flag = "SelectedDifficulty",
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()
        
        -- Thay đổi difficulty khi người dùng chọn
        changeDifficulty(Value)
        print("Đã chọn difficulty: " .. Value)
        
        Rayfield:Notify({
            Title = "Difficulty Changed",
            Content = "Đã đổi độ khó thành: " .. Value,
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Toggle Friend Only
local FriendOnlyToggle = PlayTab:CreateToggle({
    Name = "Friend Only",
    CurrentValue = ConfigSystem.CurrentConfig.FriendOnly or false,
    Flag = "FriendOnly",
    Callback = function(Value)
        friendOnly = Value
        ConfigSystem.CurrentConfig.FriendOnly = Value
        ConfigSystem.SaveConfig()
        
        -- Toggle Friend Only khi người dùng thay đổi
        toggleFriendOnly()
        
        if Value then
            Rayfield:Notify({
                Title = "Friend Only",
                Content = "Đã bật chế độ Friend Only",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Friend Only",
                Content = "Đã tắt chế độ Friend Only",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Slider Time Delay cho Story
local StoryTimeDelaySlider = PlayTab:CreateSlider({
    Name = "Time Delay (giây)",
    Range = {1, 30},
    Increment = 1,
    Suffix = "giây",
    CurrentValue = storyTimeDelay,
    Flag = "StoryTimeDelay",
    Callback = function(Value)
        storyTimeDelay = Value
        ConfigSystem.CurrentConfig.StoryTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Story Time Delay: " .. Value .. " giây")
    end
})

-- Toggle Auto Join Map
local AutoJoinMapToggle = PlayTab:CreateToggle({
    Name = "Auto Join Map",
    CurrentValue = ConfigSystem.CurrentConfig.AutoJoinMap or false,
    Flag = "AutoJoinMap",
    Callback = function(Value)
        autoJoinMapEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinMap = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinMapEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                Rayfield:Notify({
                    Title = "Auto Join Map",
                    Content = "Đang ở trong map, Auto Join Map sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Auto Join Map",
                    Content = "Auto Join Map đã được bật, sẽ bắt đầu sau " .. storyTimeDelay .. " giây",
                    Duration = 3,
                    Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Join Map",
                Content = "Auto Join Map đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Thêm nút cập nhật trạng thái
local UpdateStatusButton = PlayTab:CreateButton({
    Name = "Cập nhật trạng thái",
    Callback = function()
        local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
        
        -- Hiển thị thông báo với trạng thái hiện tại
        Rayfield:Notify({
            Title = "Trạng thái hiện tại",
            Content = statusText,
            Duration = 3,
            Image = 4483362458
        })
        
        print("Trạng thái: " .. statusText)
    end
})

-- Tạo tab Shop
local ShopTab = Window:CreateTab("Shop", 7734056747) -- Icon ID

-- Biến lưu trạng thái Summon
local selectedSummonAmount = ConfigSystem.CurrentConfig.SummonAmount or "x1"
local selectedSummonBanner = ConfigSystem.CurrentConfig.SummonBanner or "Standard"
local autoSummonEnabled = ConfigSystem.CurrentConfig.AutoSummon or false
local autoSummonLoop = nil

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

-- Thêm section Summon trong tab Shop
local SummonSection = ShopTab:CreateSection("Summon")

-- Dropdown để chọn số lượng summon
local SummonAmountDropdown = ShopTab:CreateDropdown({
    Name = "Choose Summon Amount",
    Options = {"x1", "x10"},
    CurrentOption = ConfigSystem.CurrentConfig.SummonAmount or "x1",
    Flag = "SummonAmount",
    Callback = function(Value)
        selectedSummonAmount = Value
        ConfigSystem.CurrentConfig.SummonAmount = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn summon amount: " .. Value)
    end
})

-- Dropdown để chọn banner
local SummonBannerDropdown = ShopTab:CreateDropdown({
    Name = "Choose Banner",
    Options = {"Standard", "Rate-Up"},
    CurrentOption = ConfigSystem.CurrentConfig.SummonBanner or "Standard",
    Flag = "SummonBanner",
    Callback = function(Value)
        selectedSummonBanner = Value
        ConfigSystem.CurrentConfig.SummonBanner = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn banner: " .. Value)
    end
})

-- Nút manual summon
local SummonButton = ShopTab:CreateButton({
    Name = "Summon Once",
    Callback = function()
        performSummon()
        
        Rayfield:Notify({
            Title = "Summon",
            Content = "Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner,
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Toggle Auto Summon
local AutoSummonToggle = ShopTab:CreateToggle({
    Name = "Auto Summon",
    CurrentValue = ConfigSystem.CurrentConfig.AutoSummon or false,
    Flag = "AutoSummon",
    Callback = function(Value)
        autoSummonEnabled = Value
        ConfigSystem.CurrentConfig.AutoSummon = Value
        ConfigSystem.SaveConfig()
        
        if autoSummonEnabled then
            Rayfield:Notify({
                Title = "Auto Summon",
                Content = "Auto Summon đã được bật",
                Duration = 3,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Summon",
                Content = "Auto Summon đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
            
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end
        end
    end
})

-- Biến lưu trạng thái Quest
local autoClaimQuestEnabled = ConfigSystem.CurrentConfig.AutoClaimQuest or false
local autoClaimQuestLoop = nil

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
        
        local playerName = game:GetService("Players").LocalPlayer.Name
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

-- Thêm section Quest trong tab Shop
local QuestSection = ShopTab:CreateSection("Quest")

-- Nút Claim All Quest (manual)
local ClaimQuestButton = ShopTab:CreateButton({
    Name = "Claim All Quests",
    Callback = function()
        claimAllQuests()
        
        Rayfield:Notify({
            Title = "Quests",
            Content = "Đã claim tất cả nhiệm vụ",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Toggle Auto Claim All Quest
local AutoClaimQuestToggle = ShopTab:CreateToggle({
    Name = "Auto Claim All Quests",
    CurrentValue = ConfigSystem.CurrentConfig.AutoClaimQuest or false,
    Flag = "AutoClaimQuest",
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()
        
        if autoClaimQuestEnabled then
            Rayfield:Notify({
                Title = "Auto Claim Quests",
                Content = "Auto Claim Quests đã được bật",
                Duration = 3,
                Image = 4483362458
            })
            
            -- Tạo vòng lặp Auto Claim Quests
            spawn(function()
                while autoClaimQuestEnabled and wait(30) do -- Claim mỗi 30 giây
                    claimAllQuests()
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim Quests",
                Content = "Auto Claim Quests đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Biến lưu trạng thái Ranger Stage
local selectedRangerMap = ConfigSystem.CurrentConfig.SelectedRangerMap or "OnePiece"
local selectedRangerDisplayMap = reverseMapNameMapping[selectedRangerMap] or "Voocha Village"
local selectedActs = ConfigSystem.CurrentConfig.SelectedActs or {RangerStage1 = true}
local currentActIndex = 1  -- Lưu trữ index của Act hiện tại đang được sử dụng
local orderedActs = {}     -- Lưu trữ danh sách các Acts theo thứ tự
local rangerFriendOnly = ConfigSystem.CurrentConfig.RangerFriendOnly or false
local autoJoinRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinRanger or false
local autoJoinRangerLoop = nil
local rangerTimeDelay = ConfigSystem.CurrentConfig.RangerTimeDelay or 5

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

-- Thêm section Ranger Stage trong tab Play
local RangerSection = PlayTab:CreateSection("Ranger Stage")

-- Dropdown để chọn Map cho Ranger
local RangerMapDropdown = PlayTab:CreateDropdown({
    Name = "Choose Map",
    Options = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    CurrentOption = selectedRangerDisplayMap,
    Flag = "SelectedRangerMap",
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

-- Dropdown để chọn Act (multi)
local function updateActsDropdown()
    -- Lấy danh sách acts hiện tại
    local currentOptions = {}
    for act, isSelected in pairs(selectedActs) do
        if isSelected then
            table.insert(currentOptions, act)
        end
    end
    
    return currentOptions
end

local ActsDropdown = PlayTab:CreateDropdown({
    Name = "Choose Act",
    Options = {"RangerStage1", "RangerStage2", "RangerStage3"},
    CurrentOption = updateActsDropdown(),
    Multi = true,
    Flag = "SelectedActs",
    Callback = function(Value)
        selectedActs = Value
        ConfigSystem.CurrentConfig.SelectedActs = Value
        ConfigSystem.SaveConfig()
        
        -- Cập nhật danh sách Acts đã sắp xếp
        updateOrderedActs()
        
        -- Hiển thị thông báo khi người dùng chọn act
        local selectedActsText = ""
        for act, isSelected in pairs(Value) do
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
            Rayfield:Notify({
                Title = "Acts Selected",
                Content = "Đã chọn: " .. selectedActsText,
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Warning",
                Content = "Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Toggle Friend Only cho Ranger
local RangerFriendOnlyToggle = PlayTab:CreateToggle({
    Name = "Friend Only",
    CurrentValue = ConfigSystem.CurrentConfig.RangerFriendOnly or false,
    Flag = "RangerFriendOnly",
    Callback = function(Value)
        rangerFriendOnly = Value
        ConfigSystem.CurrentConfig.RangerFriendOnly = Value
        ConfigSystem.SaveConfig()
        
        -- Toggle Friend Only khi người dùng thay đổi
        toggleRangerFriendOnly()
        
        if Value then
            Rayfield:Notify({
                Title = "Ranger Friend Only",
                Content = "Đã bật chế độ Friend Only cho Ranger Stage",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Ranger Friend Only",
                Content = "Đã tắt chế độ Friend Only cho Ranger Stage",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Slider Time Delay cho Ranger
local RangerTimeDelaySlider = PlayTab:CreateSlider({
    Name = "Time Delay (giây)",
    Range = {1, 30},
    Increment = 1,
    Suffix = "giây",
    CurrentValue = rangerTimeDelay,
    Flag = "RangerTimeDelay",
    Callback = function(Value)
        rangerTimeDelay = Value
        ConfigSystem.CurrentConfig.RangerTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Ranger Time Delay: " .. Value .. " giây")
    end
})

-- Toggle Auto Join Ranger Stage
local AutoJoinRangerToggle = PlayTab:CreateToggle({
    Name = "Auto Join Ranger Stage",
    CurrentValue = ConfigSystem.CurrentConfig.AutoJoinRanger or false,
    Flag = "AutoJoinRanger",
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
                Rayfield:Notify({
                    Title = "Warning",
                    Content = "Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.",
                    Duration = 3,
                    Image = 4483362458
                })
                return
            end
            
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                Rayfield:Notify({
                    Title = "Auto Join Ranger Stage",
                    Content = "Đang ở trong map, Auto Join Ranger sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Auto Join Ranger Stage",
                    Content = "Auto Join Ranger Stage đã được bật, sẽ bắt đầu sau " .. rangerTimeDelay .. " giây",
                    Duration = 3,
                    Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Join Ranger Stage",
                Content = "Auto Join Ranger Stage đã được tắt",
                Duration = 3,
                Image = 4483362458
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
        Rayfield:Notify({
            Title = "Auto Leave",
            Content = "Không tìm thấy kẻ địch và agent trong 10 giây, đang teleport về lobby...",
            Duration = 3,
            Image = 4483362458
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
local AutoLeaveToggle = PlayTab:CreateToggle({
    Name = "Auto Leave",
    CurrentValue = ConfigSystem.CurrentConfig.AutoLeave or false,
    Flag = "AutoLeave",
    Callback = function(Value)
        autoLeaveEnabled = Value
        ConfigSystem.CurrentConfig.AutoLeave = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto Leave",
                Content = "Auto Leave đã được bật. Sẽ tự động rời map nếu không có kẻ địch và agent trong 10 giây",
                Duration = 3,
                Image = 4483362458
            })
            
            -- Hủy vòng lặp cũ nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end
            
            -- Tạo vòng lặp tối ưu để kiểm tra folders
            spawn(function()
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
            Rayfield:Notify({
                Title = "Auto Leave",
                Content = "Auto Leave đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
            
            -- Hủy vòng lặp nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end
        end
    end
})

-- Biến lưu trạng thái Boss Event
local autoBossEventEnabled = ConfigSystem.CurrentConfig.AutoBossEvent or false
local autoBossEventLoop = nil
local bossEventTimeDelay = ConfigSystem.CurrentConfig.BossEventTimeDelay or 5

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

-- Thêm section Boss Event trong tab Play
local BossEventSection = PlayTab:CreateSection("Boss Event")

-- Slider Time Delay cho Boss Event
local BossEventTimeDelaySlider = PlayTab:CreateSlider({
    Name = "Time Delay (giây)",
    Range = {1, 30},
    Increment = 1,
    Suffix = "giây",
    CurrentValue = bossEventTimeDelay,
    Flag = "BossEventTimeDelay",
    Callback = function(Value)
        bossEventTimeDelay = Value
        ConfigSystem.CurrentConfig.BossEventTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Boss Event Time Delay: " .. Value .. " giây")
    end
})

-- Toggle Auto Join Boss Event
local AutoBossEventToggle = PlayTab:CreateToggle({
    Name = "Auto Boss Event",
    CurrentValue = ConfigSystem.CurrentConfig.AutoBossEvent or false,
    Flag = "AutoBossEvent",
    Callback = function(Value)
        autoBossEventEnabled = Value
        ConfigSystem.CurrentConfig.AutoBossEvent = Value
        ConfigSystem.SaveConfig()
        
        if autoBossEventEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                Rayfield:Notify({
                    Title = "Auto Boss Event",
                    Content = "Đang ở trong map, Auto Boss Event sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Auto Boss Event",
                    Content = "Auto Boss Event đã được bật, sẽ bắt đầu sau " .. bossEventTimeDelay .. " giây",
                    Duration = 3,
                    Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Boss Event",
                Content = "Auto Boss Event đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Biến lưu trạng thái Challenge
local autoChallengeEnabled = ConfigSystem.CurrentConfig.AutoChallenge or false
local autoChallengeLoop = nil
local challengeTimeDelay = ConfigSystem.CurrentConfig.ChallengeTimeDelay or 5

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

-- Thêm section Challenge trong tab Play
local ChallengeSection = PlayTab:CreateSection("Challenge")

-- Slider Time Delay cho Challenge
local ChallengeTimeDelaySlider = PlayTab:CreateSlider({
    Name = "Time Delay (giây)",
    Range = {1, 30},
    Increment = 1,
    Suffix = "giây",
    CurrentValue = challengeTimeDelay,
    Flag = "ChallengeTimeDelay",
    Callback = function(Value)
        challengeTimeDelay = Value
        ConfigSystem.CurrentConfig.ChallengeTimeDelay = Value
        ConfigSystem.SaveConfig()
        print("Đã đặt Challenge Time Delay: " .. Value .. " giây")
    end
})

-- Toggle Auto Challenge
local AutoChallengeToggle = PlayTab:CreateToggle({
    Name = "Auto Challenge",
    CurrentValue = ConfigSystem.CurrentConfig.AutoChallenge or false,
    Flag = "AutoChallenge",
    Callback = function(Value)
        autoChallengeEnabled = Value
        ConfigSystem.CurrentConfig.AutoChallenge = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                Rayfield:Notify({
                    Title = "Auto Challenge",
                    Content = "Đang ở trong map, Auto Challenge sẽ hoạt động khi bạn rời khỏi map",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Auto Challenge",
                    Content = "Auto Challenge đã được bật, sẽ bắt đầu sau " .. challengeTimeDelay .. " giây",
                    Duration = 3,
                    Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Challenge",
                Content = "Auto Challenge đã được tắt",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Nút Join Challenge (manual)
local JoinChallengeButton = PlayTab:CreateButton({
    Name = "Join Challenge Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đã ở trong map
        if isPlayerInMap() then
            Rayfield:Notify({
                Title = "Join Challenge",
                Content = "Bạn đang ở trong map, không thể tham gia Challenge mới",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local success = joinChallenge()
        
        if success then
            Rayfield:Notify({
                Title = "Challenge",
                Content = "Đang tham gia Challenge",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Challenge",
                Content = "Không thể tham gia Challenge. Vui lòng thử lại sau.",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Tạo tab In-Game
local InGameTab = Window:CreateTab("In-Game", 7733799901) -- Icon ID

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

-- Thêm section In-Game Controls
local InGameSection = InGameTab:CreateSection("Game Controls")

-- Biến lưu trạng thái Auto TP Lobby
local autoTPLobbyEnabled = ConfigSystem.CurrentConfig.AutoTPLobby or false
local autoTPLobbyDelay = ConfigSystem.CurrentConfig.AutoTPLobbyDelay or 10 -- Mặc định 10 phút
local autoTPLobbyLoop = nil

-- Hàm để teleport về lobby
local function teleportToLobby()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        
        -- Hiển thị thông báo trước khi teleport
        Rayfield:Notify({
            Title = "Auto TP Lobby",
            Content = "Đang teleport về lobby...",
            Duration = 3,
            Image = 4483362458
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
local AutoTPLobbyDelaySlider = InGameTab:CreateSlider({
    Name = "Auto TP Lobby Delay (phút)",
    Range = {1, 60},
    Increment = 1,
    Suffix = "phút",
    CurrentValue = autoTPLobbyDelay,
    Flag = "AutoTPLobbyDelay",
    Callback = function(Value)
        autoTPLobbyDelay = Value
        ConfigSystem.CurrentConfig.AutoTPLobbyDelay = Value
        ConfigSystem.SaveConfig()
        
        Rayfield:Notify({
            Title = "Auto TP Lobby",
            Content = "Đã đặt thời gian delay: " .. Value .. " phút",
            Duration = 2,
            Image = 4483362458
        })
        
        print("Đã đặt Auto TP Lobby Delay: " .. Value .. " phút")
    end
})

-- Toggle Auto TP Lobby
local AutoTPLobbyToggle = InGameTab:CreateToggle({
    Name = "Auto TP Lobby",
    CurrentValue = autoTPLobbyEnabled,
    Flag = "AutoTPLobby",
    Callback = function(Value)
        autoTPLobbyEnabled = Value
        ConfigSystem.CurrentConfig.AutoTPLobby = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto TP Lobby",
                Content = "Auto TP Lobby đã được bật, sẽ teleport sau " .. autoTPLobbyDelay .. " phút",
                Duration = 3,
                Image = 4483362458
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
                        Rayfield:Notify({
                            Title = "Auto TP Lobby",
                            Content = "Sẽ teleport về lobby trong 1 phút nữa",
                            Duration = 3,
                            Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto TP Lobby",
                Content = "Auto TP Lobby đã được tắt",
                Duration = 3,
                Image = 4483362458
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
local TPLobbyButton = InGameTab:CreateButton({
    Name = "TP Lobby Now",
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
local AutoPlayToggle = InGameTab:CreateToggle({
    Name = "Auto Play",
    CurrentValue = ConfigSystem.CurrentConfig.AutoPlay or false,
    Flag = "AutoPlay",
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
                Rayfield:Notify({
                    Title = "Auto Play",
                    Content = "Auto Play đã được bật",
                    Duration = 2,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Auto Play",
                    Content = "Auto Play đã được tắt",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        else
            Rayfield:Notify({
                Title = "Auto Play",
                Content = "Trạng thái Auto Play đã phù hợp (" .. (Value and "bật" or "tắt") .. ")",
                Duration = 2,
                Image = 4483362458
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
local AutoRetryToggle = InGameTab:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = ConfigSystem.CurrentConfig.AutoRetry or false,
    Flag = "AutoRetry",
    Callback = function(Value)
        autoRetryEnabled = Value
        ConfigSystem.CurrentConfig.AutoRetry = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto Retry",
                Content = "Auto Retry đã được bật",
                Duration = 2,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Retry",
                Content = "Auto Retry đã được tắt",
                Duration = 2,
                Image = 4483362458
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
local AutoNextToggle = InGameTab:CreateToggle({
    Name = "Auto Next",
    CurrentValue = ConfigSystem.CurrentConfig.AutoNext or false,
    Flag = "AutoNext",
    Callback = function(Value)
        autoNextEnabled = Value
        ConfigSystem.CurrentConfig.AutoNext = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto Next",
                Content = "Auto Next đã được bật",
                Duration = 2,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Next",
                Content = "Auto Next đã được tắt",
                Duration = 2,
                Image = 4483362458
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
local AutoVoteToggle = InGameTab:CreateToggle({
    Name = "Auto Vote",
    CurrentValue = ConfigSystem.CurrentConfig.AutoVote or false,
    Flag = "AutoVote",
    Callback = function(Value)
        autoVoteEnabled = Value
        ConfigSystem.CurrentConfig.AutoVote = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto Vote",
                Content = "Auto Vote đã được bật, sẽ bắt đầu sau 15 giây",
                Duration = 3,
                Image = 4483362458
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
                    Rayfield:Notify({
                        Title = "Auto Vote",
                        Content = "Auto Vote bắt đầu hoạt động",
                        Duration = 2,
                        Image = 4483362458
                    })
                    
                    -- Bắt đầu vòng lặp sau khi delay
                    while autoVoteEnabled and wait(3) do -- Gửi yêu cầu mỗi 3 giây
                        toggleAutoVote()
                    end
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Vote",
                Content = "Auto Vote đã được tắt",
                Duration = 2,
                Image = 4483362458
            })
            
            -- Hủy vòng lặp nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
        end
    end
})

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
local UnitsUpdateSection = InGameTab:CreateSection("Units Update")

-- Tạo 6 dropdown cho 6 slot
for i = 1, 6 do
    local SlotLevelDropdown = InGameTab:CreateDropdown({
        Name = "Slot " .. i .. " Level",
        Options = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
        CurrentOption = tostring(unitSlotLevels[i]),
        Flag = "Slot" .. i .. "Level",
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
local AutoUpdateToggle = InGameTab:CreateToggle({
    Name = "Auto Update",
    CurrentValue = ConfigSystem.CurrentConfig.AutoUpdate or false,
    Flag = "AutoUpdate",
    Callback = function(Value)
        autoUpdateEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdate = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()
            
            Rayfield:Notify({
                Title = "Auto Update",
                Content = "Auto Update đã được bật",
                Duration = 2,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Update",
                Content = "Auto Update đã được tắt",
                Duration = 2,
                Image = 4483362458
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
local AutoUpdateRandomToggle = InGameTab:CreateToggle({
    Name = "Auto Update Random",
    CurrentValue = ConfigSystem.CurrentConfig.AutoUpdateRandom or false,
    Flag = "AutoUpdateRandom",
    Callback = function(Value)
        autoUpdateRandomEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdateRandom = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()
            
            Rayfield:Notify({
                Title = "Auto Update Random",
                Content = "Auto Update Random đã được bật",
                Duration = 2,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Update Random",
                Content = "Auto Update Random đã được tắt",
                Duration = 2,
                Image = 4483362458
            })
            
            -- Hủy vòng lặp nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end
        end
    end
})

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
local RemoveAnimationToggle = InGameTab:CreateToggle({
    Name = "Remove Animation",
    CurrentValue = ConfigSystem.CurrentConfig.RemoveAnimation or true,
    Flag = "RemoveAnimation",
    Callback = function(Value)
        removeAnimationEnabled = Value
        ConfigSystem.CurrentConfig.RemoveAnimation = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Remove Animation",
                Content = "Remove Animation đã được bật",
                Duration = 2,
                Image = 4483362458
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
            Rayfield:Notify({
                Title = "Remove Animation",
                Content = "Remove Animation đã được tắt",
                Duration = 2,
                Image = 4483362458
            })
            
            -- Hủy vòng lặp nếu có
            if removeAnimationLoop then
                removeAnimationLoop:Disconnect()
                removeAnimationLoop = nil
            end
        end
    end
})

-- Tạo tab Settings
local SettingsTab = Window:CreateTab("Settings", 6031280882) -- Icon ID

-- Thêm section thiết lập trong tab Settings
local SettingsSection = SettingsTab:CreateSection("Thiết lập")

-- Biến lưu trạng thái Auto Scan Units
local autoScanUnitsEnabled = ConfigSystem.CurrentConfig.AutoScanUnits or true

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

-- Thêm section AFK vào tab Settings
local AFKSection = SettingsTab:CreateSection("AFK Settings")

-- Toggle Anti AFK
local AntiAFKToggle = SettingsTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = antiAFKEnabled,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được bật",
                Duration = 2,
                Image = 4483362458
            })
            setupAntiAFK()
        else
            Rayfield:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được tắt",
                Duration = 2,
                Image = 4483362458
            })
            -- Ngắt kết nối nếu có
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})

-- Kiểm tra trạng thái AFKWorld
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

-- Biến lưu trạng thái Auto Join AFK
local autoJoinAFKEnabled = ConfigSystem.CurrentConfig.AutoJoinAFK or false
local autoJoinAFKLoop = nil

-- Toggle Auto Join AFK
local AutoJoinAFKToggle = SettingsTab:CreateToggle({
    Name = "Auto Join AFK",
    CurrentValue = ConfigSystem.CurrentConfig.AutoJoinAFK or false,
    Flag = "AutoJoinAFK",
    Callback = function(Value)
        autoJoinAFKEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAFK = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra trạng thái AFKWorld
            local isInAFKWorld = checkAFKWorldState()
            
            Rayfield:Notify({
                Title = "Auto Join AFK",
                Content = "Auto Join AFK đã được bật",
                Duration = 2,
                Image = 4483362458
            })
            
            -- Nếu không ở trong AFKWorld, teleport ngay lập tức
            if not isInAFKWorld then
                joinAFKWorld()
            else
                Rayfield:Notify({
                    Title = "AFKWorld",
                    Content = "Bạn đã ở trong AFKWorld",
                    Duration = 2,
                    Image = 4483362458
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
            Rayfield:Notify({
                Title = "Auto Join AFK",
                Content = "Auto Join AFK đã được tắt",
                Duration = 2,
                Image = 4483362458
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
local JoinAFKButton = SettingsTab:CreateButton({
    Name = "Join AFK Now",
    Callback = function()
        local isInAFKWorld = checkAFKWorldState()
        
        if isInAFKWorld then
            Rayfield:Notify({
                Title = "AFKWorld",
                Content = "Bạn đã ở trong AFKWorld",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        joinAFKWorld()
        
        Rayfield:Notify({
            Title = "AFKWorld",
            Content = "Đang teleport đến AFKWorld...",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Tạo tab Webhook
local WebhookTab = Window:CreateTab("Webhook", 7734058803) -- Icon ID

-- Thêm section Webhook
local WebhookSection = WebhookTab:CreateSection("Discord Webhook")

-- Biến lưu trạng thái Webhook
local webhookURL = ConfigSystem.CurrentConfig.WebhookURL or ""
local autoSendWebhookEnabled = ConfigSystem.CurrentConfig.AutoSendWebhook or false

-- Input để nhập Webhook URL
local WebhookInput = WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Nhập Discord Webhook URL vào đây",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        webhookURL = Text
        ConfigSystem.CurrentConfig.WebhookURL = Text
        ConfigSystem.SaveConfig()
        
        Rayfield:Notify({
            Title = "Webhook URL",
            Content = "Đã lưu Webhook URL",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Toggle Auto Send Webhook
local AutoSendWebhookToggle = WebhookTab:CreateToggle({
    Name = "Auto Send Webhook",
    CurrentValue = ConfigSystem.CurrentConfig.AutoSendWebhook or false,
    Flag = "AutoSendWebhook",
    Callback = function(Value)
        autoSendWebhookEnabled = Value
        ConfigSystem.CurrentConfig.AutoSendWebhook = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            Rayfield:Notify({
                Title = "Auto Send Webhook",
                Content = "Auto Send Webhook đã được bật",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Auto Send Webhook",
                Content = "Auto Send Webhook đã được tắt",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Nút Test Webhook
local TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        if webhookURL == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Bạn cần nhập Webhook URL trước",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local success, error = pcall(function()
            local HttpService = game:GetService("HttpService")
            local data = {
                ["content"] = "",
                ["embeds"] = {{
                    ["title"] = "Anime Rangers X - Test Webhook",
                    ["description"] = "Webhook test thành công!",
                    ["type"] = "rich",
                    ["color"] = 65280,
                    ["fields"] = {
                        {
                            ["name"] = "Username",
                            ["value"] = game:GetService("Players").LocalPlayer.Name,
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Time",
                            ["value"] = os.date("%Y-%m-%d %H:%M:%S"),
                            ["inline"] = true
                        }
                    }
                }}
            }
            
            HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data))
        end)
        
        if success then
            Rayfield:Notify({
                Title = "Webhook Test",
                Content = "Đã gửi webhook test thành công!",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Webhook Test Error",
                Content = "Lỗi: " .. tostring(error),
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Thiết lập các vòng lặp tối ưu
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

-- Tự động đồng bộ trạng thái từ game khi khởi động
spawn(function()
    wait(3) -- Đợi game load
    
    -- Thiết lập Anti AFK
    setupAntiAFK()
    
    -- Nếu Auto Join AFK được bật và người chơi không ở trong AFKWorld
    if autoJoinAFKEnabled and not checkAFKWorldState() then
        joinAFKWorld()
    end
    
    -- Thiết lập các vòng lặp tối ưu
    setupOptimizedLoops()
    
    -- Thông báo khi script đã sẵn sàng
    Rayfield:Notify({
        Title = "HT Hub | Anime Rangers X",
        Content = "Script đã được tải thành công!",
        Duration = 3,
        Image = 4483362458
    })
end)
