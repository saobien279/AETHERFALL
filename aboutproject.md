    # ⚔️ AETHERFALL — Core Gameplay Design

    > Tài liệu này mô tả các cơ chế gameplay cốt lõi của AETHERFALL để các Agent AI sau này hiểu ngữ cảnh game khi viết code.

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

    ## 8. Mô Hình Tính Toán Sát Thương (Damage Model)

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

    ---

    ## 4. Hệ thống Chủng tộc (Race System)

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

    ## 5. Hệ thống Cấp bậc Trận chiến (Encounter Tier)

    > Độ khó và số lượng quái dựa trên Level người chơi (Normal Mode).

    | Tier | Level yêu cầu | Mô tả |
    |------|--------------|-------|
    | Tier 1 | Lvl 1–9 | 1 Enemy |
    | Tier 3 | Lvl 15–19 | 3 Enemy thường **hoặc** 1 Thường + 1 Mạnh |
    | Tier 6 | Party Only (Lvl 25+) | Quái cực mạnh, phần thưởng cao cấp |

    ---

    ## 6. Hiệu ứng Trạng thái (Status Effects)

    ### DoT (Damage over Time)
    - **Poison**: Sát thương cố định mỗi lượt.
    - **Fire**: 1% Max HP mỗi lượt + giảm hồi máu.
    - **Bleed**: Sát thương theo STR của người tấn công.

    ### Debuff
    - **Sunder**: -25% DEF.
    - **Blind**: +25% tỷ lệ hụt đòn.
    - **Silence**: Không thể dùng kỹ năng.
    - **Stun**: Mất lượt.

    ### Buff
    - **Shield**: Giáp ảo theo HP.
    - **Stealth**: Không bị nhắm mục tiêu đơn.
    - **Thorns**: Phản 20% sát thương nhận vào.

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

    ## 9. Current Work In Progress (Session Memos)

    - **Hệ thống Stats**: Đang xử lý hàm `StatsCalculator.GetTotalStats`. Logic đang tập trung tính tổng số liệu bằng cách cộng `BaseStats` của nhân vật theo `Race` từ `RaceRegistry` và chỉ số người chơi tự nâng (`invested` point). Đồng thời, đang thiết kế cách áp dụng `Passives` (nội tại tộc), bao gồm buff cho toàn bộ chỉ số (`StatMultiplier` từ `AllRounder`) và buff cho từng chỉ số cụ thể (như `SpeedMultiplier`, `StrengthMultiplier`). *Lưu ý: Đoạn code này đang dở dang (chưa done), không tự ý sửa đổi nếu không có yêu cầu.*