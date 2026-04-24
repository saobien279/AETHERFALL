local EnemyRegistry = {
    -- ID Quái vật
    ["LowlyBandit"] = {
        Name = "Tên Cướp Hẻm",
        Type = "Normal", -- Phân loại (Normal / Boss)
        Race = "Sylvanus", 
        
        -- Chỉ số gốc của Quái
        Stats = { 
            STR = 10, 
            ARC = 0, 
            END = 5, 
            SPD = 8, 
            LCK = 2 
        },
        
        -- Quái vật cũng mặc đồ như người để tính Sát thương dựa trên Vũ khí
        Inventory = {
            Equipped = {
                Weapon = "LowFinSword",
                Armor = "RecruitLeathers",
                Artifact = "None",
                Gears = { Slot1_Offensive = "None", Slot2_Defensive = "None", Slot3_Threshold = "None", Slot4_Active = "None" }
            }
        },

        -- Tương lai dùng cho AI (Não bộ)
        -- Quái vật này biết xài những chiêu nào? (Kèm trọng số Weight)
        Skillset = {
            {Name = "Normal Attack", Weight = 100}
        },
        
        -- Tiền thưởng rơi ra khi chết
        Rewards = {
            Exp = 15,
            Gold = 5
        }
    },

    ["WildSlime"] = {
        Name = "Green Slime",
        Type = "Normal",
        Race = "Aetherian", 
        Stats = { STR = 2, ARC = 15, END = 8, SPD = 5, LCK = 10 },
        Inventory = {
            Equipped = {
                Weapon = "None", -- Không cầm vũ khí (Scale sát thương tay không hoặc phép)
                Armor = "None",
                Artifact = "None",
                Gears = { Slot1_Offensive = "None", Slot2_Defensive = "None", Slot3_Threshold = "None", Slot4_Active = "None" }
            }
        },
        Skillset = {
            {Name = "Normal Attack", Weight = 100}
        },
        Rewards = {
            Exp = 5,
            Gold = 2
        }
    }
}

return EnemyRegistry
