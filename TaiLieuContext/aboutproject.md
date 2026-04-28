# ⚔️ AETHERFALL — Core Gameplay Design

> Tài liệu này mô tả các cơ chế gameplay cốt lõi của AETHERFALL để các Agent AI sau này hiểu ngữ cảnh game khi viết code.
> Sơ đồ cây thư mục code và API chi tiết nằm tại `guide.md`.

---

## 1. Hệ thống Lượt đánh (Turn-Based Combat)

- **Thứ tự**: Player ↔ Enemy theo vòng lặp.
- **Hành động mỗi lượt**: Người chơi chọn **một** trong các lệnh:

| Lệnh | Mô tả |
|------|-------|
| **Attack** | Tấn công thường |
| **Skill** | Dùng kỹ năng (tốn Energy) |
| **Block** | Phòng thủ |
| **Item** | Dùng vật phẩm |
| **Meditate** | Hồi +1 Energy, nhưng nhận thêm 25% sát thương lượt đó |
| **Retreat** | Rút lui khỏi trận |

---

## 2. Hệ thống Năng lượng (Energy System)

- **Tối đa**: 6 Energy.
- **Tiêu thụ**: Kỹ năng tốn từ 1–6 Energy tùy loại.
- **Hồi phục**: Dùng lệnh **Meditate** → +1 Energy, nhưng nhận thêm 25% sát thương lượt đó.

---

## 3. Chỉ số & Công thức (Stats & Scaling)

Hệ thống dùng cơ chế **Diminishing Returns** (Càng nâng cao, hiệu quả tăng thêm càng giảm) để tránh mất cân bằng ở cuối game.

### Chỉ số chính (Core Stats)

| Stat | Chức năng | Cơ chế Scaling |
|------|-----------|----------------|
| **STR** | Tăng Physical Damage | Diminishing (1.3% → 1% → 0.7%) |
| **ARC** | Tăng Magic Damage | Diminishing (1.3% → 1% → 0.7%) |
| **END** | Thủ & Máu | Giảm sát thương (Hard-cap 50%) + Tăng 15 HP/điểm |
| **SPD** | Tốc độ & Né | 1.6% Né / 2.5% Chặn / Giảm độ khó QTE |
| **LCK** | May mắn | 0.2% Crit Chance / 0.01x Crit Damage (mỗi 2 điểm) |

### Chi tiết Diminishing Returns

#### Cho STR và ARC (Sát thương)
- **Bậc 1 (0–40):** +1.3% mỗi điểm.
- **Bậc 2 (40–80):** +1.0% mỗi điểm.
- **Bậc 3 (80+):** +0.7% mỗi điểm.

#### Cho END (Giảm sát thương - Damage Reduction)
- **0–50:** +0.4% / điểm (Tối đa 20%).
- **50–100:** +0.3% / điểm (Tối đa thêm 15% → Tổng 35%).
- **100–200:** +0.15% / điểm (Tối đa thêm 15% → Tổng 50%).
- **200+:** **0%** (Hard-cap tại 50%). *Lưu ý: Sau mốc này END chỉ tăng mạnh HP.*

---

## 4. Mô Hình Tính Toán Sát Thương (Damage Model)

Dự án sử dụng cơ chế **"Trừ trước - Nhân sau"** để đảm bảo chỉ số phòng thủ luôn có giá trị.

### Công thức Sát thương Đầu ra (Output)
- **Vật lý:** `Damage = Base x (1 + STR%)`
- **Phép thuật:** `Magic Damage = Skill_Base x (1 + ARC%)`

### Công thức Sát thương Thực tế (Mitigation)
`Sát_thương_nhận_vào = (Sát_thương_đầu_ra - Phòng_thủ_cố_định) x (1 - %_Giảm_sát_thương)`

**Ví dụ minh họa:**
1. Kẻ địch gây **100** sát thương.
2. Bạn có **20** Defense (Phòng thủ cố định).
3. Bạn có **30%** Damage Reduction (từ END).
4. **Bước 1:** `100 - 20 = 80`.
5. **Bước 2:** `80 x (1 - 0.3) = 56`.
6. **Kết quả:** Bạn nhận **56** sát thương.

### Dual Scaling (Sức mạnh Song hành)
Khi một kỹ năng quy định scaling dựa trên 2 chỉ số (VD: `STR = 1.6, ARC = 1.6` của Void Assassination). Hệ thống sẽ so sánh % Buff của từng chỉ số, chọn con số lớn hơn. **Không cộng dồn, chỉ sử dụng thế mạnh lớn nhất**.

### Generic Stat Damage Scaling
Để tránh lạm phát khi dùng `SPD`, `LCK`, `END` làm sát thương:
- 1 Điểm = **+0.5% Sát Thương (0.005)**.
- **Hard Cap:** Tối đa **150% (1.5)** — ngang trần của STR.

---

## 5. Hệ thống Chủng tộc (Race System)

Mỗi chủng tộc có **Base Stats**, **Passive (Nội tại)**, và **Racial Ability (Kỹ năng chủng tộc)** riêng.

| Chủng tộc | Tier | Ưu điểm | Nhược điểm |
|-----------|------|---------|------------|
| **Aetherian** | Common | Thích nghi (tăng DMG theo hiệp), +10% EXP | Không |
| **Felorian** | Common | +15% SPD; Crit chắc chắn khi phá Tàng hình | -15% Max HP |
| **Sylvani** | Uncommon | +15% Magic DMG, +20% SPD | -15% DEF Vật lý, -10% HP |
| **Kraghorn** | Uncommon | +20% Phys DMG, +15% HP; Buff thủ dưới 40% HP | -20% SPD, +15% nhận DMG Phép |
| **Nyxborn** | Rare | +15% All DMG; 5% Hút máu mặc định | -50% hồi máu từ Healer, +25% DMG Lửa |
| **Drakari** | Epic | +25% All DMG; Miễn nhiễm Lửa; AoE Thiêu đốt | -15% SPD, +1 lượt Cooldown mọi kỹ năng |

---

## 6. Hệ thống Cấp bậc Trận chiến (Encounter Tier)

> Độ khó và số lượng quái dựa trên Level người chơi (Normal Mode).

| Tier | Level yêu cầu | Mô tả |
|------|--------------|-------|
| Tier 1 | Lvl 1–9 | 1 Enemy |
| Tier 3 | Lvl 15–19 | 3 Enemy thường **hoặc** 1 Thường + 1 Mạnh |
| Tier 6 | Party Only (Lvl 25+) | Quái cực mạnh, phần thưởng cao cấp |

---

## 7. Hệ thống Lớp nhân vật (Class System)

Gồm **Base Class** và 3 nhánh **Superclass**:
- ☀️ **Orderly**
- 🌀 **Neutral**
- 🩸 **Chaos**

| Base Class | Vũ khí | Vai trò |
|------------|--------|---------|
| **Vanguard** | Shield | Tank thuần, bảo vệ đồng đội |
| **Aether Swordsman** | Sword | Melee DPS, linh hoạt |
| **Aether Scholar** | Staff | AoE Magic DPS |
| **Rogue** | Dagger | Single-target DPS, ưu tiên tốc độ |
| **Aether Acolyte** | Wand | Hỗ trợ / Hồi máu |

---

## 8. Phân loại Loại Sát thương (Damage Types)

Mọi kỹ năng đều được rẽ nhánh để chịu ảnh hưởng của chỉ số phòng thủ tương ứng.

### ⚔️ Sát thương Vật lý (Physical)
*Bị giảm trừ bởi P.DEF.*
- **Aether Strike** (Aetherian), **Seismic Slam** (Kraghorn), **Void Assassination** (Nyxborn), **Crimson Feast** (Nyxborn), **Bloodrage** (Kraghorn).

### 🔮 Sát thương Ma pháp (Magical)
*Bị giảm trừ bởi M.DEF.*
- **Burst Trap** (Felorian), **Wind's Grace** (Sylvani), **Starfall Tempest** (Sylvani), **Dragon's Breath** (Drakari), **Imperial Dragon Realm** (Drakari).

---

## 9. Hệ thống Trang bị (Equipment & Gear Triggers)

### 9.1. Phân loại Trang bị Chính

| Loại | Chức năng | Cơ chế |
|------|-----------|--------|
| **Vũ Khí (Weapon)** | Base Damage + Buff % | Tra cứu tại `EquipmentRegistry.Weapons` |
| **Giáp Trụ (Armor)** | P.DEF + M.DEF | Tra cứu tại `EquipmentRegistry.Armors` |
| **Thánh Di Vật (Artifact)** | Active/Passive siêu việt | Tra cứu tại `EquipmentRegistry.Artifacts` (chưa implement) |

### 9.2. Danh mục Vũ Khí

| ID | Base DMG | Buff |
|---|---|---|
| `LowFinSword` | 7 | Không |
| `FinSword` | 10 | +5% DMG |

### 9.3. Danh mục Giáp

| ID | P.DEF | M.DEF | Speed |
|---|---|---|---|
| `RecruitLeathers` | 10 | 5 | 0 |
| `IronPlate` | 20 | 0 | 0 |
| `ScholarRobe` | 0 | 20 | 0 |
| `ScoutGarb` | 5 | 5 | +5 |
| `HeavyStoneMail` | 25 | 10 | -10 |

### 9.4. Hệ thống Phụ Kiện (4 Gear Slots)

Hoạt động dựa trên **Trigger** trong trận chiến, không cộng thụ động:

| Slot | Trigger | Ví dụ | Logic Check |
|---|---|---|---|
| **Slot 1: Offensive** | Khi tấn công | Whetstone (Crit +30%), SparkPlug (15% Burn) | `DealDamage()` |
| **Slot 2: Defensive** | Khi chịu đòn | SpikedBracers (Phản đòn), GhostlyVeil (Né → Tàng hình) | `TakeDamage()` |
| **Slot 3: Threshold** | Ngưỡng HP | BerserkerHeart (HP<30% buff), GuardianShell (Shield 15%) | `UpdateHP()` |
| **Slot 4: Active** | Chủ động dùng | FlashBang (Choáng, CD 8), PurityFlask (Xóa Debuff, CD 6) | `CanUseSkill()` |

### 9.5. Thánh Di Vật (Artifacts) — Thiết kế, chưa implement

- **Chrono-Amber**: Quay ngược trạng thái HP/Mana về 1 hiệp trước. *CD: 10 lượt*.
- **Void Summoner's Bell**: Triệu hồi lính canh 20% chỉ số chủ nhân, 3 hiệp. *CD: 12 lượt*.
- **Aurelion's Lens**: Đòn tiếp theo Crit chắc + Xuyên 100% DEF. *CD: 8 lượt*.

---

## 10. Hiệu ứng Trạng thái (Status Effects)

### 🩸 DoT (Sát thương theo thời gian)
*Gây sát thương ở ĐẦU lượt mục tiêu. Mỗi lượt trừ 1 Stack.*

| Hiệu ứng | Cơ chế |
|---|---|
| **Poison** | Sát thương cố định × số Stack |
| **Fire** | 1% Max HP/lượt + giảm 20% hồi máu |
| **Bleed** | Sát thương theo STR người cast (Snapshot) |

### 📉 Debuff (Bất lợi chỉ số)

| Hiệu ứng | Cơ chế |
|---|---|
| **Sunder** | -25% DEF |
| **Vulnerable** | +25% DMG nhận (không khuếch đại DoT) |
| **Blind** | +25% tỷ lệ hụt đòn |
| **Decay** | Mọi hồi máu bị ép về 0 |
| **Cripple** | Không thể Flee hoặc đổi vị trí |

### ⛓️ Khống chế (Crowd Control)

| Hiệu ứng | Cơ chế |
|---|---|
| **Stun** | Bỏ qua 1 lượt |
| **Silence** | Chỉ được đánh thường |
| **Taunt** | Bắt buộc nhắm vào người Taunt |

### 🛡️ Buff & Đặc biệt

| Hiệu ứng | Cơ chế |
|---|---|
| **Shield** | Khiên ảo theo HP. Tối đa 5 lượt, không cộng dồn |
| **Stealth** | Không bị nhắm Single-target |
| **Thorns** | Phản 20% DMG nhận |
| **Immunity** | Vô hiệu mọi Debuff/CC |

---

## 11. Trí Tuệ Nhân Tạo Quái Vật (Monster AI & Registry)

Quái vật đọc từ **EnemyRegistry** (không dùng DataTemplate). AI sử dụng **Weight-based Selection (Roulette Wheel)**.

### Cấu trúc EnemyRegistry
```luau
Skillset = {
    {Name = "Fireball", Weight = 60},
    {Name = "Normal Attack", Weight = 40}
}
```

### Cơ chế MonsterAI
1. Tính Tổng tỷ lệ (Total Weight).
2. Xổ số (`math.random`) bốc trúng 1 kỹ năng.
3. `SkillProcessor.CanUseSkill()` xét duyệt. Nếu xịt → loại và quay lại. `"Normal Attack"` luôn là lưới an toàn.

---

## 12. Hệ Thống Chạm Trán (Encounter & Battle Transition)

Hệ thống JRPG Encounter dùng **`CollectionService`** để quản lý hàng nghìn quái.

### Kiến Trúc "Đạp Mìn" (EncounterManager)
- Quái mang Part tàng hình gắn Tag `"EncounterZone"`.
- `EncounterManager` (Server) tự động quét Tag và gắn `Touched`.
- Khi đạp: Lấy ID quái → `Destroy` mìn → Khóa chân → `PivotTo()` cách quái 15 studs.

### Cinematic Transition
- **Server**: `CombatEvents:FireClient("FadeToBlack")` → `task.wait(1.5)` → `StartEncounterEvent:Fire()`.
- **Client**: `CinematicUIController` vẽ màn đen bằng code, Tween rèm xuống 0.5s → tối 0.5s → sáng 0.5s.

---

## 13. Danh mục UI, Model & Event (Lưu trong Roblox Studio)

> Chi tiết cây thư mục code và API xem tại `guide.md`. Dưới đây chỉ liệt kê các Object vật lý cần biết.

### Model & Part (Workspace)
- **`WildSlime`** (Model)
  - `EncounterZone` (Part - Tag `EncounterZone`)
  - `SlimePart` (Part)
  - `HeathBar` (BillboardGui) → `BackGroundBar` → `Bar` + `TextLabel`

### Events (ReplicatedStorage/Events)
| Tên | Loại | Chức năng |
|---|---|---|
| `ActionMenuEvent` | RemoteEvent | Client gửi `skillID` lên Server |
| `CombatEvents` | RemoteEvent | Server gửi UpdateHP, FadeToBlack xuống Client |
| `StartEncounterEvent` | BindableEvent | Cáp ngầm Server: EncounterManager → BattleServer |

### UI (StarterGui)
| Tên | Cấu trúc |
|---|---|
| **ActionMenu** | Chứa `AttackBtn` |
| **Heath** | Chứa `Frame` → `FillBar` |
