
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsCalculator = require(ReplicatedStorage.Modules.Utils.StatsCalculator)
local EquipmentRegistry = require(ReplicatedStorage.Modules.Registries.EquipmentRegistry)

local EntityManager = {}

--[[
    Hàm tạo một thực thể chiến đấu mới (Player hoặc Enemy).
    Logic: Lấy point đã cộng Multiplier từ Race -> Tính toán HP/DR từ Point đó.
]]
function EntityManager.New(playerData: any, RaceRegistry: any)
    -- 1. Lấy tổng điểm chỉ số (Đã bao gồm % cộng thêm từ Race vào Point)
    local totalStats = StatsCalculator.GetTotalStats(playerData, RaceRegistry)    

    -- [NEW] Lấy chỉ số từ Trang Bị và cộng dồn (như SpeedBonus)
    local equipMods = StatsCalculator.GetEquipmentModifiers(playerData.Inventory and playerData.Inventory.Equipped, EquipmentRegistry)
    if equipMods.SpeedBonus then
        totalStats.SPD = (totalStats.SPD or 0) + equipMods.SpeedBonus
    end

    -- 2. Tính toán các thông số phụ thuộc vào Endurance (END)
    -- endStats trả về: { MaxHPBonus = point * 15, DamageReduction = ... }
    local endStats = StatsCalculator.getEnduranceStats(totalStats.END)

    -- 3. Tính MaxHP: Máu gốc (100) + Bonus từ điểm END
    -- Vì Multiplier của tộc đã nhân vào point END trước đó, nên không nhân ở đây nữa.
    local maxHP = 100 + endStats.MaxHPBonus

    -- 4. Trả về hồ sơ thực thể hoàn chỉnh
    return {
        Name = playerData.Name or "Unknown",
        ID = playerData.ID or playerData.Name, -- Thẻ căn cước Mạng (Network ID)
        Type = playerData.Type or "Player", -- Mặc định là Player nếu không truyền
        Race = playerData.Race,
        Inventory = playerData.Inventory,
        Skillset = playerData.Skillset or {}, -- Chỉ xài cho Quái Vật
        
        -- Chỉ số sinh tồn (Động)
        MaxHP = maxHP,
        CurrentHP = maxHP,
        MaxEnergy = 6,  -- Trần nội năng
        Energy = 0,      -- Vừa vào game cho sẵn 2 điểm làm vốn
        IsDead = false,
        
        -- Chỉ số chiến đấu (Đã qua xử lý Diminishing)
        Stats = totalStats,
        DamageReduction = endStats.DamageReduction,
        
        -- Chỉ số từ Trang Bị
        P_DEF = equipMods.P_DEF,
        M_DEF = equipMods.M_DEF,
        WeaponBaseDamage = equipMods.WeaponBaseDamage,
        WeaponBuffMultiplier = equipMods.WeaponBuffMultiplier,
        
        -- Hệ thống quản lý Vòng lặp
        ActiveCooldowns = {}, 
        StatusEffects = {} 
    }
end

return EntityManager