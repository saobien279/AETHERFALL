--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsCalculator = require(ReplicatedStorage.Modules.Utils.StatsCalculator)
local EquipmentRegistry = require(ReplicatedStorage.Modules.Registries.EquipmentRegistry)
local SkillRegistry = require(ReplicatedStorage.Modules.Registries.SkillRegistry)

local CombatManager = {}

-- [[ HÀM LÕI 1: CẬP NHẬT MÁU (UPDATE HP) ]]
-- Luôn thông qua hàm này thay vì tự cộng trừ máu để đảm bảo không bị kẹt lỗi máu âm
function CombatManager.UpdateHP(entity: any, amount: number)
    -- Bước 1: Tính tổng máu sau khi nhận/trừ, chặn ở mức 0 và MaxHP
    entity.CurrentHP = math.clamp(entity.CurrentHP + amount, 0, entity.MaxHP)

    -- Bước 2: Kiểm tra cái chết
    if entity.CurrentHP <= 0 then
        entity.IsDead = true
        -- (Sau này ta có thể nhúng Slot Thánh Di Vật hồi sinh ở đây)
    end
    
    -- Bước 3: Phát loa thông báo cho toàn Server để Client nghe thấy và kéo ống máu
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
function CombatManager.TakeDamage(defender: any, incomingDamage: number, damageType: string)
    -- 1. Lấy chỉ số Giảm Sát Thương (Kỹ thuật caching: ta lấy luôn biến lưu sẵn trong thân thể lúc spawn)
    local damageReduction = defender.DamageReduction or 0
    
    -- 2. TÌM GIÁP: Lấy ID giáp nhân vật đang mặc và tra từ điển
    local armorID = defender.Inventory.Equipped.Armor
    local armorData = EquipmentRegistry.Armors[armorID]
    
    local pDefense = armorData and armorData.P_DEF or 0
    local mDefense = armorData and armorData.M_DEF or 0

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
end

-- [[ HÀM LÕI 3: GÂY SÁT THƯƠNG (DEAL DAMAGE) ]]
-- Hàm khởi nguồn khi người chơi bấm nút tung chiêu
function CombatManager.DealDamage(attacker: any, defender: any, skillID: string)
    local skillData = SkillRegistry[skillID]
    if not skillData then return end

    local weaponID = attacker.Inventory.Equipped.Weapon
    local weaponData = EquipmentRegistry.Weapons[weaponID]

    -- Nếu bằng 1 cách nào đó nhân vật rớt vũ khí (tay không), ta set mặc định:
    local wBase = weaponData and weaponData.BaseDmg or 0
    local wBuff = weaponData and weaponData.WeaponBuff or 1.0

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

    -- 4. Đẩy cục Damage đó vào cho Defender gánh chịu
    CombatManager.TakeDamage(defender, incomingRawDmg, damageType)
end

return CombatManager
