-- Load UI Library với error handling
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
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
ConfigSystem.FileName = "HTHubALS_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Event Settings
    DelayTime = 3,
    HalloweenEventEnabled = false,
    -- Macro Settings
    SelectedMacro = "",
    PlayMacroEnabled = false,
    -- Sell All Settings
    SellAllEnabled = false,
    SellAllWave = 0,
    -- In Game Settings
    AutoRetryEnabled = false,
    AutoNextEnabled = false,
    AutoLeaveEnabled = false,
    -- Webhook Settings
    WebhookEnabled = false,
    WebhookURL = "",
    AntiAFKEnabled = false,
    AutoHideUIEnabled = false,
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
        -- Thử parse JSON với error handling
        local parseSuccess, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(content)
        end)

        if parseSuccess and data then
            ConfigSystem.CurrentConfig = data
            print("Config loaded successfully!")
            return true
        else
            warn("Config file corrupted, using default config. Error:", data)
            ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
            ConfigSystem.SaveConfig()
            return false
        end
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Lấy tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "HT HUB | Anime Last Stand",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 220),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Hệ thống Tạo Tab
-- Tạo Tab Joiner
local JoinerTab = Window:AddTab({ Title = "Joiner", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab In Game
local InGameTab = Window:AddTab({ Title = "In Game", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab Webhook
local WebhookTab = Window:AddTab({ Title = "Webhook", Icon = "rbxassetid://90319448802378" })
-- Tạo Tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://90319448802378" })

-- tự động chọn JoinerTab khi mở script
pcall(function()
    if JoinerTab and JoinerTab.Select then
        JoinerTab:Select()
    elseif Window and Window.SelectTab then
        Window:SelectTab(1)
    end
end)

-- Tab Joiner
-- Section Event trong tab Joiner
local EventSection = JoinerTab:AddSection("Event")

-- Tab In Game
-- Section Auto Play trong tab In Game
local AutoPlaySection = InGameTab:AddSection("Auto Play")

-- Tab Settings
-- Sell All Unit Section in Settings tab
local SellAllSection = SettingsTab:AddSection("Sell All Unit")
-- Settings tab configuration in Settings tab
local SettingsSection = SettingsTab:AddSection("Script Settings")

--Tab Joiner Save Settings
-- Biến lưu trạng thái Halloween Event
local halloweenEventEnabled = ConfigSystem.CurrentConfig.HalloweenEventEnabled or false
local delayTime = ConfigSystem.CurrentConfig.DelayTime or 3

--Tab Settings Save Settings
-- Biến lưu trạng thái Sell All
local sellAllEnabled = ConfigSystem.CurrentConfig.SellAllEnabled or false
local sellAllWave = ConfigSystem.CurrentConfig.SellAllWave or 0
local waveConnection = nil

--Tab In Game Save Settings
-- Biến lưu trạng thái Auto Play
local autoRetryEnabled = ConfigSystem.CurrentConfig.AutoRetryEnabled or false
local autoNextEnabled = ConfigSystem.CurrentConfig.AutoNextEnabled or false
local autoLeaveEnabled = ConfigSystem.CurrentConfig.AutoLeaveEnabled or false
local endGameUIConnection = nil

--Tab Webhook Save Settings
-- Biến lưu trạng thái Webhook
local webhookEnabled = ConfigSystem.CurrentConfig.WebhookEnabled or false
local webhookURL = ConfigSystem.CurrentConfig.WebhookURL or ""
-- Biến lưu trạng thái Anti AFK
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFKEnabled or false
local antiAFKConn = nil
-- Biến lưu trạng thái Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUIEnabled or false


-- Hàm tự động ẩn UI sau 3 giây khi bật
local function autoHideUI()
    if not Window then return end
    task.spawn(function()
        print("Auto Hide UI: Sẽ tự động ẩn sau 3 giây...")
        task.wait(3)
        if Window.Minimize then
            Window:Minimize()
            print("UI đã được ẩn!")
        elseif Window.Visible ~= nil then
            Window.Visible = false
            print("UI đã bị ẩn thông qua Visible!")
        end
    end)
end

--Hàm Anti AFK
local function startAntiAFK()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
    local vu = game:GetService("VirtualUser")
    antiAFKConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        print("Đã chống AFK!")
    end)
end

local function stopAntiAFK()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
end

-- Hàm thực thi Halloween Event
local function executeHalloweenEvent()
    if not halloweenEventEnabled then return end

    local success, err = pcall(function()
        -- Bước 1: Enter Halloween Event
        print("Bước 1: Entering Halloween Event...")
        game:GetService("ReplicatedStorage").Events.Hallowen2025.Enter:FireServer()

        -- Bước 2: Đợi delay time rồi Start
        task.wait(delayTime)

        if halloweenEventEnabled then -- Kiểm tra lại sau khi đợi
            print("Bước 2: Starting Halloween Event...")
            game:GetService("ReplicatedStorage").Events.Hallowen2025.Start:FireServer()
            print("Halloween Event executed successfully!")
        end
    end)

    if not success then
        warn("Lỗi Halloween Event:", err)
    end
end

-- Input Delay Time
EventSection:AddInput("DelayTimeInput", {
    Title = "Delay Time",
    Default = tostring(delayTime),
    Placeholder = "(1-60s)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 1 and num <= 60 then
            delayTime = num
            ConfigSystem.CurrentConfig.DelayTime = delayTime
            ConfigSystem.SaveConfig()
            print("Delay time set to:", delayTime, "seconds")
        else
            warn("Delay time must be between 1-60 seconds")
        end
    end
})

-- Toggle Join Halloween Event
EventSection:AddToggle("HalloweenEventToggle", {
    Title = "Join Halloween Event",
    Description = "Auto Join Halloween",
    Default = halloweenEventEnabled,
    Callback = function(enabled)
        halloweenEventEnabled = enabled
        ConfigSystem.CurrentConfig.HalloweenEventEnabled = halloweenEventEnabled
        ConfigSystem.SaveConfig()
        if halloweenEventEnabled then
            print("Halloween Event Enabled - Auto Join Halloween 2025")
            executeHalloweenEvent()
        else
            print("Halloween Event Disabled - Auto Join Halloween 2025")
        end
    end
})

-- Hàm click Retry button
local function findAndClickRetry()
    local Players = game:GetService("Players")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local success, result = pcall(function()
        local player = Players.LocalPlayer
        local retryButton = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG"):WaitForChild("Buttons")
            :WaitForChild("Retry")

        if retryButton and retryButton:IsA("GuiButton") then
            local absolutePosition = retryButton.AbsolutePosition
            local absoluteSize = retryButton.AbsoluteSize

            local centerX = absolutePosition.X + (absoluteSize.X / 2)
            local centerY = absolutePosition.Y + (absoluteSize.Y / 2) + 55

            -- Sử dụng task.spawn để không block UI
            task.spawn(function()
                VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            end)

            print("Đã click vào nút Retry tại vị trí:", centerX, centerY)
            return true
        else
            warn("Không tìm thấy nút Retry!")
            return false
        end
    end)

    if not success then
        warn("Lỗi khi click Retry:", result)
        return false
    end

    return result
end

-- Hàm click Next button
local function findAndClickNext()
    local Players = game:GetService("Players")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local success, result = pcall(function()
        local player = Players.LocalPlayer
        local nextButton = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG"):WaitForChild("Buttons")
            :WaitForChild("Next")

        if nextButton and nextButton:IsA("GuiButton") then
            local absolutePosition = nextButton.AbsolutePosition
            local absoluteSize = nextButton.AbsoluteSize

            local centerX = absolutePosition.X + (absoluteSize.X / 2)
            local centerY = absolutePosition.Y + (absoluteSize.Y / 2) + 55

            -- Sử dụng task.spawn để không block UI
            task.spawn(function()
                VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            end)

            print("Đã click vào nút Next tại vị trí:", centerX, centerY)
            return true
        else
            warn("Không tìm thấy nút Next!")
            return false
        end
    end)

    if not success then
        warn("Lỗi khi click Next:", result)
        return false
    end

    return result
end

-- Hàm click Leave button
local function findAndClickLeave()
    local Players = game:GetService("Players")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local success, result = pcall(function()
        local player = Players.LocalPlayer
        local leaveButton = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG"):WaitForChild("Buttons")
            :WaitForChild("Leave")

        if leaveButton and leaveButton:IsA("GuiButton") then
            local absolutePosition = leaveButton.AbsolutePosition
            local absoluteSize = leaveButton.AbsoluteSize

            local centerX = absolutePosition.X + (absoluteSize.X / 2)
            local centerY = absolutePosition.Y + (absoluteSize.Y / 2) + 55

            -- Sử dụng task.spawn để không block UI
            task.spawn(function()
                VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            end)

            print("Đã click vào nút Leave tại vị trí:", centerX, centerY)
            return true
        else
            warn("Không tìm thấy nút Leave!")
            return false
        end
    end)

    if not success then
        warn("Lỗi khi click Leave:", result)
        return false
    end

    return result
end

-- Hàm bắt đầu theo dõi EndGameUI
local function startEndGameUIWatcher()
    if endGameUIConnection then
        endGameUIConnection:Disconnect()
        endGameUIConnection = nil
    end

    if not (autoRetryEnabled or autoNextEnabled or autoLeaveEnabled or webhookEnabled) then return end

    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 5)
    if not playerGui then
        warn("Không tìm thấy PlayerGui")
        return
    end

    endGameUIConnection = playerGui.ChildAdded:Connect(function(child)
        if child.Name == "EndGameUI" then
            -- Dừng record macro tự động nếu đang bật
            if Recorder.isRecording then
                Recorder.isRecording = false
                if Recorder.moneyConn then
                    Recorder.moneyConn:Disconnect()
                    Recorder.moneyConn = nil
                end
                local path = macroPath(selectedMacro)
                local ok, errMsg = pcall(function()
                    writefile(path, Recorder.buffer or "-- empty macro\n")
                end)
                if ok then
                    print("EndGameUI xuất hiện, đã auto lưu macro:", selectedMacro)
                    if Fluent and Fluent.Notify then
                        Fluent:Notify({
                            Title = "Macro Saved",
                            Content = "Đã tự động lưu macro",
                            Duration = 5
                        })
                    end
                else
                    warn("Lỗi auto lưu macro khi EndGameUI xuất hiện:", errMsg)
                end
            end
            print("EndGameUI detected! Waiting 2 seconds...")

            -- Sử dụng task.spawn để không block UI
            task.spawn(function()
                task.wait(2)
                -- Webhook logic FIRST
                if webhookEnabled and webhookURL ~= "" then
                    task.wait(1)
                    print("Webhook: Preparing to send data...")
                    task.spawn(function()
                        local success, result = pcall(function()
                            local player = game:GetService("Players").LocalPlayer
                            local http = game:GetService("HttpService")

                            -- lấy thông tin người chơi
                            local playerName = player.Name
                            local playerLevel = 0

                            -- lấy level người chơi
                            local levelSuccess, levelValue = pcall(function()
                                return player.Level.Value
                            end)
                            if levelSuccess then
                                playerLevel = levelValue
                            else
                                print("Không thể lấy level người chơi, sử dụng 0")
                            end

                            print("Player:", playerName, "Level:", playerLevel)

                            -- lấy rewards
                            local rewards = {}
                            local rewardsText = "No rewards found"

                            -- lấy rewards holder
                            local successRewards, rewardsData = pcall(function()
                                local rewardsHolder = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG")
                                    :WaitForChild("Container"):WaitForChild("Rewards"):WaitForChild("Holder")
                                print("Found rewards holder with", #rewardsHolder:GetChildren(), "children")

                                -- lấy rewards holder children
                                for _, rewardChild in ipairs(rewardsHolder:GetChildren()) do
                                    if rewardChild:IsA("TextButton") or rewardChild:IsA("Frame") then
                                        local amountLabel = rewardChild:FindFirstChild("Amount")
                                        if amountLabel and amountLabel:IsA("TextLabel") then
                                            -- Format reward: + Name: Amount (remove x)
                                            local amount = amountLabel.Text:gsub("x", "") -- Remove x from amount
                                            table.insert(rewards, "+ " .. rewardChild.Name .. ": " .. amount)
                                            print("Found reward:", rewardChild.Name, amount)
                                        end
                                    end
                                end
                            end)

                            if not successRewards then
                                print("Error getting rewards:", rewardsData)
                            end

                            if #rewards > 0 then
                                rewardsText = table.concat(rewards, "\n")
                            end

                            print("Final rewards:", rewardsText)

                            -- Get match results
                            local matchResults = {}
                            local matchResultsText = "No match results found"

                            local successMatch, matchData = pcall(function()
                                local rightFrame = player.PlayerGui:WaitForChild("Right")
                                local frame1 = rightFrame:WaitForChild("Frame")
                                local frame2 = frame1:WaitForChild("Frame")
                                local children = frame2:GetChildren()

                                print("Found", #children, "children in match results container")

                                if #children >= 3 then
                                    local matchContainer = children[3]
                                    print("Match container type:", matchContainer.ClassName)

                                    for _, resultChild in ipairs(matchContainer:GetChildren()) do
                                        if resultChild:IsA("TextLabel") then
                                            table.insert(matchResults, resultChild.Text)
                                            print("Found match result:", resultChild.Text)
                                        end
                                    end
                                end
                            end)

                            if not successMatch then
                                print("Error getting match results:", matchData)
                            end

                            if #matchResults > 0 then
                                matchResultsText = table.concat(matchResults, "\n")
                            end

                            -- Get Time, Wave and Result
                            local elapsedTime = "Unknown"
                            local wave = "Unknown"
                            local result = "Unknown"
                            local resultColor = 0x00FF00 -- Default green

                            local successTime, timeData = pcall(function()
                                local timeLabel = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG")
                                    :WaitForChild("Container"):WaitForChild("Stats"):WaitForChild("ElapsedTime")
                                elapsedTime = timeLabel.Text
                                print("Found elapsed time:", elapsedTime)
                            end)

                            if not successTime then
                                print("Error getting elapsed time:", timeData)
                            end

                            local successWave, waveData = pcall(function()
                                local waveObj = game:GetService("ReplicatedStorage"):WaitForChild("Wave")
                                wave = tostring(waveObj.Value)
                                print("Found wave:", wave)
                            end)

                            if not successWave then
                                print("Error getting wave:", waveData)
                            end

                            local successResult, resultData = pcall(function()
                                local resultLabel = player.PlayerGui:WaitForChild("EndGameUI"):WaitForChild("BG")
                                    :WaitForChild("Container"):WaitForChild("Stats"):WaitForChild("Result")
                                result = resultLabel.Text
                                print("Found result:", result)

                                -- Set color based on result
                                if string.find(result, "Win") then
                                    resultColor = 0x00FF00 -- Green for Win
                                elseif string.find(result, "Defeat") then
                                    resultColor = 0xFF0000 -- Red for Defeat
                                end
                            end)

                            if not successResult then
                                print("Error getting result:", resultData)
                            end

                            print("Final match results:", matchResultsText)
                            print("Time:", elapsedTime, "Wave:", wave, "Result:", result)

                            -- Create webhook payload
                            local payload = http:JSONEncode({
                                username = "Anime Last Stand",
                                avatar_url =
                                "https://www.roblox.com/asset-thumbnail/image?assetId=90319448802378&width=420&height=420&format=png",
                                embeds = {
                                    {
                                        title = "Game Ended!",
                                        description = string.format("**Player:** ||%s||\n**Level:** %d", playerName,
                                            playerLevel),
                                        color = resultColor,
                                        fields = {
                                            {
                                                name = "Rewards",
                                                value = rewardsText,
                                                inline = false
                                            },
                                            {
                                                name = "Match Result",
                                                value = string.format(
                                                    "**Result:** %s\n**Time:** %s\n**Wave:** %s\n\n**Match:**\n%s",
                                                    result, elapsedTime, wave, matchResultsText),
                                                inline = false
                                            }
                                        },
                                        footer = {
                                            text = "HTHubALS",
                                            icon_url =
                                            "https://media.discordapp.net/attachments/1321403790343274597/1364864770699821056/HT_HUB.png?ex=68eca95f&is=68eb57df&hm=3525ecf95f7e92672dbb7136678c29992df2625af44d83477e098a3839e1a10c&=&format=webp&quality=lossless&width=930&height=930"
                                        },
                                        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
                                    }
                                }
                            })

                            print("Payload created, sending webhook...")

                            -- Send webhook using request
                            local webhookSuccess, webhookResponse = pcall(function()
                                return request({
                                    Url = webhookURL,
                                    Method = "POST",
                                    Headers = {
                                        ["Content-Type"] = "application/json"
                                    },
                                    Body = payload
                                })
                            end)

                            if webhookSuccess then
                                print("Webhook sent successfully! Response:", webhookResponse)
                                return true
                            else
                                warn("Failed to send webhook:", webhookResponse)
                                return false
                            end
                        end)

                        if not success then
                            warn("Webhook error:", result)
                        end
                    end)
                else
                    print("Webhook not enabled or URL empty. Enabled:", webhookEnabled, "URL:", webhookURL)
                end

                if autoRetryEnabled then
                    task.wait(3) -- Đợi 5s như yêu cầu
                    print("Auto Retry: Clicking Retry button...")
                    findAndClickRetry()
                end

                if autoNextEnabled then
                    task.wait(5) -- Đợi thêm 5s như trong code gốc
                    print("Auto Next: Clicking Next button...")
                    findAndClickNext()
                end

                if autoLeaveEnabled then
                    task.wait(7) -- Đợi 5s như yêu cầu
                    print("Auto Leave: Clicking Leave button...")
                    findAndClickLeave()
                end
            end)
        end
    end)
end

-- Hàm dừng theo dõi EndGameUI
local function stopEndGameUIWatcher()
    if endGameUIConnection then
        endGameUIConnection:Disconnect()
        endGameUIConnection = nil
    end
end

-- Toggle Auto Retry
AutoPlaySection:AddToggle("AutoRetryToggle", {
    Title = "Auto Retry",
    Description = "",
    Default = autoRetryEnabled,
    Callback = function(enabled)
        autoRetryEnabled = enabled
        ConfigSystem.CurrentConfig.AutoRetryEnabled = autoRetryEnabled
        ConfigSystem.SaveConfig()

        if autoRetryEnabled then
            print("Auto Retry Enabled - Auto click Retry")
        else
            print("Auto Retry Disabled - Disabled auto click Retry")
        end

        startEndGameUIWatcher()
    end
})

-- Toggle Auto Next
AutoPlaySection:AddToggle("AutoNextToggle", {
    Title = "Auto Next",
    Description = "",
    Default = autoNextEnabled,
    Callback = function(enabled)
        autoNextEnabled = enabled
        ConfigSystem.CurrentConfig.AutoNextEnabled = autoNextEnabled
        ConfigSystem.SaveConfig()

        if autoNextEnabled then
            print("Auto Next Enabled - Tự động click Next")
        else
            print("Auto Next Disabled - Đã tắt tự động click Next")
        end

        startEndGameUIWatcher()
    end
})

-- Toggle Auto Leave
AutoPlaySection:AddToggle("AutoLeaveToggle", {
    Title = "Auto Leave",
    Description = "",
    Default = autoLeaveEnabled,
    Callback = function(enabled)
        autoLeaveEnabled = enabled
        ConfigSystem.CurrentConfig.AutoLeaveEnabled = autoLeaveEnabled
        ConfigSystem.SaveConfig()

        if autoLeaveEnabled then
            print("Auto Leave Enabled - Tự động click Leave")
        else
            print("Auto Leave Disabled - Đã tắt tự động click Leave")
        end

        startEndGameUIWatcher()
    end
})

-- Tab Webhook
-- Section Webhook Settings
local WebhookSection = WebhookTab:AddSection("Webhook Settings")

-- Input Webhook URL
WebhookSection:AddInput("WebhookURLInput", {
    Title = "Webhook URL",
    Default = webhookURL,
    Placeholder = "Dán link webhook Discord của bạn",
    Callback = function(val)
        webhookURL = tostring(val or "")
        ConfigSystem.CurrentConfig.WebhookURL = webhookURL
        ConfigSystem.SaveConfig()
        print("Webhook URL set:", webhookURL)
    end
})

-- Toggle Enable Webhook
WebhookSection:AddToggle("EnableWebhookToggle", {
    Title = "Enable Webhook",
    Description = "Send webhook when game ends",
    Default = webhookEnabled,
    Callback = function(enabled)
        webhookEnabled = enabled
        ConfigSystem.CurrentConfig.WebhookEnabled = webhookEnabled
        ConfigSystem.SaveConfig()

        if webhookEnabled then
            print("Webhook Enabled - Will send webhook when game ends")
        else
            print("Webhook Disabled - Disabled webhook")
        end

        startEndGameUIWatcher()
    end
})

-- Test Webhook Button
WebhookSection:AddButton({
    Title = "Test Webhook",
    Description = "Gửi webhook test để kiểm tra",
    Callback = function()
        if webhookURL == "" then
            warn("Webhook URL is empty! Please enter a webhook URL first.")
            return
        end

        print("Testing webhook...")

        task.spawn(function()
            local success, result = pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local http = game:GetService("HttpService")

                -- Get player info
                local playerName = player.Name
                local playerLevel = 0

                -- Try to get level safely
                local levelSuccess, levelValue = pcall(function()
                    return player.Level.Value
                end)
                if levelSuccess then
                    playerLevel = levelValue
                else
                    print("Could not get player level, using 0")
                end

                print("Test - Player:", playerName, "Level:", playerLevel)

                -- Create test webhook payload
                local payload = http:JSONEncode({
                    username = "Anime Last Stand Notifier",
                    avatar_url =
                    "https://www.roblox.com/asset-thumbnail/image?assetId=90319448802378&width=420&height=420&format=png",
                    embeds = {
                        {
                            title = "Test Webhook",
                            description = string.format(
                                "**Player:** %s\n**Level:** %d\n\nThis is a test webhook to verify the connection is working!",
                                playerName, playerLevel),
                            color = 0x00FF00,
                            fields = {
                                {
                                    name = "Status",
                                    value = "Webhook connection successful!",
                                    inline = false
                                },
                                {
                                    name = "Time",
                                    value = os.date("%Y-%m-%d %H:%M:%S"),
                                    inline = false
                                }
                            },
                            footer = {
                                text = "HTHubALS - Test Webhook",
                                icon_url =
                                "https://www.roblox.com/asset-thumbnail/image?assetId=90319448802378&width=420&height=420&format=png"
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
                        }
                    }
                })

                print("Test payload created, sending webhook...")

                -- Send webhook using request
                local webhookSuccess, webhookResponse = pcall(function()
                    return request({
                        Url = webhookURL,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = payload
                    })
                end)

                if webhookSuccess then
                    print("Test webhook sent successfully! Response:", webhookResponse)
                    return true
                else
                    warn("Failed to send test webhook:", webhookResponse)
                    return false
                end
            end)

            if not success then
                warn("Test webhook error:", result)
            end
        end)
    end
})

-- Khởi tạo EndGameUI watcher nếu đã được bật
if autoRetryEnabled or autoNextEnabled or autoLeaveEnabled or webhookEnabled then
    startEndGameUIWatcher()
end

-- Macro helpers
local MacroSystem = {}
MacroSystem.BaseFolder = "HTHubALS_Macros"

local function ensureMacroFolder()
    pcall(function()
        if not isfolder(MacroSystem.BaseFolder) then
            makefolder(MacroSystem.BaseFolder)
        end
    end)
end

ensureMacroFolder()

local function listMacros()
    local names = {}
    local ok, files = pcall(function()
        return listfiles(MacroSystem.BaseFolder)
    end)
    if ok and files then
        for _, p in ipairs(files) do
            local name = string.match(p, "[^/\\]+$")
            if name then table.insert(names, name) end
        end
    end
    table.sort(names)
    return names
end

local function macroPath(name)
    return MacroSystem.BaseFolder .. "/" .. name
end

local selectedMacro = ConfigSystem.CurrentConfig.SelectedMacro or ""
local pendingMacroName = ""

-- Macro UI
local macroStatusParagraph
local function updateMacroStatus(content)
    if macroStatusParagraph and macroStatusParagraph.SetDesc then
        pcall(function()
            macroStatusParagraph:SetDesc(content)
        end)
    end
end

macroStatusParagraph = MacroTab:AddParagraph({
    Title = "Status",
    Content = "Idle"
})

local MacroSection = MacroTab:AddSection("Macro Recorder")

-- Dropdown select macro
local MacroDropdown = MacroSection:AddDropdown("MacroSelect", {
    Title = "Select Macro",
    Description = "Select macro",
    Values = listMacros(),
    Default = selectedMacro ~= "" and selectedMacro or nil,
    Callback = function(val)
        selectedMacro = val
        ConfigSystem.CurrentConfig.SelectedMacro = val
        ConfigSystem.SaveConfig()
    end
})

-- Input macro name
MacroSection:AddInput("MacroNameInput", {
    Title = "Macro name",
    Default = "",
    Placeholder = "vd: my_macro.txt",
    Callback = function(val)
        pendingMacroName = tostring(val or "")
    end
})

-- Create macro button
MacroSection:AddButton({
    Title = "Create Macro",
    Description = "Create macro .txt",
    Callback = function()
        local name = pendingMacroName ~= "" and pendingMacroName or ("macro_" .. os.time() .. ".txt")
        if not string.find(name, "%.") then name = name .. ".txt" end
        local path = macroPath(name)
        local ok, errMsg = pcall(function()
            ensureMacroFolder()
            if not isfile(path) then
                writefile(path, "-- New macro file\n")
            end
        end)
        if ok then
            selectedMacro = name
            ConfigSystem.CurrentConfig.SelectedMacro = name
            ConfigSystem.SaveConfig()
            -- refresh dropdown
            pcall(function()
                MacroDropdown:SetValues(listMacros())
                MacroDropdown:SetValue(selectedMacro)
            end)
            print("Created macro:", name)
        else
            warn("Create macro failed:", errMsg)
        end
    end
})

-- Delete macro button
MacroSection:AddButton({
    Title = "Delete Macro",
    Description = "Delete selected macro",
    Callback = function()
        if not selectedMacro or selectedMacro == "" then return end
        local path = macroPath(selectedMacro)
        local ok, errMsg = pcall(function()
            if isfile(path) then delfile(path) end
        end)
        if ok then
            print("Deleted macro:", selectedMacro)
            selectedMacro = ""
            ConfigSystem.CurrentConfig.SelectedMacro = ""
            ConfigSystem.SaveConfig()
            pcall(function()
                MacroDropdown:SetValues(listMacros())
                MacroDropdown:SetValue(nil)
            end)
        else
            warn("Delete macro failed:", errMsg)
        end
    end
})

-- Recorder state
local Recorder = {
    isRecording = false,
    stt = 0,                 -- Sequence number
    hasStarted = false,
    pendingAction = nil,     -- Store only the latest action
    lastMoney = nil,
    lastMoneyRecordTime = 0, -- Debounce timer
    moneyConn = nil,
    buffer = nil,
}

local function appendLine(line)
    if Recorder.buffer then
        Recorder.buffer = Recorder.buffer .. line .. "\n"
    end
end

-- Helpers for serialization and recording
local function vecToStr(v)
    if typeof and typeof(v) == "Vector3" then
        return string.format("Vector3.new(%f, %f, %f)", v.X, v.Y, v.Z)
    end
    return tostring(v)
end

local function cframeToStr(cf)
    if typeof and typeof(cf) == "CFrame" then
        local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
        local r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        return string.format("CFrame.new(%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)",
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    end
    return tostring(cf)
end

local function isArray(tbl)
    local n = 0
    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
            return false
        end
        if k > n then n = k end
    end
    for i = 1, n do
        if tbl[i] == nil then return false end
    end
    return true, n
end

local function serialize(val, indent)
    indent = indent or 0
    local pad = string.rep(" ", indent)
    if type(val) == "table" then
        local arr, n = isArray(val)
        local parts = { "{" }
        if arr then
            for i = 1, n do
                local v = val[i]
                local valueStr
                if typeof and typeof(v) == "Vector3" then
                    valueStr = vecToStr(v)
                elseif typeof and typeof(v) == "CFrame" then
                    valueStr = cframeToStr(v)
                elseif typeof and typeof(v) == "Instance" then
                    -- Special handling for Instance objects (like Tower references)
                    if v.Parent and v.Name then
                        valueStr = string.format("workspace:WaitForChild(\"Towers\"):WaitForChild(\"%s\")", v.Name)
                    else
                        valueStr = tostring(v)
                    end
                elseif type(v) == "table" then
                    valueStr = serialize(v, indent + 4)
                elseif type(v) == "string" then
                    valueStr = string.format("\"%s\"", v)
                else
                    valueStr = tostring(v)
                end
                table.insert(parts, string.format("\n%s    %s,", pad, valueStr))
            end
        else
            for k, v in pairs(val) do
                local key = tostring(k)
                local valueStr
                if typeof and typeof(v) == "Vector3" then
                    valueStr = vecToStr(v)
                elseif typeof and typeof(v) == "CFrame" then
                    valueStr = cframeToStr(v)
                elseif typeof and typeof(v) == "Instance" then
                    -- Special handling for Instance objects (like Tower references)
                    if v.Parent and v.Name then
                        valueStr = string.format("workspace:WaitForChild(\"Towers\"):WaitForChild(\"%s\")", v.Name)
                    else
                        valueStr = tostring(v)
                    end
                elseif type(v) == "table" then
                    valueStr = serialize(v, indent + 4)
                elseif type(v) == "string" then
                    valueStr = string.format("\"%s\"", v)
                else
                    valueStr = tostring(v)
                end
                table.insert(parts, string.format("\n%s    %s = %s,", pad, key, valueStr))
            end
        end
        table.insert(parts, string.format("\n%s}", pad))
        return table.concat(parts)
    elseif type(val) == "string" then
        return string.format("\"%s\"", val)
    else
        return tostring(val)
    end
end

local function recordNow(remoteName, args, noteMoney)
    if not Recorder.isRecording or not Recorder.hasStarted then return end

    Recorder.stt = Recorder.stt + 1

    -- Cập nhật trạng thái (STT / Type / Money)
    local statusContent = string.format("-STT: %d\n-Type: %s\n-Money: %d", Recorder.stt, tostring(remoteName),
        tonumber(noteMoney) or 0)
    updateMacroStatus(statusContent)

    appendLine(string.format("--STT: %d", Recorder.stt))

    if noteMoney and noteMoney > 0 then
        appendLine(string.format("--note money: %d", noteMoney))
    end
    local okSer, argsStr = pcall(function()
        return serialize(args)
    end)
    appendLine("--call: " .. remoteName)
    if okSer and argsStr then
        appendLine("local args = " .. argsStr)
    else
        appendLine("-- serialize error: " .. tostring(argsStr))
        appendLine("local args = {}")
    end

    -- Sử dụng FireServer cho PlaceTower và PlayerReady, InvokeServer cho Upgrade
    if remoteName == "PlaceTower" or remoteName == "PlayerReady" then
        appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"Remotes\"):WaitForChild(\"" ..
            remoteName .. "\"):FireServer(unpack(args))")
    else
        appendLine("game:GetService(\"ReplicatedStorage\"):WaitForChild(\"Remotes\"):WaitForChild(\"" ..
            remoteName .. "\"):InvokeServer(unpack(args))")
    end
end

-- Install namecall hook (once)
local hookInstalled = false
local oldNamecall
local function installHookOnce()
    if hookInstalled then return end
    hookInstalled = true
    local ok, res = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            if Recorder.isRecording and (tostring(method) == "FireServer" or tostring(method) == "InvokeServer") then
                local args = { ... }
                -- Only record whitelisted endpoints
                local remoteName = tostring(self and self.Name or "")
                local allowed = {
                    PlaceTower = true,
                    Upgrade = true,
                    PlayerReady = true,
                }
                if not allowed[remoteName] then
                    return oldNamecall(self, ...)
                end
                if not Recorder.hasStarted then
                    return oldNamecall(self, ...)
                end

                -- Money-gated recording: overwrite pending action, immediate for PlayerReady
                if remoteName == "PlaceTower" or remoteName == "Upgrade" then
                    Recorder.pendingAction = { remote = remoteName, args = args }
                else
                    recordNow(remoteName, args)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not ok then
        warn("Failed to install hook:", res)
    end
end

-- Toggle record macro
MacroSection:AddToggle("RecordMacroToggle", {
    Title = "Record Macro",
    Description = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            installHookOnce()
            if not selectedMacro or selectedMacro == "" then
                -- auto name
                selectedMacro = "macro_" .. os.time() .. ".txt"
                ConfigSystem.CurrentConfig.SelectedMacro = selectedMacro
                ConfigSystem.SaveConfig()
            end

            Recorder.isRecording = true
            Recorder.hasStarted = false
            Recorder.pendingAction = nil
            Recorder.buffer = "-- Macro recorded by HT Hub\n"
            print("Recording started ->", selectedMacro)

            -- Start recording immediately
            Recorder.hasStarted = true
            Recorder.stt = 0
            updateMacroStatus("Recording...")
            print("Recording started ->", selectedMacro)

            -- money watcher
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local cash = player:WaitForChild("Cash", 5)
                if not cash then
                    warn("Could not find Cash value")
                    return
                end

                Recorder.lastMoney = tonumber(cash.Value)
                if Recorder.moneyConn then
                    Recorder.moneyConn:Disconnect()
                    Recorder.moneyConn = nil
                end
                Recorder.moneyConn = cash.Changed:Connect(function(newVal)
                    local current = tonumber(newVal)
                    if Recorder.isRecording and Recorder.hasStarted and type(current) == "number" and type(Recorder.lastMoney) == "number" then
                        if current < Recorder.lastMoney then
                            local now = tick()
                            if now - Recorder.lastMoneyRecordTime > 0.1 then
                                Recorder.lastMoneyRecordTime = now
                                local delta = Recorder.lastMoney - current
                                local action = Recorder.pendingAction
                                Recorder.pendingAction = nil
                                if action then
                                    recordNow(action.remote, action.args, delta)
                                end
                            end
                        end
                        Recorder.lastMoney = current
                    end
                end)
            end)
        else
            if Recorder.isRecording then
                Recorder.isRecording = false
                if Recorder.moneyConn then
                    Recorder.moneyConn:Disconnect()
                    Recorder.moneyConn = nil
                end
                local path = macroPath(selectedMacro)
                local ok, errMsg = pcall(function()
                    writefile(path, Recorder.buffer or "-- empty macro\n")
                end)
                if ok then
                    print("Recording saved:", selectedMacro)
                    pcall(function()
                        MacroDropdown:SetValues(listMacros())
                        MacroDropdown:SetValue(selectedMacro)
                    end)
                else
                    warn("Save macro failed:", errMsg)
                end
            end
        end
    end
})

-- Play macro
local macroPlaying = false

-- Hàm mới để phân tích nội dung macro thành các lệnh có thể thực thi
local function parseMacro(content)
    local commands = {}
    -- Tách các khối lệnh bằng --STT:
    local blocks = {}
    local lastPos = 1
    for pos, stt in content:gmatch("()--STT:%s*(%d+)") do
        if #blocks > 0 then
            blocks[#blocks].text = content:sub(lastPos, pos - 1)
        end
        table.insert(blocks, { stt = tonumber(stt) })
        lastPos = pos
    end
    if #blocks > 0 then
        blocks[#blocks].text = content:sub(lastPos)
    end

    for _, block in ipairs(blocks) do
        if block.text then
            local moneyMatch = block.text:match("--note money:%s*(%d+)")
            local money = moneyMatch and tonumber(moneyMatch) or 0

            local code = ""
            for line in block.text:gmatch("[^\r\n]+") do
                -- Chỉ bao gồm các dòng code có thể thực thi, loại bỏ các comment và task.wait
                if not line:match("^%s*--STT") and not line:match("^%s*--note money") and not line:match("^%s*task%.wait") then
                    code = code .. line .. "\n"
                end
            end

            if code ~= "" then
                table.insert(commands, {
                    stt = block.stt,
                    money = money,
                    code = code
                })
            end
        end
    end

    return commands
end

-- Hàm mới để thực thi các lệnh đã phân tích
local function executeMacro(commands)
    local player = game:GetService("Players").LocalPlayer
    local cash = player:WaitForChild("Cash", 5)

    if not cash then
        warn("Không thể tìm thấy tiền của người chơi (Cash). Dừng macro.")
        updateMacroStatus("Lỗi: Không tìm thấy tiền người chơi.")
        return
    end

    for i, command in ipairs(commands) do
        if not _G.__HT_MACRO_PLAYING then break end

        -- Cập nhật trạng thái cho hành động tiếp theo
        -- Hiển thị STT hiện tại / tổng
        local total = #commands
        updateMacroStatus(string.format("-STT: %d/%d", i, total))

        local nextCommand = commands[i]
        if nextCommand then
            local nextType = "N/A"
            local callMatch = nextCommand.code:match("--call:%s*([%w_]+)")
            if callMatch then
                nextType = callMatch
            end
            updateMacroStatus(string.format("-STT: %d/%d\n-Next Type: %s\n-Next Money: %d", i, total, nextType,
                nextCommand.money))
        end

        -- Đợi đủ tiền cho các lệnh có yêu cầu tiền
        if command.money > 0 then
            -- Cập nhật print để hiển thị cả tiền hiện có
            local currentMoney = cash.Value
            print(string.format("Đang đợi đủ tiền cho STT %d: Cần %d, Hiện có %.0f", command.stt, command.money,
                currentMoney))

            while _G.__HT_MACRO_PLAYING and cash.Value < command.money do
                task.wait(0.2)
            end
        end

        if not _G.__HT_MACRO_PLAYING then break end

        print(string.format("Thực thi STT %d (Yêu cầu tiền: %d)", command.stt, command.money))

        local loadOk, fnOrErr = pcall(function() return loadstring(command.code) end)
        if loadOk and type(fnOrErr) == "function" then
            local runOk, runErr = pcall(fnOrErr)
            if not runOk then
                warn(string.format("Lỗi khi chạy STT %d: %s", command.stt, tostring(runErr)))
            end
        else
            warn(string.format("Lỗi khi tải code cho STT %d: %s", command.stt, tostring(fnOrErr)))
        end

        -- Đợi 2 giây giữa các STT để đọc chậm
        print(string.format("Đợi 2 giây trước khi thực thi STT tiếp theo..."))
        task.wait(2)
    end
    -- Hoàn tất macro
    updateMacroStatus("Macro Completed")
end

MacroSection:AddToggle("PlayMacroToggle", {
    Title = "Play Macro",
    Description = "",
    Default = ConfigSystem.CurrentConfig.PlayMacroEnabled or false,
    Callback = function(isOn)
        -- Lưu trạng thái play macro
        ConfigSystem.CurrentConfig.PlayMacroEnabled = isOn
        ConfigSystem.SaveConfig()

        if isOn then
            if not selectedMacro or selectedMacro == "" then
                warn("No macro selected")
                return
            end
            local path = macroPath(selectedMacro)
            local ok, content = pcall(function()
                if isfile(path) then return readfile(path) end
                return nil
            end)
            if not (ok and content) then
                warn("Failed to read macro file")
                return
            end

            -- Phân tích macro một lần
            local commands = parseMacro(content)
            if #commands == 0 then
                warn("Macro rỗng hoặc không hợp lệ. Không có lệnh nào để thực thi.")
                return
            end

            _G.__HT_MACRO_PLAYING = true
            macroPlaying = true

            task.spawn(function()
                while _G.__HT_MACRO_PLAYING do
                    -- Gửi PlayerReady và đợi 3 giây
                    updateMacroStatus("Gửi PlayerReady...")
                    print("Gửi PlayerReady...")

                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayerReady")
                            :FireServer()
                    end)
                    if not success then
                        warn("Could not send PlayerReady:", err)
                        updateMacroStatus("Lỗi: Không thể gửi PlayerReady")
                        _G.__HT_MACRO_PLAYING = false
                        macroPlaying = false
                        return
                    end

                    updateMacroStatus("Đợi 3 giây...")
                    print("PlayerReady sent! Đợi 3 giây...")
                    task.wait(3)

                    -- Chạy macro sau khi đợi
                    updateMacroStatus("Đang chạy macro...")
                    print("Bắt đầu chạy macro...")

                    executeMacro(commands) -- Gọi hàm thực thi mới

                    if not _G.__HT_MACRO_PLAYING then break end

                    updateMacroStatus("Chờ game tiếp theo...")
                    print("Macro đã hoàn thành. Đang chờ game tiếp theo...")

                    -- Đợi Wave về 1 để lặp lại
                    local wave = game:GetService("ReplicatedStorage"):WaitForChild("Wave", 5)
                    if not wave then
                        warn("Không tìm thấy Wave. Tự động lặp lại sẽ không hoạt động.")
                        updateMacroStatus("Lỗi: Không tìm thấy Wave")
                        break -- Thoát khỏi vòng lặp
                    end

                    while _G.__HT_MACRO_PLAYING and wave.Value ~= 1 do
                        task.wait(1)
                    end

                    if _G.__HT_MACRO_PLAYING then
                        print("Wave = 1. Lặp lại macro.")
                        task.wait(2) -- Chờ một chút trước khi lặp lại
                    end
                end

                macroPlaying = false
                _G.__HT_MACRO_PLAYING = false
                updateMacroStatus("Idle")
                print("Vòng lặp macro đã dừng.")
            end)
        else
            -- Tắt
            _G.__HT_MACRO_PLAYING = false
            macroPlaying = false
            updateMacroStatus("Idle")
            print("Macro đã dừng")
        end
    end
})

-- Hàm bắt đầu theo dõi wave
local function startSellAllWatcher()
    if waveConnection then
        waveConnection:Disconnect()
        waveConnection = nil
    end

    if not sellAllEnabled then return end

    local wave = game:GetService("ReplicatedStorage"):WaitForChild("Wave", 5)
    if not wave then
        warn("Không tìm thấy Wave object")
        return
    end

    waveConnection = wave.Changed:Connect(function(newVal)
        if sellAllEnabled and tonumber(newVal) == sellAllWave then
            print("Wave", sellAllWave, "reached! Selling all units...")

            local success, err = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnitManager"):WaitForChild(
                    "SellAll"):FireServer()
            end)

            if success then
                print("Sell All executed successfully!")
            else
                warn("Sell All failed:", err)
            end
        end
    end)
end

-- Hàm dừng theo dõi wave
local function stopSellAllWatcher()
    if waveConnection then
        waveConnection:Disconnect()
        waveConnection = nil
    end
end

-- Khởi tạo Sell All watcher nếu đã được bật
if sellAllEnabled then
    startSellAllWatcher()
end

-- Input Wave
SellAllSection:AddInput("SellAllWaveInput", {
    Title = "Sell At Wave",
    Default = tostring(sellAllWave),
    Placeholder = "Nhập wave để sell all (1-999)",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 1 and num <= 999 then
            sellAllWave = num
            ConfigSystem.CurrentConfig.SellAllWave = sellAllWave
            ConfigSystem.SaveConfig()
            print("Sell All Wave set to:", sellAllWave)
        else
            warn("Wave must be between 1-999")
        end
    end
})

-- Toggle Sell All
SellAllSection:AddToggle("SellAllToggle", {
    Title = "Auto Sell All Units",
    Description = "Tự động sell all units khi đạt wave chỉ định",
    Default = sellAllEnabled,
    Callback = function(enabled)
        sellAllEnabled = enabled
        ConfigSystem.CurrentConfig.SellAllEnabled = sellAllEnabled
        ConfigSystem.SaveConfig()

        if sellAllEnabled then
            print("Sell All Enabled - Tự động sell all units tại wave", sellAllWave)
            startSellAllWatcher()
        else
            print("Sell All Disabled - Đã tắt tự động sell all units")
            stopSellAllWatcher()
        end
    end
})

-- Add Anti AFK toggle in Settings tab
SettingsSection:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Description = "Bật/tắt chống AFK tự động",
    Default = antiAFKEnabled,
    Callback = function(enabled)
        antiAFKEnabled = enabled
        ConfigSystem.CurrentConfig.AntiAFKEnabled = antiAFKEnabled
        ConfigSystem.SaveConfig()
        if antiAFKEnabled then
            print("Anti AFK Enabled!")
            startAntiAFK()
        else
            print("Anti AFK Disabled!")
            stopAntiAFK()
        end
    end
})

-- Khởi động Anti AFK nếu được bật ở config
if antiAFKEnabled then
    startAntiAFK()
end

-- Thêm Toggle Auto Hide UI vào Settings tab
SettingsSection:AddToggle("AutoHideUIToggle", {
    Title = "Auto Hide UI",
    Description = "Tự động ẩn UI sau 3 giây khi bật",
    Default = autoHideUIEnabled,
    Callback = function(enabled)
        autoHideUIEnabled = enabled
        ConfigSystem.CurrentConfig.AutoHideUIEnabled = autoHideUIEnabled
        ConfigSystem.SaveConfig()
        if autoHideUIEnabled then
            autoHideUI()
        else
            print("Auto Hide UI đã tắt")
        end
    end
})

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
InterfaceManager:SetFolder("HTHubALS")
SaveManager:SetFolder("HTHubALS/" .. playerName)

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
    for _, tab in pairs({ JoinerTab, MacroTab, InGameTab, WebhookTab, SettingsTab }) do
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
            ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
            ImageButton.Size = UDim2.new(0, 50, 0, 50)
            ImageButton.Image = "rbxassetid://90319448802378" -- Logo HT Hub
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2

            UICorner.CornerRadius = UDim.new(0, 200)
            UICorner.Parent = ImageButton

            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            end)
        end
    end)

    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

print("HT Hub Anime Last Stand Script đã tải thành công!")
print("Sử dụng Left Ctrl để thu nhỏ/mở rộng UI")
