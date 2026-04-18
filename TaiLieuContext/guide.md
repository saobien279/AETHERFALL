# 🗺️ AETHERFALL - LẬP TRÌNH API & GUIDE

> **Cẩm nang Code (Dành cho AI & Người phát triển)**
> File này lưu trữ vị trí của toàn bộ các File cấu trúc, chức năng hàm, và đặc biệt là Sơ đồ móc nối tới hệ thống UI/Part lưu trên Roblox Studio mà Code không thể tự nhìn thấy.

---

## 1. CÂY THƯ MỤC LƯU TRỮ VẬT LÝ CHIẾU TRÊN ROBLOX STUDIO

Do AI không có khả năng quan sát không gian 3D và giao diện trực tiếp trên Roblox, bất kỳ dòng code UI/Part nào muốn trỏ tới đúng mục tiêu đều bắt buộc phải tham chiếu **Tuyệt đối** theo cây đồ thị (Hierarchy) dưới đây (Sử dụng `WaitForChild()` để truy cập):

### 📺 StarterGui (Hệ thống Menu / Giao diện chiến đấu)
*(Chưa cập nhật thông tin: Đang chờ User cung cấp cấu trúc CombatScreen, HealthBar, Button...)*

### 📡 ReplicatedStorage (Giao thức mạng)
- `Events/ActionMenuEvent` **[RemoteEvent]**: Đường truyền tín hiệu để UI ném tên thủ thuật (`skillID`) chọc ngoáy lên Máy Chủ xử lý lượt tính máu.

### 🌍 Workspace (Hệ thống Vật thể / Sàn đấu 3D)
*(Chưa cập nhật thông tin: Đang chờ User cung cấp cấu trúc Monster Model, Battle Arena...)*

---

## 2. TỪ ĐIỂN API & KIẾN TRÚC MODULES (`src/ReplicatedStorage/Modules/`)

Toàn bộ Backend lõi của game hiện đang được chia thành 4 Tầng cấu trúc độc lập. Dưới đây là các hàm bạn có thể gọi:

### 📁 TÀI LIỆU TẦNG CORE (Lõi vận hành trận đấu)
**1. Tệp `CombatManager.luau`**
*Loại File: Chứa các hàm xử lý Vòng lặp đấm đá, chịu đòn và sụt máu.*
- `CombatManager.UpdateHP(entity: table, amount: number)`
  - **Truyền vào:** `entity` (Một thực thể sống sinh ra từ EntityManager) và `amount` (Số máu cộng thêm hoặc nhận sát thương).
  - **Trả về (`return`):** Trả về `number` (Là CurrentHP còn lại).
  - **Nhiệm vụ:** Cộng/trừ máu an toàn với tính năng Kẹp trần `math.clamp` không cho máu quá MaxHP hoặc tụt âm. Check và vứt hàm `IsDead = true`.
- `CombatManager.TakeDamage(defender: table, incomingDamage: number, damageType: string)`
  - **Truyền vào:** Kẻ chịu đòn (`defender`), Sát thương đầu vào thô (`incomingDamage`), và Hệ Sát Thương `damageType` (Là chữ `"Physical"` hoặc `"Magical"`).
  - **Trả về (`return`):** `nil`.
  - **Nhiệm vụ:** Tìm áo Giáp của phe thủ để lấy `P_DEF`/`M_DEF` tương ứng với `damageType`. Gọi hàm `FinalDamage` và sau đó đem cục máu cuối cùng đẩy cho `UpdateHP` trừ.
- `CombatManager.DealDamage(attacker: table, defender: table, skillID: string)`
  - **Truyền vào:** Kẻ đánh (`attacker`), Kẻ thủ (`defender`) và Tên chiêu thức (`skillID`).
  - **Trả về (`return`):** `nil`.
  - **Nhiệm vụ:** Hàm khởi nguồn. Tra cứu Kỹ năng + Scale Vũ khí + Tính Dual-Scales / Diminishing Returns, sau đó đẩy đống Data Damage này vứt sang cho nhánh `TakeDamage`.

**2. Tệp `EntityManager.luau`**
*Loại File: Chứa các hàm liên quan đến nhào nặn thân thể thực thể trận đánh.*
- `EntityManager.New(playerData: table, RaceRegistry: table)`
  - **Truyền vào:** Dữ liệu cấp bậc/tộc hiện tại của người chơi (`playerData`) từ DataTemplate và biến môi trường `RaceRegistry`.
  - **Trả về (`return`):** Trả về một **Bảng `table` Entity hoàn chỉnh** gồm có `{Name, Race, MaxHP, CurrentHP, Energy, IsDead, Stats, DamageReduction, StatusEffects}`.
  - **Nhiệm vụ:** Sinh ra một con cờ (Thực thể) hoàn thiện có gắn máu dâng theo END và chứa toàn bộ Trạng thái trước khi thảy nó lên sàn đấu.

### 📁 TÀI LIỆU TẦNG UTILS (Hỗ trợ Tính toán)
**Tệp `StatsCalculator.luau`**
- `StatsCalculator.GetTotalStats(playerData: table, RaceRegistry: table)`
  - **Truyền vào:** Hồ sơ nhân vật `playerData`.
  - **Trả về (`return`):** `table` (Trả ra 5 dòng Point nguyên bản: `STR`, `ARC`, `END`, `SPD`, `LCK` sau khi cộng thưởng bị động từ Tộc).
- `StatsCalculator.CalculateOutputDamage(skillBase: number, statBonus: number, weaponBase: number, weaponBuff: number)`
  - **Truyền vào:** Sát thương gốc Skill, Hệ số Buff chỉ số %, Sát thương gốc Vũ khí, Phép chấn Vũ khí %.
  - **Trả về (`return`):** `number` (Sát thương Thô).
- `StatsCalculator.calculateFinalDamage(incomingDamage: number, defenderDefense: number, defenderDR: number)`
  - **Truyền vào:** Máu gốc trước đánh, Chỉ số Thủ của Giáp, % Giảm sát thương.
  - **Trả về (`return`):** `number` (Sát thương Máu thật qua kẹp làm tròn).

### 📁 TÀI LIỆU TẦNG DATA & REGISTRIES (Chỉ lưu trữ tĩnh)
- `DataTemplate.luau`: Tệp nháp Inventory/Stats nhân vật lúc NewGame. Không có Hàm.
- `SkillRegistry.luau`: Chứa định nghĩa `BasePower`, `DamageType`, Cost.
- `RaceRegistry.luau`: Chứa các hệ số Buff chủng tộc `Passives`.
- `EquipmentRegistry.luau`: Chứa định nghĩa của `Weapons`, `Armors`, và 4 Slot `Gears`.
