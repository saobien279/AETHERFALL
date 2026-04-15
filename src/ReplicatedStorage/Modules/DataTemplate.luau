local DataTemplate = {
    -- 1. DỮ LIỆU TÀI KHOẢN (Account-wide - Dùng chung cho mọi nhân vật)
    AccountData = {
        GoldAccount = 0,      -- Tiền nạp hoặc tiền dùng chung
        TotalDonated = 0,
        UnlockedSlots = 1,    -- Số lượng slot nhân vật đã mở khóa
        CurrentSlotIndex = "Slot1", -- Slot đang chơi gần nhất
        Settings = {
            MusicVolume = 0.5,
            SFXVolume = 0.5,
        }
    },

    -- 2. DANH SÁCH NHÂN VẬT (Multi-Slot Characters)
    Characters = {
        ["Slot1"] = {
            -- Thông tin cơ bản
            Name = "New Explorer",
            Race = "Aetherian",  -- Lưu tên Race để tra cứu Registry
            Class = "None",      -- Vanguard, Aether Swordsman, v.v.
            Level = 1,
            Exp = 0,

            -- Chỉ số cộng thêm (Invested Stats)
            -- Lưu ý: CHỈ lưu điểm người chơi tự cộng. 
            -- Tổng chỉ số = (Stats này + Base Race Stats) * Multiplier
            Stats = {
                STR = 0,
                ARC = 0,
                END = 0,
                SPD = 0,
                LCK = 0,
                UnusedPoints = 0, -- Điểm chưa cộng (3 điểm mỗi level)
            },

            -- Trạng thái chiến đấu & Tài nguyên
            Combat = {
                CurrentHP = 100,      -- Để khi thoát game vào lại vẫn giữ máu cũ
                CurrentEnergy = 0,    -- Năng lượng tích lũy (Max 6)
            },

            -- Trang bị & Túi đồ
            Inventory = {
                Equipped = {
                    Weapon = "WoodenSword",
                    Armor = "TatteredClothes",
                    Accessory = "None",
                },
                Items = {}, -- Danh sách ID vật phẩm người chơi sở hữu
            },

            -- Tiến trình (Progress)
            Progress = {
                HighestTier = 1,
                UnlockedWaypoints = {"SpawnVillage"},
                CompletedQuests = {},
            }
        },
        -- Các Slot 2, 3 sẽ được copy từ khuôn này khi người chơi tạo mới
    }
}

return DataTemplate