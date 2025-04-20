-- Anime Rangers X Script
-- Tải thư viện Fluent UI
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

-- Khởi tạo Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Anime Rangers X",
    SubTitle = "by Script Master",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Cấu hình nút thu gọn (-)
local MinimizeBtn = Window.Root.Main.TopBar.Minimize
MinimizeBtn.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- Cấu hình chế độ thu gọn hiển thị logo
Window.Minimized:Connect(function()
    Fluent:Notify({
        Title = "UI",
        Content = "Giao diện đã được thu nhỏ",
        Duration = 2
    })
end)

-- Cấu hình khi mở lại cửa sổ
Window.Restored:Connect(function()
    Fluent:Notify({
        Title = "UI",
        Content = "Giao diện đã được mở lại",
        Duration = 2
    })
end)

-- Tạo các tab
local InfoTab = Window:AddTab({ Title = "Info", Icon = "rbxassetid://10723424505" })

-- Lưu và tải cấu hình
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Setup cửa sổ
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AnimeRangersX")
SaveManager:SetFolder("AnimeRangersX/configs")

-- Hệ thống auto save config theo tên người chơi
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Đợi đến khi người chơi sẵn sàng
if not player then
    player = Players.PlayerAdded:Wait()
end

local playerName = player.Name
local configName = "Player_" .. playerName

-- Tự động lưu cấu hình khi đóng
Window.Closed:Connect(function()
    SaveManager:Save(configName)
    Fluent:Notify({
        Title = "Auto Save",
        Content = "Đã lưu cấu hình cho " .. playerName,
        Duration = 3
    })
end)

-- Tự động tải cấu hình khi mở
task.spawn(function()
    wait(1)
    -- Thử tải cấu hình của người chơi
    if SaveManager:Load(configName) then
        Fluent:Notify({
            Title = "Auto Load",
            Content = "Đã tải cấu hình cho " .. playerName,
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Load",
            Content = "Không tìm thấy cấu hình, tạo mới cho " .. playerName,
            Duration = 3
        })
        SaveManager:Save(configName)
    end
end)

-- Tự động lưu định kỳ (mỗi 5 giây)
task.spawn(function()
    while true do
        wait(5) -- 5 giây
        SaveManager:Save(configName)
        Fluent:Notify({
            Title = "Auto Save",
            Content = "Đã tự động lưu cấu hình cho " .. playerName,
            Duration = 2
        })
    end
end)

Window:SelectTab(1)

-- Code hệ thống game - đặt trong pcall để bắt lỗi
pcall(function()
    -- Đảm bảo các services sẵn sàng
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    -- Đợi đến khi ReplicatedStorage sẵn sàng
    if not ReplicatedStorage then
        warn("ReplicatedStorage chưa sẵn sàng, đang đợi...")
        ReplicatedStorage = game:WaitForService("ReplicatedStorage")
    end

    -- Các biến và constants
    local DAMAGE_MULTIPLIER = 1.5
    local COOLDOWN_BASIC_ATTACK = 0.8
    local COOLDOWN_SPECIAL_ABILITY = 10

    -- Kiểm tra xem RemoteEvents đã tồn tại chưa
    local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEvents then
        -- Tạo thư mục cho Remote Events
        RemoteEvents = Instance.new("Folder")
        RemoteEvents.Name = "RemoteEvents"
        RemoteEvents.Parent = ReplicatedStorage
    end

    -- Kiểm tra và tạo các Remote Events nếu chưa có
    local DamageEvent = RemoteEvents:FindFirstChild("DamageEvent")
    if not DamageEvent then
        DamageEvent = Instance.new("RemoteEvent")
        DamageEvent.Name = "DamageEvent"
        DamageEvent.Parent = RemoteEvents
    end

    local AbilityEvent = RemoteEvents:FindFirstChild("AbilityEvent")
    if not AbilityEvent then
        AbilityEvent = Instance.new("RemoteEvent")
        AbilityEvent.Name = "AbilityEvent"
        AbilityEvent.Parent = RemoteEvents
    end

    -- Hàm quản lý nhân vật
    local function setupCharacter(player, character)
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then
            warn("Không tìm thấy Humanoid cho nhân vật")
            return
        end
        
        local stats = Instance.new("Folder")
        stats.Name = "Stats"
        stats.Parent = character
        
        -- Các chỉ số cơ bản
        local strength = Instance.new("NumberValue")
        strength.Name = "Strength"
        strength.Value = 10
        strength.Parent = stats
        
        local defense = Instance.new("NumberValue")
        defense.Name = "Defense"
        defense.Value = 5
        defense.Parent = stats
        
        local speed = Instance.new("NumberValue")
        speed.Name = "Speed"
        speed.Value = 16
        speed.Parent = stats
        
        -- Set tốc độ di chuyển
        humanoid.WalkSpeed = speed.Value
        
        -- Xử lý khi nhân vật chết
        humanoid.Died:Connect(function()
            wait(3)
            character:BreakJoints()
            player:LoadCharacter()
        end)
    end

    -- Hàm tấn công cơ bản
    local function basicAttack(player, target)
        local character = player.Character
        if not character then return end
        
        local stats = character:FindFirstChild("Stats")
        if not stats then return end
        
        local strength = stats:FindFirstChild("Strength")
        if not strength then return end
        
        local damage = strength.Value * DAMAGE_MULTIPLIER
        
        -- Gửi sự kiện gây sát thương nếu có thể
        if DamageEvent and target then
            DamageEvent:FireClient(target, damage)
        end
    end

    -- Hàm kích hoạt kỹ năng đặc biệt
    local function activateSpecialAbility(player, abilityName)
        local character = player.Character
        if not character then return end
        
        -- Thực hiện kỹ năng tùy thuộc vào tên nếu AbilityEvent tồn tại
        if AbilityEvent and player then
            if abilityName == "FireballAttack" then
                -- Code xử lý fireball
                AbilityEvent:FireClient(player, "FireballAttack")
            elseif abilityName == "LightningStrike" then
                -- Code xử lý lightning strike
                AbilityEvent:FireClient(player, "LightningStrike")
            elseif abilityName == "UltraCombo" then
                -- Code xử lý combo đặc biệt
                AbilityEvent:FireClient(player, "UltraCombo")
            end
        end
    end

    -- Xử lý khi người chơi tham gia nếu Players service sẵn sàng
    if Players then
        Players.PlayerAdded:Connect(function(player)
            if player then
                player.CharacterAdded:Connect(function(character)
                    setupCharacter(player, character)
                end)
                
                -- Setup cho nhân vật hiện tại nếu có
                if player.Character then
                    setupCharacter(player, player.Character)
                end
            end
        end)
        
        -- Setup cho các người chơi hiện tại
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                setupCharacter(player, player.Character)
            end
            
            player.CharacterAdded:Connect(function(character)
                setupCharacter(player, character)
            end)
        end
    end

    -- Xử lý input từ người chơi (phía Client) nếu UserInputService sẵn sàng
    if UserInputService and Players.LocalPlayer then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local player = Players.LocalPlayer
            if not player then return end
            
            if input.KeyCode == Enum.KeyCode.E then
                -- Kích hoạt tấn công cơ bản
                -- Tìm mục tiêu gần nhất (cần thêm code)
                local target = nil
                
                if target then
                    basicAttack(player, target)
                end
            elseif input.KeyCode == Enum.KeyCode.Q then
                -- Kích hoạt kỹ năng đặc biệt 1
                activateSpecialAbility(player, "FireballAttack")
            elseif input.KeyCode == Enum.KeyCode.R then
                -- Kích hoạt kỹ năng đặc biệt 2
                activateSpecialAbility(player, "LightningStrike")
            elseif input.KeyCode == Enum.KeyCode.F then
                -- Kích hoạt kỹ năng đặc biệt 3
                activateSpecialAbility(player, "UltraCombo")
            end
        end)
    end
end)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "AnimeRangersX script đã được tải thành công!",
    Duration = 5
})