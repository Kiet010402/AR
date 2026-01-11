local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local DropsFolder = workspace
    :WaitForChild("Ignore")
    :WaitForChild("Drops")

local delayTime = 2 -- giây giữa mỗi lần teleport


local function teleportTo(obj)
    if obj and obj:IsA("BasePart") then
        hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
    elseif obj:IsA("Model") and obj.PrimaryPart then
        hrp.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
    end
end

while true do
    for _, drop in ipairs(DropsFolder:GetChildren()) do
        if drop.Name == "Present" or drop.Name == "DropZone" then
            print("TP to:", drop.Name)

            pcall(function()
                teleportTo(drop)
            end)

            task.wait(delayTime)
        end
    end

    task.wait(1)
end
