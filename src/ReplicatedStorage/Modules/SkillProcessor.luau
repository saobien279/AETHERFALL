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

