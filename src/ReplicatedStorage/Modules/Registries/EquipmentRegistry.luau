--!strict
local EquipmentRegistry = {
    -- =======================================
    -- KHO VŨ KHÍ (WEAPONS)
    -- =======================================
    Weapons = {
        ["LowFinSword"] = {
            Type = "Weapon",
            BaseDmg = 7,
            WeaponBuff = 1.0, -- Không buff (1.0 = x1)
            Description = "Một thanh kiếm phổ thông với chất lượng bình thường."
        },
        ["FinSword"] = {
            Type = "Weapon",
            BaseDmg = 10,
            WeaponBuff = 1.05, -- Buff +5% sát thương
            Description = "Thanh kiếm mang dấu ấn tinh xảo của các bậc thầy Aether."
        }
    },

    -- =======================================
    -- KHO GIÁP TRỤ (ARMORS)
    -- =======================================
    Armors = {
        ["RecruitLeathers"] = {
            Type = "Armor",
            P_DEF = 10,
            M_DEF = 5,
            SpeedBonus = 0,
            Description = "Giáp Da Tân Binh - Cân bằng, nhẹ nhàng."
        },
        ["IronPlate"] = {
            Type = "Armor",
            P_DEF = 20,
            M_DEF = 0,
            SpeedBonus = 0,
            Description = "Giáp Sắt - Chống vật lý cực tốt."
        },
        ["ScholarRobe"] = {
            Type = "Armor",
            P_DEF = 0,
            M_DEF = 20,
            SpeedBonus = 0,
            Description = "Áo Choàng Học Giả - Kháng phép tối ưu."
        },
        ["ScoutGarb"] = {
            Type = "Armor",
            P_DEF = 5,
            M_DEF = 5,
            SpeedBonus = 5,
            Description = "Y phục Thám Báo - Ưu tiên tốc độ, né tránh."
        },
        ["HeavyStoneMail"] = {
            Type = "Armor",
            P_DEF = 25,
            M_DEF = 10,
            SpeedBonus = -10,
            Description = "Giáp Đá Nặng - Lì lợm nhưng chậm chạp."
        }
    },

    -- =======================================
    -- KHO TRANG BỊ BỔ TRỢ (GEARS)
    -- =======================================
    Gears = {
        -- Slot 1: Kích hoạt khi tấn công
        ["Whetstone"] = {
            SlotType = "Slot1_Offensive",
            Description = "Khi Chí mạng, gây thêm sát thương vật lý bằng 30% sát thương gốc."
        },
        ["SparkPlug"] = {
            SlotType = "Slot1_Offensive",
            Description = "Đòn đánh thường có 15% tỷ lệ gây hiệu ứng [Burn] (Trừ 2% Max HP/lượt)."
        },

        -- Slot 2: Kích hoạt khi phòng thủ
        ["SpikedBracers"] = {
            SlotType = "Slot2_Defensive",
            Description = "Bị tấn công cận chiến sẽ Phản 40% chỉ số P.DEF thành sát thương về số 0."
        },
        ["GhostlyVeil"] = {
            SlotType = "Slot2_Defensive",
            Description = "Sau khi Né tránh, nhận ngay lập tức trạng thái [Tàng Hình] (1 lượt)."
        },

        -- Slot 3: Kích hoạt ngưỡng HP
        ["BerserkerHeart"] = {
            SlotType = "Slot3_Threshold",
            Description = "HP < 30% -> Nhận +20% Sát thương và +10% Hút máu."
        },
        ["GuardianShell"] = {
            SlotType = "Slot3_Threshold",
            Description = "Mỗi trận đấu Khởi tạo với một lớp khiên ảo (Shield) = 15% Max HP."
        },

        -- Slot 4: Kỹ năng chủ động
        ["FlashBang"] = {
            SlotType = "Slot4_Active",
            Cooldown = 8,
            Description = "Gây 1 DMG và làm toàn bộ kẻ địch mất lượt (Choáng)."
        },
        ["PurityFlask"] = {
            SlotType = "Slot4_Active",
            Cooldown = 6,
            Description = "Xóa mọi Debuff, hồi phục 10% năng lượng."
        }
    },

    -- =======================================
    -- THÁNH DI VẬT (ARTIFACTS)
    -- =======================================
    Artifacts = {
        -- Phức tạp, để trống, cập nhật sau cùng theo Plan
    }
}

return EquipmentRegistry
