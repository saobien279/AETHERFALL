--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsCalculator = require(ReplicatedStorage.Modules.Utils.StatsCalculator)
local SkillRegistry = require(ReplicatedStorage.Modules.Registries.SkillRegistry)

local CombatManager = {}

-- [[ HÀM LÕI 1: CẬP NHẬT MÁU (UPDATE HP) ]]
-- Luôn thông qua hàm này thay vì tự cộng trừ máu để đảm bảo không bị kẹt lỗi máu âm
function CombatManager.UpdateHP(entity: any, amount: number)
    -- [HOOK INJECTION]: Xử lý tác động trước khi hồi máu (Decay, Burn)
    if amount > 0 then
        amount = CombatManager.RunModifierHook(entity, "BeforeHeal", amount, nil)
    end

    -- Bước 1: Tính tổng máu sau khi nhận/trừ, chặn ở mức 0 và MaxHP
    entity.CurrentHP = math.clamp(entity.CurrentHP + amount, 0, entity.MaxHP)

    -- Bước 2: Kiểm tra cái chết
    if entity.CurrentHP <= 0 then
        entity.IsDead = true
        -- (Sau này ta có thể nhúng Slot Thánh Di Vật hồi sinh ở đây)
    end
    
    -- Phát loa thông báo cho toàn Server để Client nghe thấy và kéo ống máu
    local combatEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("CombatEvents")
    if combatEvent and game:GetService("RunService"):IsServer() then
        -- Dùng chung CombatEvents, gửi kèm nhãn "UpdateHP" và GỬI MÃ ID CỦA THỰC THỂ!
        combatEvent:FireAllClients("UpdateHP", entity.ID, entity.CurrentHP, entity.MaxHP)
    end
    
    -- Trả về lượng HP thực tế đã nhảy (để lỡ dùng In ra màn hình UI)
    return entity.CurrentHP
end

-- [[ HÀM LÕI 2: CHỊU ĐÒN (TAKE DAMAGE) ]]
-- Hàm này xử lý sát thương ập vào người, tính toán giảm trừ giáp dựa theo Phân loại Sát thương
function CombatManager.TakeDamage(defender: any, incomingDamage: number, damageType: string, attacker: any)
    -- [HOOK INJECTION]: Khuếch đại sát thương trước khi tính giáp (Vulnerable)
    incomingDamage = CombatManager.RunModifierHook(defender, "BeforeTakeDamage", incomingDamage, {Attacker = attacker, DamageType = damageType})

    -- 1. Lấy chỉ số Giảm Sát Thương (Kỹ thuật caching: ta lấy luôn biến lưu sẵn trong thân thể lúc spawn)
    local damageReduction = defender.DamageReduction or 0
    
    -- 2. Đọc Giáp trực tiếp từ Thực Thể (Đã được nạp sẵn lúc tạo từ EntityManager)
    local pDefense = defender.P_DEF or 0
    local mDefense = defender.M_DEF or 0

    local finalDamage = 0

    -- 3. Phân luồng Sát thương như User thiết kế
    if damageType == "Physical" then
        finalDamage = StatsCalculator.calculateFinalDamage(incomingDamage, pDefense, damageReduction)
    elseif damageType == "Magical" then
        finalDamage = StatsCalculator.calculateFinalDamage(incomingDamage, mDefense, damageReduction)
    else
        -- Default/True damage 
        finalDamage = incomingDamage 
    end

    -- 4. Trừ máu thồi!
    CombatManager.UpdateHP(defender, -finalDamage)
    
    -- [HOOK INJECTION]: Kích hoạt hiệu ứng trả đũa sau khi nhận sát thương (Thorns)
    CombatManager.RunActionHook(defender, "AfterTakeDamage", {DamageTaken = finalDamage, Attacker = attacker, DamageType = damageType})
end

-- [[ HÀM LÕI 3: GÂY SÁT THƯƠNG (DEAL DAMAGE) ]]
-- Hàm khởi nguồn khi người chơi bấm nút tung chiêu
function CombatManager.DealDamage(attacker: any, defender: any, skillID: string)
    local skillData = SkillRegistry[skillID]
    if not skillData then return end

    -- Đọc Vũ khí trực tiếp từ Thực Thể (Đã được nạp sẵn lúc tạo từ EntityManager)
    local wBase = attacker.WeaponBaseDamage or 0
    local wBuff = attacker.WeaponBuffMultiplier or 1.0

    -- 1. Tìm loại Sát Thương như bạn thiết kế (Mặc định Physical nếu quên ghi)
    local damageType = skillData.DamageType or "Physical"

    -- 2. Đọc vào Scaling: CHỌN RA CHỈ SỐ GÂY HIGHEST DAMAGE (Hỗ trợ Dual Scale và mọi Stat)
    local bestStatBonus = 0
    if skillData.Scaling then
        for statName, scaleFactor in pairs(skillData.Scaling) do
            local currentBonus = 0
            local point = attacker.Stats and attacker.Stats[statName] or 0

            if statName == "STR" then
                currentBonus = StatsCalculator.getStrengthBonus(point) * scaleFactor
            elseif statName == "ARC" then
                currentBonus = StatsCalculator.getArcaneBonus(point) * scaleFactor
            else
                -- Luật chung cho SPD, LCK, END: 1 điểm = 0.5% (Tức là x 0.005). 
                -- Thêm lệnh math.min(..., 1.5) để kẹp trần tỷ lệ vĩnh viễn không vượt qua ngưỡng 150% giống hệt STR.
                local rawGenericBonus = (point * 0.5) / 100
                currentBonus = math.min(rawGenericBonus, 1.5) * scaleFactor
            end

            -- Chốt: Chỉ lấy nguyên liệu Scaling đẩy ra lượng % sức mạnh to nhất
            if currentBonus > bestStatBonus then
                bestStatBonus = currentBonus
            end
        end
    end

    -- 3. Đưa vào hàm tính Sát thương đầu ra của User
    local incomingRawDmg = StatsCalculator.CalculateOutputDamage(skillData.BasePower, bestStatBonus, wBase, wBuff)

    -- [HOOK INJECTION]: Nhồi thêm buff trước khi vung đòn đánh (Whetstone)
    incomingRawDmg = CombatManager.RunModifierHook(attacker, "BeforeDealDamage", incomingRawDmg, {Defender = defender, SkillID = skillID})

    -- 4. Đẩy cục Damage đó vào cho Defender gánh chịu (Gửi kèm danh tính Attacker)
    CombatManager.TakeDamage(defender, incomingRawDmg, damageType, attacker)
    
    -- [HOOK INJECTION]: Kích hoạt hiệu ứng sau khi đánh trúng (Hút máu - Lifesteal)
    CombatManager.RunActionHook(attacker, "AfterDealDamage", {Defender = defender, DamageDealt = incomingRawDmg, SkillID = skillID})
end

-- [[ HÀM CHẠY HOOK (RUN MODIFIER HOOK) ]]
-- Cỗ máy màng lọc đa năng, chạy qua tất cả bệnh án để sửa đổi một con số (Máu, Sát thương, v.v.).
function CombatManager.RunModifierHook(entity: any, hookName: string, baseValue: number, context: any)
    local finalValue = baseValue
    local StatusEffectRegistry = require(game:GetService("ReplicatedStorage").Modules.Registries.StatusEffectRegistry)
    
    -- 1. Quét qua các Hiệu ứng Trạng thái (Status Effects)
    if entity.StatusEffects then
        for effectName, effectData in pairs(entity.StatusEffects) do
            local effectTemplate = StatusEffectRegistry[effectName]
            
            -- Nếu trong Registry có thiết kế trạm kiểm soát này:
            if effectTemplate and effectTemplate[hookName] then
                -- Đưa cục thịt (finalValue) và tờ bệnh án (effectData) vào cho hàm xào nấu
                finalValue = effectTemplate[hookName](entity, finalValue, effectData, context)
            end
        end
    end
    
    -- (TODO: Chúng ta sẽ thêm phần quét qua Phụ kiện (Gears) ở đây trong các bước sau)
    
    return finalValue
end

-- [[ HÀM CHẠY LỆNH HOOK (RUN ACTION HOOK) ]]
-- Cỗ máy gom nhặt các Hành động phát sinh từ hiệu ứng (như trừ máu độc, phản đòn) và thi hành chúng.
function CombatManager.RunActionHook(entity: any, hookName: string, context: any)
    local StatusEffectRegistry = require(game:GetService("ReplicatedStorage").Modules.Registries.StatusEffectRegistry)
    
    -- 1. Tạo một cái giỏ rỗng để hứng các bảng lệnh
    local actionQueue = {}

    if entity.StatusEffects then
        for effectName, effectData in pairs(entity.StatusEffects) do
            local effectTemplate = StatusEffectRegistry[effectName]
            
            if effectTemplate and effectTemplate[hookName] then
                -- Lấy cái lệnh nhả ra (Ví dụ: {Action="TakeTrueDamage", Amount=5})
                local actionCommand = effectTemplate[hookName](entity, effectData, context)
                
                -- Cất lệnh vào giỏ (nếu có lệnh)
                if actionCommand then
                    table.insert(actionQueue, actionCommand)
                end
            end
        end
    end
    
    -- (TODO: Thêm vòng lặp quét Phụ kiện (Gears) ở đây sau này)

    -- 2. THI HÀNH ÁN: Đọc từng Lệnh trong giỏ và ra tay
    for _, cmd in ipairs(actionQueue) do
        if cmd.Action == "TakeTrueDamage" then
            -- Máu tự rút (Độc, Lửa)
            CombatManager.UpdateHP(entity, -cmd.Amount)
            
        elseif cmd.Action == "ReflectDamage" and cmd.Target then
            -- Phản đòn (Gai) -> Đánh ngược lại thằng Target
            CombatManager.TakeDamage(cmd.Target, cmd.Amount, "TrueDamage")
        end
        
        -- (Sau này nếu có Action mới như "BuffHeal" thì chỉ việc viết thêm elseif ở đây)
    end
end

-- [[ HÀM QUẢN LÝ 1: GÁN HIỆU ỨNG (APPLY STATUS EFFECT) ]]
function CombatManager.ApplyStatusEffect(entity: any, effectName: string, stacks: number?, duration: number?)
    local StatusEffectRegistry = require(game:GetService("ReplicatedStorage").Modules.Registries.StatusEffectRegistry)
    local effectTemplate = StatusEffectRegistry[effectName]
    
    -- 1. Nếu tên hiệu ứng gõ sai hoặc không có trong Registry -> Nghỉ
    if not effectTemplate then return end

    -- (TODO: Chèn logic kiểm tra Immunity (Miễn nhiễm) ở đây sau)

    -- 2. Khởi tạo kho chứa bệnh án nếu entity vô tình chưa có
    if not entity.StatusEffects then
        entity.StatusEffects = {}
    end

    -- 3. Kiểm tra xem người này đã dính hiệu ứng này chưa
    if entity.StatusEffects[effectName] then
        -- TRƯỜNG HỢP A: ĐÃ DÍNH RỒI
        
        -- Logic riêng cho Shield: Không cộng dồn, không ghi đè. Đến trước phục vụ trước.
        if effectName == "Shield" then
            return -- Đang có khiên rồi thì bỏ qua luôn, không cấp khiên mới
        end

        -- Các hiệu ứng khác (Stackable): Chỉ cộng dồn số Stacks.
        -- Theo thiết kế của bạn: Với Sunder/Poison, số Stacks chính là Thời gian tồn tại (mỗi hiệp trừ 1).
        if stacks then
            entity.StatusEffects[effectName].Stacks += stacks
        end
    else
        -- TRƯỜNG HỢP B: CHƯA BỊ DÍNH (LẦN ĐẦU TIÊN TẠO HỒ SƠ)
        entity.StatusEffects[effectName] = {
            Name = effectName,
            Stacks = stacks or 1,
            Duration = duration or 1
        }

        -- Quan trọng: Gọi hàm OnApply trong từ điển để nó kích hoạt sửa chỉ số (ví dụ: Sunder trừ giáp ngay lập tức)
        if effectTemplate.OnApply then
            effectTemplate.OnApply(entity, entity.StatusEffects[effectName], nil)
        end
    end
end

-- [[ HÀM QUẢN LÝ 2: GỠ HIỆU ỨNG (REMOVE STATUS EFFECT) ]]
function CombatManager.RemoveStatusEffect(entity: any, effectName: string)
    -- 1. Kiểm tra xem có đang mang bệnh án này không. Không có thì lờ đi.
    if not entity.StatusEffects or not entity.StatusEffects[effectName] then 
        return 
    end

    local StatusEffectRegistry = require(game:GetService("ReplicatedStorage").Modules.Registries.StatusEffectRegistry)
    local effectTemplate = StatusEffectRegistry[effectName]

    -- 2. Quan trọng: Gọi hàm OnRemove trong từ điển để nó dọn dẹp hiện trường (ví dụ: Sunder cộng trả lại giáp)
    if effectTemplate and effectTemplate.OnRemove then
        effectTemplate.OnRemove(entity, entity.StatusEffects[effectName], nil)
    end

    -- 3. Xé bỏ tờ bệnh án
    entity.StatusEffects[effectName] = nil
end

return CombatManager
