local SkillProcessor = {}

-- Các loại thông báo lỗi để UI hiển thị cho người chơi
SkillProcessor.Errors = {
    NOT_ENOUGH_ENERGY = "Không đủ Energy!",
    ON_COOLDOWN = "Kỹ năng đang trong thời gian hồi!",
    SILENCED = "Bạn đang bị Câm Lặng, không thể dùng kỹ năng!"
}

function SkillProcessor.CanUseSkill(attacker: any , Skillname: string , skillRegistry: any)
    local skill = skillRegistry[Skillname]
    if not skill then return false, "Kỹ năng không tồn tại!" end
    
    if attacker.Energy < skill.EnergyCost then
        return false,SkillProcessor.Errors.NOT_ENOUGH_ENERGY
    end

    -- 2. KIỂM TRA COOLDOWN
    -- Chỉnh sửa: Truy cập vào ActiveCooldowns (theo DataTemplate)
    -- Nếu không có trong bảng (nil), coi như là 0 lượt
    local turnsLeft = (attacker.ActiveCooldowns and attacker.ActiveCooldowns[Skillname]) or 0
    if turnsLeft > 0 then
        return false, SkillProcessor.Errors.ON_COOLDOWN
    end
    -- 3. KIỂM TRA STATUS (Silence - Câm lặng)
    if attacker.StatusEffects and attacker.StatusEffects["Silence"] then
        return false, SkillProcessor.Errors.SILENCED
    end

    return true, nil
end

-- [[ HÀM TRỪ PHÍ VÀ LƯU NỢ COOLDOWN HẬU KỲ ]]
function SkillProcessor.ConsumeCost(attacker: any, skillName: string, skillRegistry: any)
    local skill = skillRegistry[skillName]
    if not skill then return end

    -- Trừ Mana
    attacker.Energy = math.clamp(attacker.Energy - skill.EnergyCost, 0, attacker.MaxEnergy or 6)
    
    -- Nhét vào đầu cuốn sổ nợ Cooldown (Lưu ý: Mới đánh xong thì chờ X lượt)
    if skill.Cooldown and skill.Cooldown > 0 then
        attacker.ActiveCooldowns[skillName] = skill.Cooldown
    end
end

-- [[ HÀM CẬP NHẬT ĐẦU LƯỢT (Gọi khi đến lượt của Nhân vật/Quái) ]]
function SkillProcessor.ProcessStartTurn(entity: any)
    -- Hồi 2 năng lượng (MP) mỗi lượt để có vốn đánh tiếp
    entity.Energy = math.clamp(entity.Energy + 1, 0, entity.MaxEnergy or 6)

    -- Trừ 1 hiệp cho toàn bộ chiêu đang dính Cooldown
    if entity.ActiveCooldowns then
        for sName, turnsLeft in pairs(entity.ActiveCooldowns) do
            if turnsLeft > 0 then
                entity.ActiveCooldowns[sName] = turnsLeft - 1
            end
            -- Xóa nợ nếu cấn xong
            if entity.ActiveCooldowns[sName] <= 0 then
                entity.ActiveCooldowns[sName] = nil
            end
        end
    end
end

return SkillProcessor