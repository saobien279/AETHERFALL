local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillProcessor = require(ReplicatedStorage.Modules.SkillProcessor)
local SkillRegistry = require(ReplicatedStorage.Modules.Registries.SkillRegistry)
local CombatManager = require(ReplicatedStorage.Modules.Core.CombatManager)

local MonsterAI = {}

-- Đầu vào: Thực thể Quái (attacker) và Thực thể Người chơi (defender)
function MonsterAI.ProcessTurn(attackerEntity, defenderEntity)
    
    -- ==========================================
    -- MỨC ĐỘ 3: KIỂM TRA LOGIC BOSS (TƯƠNG LAI)
    -- ==========================================
    if attackerEntity.Type == "Boss" then
        -- Chỗ này mai mốt nếu là Boss Rồng Máu < 30%, gọi code khạc lửa Cố định.
        -- return
    end

    -- ==========================================
    -- MỨC ĐỘ 2: BỘ NÃO XÁC SUẤT (Dành cho Quái Normal)
    -- ==========================================
    
    -- BƯỚC 1: LỌC RÁC
    local availableSkills = {}
    local totalWeight = 0

    for _, skillData in ipairs(attackerEntity.Skillset) do
        -- Đem lên nhờ Cảnh Sát duyệt
        local canUse, _ = SkillProcessor.CanUseSkill(attackerEntity, skillData.Name, SkillRegistry)
        if canUse then
            table.insert(availableSkills, skillData)
            totalWeight += skillData.Weight
        end
    end

    -- BƯỚC 2: PHÒNG HỜ MẤT ĐIỆN
    if #availableSkills == 0 then
        print("[AI] 🤖 LỖI: Quái vật " .. attackerEntity.Name .. " bị phong ấn hết chiêu. Chấp nhận Bỏ lượt!")
        return
    end

    -- BƯỚC 3: QUAY XỔ SỐ
    local ticket = math.random(1, totalWeight)
    local chosenSkillName = ""

    for _, skillData in ipairs(availableSkills) do
        ticket = ticket - skillData.Weight
        if ticket <= 0 then
            chosenSkillName = skillData.Name
            break
        end
    end

    print("🤖 [MONSTER AI] Quay xổ số thành công! Tung chiêu: " .. chosenSkillName)

    -- BƯỚC 4: XUẤT CHIÊU TÁC ĐỘNG VÀO TRẬN ĐÁNH
    -- Trừ Mana của chiêu và ghi nợ Cooldown
    SkillProcessor.ConsumeCost(attackerEntity, chosenSkillName, SkillRegistry)
    
    -- Tung dao đâm thẳng người chơi
    CombatManager.DealDamage(attackerEntity, defenderEntity, chosenSkillName)
end

return MonsterAI
