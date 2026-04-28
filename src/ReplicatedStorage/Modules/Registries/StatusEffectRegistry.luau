--!strict
--[[
    STATUS EFFECT REGISTRY
    Chứa tất cả các hiệu ứng trạng thái trong game.
    Sử dụng kiến trúc Event-Driven (Hook) để linh hoạt xử lý mọi loại hiệu ứng.
    
    CÁC HOOK HỖ TRỢ (2 Giao diện chuẩn):
    - Modifier Hook (Sửa số, trả về number):  function(target, value, effectData, context)
      Danh sách: BeforeHeal, BeforeTakeDamage, BeforeDealDamage
    - Action Hook (Thi hành, trả về Action Table hoặc nil):  function(target, effectData, context)
      Danh sách: OnApply, OnRemove, OnTurnStart, OnTurnEnd, AfterTakeDamage, AfterDealDamage
    
    LƯU Ý VỀ CODE DESIGN (Chống Circular Dependency):
    Tuyệt đối KHÔNG require() CombatManager ở trong file này để tránh lỗi module gọi chéo nhau.
    Thay vào đó, các hàm Hook nếu cần gây sát thương hãy return về một bảng {Action = "...", Amount = ...}. 
    CombatManager khi gọi Hook sẽ tự đọc bảng return này và thực thi.
]]

local StatusEffectRegistry = {}

-- ==========================================
-- [1] NHÓM SÁT THƯƠNG THEO THỜI GIAN (DoT)
-- ==========================================
StatusEffectRegistry.Poison = {
    Type = "DoT",
    Description = "Gây sát thương cố định mỗi đầu hiệp dựa trên số Stack.",
    
    -- Kích hoạt mỗi đầu hiệp của người bị dính
    OnTurnStart = function(target: any, effectData: any, context: any)
        local stacks = effectData and effectData.Stacks or 1
        local damage = 5 * stacks
        
        -- Trả về lệnh để CombatManager xử lý trừ máu (Tránh gọi ngược CombatManager ở đây)
        return {
            Action = "TakeTrueDamage",
            Amount = damage
        }
    end
}

StatusEffectRegistry.Burn = {
    Type = "DoT",
    Description = "Đốt 1% Max HP mỗi đầu lượt và giảm hồi máu.",
    
    OnTurnStart = function(target: any, effectData: any, context: any)
        local damage = math.floor(target.MaxHP * 0.01)
        return {
            Action = "TakeTrueDamage",
            Amount = damage
        }
    end,
    
    -- Lưỡi dao thứ 2 của Burn: Cắt giảm 20% lượng hồi máu
    BeforeHeal = function(target: any, value: number, effectData: any, context: any)
        return value * 0.8 
    end
}

-- ==========================================
-- [2] NHÓM DEBUFF (BẤT LỢI)
-- ==========================================
StatusEffectRegistry.Sunder = {
    Type = "Debuff",
    Description = "Trừ 25% P_DEF và M_DEF. (Bị phá giáp)",
    
    OnApply = function(target: any, effectData: any, context: any)
        -- Lưu lại lượng giáp đã bị trừ vào chính entity để lúc sau trả lại cho đúng
        target.pTempSunderMemory = target.P_DEF * 0.25
        target.mTempSunderMemory = target.M_DEF * 0.25
        target.P_DEF = target.P_DEF - target.pTempSunderMemory
        target.M_DEF = target.M_DEF - target.mTempSunderMemory
    end,
    
    OnRemove = function(target: any, effectData: any, context: any)
        -- Hết hạn -> Trả lại giáp
        if target.pTempSunderMemory and target.mTempSunderMemory then
            target.P_DEF = target.P_DEF + target.pTempSunderMemory
            target.M_DEF = target.M_DEF + target.mTempSunderMemory
            target.pTempSunderMemory = nil
            target.mTempSunderMemory = nil
        end
    end
}

StatusEffectRegistry.Vulnerable = {
    Type = "Debuff",
    Description = "Nhận thêm 25% sát thương từ mọi nguồn.",
    
    BeforeTakeDamage = function(target: any, value: number, effectData: any, context: any)
        -- Trả về lượng sát thương MỚI sau khi bị khuếch đại 25%
        return value * 1.25
    end
}

StatusEffectRegistry.Decay = {
    Type = "Debuff",
    Description = "Mọi lượng hồi máu bị ép về 0.",
    
    BeforeHeal = function(target: any, value: number, effectData: any, context: any)
        return 0 -- Khóa van vĩnh viễn, không cho hồi máu
    end
}

-- ==========================================
-- [3] NHÓM KHỐNG CHẾ (CROWD CONTROL)
-- ==========================================
StatusEffectRegistry.Stun = {
    Type = "CC",
    Description = "Bỏ qua 1 lượt đánh.",
    -- Dùng Cờ (Flags) để hệ thống TurnbaseEngine đọc và đá văng kẻ này khỏi lượt đánh
    Flags = {
        CannotAct = true 
    }
}

StatusEffectRegistry.Silence = {
    Type = "CC",
    Description = "Chỉ được dùng đòn đánh thường.",
    Flags = {
        CannotUseSkill = true
    }
}

-- ==========================================
-- [4] NHÓM BUFF (CÓ LỢI)
-- ==========================================
StatusEffectRegistry.Thorns = {
    Type = "Buff",
    Description = "Phản 20% sát thương nhận vào.",
    
    -- Hook này chạy SAU khi người này bị trừ máu
    AfterTakeDamage = function(target: any, effectData: any, context: any)
        local attacker = context and context.Attacker
        local damageTaken = context and context.DamageTaken or 0
        
        if attacker and attacker ~= target then
            local reflectDmg = math.floor(damageTaken * 0.2)
            
            -- Trả về lệnh để CombatManager gọi hàm đánh ngược lại Kẻ Tấn Công
            return {
                Action = "ReflectDamage",
                Target = attacker,
                Amount = reflectDmg
            }
        end
        return nil
    end
}

StatusEffectRegistry.Stealth = {
    Type = "Buff",
    Description = "Không bị chọn làm mục tiêu đơn.",
    Flags = {
        Untargetable = true
    }
}

return StatusEffectRegistry
