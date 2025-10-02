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
    AutoBuySeedsEnabled = false,
    SelectedSeedsToBuy = {},
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
local sellBrainrotsEnabled = ConfigSystem.CurrentConfig.SellBrainrotsEnabled or false
local sellBrainrotsDelay = ConfigSystem.CurrentConfig.SellBrainrotsDelay or 1
local autoBuySeedsEnabled = ConfigSystem.CurrentConfig.AutoBuySeedsEnabled or false
local selectedSeedsToBuy = ConfigSystem.CurrentConfig.SelectedSeedsToBuy or {}

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

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
-- Tạo Tab Shop
local ShopTab = Window:AddTab({ Title = "Shop", Icon = "rbxassetid://13311802307" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tab Main
-- Section Auto Play trong tab Main
local AutoPlaySection = MainTab:AddSection("Auto Play")

-- Tab Shop
-- Section Seeds Shop trong tab Shop
local SeedsShopSection = ShopTab:AddSection("Seeds Shop")

-- Lấy danh sách hạt giống
local allSeedNames = getSortedSeedNames()

-- Thêm Toggle cho từng hạt giống
for i, seedName in ipairs(allSeedNames) do
    SeedsShopSection:AddToggle("SeedToggle_" .. seedName, {
        Title = seedName,
        Description = "Chọn để tự động mua hạt giống này",
        Default = table.find(ConfigSystem.CurrentConfig.SelectedSeedsToBuy, seedName) ~= nil,
        Callback = function(Value)
            if Value then
                table.insert(selectedSeedsToBuy, seedName)
            else
                local index = table.find(selectedSeedsToBuy, seedName)
                if index then
                    table.remove(selectedSeedsToBuy, index)
                end
            end
            ConfigSystem.CurrentConfig.SelectedSeedsToBuy = selectedSeedsToBuy
            ConfigSystem.SaveConfig()
        end
    })
end

-- Thêm Toggle Auto Buy Seeds
SeedsShopSection:AddToggle("AutoBuySeedsToggle", {
    Title = "Tự động mua hạt giống",
    Description = "Tự động mua các hạt giống đã chọn mỗi 30 giây",
    Default = ConfigSystem.CurrentConfig.AutoBuySeedsEnabled or false,
    Callback = function(Value)
        autoBuySeedsEnabled = Value
        ConfigSystem.CurrentConfig.AutoBuySeedsEnabled = Value
        ConfigSystem.SaveConfig()

        if autoBuySeedsEnabled then
            Fluent:Notify({
                Title = "Đã bật tự động mua hạt giống",
                Content = "Tự động mua hạt giống đã được bật.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Đã tắt tự động mua hạt giống",
                Content = "Tự động mua hạt giống đã bị tắt.",
                Duration = 3
            })
        end
    end
})

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
    for _, tab in pairs({MainTab, ShopTab, SettingsTab}) do
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
    Description = "Tự động trang bị brainrots tốt nhất",
    Default = ConfigSystem.CurrentConfig.EquipBestBrainrotsEnabled or false,
    Callback = function(Value)
        equipBestBrainrotsEnabled = Value
        ConfigSystem.CurrentConfig.EquipBestBrainrotsEnabled = Value
        ConfigSystem.SaveConfig()

        if equipBestBrainrotsEnabled then
            Fluent:Notify({
                Title = "Đã bật tự động trang bị Brainrots",
                Content = "Tự động trang bị Brainrots tốt nhất đã được bật.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Đã tắt tự động trang bị Brainrots",
                Content = "Tự động trang bị Brainrots tốt nhất đã bị tắt.",
                Duration = 3
            })
        end
    end
})

-- Input cho Delay Time
AutoPlaySection:AddInput("EquipBestBrainrotsDelayInput", {
    Title = "Thời gian chờ (phút)",
    Description = "Thời gian chờ giữa các lần kích hoạt (phút, 1-60)",
    Default = tostring(ConfigSystem.CurrentConfig.EquipBestBrainrotsDelay or 1),
    Placeholder = "1-60 phút",
    Callback = function(Value)        local numericValue = tonumber(Value)
        if numericValue and numericValue >= 1 and numericValue <= 60 then
            equipBestBrainrotsDelay = numericValue
            ConfigSystem.CurrentConfig.EquipBestBrainrotsDelay = numericValue
            ConfigSystem.SaveConfig()
            Fluent:Notify({
                Title = "Đã cập nhật thời gian chờ",
                Content = "Thời gian chờ đã được cập nhật thành " .. numericValue .. " phút.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Giá trị không hợp lệ",
                Content = "Vui lòng nhập số từ 1 đến 60.",
                Duration = 3
            })
        end
    end
})

-- Toggle Sell Brainrots
AutoPlaySection:AddToggle("SellBrainrotsToggle", {
    Title = "Bán Brainrots",
    Description = "Tự động bán brainrots",
    Default = ConfigSystem.CurrentConfig.SellBrainrotsEnabled or false,
    Callback = function(Value)
        sellBrainrotsEnabled = Value
        ConfigSystem.CurrentConfig.SellBrainrotsEnabled = Value
        ConfigSystem.SaveConfig()

        if sellBrainrotsEnabled then
            Fluent:Notify({
                Title = "Đã bật tự động bán Brainrots",
                Content = "Tự động bán Brainrots đã được bật.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Đã tắt tự động bán Brainrots",
                Content = "Tự động bán Brainrots đã bị tắt.",
                Duration = 3
            })
        end
    end
})

-- Input cho Delay Time (Sell Brainrots)
AutoPlaySection:AddInput("SellBrainrotsDelayInput", {
    Title = "Thời gian chờ bán (phút)",
    Description = "Thời gian chờ giữa các lần bán (phút, 1-60)",
    Default = tostring(ConfigSystem.CurrentConfig.SellBrainrotsDelay or 1),
    Placeholder = "1-60 phút",
    Callback = function(Value)
        local numericValue = tonumber(Value)
        if numericValue and numericValue >= 1 and numericValue <= 60 then
            sellBrainrotsDelay = numericValue
            ConfigSystem.CurrentConfig.SellBrainrotsDelay = numericValue
            ConfigSystem.SaveConfig()
            Fluent:Notify({
                Title = "Đã cập nhật thời gian chờ bán",
                Content = "Thời gian chờ bán đã được cập nhật thành " .. numericValue .. " phút.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Giá trị không hợp lệ",
                Content = "Vui lòng nhập số từ 1 đến 60.",
                Duration = 3
            })
        end
    end
})

-- Auto Sell Brainrots with Delay
local function AutoSellBrainrots()
    spawn(function()
        while true do
            if sellBrainrotsEnabled then
                executeSellBrainrots()
                wait(sellBrainrotsDelay * 60) -- Convert minutes to seconds
            else
                wait(1) -- Wait a short time if disabled to avoid busy-waiting
            end
        end
    end)
end

-- Thực thi tự động bán brainrots
AutoSellBrainrots()

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

-- Hàm lấy và sắp xếp danh sách hạt giống
local function getSortedSeedNames()
    local seedNames = {}
    local seedsFolder = game:GetService("ReplicatedStorage").Assets:WaitForChild("Seeds")
    for _, seed in pairs(seedsFolder:GetChildren()) do
        if seed:IsA("Folder") or seed:IsA("Model") then -- Giả sử mỗi hạt giống là một Folder hoặc Model
            table.insert(seedNames, seed.Name)
        end
    end
    table.sort(seedNames) -- Sắp xếp theo thứ tự chữ cái
    return seedNames
end

-- Hàm Auto Buy Seeds
local function executeAutoBuySeeds()
    if autoBuySeedsEnabled and #selectedSeedsToBuy > 0 then
        for _, seedName in ipairs(selectedSeedsToBuy) do
            local success, err = pcall(function()
                local args = {seedName}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyItem"):FireServer(unpack(args))
            end)

            if not success then
                warn("Lỗi Auto Buy Seed (" .. seedName .. "): " .. tostring(err))
            else
                print("Auto Buy Seed (" .. seedName .. ") executed successfully")
            end
            wait(0.1) -- Đợi một chút giữa các lần mua để tránh spam
        end
    end
end

-- Auto Buy Seeds Loop
local function AutoBuySeeds()
    spawn(function()
        while true do
            if autoBuySeedsEnabled then
                executeAutoBuySeeds()
                wait(30) -- Lặp lại mỗi 30 giây
            else
                wait(1) -- Đợi một chút nếu chức năng bị tắt
            end
        end
    end)
end

-- Thực thi tự động mua hạt giống
AutoBuySeeds()

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

print("HT Hub Plant vs Brainrots Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
