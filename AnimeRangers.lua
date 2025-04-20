-- Anime Rangers X Script
-- Sử dụng Orion UI Library thay vì Fluent UI

-- Lấy các service cần thiết
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Tạo thư mục cho lưu cấu hình
local function createFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

-- Hàm lưu cấu hình
local function saveConfig(configName, data)
    createFolder("AnimeRangersX")
    createFolder("AnimeRangersX/configs")
    writefile("AnimeRangersX/configs/" .. configName .. ".json", HttpService:JSONEncode(data))
end

-- Hàm tải cấu hình
local function loadConfig(configName)
    local path = "AnimeRangersX/configs/" .. configName .. ".json"
    if isfile(path) then
        return HttpService:JSONDecode(readfile(path))
    end
    return nil
end

-- Cấu hình dựa trên tên người chơi
local playerName = player.Name
local configName = "Player_" .. playerName
local settings = loadConfig(configName) or {
    autoFarm = false,
    autoAttack = false,
    walkSpeed = 16
}

-- Tải Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo cửa sổ UI
local Window = OrionLib:MakeWindow({
    Name = "Anime Rangers X", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "AnimeRangersX"
})

-- Tab Info
local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddLabel("Anime Rangers X Script")
InfoTab:AddLabel("Phiên bản: 1.0.0")
InfoTab:AddLabel("Tác giả: Script Master")
InfoTab:AddParagraph("Hướng dẫn", "Sử dụng các tab để điều chỉnh cài đặt script")

-- Tự động lưu cấu hình
task.spawn(function()
    while true do
        wait(5) -- 5 giây
        saveConfig(configName, settings)
        OrionLib:MakeNotification({
            Name = "Auto Save",
            Content = "Đã tự động lưu cấu hình cho " .. playerName,
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
end)

-- Thông báo khi tải script
OrionLib:MakeNotification({
    Name = "Script Loaded",
    Content = "AnimeRangersX script đã được tải thành công!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Code hệ thống game - đặt trong pcall để bắt lỗi
pcall(function()
    -- Đảm bảo ReplicatedStorage sẵn sàng
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
        speed.Value = settings.walkSpeed or 16
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

-- Khởi tạo UI
OrionLib:Init()
