--== ROBLOX: Action Logger Script ==--
-- Tên file log, có thể đổi thành tên khác nếu thích
local logFile = "ActionLog.txt"

-- Hàm Convert Instance thành chuỗi truy xuất code Roblox
local function instanceToCodePath(obj)
    if typeof(obj) ~= "Instance" then return tostring(obj) end
    local path = {}
    local current = obj
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    if #path == 0 then return "game" end
    -- Dịch node đầu tiên là Service
    local code = "game"
    if #path >= 1 then
        -- Chỉ các Service phổ biến mới chuyển sang GetService
        local serviceName = path[1]
        local serviceList = {
            ReplicatedStorage=true, Workspace=true, Players=true, Lighting=true, StarterGui=true, ServerScriptService=true,
            ServerStorage=true, ReplicatedFirst=true, Teams=true, SoundService=true, Chat=true, TweenService=true
        }
        if serviceList[serviceName] then
            code = code .. string.format(':GetService("%s")', serviceName)
        else
            code = code .. string.format(':WaitForChild("%s")', serviceName)
        end
        for i = 2, #path do
            code = code .. string.format(':WaitForChild("%s")', path[i])
        end
    end
    return code
end

-- Hàm ghi dữ liệu vào file, thêm vào cuối file
local function appendToFile(text)
    local old = ""
    if isfile(logFile) then
        old = readfile(logFile)
    end
    writefile(logFile, old .. text .. "\n")
end

-- Hook __namecall để bắt mọi FireServer, InvokeServer gửi tới server
local hookInstalled = false

if not hookInstalled then
    hookInstalled = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        -- Chỉ log các remote cụ thể, hoặc tất cả (ở đây sẽ log hết)
        if typeof(self) == "Instance" and (method == "FireServer" or method == "InvokeServer") then
            -- Tạo log
            local vals = {...}
            local logTable = {
                time = os.date("%Y-%m-%d %H:%M:%S"),
                remote = instanceToCodePath(self),
                method = method,
                args = vals
            }
            -- Serialize nhanh args (dễ đọc)
            local function serializeArgs(t)
                local str = {}
                for i,v in ipairs(t) do
                    table.insert(str, tostring(v))
                end
                return table.concat(str, ", ")
            end
            local line = string.format("[%s] %s:%s(%s)",
                logTable.time,
                logTable.remote,
                logTable.method,
                serializeArgs(logTable.args)
            )
            -- Ghi hàng mới vào file
            appendToFile(line)
        end
        return oldNamecall(self, ...)
    end)
    print("[ACTION LOGGER] Đang ghi lại mọi action vào file:", logFile)
end
