local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Ép nó chờ cho bằng được thư mục Heath và các Frame ở bên trong (do bạn xây ở màn hình Studio)
local heathMenu = playerGui:WaitForChild("Heath")
local frame = heathMenu:WaitForChild("Frame")
local fillBar = frame:WaitForChild("FillBar")

-- Tạo một cái hàm tiện ích để cập nhật Máu mượt mà
local function UpdateHealthBar(currentHP, maxHP)
    local ratio = math.clamp(currentHP / maxHP, 0, 1)
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = { Size = UDim2.new(ratio, 0, 1, 0) } 
    
    local tween = TweenService:Create(fillBar, tweenInfo, goal)
    tween:Play()
end

-- Tương lai chúng ta sẽ lắng nghe sự kiện Máu Tụt từ máy chủ ở đây và nhét vào cái hàm trên
-- Demo chạy thử để bạn coi lúc load game nó mượt thế nào:
task.wait(2)
UpdateHealthBar(20, 100)
