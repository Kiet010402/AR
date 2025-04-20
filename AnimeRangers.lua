-- Anime Rangers X Script
-- Sử dụng UI Library từ AirHub

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
local playerName = player and player.Name or "Player"
local configName = "Player_" .. playerName
local settings = loadConfig(configName) or {
    autoFarm = false,
    autoAttack = false,
    walkSpeed = 16
}

-- Tải UI Library từ AirHub
local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

-- Tạo cửa sổ UI
local MainFrame = Library:CreateWindow({
    Name = "Anime Rangers X",
    Themeable = {
        Image = "7059346386",
        Info = "Made by Script Master\nAnime Rangers X",
        Credit = false
    },
    Background = "",
    Theme = [[{"__Designer.Colors.topGradient":"3F0C64","__Designer.Colors.section":"C259FB","__Designer.Colors.hoveredOptionBottom":"4819B4","__Designer.Background.ImageAssetID":"rbxassetid://4427304036","__Designer.Colors.selectedOption":"4E149C","__Designer.Colors.unselectedOption":"482271","__Designer.Files.WorkspaceFile":"AnimeRangersX","__Designer.Colors.unhoveredOptionTop":"310269","__Designer.Colors.outerBorder":"391D57","__Designer.Background.ImageColor":"69009C","__Designer.Colors.tabText":"B9B9B9","__Designer.Colors.elementBorder":"160B24","__Designer.Background.ImageTransparency":100,"__Designer.Colors.background":"1E1237","__Designer.Colors.innerBorder":"531E79","__Designer.Colors.bottomGradient":"361A60","__Designer.Colors.sectionBackground":"21002C","__Designer.Colors.hoveredOptionTop":"6B10F9","__Designer.Colors.otherElementText":"7B44A8","__Designer.Colors.main":"AB26FF","__Designer.Colors.elementText":"9F7DB5","__Designer.Colors.unhoveredOptionBottom":"3E0088","__Designer.Background.UseBackgroundImage":false}]]
})

-- Tạo các tab
local InfoTab = MainFrame:CreateTab({
    Name = "Info"
})

local FarmTab = MainFrame:CreateTab({
    Name = "Farm"
})

local SettingsTab = MainFrame:CreateTab({
    Name = "Settings"
})

local FunctionsTab = MainFrame:CreateTab({
    Name = "Functions"
})

-- Sections
local InfoSection = InfoTab:CreateSection({
    Name = "Information"
})

local FarmSection = FarmTab:CreateSection({
    Name = "Auto Farm"
})

local CharacterSection = SettingsTab:CreateSection({
    Name = "Character"
})

local GameSection = SettingsTab:CreateSection({
    Name = "Game Settings",
    Side = "Right"
})

local FunctionsSection = FunctionsTab:CreateSection({
    Name = "Functions"
})

-- Info Section
InfoSection:AddLabel({
    Text = "Anime Rangers X Script"
})

InfoSection:AddLabel({
    Text = "Version: 1.0.0"
})

InfoSection:AddLabel({
    Text = "Made by Script Master"
})

-- Farm Section
FarmSection:AddToggle({
    Name = "Auto Farm",
    Value = settings.autoFarm,
    Callback = function(New, Old)
        settings.autoFarm = New
    end
}).Default = settings.autoFarm

FarmSection:AddToggle({
    Name = "Auto Attack",
    Value = settings.autoAttack,
    Callback = function(New, Old)
        settings.autoAttack = New
    end
}).Default = settings.autoAttack

-- Character Section
CharacterSection:AddToggle({
    Name = "WalkSpeed Enabled",
    Value = settings.walkSpeedEnabled or false,
    Callback = function(New, Old)
        settings.walkSpeedEnabled = New
        
        if New and player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = settings.walkSpeed or 16
        end
    end
}).Default = settings.walkSpeedEnabled or false

CharacterSection:AddSlider({
    Name = "WalkSpeed",
    Value = settings.walkSpeed or 16,
    Callback = function(New, Old)
        settings.walkSpeed = New
        
        if settings.walkSpeedEnabled and player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = New
        end
    end,
    Min = 16,
    Max = 100
}).Default = settings.walkSpeed or 16

-- Game Settings Section
GameSection:AddToggle({
    Name = "Auto Save Config",
    Value = settings.autoSaveConfig or true,
    Callback = function(New, Old)
        settings.autoSaveConfig = New
    end
}).Default = settings.autoSaveConfig or true

-- Functions Section
FunctionsSection:AddButton({
    Name = "Save Configuration",
    Callback = function()
        saveConfig(configName, settings)
        print("Configuration saved for " .. playerName)
    end
})

FunctionsSection:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        settings = {
            autoFarm = false,
            autoAttack = false,
            walkSpeed = 16,
            walkSpeedEnabled = false,
            autoSaveConfig = true
        }
        
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
        
        saveConfig(configName, settings)
        Library.ResetAll()
    end
})

FunctionsSection:AddButton({
    Name = "Exit",
    Callback = Library.Unload
})

-- Auto Save
if settings.autoSaveConfig then
    task.spawn(function()
        while wait(5) do
            if settings.autoSaveConfig then
                saveConfig(configName, settings)
            end
        end
    end)
end

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
        if settings.walkSpeedEnabled then
            humanoid.WalkSpeed = settings.walkSpeed or 16
        else
            humanoid.WalkSpeed = 16
        end
        
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

-- Auto Farm Function
task.spawn(function()
    while wait(1) do
        if settings.autoFarm then
            -- Implement auto farm logic here
            print("Auto farming...")
        end
    end
end)

-- Auto Attack Function
task.spawn(function()
    while wait(0.5) do
        if settings.autoAttack then
            -- Implement auto attack logic here
            print("Auto attacking...")
        end
    end
end)

-- Thông báo khi script đã tải xong
print("Anime Rangers X Script has been loaded!")
