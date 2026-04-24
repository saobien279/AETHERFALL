local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatEvents")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Hàm này sẽ tự động chế tạo 1 màn hình đen (khỏi mất công bạn tạo bằng tay trên Studio)
local function CreateBlackScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CinematicScreen"
    screenGui.IgnoreGuiInset = true -- Tràn viền lấp luôn cả thanh máu Roblox mặc định
    screenGui.DisplayOrder = 999 -- Đè lên vạn vật
    
    local blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Màu đen
    blackFrame.BackgroundTransparency = 1 -- Ban đầu tàng hình
    blackFrame.BorderSizePixel = 0
    blackFrame.Parent = screenGui
    
    screenGui.Parent = playerGui
    
    return blackFrame, screenGui
end

-- Cấu hình hiệu ứng Fade Mượt
local fadeInfo = TweenInfo.new(
    0.5, -- Mất 0.5 giây để kéo màn hình đen
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.InOut
)

CombatEvents.OnClientEvent:Connect(function(actionType: string)
    if actionType ~= "FadeToBlack" then return end
    
    -- 1. Tạo màn hình đen
    local blackFrame, screenGui = CreateBlackScreen()
    
    -- 2. Kéo rèm xuống (Từ trong suốt -> Đen đặc)
    local tweenIn = TweenService:Create(blackFrame, fadeInfo, {BackgroundTransparency = 0})
    tweenIn:Play()
    
    -- Đợi 0.5s cho rèm kéo xong
    tweenIn.Completed:Wait() 
    
    -- 3. Đứng im trong bóng tối 0.5s (Lúc này ở Server, Battle đang khởi tạo)
    task.wait(0.5)
    
    -- 4. Kéo rèm lên (Từ Đen đặc -> Trong suốt) để thấy giao diện Battle
    local tweenOut = TweenService:Create(blackFrame, fadeInfo, {BackgroundTransparency = 1})
    tweenOut:Play()
    
    -- Đợi rèm kéo lên xong thì vứt luôn cái Gui này vô thùng rác cho nhẹ máy
    tweenOut.Completed:Wait()
    screenGui:Destroy()
end)
