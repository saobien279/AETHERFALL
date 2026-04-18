local RaceRegistry = {
	-- TIER 1: COMMON (60%)
	["Aetherian"] = {
		Tier = "Common",
		SpawnRate = 0.60,
		BaseStats = { STR = 2, ARC = 2, END = 2, SPD = 2, LCK = 2 }, -- [cite: 398]
		Passives = {
			FastLearner = { ExpBonus = 0.10 }, -- +10% EXP [cite: 394]
			AllRounder = { StatMultiplier = 1.05 }, -- +5% All Stats [cite: 395]
			Adaption = { UnlockLevel = 5, DamagePerTurn = 0.01, MaxMultiplier = 1.10 } -- [cite: 388]
		},
		Abilities = {
			"Aether Strike"
		}
	},

	["Felorian"] = {
		Tier = "Common",
		SpawnRate = 0.60,
		BaseStats = { STR = 2, ARC = 1, END = 1, SPD = 4, LCK = 2 }, -- [cite: 417]
		Passives = {
			PredatorsInstinct = { SpeedMultiplier = 1.15, LuckMultiplier = 1.05 }, -- Đã đổi CritBonus thành LuckMultiplier để đồng bộ
            FragileFrame = { MaxHPMultiplier = 0.85 }
		},
		Abilities = {
			"Prowl",
			"Burst Trap"
		}
	},

	-- TIER 2: UNCOMMON (33%) [cite: 418]
	["Sylvani"] = {
		Tier = "Uncommon",
		SpawnRate = 0.33,
		BaseStats = { STR = 1, ARC = 4, END = 1, SPD = 3, LCK = 1 }, -- [cite: 436]
		Passives = {
			AetherSpirit = { SpeedMultiplier = 1.20, ArcaneMultiplier = 1.15 }, -- Đã đổi MagicDamage thành ArcaneMultiplier
            EtherealBody = { EnduranceMultiplier = 0.85, MaxHPMultiplier = 0.90 } -- PhysDef dựa trên END nên dùng EnduranceMultiplier
		},
		Abilities = {
			"Wind's Grace",
			"Starfall Tempest"
		}
	},

	["Kraghorn"] = {
		Tier = "Uncommon",
		SpawnRate = 0.33,
		BaseStats = { STR = 4, ARC = 1, END = 4, SPD = 0, LCK = 1 }, -- 
		Passives = {
			DarkVitality = { StrengthMultiplier = 1.15, ArcaneMultiplier = 1.15, BasicLifesteal = 0.05 }, -- Tách AllDamage thành STR và ARC
            VoidCurse = { HealingReceivedMultiplier = 0.5, FireDamageTakenMultiplier = 1.25 }
		},
		Abilities = {
			"Bloodrage",
			"Seismic Slam"
		}
	},

	-- TIER 3: RARE (6%) [cite: 455]
	["Nyxborn"] = {
		Tier = "Rare",
		SpawnRate = 0.06,
		BaseStats = { STR = 3, ARC = 3, END = 2, SPD = 1, LCK = 1 }, -- [cite: 473, 474]
		Passives = {
			DarkVitality = { AllDamageMultiplier = 1.15, BasicLifesteal = 0.05 }, -- [cite: 469, 470]
			VoidCurse = { HealingReceivedMultiplier = 0.5, FireDamageTakenMultiplier = 1.25 } -- [cite: 471, 472]
		},
		Abilities = {
			"Crimson Feast",
			"Void Assassination"
		}
	},

	-- TIER 4: EPIC (1%) [cite: 475]
	["Drakari"] = {
		Tier = "Epic",
		SpawnRate = 0.01,
		BaseStats = { STR = 4, ARC = 3, END = 4, SPD = 1, LCK = 0 }, -- 
		Passives = {
			Dragonblood = { 
                EnduranceMultiplier = 1.15, 
                StrengthMultiplier = 1.25, 
                ArcaneMultiplier = 1.25, 
                FireImmune = true 
            }, -- Tách AllDamage thành STR/ARC
            HeavyToll = { SpeedMultiplier = 0.85, CooldownPenalty = 1 }
		},
		Abilities = {
			"Dragon's Breath",
			"Imperial Dragon Realm"
		}
	}
}

return RaceRegistry