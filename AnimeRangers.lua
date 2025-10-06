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
    -- Map Settings
    SelectedMap = "namek",
    SelectedAct = "Act 1",
    SelectedDifficulty = "normal",
    FriendOnly = false,
    AutoJoin = false,
    AutoMatching = false,
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
        ConfigSystem.CurrentConfig = {}
        for k, v in pairs(ConfigSystem.DefaultConfig) do
            ConfigSystem.CurrentConfig[k] = v
        end
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Biến lưu trạng thái của tab Maps
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "namek"
local selectedAct = ConfigSystem.CurrentConfig.SelectedAct or "Act 1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoin = ConfigSystem.CurrentConfig.AutoJoin or false
local autoMatching = ConfigSystem.CurrentConfig.AutoMatching or false

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
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tab Main
-- Hàm Auto Join
local function executeAutoJoin()
    if autoJoin then
        local success, err = pcall(function()
            -- Bước 1: Join lobby
            local args = {"P1"}
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args))
            
            wait(1) -- Đợi 1 giây
            
            -- Bước 2: Lock level
            local actNumber = string.match(selectedAct, "%d+") -- Lấy số từ "Act X"
            local levelName = ""
            
            if selectedMap == "Entertainment_district" then
                levelName = "Entertainment_district_" .. actNumber
            else
                levelName = selectedMap .. "_level_" .. actNumber
            end
            
            local difficulty = string.upper(string.sub(selectedDifficulty, 1, 1)) .. string.sub(selectedDifficulty, 2) -- Normal/Hard
            
            local args = {
                "P1",
                levelName,
                friendOnly,
                difficulty
            }
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
            
            wait(1) -- Đợi 1 giây
            
            -- Bước 3: Start game
            local args = {"P1"}
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer(unpack(args))
        end)
        
        if not success then
            warn("Lỗi Auto Join: " .. tostring(err))
        else
            print("Auto Join executed successfully")
        end
    end
end

-- Hàm Auto Matching
local function executeAutoMatching()
    if autoMatching then
        local success, err = pcall(function()
            -- Bước 1: Join lobby
            local args = {"P1"}
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args))
            
            wait(1) -- Đợi 1 giây
            
            -- Bước 2: Request matchmaking
            local difficulty = string.upper(string.sub(selectedDifficulty, 1, 1)) .. string.sub(selectedDifficulty, 2) -- Normal/Hard
            
            local args = {
                "namek_level_1",
                {
                    Difficulty = difficulty
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer(unpack(args))
        end)
        
        if not success then
            warn("Lỗi Auto Matching: " .. tostring(err))
        else
            print("Auto Matching executed successfully")
        end
    end
end

-- Section Story trong tab Maps
local StorySection = MapsTab:AddSection("Story")

-- Dropdown Select Map
StorySection:AddDropdown("MapDropdown", {
    Title = "Select Map",
    Description = "Chọn map để chơi",
    Options = {"namek", "marineford", "karakura", "shibuya", "Entertainment_district"},
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
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"},
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
    Options = {"normal", "hard"},
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
            -- Thực hiện Auto Join
            executeAutoJoin()
        else
            print("Auto Join Disabled - Đã tắt tự động tham gia game")
        end
    end
})

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
            -- Thực hiện Auto Matching
            executeAutoMatching()
        else
            print("Auto Matching Disabled - Đã tắt tự động tìm kiếm game")
        end
    end
})

-- Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

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
