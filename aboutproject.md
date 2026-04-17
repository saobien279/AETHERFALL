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

    *(Hiện tại chưa có)*

    ---

    ## 10. Danh mục UI, Model & Event (Lưu trực tiếp trong Roblox)

    > Các đối tượng dưới đây được xây dựng và chỉnh sửa trực tiếp bên trong Roblox Studio. Bảng dưới đây cung cấp chính xác cấu trúc Cây Hierarchy (Cha-Con) theo thực tế để AI Agent gọi bằng code (VD: `WaitForChild()`).

    ### 10.1. Hệ thống Giao diện (UI) - Nằm trong `StarterGui` (hoặc `PlayerGui`)
    *(Chưa có thông tin - Đang chờ người dùng cung cấp)*

    ### 10.2. Hệ thống Model & Part - Nằm trong `Workspace`
    *(Chưa có thông tin - Đang chờ người dùng cung cấp)*

    ### 10.3. Hệ thống Events - Nằm trong `ReplicatedStorage`

    **📡 `ReplicatedStorage`**:
    - ↳ **`Events`** (Folder) - Thư mục chứa tất cả RemoteEvent dùng cho Client-Server Communication.
      - ↳ `ActionHandle` (RemoteEvent) - Xử lý thông tin khi click vào các nút hành động (Đang chờ Rework).
      - ↳ `CombatEvents` (RemoteEvent) - Quản lý các event khác liên quan đến cơ chế Turn-based.

    *(Lưu ý của User: Các Agent KHÔNG ĐƯỢC đọc code cũ trong `TurnbaseCore.server.luau` hoặc các Remote Event liên quan trực tiếp đến `ActionMenu` hay `ActionHandle` theo yêu cầu của User trong đợt rework tiếp theo).*

    ---

    ## 12. Phân loại Loại Sát thương (Damage Types)
    Mọi kỹ năng và đòn tấn công trong game đều được rẽ nhánh để chịu sự ảnh hưởng của chỉ số phòng thủ tương đối thông qua hệ thống `DamageType`.

    ### ⚔️ Sát thương Vật lý (Physical)
    *Đặc điểm: Bị giảm trừ triệt để bởi chỉ số T.DEF (P.DEF) từ Giáp trụ và sức chịu đựng.*
    - **Aether Strike** (Aetherian): Dù bọc năng lượng nhưng bản chất là một cú đấm dồn lực.
    - **Seismic Slam** (Kraghorn): Dùng sức mạnh cơ bắp thuần túy để giậm chấn động đất.
    - **Void Assassination** (Nyxborn): Đâm từ hư không, dùng ARC dịch chuyển nhưng lưỡi dao là vật lý.
    - **Crimson Feast** (Nyxborn) & **Bloodrage** (Kraghorn): Cường hóa thân thể/vũ khí, chém ra đòn vật lý.

    ### 🔮 Sát thương Ma pháp (Magical)
    *Đặc điểm: Bị giảm trừ bởi chỉ số Kháng Phép (M.DEF) từ Áo choàng/Phụ kiện.*
    - **Burst Trap** (Felorian): Thuốc súng và bột lửa Aether bùng nổ, mang đặc tính nguyên tố.
    - **Wind's Grace** (Sylvani): Nhát cắt cấu hành từ luồng gió ma thuật.
    - **Starfall Tempest** (Sylvani): Năng lượng tinh tú gọi thiên thạch giáng xuống.
    - **Dragon's Breath** (Drakari): Hỏa thuật từ loài rồng thuần chủng nguyên tố Fire.
    - **Imperial Dragon Realm** (Drakari): Lãnh địa thiết lập bằng quyền năng ma pháp cổ xưa.

    ---

    ## 13. Cơ chế Tính Sát Thương: Dual Scale & Generic Scaling
    
    ### Dual Scaling (Sức mạnh Song hành)
    Khi một kỹ năng quy định scaling dựa trên 2 chỉ số (VD: `STR = 1.6, ARC = 1.6` của Void Assassination). Hệ thống sẽ chạy công thức tính phần trăm Buff của riêng từng loại chỉ số, và so sánh. Tỷ lệ phần trăm nào quy ra con số khổng lồ hơn, sẽ được hệ thống ưu tiên lựa chọn. **Nhân vật không được cộng dồn cả 2, mà chỉ sử dụng thế mạnh lớn nhất của mình**.
    
    ### Generic Stat Damage Scaling (Các nhánh làm sát thương Phụ)
    STR và ARC có chỉ số Diminishing Return chuyên sâu (Logarithm/Ngưỡng chặn). Tuy nhiên để tránh lạm phát sức mạnh khi dùng `SPD`, `LCK` hay `END` để tính sát thương thô, hệ thống thống nhất một kẹp toán học để cân bằng:
    - 1 Điểm `SPD/LCK/END` = **Tăng 0.5% Sát Thương (0.005)**.
    - **Ngưỡng chặn khẩn cấp (Hard Cap):** Dù cộng tới 1000 điểm, phần trăm buff cộng thêm sẽ khựng lại ở mức tối đa là **150% (1.5)** ngang với ngưỡng trần của STR.

    ---

    ## 11. Hệ thống Trang bị (Equipment & Gear Triggers)

    > Hệ thống Trang bị là mảnh ghép cuối để hoàn thiện sức mạnh nhân vật, với cơ chế kích hoạt (Trigger) xử lý trong Combat Engine.

    ### 11.1. Phân loại Trang bị Chính (Core Equipment)
    | Loại | Đặc điểm / Chức năng | Cơ chế tác động |
    |------|----------------------|-----------------|
    | **Giáp Trụ (Armor)** | Mặc nguyên bộ (Full set), định hình lối chơi chịu đòn hoặc né tránh. | Cung cấp P.DEF và M.DEF. Giáp Nặng giảm Speed, Giáp Nhẹ tăng Tốc/Né. |
    | **Vũ Khí (Weapon)** | Đại diện cho phương thức chiến đấu của Superclass. | Cộng thẳng vào Base Damage (Damage gốc) của kỹ năng, thêm hệ số % Buff DMG. Có nội tại riêng. |
    | **Thánh Di Vật (Artifact)** | Món đồ quý hiếm cấp độ cổ đại. | Mở khóa các Active/Passive siêu việt mà Race/Class không có (VD: Quay ngược thời gian). |

    ### 11.2. Hệ thống Phụ Kiện (4 Gear Slots) - Xử lý theo Event-Driven
    Các slot phụ kiện không cộng thụ động vào Base Stats mà hoạt động dựa trên các khoảnh khắc (Trigger) trong trận chiến:

    - **Slot 1: Offensive Trigger (Kích hoạt khi Tấn công)**
      - **Logic Check:** Nằm trong hàm `DealDamage()`
      - **Ví dụ:** *Lõi Nhiệt* (Bạo kích gây thêm 30% sát thương Fire), *Kiếm Cưa* (Đánh thường có 10% chảy máu).
    - **Slot 2: Defensive Trigger (Kích hoạt khi Phòng thủ)**
      - **Logic Check:** Nằm trong hàm `TakeDamage()` hoặc `CheckEvade()`
      - **Ví dụ:** *Khiên Phản* (Chặn thành công phản sát thương), *Giày Lông Vũ* (Né thành công nhận vội 15% SPD lượt tới).
    - **Slot 3: Threshold Trigger (Kích hoạt theo ngưỡng Máu/Năng lượng)**
      - **Logic Check:** Nằm ở mọi hàm làm thay đổi HP/Energy (`OnResourceChanged()`)
      - **Ví dụ:** *Hơi Thở Cuối* (HP < 30% tăng 50% Crit), *Ý Chí Thép* (HP 100% giảm 20% Cooldown).
    - **Slot 4: Special Active (Kỹ năng chủ động từ Vật phẩm/Gadget)**
      - **Logic Check:** Nằm trong khối xử lý Skill (`CanUseSkill`, `ExecuteItem`)
      - **Ví dụ:** *Bom Khói* (Tàng hình 1 lượt cấm chỉ định), *Bình Thanh Tẩy* (Xóa toàn bộ Debuff).