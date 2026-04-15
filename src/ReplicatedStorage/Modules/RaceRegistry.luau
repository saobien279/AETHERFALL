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
			["Aether Strike"] = { -- [cite: 389]
				UnlockLevel = 40,
				Cooldown = 6,
				BasePower = 15,
				Scaling = { STR = 1.0, ARC = 1.0 }, -- 100% Str/Arc [cite: 390]
				BaseMultiplier = 1.3,
				HighHPBonus = 1.2 -- x1.2 if enemy HP > 80% [cite: 392]
			}
		}
	},

	["Felorian"] = {
		Tier = "Common",
		SpawnRate = 0.60,
		BaseStats = { STR = 2, ARC = 1, END = 1, SPD = 4, LCK = 2 }, -- [cite: 417]
		Passives = {
			PredatorsInstinct = { SpeedMultiplier = 1.15, CritBonus = 0.05 }, -- +15% SPD, +5% Crit [cite: 414]
			FragileFrame = { MaxHPMultiplier = 0.85 } -- -15% Max HP [cite: 415]
		},
		Abilities = {
			["Prowl"] = { -- 
				UnlockLevel = 5,
				Cooldown = 5,
				NextTurnMultiplier = 1.5,
				DefensePierce = 0.25,
				Status = "Stealth"
			},
			["Burst Trap"] = { -- [cite: 409]
				UnlockLevel = 40,
				Cooldown = 5,
				Duration = 3,
				BasePower = 8,
				Scaling = { SPD = 0.8, LCK = 0.4 }, -- [cite: 410]
				Effects = {"Fire Counter", "Blind"} -- [cite: 412]
			}
		}
	},

	-- TIER 2: UNCOMMON (33%) [cite: 418]
	["Sylvani"] = {
		Tier = "Uncommon",
		SpawnRate = 0.33,
		BaseStats = { STR = 1, ARC = 4, END = 1, SPD = 3, LCK = 1 }, -- [cite: 436]
		Passives = {
			AetherSpirit = { SpeedMultiplier = 1.20, MagicDamageMultiplier = 1.15 }, -- [cite: 433]
			EtherealBody = { PhysDefMultiplier = 0.85, MaxHPMultiplier = 0.90 } -- [cite: 434]
		},
		Abilities = {
			["Wind's Grace"] = { -- [cite: 426]
				UnlockLevel = 5,
				Cooldown = 5,
				BasePower = 12,
				Scaling = { ARC = 0.9 }, -- [cite: 427]
				Status = "Stealth",
				Duration = 1
			},
			["Starfall Tempest"] = { -- [cite: 429]
				UnlockLevel = 40,
				Cooldown = 8,
				BasePower = 25,
				Scaling = { ARC = 1.3 }, -- [cite: 430]
				AoE = true,
				StunChance = 0.20,
				MDefShred = 0.85 -- Giảm xuống 0.85x [cite: 431]
			}
		}
	},

	["Kraghorn"] = {
		Tier = "Uncommon",
		SpawnRate = 0.33,
		BaseStats = { STR = 4, ARC = 1, END = 4, SPD = 0, LCK = 1 }, -- 
		Passives = {
			StoneSkin = { PhysDamageMultiplier = 1.20, MaxHPMultiplier = 1.15 }, -- [cite: 450]
			Heavyweight = { SpeedMultiplier = 0.80, MagicDamageTakenMultiplier = 1.15 } -- [cite: 451, 452]
		},
		Abilities = {
			["Bloodrage"] = { -- [cite: 445]
				UnlockLevel = 5,
				BaseBuff = 1.1,
				LowHPThreshold = 0.4,
				LowHPBuff = 1.2 -- HP < 40% [cite: 445]
			},
			["Seismic Slam"] = { -- [cite: 446]
				UnlockLevel = 40,
				Cooldown = 7,
				BasePower = 20,
				Scaling = { STR = 1.0, END = 0.3 }, -- [cite: 447]
				AoE = true,
				Status = "Cripple",
				SpeedDebuff = 0.8 -- Giảm còn 0.8x [cite: 448]
			}
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
			["Crimson Feast"] = { -- [cite: 464]
				UnlockLevel = 5,
				NextHitMultiplier = 1.15,
				HealFromDamage = 0.15
			},
			["Void Assassination"] = { -- [cite: 465]
				UnlockLevel = 40,
				Cooldown = 6,
				BasePower = 30,
				Scaling = { STR = 1.6, ARC = 1.6 }, -- [cite: 466]
				IgnoreShield = true,
				DoTMultiplier = 1.25 -- x1.25 if enemy has DoT [cite: 467]
			}
		}
	},

	-- TIER 4: EPIC (1%) [cite: 475]
	["Drakari"] = {
		Tier = "Epic",
		SpawnRate = 0.01,
		BaseStats = { STR = 4, ARC = 3, END = 4, SPD = 1, LCK = 0 }, -- 
		Passives = {
			Dragonblood = { MaxHPMultiplier = 1.15, DefMultiplier = 1.15, AllDamageMultiplier = 1.25, FireImmune = true }, -- [cite: 492, 493]
			HeavyToll = { SpeedMultiplier = 0.85, CooldownPenalty = 1 } -- +1 Cooldown [cite: 494, 495]
		},
		Abilities = {
			["Dragon's Breath"] = { -- [cite: 483]
				UnlockLevel = 10,
				Cooldown = 8,
				BasePower = 18,
				Scaling = { STR = 1.0, ARC = 1.0 }, -- [cite: 484]
				AoE = true,
				Status = "Burn",
				BurnDamage = 0.04 -- 4% Max HP/turn [cite: 485]
			},
			["Imperial Dragon Realm"] = { -- [cite: 486]
				UnlockLevel = 40,
				Cooldown = 15,
				Duration = 5,
				DamagePerTurn = 10,
				Scaling = { ARC = 0.4 }, -- [cite: 488]
				HealBoost = 1.2,
				Mulligan = { HPRecover = 0.20, Status = "Immortal" } -- 
			}
		}
	}
}

return RaceRegistry