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
ConfigSystem.FileName = "HTHubAllStar_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Auto Play Settings
    EquipBestBrainrotsEnabled = false,
    EquipBestBrainrotsDelay = 1, -- Mặc định là 1 phút
    SellBrainrotsEnabled = false,
    SellBrainrotsDelay = 1, -- Mặc định là 1 phút
    -- Shop Settings
    SelectedSeeds = {},
    AutoBuySeedsEnabled = false,
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

-- Biến lưu trạng thái của tab Main
local autoVoteEnabled = false
local autoRetryEnabled = false
local equipBestBrainrotsEnabled = ConfigSystem.CurrentConfig.EquipBestBrainrotsEnabled or false
local equipBestBrainrotsDelay = ConfigSystem.CurrentConfig.EquipBestBrainrotsDelay or 1
-- Shop state
local selectedSeeds = ConfigSystem.CurrentConfig.SelectedSeeds or {}
local autoBuySeedsEnabled = ConfigSystem.CurrentConfig.AutoBuySeedsEnabled or false

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Utility: get and sort seed names A-Z from ReplicatedStorage.Assets.Seeds
local function getSortedSeedNames()
    local seedsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
    if seedsFolder then seedsFolder = seedsFolder:FindFirstChild("Seeds") end
    local names = {}
    if seedsFolder and seedsFolder:IsA("Folder") then
        for _, child in ipairs(seedsFolder:GetChildren()) do
            table.insert(names, child.Name)
        end
    end
    table.sort(names, function(a,b)
        return string.lower(a) < string.lower(b)
    end)
    return names
end

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | Plant vs Brainrots",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Hệ thống Tạo Tab

-- Tạo Tab Main
local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://13311802307" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })
-- Tạo Tab Shop
local ShopTab = Window:AddTab({ Title = "Shop", Icon = "rbxassetid://13311800295" })

-- Tab Main
-- Section Auto Play trong tab Main
local AutoPlaySection = MainTab:AddSection("Auto Play")

-- Shop tab sections
local SeedsShopSection = ShopTab:AddSection("Seeds Shop")

-- Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubAllStar")
SaveManager:SetFolder("HTHubAllStar/" .. playerName)

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
    for _, tab in pairs({MainTab, SettingsTab}) do
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

-- Hàm Auto Play
-- Hàm Equip Best Brainrots
local function executeEquipBestBrainrots()
    if equipBestBrainrotsEnabled then
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EquipBestBrainrots"):FireServer()
        end)

        if not success then
            warn("Lỗi Equip Best Brainrots: " .. tostring(err))
        else
            print("Equip Best Brainrots executed successfully")
        end
    end
end

-- Hàm Sell Brainrots
local function executeSellBrainrots()
    if sellBrainrotsEnabled then
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ItemSell"):FireServer()
        end)

        if not success then
            warn("Lỗi Sell Brainrots: " .. tostring(err))
        else
            print("Sell Brainrots executed successfully")
        end
    end
end

-- Toggle Equip Best Brainrots
AutoPlaySection:AddToggle("EquipBestBrainrotsToggle", {
    Title = "Equip Best Brainrots",
    Description = "Auto equip best brainrots",
    Default = ConfigSystem.CurrentConfig.EquipBestBrainrotsEnabled or false,
    Callback = function(Value)
        equipBestBrainrotsEnabled = Value
        ConfigSystem.CurrentConfig.EquipBestBrainrotsEnabled = Value
        ConfigSystem.SaveConfig()

        if equipBestBrainrotsEnabled then
            Fluent:Notify({
                Title = "Equip Best Brainrots Enabled",
                Content = "Auto equip best brainrots enabled",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Equip Best Brainrots Disabled",
                Content = "Auto equip best brainrots disabled",
                Duration = 3
            })
        end
    end
})

-- Input cho Delay Time
AutoPlaySection:AddInput("EquipBestBrainrotsDelayInput", {
    Title = "Delay Time (1-60)",
    Description = "Delay time between each activation (minutes)",
    Default = tostring(ConfigSystem.CurrentConfig.EquipBestBrainrotsDelay or 1),
    Placeholder = "1-60 minutes",
    Callback = function(Value)        local numericValue = tonumber(Value)
        if numericValue and numericValue >= 1 and numericValue <= 60 then
            equipBestBrainrotsDelay = numericValue
            ConfigSystem.CurrentConfig.EquipBestBrainrotsDelay = numericValue
            ConfigSystem.SaveConfig()
            Fluent:Notify({
                Title = "Delay Time Updated",
                Content = "Delay time updated to " .. numericValue .. " minutes",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Invalid Input",
                Content = "Please enter a number between 1-60.",
                Duration = 3
            })
        end
    end
})

-- Toggle Sell Brainrots
AutoPlaySection:AddToggle("SellBrainrotsToggle", {
    Title = "Sell Brainrots",
    Description = "Auto sell brainrots",
    Default = ConfigSystem.CurrentConfig.SellBrainrotsEnabled or false,
    Callback = function(Value)
        sellBrainrotsEnabled = Value
        ConfigSystem.CurrentConfig.SellBrainrotsEnabled = Value
        ConfigSystem.SaveConfig()

        if sellBrainrotsEnabled then
            Fluent:Notify({
                Title = "Sell Brainrots Enabled",
                Content = "Auto sell brainrots enabled",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Sell Brainrots Disabled",
                Content = "Auto sell brainrots disabled",
                Duration = 3
            })
        end
    end
})

-- Input cho Delay Time (Sell Brainrots)
AutoPlaySection:AddInput("SellBrainrotsDelayInput", {
    Title = "Sell Delay Time (1-60)",
    Description = "Delay time between each sell (minutes)",
    Default = tostring(ConfigSystem.CurrentConfig.SellBrainrotsDelay or 1),
    Placeholder = "1-60 minutes",
    Callback = function(Value)
        local numericValue = tonumber(Value)
        if numericValue and numericValue >= 1 and numericValue <= 60 then
            sellBrainrotsDelay = numericValue
            ConfigSystem.CurrentConfig.SellBrainrotsDelay = numericValue
            ConfigSystem.SaveConfig()
            Fluent:Notify({
                Title = "Sell Delay Time Updated",
                Content = "Sell delay time updated to " .. numericValue .. " minutes",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Invalid Input",
                Content = "Please enter a number between 1-60.",
                Duration = 3
            })
        end
    end
})

-- Seeds dropdown (multi-select) and auto-buy toggle
local availableSeeds = getSortedSeedNames()
SeedsShopSection:AddDropdown("SeedsMulti", {
    Title = "Select Seeds",
    Description = "Chọn một hoặc nhiều seeds (A-Z)",
    Values = availableSeeds,
    Multi = true,
    Default = selectedSeeds,
    Callback = function(values)
        selectedSeeds = values
        ConfigSystem.CurrentConfig.SelectedSeeds = values
        ConfigSystem.SaveConfig()
    end
})

SeedsShopSection:AddToggle("AutoBuySeedsToggle", {
    Title = "Auto Buy",
    Description = "Tự động mua seeds đã chọn mỗi 30 giây",
    Default = autoBuySeedsEnabled,
    Callback = function(Value)
        autoBuySeedsEnabled = Value
        ConfigSystem.CurrentConfig.AutoBuySeedsEnabled = Value
        ConfigSystem.SaveConfig()
        if autoBuySeedsEnabled then
            Fluent:Notify({ Title = "Auto Buy Seeds Enabled", Content = "Đang tự động mua seeds đã chọn", Duration = 3 })
        else
            Fluent:Notify({ Title = "Auto Buy Seeds Disabled", Content = "Đã tắt tự động mua seeds", Duration = 3 })
        end
    end
})

-- Auto buy loop
local function autoBuySeedsLoop()
    spawn(function()
        while true do
            if autoBuySeedsEnabled and type(selectedSeeds) == "table" then
                for _, seedName in pairs(selectedSeeds) do
                    if typeof(seedName) == "string" and seedName ~= "" then
                        pcall(function()
                            local args = { seedName }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyItem"):FireServer(unpack(args))
                        end)
                    end
                end
                wait(30)
            else
                wait(1)
            end
        end
    end)
end

autoBuySeedsLoop()

-- Auto Equip Best Brainrots with Delay
local function AutoEquipBestBrainrots()
    spawn(function()
        while true do
            if equipBestBrainrotsEnabled then
                executeEquipBestBrainrots()
                wait(equipBestBrainrotsDelay * 60) -- Convert minutes to seconds
            else
                wait(1) -- Wait a short time if disabled to avoid busy-waiting
            end
        end
    end)
end

-- Thực thi tự động trang bị brainrots
AutoEquipBestBrainrots()



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

print("HT Hub All Star Tower Defense Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
