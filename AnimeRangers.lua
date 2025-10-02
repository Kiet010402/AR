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
    -- Seeds Shop Settings 
    AutoBuySeedsEnabled = false,
    SelectedSeeds = {},
    -- Gears Shop Settings
    AutoBuyGearsEnabled = false,
    SelectedGears = {},
    -- Settings
    AntiAFKEnabled = false,
    -- Favorite Settings
    AutoFavoriteEnabled = false,
    FavoriteRarities = {},
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

-- Shop Seeds
local autoBuySeedsEnabled = ConfigSystem.CurrentConfig.AutoBuySeedsEnabled or false
local selectedSeeds = ConfigSystem.CurrentConfig.SelectedSeeds or {}

-- Gear Shop
local autoBuyGearsEnabled = ConfigSystem.CurrentConfig.AutoBuyGearsEnabled or false
local selectedGears = ConfigSystem.CurrentConfig.SelectedGears or {}

-- Settings: Anti AFK
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFKEnabled or false
local antiAFKConnection = nil

-- Favorite system
local autoFavoriteEnabled = ConfigSystem.CurrentConfig.AutoFavoriteEnabled or false
local favoriteRarities = ConfigSystem.CurrentConfig.FavoriteRarities or {}
local brainrotNameToRarity = {}

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | Plant vs Brainrots",
    SubTitle = "",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 350),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo Tab Main
local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://13311802307" })
-- Tạo Tab Shop
local ShopTab = Window:AddTab({ Title = "Shop", Icon = "rbxassetid://13311804536" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Auto select Main tab on startup
Window:SelectTab(1)

-- Tab Main
-- Section Auto Play trong tab Main
local AutoPlaySection = MainTab:AddSection("Auto Play")
local FavoriteSection = MainTab:AddSection("Favorite")

-- Shop tab configuration
local SeedsShopSection = ShopTab:AddSection("Seeds Shop")
local GearShopSection = ShopTab:AddSection("Gear Shop")

-- Settings tab configuration
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Anti AFK setup
local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    if antiAFKEnabled then
        local VirtualUser = game:GetService("VirtualUser")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        if LocalPlayer then
            antiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end

-- Add Anti AFK toggle in Settings
SettingsSection:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Description = "Prevent idle kick",
    Default = antiAFKEnabled,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFKEnabled = Value
        ConfigSystem.SaveConfig()
        setupAntiAFK()
        if Value then
            Fluent:Notify({ Title = "Anti AFK", Content = "Enabled", Duration = 2 })
        else
            Fluent:Notify({ Title = "Anti AFK", Content = "Disabled", Duration = 2 })
        end
    end
})

-- Initialize Anti AFK if enabled on startup
setupAntiAFK()

-- Helper: get sorted seed names from ReplicatedStorage.Assets.Seeds
local function getAllSeedNames()
    local seedsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):FindFirstChild("Seeds")
    local names = {}
    if seedsFolder then
        for _, inst in ipairs(seedsFolder:GetChildren()) do
            table.insert(names, inst.Name)
        end
        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
    end
    return names
end

-- Helper: get sorted gear names from ReplicatedStorage.Assets.Gears
local function getAllGearNames()
    local gearsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):FindFirstChild("Gears")
    local names = {}
    if gearsFolder then
        for _, inst in ipairs(gearsFolder:GetChildren()) do
            table.insert(names, inst.Name)
        end
        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
    end
    return names
end

-- Build dropdown options
local seedOptions = getAllSeedNames()
local gearOptions = getAllGearNames()

-- Multi-select dropdown (using AddDropdown with Multi = true)
SeedsShopSection:AddDropdown("SeedsDropdown", {
    Title = "Select Seeds",
    Description = "Choose one or more seeds to buy",
    Values = seedOptions,
    Multi = true,
    Default = selectedSeeds,
    Callback = function(selection)
        -- Normalize selection to an array of seed names
        local normalized = {}
        if type(selection) == "table" then
            -- Case 1: map { ["SeedName"] = true }
            for key, value in pairs(selection) do
                if typeof(key) == "string" and value == true then
                    table.insert(normalized, key)
                end
            end
            -- Case 2: array {"SeedName1","SeedName2"}
            for _, value in ipairs(selection) do
                if typeof(value) == "string" then
                    table.insert(normalized, value)
                end
            end
        end
        -- Deduplicate and sort
        local seen = {}
        local unique = {}
        for _, name in ipairs(normalized) do
            if not seen[name] then
                seen[name] = true
                table.insert(unique, name)
            end
        end
        table.sort(unique, function(a,b) return string.lower(a) < string.lower(b) end)
        selectedSeeds = unique
        ConfigSystem.CurrentConfig.SelectedSeeds = selectedSeeds
        ConfigSystem.SaveConfig()
    end
})

-- Auto Buy toggle
SeedsShopSection:AddToggle("AutoBuySeedsToggle", {
    Title = "Auto Buy",
    Description = "Automatically buy selected seeds every 5 seconds",
    Default = autoBuySeedsEnabled,
    Callback = function(value)
        autoBuySeedsEnabled = value
        ConfigSystem.CurrentConfig.AutoBuySeedsEnabled = value
        ConfigSystem.SaveConfig()
        if autoBuySeedsEnabled then
            Fluent:Notify({ Title = "Auto Buy Enabled", Content = "Buying seeds every 5s", Duration = 3 })
        else
            Fluent:Notify({ Title = "Auto Buy Disabled", Content = "Stopped auto buying", Duration = 3 })
        end
    end
})

-- Gear dropdown
GearShopSection:AddDropdown("GearsDropdown", {
    Title = "Select Gears",
    Description = "Choose one or more gears to buy",
    Values = gearOptions,
    Multi = true,
    Default = selectedGears,
    Callback = function(selection)
        -- Normalize selection to an array of gear names
        local normalized = {}
        if type(selection) == "table" then
            for key, value in pairs(selection) do
                if typeof(key) == "string" and value == true then
                    table.insert(normalized, key)
                end
            end
            for _, value in ipairs(selection) do
                if typeof(value) == "string" then
                    table.insert(normalized, value)
                end
            end
        end
        local seen = {}
        local unique = {}
        for _, name in ipairs(normalized) do
            if not seen[name] then
                seen[name] = true
                table.insert(unique, name)
            end
        end
        table.sort(unique, function(a,b) return string.lower(a) < string.lower(b) end)
        selectedGears = unique
        ConfigSystem.CurrentConfig.SelectedGears = selectedGears
        ConfigSystem.SaveConfig()
    end
})

-- Auto Buy toggle for gears
GearShopSection:AddToggle("AutoBuyGearsToggle", {
    Title = "Auto Buy",
    Description = "Automatically buy selected gears every 5 seconds",
    Default = autoBuyGearsEnabled,
    Callback = function(value)
        autoBuyGearsEnabled = value
        ConfigSystem.CurrentConfig.AutoBuyGearsEnabled = value
        ConfigSystem.SaveConfig()
        if autoBuyGearsEnabled then
            Fluent:Notify({ Title = "Auto Buy Enabled", Content = "Buying gears every 5s", Duration = 3 })
        else
            Fluent:Notify({ Title = "Auto Buy Disabled", Content = "Stopped auto buying", Duration = 3 })
        end
    end
})

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubAllStar")
SaveManager:SetFolder("HTHubAllStar/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Auto Save Config",
    Content = "Your config is automatically saved by the character name: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Shortcut",
    Content = "Press LeftControl to hide/show the interface"
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
    Description = "Delay time Equip Best Brainrots (minutes)",
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
    Description = "Delay time Sell Brainrots (minutes)",
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

-- Buy selected seeds once
local function buySelectedSeeds()
    -- Build an ordered list from selectedSeeds which may be an array or a map
    local toBuy = {}
    if type(selectedSeeds) == "table" then
        -- Map form
        for key, value in pairs(selectedSeeds) do
            if typeof(key) == "string" and value == true then
                table.insert(toBuy, key)
            end
        end
        -- Array form
        for _, value in ipairs(selectedSeeds) do
            if typeof(value) == "string" then
                table.insert(toBuy, value)
            end
        end
    end
    -- Deduplicate preserving first occurrence
    local seen = {}
    local ordered = {}
    for _, name in ipairs(toBuy) do
        if not seen[name] then
            seen[name] = true
            table.insert(ordered, name)
        end
    end
    -- Iterate and fire remote per seed with 2s interval
    for _, seedName in ipairs(ordered) do
        local args = { seedName }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyItem"):FireServer(unpack(args))
        end)
        wait(2)
    end
end

-- Background loop for auto buy every 5 seconds
spawn(function()
    while true do
        if autoBuySeedsEnabled and selectedSeeds and #selectedSeeds > 0 then
            buySelectedSeeds()
            wait(5)
        else
            wait(1)
        end
    end
end)

-- Buy selected gears once
local function buySelectedGears()
    -- Build an ordered list from selectedGears which may be an array or a map
    local toBuy = {}
    if type(selectedGears) == "table" then
        for key, value in pairs(selectedGears) do
            if typeof(key) == "string" and value == true then
                table.insert(toBuy, key)
            end
        end
        for _, value in ipairs(selectedGears) do
            if typeof(value) == "string" then
                table.insert(toBuy, value)
            end
        end
    end
    local seen = {}
    local ordered = {}
    for _, name in ipairs(toBuy) do
        if not seen[name] then
            seen[name] = true
            table.insert(ordered, name)
        end
    end
    for _, gearName in ipairs(ordered) do
        local args = { gearName }
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyGear"):FireServer(unpack(args))
        end)
        wait(2)
    end
end

-- Background loop for auto buy gears every 5 seconds
spawn(function()
    while true do
        if autoBuyGearsEnabled and selectedGears and #selectedGears > 0 then
            buySelectedGears()
            wait(5)
        else
            wait(1)
        end
    end
end)

-- Build name->rarity map from Assets.Brainrots
local function refreshBrainrotCatalog()
    brainrotNameToRarity = {}
    local folder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):FindFirstChild("Brainrots")
    if folder then
        for _, inst in ipairs(folder:GetChildren()) do
            local rarityValue = (inst:FindFirstChild("Rarity") and inst.Rarity.Value) or (inst:GetAttribute("Rarity"))
            local rarity = tostring(rarityValue or "")
            brainrotNameToRarity[inst.Name] = rarity
        end
    end
end
refreshBrainrotCatalog()

-- Helper to extract clean item name from Backpack tool Text/ItemName
local function getCleanBackpackName(tool)
    -- Prefer attribute ItemName if present
    local attrName = tool:GetAttribute("ItemName")
    if attrName and attrName ~= "" then return tostring(attrName) end
    -- Fallback to Name: strip prefixes like [Gold] [11.2 kg]
    local raw = tool.Name or ""
    -- Remove bracketed prefixes
    local cleaned = raw:gsub("%b[]%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return cleaned
end

-- Helper to buy favorite: call FavoriteItem with ID
local function favoriteById(id)
    pcall(function()
        local args = { id }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("FavoriteItem"):FireServer(unpack(args))
    end)
end

-- Favorite UI: dropdown of rarities
local rarityOptions = { "Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret", "Limited" }
FavoriteSection:AddDropdown("FavoriteRarityDropdown", {
    Title = "Favorite Rarity",
    Description = "Select rarities to auto-favorite",
    Values = rarityOptions,
    Multi = true,
    Default = favoriteRarities,
    Callback = function(values)
        favoriteRarities = values
        ConfigSystem.CurrentConfig.FavoriteRarities = values
        ConfigSystem.SaveConfig()
    end
})

-- Toggle Auto Favorite
FavoriteSection:AddToggle("AutoFavoriteToggle", {
    Title = "Auto Favorite",
    Description = "Auto favorite matching items in Backpack",
    Default = autoFavoriteEnabled,
    Callback = function(value)
        autoFavoriteEnabled = value
        ConfigSystem.CurrentConfig.AutoFavoriteEnabled = value
        ConfigSystem.SaveConfig()
        if value then
            Fluent:Notify({ Title = "Auto Favorite", Content = "Enabled", Duration = 2 })
        else
            Fluent:Notify({ Title = "Auto Favorite", Content = "Disabled", Duration = 2 })
        end
    end
})

-- Background loop: scan Backpack and favorite matches
spawn(function()
    local processedIds = {}
    while true do
        if autoFavoriteEnabled then
            pcall(function()
                refreshBrainrotCatalog()
                local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        local itemName = getCleanBackpackName(tool)
                        local desiredRarity = brainrotNameToRarity[itemName]
                        if desiredRarity then
                            -- values may be map or array; normalize check
                            local selected = false
                            if type(favoriteRarities) == "table" then
                                for k, v in pairs(favoriteRarities) do
                                    if type(k) == "string" and v == true and string.lower(k) == string.lower(desiredRarity) then
                                        selected = true; break
                                    elseif type(k) == "number" and type(v) == "string" and string.lower(v) == string.lower(desiredRarity) then
                                        selected = true; break
                                    end
                                end
                            end
                            if selected then
                                -- Get ID attribute/value
                                local id = tool:GetAttribute("ID") or (tool:FindFirstChild("ID") and tool.ID.Value)
                                if id and not processedIds[id] then
                                    favoriteById(id)
                                    processedIds[id] = true
                                    wait(2)
                                end
                            end
                        end
                    end
                end
            end)
            wait(1)
        else
            wait(1)
        end
    end
end)

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
            ImageButton.Image = "rbxassetid://90319448802378"
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
        warn("Error creating UI logo: " .. tostring(errorMsg))
    end
end)

print("HT Hub Plant vs Brainrots Script loaded successfully!")
print("Use Left Ctrl to hide/show the interface")
