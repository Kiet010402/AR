-- Anime Rangers X Script

-- Tải thư viện Fluent từ Arise
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
    local service = nil
    pcall(function()
        service = game:GetService(serviceName)
    end)
    return service
end

-- Utility function để kiểm tra và lấy child một cách an toàn
local function safeGetChild(parent, childName, waitTime)
    if not parent then return nil end
    
    local child = nil
    waitTime = waitTime or 1
    
    local success = pcall(function()
        child = parent:FindFirstChild(childName)
        if not child and waitTime > 0 then
            child = parent:WaitForChild(childName, waitTime)
        end
    end)
    
    return child
end

-- Utility function để lấy đường dẫn đầy đủ một cách an toàn
local function safeGetPath(startPoint, path, waitTime)
    waitTime = waitTime or 1
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
    UITheme = "Dark",
    
    -- Cài đặt Shop/Summon
    SummonAmount = "x1",
    SummonBanner = "Standard",
    AutoSummon = false,
    
    -- Cài đặt Quest
    AutoClaimQuest = false
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

-- Bắt sự kiện phím để kích hoạt minimize
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        Window.Minimize()
    end
end)

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:AddSection("Thông tin")

InfoSection:AddParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 1.0.0\nTrạng thái: Hoạt động"
})

InfoSection:AddParagraph({
    Title = "Người phát triển",
    Content = "Script được phát triển bởi HT Hub"
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
    for _, tab in pairs({InfoTab, ShopTab, SettingsTab}) do
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

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "HT Hub | Anime Rangers X",
    Content = "Script đã tải thành công! Đã tải cấu hình cho " .. playerName,
    Duration = 3
})

print("Anime Rangers X Script has been loaded!")
