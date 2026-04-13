--strict
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VFX = ReplicatedStorage:WaitForChild("VFX")
local dmgtext = VFX:WaitForChild("DamageText")
local HitVFX = Workspace:WaitForChild("Slime"):WaitForChild("HIVVFX") :: ParticleEmitter

local Monster = {}
Monster.__index = Monster
-- 1. CONSTRUCTOR (Hàm khởi tạo)
-- Trong C#: public Monster(string name, int maxHp)
function Monster.new(name : string, maxHp : number,model: Part)

    local self = setmetatable({},Monster)

    --Khai Bao Cac Thuoc Tinh
    self.Name = name
    self.MaxHp = maxHp
    self.CurrentHp = maxHp
    self.Model = model -- Lưu trữ cục gạch (Part) vào trong Object
    
    return self
end

function Monster:TakeDamage(amount: number)
    self.CurrentHp = self.CurrentHp - amount

    local clonedmgtext = dmgtext:Clone()
    local label = clonedmgtext:WaitForChild("Label") :: TextLabel
    clonedmgtext.Parent = self.Model
    label.Text = "-" .. amount

    local randomOffsetX = math.random(-20, 20) / 10 
    local randomOffsetZ = math.random(-20, 20) / 10

    clonedmgtext.StudsOffset = Vector3.new(randomOffsetX, 2, randomOffsetZ)
    
    local vfxTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    local moveUpGoal = { StudsOffset = Vector3.new(randomOffsetX, 5, randomOffsetZ) }

    TweenService:Create(clonedmgtext, vfxTweenInfo, moveUpGoal):Play()

    local fadeOutGoal = {TextTransparency = 1 , TextStrokeTransparency = 1}
    TweenService:Create(label, vfxTweenInfo, fadeOutGoal):Play()

    local Debris = game:GetService("Debris")
    Debris:AddItem(clonedmgtext, 1)

    if self.CurrentHp <= 0 then
        self.CurrentHp = 0  
        print("💀 Hệ thống: " .. self.Name .. " đã bị tiêu diệt!")
    else
        print("⚔️ Hệ thống: " .. self.Name .. " mất " .. amount .. " HP. Còn lại: " .. self.CurrentHp .. "/" .. self.MaxHp)
    end

    HitVFX:Emit(10)
    -- DATA BINDING: Tính toán phần trăm máu còn lại (từ 0 đến 1)
    local fillPercentage = self.CurrentHp / self.MaxHp

    local ui = self.Model:WaitForChild("HealthUI") :: BillboardGui
    local bg = ui:WaitForChild("Bg") :: Frame
    local fill = bg:WaitForChild("Fill") :: Frame
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local goal = { Size = UDim2.new(fillPercentage, 0, 1, 0) }
    local tween = TweenService:Create(fill, tweenInfo, goal)
    tween:Play()
end

return Monster