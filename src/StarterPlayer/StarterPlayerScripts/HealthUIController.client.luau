local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatEvents")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
-- Ép nó chờ cho bằng được thư mục Heath và các Frame ở bên trong (do bạn xây ở màn hình Studio)
local heathMenu = playerGui:WaitForChild("Heath")
local frame = heathMenu:WaitForChild("Frame")
local fillBar = frame:WaitForChild("FillBar")


local tweenInfo = TweenInfo.new(
    0.5, 
    Enum.EasingStyle.Quad, 
    Enum.EasingDirection.Out
)

-- Tạo một cái hàm tiện ích để cập nhật Máu mượt mà
CombatEvents.OnClientEvent:Connect(function(actionType: string, entityName: string, currentHP: number, maxHP: number)
    -- Lọc sự kiện (Vì CombatEvents dùng chung cho rất nhiều việc)
    if actionType ~= "UpdateHP" then return end

    if entityName ~= localPlayer.Name then return end
    -- 3. TÍNH TOÁN: Quy ra tỷ lệ phần trăm (Ví dụ 50/100 = 0.5)
    local hpPercent = currentHP / maxHP

    -- 4. HIỆU ỨNG (TWEEN):
    -- Chỉ bóp chiều ngang (Scale X) theo hpPercent. Chiều dọc (Scale Y) luôn là 1.
    local goal = {
        Size = UDim2.new(hpPercent, 0, 1, 0)
    }

    local tween = TweenService:Create(fillBar, tweenInfo, goal)
    tween:Play()
end)
-- Tương lai chúng ta sẽ lắng nghe sự kiện Máu Tụt từ máy chủ ở đây và nhét vào cái hàm trên
-- Demo chạy thử để bạn coi lúc load game nó mượt thế nào:
