--!strict
local SkillRegistry = {
    -- ==========================================
    -- HỆ THỐNG KỸ NĂNG CHUNG CHƯA PHÂN LOẠI
    -- ==========================================
    ["Aether Healing"] = {
        UnlockLevel = 1,
        EnergyCost = 4, 
        Cooldown = 5,
        BasePower = 20,
        Scaling = { ARC = 1.5 },
        Type = "AoE",
        DamageType = "Magical",
        IsHeal = true,
        Description = "Hồi máu cho toàn bộ đồng đội."
    },

    -- ==========================================
    -- AETHERIAN SKILLS
    -- ==========================================
    ["Aether Strike"] = {
        UnlockLevel = 40,
        EnergyCost = 2,
        Cooldown = 6,
        BasePower = 15,
        Scaling = { STR = 1.0, ARC = 1.0 },
        Type = "Single",
        DamageType = "Physical", -- Đấm vật lý
        BaseMultiplier = 1.3,
        HighHPBonus = 1.2, -- x1.2 if enemy HP > 80%
        Description = "Cú đấm tập trung năng lượng Aether. Gây thêm sát thương nếu kẻ địch còn nhiều máu."
    },

    -- ==========================================
    -- FELORIAN SKILLS
    -- ==========================================
    ["Prowl"] = {
        UnlockLevel = 5,
        EnergyCost = 2,
        Cooldown = 5,
        NextTurnMultiplier = 1.5,
        DefensePierce = 0.25,
        Status = "Stealth",
        Type = "Buff",
        DamageType = "Physical",
        Description = "Tàng hình một lượt, tăng sát thương và xuyên thủng giáp vào lượt kế tiếp."
    },
    ["Burst Trap"] = {
        UnlockLevel = 40,
        EnergyCost = 3,
        Cooldown = 5,
        Duration = 3,
        BasePower = 8,
        Scaling = { SPD = 0.8, LCK = 0.4 },
        Effects = {"Fire Counter", "Blind"},
        Type = "Trap",
        DamageType = "Magical", -- Bẫy nổ ma thuật
        Description = "Đặt bẫy nổ bằng bột lửa. Kẻ địch kích hoạt sẽ chịu mù và sát thương lửa."
    },

    -- ==========================================
    -- SYLVANI SKILLS
    -- ==========================================
    ["Wind's Grace"] = {
        UnlockLevel = 5,
        EnergyCost = 2,
        Cooldown = 5,
        BasePower = 12,
        Scaling = { ARC = 0.9 },
        Status = "Stealth",
        Duration = 1,
        Type = "Single",
        DamageType = "Magical", -- Nhát cắt gió ma thuật
        Description = "Lướt theo gió gây sát thương và tạm thời tàng hình."
    },
    ["Starfall Tempest"] = {
        UnlockLevel = 40,
        EnergyCost = 4,
        Cooldown = 8,
        BasePower = 25,
        Scaling = { ARC = 1.3 },
        StunChance = 0.20,
        MDefShred = 0.85,
        Type = "AoE",
        DamageType = "Magical", -- Thiên thạch tinh tú
        Description = "Triệu hồi pháp trận sao băng giáng xuống, có tỷ lệ làm choáng và trừ MDef."
    },

    -- ==========================================
    -- KRAGHORN SKILLS
    -- ==========================================
    ["Bloodrage"] = {
        UnlockLevel = 5,
        EnergyCost = 1,
        Cooldown = 6,
        BaseBuff = 1.1,
        LowHPThreshold = 0.4,
        LowHPBuff = 1.2,
        Type = "Buff",
        DamageType = "Physical", -- Huyết nộ cường hóa cơ bắp
        Description = "Kích phát huyết nộ tăng sát thương, sức mạnh nhân lên kinh khủng khi HP dưới 40%."
    },
    ["Seismic Slam"] = {
        UnlockLevel = 40,
        EnergyCost = 3,
        Cooldown = 7,
        BasePower = 20,
        Scaling = { STR = 1.0, END = 0.3 },
        Status = "Cripple",
        SpeedDebuff = 0.8,
        Type = "AoE",
        DamageType = "Physical", -- Dậm đất cơ bắp
        Description = "Dậm mạnh xuống đất làm đối thủ tê liệt, trừ nặng tốc độ đánh."
    },

    -- ==========================================
    -- NYXBORN SKILLS
    -- ==========================================
    ["Crimson Feast"] = {
        UnlockLevel = 5,
        EnergyCost = 2,
        Cooldown = 4,
        NextHitMultiplier = 1.15,
        HealFromDamage = 0.15,
        Type = "Buff",
        DamageType = "Physical", -- Lưỡi kiếm tẩm máu vật lý
        Description = "Bao phủ vũ khí bằng khí huyết, cường hóa đòn đánh tiếp theo và hút máu."
    },
    ["Void Assassination"] = {
        UnlockLevel = 40,
        EnergyCost = 5,
        Cooldown = 6,
        BasePower = 30,
        Scaling = { STR = 1.6, ARC = 1.6 },
        IgnoreShield = true,
        DoTMultiplier = 1.25,
        Type = "Single",
        DamageType = "Physical", -- Đâm thấu xương
        Description = "Ám sát từ hư không, xuyên khiên. Gây thêm rất nhiều sát thương nếu mục tiêu đang có hiệu ứng DoT."
    },

    -- ==========================================
    -- DRAKARI SKILLS
    -- ==========================================
    ["Dragon's Breath"] = {
        UnlockLevel = 10,
        EnergyCost = 3,
        Cooldown = 8,
        BasePower = 18,
        Scaling = { STR = 1.0, ARC = 1.0 },
        Status = "Burn",
        BurnDamage = 0.04,
        Type = "AoE",
        DamageType = "Magical", -- Lửa rồng ma thuật
        Description = "Thở ra ngọn lửa chân rồng, gây Thiêu đốt mục tiêu theo 4% Max HP mỗi lượt."
    },
    ["Imperial Dragon Realm"] = {
        UnlockLevel = 40,
        EnergyCost = 6,
        Cooldown = 15,
        Duration = 5,
        BasePower = 10,
        DamagePerTurn = 10,
        Scaling = { ARC = 0.4 },
        HealBoost = 1.2,
        SpecialEffect = "Mulligan",
        Mulligan = { HPRecover = 0.20, Status = "Immortal" },
        Type = "AoE",
        DamageType = "Magical", -- Long giới ma pháp
        Description = "Mở ra long giới bảo hộ và thiêu đốt kẻ thù, cho phép hồi lại 1 lượng HP khi chí tử."
    }
}

return SkillRegistry
