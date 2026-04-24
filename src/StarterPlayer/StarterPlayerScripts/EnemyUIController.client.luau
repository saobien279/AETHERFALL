--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CombatEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatEvents")

-- Cấu hình hiệu ứng tụt máu (0.5 giây, gia tốc mượt)
local tweenInfo = TweenInfo.new(
    0.5, 
    Enum.EasingStyle.Quad, 
    Enum.EasingDirection.Out
)

CombatEvents.OnClientEvent:Connect(function(actionType: string, entityName: string, currentHP: number, maxHP: number)
    -- Lọc sự kiện (Vì CombatEvents dùng chung cho rất nhiều việc)
    if actionType ~= "UpdateHP" then return end

    -- 1. TÌM MỤC TIÊU: Quét trong Workspace xem có Model nào trùng tên không
    local targetModel = Workspace:FindFirstChild(entityName)
    if not targetModel then return end -- Nếu là Người chơi (nằm trong thư mục Player) thì bỏ qua

    -- 2. TÌM ỐNG MÁU: Trỏ vào cấu trúc theo đúng thiết kế của bạn
    local heathBar = targetModel:FindFirstChild("HeathBar")
    if not heathBar then return end

    local bgBar = heathBar:FindFirstChild("BackGroundBar")
    if not bgBar then return end
    
    local fillBar = bgBar:FindFirstChild("Bar")
    if not fillBar then return end

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
