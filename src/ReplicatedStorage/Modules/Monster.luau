--strict
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

    if self.CurrentHp <= 0 then
        self.CurrentHp = 0  
        print("💀 Hệ thống: " .. self.Name .. " đã bị tiêu diệt!")
    else
        print("⚔️ Hệ thống: " .. self.Name .. " mất " .. amount .. " HP. Còn lại: " .. self.CurrentHp .. "/" .. self.MaxHp)
    end

    -- DATA BINDING: Tính toán phần trăm máu còn lại (từ 0 đến 1)
    local fillPercentage = self.CurrentHp / self.MaxHp

    local ui = self.Model:WaitForChild("HealthUI") :: BillboardGui
    local bg = ui:WaitForChild("Bg") :: Frame
    local fill = bg:WaitForChild("Fill") :: Frame
    
    fill.Size = UDim2.new(fillPercentage, 0, 1, 0)
end

return Monster