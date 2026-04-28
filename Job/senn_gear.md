# ⚔️ JOB ASSIGNMENT: SENN (SYSTEM/DATA DEVELOPER)

**Task Focus**: Hệ thống Trang bị (Gear/Equipment) & Tích hợp chỉ số chiến đấu.

## 📋 MÔ TẢ CÔNG VIỆC
Xây dựng và hoàn thiện logic trang bị, đảm bảo các vật phẩm (Vũ khí, Giáp) tác động chính xác lên thực thể trong trận đấu.

## 🏗️ CẤU TRÚC DỮ LIỆU (DATA STRUCTURE)
Làm việc chính trong:
- `src/ReplicatedStorage/Modules/Registries/EquipmentRegistry.luau`: Định nghĩa thuộc tính vật phẩm (Sát thương gốc, loại sát thương, chỉ số cộng thêm).
- `src/ReplicatedStorage/Modules/Data/DataTemplate.luau`: Cấu trúc lưu trữ trang bị trong túi đồ (`Inventory`) và các ô đang mặc (`Equipped`).

## 🛠️ CÁC MODULE LIÊN QUAN
- `src/ReplicatedStorage/Modules/Utils/StatsCalculator.luau`: **(Trọng tâm)**
    - Viết hàm tính toán chỉ số tổng khi có mặc đồ: `BaseStats + EquipmentStats`.
    - Tính toán `P_DEF` và `M_DEF` dựa trên loại giáp đang mặc.
- `src/ReplicatedStorage/Modules/Core/EntityManager.luau`:
    - Cập nhật hàm `New()` để quét `playerData.Inventory.Equipped` (LƯU Ý: `Equipped` nằm bên trong `Inventory`, không phải cấp gốc).
    - Gọi `StatsCalculator` để tạo ra một Thực thể có chỉ số chính xác ngay khi vào trận.
- `src/ReplicatedStorage/Modules/Core/CombatManager.luau`: **(ĐÃ CÓ SẴN logic cơ bản)**
    - `DealDamage()` (dòng 64-108): **Đã** lấy Weapon từ `attacker.Inventory.Equipped.Weapon` và tra `EquipmentRegistry.Weapons`.
    - `TakeDamage()` (dòng 35-60): **Đã** lấy Armor từ `defender.Inventory.Equipped.Armor` và tra `EquipmentRegistry.Armors`.
    - **CẦN LÀM THÊM**: Tích hợp logic **Gear Triggers** (4 slot phụ kiện trong `Equipped.Gears`) - ví dụ: Whetstone gây thêm 30% khi Crit, SpikedBracers phản đòn.

## 🔄 WORKFLOW LOGIC
1. **Data Definition**: Thiết lập các mẫu Vũ khí/Giáp trong Registry.
2. **Calculation**: Đảm bảo các hàm toán học cộng dồn chỉ số không bị lỗi (tránh trường hợp chỉ số nhảy vọt quá cao).
3. **Integration**: Kết nối vào `CombatManager` để việc mặc đồ có ý nghĩa trong chiến đấu (Mặc giáp nặng thì quái đánh bớt đau).

---
*Ghi chú: Đảm bảo sử dụng `Network ID (.ID)` khi truy vấn dữ liệu thực thể để đồng bộ với hệ thống hiện tại.*
