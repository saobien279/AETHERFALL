--!strict
local StatsCalculator = {}

------------------------------------------------------
-- CONSTANTS (Cấu hình hệ số)
------------------------------------------------------
local DAMAGE_SCALING = {
	TIER_1 = { CAP = 40, MULT = 1.3 },
	TIER_2 = { CAP = 80, MULT = 1.0 },
	TIER_3 = { MULT = 0.7 }
}

local ENDURANCE_SCALING = {
	TIER_1 = { CAP = 50, MULT = 0.4 },
	TIER_2 = { CAP = 100, MULT = 0.3 },
	TIER_3 = { CAP = 200, MULT = 0.15 },
	HARD_CAP = 50 -- 50% Damage Reduction
}

------------------------------------------------------
-- PRIVATE CALCULATORS
------------------------------------------------------

-- Tính toán Diminishing cho Sát thương (STR/ARC)
local function calculateDiminishingDamage(point: number): number
	local totalBonus = 0

	if point <= DAMAGE_SCALING.TIER_1.CAP then
		totalBonus = point * DAMAGE_SCALING.TIER_1.MULT
	elseif point <= DAMAGE_SCALING.TIER_2.CAP then
		totalBonus = (DAMAGE_SCALING.TIER_1.CAP * DAMAGE_SCALING.TIER_1.MULT) 
			+ (point - DAMAGE_SCALING.TIER_1.CAP) * DAMAGE_SCALING.TIER_2.MULT
	else
		totalBonus = (DAMAGE_SCALING.TIER_1.CAP * DAMAGE_SCALING.TIER_1.MULT) 
			+ ((DAMAGE_SCALING.TIER_2.CAP - DAMAGE_SCALING.TIER_1.CAP) * DAMAGE_SCALING.TIER_2.MULT) 
			+ (point - DAMAGE_SCALING.TIER_2.CAP) * DAMAGE_SCALING.TIER_3.MULT
	end

	return totalBonus / 100
end

-- Tính toán Diminishing cho Thủ (END)
local function calculateDiminishingDR(point: number): number
	local drScore = 0

	if point <= ENDURANCE_SCALING.TIER_1.CAP then
		drScore = point * ENDURANCE_SCALING.TIER_1.MULT
	elseif point <= ENDURANCE_SCALING.TIER_2.CAP then
		drScore = (50 * 0.4) + (point - 50) * ENDURANCE_SCALING.TIER_2.MULT
	elseif point <= ENDURANCE_SCALING.TIER_3.CAP then
		drScore = (50 * 0.4) + (50 * 0.3) + (point - 100) * ENDURANCE_SCALING.TIER_3.MULT
	else
		drScore = ENDURANCE_SCALING.HARD_CAP -- Hard-cap tại 50%
	end

	return math.min(drScore, ENDURANCE_SCALING.HARD_CAP) / 100
end

------------------------------------------------------
-- PUBLIC API
------------------------------------------------------

-- [STRENGTH] Lấy % Bonus sát thương vật lý
function StatsCalculator.getStrengthBonus(point: number): number
	return calculateDiminishingDamage(point)
end

-- [ARCANE] Lấy % Bonus sát thương phép
function StatsCalculator.getArcaneBonus(point: number): number
	return calculateDiminishingDamage(point)
end

-- [ENDURANCE] Lấy chỉ số Thủ và Máu
function StatsCalculator.getEnduranceStats(point: number)
	return {
		MaxHPBonus = point * 15,
		DamageReduction = calculateDiminishingDR(point)
	}
end

-- [LUCK] Lấy chỉ số Chí mạng
function StatsCalculator.getLuckStats(point: number)
	return {
		CritChanceBonus = (point * 0.2) / 100,
		CritDamageBonus = math.floor(point / 2) * 0.01 
	}
end

-- [SPEED] Lấy chỉ số Né và Chặn
function StatsCalculator.getSpeedStats(point: number)
	return {
		EvasionBonus = (point * 1.6) / 100,
		BlockBonus = (point * 2.5) / 100
	}
end

-- [CORE] TÌM SÁT THƯƠNG ĐẦU RA (Tấn công)
-- Tính toán kết hợp giữa Skill, Vũ khí và Hệ số gốc
function StatsCalculator.CalculateOutputDamage(skillBasePower: number, statBonus: number, weaponBase: number, weaponBuff: number): number
    local rawDamage = ((skillBasePower + weaponBase) * (1 + statBonus)) * weaponBuff
    return math.round(rawDamage) -- Làm tròn để tránh máu lẻ tẻ
end

-- [CORE] CÔNG THỨC DAMAGE MODEL CHÍNH (Trừ trước - Nhân sau / Phòng thủ)
-- Dùng hàm này để tính sát thương cuối cùng nhận vào sau khi trừ giáp
function StatsCalculator.calculateFinalDamage(incomingDamage: number, defenderDefense: number, defenderDR: number): number
	-- Bước 1: Trừ thủ cố định
	local postDefenseDamage = math.max(0, incomingDamage - defenderDefense)
	
	-- Bước 2: Nhân giảm % (Damage Reduction)
	local finalDamage = postDefenseDamage * (1 - defenderDR)
	
	return math.round(finalDamage)
end

-- Lấy Tổng chỉ số sức mạnh cơ bản của nhân vật
function StatsCalculator.GetTotalStats(playerData, RaceRegistry)
    local finalStats = {}
    local raceName = playerData.Race
    local raceData = RaceRegistry[raceName]

    if not raceData then return playerData.Stats end -- Fallback nếu không tìm thấy tộc

    local statNames = {"STR", "ARC", "END", "SPD", "LCK"}
    
    -- Bảng ánh xạ từ viết tắt sang tên đầy đủ trong Passives
    local shortToFull = {
        STR = "Strength",
        ARC = "Arcane",
        END = "Endurance",
        SPD = "Speed",
        LCK = "Luck"
    }

    for _, stat in ipairs(statNames) do
        local invested = playerData.Stats[stat] or 0
        local base = raceData.BaseStats[stat] or 0
        
        local multiplier = 1
        local fullStatName = shortToFull[stat]
        local specificKey = fullStatName .. "Multiplier" 

        -- Duyệt qua các nội tại của chủng tộc
        for _, passiveEffect in pairs(raceData.Passives) do
            -- 1. Buff toàn bộ chỉ số (ví dụ: AllRounder 1.05x)
            if passiveEffect.StatMultiplier then
                multiplier *= passiveEffect.StatMultiplier
            end
            
            -- 2. Buff riêng cho chỉ số này (ví dụ: StrengthMultiplier)
            if passiveEffect[specificKey] then
                multiplier *= passiveEffect[specificKey]
            end
        end

        -- Công thức: (Cơ bản + Điểm cộng thêm) * Tổng hệ số nhân
        finalStats[stat] = (base + invested) * multiplier
    end
    
    return finalStats
end

return StatsCalculator