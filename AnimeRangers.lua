-- Anime Rangers X Script

-- Kiểm tra Place ID
local currentPlaceId = game.PlaceId
local allowedPlaceId = 72829404259339

-- Hệ thống kiểm soát logs
local LogSystem = {
    Enabled = false,        -- Mặc định tắt logs
    WarningsEnabled = false -- Mặc định tắt cả warnings
}

-- Ghi đè hàm print để kiểm soát logs
local originalPrint = print
print = function(...)
    if LogSystem.Enabled then
        originalPrint(...)
    end
end

-- Ghi đè hàm warn để kiểm soát warnings
local originalWarn = warn
warn = function(...)
    if LogSystem.WarningsEnabled then
        originalWarn(...)
    end
end

if currentPlaceId ~= allowedPlaceId then
    warn("Script này chỉ hoạt động trên game Anime Rangers X (Place ID: " .. tostring(allowedPlaceId) .. ")")
    return
end

-- Phiên bản thay thế cho Fluent:Notify
local Fluent = {}
Fluent.Notify = function(options)
    local title = options.Title or ""
    local content = options.Content or ""
    local duration = options.Duration or 3

    -- In thông báo ra console thay vì hiển thị UI
    print("[" .. title .. "] " .. content)

    -- Có thể thêm logic thông báo khác tại đây nếu cần
    return {
        -- Giả lập các phương thức của đối tượng thông báo Fluent nếu cần
        Destroy = function() end
    }
end

-- Delay 10 giây trước khi mở script
print("Kaihon Hub | Anime Rangers X đang khởi động, vui lòng đợi 10 giây...")
wait(10)
print("Đang tải script...")

-- Tải thư viện Fluent
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

if not Fluent then
    error("Không thể tải thư viện Fluent. Vui lòng kiểm tra kết nối internet hoặc executor.")
    return
end

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
    UITheme = "Amethyst",

    -- Cài đặt log
    LogsEnabled = false,
    WarningsEnabled = false,

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
    SelectedRangerMaps = {}, -- Thêm cấu hình mặc định cho map đã chọn (ban đầu rỗng hoặc chỉ có map default)
    SelectedActs = { RangerStage1 = true },
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

    -- Cài đặt Anti AFK
    AntiAFK = true, -- Mặc định bật

    -- Cài đặt Auto Leave
    AutoLeave = false,

    -- Cài đặt Webhook
    WebhookURL = "",
    AutoSendWebhook = false,

    -- Cài đặt Auto Movement
    AutoMovement = false,

    -- Cài đặt Portal
    SelectedPortals = {},
    AutoOpenPortal = false,

    -- Cài đặt RC Exchange
    AutoBuyQuinque = false,

    -- Cài đặt Portal
    AutoStartPortal = false,
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

            -- Cập nhật cài đặt log
            if data.LogsEnabled ~= nil then
                LogSystem.Enabled = data.LogsEnabled
            end

            if data.WarningsEnabled ~= nil then
                LogSystem.WarningsEnabled = data.WarningsEnabled
            end

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

-- Biến toàn cục để theo dõi UI
local OpenUI = nil
local isMinimized = false

-- Biến lưu trạng thái Summon
local selectedSummonAmount = ConfigSystem.CurrentConfig.SummonAmount or "x1"
local selectedSummonBanner = ConfigSystem.CurrentConfig.SummonBanner or "Standard"
local autoSummonEnabled = ConfigSystem.CurrentConfig.AutoSummon or false
local autoSummonLoop = nil

-- Biến lưu trạng thái Auto Sell
local autoSellRarities = {
    Rare = ConfigSystem.CurrentConfig.AutoSellRare or false,
    Epic = ConfigSystem.CurrentConfig.AutoSellEpic or false,
    Legendary = ConfigSystem.CurrentConfig.AutoSellLegendary or false
}

-- Biến lưu trạng thái Quest
local autoClaimQuestEnabled = ConfigSystem.CurrentConfig.AutoClaimQuest or false
local autoClaimQuestLoop = nil

-- Mapping giữa tên hiển thị và tên thật của map
local mapNameMapping = {
    ["Voocha Village"] = "OnePiece",
    ["Green Planet"] = "Namek",
    ["Demon Forest"] = "DemonSlayer",
    ["Leaf Village"] = "Naruto",
    ["Z City"] = "OPM",
    ["Ghoul City"] = "TokyoGhoul"
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
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoinMapEnabled = ConfigSystem.CurrentConfig.AutoJoinMap or false
local autoJoinMapLoop = nil
-- Biến lưu trạng thái Auto Join Highest Story
local autoJoinHighestStoryEnabled = ConfigSystem.CurrentConfig.AutoJoinHighestStory or false
local autoJoinHighestStoryLoop = nil
local isInHighestStory = false

-- Biến lưu trạng thái Ranger Stage
local selectedRangerMap = ConfigSystem.CurrentConfig.SelectedRangerMap or "OnePiece"
local selectedRangerDisplayMap = reverseMapNameMapping[selectedRangerMap] or "Voocha Village"
-- Thêm biến lưu các map đã chọn
local selectedRangerMaps = ConfigSystem.CurrentConfig.SelectedRangerMaps or
    { [selectedRangerMap] = true } -- Lưu dạng table {MapName = true}
local selectedActs = ConfigSystem.CurrentConfig.SelectedActs or { RangerStage1 = true }
local currentActIndex = 1          -- Lưu trữ index của Act hiện tại đang được sử dụng
local orderedActs = {}             -- Lưu trữ danh sách các Acts theo thứ tự
local rangerFriendOnly = ConfigSystem.CurrentConfig.RangerFriendOnly or false
local autoJoinRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinRanger or false
local autoJoinRangerLoop = nil

-- Biến lưu trạng thái Boss Event
local autoBossEventEnabled = ConfigSystem.CurrentConfig.AutoBossEvent or false
local autoBossEventLoop = nil

-- Biến lưu trạng thái Challenge
local autoChallengeEnabled = ConfigSystem.CurrentConfig.AutoChallenge or false
local autoChallengeLoop = nil
local challengeTimeDelay = ConfigSystem.CurrentConfig.ChallengeTimeDelay or 5

-- Biến lưu trạng thái In-Game
local autoPlayEnabled = ConfigSystem.CurrentConfig.AutoPlay or false
local autoRetryEnabled = ConfigSystem.CurrentConfig.AutoRetry or false
local autoNextEnabled = ConfigSystem.CurrentConfig.AutoNext or false
local autoVoteEnabled = ConfigSystem.CurrentConfig.AutoVote or false
local autoRetryLoop = nil
local autoNextLoop = nil
local autoVoteLoop = nil

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

-- Biến lưu trạng thái Time Delay
local storyTimeDelay = ConfigSystem.CurrentConfig.StoryTimeDelay or 5
local rangerTimeDelay = ConfigSystem.CurrentConfig.RangerTimeDelay or 5
local bossEventTimeDelay = ConfigSystem.CurrentConfig.BossEventTimeDelay or 5

-- Biến lưu trạng thái AFK
local autoJoinAFKEnabled = ConfigSystem.CurrentConfig.AutoJoinAFK or false
local autoJoinAFKLoop = nil

-- Biến lưu trạng thái Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUI or false
local autoHideUITimer = nil

-- Thông tin người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Tạo Window
local Window = Fluent:CreateWindow({
    Title = "Kaihon Hub | Anime Rangers X",
    SubTitle = "",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 350),
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
    Icon = "rbxassetid://7743871480"
})

-- Tạo tab In-Game
local InGameTab = Window:AddTab({
    Title = "In-Game",
    Icon = "rbxassetid://7733799901"
})


-- Tạo tab Portal
local PortalTab = Window:AddTab({
    Title = "Portal",
    Icon = "rbxassetid://7734068321"
})

-- Tạo tab Unit
local UnitTab = Window:AddTab({
    Title = "Unit",
    Icon = "rbxassetid://7743866529"
})

-- Tạo tab Shop
local ShopTab = Window:AddTab({
    Title = "Shop",
    Icon = "rbxassetid://7734056747"
})

-- Tạo tab Webhook
local WebhookTab = Window:AddTab({
    Title = "Webhook",
    Icon = "rbxassetid://7734058803"
})

-- Tạo tab Settings
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "rbxassetid://6031280882"
})


-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://124432203914164" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl"              -- Phím để bật/tắt giao diện

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
            ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
            ImageButton.Size = UDim2.new(0, 50, 0, 50)
            ImageButton.Image = getgenv().Image
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2

            UICorner.CornerRadius = UDim.new(0, 200)
            UICorner.Parent = ImageButton

            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, getgenv().ToggleUI, false, game)
            end)
        end
    end)

    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

-- Tự động chọn tab Info khi khởi động
Window:SelectTab(1) -- Chọn tab đầu tiên (Info)

-- Thêm section thông tin trong tab Info
local InfoSection = InfoTab:AddSection("Thông tin")

InfoSection:AddParagraph({
    Title = "Anime Rangers X",
    Content = "Phiên bản: 0.6 Beta\nTrạng thái: Hoạt động"
})

InfoSection:AddParagraph({
    Title = "Người phát triển",
    Content = "Script được phát triển bởi Dương Tuấn và ghjiukliop"
})

-- Tạo Paragraph để hiển thị thông tin Challenge
local challengeInfoParagraph = InfoSection:AddParagraph({
    Title = "Current Challenge Info",
    Content = "Đang tải thông tin Challenge..."
})

-- Hàm để cập nhật thông tin Challenge
local function updateChallengeInfo()
    -- Đảm bảo đường dẫn là đúng
    local challengePath = game:GetService("ReplicatedStorage"):FindFirstChild("Gameplay")
    if not challengePath then
        challengeInfoParagraph:SetDesc("Không tìm thấy thông tin Challenge")
        return
    end

    challengePath = challengePath:FindFirstChild("Game")
    if not challengePath then
        challengeInfoParagraph:SetDesc("Không tìm thấy thông tin Challenge")
        return
    end

    challengePath = challengePath:FindFirstChild("Challenge")
    if not challengePath then
        challengeInfoParagraph:SetDesc("Không tìm thấy thông tin Challenge")
        return
    end

    -- Lấy các giá trị
    local challengeName = challengePath:FindFirstChild("ChallengeName") and challengePath.ChallengeName.Value or "N/A"
    local chapter = challengePath:FindFirstChild("Chapter") and challengePath.Chapter.Value or "N/A"
    local world = challengePath:FindFirstChild("World") and challengePath.World.Value or "N/A"

    -- Xử lý hiển thị Chapter (chỉ lấy số nếu là dạng World_ChapterX)
    local chapterNumber = chapter:match("Chapter(%d+)")
    if chapterNumber then
        chapter = chapterNumber
    end

    -- Xử lý hiển thị World (chuyển từ tên thật sang tên hiển thị)
    if reverseMapNameMapping[world] then
        world = reverseMapNameMapping[world]
    end

    -- Quét và hiển thị Items
    local itemsText = ""
    local itemsFolder = challengePath:FindFirstChild("Items")
    if itemsFolder then
        for _, item in pairs(itemsFolder:GetChildren()) do
            -- Lấy tên item và số lượng nếu có
            local itemValue = ""
            if item:IsA("StringValue") or item:IsA("NumberValue") or item:IsA("IntValue") then
                itemValue = tostring(item.Value)
            else
                itemValue = item.Name
            end

            itemsText = itemsText .. "• " .. item.Name
            if itemValue ~= item.Name then
                itemsText = itemsText .. ": " .. itemValue
            end
            itemsText = itemsText .. "\n"
        end
    else
        itemsText = "Không có item nào"
    end

    -- Cập nhật nội dung Paragraph
    local content = "ChallengeName: " .. challengeName .. "\n" ..
        "Chapter: " .. chapter .. "\n" ..
        "World: " .. world .. "\n" ..
        "Items:\n" .. itemsText

    challengeInfoParagraph:SetDesc(content)
end

-- Thiết lập vòng lặp cập nhật thông tin Challenge
spawn(function()
    while wait(1) do -- Cập nhật mỗi 1 giây
        pcall(updateChallengeInfo)
    end
end)

-- Kiểm tra xem người chơi đã ở trong map chưa
local function isPlayerInMap()
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end

    -- Kiểm tra UnitsFolder một cách hiệu quả
    return player:FindFirstChild("UnitsFolder") ~= nil
end

local function isPlayerInRangerStageMap()
    -- Path: ReplicatedStorage -> Values -> Game -> Gamemode (StringValue)
    local gamemodeStringValue = safeGetPath(game:GetService("ReplicatedStorage"), { "Values", "Game", "Gamemode" }, 0.1) -- waitTime 0.1s

    if gamemodeStringValue and gamemodeStringValue:IsA("StringValue") then
        if gamemodeStringValue.Value == "Ranger Stage" then
            -- print("Currently in Ranger Stage map.") -- For debugging
            return true
        else
            -- print("Gamemode is: " .. gamemodeStringValue.Value .. ", not Ranger Stage.") -- For debugging
            return false
        end
    else
        -- print("Gamemode StringValue not found at ReplicatedStorage.Values.Game.Gamemode") -- For debugging
        return false
    end
end

-- Thêm section Story trong tab Play
local StorySection = PlayTab:AddSection("Story")

-- Hàm để thay đổi map
local function changeWorld(worldDisplay)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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

-- Hàm để kiểm tra xem có phải đang ở màn hình rewards với mode Ranger Stage và Act 5 không
local function isRangerStageAct5RewardsUI()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end

        -- Kiểm tra UI RewardsUI
        local rewardsUI = player.PlayerGui:FindFirstChild("RewardsUI")
        if not rewardsUI then return false end

        local main = rewardsUI:FindFirstChild("Main")
        if not main then return false end

        local leftSide = main:FindFirstChild("LeftSide")
        if not leftSide then return false end

        -- Kiểm tra Mode (Ranger Stage)
        local mode = leftSide:FindFirstChild("Mode")
        if not mode or mode.Text ~= "Ranger Stage" then return false end

        -- Kiểm tra Chapter (Act 5 - Wings of the Abyss)
        local chapter = leftSide:FindFirstChild("Chapter")
        if not chapter or chapter.Text ~= "Act 5 - Wings of the Abyss" then return false end

        return true
    end)

    if not success then
        warn("Lỗi khi kiểm tra Ranger Stage Act 5 RewardsUI: " .. tostring(result))
        return false
    end

    return result
end

-- Hàm lấy giá trị Level hiện tại từ DataValue
local function getCurrentLevel()
    local levelValue = game:GetService("ReplicatedStorage"):FindFirstChild("Values")
        and game:GetService("ReplicatedStorage").Values:FindFirstChild("Game")
        and game:GetService("ReplicatedStorage").Values.Game:FindFirstChild("Level")

    if levelValue then
        print("Current Level from DataValue:", levelValue.Value)
        return levelValue.Value
    end

    return nil
end

-- Hàm tìm và join highest story
local function findAndJoinHighestStory()
    if isInHighestStory then
        print("Người chơi đang ở trong map cao nhất, không thực hiện join.")
        return
    end

    local player = game:GetService("Players").LocalPlayer
    local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")
    local playerFolder = playerData and playerData:FindFirstChild(player.Name)
    local chapterLevels = playerFolder and playerFolder:FindFirstChild("ChapterLevels")

    -- Map thứ tự ưu tiên
    local mapOrder = { "OnePiece", "Namek", "DemonSlayer", "Naruto", "OPM", "TokyoGhoul" }
    local highestMap, highestChapter = nil, nil

    if chapterLevels then
        for i = #mapOrder, 1, -1 do
            local map = mapOrder[i]
            if chapterLevels:FindFirstChild(map .. "_Chapter1") then
                for j = 10, 1, -1 do
                    local chapterName = map .. "_Chapter" .. j
                    if chapterLevels:FindFirstChild(chapterName) then
                        highestMap = map
                        highestChapter = "Chapter" .. j
                        break
                    end
                end
            end
            if highestMap then break end
        end
    end

    if highestMap and highestChapter then
        local currentLevel = getCurrentLevel()
        local highestLevel = highestMap .. "_" .. highestChapter

        if currentLevel == highestLevel then
            print("Người chơi đang ở level cao nhất: " .. highestLevel)
            isInHighestStory = true
            return
        end

        print("Đã tìm thấy highest story để join: " .. highestLevel)

        -- Thực hiện join map
        local function joinMap()
            local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote"):FindFirstChild("Server")
                :FindFirstChild("PlayRoom"):FindFirstChild("Event")
            if not Event then
                warn("Không tìm thấy Event để join map.")
                return
            end
            Event:FireServer("Create")
            wait(0.5)
            Event:FireServer("Change-World", { ["World"] = highestMap })
            wait(0.5)
            Event:FireServer("Change-Chapter", { ["Chapter"] = highestLevel })
            wait(0.5)
            Event:FireServer("Change-Difficulty", { ["Difficulty"] = "Normal" })
            wait(0.5)
            Event:FireServer("Submit")
            wait(1)
            Event:FireServer("Start")
            print("Đã join map: " .. highestLevel)
            isInHighestStory = true
        end

        joinMap()
    else
        print("Không tìm thấy highest story để join.")
    end
end

-- Hàm xử lý toggle Auto Join Highest Story
local function toggleAutoJoinHighestStory(state)
    autoJoinHighestStoryEnabled = state
    ConfigSystem.CurrentConfig.AutoJoinHighestStory = state
    ConfigSystem.SaveConfig()
    isInHighestStory = false

    if autoJoinHighestStoryEnabled then
        print("Auto Join Highest Story đã được bật")
        autoJoinHighestStoryLoop = task.spawn(function()
            while autoJoinHighestStoryEnabled do
                findAndJoinHighestStory()
                wait(10)
            end
        end)
    else
        print("Auto Join Highest Story đã được tắt")
        if autoJoinHighestStoryLoop then
            task.cancel(autoJoinHighestStoryLoop)
            autoJoinHighestStoryLoop = nil
        end
    end
end

-- Hàm để tự động tham gia map
local function joinMap()
    -- Kiểm tra nếu đang ở Ranger Stage: Act 5 - Wings of the Abyss thì join ngay lập tức
    if isRangerStageAct5RewardsUI() then
        print("Phát hiện Ranger Stage: Act 5 - Wings of the Abyss, tham gia ngay lập tức")
        -- Bỏ qua kiểm tra người chơi có đang ở trong map hay không
    else
        -- Kiểm tra xem người chơi đã ở trong map chưa
        if isPlayerInMap() then
            print("Đã phát hiện người chơi đang ở trong map, không thực hiện join map")
            return false
        end
    end

    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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

-- Dropdown để chọn Map
StorySection:AddDropdown("MapDropdown", {
    Title = "Map",
    Values = { "Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City", "Ghoul City" },
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
    Title = "Chapter",
    Values = { "Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10" },
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

-- Dropdown để chọn Difficulty
StorySection:AddDropdown("DifficultyDropdown", {
    Title = "Difficulty",
    Values = { "Normal", "Hard", "Nightmare" },
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal",
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()

        -- Thay đổi difficulty khi người dùng chọn
        changeDifficulty(Value)
        print("Đã chọn difficulty: " .. Value)
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
            print("Đã bật chế độ Friend Only")
        else
            print("Đã tắt chế độ Friend Only")
        end
    end
})

-- Cập nhật Toggle Auto Join Map để kiểm tra và xử lý trường hợp Ranger Stage Act 5
StorySection:AddToggle("AutoJoinMapToggle", {
    Title = "Auto Join Map",
    Default = ConfigSystem.CurrentConfig.AutoJoinMap or false,
    Callback = function(Value)
        autoJoinMapEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinMap = Value
        ConfigSystem.SaveConfig()

        if autoJoinMapEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Join Map sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Join Map đã được bật, sẽ bắt đầu sau " .. storyTimeDelay .. " giây")

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
                    -- Kiểm tra nếu đang ở màn hình Ranger Stage Act 5 thì join ngay lập tức
                    if isRangerStageAct5RewardsUI() then
                        print("Phát hiện Ranger Stage: Act 5 - Wings of the Abyss trên RewardsUI, tham gia ngay lập tức")
                        joinMap()
                        -- Nếu không phải màn hình Ranger Stage Act 5, thì mới kiểm tra người chơi có đang ở trong map không
                    elseif not isPlayerInMap() then
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
            print("Auto Join Map đã được tắt")
        end
    end
})

StorySection:AddToggle("AutoJoinHighestStoryToggle", {
    Title = "Auto Join Highest Story",
    Default = ConfigSystem.CurrentConfig.AutoJoinHighestStory or false,
    Callback = function(value)
        toggleAutoJoinHighestStory(value)
    end
})

-- Thêm section Summon trong tab Shop
local SummonSection = ShopTab:AddSection("Summon")

-- Hàm thực hiện summon
local function performSummon()
    -- An toàn kiểm tra Remote có tồn tại không
    local success, err = pcall(function()
        local Remote = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "Gambling", "UnitsGacha" },
            2)

        if Remote then
            local args = {
                [1] = selectedSummonAmount,
                [2] = selectedSummonBanner,
                [3] = {
                    Rare = autoSellRarities.Rare,
                    Epic = autoSellRarities.Epic,
                    Legendary = autoSellRarities.Legendary
                }
            }

            Remote:FireServer(unpack(args))

            local autoSellInfo = ""
            if autoSellRarities.Rare or autoSellRarities.Epic or autoSellRarities.Legendary then
                autoSellInfo = " với Auto Sell: "
                local sellTypes = {}
                if autoSellRarities.Rare then table.insert(sellTypes, "Rare") end
                if autoSellRarities.Epic then table.insert(sellTypes, "Epic") end
                if autoSellRarities.Legendary then table.insert(sellTypes, "Legendary") end
                autoSellInfo = autoSellInfo .. table.concat(sellTypes, ", ")
            end

            print("Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner .. autoSellInfo)
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
    Title = "Summon",
    Values = { "x1", "x10" },
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
    Title = "Banner",
    Values = { "Standard", "Rateup" },
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SummonBanner or "Standard",
    Callback = function(Value)
        selectedSummonBanner = Value
        ConfigSystem.CurrentConfig.SummonBanner = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn banner: " .. Value)
    end
})

-- Dropdown cho Auto Sell
SummonSection:AddDropdown("AutoSellDropdown", {
    Title = "Auto Sell",
    Values = { "Rare", "Epic", "Legendary" },
    Multi = true,
    Default = {
        Rare = ConfigSystem.CurrentConfig.AutoSellRare or false,
        Epic = ConfigSystem.CurrentConfig.AutoSellEpic or false,
        Legendary = ConfigSystem.CurrentConfig.AutoSellLegendary or false
    },
    Callback = function(Values)
        autoSellRarities.Rare = Values.Rare or false
        autoSellRarities.Epic = Values.Epic or false
        autoSellRarities.Legendary = Values.Legendary or false

        -- Lưu cấu hình
        ConfigSystem.CurrentConfig.AutoSellRare = autoSellRarities.Rare
        ConfigSystem.CurrentConfig.AutoSellEpic = autoSellRarities.Epic
        ConfigSystem.CurrentConfig.AutoSellLegendary = autoSellRarities.Legendary
        ConfigSystem.SaveConfig()

        -- Hiển thị thông báo
        local selectedTypes = {}
        if autoSellRarities.Rare then table.insert(selectedTypes, "Rare") end
        if autoSellRarities.Epic then table.insert(selectedTypes, "Epic") end
        if autoSellRarities.Legendary then table.insert(selectedTypes, "Legendary") end

        if #selectedTypes > 0 then
            print("Đã bật Auto Sell cho: " .. table.concat(selectedTypes, ", "))
        else
            print("Đã tắt Auto Sell")
        end
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

        -- Tạo biến mới để kiểm soát click độc lập
        local autoClickEnabled = true

        if autoSummonEnabled then
            print("Auto Summon đã được bật")

            -- Tạo vòng lặp Auto Summon
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end

            -- Hàm để mô phỏng một click chuột
            local function simulateClick()
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

                -- Lấy kích thước màn hình hiện tại
                local guiInset = game:GetService("GuiService"):GetGuiInset()
                local screenSize = workspace.CurrentCamera.ViewportSize

                -- Tính toán vị trí trung tâm màn hình (vị trí tốt nhất để click)
                local centerX = screenSize.X / 2
                local centerY = screenSize.Y / 2

                -- Tạo click tại trung tâm màn hình
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                wait(0.05) -- Độ trễ nhỏ
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)

                -- Thử click thêm vài vị trí nếu cần thiết (4 góc màn hình)
                local testPositions = {
                    { X = centerX,       Y = centerY },       -- Trung tâm
                    { X = centerX * 0.9, Y = centerY * 1.5 }, -- Phía dưới
                    { X = centerX * 1.5, Y = centerY * 0.9 }, -- Phía phải
                    { X = centerX * 0.5, Y = centerY * 0.5 }  -- Phía trên bên trái
                }

                for _, pos in ipairs(testPositions) do
                    if pos.X > 0 and pos.X < screenSize.X and pos.Y > 0 and pos.Y < screenSize.Y then
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                        wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                        wait(0.05)
                    end
                end

                -- Thông báo debug
                print("Đã thực hiện click tự động trên màn hình " .. screenSize.X .. "x" .. screenSize.Y)
            end

            -- Tạo vòng lặp riêng cho Auto Summon
            spawn(function()
                while autoSummonEnabled do
                    -- Bước 1: Thực hiện summon ngay lập tức
                    performSummon()

                    -- Bước 2: Đợi 2 giây
                    wait(2)

                    -- Bước 3: Click nhiều lần dựa trên loại summon
                    local clickCount = selectedSummonAmount == "x1" and 1 or 8
                    print("Đang thực hiện " .. clickCount .. " lần click cho summon " .. selectedSummonAmount)

                    for i = 1, clickCount do
                        if not autoSummonEnabled then break end
                        simulateClick()
                        wait(0.5) -- Đợi 0.5 giây giữa các lần click
                    end

                    -- Kiểm tra lại xem Auto Summon có còn được bật không
                    if not autoSummonEnabled then break end

                    -- Bước 4: Tiếp tục vòng lặp (không cần wait thêm, vì lúc này sẽ bắt đầu lại từ đầu)
                end
            end)

            -- Tạo vòng lặp riêng cho Auto Click
            spawn(function()
                -- Gọi simulateClick ngay lập tức không cần đợi
                simulateClick()

                -- Tiếp tục vòng lặp click mà không phụ thuộc vào autoSummonEnabled
                while autoClickEnabled and wait(0.1) do -- Click mỗi 0.1 giây
                    simulateClick()

                    -- Kiểm tra nếu Auto Summon đã bị tắt thì dừng vòng lặp
                    if not autoSummonEnabled then
                        autoClickEnabled = false
                    end
                end
            end)
        else
            print("Auto Summon đã được tắt")

            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end

            -- Đảm bảo dừng vòng lặp click khi tắt Auto Summon
            autoClickEnabled = false
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
        local QuestEvent = safeGetPath(ReplicatedStorage, { "Remote", "Server", "Gameplay", "QuestEvent" }, 2)
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

-- Toggle Auto Claim All Quest
QuestSection:AddToggle("AutoClaimQuestToggle", {
    Title = "Auto Claim All Quests",
    Default = ConfigSystem.CurrentConfig.AutoClaimQuest or false,
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()

        if autoClaimQuestEnabled then
            print("Auto Claim Quests đã được bật")

            -- Tạo vòng lặp Auto Claim Quests
            spawn(function()
                while autoClaimQuestEnabled and wait(1) do -- Claim mỗi 30 giây
                    claimAllQuests()
                end
            end)
        else
            print("Auto Claim Quests đã được tắt")
        end
    end
})

-- Thêm section thiết lập trong tab Settings
local SettingsSection = SettingsTab:AddSection("Thiết lập")

-- Dropdown chọn theme
SettingsSection:AddDropdown("ThemeDropdown", {
    Title = "Chọn Theme",
    Values = { "Dark", "Light", "Darker", "Aqua", "Amethyst" },
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
    for _, tab in pairs({ InfoTab, PlayTab, ShopTab, SettingsTab, PortalTab, UnitTab, InGameTab, WebhookTab }) do
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

-- Khởi tạo các vòng lặp tối ưu
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
                    wait(1) -- Đợi để xem đã vào map chưa
                    shouldContinue = isPlayerInMap()
                end

                -- Kiểm tra Auto Join Ranger
                if autoJoinRangerEnabled and not shouldContinue then
                    cycleRangerStages()
                    wait(1)
                    shouldContinue = isPlayerInMap()
                end

                -- Kiểm tra Auto Boss Event
                if autoBossEventEnabled and not shouldContinue then
                    joinBossEvent()
                    wait(1)
                    shouldContinue = isPlayerInMap()
                end

                -- Kiểm tra Auto Challenge
                if autoChallengeEnabled and not shouldContinue then
                    joinChallenge()
                    wait(1)
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

-- Thêm section Ranger Stage trong tab Play
local RangerSection = PlayTab:AddSection("Ranger Stage")

-- Hàm để thay đổi act
local function changeAct(map, act)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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

-- Hàm để tự động tham gia Ranger Stage (Sửa đổi để nhận map và act)
local function joinRangerStage(mapToJoin, actToJoin)
    -- Kiểm tra xem người chơi đã ở trong map Ranger Stage chưa
    if isPlayerInRangerStageMap() then
        print("Đã phát hiện người chơi đang ở trong map Ranger Stage, không thực hiện join Ranger Stage")
        return false
    end

    -- Nếu không có map/act cụ thể được cung cấp, dùng giá trị từ UI
    if not mapToJoin or not actToJoin then
        updateOrderedActs()
        if #orderedActs == 0 then
            warn("Không có Act nào được chọn để join Ranger Stage (UI)")
            return false
        end
        mapToJoin = selectedRangerMap            -- Lấy từ UI
        actToJoin = orderedActs[currentActIndex] -- Lấy từ UI
    end

    -- Kiểm tra lại nếu map/act vẫn nil
    if not mapToJoin or not actToJoin then
        warn("Map hoặc Act không hợp lệ để join Ranger Stage")
        return false
    end

    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)
        if not Event then
            warn("Không tìm thấy Event để join Ranger Stage"); return
        end

        -- 1. Create
        Event:FireServer("Create")
        wait(0.1)

        -- 2. Change Mode to Ranger Stage
        local modeArgs = { [1] = "Change-Mode", [2] = { ["Mode"] = "Ranger Stage" } }
        Event:FireServer(unpack(modeArgs))
        wait(0.1)

        -- 3. Friend Only (sử dụng cài đặt global)
        if rangerFriendOnly then
            Event:FireServer("Change-FriendOnly")
            wait(0.1)
        end

        -- 4. Chọn Map và Act (sử dụng tham số đầu vào)
        -- 4.1 Đổi Map
        local args1 = { [1] = "Change-World", [2] = { ["World"] = mapToJoin } }
        Event:FireServer(unpack(args1))
        wait(0.1)

        -- 4.2 Đổi Act
        local args2 = { [1] = "Change-Chapter", [2] = { ["Chapter"] = mapToJoin .. "_" .. actToJoin } }
        Event:FireServer(unpack(args2))
        wait(0.1)

        -- 5. Submit
        Event:FireServer("Submit")
        wait(0.1)

        -- 6. Start
        Event:FireServer("Start")
        wait(0.1)
        print("Đã join Ranger Stage: " .. mapToJoin .. "_" .. actToJoin)

        -- Cập nhật index cho lần tiếp theo chỉ khi dùng giá trị từ UI
        if not mapToJoin or not actToJoin then
            currentActIndex = (currentActIndex % #orderedActs) + 1
        end
    end)

    if not success then
        warn("Lỗi khi join Ranger Stage: " .. tostring(err))
        return false
    end

    return true
end

-- Hàm để lặp qua các selected Acts (Sửa đổi để không cần thiết nữa nếu chỉ dùng cho Auto Join All)
-- local function cycleRangerStages() ... end -- Có thể xóa hoặc giữ lại nếu vẫn cần Auto Join Ranger theo UI

-- Lưu biến cho Story Time Delay
local storyTimeDelayInput = nil


-- Input cho Story Time Delay
storyTimeDelayInput = StorySection:AddInput("StoryTimeDelayInput", {
    Title = "Delay (1-30s)", -- Thêm min/max vào Title
    Placeholder = "Nhập delay",
    Default = tostring(storyTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            storyTimeDelay = numValue
            ConfigSystem.CurrentConfig.StoryTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Story Time Delay (Input): " .. numValue .. " giây")
            -- Bỏ cập nhật Slider
            -- if storyTimeDelaySlider and storyTimeDelaySlider.Set then storyTimeDelaySlider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            -- Reset Input về giá trị cũ nếu không hợp lệ
            if storyTimeDelayInput and storyTimeDelayInput.Set then storyTimeDelayInput:Set(tostring(storyTimeDelay)) end
        end
    end
})

-- Dropdown để chọn Map cho Ranger
RangerSection:AddDropdown("RangerMapDropdown", {
    Title = "Map",        -- Sửa tiêu đề
    Values = { "Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City", "Ghoul City" },
    Multi = true,         -- Cho phép chọn nhiều
    Default = (function() -- Khôi phục trạng thái đã chọn từ config
        local defaults = {}
        for mapName, isSelected in pairs(selectedRangerMaps) do
            local displayMap = reverseMapNameMapping[mapName]
            if displayMap and isSelected then
                defaults[displayMap] = true
            end
        end
        -- Đảm bảo luôn có ít nhất 1 map được chọn ban đầu nếu config rỗng
        if next(defaults) == nil and reverseMapNameMapping[selectedRangerMap] then
            defaults[reverseMapNameMapping[selectedRangerMap]] = true
        end
        return defaults
    end)(),
    Callback = function(Values)
        selectedRangerMaps = {} -- Reset trước khi cập nhật
        local firstSelectedMap = nil
        local firstSelectedDisplayMap = nil
        for displayMap, isSelected in pairs(Values) do
            local realMap = mapNameMapping[displayMap]
            if realMap and isSelected then
                selectedRangerMaps[realMap] = true
                if not firstSelectedMap then
                    firstSelectedMap = realMap
                    firstSelectedDisplayMap = displayMap
                end
                print("Đã chọn Ranger map: " .. displayMap .. " (thực tế: " .. realMap .. ")")
            end
        end
        -- Cập nhật selectedRangerMap (dùng cho các chức năng khác nếu cần) thành map đầu tiên được chọn
        selectedRangerMap = firstSelectedMap or "OnePiece"
        selectedRangerDisplayMap = firstSelectedDisplayMap or "Voocha Village"

        ConfigSystem.CurrentConfig.SelectedRangerMaps = selectedRangerMaps
        ConfigSystem.CurrentConfig.SelectedRangerMap = selectedRangerMap -- Lưu map đầu tiên làm map chính (nếu cần)
        ConfigSystem.SaveConfig()

        -- Thông báo (có thể bỏ nếu không muốn)
        local selectedMapsText = ""
        for map, isSelected in pairs(selectedRangerMaps) do
            if isSelected then selectedMapsText = selectedMapsText .. (reverseMapNameMapping[map] or map) .. ", " end
        end
        if selectedMapsText ~= "" then
            selectedMapsText = selectedMapsText:sub(1, -3)
            print("Các map Ranger đã chọn: " .. selectedMapsText)
        else
            print("Chưa chọn map Ranger nào.")
        end
    end
})

-- Dropdown để chọn Act
RangerSection:AddDropdown("ActDropdown", {
    Title = "Act",
    Values = { "RangerStage1", "RangerStage2", "RangerStage3", "RangerStage4", "RangerStage5" },
    Multi = true,
    Default = ConfigSystem.CurrentConfig.SelectedActs or { RangerStage1 = true },
    Callback = function(Values)
        selectedActs = Values
        ConfigSystem.CurrentConfig.SelectedActs = Values
        ConfigSystem.SaveConfig()

        -- Cập nhật danh sách Acts đã sắp xếp
        updateOrderedActs()

        -- Hiển thị thông báo khi người dùng chọn act
        local selectedActsText = ""
        for act, isSelected in pairs(Values) do
            if isSelected then
                selectedActsText = selectedActsText .. act .. ", "

                -- Thay đổi act khi người dùng chọn
                changeAct(selectedRangerMap, act)
                print("Đã chọn act: " .. act)
                wait(0.1) -- Đợi 0.5 giây giữa các lần gửi để tránh lỗi
            end
        end

        if selectedActsText ~= "" then
            selectedActsText = selectedActsText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            print("Đã chọn act: " .. selectedActsText)
        else
            print("Bạn chưa chọn act nào! Vui lòng chọn ít nhất một act.")
        end
    end
})

-- Toggle Friend Only cho Ranger
RangerSection:AddToggle("RangerFriendOnlyToggle", {
    Title = "Friend Only",
    Default = ConfigSystem.CurrentConfig.RangerFriendOnly or false,
    Callback = function(Value)
        rangerFriendOnly = Value
        ConfigSystem.CurrentConfig.RangerFriendOnly = Value
        ConfigSystem.SaveConfig()

        -- Toggle Friend Only khi người dùng thay đổi
        toggleRangerFriendOnly()

        if Value then
            print("Đã bật chế độ Friend Only cho Ranger Stage")
        else
            print("Đã tắt chế độ Friend Only cho Ranger Stage")
        end
    end
})

-- Lưu biến cho Ranger Time Delay
local rangerTimeDelayInput = nil

-- Input cho Ranger Time Delay (Giữ lại, sửa callback)
rangerTimeDelayInput = RangerSection:AddInput("RangerTimeDelayInput", {
    Title = "Delay (1-30s)",
    Placeholder = "Nhập delay",
    Default = tostring(rangerTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            rangerTimeDelay = numValue
            ConfigSystem.CurrentConfig.RangerTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Ranger Time Delay (Input): " .. numValue .. " giây")
            -- Bỏ cập nhật Slider
            -- if rangerTimeDelaySlider and rangerTimeDelaySlider.Set then rangerTimeDelaySlider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            if rangerTimeDelayInput and rangerTimeDelayInput.Set then rangerTimeDelayInput:Set(tostring(rangerTimeDelay)) end
        end
    end
})

-- Hàm kiểm tra cooldown của map và act
local function isMapActOnCooldown(mapName, actName)
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end

        local playerName = player.Name
        local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")
        if not playerData then return false end

        local playerFolder = playerData:FindFirstChild(playerName)
        if not playerFolder then return false end

        local rangerStageFolder = playerFolder:FindFirstChild("RangerStage")
        if not rangerStageFolder then return false end

        -- Kiểm tra xem map_act này có đang trong cooldown không
        local mapActKey = mapName .. "_" .. actName
        return rangerStageFolder:FindFirstChild(mapActKey) ~= nil
    end)

    if not success then
        warn("Lỗi khi kiểm tra cooldown cho " .. mapName .. "_" .. actName .. ": " .. tostring(result))
        return false
    end

    return result
end

-- Cải tiến hàm Auto Join Ranger Stage để thông minh hơn với việc xử lý cooldown
RangerSection:AddToggle("AutoJoinRangerToggle", {
    Title = "Auto Join Selected Stage", -- Đổi tên cho rõ nghĩa
    Default = ConfigSystem.CurrentConfig.AutoJoinRanger or false,
    Callback = function(Value)
        autoJoinRangerEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinRanger = Value
        ConfigSystem.SaveConfig()

        if autoJoinRangerEnabled then
            -- Kiểm tra xem có Map nào được chọn không
            local hasSelectedMap = false
            for _, isSelected in pairs(selectedRangerMaps) do
                if isSelected then
                    hasSelectedMap = true; break;
                end
            end
            if not hasSelectedMap then
                print("Chưa chọn map nào trong Ranger Stage!"); return
            end

            -- Kiểm tra xem có Act nào được chọn không
            local hasSelectedAct = false
            for _, isSelected in pairs(selectedActs) do
                if isSelected then
                    hasSelectedAct = true; break;
                end
            end
            if not hasSelectedAct then
                print("Chưa chọn act nào trong Ranger Stage!"); return
            end

            print("Auto Join Selected Ranger Stage đã được bật")
            if autoJoinRangerLoop then
                autoJoinRangerLoop:Disconnect(); autoJoinRangerLoop = nil;
            end

            autoJoinRangerLoop = spawn(function()
                while autoJoinRangerEnabled do
                    local didJoin = false

                    -- Kiểm tra nếu đang ở trong map Ranger Stage, đợi ra khỏi map trước
                    if isPlayerInRangerStageMap() then
                        print("Đang ở trong map Ranger Stage, đợi thoát...")
                        while isPlayerInRangerStageMap() and autoJoinRangerEnabled do wait(0.1) end
                        if not autoJoinRangerEnabled then return end
                        wait(0.5) -- Đợi một chút giữa các lần kiểm tra
                    end

                    -- Tìm map và act không bị cooldown để join
                    local availableMaps = {}

                    -- Thu thập tất cả map+act không bị cooldown
                    for map, mapSelected in pairs(selectedRangerMaps) do
                        if mapSelected then
                            for act, actSelected in pairs(selectedActs) do
                                if actSelected then
                                    if not isMapActOnCooldown(map, act) then
                                        table.insert(availableMaps, { map = map, act = act })
                                    else
                                        print(map .. "_" .. act .. " đang trong cooldown, sẽ bỏ qua")
                                    end
                                end
                            end
                        end
                    end

                    -- Nếu có map nào available, join map đó
                    if #availableMaps > 0 then
                        -- Ưu tiên map theo thứ tự (có thể tùy chỉnh logic sắp xếp nếu muốn)
                        local mapToJoin = availableMaps[1]
                        print("Chuẩn bị join map không có cooldown: " .. mapToJoin.map .. " - " .. mapToJoin.act)

                        -- Join map
                        joinRangerStage(mapToJoin.map, mapToJoin.act)
                        didJoin = true

                        -- Đợi vào map hoặc timeout
                        local t = 0
                        while not isPlayerInRangerStageMap() and t < 10 and autoJoinRangerEnabled do
                            wait(0.5); t = t + 0.5;
                        end

                        -- Nếu đã vào map, đợi delay
                        if isPlayerInRangerStageMap() and autoJoinRangerEnabled then
                            print("Đã vào map Ranger Stage, đợi " .. rangerTimeDelay .. " giây...")
                            wait(rangerTimeDelay)
                        end
                    else
                        print("Tất cả map đã chọn đều đang trong cooldown, đợi 5 giây và kiểm tra lại...")
                        wait(5)
                    end

                    -- Nếu không join được map nào, đợi một chút
                    if not didJoin and autoJoinRangerEnabled then
                        wait(1)
                    end
                end
            end)
        else
            print("Auto Join Selected Ranger Stage đã được tắt")
            if autoJoinRangerLoop then
                autoJoinRangerLoop:Disconnect(); autoJoinRangerLoop = nil;
            end
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
        print("Không tìm thấy kẻ địch và agent trong 10 giây, đang teleport về lobby...")

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
RangerSection:AddToggle("AutoLeaveToggle", {
    Title = "Auto Leave",
    Default = ConfigSystem.CurrentConfig.AutoLeave or false,
    Callback = function(Value)
        autoLeaveEnabled = Value
        ConfigSystem.CurrentConfig.AutoLeave = Value
        ConfigSystem.SaveConfig()

        if Value then
            print(
                "Auto Leave đã được bật. Sẽ tự động rời map nếu không có kẻ địch và agent trong 10 giây (chỉ khi đang ở trong map)")

            -- Hủy vòng lặp cũ nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end

            -- Tạo vòng lặp tối ưu để kiểm tra folders
            autoLeaveLoop = spawn(function()
                local checkInterval = 1 -- Kiểm tra mỗi 1 giây
                local maxEmptyTime = 10 -- Thời gian tối đa folder trống trước khi leave
                local emptyTime = 0

                while autoLeaveEnabled do
                    -- Chỉ kiểm tra khi người chơi đang ở trong map
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
                        -- Reset counter nếu không ở trong map
                        if emptyTime > 0 then
                            emptyTime = 0
                        end
                        -- Không cần print thông báo ở đây để tránh spam
                    end

                    wait(checkInterval)

                    -- Thoát vòng lặp nếu Auto Leave bị tắt
                    if not autoLeaveEnabled then
                        break
                    end
                end
            end)
        else
            print("Auto Leave đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoLeaveLoop then
                autoLeaveLoop:Disconnect()
                autoLeaveLoop = nil
            end
        end
    end
})

-- Thêm section Challenge trong tab Play
local ChallengeSection = PlayTab:AddSection("Challenge")

-- Hàm để kiểm tra xem có phải đang ở map Ranger Stage: Act 5 - Wings of the Abyss không
local function isRangerStageAct5()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end

        -- Kiểm tra UI RewardsUI
        local rewardsUI = player.PlayerGui:FindFirstChild("RewardsUI")
        if not rewardsUI then return false end

        local main = rewardsUI:FindFirstChild("Main")
        if not main then return false end

        local leftSide = main:FindFirstChild("LeftSide")
        if not leftSide then return false end

        -- Kiểm tra Mode (Ranger Stage)
        local mode = leftSide:FindFirstChild("Mode")
        if not mode or mode.Text ~= "Ranger Stage" then return false end

        -- Kiểm tra Chapter (Act 5 - Wings of the Abyss)
        local chapter = leftSide:FindFirstChild("Chapter")
        if not chapter or chapter.Text ~= "Act 5 - Wings of the Abyss" then return false end

        return true
    end)

    if not success then
        warn("Lỗi khi kiểm tra Ranger Stage Act 5: " .. tostring(result))
        return false
    end

    return result
end

local function joinChallenge()
    -- Kiểm tra nếu đang ở Ranger Stage: Act 5 - Wings of the Abyss thì join ngay lập tức
    if isRangerStageAct5() then
        print("Phát hiện Ranger Stage: Act 5 - Wings of the Abyss, tham gia ngay lập tức")
        -- Bỏ qua kiểm tra người chơi có đang ở trong map hay không
    else
        -- Chỉ kiểm tra xem người chơi đã ở trong map chưa nếu không phải Ranger Stage Act 5
        if isPlayerInMap() then
            print("Đã phát hiện người chơi đang ở trong map, không thực hiện join Challenge")
            return false
        end
    end

    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "PlayRoom", "Event" }, 2)

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

-- Lưu biến cho Challenge Time Delay
local challengeTimeDelayInput = nil

-- Input cho Challenge Time Delay
challengeTimeDelayInput = ChallengeSection:AddInput("ChallengeTimeDelayInput", {
    Title = "Delay (1-30s)",
    Placeholder = "Nhập delay",
    Default = tostring(challengeTimeDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            challengeTimeDelay = numValue
            ConfigSystem.CurrentConfig.ChallengeTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Challenge Time Delay (Input): " .. numValue .. " giây")
            -- Bỏ cập nhật Slider
            -- if challengeTimeDelaySlider and challengeTimeDelaySlider.Set then challengeTimeDelaySlider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-30)")
            if challengeTimeDelayInput and challengeTimeDelayInput.Set then
                challengeTimeDelayInput:Set(tostring(
                    challengeTimeDelay))
            end
        end
    end
})

-- Toggle Auto Challenge
ChallengeSection:AddToggle("AutoChallengeToggle", {
    Title = "Auto Challenge",
    Default = ConfigSystem.CurrentConfig.AutoChallenge or false,
    Callback = function(Value)
        autoChallengeEnabled = Value
        ConfigSystem.CurrentConfig.AutoChallenge = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Challenge sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Challenge đã được bật, sẽ bắt đầu sau " .. challengeTimeDelay .. " giây")

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
                    -- Kiểm tra nếu đang ở Ranger Stage: Act 5 - Wings of the Abyss thì join ngay lập tức
                    if isRangerStageAct5() then
                        print("Phát hiện Ranger Stage: Act 5 - Wings of the Abyss, tham gia ngay lập tức")
                        joinChallenge()
                        -- Nếu không, thì chỉ thực hiện join challenge nếu người chơi không ở trong map
                    elseif not isPlayerInMap() then
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
            print("Auto Challenge đã được tắt")
        end
    end
})

-- Thêm section In-Game Controls
local InGameSection = InGameTab:AddSection("Game Controls")

-- Thêm biến lưu trạng thái Auto TP Lobby
local autoTPLobbyEnabled = ConfigSystem.CurrentConfig.AutoTPLobby or false
local autoTPLobbyDelay = ConfigSystem.CurrentConfig.AutoTPLobbyDelay or 10 -- Mặc định 10 phút
local autoTPLobbyLoop = nil

-- Hàm để teleport về lobby
local function teleportToLobby()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")

        -- Hiển thị thông báo trước khi teleport
        print("Đang teleport về lobby...")

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

-- Lưu biến cho Auto TP Lobby Delay
local autoTPLobbyDelayInput = nil

-- Input cho Auto TP Lobby Delay
autoTPLobbyDelayInput = InGameSection:AddInput("AutoTPLobbyDelayInput", {
    Title = "Delay (1-60m) ",
    Placeholder = "Nhập phút",
    Default = tostring(autoTPLobbyDelay),
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 60 then
            autoTPLobbyDelay = numValue
            ConfigSystem.CurrentConfig.AutoTPLobbyDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Auto TP Lobby Delay (Input): " .. numValue .. " phút")
            -- Bỏ cập nhật Slider
            -- if autoTPLobbyDelaySlider and autoTPLobbyDelaySlider.Set then autoTPLobbyDelaySlider:Set(numValue) end
        else
            print("Giá trị delay không hợp lệ (1-60 phút)")
            if autoTPLobbyDelayInput and autoTPLobbyDelayInput.Set then
                autoTPLobbyDelayInput:Set(tostring(
                    autoTPLobbyDelay))
            end
        end
    end
})

-- Toggle Auto TP Lobby
InGameSection:AddToggle("AutoTPLobbyToggle", {
    Title = "Auto TP Lobby",
    Default = autoTPLobbyEnabled,
    Callback = function(Value)
        autoTPLobbyEnabled = Value
        ConfigSystem.CurrentConfig.AutoTPLobby = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto TP Lobby đã được bật, sẽ teleport sau " .. autoTPLobbyDelay .. " phút")

            -- Hủy vòng lặp cũ nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                local timeRemaining = autoTPLobbyDelay * 60 -- Chuyển đổi thành giây

                while autoTPLobbyEnabled and wait(1) do     -- Đếm ngược mỗi giây
                    timeRemaining = timeRemaining - 1

                    -- Hiển thị thông báo khi còn 1 phút
                    if timeRemaining == 60 then
                        print("Sẽ teleport về lobby trong 1 phút nữa")
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
            print("Auto TP Lobby đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end
        end
    end
})

-- Nút TP Lobby ngay lập tức
InGameSection:AddButton({
    Title = "TP Lobby Now",
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
        local AutoPlayRemote = safeGetPath(game:GetService("ReplicatedStorage"),
            { "Remote", "Server", "Units", "AutoPlay" }, 2)

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
InGameSection:AddToggle("AutoPlayToggle", {
    Title = "Auto Play",
    Default = ConfigSystem.CurrentConfig.AutoPlay or false,
    Callback = function(Value)
        -- Cập nhật cấu hình
        autoPlayEnabled = Value
        ConfigSystem.CurrentConfig.AutoPlay = Value
        ConfigSystem.SaveConfig()

        -- Kiểm tra trạng thái thực tế của AutoPlay
        local actualState = checkActualAutoPlayState()

        -- Chỉ toggle khi trạng thái mong muốn khác với trạng thái hiện tại
        if Value ~= actualState then
            if Value then
                toggleAutoPlay()
                print("Auto Play đã được bật")
            else
                toggleAutoPlay()
                print("Auto Play đã được tắt")
            end
        else
            print("Trạng thái Auto Play đã phù hợp (" .. (Value and "bật" or "tắt") .. ")")
        end
    end
})

-- Hàm để bật/tắt Auto Retry
local function toggleAutoRetry()
    local success, err = pcall(function()
        local AutoRetryRemote = safeGetPath(game:GetService("ReplicatedStorage"),
            { "Remote", "Server", "OnGame", "Voting", "VoteRetry" }, 2)

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
        local AutoNextRemote = safeGetPath(game:GetService("ReplicatedStorage"),
            { "Remote", "Server", "OnGame", "Voting", "VoteNext" }, 2)

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
        local AutoVoteRemote = safeGetPath(game:GetService("ReplicatedStorage"),
            { "Remote", "Server", "OnGame", "Voting", "VotePlaying" }, 2)

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

-- Cập nhật Toggle Auto Retry
InGameSection:AddToggle("AutoRetryToggle", {
    Title = "Auto Retry",
    Default = ConfigSystem.CurrentConfig.AutoRetry or false,
    Callback = function(Value)
        autoRetryEnabled = Value
        ConfigSystem.CurrentConfig.AutoRetry = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Retry đã được bật (bao gồm tự động click sau GameEndedAnimationUI)")

            -- Hủy vòng lặp cũ nếu có
            if autoRetryLoop then
                autoRetryLoop:Disconnect()
                autoRetryLoop = nil
            end

            -- Không tạo vòng lặp mới để tránh gửi yêu cầu liên tục
            -- Chỉ kích hoạt khi RewardsUI xuất hiện
        else
            print("Auto Retry đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoRetryLoop then
                autoRetryLoop:Disconnect()
                autoRetryLoop = nil
            end
        end
    end
})

-- Toggle Auto Next
InGameSection:AddToggle("AutoNextToggle", {
    Title = "Auto Next",
    Default = ConfigSystem.CurrentConfig.AutoNext or false,
    Callback = function(Value)
        autoNextEnabled = Value
        ConfigSystem.CurrentConfig.AutoNext = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Next đã được bật (bao gồm tự động click sau GameEndedAnimationUI)")

            -- Hủy vòng lặp cũ nếu có
            if autoNextLoop then
                autoNextLoop:Disconnect()
                autoNextLoop = nil
            end

            -- Không tạo vòng lặp mới để tránh gửi yêu cầu liên tục
            -- Chỉ kích hoạt khi RewardsUI xuất hiện
        else
            print("Auto Next đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoNextLoop then
                autoNextLoop:Disconnect()
                autoNextLoop = nil
            end
        end
    end
})

-- Toggle Auto Vote
InGameSection:AddToggle("AutoVoteToggle", {
    Title = "Auto Vote",
    Default = ConfigSystem.CurrentConfig.AutoVote or false,
    Callback = function(Value)
        autoVoteEnabled = Value
        ConfigSystem.CurrentConfig.AutoVote = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Vote đã được bật, sẽ bắt đầu ngay lập tức")
            -- Hủy vòng lặp cũ nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
            -- Gửi vote ngay lập tức
            toggleAutoVote()
            -- Tạo vòng lặp mới
            spawn(function()
                while autoVoteEnabled and wait(0.5) do -- Gửi yêu cầu mỗi 0.5 giây
                    toggleAutoVote()
                end
            end)
        else
            print("Auto Vote đã được tắt")
            -- Hủy vòng lặp nếu có
            if autoVoteLoop then
                autoVoteLoop:Disconnect()
                autoVoteLoop = nil
            end
        end
    end
})

-- Hàm để scan unit trong UnitsFolder
local function scanUnits()
    -- Lấy player
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then
        print(" Không tìm thấy LocalPlayer")
        return false
    end

    -- Đợi/kiểm tra UnitsFolder
    local unitsFolder = player:FindFirstChild("UnitsFolder")
    if not unitsFolder then
        print(" Không tìm thấy UnitsFolder")
        return false
    end

    print(" Bắt đầu scan UnitsFolder...")

    -- Mapping tiêu chuẩn cho 6/6 unit
    local slotMapping = {
        [1] = 1, -- Slot 1 vẫn đúng là slot 1
        [2] = 6, -- Slot 2 thực tế là slot 6
        [3] = 5, -- Slot 3 thực tế là slot 5
        [4] = 4, -- Slot 4 vẫn đúng là slot 4
        [5] = 3, -- Slot 5 thực tế là slot 3
        [6] = 2  -- Slot 6 thực tế là slot 2
    }

    -- Mapping cụ thể theo số lượng unit
    local customMappings = {
        -- Mapping cho 3/6 unit
        [3] = {
            [1] = 1, -- Slot 1 giữ nguyên
            [2] = 3, -- Slot 2 → update slot 3
            [3] = 2  -- Slot 3 → update slot 2
        },
        -- Mapping cho 4/6 unit
        [4] = {
            [1] = 1, -- Slot 1 giữ nguyên
            [2] = 4, -- Slot 2 → update slot 4
            [3] = 3, -- Slot 3 giữ nguyên
            [4] = 2  -- Slot 4 → update slot 2
        },
        -- Mapping cho 5/6 unit
        [5] = {
            [1] = 1, -- Slot 1 giữ nguyên
            [2] = 5, -- Slot 2 → update slot 5
            [3] = 4, -- Slot 3 → update slot 4
            [4] = 3, -- Slot 4 → update slot 3
            [5] = 2  -- Slot 5 → update slot 2
        }
    }

    -- Reset unitSlots
    unitSlots = {}

    -- Lấy danh sách unit
    local children = unitsFolder:GetChildren()
    local unitCount = #children

    -- Hiển thị các unit tìm thấy trực tiếp
    for i, unit in ipairs(children) do
        if i <= 6 then
            local unitName = unit:FindFirstChild("Name") and unit.Name.Value or unit.Name
            print(" Unit tìm thấy #" .. i .. ": " .. unitName)
        end
    end

    -- Tạo danh sách tạm
    local tempSlots = {}
    for i, unit in ipairs(children) do
        if i <= unitCount then
            tempSlots[i] = unit
        end
    end

    -- Áp dụng mapping dựa trên số lượng unit
    if unitCount == 6 then
        -- Case 6/6: Dùng mapping tiêu chuẩn
        for displaySlot, actualSlot in pairs(slotMapping) do
            if tempSlots[actualSlot] then
                unitSlots[displaySlot] = tempSlots[actualSlot]
                local unitName = tempSlots[actualSlot]:FindFirstChild("Name") and tempSlots[actualSlot].Name.Value or
                    tempSlots[actualSlot].Name
                print(" Mapped (6/6): Game Slot " ..
                    actualSlot .. " → UI Slot " .. displaySlot .. " (" .. unitName .. ")")
            end
        end
    elseif customMappings[unitCount] then
        -- Case 3/6, 4/6, 5/6: Dùng custom mapping
        for displaySlot, actualSlot in pairs(customMappings[unitCount]) do
            if tempSlots[actualSlot] then
                unitSlots[displaySlot] = tempSlots[actualSlot]
                local unitName = tempSlots[actualSlot]:FindFirstChild("Name") and tempSlots[actualSlot].Name.Value or
                    tempSlots[actualSlot].Name
                print(" Mapped (" ..
                    unitCount ..
                    "/6): Game Slot " .. actualSlot .. " → UI Slot " .. displaySlot .. " (" .. unitName .. ")")
            end
        end
    else
        -- Trường hợp khác (1/6, 2/6): Map theo thứ tự tự nhiên
        for i, unit in ipairs(tempSlots) do
            unitSlots[i] = unit
            local unitName = unit:FindFirstChild("Name") and unit.Name.Value or unit.Name
            print(" Mapped (Mặc định): Game Slot " .. i .. " → UI Slot " .. i .. " (" .. unitName .. ")")
        end
    end

    print(" Đã tìm thấy " .. unitCount .. " unit trong UnitsFolder, " .. #unitSlots .. " unit được map")

    return #unitSlots > 0
end

-- Hàm để nâng cấp unit tối ưu
local function upgradeUnit(unit)
    if not unit then
        return false
    end

    local upgradeRemote = safeGetPath(game:GetService("ReplicatedStorage"), { "Remote", "Server", "Units", "Upgrade" },
        0.5)
    if not upgradeRemote then
        return false
    end

    upgradeRemote:FireServer(unit)
    return true
end

-- Thêm section Units Update trong tab In-Game
local UnitsUpdateSection = InGameTab:AddSection("Units Update")

-- Tạo 6 dropdown cho 6 slot
for i = 1, 6 do
    UnitsUpdateSection:AddDropdown("Slot" .. i .. "LevelDropdown", {
        Title = "Slot " .. i .. " Level",
        Values = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
        Multi = false,
        Default = tostring(unitSlotLevels[i]),
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
--[[
-- Thêm nút Debug Unit Slots
UnitsUpdateSection:AddButton({
    Title = "Debug Unit Slots",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return end

        local unitsFolder = player:FindFirstChild("UnitsFolder")
        if not unitsFolder then
            print("Không tìm thấy UnitsFolder (cần vào map trước)")
            return
        end

        print("===== DEBUG UNIT SLOTS =====")
        local children = unitsFolder:GetChildren()
        for i, unit in ipairs(children) do
            if i <= 6 then
                local slotInfo = "Game Slot "..i..": "
                if unit:FindFirstChild("Name") then
                    slotInfo = slotInfo .. unit.Name.Value
                else
                    slotInfo = slotInfo .. unit.Name
                end
                print(slotInfo)
            end
        end

        print("===== MAPPED UNIT SLOTS =====")
        for i, unit in pairs(unitSlots) do
            local slotInfo = "UI Slot "..i.." → Game Unit: "
            if unit:FindFirstChild("Name") then
                slotInfo = slotInfo .. unit.Name.Value
            else
                slotInfo = slotInfo .. unit.Name
            end
            print(slotInfo)
        end
    end
})
--]]
-- Toggle Auto Update
UnitsUpdateSection:AddToggle("AutoUpdateToggle", {
    Title = "Auto Update",
    Default = ConfigSystem.CurrentConfig.AutoUpdate or false,
    Callback = function(Value)
        autoUpdateEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdate = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()

            print("Auto Update đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if autoUpdateLoop then
                autoUpdateLoop:Disconnect()
                autoUpdateLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateEnabled and wait(0.5) do -- Cập nhật mỗi 0.1 giây
                    -- Kiểm tra xem có trong map không
                    if isPlayerInMap() then
                        -- Lặp qua từng slot và nâng cấp theo cấp độ đã chọn
                        for i = 1, 6 do
                            if unitSlots[i] and unitSlotLevels[i] > 0 then
                                -- Lấy unit và kiểm tra level hiện tại
                                local unit = unitSlots[i]
                                local upgradeFolder = unit:FindFirstChild("Upgrade_Folder")

                                if upgradeFolder then
                                    local levelValue = upgradeFolder:FindFirstChild("Level")
                                    if levelValue and levelValue:IsA("NumberValue") then
                                        local currentLevel = levelValue.Value
                                        local targetLevel = unitSlotLevels[i]

                                        -- Chỉ nâng cấp nếu level hiện tại thấp hơn level mục tiêu
                                        if currentLevel < targetLevel then
                                            print(" Slot " ..
                                                i .. ": Nâng cấp từ Lv " .. currentLevel .. " lên Lv " .. targetLevel)
                                            upgradeUnit(unit)
                                            wait(0.3) -- Thêm chờ nhẹ giữa các lần nâng cấp để tránh spam
                                        end
                                    end
                                end
                            end
                        end
                    else
                        -- Người chơi không ở trong map, thử scan lại
                        scanUnits()
                        wait(1) -- Chờ sau khi scan nếu không ở trong map
                    end
                end
            end)
        else
            print("Auto Update đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoUpdateLoop then
                autoUpdateLoop:Disconnect()
                autoUpdateLoop = nil
            end
        end
    end
})

-- Toggle Auto Update Random
UnitsUpdateSection:AddToggle("AutoUpdateRandomToggle", {
    Title = "Auto Update Random",
    Default = ConfigSystem.CurrentConfig.AutoUpdateRandom or false,
    Callback = function(Value)
        autoUpdateRandomEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdateRandom = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Scan unit trước khi bắt đầu
            scanUnits()

            print("Auto Update Random đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                while autoUpdateRandomEnabled and wait(0.1) do -- Cập nhật mỗi 0.1 giây
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
            print("Auto Update Random đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoUpdateRandomLoop then
                autoUpdateRandomLoop:Disconnect()
                autoUpdateRandomLoop = nil
            end
        end
    end
})

-- Hàm để kiểm tra trạng thái AFKWorld
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
    local afkTeleportRemote = safeGetPath(game:GetService("ReplicatedStorage"),
        { "Remote", "Server", "Lobby", "AFKWorldTeleport" }, 0.5)
    if not afkTeleportRemote then
        warn("Không tìm thấy Remote AFKWorldTeleport")
        return false
    end

    afkTeleportRemote:FireServer()
    return true
end

-- Thêm section AFK vào tab Settings
local AFKSection = SettingsTab:AddSection("AFK Settings")

-- Biến lưu trạng thái Anti AFK
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFK or true -- Mặc định bật
local antiAFKConnection = nil                                     -- Kết nối sự kiện

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

-- Toggle Anti AFK
AFKSection:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = antiAFKEnabled,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()

        if Value then
            Fluent:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được bật",
                Duration = 2
            })
            setupAntiAFK()
        else
            Fluent:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK đã được tắt",
                Duration = 2
            })
            -- Ngắt kết nối nếu có
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})

-- Toggle Auto Join AFK
AFKSection:AddToggle("AutoJoinAFKToggle", {
    Title = "Auto Join AFK",
    Default = ConfigSystem.CurrentConfig.AutoJoinAFK or false,
    Callback = function(Value)
        autoJoinAFKEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAFK = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Kiểm tra trạng thái AFKWorld
            local isInAFKWorld = checkAFKWorldState()

            print("Auto Join AFK đã được bật")

            -- Nếu không ở trong AFKWorld, teleport ngay lập tức
            if not isInAFKWorld then
                joinAFKWorld()
            else
                print("Bạn đã ở trong AFKWorld")
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
            print("Auto Join AFK đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoJoinAFKLoop then
                autoJoinAFKLoop:Disconnect()
                autoJoinAFKLoop = nil
            end
        end
    end
})

-- Tự động đồng bộ trạng thái từ game khi khởi động
spawn(function()
    wait(3) -- Đợi game load

    -- Khởi tạo danh sách Acts khi script khởi động
    updateOrderedActs()

    -- Kiểm tra nếu người chơi đã ở trong AFKWorld
    local isInAFKWorld = checkAFKWorldState()

    -- Nếu Auto Join AFK được bật và người chơi không ở trong AFKWorld
    if autoJoinAFKEnabled and not isInAFKWorld then
        joinAFKWorld()
    end
end)

-- Thêm section UI Settings vào tab Settings
local UISettingsSection = SettingsTab:AddSection("UI Settings")

-- Toggle Auto Hide UI
UISettingsSection:AddToggle("AutoHideUIToggle", {
    Title = "Auto Hide UI",
    Default = ConfigSystem.CurrentConfig.AutoHideUI or false,
    Callback = function(Value)
        autoHideUIEnabled = Value
        ConfigSystem.CurrentConfig.AutoHideUI = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Hide UI đã được bật, UI sẽ tự động ẩn sau 1 giây")

            -- Tạo timer mới để tự động ẩn UI
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end

            autoHideUITimer = spawn(function()
                wait(1) -- Đợi 1 giây
                -- Sử dụng Window.Visible thay vì isMinimized để kiểm tra
                if autoHideUIEnabled and Window and Window.Visible then
                    Window:Minimize()
                end
            end)
        else
            print("Auto Hide UI đã được tắt")

            -- Hủy timer nếu có
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
        end
    end
})

-- Tự động ẩn UI nếu tính năng được bật KHI KHỞI ĐỘNG SCRIPT
spawn(function()
    print("AutoHideUI startup: Waiting for Window and game load...") -- Debug
    -- Đợi cho đến khi Window được tạo và game load xong
    while not Window or not game:IsLoaded() do wait(0.1) end
    print("AutoHideUI startup: Window and game loaded.") -- Debug
    wait(1.5)                                            -- Tăng thời gian chờ lên 1.5 giây
    print("AutoHideUI startup: Checking config...")      -- Debug

    -- Kiểm tra config và thực hiện minimize nếu cần
    if ConfigSystem.CurrentConfig.AutoHideUI then
        print("AutoHideUI startup: Config enabled. Attempting to minimize Window...") -- Debug
        -- Kiểm tra kỹ Window và phương thức Minimize trước khi gọi
        if Window and type(Window.Minimize) == 'function' then
            local success, err = pcall(function()
                Window:Minimize()
            end)
            if success then
                print("AutoHideUI startup: Window:Minimize() called successfully.") -- Debug
            else
                print("AutoHideUI startup: Error calling Window:Minimize():", err)  -- Debug
            end
        else
            print("AutoHideUI startup: Error - Window object or Window.Minimize method not available or not a function.") -- Debug
        end
    else
        print("AutoHideUI startup: Config disabled.") -- Debug
    end
end)

-- Thêm section Merchant trong tab Shop
local MerchantSection = ShopTab:AddSection("Merchant")

-- Biến lưu trạng thái Merchant
local selectedMerchantItems = ConfigSystem.CurrentConfig.SelectedMerchantItems or {}
local autoMerchantBuyEnabled = ConfigSystem.CurrentConfig.AutoMerchantBuy or false
local autoMerchantBuyLoop = nil

-- Danh sách các item có thể mua từ Merchant
local merchantItems = {
    "Green Bean",
    "Onigiri",
    "Dr. Megga Punk",
    "Cursed Finger",
    "Stats Key",
    "French Fries",
    "Trait Reroll",
    "Ranger Crystal",
    "Rubber Fruit"
}

-- Hàm để mua item từ Merchant
local function buyMerchantItem(itemName)
    local success, err = pcall(function()
        local merchantRemote = safeGetPath(game:GetService("ReplicatedStorage"),
            { "Remote", "Server", "Gameplay", "Merchant" }, 2)

        if merchantRemote then
            local args = {
                [1] = itemName,
                [2] = 1
            }

            merchantRemote:FireServer(unpack(args))
            print("Đã mua item: " .. itemName)

            -- Hiển thị thông báo
            print("Đã mua item: " .. itemName)
        else
            warn("Không tìm thấy Remote Merchant")
        end
    end)

    if not success then
        warn("Lỗi khi mua item từ Merchant: " .. tostring(err))
    end
end

-- Dropdown để chọn nhiều items
MerchantSection:AddDropdown("MerchantItemsDropdown", {
    Title = "Select Items",
    Values = merchantItems,
    Multi = true,
    Default = selectedMerchantItems,
    Callback = function(Values)
        selectedMerchantItems = Values
        ConfigSystem.CurrentConfig.SelectedMerchantItems = Values
        ConfigSystem.SaveConfig()

        local selectedItemsText = ""
        -- Sửa cách xử lý Values để tránh lỗi
        if type(Values) == "table" then
            for item, isSelected in pairs(Values) do
                if isSelected then
                    selectedItemsText = selectedItemsText .. item .. ", "
                end
            end
        end

        if selectedItemsText ~= "" then
            selectedItemsText = selectedItemsText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            print("Đã chọn items: " .. selectedItemsText)
        else
            print("Không có item nào được chọn")
        end
    end
})

-- Toggle Auto Buy
MerchantSection:AddToggle("AutoMerchantBuyToggle", {
    Title = "Auto Buy",
    Default = ConfigSystem.CurrentConfig.AutoMerchantBuy or false,
    Callback = function(Value)
        autoMerchantBuyEnabled = Value
        ConfigSystem.CurrentConfig.AutoMerchantBuy = Value
        ConfigSystem.SaveConfig()

        if Value then
            local selectedItemsCount = 0
            for item, isSelected in pairs(selectedMerchantItems) do
                if isSelected then
                    selectedItemsCount = selectedItemsCount + 1
                end
            end

            if selectedItemsCount == 0 then
                print("Auto Buy đã bật nhưng không có item nào được chọn")
            else
                print("Auto Buy đã được bật, sẽ tự động mua items mỗi 2 giây")
            end

            -- Hủy vòng lặp cũ nếu có
            if autoMerchantBuyLoop then
                autoMerchantBuyLoop:Disconnect()
                autoMerchantBuyLoop = nil
            end

            -- Tạo vòng lặp mới để tự động mua
            spawn(function()
                while autoMerchantBuyEnabled and wait(2) do -- Mua mỗi 2 giây
                    for item, isSelected in pairs(selectedMerchantItems) do
                        if isSelected then
                            buyMerchantItem(item)
                            wait(0.5) -- Chờ 0.5 giây giữa các lần mua
                        end
                    end
                end
            end)
        else
            print("Auto Buy đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoMerchantBuyLoop then
                autoMerchantBuyLoop:Disconnect()
                autoMerchantBuyLoop = nil
            end
        end
    end
})

-- Biến lưu trạng thái Auto Scan Units
local autoScanUnitsEnabled = ConfigSystem.CurrentConfig.AutoScanUnits or true
local autoScanUnitsLoop = nil

-- Tự động scan unit khi bắt đầu
spawn(function()
    wait(5) -- Đợi 5 giây để game load
    scanUnits()

    -- Bắt đầu vòng lặp auto scan nếu đã bật
    if autoScanUnitsEnabled then
        spawn(function()
            while autoScanUnitsEnabled and wait(3) do
                if isPlayerInMap() then
                    local success = scanUnits()
                    if success then
                        print("Auto Scan: Phát hiện " .. #unitSlots .. " unit")
                    end
                end
            end
        end)
    end
end)

-- Tự động cập nhật trạng thái từ game khi khởi động
spawn(function()
    wait(3) -- Đợi game load
    local actualState = checkActualAutoPlayState()

    -- Cập nhật cấu hình nếu trạng thái thực tế khác với cấu hình
    if autoPlayEnabled ~= actualState then
        autoPlayEnabled = actualState
        ConfigSystem.CurrentConfig.AutoPlay = actualState
        ConfigSystem.SaveConfig()

        -- Cập nhật UI nếu cần
        local autoPlayToggle = InGameSection:GetComponent("AutoPlayToggle")
        if autoPlayToggle and autoPlayToggle.Set then
            autoPlayToggle:Set(actualState)
        end

        print("Đã cập nhật trạng thái Auto Play từ game: " .. (actualState and "bật" or "tắt"))
    end
end)

-- Khởi tạo Anti AFK khi script khởi động
spawn(function()
    -- Đợi một chút để script khởi động hoàn tất
    wait(3)

    -- Nếu Anti AFK được bật, thiết lập nó
    if antiAFKEnabled then
        setupAntiAFK()
        print("Đã tự động thiết lập Anti AFK khi khởi động script")
    end
end)

-- Khởi động các vòng lặp tối ưu
setupOptimizedLoops()

-- Kiểm tra trạng thái người chơi khi script khởi động
if isPlayerInMap() then
    print("Bạn đang ở trong map, Auto Join sẽ chỉ hoạt động khi bạn rời khỏi map")
end

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "Kaihon Hub | Anime Rangers X",
    Content = "Script đã tải thành công! Đã tối ưu hóa cho trải nghiệm mượt mà.",
    Duration = 3
})

-- Biến lưu trạng thái Webhook sử dụng _G (cách 3)
_G.webhookURL = ConfigSystem.CurrentConfig.WebhookURL or ""
_G.autoSendWebhookEnabled = ConfigSystem.CurrentConfig.AutoSendWebhook or false
_G.webhookSentLog = {} -- Lưu trữ log các lần đã gửi để tránh gửi lặp lại

-- Phần này sẽ không bị ảnh hưởng bởi việc mã hóa
local webhookURL = _G.webhookURL
local autoSendWebhookEnabled = _G.autoSendWebhookEnabled
local webhookSentLog = _G.webhookSentLog

-- Hàm lấy thông tin phần thưởng
local function getRewards()
    local player = game:GetService("Players").LocalPlayer
    local rewardsShow = player:FindFirstChild("RewardsShow")
    local result = {}

    if rewardsShow then
        for _, folder in ipairs(rewardsShow:GetChildren()) do
            local amount = folder:FindFirstChild("Amount")
            table.insert(result, {
                Name = folder.Name,
                Amount = (amount and amount.Value) or 0
            })
        end
    end

    return result
end

-- Hàm lấy số lượng tài nguyên hiện tại
local function getCurrentResources()
    local player = game:GetService("Players").LocalPlayer
    local playerName = player.Name
    local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")

    if not playerData then
        return {}
    end

    local playerFolder = playerData:FindFirstChild(playerName)
    if not playerFolder then
        return {}
    end

    local dataFolder = playerFolder:FindFirstChild("Data")
    if not dataFolder then
        return {}
    end

    local resources = {}

    -- Lấy số lượng các tài nguyên phổ biến
    local commonResources = { "Gold", "Gem", "EXP", "Rubber Fruit" }
    for _, resourceName in ipairs(commonResources) do
        local resourceValue = dataFolder:FindFirstChild(resourceName)
        if resourceValue then
            resources[resourceName] = resourceValue.Value
        end
    end

    -- Kiểm tra thêm các tài nguyên khác trong Data folder
    for _, child in pairs(dataFolder:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            resources[child.Name] = child.Value
        end
    end

    return resources
end

-- Hàm lấy thông tin trận đấu
local function getGameInfoText()
    -- Thêm delay 1 giây trước khi lấy thông tin
    wait(1)

    local player = game:GetService("Players").LocalPlayer
    local rewardsUI = player:WaitForChild("PlayerGui", 1):FindFirstChild("RewardsUI")
    local infoLines = {}

    if rewardsUI then
        local leftSide = rewardsUI:FindFirstChild("Main") and rewardsUI.Main:FindFirstChild("LeftSide")
        if leftSide then
            local labels = {
                "GameStatus",
                "Mode",
                "World",
                "Chapter",
                "Difficulty",
                "TotalTime"
            }

            for _, labelName in ipairs(labels) do
                local label = leftSide:FindFirstChild(labelName)
                if label and label:IsA("TextLabel") then
                    table.insert(infoLines, "- " .. labelName .. ": " .. label.Text)
                end
            end
        end
    end

    return table.concat(infoLines, "\n")
end

-- Hàm tạo nội dung embed
local function createEmbed(rewards, gameInfo)
    local fields = {}

    -- Thêm trường phần thưởng
    local rewardText = ""
    for _, r in ipairs(rewards) do
        rewardText = rewardText .. "- " .. r.Name .. ": +" .. r.Amount .. "\n"
    end

    if rewardText ~= "" then
        table.insert(fields, {
            name = "Reward",
            value = rewardText,
            inline = false
        })
    end

    -- Lấy và hiển thị thông tin tài nguyên người chơi
    local playerResources = getCurrentResources()
    local statsText = ""

    -- Thêm tên người chơi
    local playerName = game:GetService("Players").LocalPlayer.Name
    statsText = "- Name: " .. "||" .. playerName .. "||\n"

    -- Luôn hiển thị các tài nguyên chính: Level, Gem, Gold
    local mainResources = { "Level", "Gem", "Gold" }
    for _, resourceName in ipairs(mainResources) do
        local value = playerResources[resourceName] or 0
        statsText = statsText .. "- " .. resourceName .. ": " .. value .. "\n"
    end

    table.insert(fields, {
        name = "Account",
        value = statsText,
        inline = false
    })

    -- Thêm trường thông tin trận đấu
    if gameInfo ~= "" then
        table.insert(fields, {
            name = "Match Info",
            value = gameInfo,
            inline = false
        })
    end

    -- Tạo embed
    local embed = {
        title = "Anime Rangers X - Kaihon Hub",
        description = "Game Info",
        color = 5793266, -- Màu tím
        fields = fields,
        thumbnail = {
            url =
            "https://images-ext-1.discordapp.net/external/CmlSOppXAMnvaaK2XVHV8FZlQDakSJQGop2XAPbhPyw/%3Fsize%3D4096/https/cdn.discordapp.com/avatars/1269841484090179636/a6032236a677c176d236a53ac480c586.png?format=webp&quality=lossless&width=900&height=900" -- Logo HT Hub
        },
        footer = {
            text = "Kaihon Hub | Anime Rangers X • " .. os.date("%x %X"),
            icon_url =
            "https://images-ext-1.discordapp.net/external/CmlSOppXAMnvaaK2XVHV8FZlQDakSJQGop2XAPbhPyw/%3Fsize%3D4096/https/cdn.discordapp.com/avatars/1269841484090179636/a6032236a677c176d236a53ac480c586.png?format=webp&quality=lossless&width=900&height=900"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    return embed
end

-- Hàm gửi webhook
local function sendWebhook(rewards)
    -- Sử dụng biến global _G.webhookURL để tránh lỗi khi script bị mã hóa
    local currentURL = _G.webhookURL or webhookURL

    -- Kiểm tra URL webhook
    if currentURL == "" then
        warn("URL webhook trống, không thể gửi thông tin")
        return false
    end

    -- Tạo ID cho lần gửi này
    local gameId = os.time() .. "_" .. math.random(1000, 9999)

    -- Kiểm tra nếu đã gửi trước đó
    if _G.webhookSentLog[gameId] then
        return false
    end

    -- Lấy thông tin trận đấu
    local gameInfo = getGameInfoText()

    -- Đợi thêm 1 giây để đảm bảo thông tin đã được cập nhật đầy đủ
    wait(1)

    -- Khởi tạo rewards nếu chưa có (trường hợp thua)
    if not rewards or #rewards == 0 then
        rewards = {
            { Name = "", Amount = "" }
        }
    end

    -- Sử dụng embed
    local embed = createEmbed(rewards, gameInfo)
    local payload = game:GetService("HttpService"):JSONEncode({
        embeds = { embed }
    })

    -- Gửi request
    local httpRequest = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or HttpPost
    if not httpRequest then
        warn("Không tìm thấy hàm gửi HTTP request tương thích.")
        return false
    end

    local success, response = pcall(function()
        return httpRequest({
            Url = currentURL, -- Sử dụng biến currentURL thay cho webhookURL
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success then
        print("Đã gửi thông tin game qua webhook!")
        _G.webhookSentLog[gameId] = true -- Sử dụng biến global
        return true
    else
        warn("Gửi webhook thất bại:", response)
        return false
    end
end

-- Thiết lập vòng lặp kiểm tra game kết thúc và gửi webhook
local function setupWebhookMonitor()
    -- Biến để theo dõi trạng thái explosion đã được phát hiện chưa
    local explosionDetected = false
    -- Biến để theo dõi trạng thái UI kết thúc trận đã xuất hiện
    local gameEndUIDetected = false

    -- Tạo một kết nối để theo dõi khi Base_Explosion2 xuất hiện (thắng)
    spawn(function()
        while wait(0.5) do
            if not _G.autoSendWebhookEnabled then
                wait(1)
                explosionDetected = false -- Reset trạng thái khi tắt
                gameEndUIDetected = false
            else
                -- Chỉ kiểm tra nếu đang ở trong map
                if isPlayerInMap() then
                    -- Kiểm tra Visual folder và Base_Explosion2 (thắng)
                    local visualFolder = workspace:FindFirstChild("Visual")
                    if visualFolder then
                        local explosion = visualFolder:FindFirstChild("Base_Explosion2")
                        if explosion and not explosionDetected then
                            explosionDetected = true
                            print("Phát hiện Base_Explosion2, đang gửi webhook...")

                            -- Đợi một chút để đảm bảo rewards đã được cập nhật
                            wait(1)

                            -- Lấy phần thưởng và gửi webhook
                            local player = game:GetService("Players").LocalPlayer
                            local rewards = getRewards()

                            -- Gửi webhook ngay cả khi không có phần thưởng
                            sendWebhook(rewards)
                            -- Đợi một thời gian để không gửi lặp lại
                            wait(10)
                            explosionDetected = false -- Reset trạng thái sau khi gửi
                        end
                    end

                    -- Kiểm tra UI thất bại
                    local player = game:GetService("Players").LocalPlayer
                    if player and player:FindFirstChild("PlayerGui") then
                        local rewardsUI = player.PlayerGui:FindFirstChild("RewardsUI")
                        if rewardsUI and not gameEndUIDetected then
                            local failText = false

                            -- Tìm các text cho kết quả thất bại
                            for _, v in pairs(rewardsUI:GetDescendants()) do
                                if v:IsA("TextLabel") and (v.Text:find("Thất bại") or v.Text:find("Fail") or v.Text == "Lose") then
                                    failText = true
                                    break
                                end

                                -- Kiểm tra bổ sung trong GameStatus
                                if v.Name == "GameStatus" and v:IsA("TextLabel") and (v.Text:find("Defeat") or v.Text:find("Game Over")) then
                                    failText = true
                                    break
                                end
                            end

                            if failText and not gameEndUIDetected then
                                gameEndUIDetected = true
                                print("Phát hiện UI thất bại, đang gửi webhook...")

                                -- Đợi một chút để đảm bảo UI đã được cập nhật đầy đủ
                                wait(1)

                                -- Gửi webhook với thông báo thất bại
                                local failRewards = { { Name = "Kết quả", Amount = "Thất bại" } }
                                sendWebhook(failRewards)

                                -- Đợi một thời gian để không gửi lặp lại
                                wait(10)
                                gameEndUIDetected = false -- Reset trạng thái sau khi gửi
                            end
                        end
                    end
                else
                    explosionDetected = false -- Reset trạng thái khi không ở trong map
                    gameEndUIDetected = false
                end
            end
        end
    end)

    -- Thêm một kết nối để theo dõi khi Visual folder thay đổi
    spawn(function()
        while wait(2) do
            if _G.autoSendWebhookEnabled and isPlayerInMap() then
                local visualFolder = workspace:FindFirstChild("Visual")
                if visualFolder then
                    local connection
                    connection = visualFolder.ChildAdded:Connect(function(child)
                        if child.Name == "Base_Explosion2" and not explosionDetected then
                            explosionDetected = true
                            print("Phát hiện Base_Explosion2 mới, đang gửi webhook...")

                            -- Đợi một chút để đảm bảo rewards đã được cập nhật
                            wait(1)

                            -- Lấy phần thưởng và gửi webhook
                            local player = game:GetService("Players").LocalPlayer
                            local rewards = getRewards()

                            -- Gửi webhook ngay cả khi không có phần thưởng
                            sendWebhook(rewards)
                            -- Đợi một thời gian để không gửi lặp lại
                            wait(10)
                            explosionDetected = false -- Reset trạng thái sau khi gửi

                            connection:Disconnect()
                        end
                    end)

                    -- Đợi một khoảng thời gian trước khi thiết lập lại kết nối
                    wait(5)
                    if connection then
                        connection:Disconnect()
                    end
                end
            end
        end
    end)

    -- Thêm một kết nối để theo dõi khi RewardsUI xuất hiện (bao gồm cả thắng và thua)
    spawn(function()
        while wait(2) do
            if _G.autoSendWebhookEnabled and isPlayerInMap() then
                local player = game:GetService("Players").LocalPlayer
                if player and player:FindFirstChild("PlayerGui") then
                    local connection
                    connection = player.PlayerGui.ChildAdded:Connect(function(child)
                        if child.Name == "RewardsUI" and not gameEndUIDetected then
                            -- Đợi một chút để UI được tải đầy đủ
                            wait(1.5)

                            gameEndUIDetected = true
                            print("Phát hiện RewardsUI, đang kiểm tra kết quả trận đấu...")

                            -- Phát hiện xem là thắng hay thua
                            local isDefeat = false
                            for _, v in pairs(child:GetDescendants()) do
                                if v:IsA("TextLabel") and (v.Text:find("Thất bại") or v.Text:find("Fail") or v.Text == "Lose" or
                                        v.Text:find("Defeat") or v.Text:find("Game Over")) then
                                    isDefeat = true
                                    break
                                end
                            end

                            -- Lấy phần thưởng nếu có
                            local rewards = getRewards()

                            -- Nếu không có phần thưởng hoặc là thua, gửi thông báo thua
                            if #rewards == 0 or isDefeat then
                                local defeatRewards = { { Name = "Kết quả", Amount = "Thất bại" } }
                                print("Trận đấu kết thúc: Thất bại")
                                sendWebhook(defeatRewards)
                            else
                                print("Trận đấu kết thúc: Thắng lợi")
                                sendWebhook(rewards)
                            end

                            -- Đợi một thời gian để không gửi lặp lại
                            wait(10)
                            gameEndUIDetected = false

                            connection:Disconnect()
                        end
                    end)

                    -- Đợi một khoảng thời gian trước khi thiết lập lại kết nối
                    wait(5)
                    if connection then
                        connection:Disconnect()
                    end
                end
            end
        end
    end)
end

-- Thêm section Webhook trong tab Webhook
local WebhookSection = WebhookTab:AddSection("Discord Webhook")

-- Thêm input để nhập URL webhook
WebhookSection:AddInput("WebhookURLInput", {
    Title = "Webhook URL",
    Default = _G.webhookURL,
    Placeholder = "Nhập URL webhook Discord của bạn",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        -- Lưu URL webhook vào cả biến local và biến global
        webhookURL = Value
        _G.webhookURL = Value
        ConfigSystem.CurrentConfig.WebhookURL = Value
        ConfigSystem.SaveConfig()

        print("Đã cập nhật URL webhook")
    end
})

-- Toggle Auto SendWebhook
WebhookSection:AddToggle("AutoSendWebhookToggle", {
    Title = "Auto Send Webhook",
    Default = _G.autoSendWebhookEnabled,
    Callback = function(Value)
        if Value then
            -- Kiểm tra URL webhook
            if _G.webhookURL == "" then
                print("URL webhook trống! Vui lòng nhập URL webhook trước khi bật tính năng này.")
                -- Trả về toggle về trạng thái tắt
                WebhookSection:GetComponent("AutoSendWebhookToggle"):Set(false)
                return
            end

            -- Loại bỏ kiểm tra đang ở trong map không, cho phép bật ở lobby
            autoSendWebhookEnabled = true
            _G.autoSendWebhookEnabled = true
            ConfigSystem.CurrentConfig.AutoSendWebhook = true
            ConfigSystem.SaveConfig()

            print("Auto Send Webhook đã được bật. Thông tin trận đấu sẽ tự động gửi khi game kết thúc.")
        else
            autoSendWebhookEnabled = false
            _G.autoSendWebhookEnabled = false
            ConfigSystem.CurrentConfig.AutoSendWebhook = false
            ConfigSystem.SaveConfig()

            print("Auto Send Webhook đã được tắt")
        end
    end
})

-- Nút Test Webhook
WebhookSection:AddButton({
    Title = "Test Webhook",
    Callback = function()
        -- Kiểm tra URL webhook
        if _G.webhookURL == "" then
            print("URL webhook trống! Vui lòng nhập URL webhook trước khi test.")
            return
        end

        -- Tạo dữ liệu test
        local testRewards = {
            { Name = "Gem",  Amount = 100 },
            { Name = "Gold", Amount = 1000 },
            { Name = "EXP",  Amount = 500 }
        }

        -- Gửi webhook test
        local success = sendWebhook(testRewards)

        if success then
            print("Đã gửi webhook test thành công!")
        else
            print("Gửi webhook test thất bại! Kiểm tra lại URL và quyền truy cập.")
        end
    end
})

-- Khởi động vòng lặp kiểm tra game kết thúc
setupWebhookMonitor()

-- Toggle Auto Join All (Ranger)
local autoJoinAllRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinAllRanger or false
local autoJoinAllRangerLoop = nil

RangerSection:AddToggle("AutoJoinAllRangerToggle", {
    Title = "Auto Join All",
    Default = autoJoinAllRangerEnabled,
    Callback = function(Value)
        autoJoinAllRangerEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAllRanger = Value
        ConfigSystem.SaveConfig()
        if Value then
            print("Auto Join All Ranger đã được bật")
            if autoJoinAllRangerLoop then
                autoJoinAllRangerLoop:Disconnect()
                autoJoinAllRangerLoop = nil
            end
            spawn(function()
                local allMaps = { "OnePiece", "Namek", "DemonSlayer", "Naruto", "OPM" }
                local allActs = { "RangerStage1", "RangerStage2", "RangerStage3" }
                while autoJoinAllRangerEnabled do
                    -- Kiểm tra nếu đang ở trong map Ranger Stage, đợi ra khỏi map trước
                    if isPlayerInRangerStageMap() then
                        print("Auto Join All: Đang ở trong map Ranger Stage, đợi thoát...")
                        while isPlayerInRangerStageMap() and autoJoinAllRangerEnabled do wait(0.1) end
                        if not autoJoinAllRangerEnabled then return end
                        wait(0.5) -- Đợi một chút giữa các lần kiểm tra
                    end

                    -- Thu thập tất cả map+act không bị cooldown
                    local availableMaps = {}
                    for _, map in ipairs(allMaps) do
                        for _, act in ipairs(allActs) do
                            if not isMapActOnCooldown(map, act) then
                                table.insert(availableMaps, { map = map, act = act })
                            else
                                print("Auto Join All: " .. map .. "_" .. act .. " đang trong cooldown, sẽ bỏ qua")
                            end
                        end
                    end

                    -- Nếu có map nào available, join map đó
                    if #availableMaps > 0 then
                        -- Lấy map đầu tiên không bị cooldown
                        local mapToJoin = availableMaps[1]
                        print("Auto Join All: Chuẩn bị join map không có cooldown: " ..
                            mapToJoin.map .. " - " .. mapToJoin.act)

                        -- Join map
                        joinRangerStage(mapToJoin.map, mapToJoin.act)

                        -- Đợi vào map hoặc timeout
                        local t = 0
                        while not isPlayerInRangerStageMap() and t < 10 and autoJoinAllRangerEnabled do
                            wait(0.5)
                            t = t + 0.5
                        end

                        -- Nếu đã vào map, đợi delay
                        if isPlayerInRangerStageMap() and autoJoinAllRangerEnabled then
                            print("Auto Join All: Đã vào map Ranger Stage, đợi " .. rangerTimeDelay .. " giây...")
                            wait(rangerTimeDelay)
                        end
                    else
                        print("Auto Join All: Tất cả map đều đang trong cooldown, đợi 5 giây và kiểm tra lại...")
                        wait(5)
                    end

                    -- Đợi một chút trước khi tiếp tục vòng lặp
                    if autoJoinAllRangerEnabled then wait(1) end
                end
            end)
        else
            print("Auto Join All Ranger đã được tắt")
            if autoJoinAllRangerLoop then
                autoJoinAllRangerLoop:Disconnect()
                autoJoinAllRangerLoop = nil
            end
        end
    end
})

-- Biến lưu trạng thái Auto Movement
local autoMovementEnabled = ConfigSystem.CurrentConfig.AutoMovement or false
local autoMovementLoop = nil

-- Cập nhật ConfigSystem.DefaultConfig bằng cách thêm thuộc tính AutoMovement
ConfigSystem.DefaultConfig.AutoMovement = false

-- Thêm section Auto Movement vào tab Settings
local MovementSection = SettingsTab:AddSection("Auto Movement")

-- Hàm thực hiện di chuyển ngẫu nhiên
local function performRandomMovement()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Đặt tốc độ di chuyển cao hơn
    local walkSpeed = math.random(10, 15)
    humanoid.WalkSpeed = walkSpeed

    -- Tạo hướng di chuyển ngẫu nhiên với khoảng cách xa hơn
    local moveDistance = math.random(3, 5) -- Khoảng cách di chuyển (đơn vị)

    -- Các hướng di chuyển cơ bản
    local directions = {
        Vector3.new(1, 0, 0),  -- Phải
        Vector3.new(-1, 0, 0), -- Trái
        Vector3.new(0, 0, 1),  -- Lên
        Vector3.new(0, 0, -1), -- Xuống
        Vector3.new(1, 0, 1),  -- Phải-Lên
        Vector3.new(-1, 0, 1), -- Trái-Lên
        Vector3.new(1, 0, -1), -- Phải-Xuống
        Vector3.new(-1, 0, -1) -- Trái-Xuống
    }

    -- Chọn hướng ngẫu nhiên
    local randomDir = directions[math.random(1, #directions)]

    -- Điểm đích đến (vị trí hiện tại + hướng * khoảng cách)
    local targetPosition = rootPart.Position + (randomDir * moveDistance)

    -- Tạo một path finding để di chuyển
    local pathService = game:GetService("PathfindingService")
    local path = pathService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })

    -- Sử dụng CFrame để di chuyển trực tiếp
    local movementDuration = math.random(3, 6) -- Thời gian di chuyển (giây)
    local startTime = tick()

    -- Di chuyển liên tục đến điểm đích
    spawn(function()
        while tick() - startTime < movementDuration and autoMovementEnabled do
            if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then
                break
            end

            -- Tính vectơ di chuyển tới điểm đích
            local direction = (targetPosition - rootPart.Position).Unit

            -- Sử dụng MoveTo để di chuyển tới điểm đích
            humanoid:MoveTo(targetPosition)

            -- Nhảy ngẫu nhiên (15% cơ hội)
            if math.random(1, 20) == 1 then
                humanoid.Jump = true
            end

            wait(0.1) -- Đợi một chút trước khi tiếp tục di chuyển
        end
    end)
end

-- Toggle Auto Movement
MovementSection:AddToggle("AutoMovementToggle", {
    Title = "Auto Movement",
    Default = autoMovementEnabled,
    Callback = function(Value)
        autoMovementEnabled = Value
        ConfigSystem.CurrentConfig.AutoMovement = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Movement đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if autoMovementLoop then
                autoMovementLoop:Disconnect()
                autoMovementLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                while autoMovementEnabled and wait(math.random(4, 8)) do -- Tăng thời gian giữa các lần di chuyển
                    -- Chỉ thực hiện khi nhân vật tồn tại
                    if game:GetService("Players").LocalPlayer.Character then
                        pcall(function()
                            performRandomMovement()
                        end)
                    end
                end
            end)
        else
            print("Auto Movement đã được tắt")

            -- Hủy vòng lặp nếu có
            if autoMovementLoop then
                autoMovementLoop:Disconnect()
                autoMovementLoop = nil
            end

            -- Dừng nhân vật
            pcall(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                    game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, 0))
                end
            end)
        end
    end
})

-- Thêm section Stats Potential trong tab Unit
local StatsPotentialSection = UnitTab:AddSection("Stats Potential")

-- Biến lưu trạng thái Stats Potential
local availableUnits = {}
local selectedUnit = nil
local selectedUnitTag = nil
local selectedDamageValues = {}
local selectedHealthValues = {}
local selectedSpeedValues = {}
local selectedRangeValues = {}
local selectedCooldownValues = {}
local autoRollStatsEnabled = ConfigSystem.CurrentConfig.AutoRollStats or false
local autoRollStatsLoop = nil

-- Hàm để quét và lấy danh sách units từ Collection
local function scanAvailableUnits()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local playerName = player.Name
        local playerData = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data")
        local playerCollection = playerData:FindFirstChild(playerName) and
            playerData[playerName]:FindFirstChild("Collection")

        if not playerCollection then
            return {}
        end

        -- Tạo bảng tạm để nhóm các unit theo tên và level
        local unitGroups = {}

        for _, unit in pairs(playerCollection:GetChildren()) do
            if unit:IsA("Folder") and unit:FindFirstChild("Tag") and unit:FindFirstChild("Level") then
                local unitName = unit.Name
                local unitLevel = unit.Level.Value
                local unitTag = unit.Tag.Value

                -- Tạo key để nhóm theo tên và level
                local groupKey = unitName .. "_" .. unitLevel

                -- Tạo nhóm nếu chưa tồn tại
                if not unitGroups[groupKey] then
                    unitGroups[groupKey] = {}
                end

                -- Thêm unit vào nhóm
                table.insert(unitGroups[groupKey], {
                    name = unitName,
                    level = unitLevel,
                    tag = unitTag,
                    ref = unit
                })
            end
        end

        -- Tạo danh sách kết quả với displayName đã được đánh số
        local units = {}

        for groupKey, groupUnits in pairs(unitGroups) do
            -- Nếu chỉ có 1 unit trong nhóm, không cần đánh số
            if #groupUnits == 1 then
                local unit = groupUnits[1]
                table.insert(units, {
                    name = unit.name,
                    displayName = unit.name .. " (Lv: " .. unit.level .. ")",
                    tag = unit.tag,
                    ref = unit.ref
                })
            else
                -- Nếu có nhiều unit trong nhóm, đánh số để phân biệt
                for i, unit in ipairs(groupUnits) do
                    table.insert(units, {
                        name = unit.name,
                        displayName = unit.name .. " (Lv: " .. unit.level .. " #" .. i .. ")",
                        tag = unit.tag,
                        ref = unit.ref
                    })
                end
            end
        end

        -- Sắp xếp theo tên
        table.sort(units, function(a, b)
            return a.name < b.name
        end)

        return units
    end)

    if success then
        return result
    else
        warn("Lỗi khi quét units: " .. tostring(result))
        return {}
    end
end

-- Hàm để lấy danh sách tên hiển thị của các unit
local function getUnitDisplayNames()
    local displayNames = {}
    for _, unit in ipairs(availableUnits) do
        table.insert(displayNames, unit.displayName)
    end
    return displayNames
end

-- Hàm để lấy thông tin chi tiết về unit đã chọn
local function getUnitDetailsByDisplayName(displayName)
    for _, unit in ipairs(availableUnits) do
        if unit.displayName == displayName then
            return unit
        end
    end
    return nil
end

-- Hàm để kiểm tra xem giá trị potential hiện tại có nằm trong danh sách mong muốn không
local function isPotentialValueInTargetList(currentValue, targetValues)
    -- Nếu không có giá trị nào được chọn, không cần roll
    if not targetValues or next(targetValues) == nil then
        return true
    end

    -- Kiểm tra xem giá trị hiện tại có nằm trong danh sách mong muốn không
    return targetValues[currentValue] == true
end

-- Hàm để roll stats potential
local function rollStatsPotential()
    if not selectedUnit or not selectedUnitTag then
        print("Không có unit nào được chọn để roll stats.")
        return
    end

    local unitRef = selectedUnit.ref
    if not unitRef then
        print("Không tìm thấy thông tin unit.")
        return
    end

    local stats = {
        { name = "Damage",         potential = "DamagePotential",         selected = selectedDamageValues },
        { name = "Health",         potential = "HealthPotential",         selected = selectedHealthValues },
        { name = "Speed",          potential = "SpeedPotential",          selected = selectedSpeedValues },
        { name = "Range",          potential = "RangePotential",          selected = selectedRangeValues },
        { name = "AttackCooldown", potential = "AttackCooldownPotential", selected = selectedCooldownValues }
    }

    local rollCount = 0

    for _, stat in ipairs(stats) do
        -- Kiểm tra xem có giá trị nào được chọn không
        if next(stat.selected) ~= nil then
            local potentialValue = unitRef:FindFirstChild(stat.potential) and unitRef[stat.potential].Value or ""

            -- Kiểm tra xem giá trị hiện tại có nằm trong danh sách mong muốn không
            if not isPotentialValueInTargetList(potentialValue, stat.selected) then
                -- Thực hiện roll cho stat này
                local statArgName = stat.name
                if statArgName == "AttackCooldown" then
                    statArgName = "AttackCooldown"
                end

                local args = {
                    statArgName,
                    selectedUnitTag,
                    "Selective"
                }

                local rerollRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server")
                    :WaitForChild("Gambling"):WaitForChild("RerollPotential")
                rerollRemote:FireServer(unpack(args))

                print("Đã roll " ..
                    stat.name .. " cho " .. selectedUnit.name .. " - Giá trị hiện tại: " .. potentialValue)
                rollCount = rollCount + 1
                wait(1) -- Đợi 1 giây giữa các lần roll
            else
                print(stat.name .. " đã đạt giá trị mong muốn: " .. potentialValue)
            end
        end
    end

    if rollCount == 0 then
        print("Không có stat nào cần roll cho " .. selectedUnit.name)
    else
        print("Đã roll " .. rollCount .. " stats cho " .. selectedUnit.name)
    end
end

-- Quét danh sách các unit có sẵn
availableUnits = scanAvailableUnits()

-- Dropdown để chọn Unit
local unitDropdown = StatsPotentialSection:AddDropdown("UnitDropdown", {
    Title = "Choose Unit",
    Values = getUnitDisplayNames(),
    Multi = false,
    Default = "",
    Callback = function(Value)
        local unit = getUnitDetailsByDisplayName(Value)
        if unit then
            selectedUnit = unit
            selectedUnitTag = unit.tag
            print("Đã chọn unit: " .. unit.name .. " (Tag: " .. unit.tag .. ")")

            -- Hiển thị thông tin chi tiết về potential hiện tại
            local unitRef = unit.ref
            if unitRef then
                local damageValue = unitRef:FindFirstChild("DamagePotential") and unitRef.DamagePotential.Value or "N/A"
                local healthValue = unitRef:FindFirstChild("HealthPotential") and unitRef.HealthPotential.Value or "N/A"
                local speedValue = unitRef:FindFirstChild("SpeedPotential") and unitRef.SpeedPotential.Value or "N/A"
                local rangeValue = unitRef:FindFirstChild("RangePotential") and unitRef.RangePotential.Value or "N/A"
                local cooldownValue = unitRef:FindFirstChild("AttackCooldownPotential") and
                    unitRef.AttackCooldownPotential.Value or "N/A"

                print("Stats Potential hiện tại:")
                print("- Damage: " .. damageValue)
                print("- Health: " .. healthValue)
                print("- Speed: " .. speedValue)
                print("- Range: " .. rangeValue)
                print("- Cooldown: " .. cooldownValue)
            end
        else
            selectedUnit = nil
            selectedUnitTag = nil
            print("Không tìm thấy thông tin unit")
        end
    end
})

-- Nút Refresh Units
StatsPotentialSection:AddButton({
    Title = "Refresh Units List",
    Callback = function()
        print("Đang cập nhật danh sách units...")
        availableUnits = scanAvailableUnits()

        if #availableUnits > 0 then
            if unitDropdown and unitDropdown.SetValues then
                unitDropdown:SetValues(getUnitDisplayNames())
                print("Đã cập nhật danh sách với " .. #availableUnits .. " units")
            end
        else
            print("Không tìm thấy unit nào trong Collection")
        end
    end
})

-- Định nghĩa các giá trị potential
local potentialValues = { "S", "S-", "S+", "SS", "SSS", "O", "O-", "O+" }

-- Dropdown để chọn giá trị Damage Potential
StatsPotentialSection:AddDropdown("DamageDropdown", {
    Title = "Damage",
    Values = potentialValues,
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedDamageValues = Values
        ConfigSystem.CurrentConfig.SelectedDamageValues = Values
        ConfigSystem.SaveConfig()

        local selectedText = ""
        for value, isSelected in pairs(Values) do
            if isSelected then
                selectedText = selectedText .. value .. ", "
            end
        end

        if selectedText ~= "" then
            selectedText = selectedText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            print("Mục tiêu Damage: " .. selectedText)
        else
            print("Không có mục tiêu Damage nào được chọn")
        end
    end
})

-- Dropdown để chọn giá trị Health Potential
StatsPotentialSection:AddDropdown("HealthDropdown", {
    Title = "Health",
    Values = potentialValues,
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedHealthValues = Values
        ConfigSystem.CurrentConfig.SelectedHealthValues = Values
        ConfigSystem.SaveConfig()

        local selectedText = ""
        for value, isSelected in pairs(Values) do
            if isSelected then
                selectedText = selectedText .. value .. ", "
            end
        end

        if selectedText ~= "" then
            selectedText = selectedText:sub(1, -3)
            print("Mục tiêu Health: " .. selectedText)
        else
            print("Không có mục tiêu Health nào được chọn")
        end
    end
})

-- Dropdown để chọn giá trị Speed Potential
StatsPotentialSection:AddDropdown("SpeedDropdown", {
    Title = "Speed",
    Values = potentialValues,
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedSpeedValues = Values
        ConfigSystem.CurrentConfig.SelectedSpeedValues = Values
        ConfigSystem.SaveConfig()

        local selectedText = ""
        for value, isSelected in pairs(Values) do
            if isSelected then
                selectedText = selectedText .. value .. ", "
            end
        end

        if selectedText ~= "" then
            selectedText = selectedText:sub(1, -3)
            print("Mục tiêu Speed: " .. selectedText)
        else
            print("Không có mục tiêu Speed nào được chọn")
        end
    end
})

-- Dropdown để chọn giá trị Range Potential
StatsPotentialSection:AddDropdown("RangeDropdown", {
    Title = "Range",
    Values = potentialValues,
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedRangeValues = Values
        ConfigSystem.CurrentConfig.SelectedRangeValues = Values
        ConfigSystem.SaveConfig()

        local selectedText = ""
        for value, isSelected in pairs(Values) do
            if isSelected then
                selectedText = selectedText .. value .. ", "
            end
        end

        if selectedText ~= "" then
            selectedText = selectedText:sub(1, -3)
            print("Mục tiêu Range: " .. selectedText)
        else
            print("Không có mục tiêu Range nào được chọn")
        end
    end
})

-- Dropdown để chọn giá trị Cooldown Potential
StatsPotentialSection:AddDropdown("CooldownDropdown", {
    Title = "Cooldown",
    Values = potentialValues,
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedCooldownValues = Values
        ConfigSystem.CurrentConfig.SelectedCooldownValues = Values
        ConfigSystem.SaveConfig()

        local selectedText = ""
        for value, isSelected in pairs(Values) do
            if isSelected then
                selectedText = selectedText .. value .. ", "
            end
        end

        if selectedText ~= "" then
            selectedText = selectedText:sub(1, -3)
            print("Mục tiêu Cooldown: " .. selectedText)
        else
            print("Không có mục tiêu Cooldown nào được chọn")
        end
    end
})

-- Toggle Roll Stats Potential
StatsPotentialSection:AddToggle("RollStatsPotentialToggle", {
    Title = "Roll Stats Potential",
    Default = autoRollStatsEnabled,
    Callback = function(Value)
        autoRollStatsEnabled = Value
        ConfigSystem.CurrentConfig.AutoRollStats = Value
        ConfigSystem.SaveConfig()

        if Value then
            if not selectedUnit then
                print("Vui lòng chọn unit trước khi bật Roll Stats Potential")
                -- Trả về toggle về trạng thái tắt
                StatsPotentialSection:GetComponent("RollStatsPotentialToggle"):Set(false)
                return
            end

            print("Roll Stats Potential đã được bật cho unit: " .. selectedUnit.name)

            -- Thực hiện roll ngay lập tức
            rollStatsPotential()

            -- Tạo vòng lặp để kiểm tra và roll nếu cần
            if autoRollStatsLoop then
                autoRollStatsLoop:Disconnect()
                autoRollStatsLoop = nil
            end

            spawn(function()
                while autoRollStatsEnabled and wait(0.5) do
                    if selectedUnit then
                        -- Quét lại thông tin unit để lấy potential hiện tại
                        local currentUnits = scanAvailableUnits()
                        local updatedUnit = nil

                        -- Tìm unit có cùng tag với unit đang chọn
                        for _, unit in ipairs(currentUnits) do
                            if unit.tag == selectedUnitTag then
                                updatedUnit = unit
                                break
                            end
                        end

                        -- Cập nhật unit nếu tìm thấy
                        if updatedUnit then
                            selectedUnit = updatedUnit

                            -- Hiển thị thông tin chi tiết về potential hiện tại sau mỗi lần roll
                            local unitRef = selectedUnit.ref
                            if unitRef then
                                local damageValue = unitRef:FindFirstChild("DamagePotential") and
                                    unitRef.DamagePotential.Value or "N/A"
                                local healthValue = unitRef:FindFirstChild("HealthPotential") and
                                    unitRef.HealthPotential.Value or "N/A"
                                local speedValue = unitRef:FindFirstChild("SpeedPotential") and
                                    unitRef.SpeedPotential.Value or "N/A"
                                local rangeValue = unitRef:FindFirstChild("RangePotential") and
                                    unitRef.RangePotential.Value or "N/A"
                                local cooldownValue = unitRef:FindFirstChild("AttackCooldownPotential") and
                                    unitRef.AttackCooldownPotential.Value or "N/A"

                                print("Stats Potential hiện tại của " .. selectedUnit.name .. ":")
                                print("- Damage: " .. damageValue)
                                print("- Health: " .. healthValue)
                                print("- Speed: " .. speedValue)
                                print("- Range: " .. rangeValue)
                                print("- Cooldown: " .. cooldownValue)
                            end
                        end

                        rollStatsPotential()
                    else
                        print("Không có unit nào được chọn để roll stats")
                        autoRollStatsEnabled = false
                        StatsPotentialSection:GetComponent("RollStatsPotentialToggle"):Set(false)
                        break
                    end
                end
            end)
        else
            print("Roll Stats Potential đã được tắt")

            if autoRollStatsLoop then
                autoRollStatsLoop:Disconnect()
                autoRollStatsLoop = nil
            end
        end
    end
})

-- Hàm để theo dõi RewardsUI và kích hoạt Auto Retry và Auto Next
local function setupRewardsUIWatcher()
    spawn(function()
        -- Sử dụng pcall để tránh lỗi khi không tìm thấy PlayerGui
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if not player then return end

            -- Đợi PlayerGui load
            while not player:FindFirstChild("PlayerGui") do wait(0.1) end
            local PlayerGui = player.PlayerGui

            -- Biến để theo dõi khi nào đã thực hiện Auto Retry/Auto Next
            local hasTriggeredAction = false

            -- Hàm để mô phỏng một click chuột
            local function simulateClick()
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

                -- Lấy kích thước màn hình hiện tại
                local guiInset = game:GetService("GuiService"):GetGuiInset()
                local screenSize = workspace.CurrentCamera.ViewportSize

                -- Tính toán vị trí trung tâm màn hình (vị trí tốt nhất để click)
                local centerX = screenSize.X / 2
                local centerY = screenSize.Y / 2

                -- Tạo click tại trung tâm màn hình
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                wait(0.05) -- Độ trễ nhỏ
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)

                -- Thử click thêm vài vị trí nếu cần thiết (4 góc màn hình)
                local testPositions = {
                    { X = centerX,       Y = centerY },       -- Trung tâm
                    { X = centerX * 0.9, Y = centerY * 1.5 }, -- Phía dưới
                    { X = centerX * 1.5, Y = centerY * 0.9 }, -- Phía phải
                    { X = centerX * 0.5, Y = centerY * 0.5 }  -- Phía trên bên trái
                }

                for _, pos in ipairs(testPositions) do
                    if pos.X > 0 and pos.X < screenSize.X and pos.Y > 0 and pos.Y < screenSize.Y then
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                        wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                        wait(0.05)
                    end
                end

                -- Thông báo debug
                print("Đã thực hiện click tự động trên màn hình " .. screenSize.X .. "x" .. screenSize.Y)
            end

            -- Theo dõi khi GameEndedAnimationUI được thêm vào PlayerGui
            PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "GameEndedAnimationUI" then
                    warn("Đã phát hiện GameEndedAnimationUI")
                    hasTriggeredAction = false

                    -- Chỉ kích hoạt tính năng này nếu Auto Retry hoặc Auto Next được bật
                    if autoRetryEnabled or autoNextEnabled then
                        -- Lặp liên tục click cho tới khi RewardsUI.Enabled = true
                        task.spawn(function()
                            while true do
                                task.wait(0.5) -- thời gian chờ giữa mỗi click, tránh spam quá nhanh

                                local rewardsUI = PlayerGui:FindFirstChild("RewardsUI")
                                if rewardsUI and rewardsUI.Enabled then
                                    warn("RewardsUI đã bật. Ngưng click.")
                                    break
                                end

                                warn("Đang thực hiện click tự động...")
                                simulateClick()
                            end
                        end)
                    end
                end
            end)

            -- Kiểm tra RewardsUI định kỳ
            while wait(0.5) do
                local rewardsUI = player.PlayerGui:FindFirstChild("RewardsUI")

                -- Chỉ kích hoạt nếu RewardsUI được bật VÀ chưa thực hiện Auto Retry/Auto Next
                if rewardsUI and rewardsUI.Enabled and not hasTriggeredAction then
                    print("RewardsUI được bật lên, sẽ kích hoạt Auto Retry và Auto Next sau 1s")
                    wait(1) -- Đợi 1 giây như yêu cầu

                    -- Đánh dấu đã kích hoạt để không kích hoạt lại liên tục
                    hasTriggeredAction = true

                    -- Kích hoạt Auto Retry/Auto Next một lần duy nhất
                    if autoRetryEnabled then
                        print("Kích hoạt Auto Retry...")
                        toggleAutoRetry()
                    end

                    if autoNextEnabled then
                        print("Kích hoạt Auto Next...")
                        toggleAutoNext()
                    end

                    -- Reset cờ hasTriggeredAction sau 5 giây để chuẩn bị cho lần tiếp theo
                    spawn(function()
                        wait(5)
                        hasTriggeredAction = false
                    end)
                end
            end
        end)
    end)
end

-- Gọi hàm theo dõi RewardsUI khi script khởi động
setupRewardsUIWatcher()

-- end
print("HT Hub | Anime Rangers X đã được tải thành công!")

-- Thêm section Trait Reroll trong tab Unit
local TraitRerollSection = UnitTab:AddSection("Trait Reroll")

-- Biến lưu trạng thái
local selectedUnit = nil
local selectedUnitDisplay = ""
local selectedTraits = {}
local autoTraitRerollEnabled = false
local autoTraitRerollLoop = nil
local unitCollectionCache = {}

-- Hàm để quét danh sách unit từ Collection
local function scanUnitCollection()
    unitCollectionCache = {}
    local displayUnits = {}

    local success, result = pcall(function()
        local playerName = game:GetService("Players").LocalPlayer.Name
        local collectionPath = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data", 2):WaitForChild(
            playerName, 2):WaitForChild("Collection", 2)

        if not collectionPath then
            print(" Không tìm thấy Collection")
            return {}
        end

        -- Tạo bản đồ đếm số lượng unit trùng tên
        local unitCountMap = {}

        -- Quét lần đầu để đếm số lượng unit cùng tên
        for _, unit in pairs(collectionPath:GetChildren()) do
            local unitName = unit.Name
            local level = unit:FindFirstChild("Level") and unit.Level.Value or 0

            local baseKey = unitName .. " Lv: " .. level
            unitCountMap[baseKey] = (unitCountMap[baseKey] or 0) + 1
        end

        -- Quét lần thứ hai để tạo key hiển thị duy nhất
        local unitIndexMap = {} -- Bản đồ lưu index hiện tại của mỗi loại unit

        for _, unit in pairs(collectionPath:GetChildren()) do
            local unitName = unit.Name
            local level = unit:FindFirstChild("Level") and unit.Level.Value or 0

            local baseKey = unitName .. " Lv: " .. level

            -- Khởi tạo index nếu chưa tồn tại
            if not unitIndexMap[baseKey] then
                unitIndexMap[baseKey] = 0
            end

            -- Tăng index lên 1
            unitIndexMap[baseKey] = unitIndexMap[baseKey] + 1

            -- Tạo key hiển thị
            local displayKey = baseKey

            -- Tìm thêm thuộc tính phụ để phân biệt
            local primaryTrait = unit:FindFirstChild("PrimaryTrait") and unit.PrimaryTrait.Value or "None"
            local secondaryTrait = unit:FindFirstChild("SecondaryTrait") and unit.SecondaryTrait.Value or "None"

            -- Nếu có trait, thêm vào key để dễ phân biệt
            if primaryTrait ~= "None" or secondaryTrait ~= "None" then
                displayKey = displayKey .. " (" .. primaryTrait
                if secondaryTrait ~= "None" then
                    displayKey = displayKey .. ", " .. secondaryTrait
                end
                displayKey = displayKey .. ")"
            end

            -- Nếu có nhiều unit trùng tên, thêm index vào cuối
            if unitCountMap[baseKey] > 1 then
                displayKey = displayKey .. " #" .. unitIndexMap[baseKey]
            end

            -- Lưu vào cache để sử dụng sau
            unitCollectionCache[displayKey] = unit
            table.insert(displayUnits, displayKey)
        end

        return displayUnits
    end)

    if not success then
        warn("Lỗi khi quét unit collection: " .. tostring(result))
        return {}
    end

    table.sort(displayUnits) -- Sắp xếp theo thứ tự bảng chữ cái
    return displayUnits
end

-- Hàm để thực hiện reroll trait
local function rerollTrait(unitObject)
    if not unitObject then return false end

    local success, result = pcall(function()
        local rerollRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 2):WaitForChild("Server", 2)
            :WaitForChild("Gambling", 2):WaitForChild("RerollTrait", 2)

        if not rerollRemote then
            warn("Không tìm thấy RerollTrait Remote")
            return false
        end

        local args = {
            unitObject,
            "Reroll",
            "Main",
            "Shards"
        }

        rerollRemote:FireServer(unpack(args))
        return true
    end)

    if not success then
        warn("Lỗi khi reroll trait: " .. tostring(result))
        return false
    end

    return result
end

-- Hàm kiểm tra xem unit hiện tại có trait mong muốn không
local function checkTraitMatch(unitObject)
    if not unitObject then return false end

    local success, result = pcall(function()
        local primaryTrait = unitObject:FindFirstChild("PrimaryTrait") and unitObject.PrimaryTrait.Value or ""
        local secondaryTrait = unitObject:FindFirstChild("SecondaryTrait") and unitObject.SecondaryTrait.Value or ""

        -- Kiểm tra xem có bất kỳ trait nào khớp với danh sách đã chọn
        for trait, isSelected in pairs(selectedTraits) do
            if isSelected then
                if primaryTrait == trait or secondaryTrait == trait then
                    print("Đã tìm thấy trait mong muốn: " ..
                        trait .. " (Primary: " .. primaryTrait .. ", Secondary: " .. secondaryTrait .. ")")
                    return true
                end
            end
        end

        return false
    end)

    if not success then
        warn("Lỗi khi kiểm tra trait: " .. tostring(result))
        return false
    end

    return result
end

-- Quét unit collection ban đầu
local unitDisplayList = scanUnitCollection()

-- Dropdown để chọn Unit
local unitDropdown = TraitRerollSection:AddDropdown("UnitDropdown", {
    Title = "Choose Unit",
    Values = unitDisplayList,
    Multi = false,
    Default = "",
    Callback = function(Value)
        selectedUnitDisplay = Value
        selectedUnit = unitCollectionCache[Value]

        if selectedUnit then
            local primaryTrait = selectedUnit:FindFirstChild("PrimaryTrait") and selectedUnit.PrimaryTrait.Value or
                "None"
            local secondaryTrait = selectedUnit:FindFirstChild("SecondaryTrait") and selectedUnit.SecondaryTrait.Value or
                "None"

            print("Đã chọn unit: " .. selectedUnitDisplay)
            print("Current Traits - Primary: " .. primaryTrait .. ", Secondary: " .. secondaryTrait)
        else
            print("Không tìm thấy thông tin về unit đã chọn")
        end
    end
})

-- Dropdown để chọn Trait
TraitRerollSection:AddDropdown("TraitDropdown", {
    Title = "Choose Trait",
    Values = { "Seraph", "Capitalist", "Duplicator", "Soversign" },
    Multi = true,
    Default = {},
    Callback = function(Values)
        selectedTraits = Values

        local selectedTraitsList = {}
        for trait, isSelected in pairs(Values) do
            if isSelected then
                table.insert(selectedTraitsList, trait)
            end
        end

        if #selectedTraitsList > 0 then
            print("Đã chọn trait: " .. table.concat(selectedTraitsList, ", "))
        else
            print("Chưa chọn trait nào")
        end
    end
})

-- Toggle Auto Roll Trait
TraitRerollSection:AddToggle("RollTraitToggle", {
    Title = "Roll Trait",
    Default = false,
    Callback = function(Value)
        autoTraitRerollEnabled = Value

        if Value then
            if not selectedUnit then
                print(" Vui lòng chọn unit trước khi bật Roll Trait")
                -- Reset toggle về false
                TraitRerollSection:GetComponent("RollTraitToggle"):Set(false)
                return
            end

            local hasSelectedTrait = false
            for _, isSelected in pairs(selectedTraits) do
                if isSelected then
                    hasSelectedTrait = true
                    break
                end
            end

            if not hasSelectedTrait then
                print(" Vui lòng chọn ít nhất một trait để roll")
                -- Reset toggle về false
                TraitRerollSection:GetComponent("RollTraitToggle"):Set(false)
                return
            end

            print(" Bắt đầu Roll Trait cho " .. selectedUnitDisplay)

            -- Kiểm tra ngay lập tức nếu unit đã có trait mong muốn
            if checkTraitMatch(selectedUnit) then
                print(" Unit đã có trait mong muốn. Không cần roll thêm.")
                -- Reset toggle về false
                TraitRerollSection:GetComponent("RollTraitToggle"):Set(false)
                return
            end

            -- Bắt đầu vòng lặp roll trait
            spawn(function()
                while autoTraitRerollEnabled do
                    -- Thực hiện reroll
                    local success = rerollTrait(selectedUnit)

                    if success then
                        -- Đợi một chút để dữ liệu cập nhật
                        wait(0.2)

                        -- Kiểm tra trait sau khi roll
                        if checkTraitMatch(selectedUnit) then
                            print(" Đã roll được trait mong muốn! Dừng tự động roll.")
                            autoTraitRerollEnabled = false
                            -- Reset toggle về false
                            TraitRerollSection:GetComponent("RollTraitToggle"):Set(false)
                            break
                        end
                    else
                        -- Nếu reroll thất bại, đợi thêm thời gian
                        wait(1)
                    end

                    -- Đợi một chút giữa các lần roll để tránh spam
                    wait(0.3)
                end
            end)
        else
            print(" Đã dừng Roll Trait")
        end
    end
})

-- Button Refresh Unit List
TraitRerollSection:AddButton({
    Title = "Refresh",
    Callback = function()
        local newUnitList = scanUnitCollection()

        if #newUnitList > 0 then
            unitDropdown:SetValues(newUnitList)
            print(" Đã làm mới danh sách unit: " .. #newUnitList .. " unit")
        else
            print(" Không tìm thấy unit nào trong Collection")
        end
    end
})

-- Tạo hệ thống toàn cục để giảm số lượng biến cục bộ
_G.SystemManager = _G.SystemManager or {}

-- Hợp nhất tất cả các biến Portal vào một bảng
_G.SystemManager.Portal = {
    SelectedPortals = ConfigSystem.CurrentConfig.SelectedPortals or {},
    AutoOpenEnabled = ConfigSystem.CurrentConfig.AutoOpenPortal or false,
    AutoOpenLoop = nil,
    AutoStartEnabled = ConfigSystem.CurrentConfig.AutoStartPortal or false,
    AutoStartLoop = nil,

    Open = function(portalName)
        local success, err = pcall(function()
            local playerName = game:GetService("Players").LocalPlayer.Name
            local portalItem = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(playerName)
                :WaitForChild("Items"):WaitForChild(portalName)

            if portalItem then
                local args = { portalItem }
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby")
                    :WaitForChild("ItemUse"):FireServer(unpack(args))
                print("Đã mở: " .. portalName)
                return true
            else
                print("Không tìm thấy portal: " .. portalName)
                return false
            end
        end)

        if not success then
            warn("Lỗi khi mở portal: " .. tostring(err))
            return false
        end

        return success
    end,

    Start = function()
        local success, err = pcall(function()
            local args = {
                "Start"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby")
                :WaitForChild("PortalEvent"):FireServer(unpack(args))
            print("Đã gửi lệnh Start Portal")
        end)

        if not success then
            warn("Lỗi khi bắt đầu Portal: " .. tostring(err))
            return false
        end

        return true
    end
}

-- Hợp nhất RC Exchange vào bảng toàn cục
_G.SystemManager.RCExchange = {
    AutoBuyEnabled = ConfigSystem.CurrentConfig.AutoBuyQuinque or false,
    AutoBuyLoop = nil,

    BuyQuinque = function()
        local success, err = pcall(function()
            local args = {
                "Quinque Box",
                1
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay")
                :WaitForChild("RCExchange"):FireServer(unpack(args))
            print("Đã mua Quinque Box")
        end)

        if not success then
            warn("Lỗi khi mua Quinque Box: " .. tostring(err))
        end
    end
}

-- Cập nhật lại các tham chiếu tới các biến Portal
local PortalSection = PortalTab:AddSection("Portal")

-- Dropdown để chọn Portal
PortalSection:AddDropdown("PortalDropdown", {
    Title = "Choose Portal",
    Values = { "Ghoul City Portal I", "Ghoul City Portal II", "Ghoul City Portal III" },
    Multi = true,
    Default = ConfigSystem.CurrentConfig.SelectedPortals or {},
    Callback = function(Values)
        _G.SystemManager.Portal.SelectedPortals = Values
        ConfigSystem.CurrentConfig.SelectedPortals = Values
        ConfigSystem.SaveConfig()

        local selectedPortalsList = {}
        for portal, isSelected in pairs(Values) do
            if isSelected then
                table.insert(selectedPortalsList, portal)
            end
        end

        if #selectedPortalsList > 0 then
            print("Đã chọn portal: " .. table.concat(selectedPortalsList, ", "))
        else
            print("Chưa chọn portal nào")
        end
    end
})

-- Toggle Auto Open Portal
PortalSection:AddToggle("OpenPortalToggle", {
    Title = "Open Portal",
    Default = ConfigSystem.CurrentConfig.AutoOpenPortal or false,
    Callback = function(Value)
        _G.SystemManager.Portal.AutoOpenEnabled = Value
        ConfigSystem.CurrentConfig.AutoOpenPortal = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Kiểm tra nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, không thể kích hoạt Open Portal. Vui lòng trở về lobby trước.")
                -- Reset toggle về false
                PortalSection:GetComponent("OpenPortalToggle"):Set(false)
                return
            end

            local hasSelectedPortal = false
            for _, isSelected in pairs(_G.SystemManager.Portal.SelectedPortals) do
                if isSelected then
                    hasSelectedPortal = true
                    break
                end
            end

            if not hasSelectedPortal then
                print("Vui lòng chọn ít nhất một portal trước khi bật Open Portal")
                -- Reset toggle về false
                PortalSection:GetComponent("OpenPortalToggle"):Set(false)
                return
            end

            print("Auto Open Portal đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if _G.SystemManager.Portal.AutoOpenLoop then
                _G.SystemManager.Portal.AutoOpenLoop:Disconnect()
                _G.SystemManager.Portal.AutoOpenLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                while _G.SystemManager.Portal.AutoOpenEnabled and wait(1) do
                    -- Kiểm tra liên tục xem người chơi có vào map không
                    if isPlayerInMap() then
                        print("Đã phát hiện người chơi vào map, tự động tắt Open Portal")
                        _G.SystemManager.Portal.AutoOpenEnabled = false
                        PortalSection:GetComponent("OpenPortalToggle"):Set(false)
                        break
                    end

                    for portal, isSelected in pairs(_G.SystemManager.Portal.SelectedPortals) do
                        if isSelected then
                            _G.SystemManager.Portal.Open(portal)
                            wait(0.5) -- Đợi 0.5 giây giữa các lần mở portal
                        end
                    end

                    wait(10) -- Đợi 10 giây trước khi bắt đầu vòng lặp mới
                end
            end)
        else
            print("Auto Open Portal đã được tắt")

            -- Hủy vòng lặp nếu có
            if _G.SystemManager.Portal.AutoOpenLoop then
                _G.SystemManager.Portal.AutoOpenLoop:Disconnect()
                _G.SystemManager.Portal.AutoOpenLoop = nil
            end
        end
    end
})

-- Toggle Start Portal
PortalSection:AddToggle("StartPortalToggle", {
    Title = "Start Portal",
    Default = ConfigSystem.CurrentConfig.AutoStartPortal or false,
    Callback = function(Value)
        _G.SystemManager.Portal.AutoStartEnabled = Value
        ConfigSystem.CurrentConfig.AutoStartPortal = Value
        ConfigSystem.SaveConfig()

        if Value then
            -- Kiểm tra nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, không thể kích hoạt Start Portal. Vui lòng trở về lobby trước.")
                -- Reset toggle về false
                PortalSection:GetComponent("StartPortalToggle"):Set(false)
                return
            end

            print("Auto Start Portal đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if _G.SystemManager.Portal.AutoStartLoop then
                _G.SystemManager.Portal.AutoStartLoop:Disconnect()
                _G.SystemManager.Portal.AutoStartLoop = nil
            end

            -- Gọi ngay một lần
            _G.SystemManager.Portal.Start()

            -- Tạo vòng lặp mới
            spawn(function()
                while _G.SystemManager.Portal.AutoStartEnabled and wait(1) do
                    -- Kiểm tra liên tục xem người chơi có vào map không
                    if isPlayerInMap() then
                        print("Đã phát hiện người chơi vào map, tự động tắt Start Portal")
                        _G.SystemManager.Portal.AutoStartEnabled = false
                        PortalSection:GetComponent("StartPortalToggle"):Set(false)
                        break
                    end

                    -- Gửi lệnh Start Portal mỗi 3 giây
                    _G.SystemManager.Portal.Start()
                    wait(3) -- Đợi 3 giây giữa các lần gửi lệnh Start
                end
            end)
        else
            print("Auto Start Portal đã được tắt")

            -- Hủy vòng lặp nếu có
            if _G.SystemManager.Portal.AutoStartLoop then
                _G.SystemManager.Portal.AutoStartLoop:Disconnect()
                _G.SystemManager.Portal.AutoStartLoop = nil
            end
        end
    end
})

-- Thêm section RC Exchange trong tab Shop
local RCExchangeSection = ShopTab:AddSection("RC Exchange")

-- Toggle Buy Quinque
RCExchangeSection:AddToggle("BuyQuinqueToggle", {
    Title = "Buy Quinque",
    Default = ConfigSystem.CurrentConfig.AutoBuyQuinque or false,
    Callback = function(Value)
        _G.SystemManager.RCExchange.AutoBuyEnabled = Value
        ConfigSystem.CurrentConfig.AutoBuyQuinque = Value
        ConfigSystem.SaveConfig()

        if Value then
            print("Auto Buy Quinque đã được bật")

            -- Hủy vòng lặp cũ nếu có
            if _G.SystemManager.RCExchange.AutoBuyLoop then
                _G.SystemManager.RCExchange.AutoBuyLoop:Disconnect()
                _G.SystemManager.RCExchange.AutoBuyLoop = nil
            end

            -- Tạo vòng lặp mới
            spawn(function()
                while _G.SystemManager.RCExchange.AutoBuyEnabled do
                    _G.SystemManager.RCExchange.BuyQuinque()
                    wait(0.5) -- Đợi 0.5 giây giữa các lần mua
                end
            end)
        else
            print("Auto Buy Quinque đã được tắt")

            -- Hủy vòng lặp nếu có
            if _G.SystemManager.RCExchange.AutoBuyLoop then
                _G.SystemManager.RCExchange.AutoBuyLoop:Disconnect()
                _G.SystemManager.RCExchange.AutoBuyLoop = nil
            end
        end
    end
})
