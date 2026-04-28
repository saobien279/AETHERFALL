# 🛠️ JOB ASSIGNMENT: ASTRO (UI/UX DEVELOPER)

**Task Focus**: Hệ thống Giao diện Chiến đấu (Battle UI) & Logic chuyển đổi chiêu thức.

## 📋 MÔ TẢ CÔNG VIỆC
Xây dựng hệ thống UI đa tầng cho phép người chơi chọn lệnh (Command) và chọn kỹ năng (Skill) một cách mượt mà.

## 🏗️ CẤU TRÚC PHÂN CẤP UI (UI HIERARCHY)
Cần xây dựng trong `StarterGui`:
- **BattleHUD (ScreenGui)**:
    - **CommandMenu (Frame)**: Chứa danh sách nút (UIListLayout) -> `Attack`, `Item`, `Guard`, `Meditate`, `Escape`.
    - **SubMenu (Frame)**: Ban đầu ẩn (`Visible = false`). Chứa danh sách các kỹ năng cụ thể sau khi nhấn `Attack`.
    - **SkillSlot (Template)**: Một mẫu nút kỹ năng để nhân bản (Clone) dựa trên danh sách chiêu thức của Player.

## ⚠️ LƯU Ý QUAN TRỌNG: LUỒNG DỮ LIỆU SKILL
- Danh sách kỹ năng (`Skillset`) hiện **chỉ tồn tại trên Server** (trong `playerEntity`).
- Để Client hiển thị được danh sách chiêu, cần **Server gửi danh sách Skill ID về Client** thông qua `CombatEvents` (hoặc tạo RemoteEvent mới) tại thời điểm bắt đầu trận đấu.
- Tra cứu tên hiển thị, mô tả, icon của chiêu thức tại: `src/ReplicatedStorage/Modules/Registries/SkillRegistry.luau`.

## 🛠️ CÁC MODULE LIÊN QUAN
- `src/StarterPlayer/StarterPlayerScripts/ActionMenuController.client.luau`: **(Trọng tâm - Đã có sẵn code cơ bản)**
    - **Hiện tại:** Chỉ có 1 nút `AttackBtn` cố định gửi `"Normal Attack"` lên Server. Cần mở rộng.
    - Viết logic lắng nghe sự kiện Click trên CommandMenu.
    - Xử lý chuyển đổi: Nhấn `Attack` -> Ẩn `CommandMenu`, Hiện `SubMenu`.
    - Đổ dữ liệu kỹ năng: Duyệt qua danh sách Skill nhận từ Server để tạo các nút trong `SubMenu`.
    - Gửi tín hiệu: Khi chọn xong chiêu, gọi `ActionMenuEvent:FireServer(skillID)`.
- `src/ReplicatedStorage/Modules/Registries/SkillRegistry.luau`: **(Tham khảo)**
    - Chứa thông tin chi tiết (BasePower, DamageType, Scaling, EnergyCost...) của từng chiêu thức.
    - Dùng để hiển thị tooltip hoặc mô tả chiêu trên UI.

## 📡 GIAO THỨC MẠNG HIỆN CÓ
- `Events/ActionMenuEvent` **[RemoteEvent]**: Client gửi `skillID` (string) lên Server. Server xử lý tại `BattleServer.server.luau`.
- `Events/CombatEvents` **[RemoteEvent]**: Server gửi tín hiệu xuống Client (UpdateHP, FadeToBlack). Có thể dùng thêm actionType mới để gửi danh sách Skill.

## 🔄 WORKFLOW LOGIC
1. **Initial State**: Chỉ hiện `CommandMenu`.
2. **On Attack Click**: 
   - `TweenService` làm mờ/di chuyển `CommandMenu`.
   - Lấy danh sách Skill từ `EntityManager` (thông qua cache hoặc truyền data).
   - Hiển thị `SubMenu`.
3. **On Skill Click**: 
   - Khóa UI để tránh spam.
   - Gửi `RemoteEvent` lên máy chủ.
   - Reset UI về trạng thái ẩn để chờ lượt sau.

---
*Ghi chú: Luôn sử dụng `TweenService` để tạo cảm giác cao cấp (Premium) cho giao diện.*
