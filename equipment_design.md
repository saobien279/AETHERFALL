# 🛡️ TÀI LIỆU THIẾT KẾ TRANG BỊ & PHỤ KIỆN (AETHERFALL)

Tài liệu này định nghĩa mọi trang bị tồn tại trong trò chơi và là bản lề để lập trình hệ thống `EquipmentRegistry`.

---

## ⚔️ VŨ KHÍ (WEAPONS)
Cấp độ **Low-Fin** là những tạo vật phổ thông, trong khi **Fin** mang dấu ấn tinh xảo của các bậc thầy Aether.

| ID / Tên Vũ Khí | Series | Base DMG | Hiệu ứng (Buff) |
|---|---|---|---|
| `LowFinSword` (Low Fin + Tên) | Low-Fin| 7 | Không có |
| `FinSword` (Fin + Tên) | Fin | 10 | +5% Tổng sát thương đầu ra |

---

## 🛡️ GIÁP TRỤ (ARMOR)
Mặc định nguyên bộ (Full set), định hình lối chơi.

| ID | Tên trang bị | Chỉ số mang lại | Lối chơi |
|---|---|---|---|
| `RecruitLeathers` | Giáp Da Tân Binh | 10 P.DEF / 5 M.DEF | Cân bằng, nhẹ nhàng |
| `IronPlate` | Giáp Sắt | 20 P.DEF / 0 M.DEF | Phản vật lý cực tốt |
| `ScholarRobe` | Áo Choàng Học Giả | 0 P.DEF / 20 M.DEF | Kháng phép tối ưu |
| `ScoutGarb` | Y phục Thám Báo | 5 P.DEF / 5 M.DEF / +5 Speed | Ưu tiên tốc độ, né tránh |
| `HeavyStoneMail` | Giáp Đá Nặng | 25 P.DEF / 10 M.DEF / -10 Speed | Lì lợm nhưng chậm chạp |

---

## 🏺 THÁNH DI VẬT (ARTIFACTS)
Cổ vật mang quyền năng phá vỡ quy luật, thường có hồi chiêu rất dài và kích hoạt chủ động.

- **Chrono-Amber** (Hổ Phách Thời Gian)
  - *Hiệu ứng*: Quay ngược trạng thái. Hồi phục lượng HP và Mana về mức của 1 hiệp trước đó.
  - *Hồi chiêu*: 10 lượt.
- **Void Summoner’s Bell** (Chuông Triệu Hồi)
  - *Hiệu ứng*: Triệu hồi 1 lính canh bóng tối mang 20% chỉ số chủ nhân, tự động tấn công kẻ thù trong 3 hiệp.
  - *Hồi chiêu*: 12 lượt.
- **Aurelion’s Lens** (Thấu Kính Aurelion)
  - *Hiệu ứng*: Thấu thị điểm yếu. Đòn đánh tiếp theo chắc chắn Chí mạng và Xuyên 100% DEF/M.DEF mục tiêu.
  - *Hồi chiêu*: 8 lượt.

---

## ⚙️ TRANG BỊ BỔ TRỢ (GEARS - 4 SLOTS)
Kích hoạt tự động hoặc chủ động thông qua Combat Engine Triggers.

### Slot 1: Offensive (Kích hoạt Tấn công)
- **Whetstone** (Đá Mài): Khi Chí mạng, gây thêm sát thương vật lý bằng 30% sát thương gốc.
- **Spark Plug** (Buggy Lửa): Đòn đánh thường có 15% tỷ lệ gây hiệu ứng [Burn] (Trừ 2% Max HP/lượt).

### Slot 2: Defensive (Kích hoạt Phòng thủ)
- **Spiked Bracers** (Vòng Gai): Bị tấn công cận chiến sẽ Phản 40% chỉ số P.DEF thành sát thương về số 0.
- **Ghostly Veil** (Màn Sương Ma Mị): Sau khi Né tránh, nhận ngay lập tức trạng thái [Tàng Hình] (1 lượt).

### Slot 3: Threshold (Kích hoạt Ngưỡng HP)
- **Berserker’s Heart** (Tim Cuồng Chiến): HP < 30% -> Nhận +20% Sát thương và +10% Hút máu.
- **Guardian’s Shell** (Mai Hộ Mệnh): HP > 90% (Lúc đầy máu) -> Khởi tạo với một lớp khiên ảo (Shield) = 15% Max HP.

### Slot 4: Special Active (Kỹ năng Chủ động)
- **Flash Bang** (Bom Choáng): Gây 1 DMG và làm toàn bộ kẻ địch mất lượt (Choáng). *Cooldown: 8 lượt*.
- **Purity Flask** (Bình Thanh Tẩy): Xóa mọi Debuff, hồi phục 10% năng lượng. *Cooldown: 6 lượt*.
