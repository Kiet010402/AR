-- Anime Rangers X Script

-- Đảm bảo game đã tải xong trước khi thực thi script
repeat task.wait(0.5) until game:IsLoaded()

-- Đợi thêm 2 giây để đảm bảo các dịch vụ đã sẵn sàng
task.wait(2)

-- Hàm báo lỗi an toàn
local function safeWarn(...)
    pcall(function() warn(...) end)
end

-- Tải thư viện Fluent từ Arise
local Fluent, SaveManager, InterfaceManager

local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    safeWarn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

if not Fluent then
    safeWarn("Không thể tải thư viện Fluent. Vui lòng kiểm tra kết nối internet hoặc executor.")
    return
end

-- Utility function để kiểm tra và lấy service/object một cách an toàn, với thời gian chờ dài hơn
local function safeGetService(serviceName)
    local service = nil
    pcall(function()
        service = game:GetService(serviceName)
    end)
    return service
end

-- Utility function để kiểm tra và lấy child một cách an toàn, với thời gian chờ dài hơn
local function safeGetChild(parent, childName, waitTime)
    if not parent then return nil end
    if type(parent) ~= "userdata" then return nil end
    
    local child = nil
    waitTime = waitTime or 3 -- Tăng thời gian chờ mặc định lên 3 giây
    
    local success = pcall(function()
        -- Thử FindFirstChild trước
        child = parent:FindFirstChild(childName)
        
        -- Nếu không tìm thấy và có thời gian chờ, thử WaitForChild
        if not child and waitTime > 0 then
            child = parent:WaitForChild(childName, waitTime)
        end
    end)
    
    return child
end

-- Utility function để lấy đường dẫn đầy đủ một cách an toàn
local function safeGetPath(startPoint, path, waitTime)
    if not startPoint then return nil end
    
    waitTime = waitTime or 3 -- Tăng thời gian chờ mặc định
    local current = startPoint
    
    for _, name in ipairs(path) do
        if not current then 
            safeWarn("Không tìm thấy path: " .. table.concat(path, " > ") .. " tại: " .. name)
            return nil 
        end
        
        -- Chờ lâu hơn cho các thành phần quan trọng
        current = safeGetChild(current, name, waitTime)
    end
    
    return current
end

-- Hàm tìm kiếm services cần thiết
local ReplicatedStorage = safeGetService("ReplicatedStorage")
local Players = safeGetService("Players")
local LocalPlayer = Players and Players.LocalPlayer
local UserInputService = safeGetService("UserInputService")
local HttpService = safeGetService("HttpService")

-- Đảm bảo các services cơ bản đã được tải
if not ReplicatedStorage or not Players or not LocalPlayer or not UserInputService or not HttpService then
    safeWarn("Không thể tải các dịch vụ cần thiết. Vui lòng thử lại sau.")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubARConfig_" .. LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Các cài đặt mặc định
    UITheme = "Dark",
    
    -- Cài đặt Shop/Summon
    SummonAmount = "x1",
    SummonBanner = "Standard",
    AutoSummon = false,
    
    -- Cài đặt Quest
    AutoClaimQuest = false,
    
    -- Cài đặt Story
    SelectedMap = "OnePiece",
    SelectedChapter = "Chapter1",
    FriendOnly = false,
    AutoJoinMap = false
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, HttpService:JSONEncode(ConfigSystem.CurrentConfig))
    end)
    
    if success then
        print("Đã lưu cấu hình thành công!")
    else
        safeWarn("Lưu cấu hình thất bại:", err)
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
        local data = HttpService:JSONDecode(content)
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
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoinMapEnabled = ConfigSystem.CurrentConfig.AutoJoinMap or false
local autoJoinMapLoop = nil

-- Tọa độ xác nhận cho mỗi map (để kiểm tra nếu người chơi đã ở trong map)
local mapSpawnCoordinates = {
    ["Voocha Village"] = {
        center = Vector3.new(200.037, 51.664, 156.521),
        radius = 50 -- Bán kính xung quanh tọa độ trung tâm để xác nhận
    },
    ["Green Planet"] = {
        center = Vector3.new(200.037, 51.664, 156.521), -- Thay bằng tọa độ thực tế
        radius = 50 
    },
    ["Demon Forest"] = {
        center = Vector3.new(200.037, 51.664, 156.521), -- Thay bằng tọa độ thực tế
        radius = 50
    },
    ["Leaf Village"] = {
        center = Vector3.new(200.037, 51.664, 156.521), -- Thay bằng tọa độ thực tế
        radius = 50
    },
    ["Z City"] = {
        center = Vector3.new(200.037, 51.664, 156.521), -- Thay bằng tọa độ thực tế
        radius = 50
    }
}

-- Thông tin người chơi
local playerName = LocalPlayer.Name

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
    Icon = "rbxassetid://7743878070"
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

-- Tạo logo UI để mở lại khi đã thu nhỏ
local function CreateLogoUI()
    local success, UI = pcall(function()
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
        Button.Image = "rbxassetid://10723424401"
        Button.ImageTransparency = 0.1
        Button.Active = true
        Button.Draggable = true
        
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = Button
        
        -- Ẩn logo ban đầu
        UI.Enabled = false
        
        -- Khi click vào logo
        Button.MouseButton1Click:Connect(function()
            UI.Enabled = false
            isMinimized = false
            
            -- Hiển thị lại UI chính
            if Window and Window.Minimize then
                Window.Minimize()
            end
        end)
        
        return UI
    end)
    
    if not success then
        safeWarn("Lỗi khi tạo logo UI: " .. tostring(UI))
        return nil
    end
    
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
    end
    
    -- Gọi hàm minimize gốc
    oldMinimize()
end

-- Bắt sự kiện phím để kích hoạt minimize một cách an toàn
if UserInputService then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
            Window.Minimize()
        end
    end)
end

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:AddSection("Thông tin")

InfoSection:AddParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 1.0.1\nTrạng thái: Hoạt động"
})

InfoSection:AddParagraph({
    Title = "Người phát triển",
    Content = "Script được phát triển bởi HT Hub"
})

-- Thêm section Story trong tab Play
local StorySection = PlayTab:AddSection("Story")

-- Hàm để kiểm tra xem người chơi có đang ở trong map đã chọn không
local function isPlayerInSelectedMap()
    local player = LocalPlayer
    if not player or not player.Character then return false end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local playerPos = hrp.Position
    
    -- Tìm thông tin tọa độ cho map đã chọn
    local mapInfo = mapSpawnCoordinates[selectedDisplayMap]
    if not mapInfo then return false end
    
    -- Kiểm tra khoảng cách từ vị trí người chơi đến trung tâm map
    local distance = (playerPos - mapInfo.center).Magnitude
    return distance <= mapInfo.radius
end

-- Hàm để thay đổi map
local function changeWorld(worldDisplay)
    local success, err = pcall(function()
        local Event = safeGetPath(ReplicatedStorage, {"Remote", "Server", "PlayRoom", "Event"}, 4)
        
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
            safeWarn("Không tìm thấy Event để đổi map")
        end
    end)
    
    if not success then
        safeWarn("Lỗi khi đổi map: " .. tostring(err))
    end
end

-- Hàm để thay đổi chapter
local function changeChapter(map, chapter)
    local success, err = pcall(function()
        local Event = safeGetPath(ReplicatedStorage, {"Remote", "Server", "PlayRoom", "Event"}, 4)
        
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
            safeWarn("Không tìm thấy Event để đổi chapter")
        end
    end)
    
    if not success then
        safeWarn("Lỗi khi đổi chapter: " .. tostring(err))
    end
end

-- Hàm để toggle Friend Only
local function toggleFriendOnly()
    local success, err = pcall(function()
        local Event = safeGetPath(ReplicatedStorage, {"Remote", "Server", "PlayRoom", "Event"}, 4)
        
        if Event then
            local args = {
                [1] = "Change-FriendOnly"
            }
            
            Event:FireServer(unpack(args))
            print("Đã toggle Friend Only")
        else
            safeWarn("Không tìm thấy Event để toggle Friend Only")
        end
    end)
    
    if not success then
        safeWarn("Lỗi khi toggle Friend Only: " .. tostring(err))
    end
end

-- Hàm để tự động tham gia map
local function joinMap()
    -- Kiểm tra xem người chơi đã ở trong map được chọn chưa
    if isPlayerInSelectedMap() then
        print("Người chơi đã ở trong map " .. selectedDisplayMap .. ". Không cần join lại.")
        return
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(ReplicatedStorage, {"Remote", "Server", "PlayRoom", "Event"}, 4)
        
        if not Event then
            safeWarn("Không tìm thấy Event để join map")
            return
        end
        
        -- 1. Create
        Event:FireServer("Create")
        task.wait(0.5)
        
        -- 2. Friend Only (nếu được bật)
        if friendOnly then
            Event:FireServer("Change-FriendOnly")
            task.wait(0.5)
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
        task.wait(0.5)
        
        -- 3.2 Đổi Chapter
        local args2 = {
            [1] = "Change-Chapter",
            [2] = {
                ["Chapter"] = selectedMap .. "_" .. selectedChapter
            }
        }
        Event:FireServer(unpack(args2))
        task.wait(0.5)
        
        -- 4. Submit
        Event:FireServer("Submit")
        task.wait(1)
        
        -- 5. Start
        Event:FireServer("Start")
        
        print("Đã join map: " .. selectedMap .. "_" .. selectedChapter)
    end)
    
    if not success then
        safeWarn("Lỗi khi join map: " .. tostring(err))
    end
end

-- Hiển thị tọa độ hiện tại (chỉ để debug)
StorySection:AddButton({
    Title = "Show Current Position",
    Callback = function()
        local player = LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = player.Character.HumanoidRootPart.Position
            print("Tọa độ hiện tại: X=" .. pos.X .. ", Y=" .. pos.Y .. ", Z=" .. pos.Z)
            
            Fluent:Notify({
                Title = "Current Position",
                Content = "X=" .. string.format("%.2f", pos.X) .. ", Y=" .. string.format("%.2f", pos.Y) .. ", Z=" .. string.format("%.2f", pos.Z),
                Duration = 5
            })
            
            -- Cập nhật tọa độ cho map hiện tại để sử dụng sau này
            if mapSpawnCoordinates[selectedDisplayMap] then
                mapSpawnCoordinates[selectedDisplayMap].center = pos
                print("Đã cập nhật tọa độ cho map " .. selectedDisplayMap)
            end
        else
            print("Không thể lấy tọa độ người chơi")
        end
    end
})

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
            -- Kiểm tra xem người chơi đã ở trong map được chọn chưa
            if isPlayerInSelectedMap() then
                Fluent:Notify({
                    Title = "Auto Join Map",
                    Content = "Bạn đã ở trong map " .. selectedDisplayMap .. ". Auto Join Map sẽ không kích hoạt.",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Auto Join Map",
                    Content = "Auto Join Map đã được bật",
                    Duration = 3
                })
                
                -- Tạo vòng lặp Auto Join Map
                spawn(function()
                    while autoJoinMapEnabled and task.wait(10) do -- Thử join map mỗi 10 giây
                        if not isPlayerInSelectedMap() then
                            joinMap()
                        else
                            print("Người chơi đã ở trong map " .. selectedDisplayMap .. ". Không cần join lại.")
                        end
                    end
                end)
            end
        else
            Fluent:Notify({
                Title = "Auto Join Map",
                Content = "Auto Join Map đã được tắt",
                Duration = 3
            })
        end
    end
})

-- Nút Join Map (manual)
StorySection:AddButton({
    Title = "Join Map Now",
    Callback = function()
        -- Kiểm tra xem người chơi đã ở trong map được chọn chưa
        if isPlayerInSelectedMap() then
            Fluent:Notify({
                Title = "Join Map",
                Content = "Bạn đã ở trong map " .. selectedDisplayMap .. ". Không cần join lại.",
                Duration = 3
            })
            return
        end
        
        joinMap()
        
        Fluent:Notify({
            Title = "Join Map",
            Content = "Đang tham gia map: " .. selectedDisplayMap .. " - " .. selectedChapter,
            Duration = 2
        })
    end
})

-- Thêm section Summon trong tab Shop
local SummonSection = ShopTab:AddSection("Summon")

-- Hàm thực hiện summon
local function performSummon()
    -- An toàn kiểm tra Remote có tồn tại không
    local success, err = pcall(function()
        local Remote = safeGetPath(ReplicatedStorage, {"Remote", "Server", "Gambling", "UnitsGacha"}, 4)
        
        if Remote then
            local args = {
                [1] = selectedSummonAmount,
                [2] = selectedSummonBanner,
                [3] = {}
            }
            
            Remote:FireServer(unpack(args))
            print("Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner)
        else
            safeWarn("Không tìm thấy Remote UnitsGacha")
        end
    end)
    
    if not success then
        safeWarn("Lỗi khi summon: " .. tostring(err))
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
                pcall(function() autoSummonLoop:Disconnect() end)
                autoSummonLoop = nil
            end
            
            -- Sử dụng spawn thay vì coroutine
            spawn(function()
                while autoSummonEnabled and task.wait(2) do -- Summon mỗi 2 giây
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
                pcall(function() autoSummonLoop:Disconnect() end)
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
        if not ReplicatedStorage then
            safeWarn("Không tìm thấy ReplicatedStorage")
            return
        end
        
        local PlayerData = safeGetChild(ReplicatedStorage, "Player_Data", 4)
        if not PlayerData then
            safeWarn("Không tìm thấy Player_Data")
            return
        end
        
        local PlayerFolder = safeGetChild(PlayerData, playerName, 4)
        if not PlayerFolder then
            safeWarn("Không tìm thấy dữ liệu người chơi: " .. playerName)
            return
        end
        
        local DailyQuest = safeGetChild(PlayerFolder, "DailyQuest", 4)
        if not DailyQuest then
            safeWarn("Không tìm thấy DailyQuest")
            return
        end
        
        -- Lấy đường dẫn đến QuestEvent
        local QuestEvent = safeGetPath(ReplicatedStorage, {"Remote", "Server", "Gameplay", "QuestEvent"}, 4)
        if not QuestEvent then
            safeWarn("Không tìm thấy QuestEvent")
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
                task.wait(0.2) -- Chờ một chút giữa các lần claim để tránh lag
            end
        end
    end)
    
    if not success then
        safeWarn("Lỗi khi claim quest: " .. tostring(err))
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
                while autoClaimQuestEnabled and task.wait(30) do -- Claim mỗi 30 giây
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
        while task.wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    pcall(function()
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
    end)
end

-- Tích hợp với SaveManager
if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    -- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
    InterfaceManager:SetFolder("HTHubAR")
    SaveManager:SetFolder("HTHubAR/" .. playerName)
end

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

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "HT Hub | Anime Rangers X",
    Content = "Script đã tải thành công! Đã tải cấu hình cho " .. playerName,
    Duration = 3
})

print("Anime Rangers X Script has been loaded!")
