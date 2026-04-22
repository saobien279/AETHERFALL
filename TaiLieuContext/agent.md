# 🤖 Hướng dẫn cho AI Agent — AETHERFALL (Roblox + Rojo)

> Tài liệu này giúp các Agent AI hiểu cách làm việc với dự án AETHERFALL để đảm bảo tính đồng nhất.  
> Đọc kỹ trước khi viết bất kỳ file nào.

---

## 1. Cách Build & Serve dự án

```bash
# Build thành file place
rojo build -o "AetherFall.rbxlx"

# Khởi động Rojo server (sync live vào Studio)
rojo serve
```

> Mở `AetherFall.rbxlx` trong Roblox Studio **trước**, rồi mới chạy `rojo serve`.

---

## 2. Cấu trúc thư mục `src/`

Dự án dùng **Rojo** để sync từ ổ cứng vào Roblox Studio. Mọi code nằm trong `src/`:

| Thư mục | Tương ứng trong Studio | Mục đích |
|---------|------------------------|----------|
| `src/Workspace` | Workspace | Parts, Models vật lý |
| `src/Players` | Players | Quản lý người chơi |
| `src/ReplicatedFirst` | ReplicatedFirst | Script chạy đầu tiên (Loading Screen) |
| `src/ReplicatedStorage` | ReplicatedStorage | ModuleScript & RemoteEvent dùng chung (Server + Client) |
| `src/ServerScriptService` | ServerScriptService | Script chỉ chạy phía Server |
| `src/ServerStorage` | ServerStorage | Dữ liệu chỉ Server truy cập được |
| `src/StarterGui` | StarterGui | UI (ScreenGui, Frame, ...) |
| `src/StarterPack` | StarterPack | Tools & vật phẩm khởi đầu |
| `src/StarterPlayer` | StarterPlayer | `StarterPlayerScripts` và `StarterCharacterScripts` |

> **Quan trọng**: Luôn kiểm tra `default.project.json` trước khi thêm thư mục mới để đảm bảo được sync đúng.

---

## 3. Quy tắc đặt tên file Script

| Đuôi file | Loại script trong Studio |
|-----------|--------------------------|
| `.server.luau` | `Script` (Server) |
| `.client.luau` | `LocalScript` (Client) |
| `.luau` | `ModuleScript` |

---

## 4. Quản lý Mô hình (Models & Parts)

> **CẬP NHẬT MỚI**: Dự án hiện tại lưu các Model và Part vật lý **trực tiếp trong file Roblox (Roblox Studio)**, thay vì sử dụng các file `.model.json` qua Rojo.
- Các Agent AI khi code cần tương tác với Part/Model phải tra cứu tên, vị trí và cấu trúc của chúng trong file `aboutproject.md`.

---

## 5. Quản lý Giao diện (UI)

> **CẬP NHẬT MỚI**: Tương tự như Model, toàn bộ Giao diện người dùng (ScreenGui, Frame, TextButton...) được thiết kế và lưu **trực tiếp trong Roblox Studio**. Dự án không dùng thư mục `.meta.json` để tạo UI nữa.
- Để biết ID, tên phần tử UI (như `ActionMenu`, `HealthBar`...) và vị trí của chúng (trong `StarterGui` hay `PlayerGui`), hãy tham khảo file `aboutproject.md`.
- Các file script UI (`.client.luau`) vẫn có thể được viết trong `src/`, và sẽ tự động gắn/hook vào UI đã có sẵn bằng code (ví dụ: `PlayerGui:WaitForChild("BattleUI")`).

---

## 6. Quy tắc kiểu dữ liệu (Data Types trong JSON)

| Kiểu | Định dạng JSON |
|------|---------------|
| `UDim2` | `[[ScaleX, OffsetX], [ScaleY, OffsetY]]` |
| `Color3` | `[R, G, B]` — giá trị 0.0 đến 1.0 |
| `Vector3` | `[X, Y, Z]` |

---

## 7. Quy tắc Type Checking (Strict Mode)

- **Luôn bật Strict Mode**: Mọi file `.luau` phải bắt đầu bằng `--!strict`.
- **Annotate tham số và return**:
  ```luau
  function MyFunction(param: number): string
  ```
- **Annotate biến local**:
  ```luau
  local myVar: string = "hello"
  ```
- **Dùng `typeof()`** thay vì `type()` khi kiểm tra kiểu runtime.
- **Tránh `any`** — dùng union type hoặc generic thay thế.

---

## 8. Lỗi thường gặp & Cách khắc phục

| Lỗi / Warning | Nguyên nhân | Khắc phục |
|---------------|-------------|-----------|
| `Unknown property Folder.FilteringEnabled` | Dùng `init.meta.json` để set property của Service (Workspace, Lighting...) | Khai báo trong `$properties` của `default.project.json` |
| `Model had a top-level Name field` | File `.model.json` có trường `"Name"` ở cấp cao nhất | Xóa trường `"Name"` |
| Lỗi đồng bộ `$path` | Đổi tên thư mục trong `src/` nhưng không cập nhật `default.project.json` | Cập nhật cả hai cùng lúc |
| `Rojo crashed: Name property should not exist in Instance.properties` | Đặt `"Name"` trong bảng `"properties"` của `.model.json` | Tuyệt đối không để `"Name"` trong `"properties"` |

---

## 9. ProfileStore — Tóm tắt sử dụng

Dự án dùng **ProfileStore** (by loleris / MAD STUDIO) để lưu dữ liệu người chơi với session locking.

### Khởi tạo

```luau
local ProfileStore = require(path.to.ProfileStore)
local PlayerStore = ProfileStore.New("PlayerData", { -- template mặc định
    Level = 1,
    Gold = 0,
})
```

### Vòng đời Profile

```luau
-- Khi player join
local profile = PlayerStore:StartSessionAsync("Player_" .. player.UserId)
if profile then
    profile:AddUserId(player.UserId) -- GDPR
    profile:Reconcile()              -- Điền các key thiếu từ template
    -- ... dùng profile.Data
end

-- Khi player leave
profile:EndSession()
```

### Các quy tắc quan trọng với `Profile.Data`

> ⚠️ KHÔNG làm những điều sau trong `Profile.Data`:
> - Tạo table số có khoảng trống (gaps) trong index
> - Tạo mixed table (vừa số vừa string key)
> - Lưu Roblox Instance (Part, Model...)
> - Lưu userdata (Vector3, Color3, CFrame...) — phải serialize trước
> - Lưu function

### Các method hay dùng

| Method | Mô tả |
|--------|-------|
| `ProfileStore:StartSessionAsync(key)` | Bắt đầu session, trả về Profile hoặc nil |
| `ProfileStore:GetAsync(key)` | Đọc profile không lock session |
| `ProfileStore:RemoveAsync(key)` | Xóa hoàn toàn data |
| `profile:IsActive()` | Kiểm tra session còn active không |
| `profile:Reconcile()` | Điền key thiếu từ template |
| `profile:EndSession()` | Kết thúc session (thường dùng khi player leave) |
| `profile:Save()` | Force save ngay lập tức |
| `profile:MessageHandler(fn)` | Nhận message từ server khác |

### Signals hay dùng

| Signal | Khi nào trigger |
|--------|----------------|
| `Profile.OnSave` | Trước mỗi lần save |
| `Profile.OnSessionEnd` | Khi session bị kết thúc |
| `Profile.OnLastSave` | Lần save cuối cùng (lý do: "Manual" / "Shutdown" / "External") |

---

## 10. Current Work In Progress (Session Memos)

- **Công việc hiện tại**: Đang tích hợp hàm `GetTotalStats` bên trong module `StatsCalculator`.
- **Ngữ cảnh**: Hàm đang kết hợp lấy dữ liệu `playerData.Stats` và `raceData.BaseStats` (từ `RaceRegistry`), sau đó áp dụng hệ số nhân từ `raceData.Passives`. Hệ thống đang xử lý việc ánh xạ từ chữ viết tắt của chỉ số (vd: "SPD") sang tên đầy đủ (vd: "Speed") để gọi đúng các multiplier cụ thể (vd: "SpeedMultiplier"). 
- **Lưu ý cho Agent**: Đoạn code được người dùng chủ ý để dang dở. **Tuyệt đối không tự ý hoàn thành hay sửa đổi code** nếu không được người dùng yêu cầu rõ ràng. Đọc lưu ý này khi bắt đầu session để biết mạch làm việc.

---

## 11. Quy tắc Tương tác & Học tập (User Working Rules)

> LƯU Ý TỐI QUAN TRỌNG CHO TẤT CẢ AGENT AI TIẾP QUẢN DỰ ÁN:

1. **Phương pháp Socratic (Dẫn dắt thay vì Đút ăn):** User đang trong quá trình **Vừa làm vừa học**. 
   - Tuyệt đối **KHÔNG** vội vàng tuôn ra một núi code nếu User chưa theo kịp vấn đề. 
   - Làm việc chậm rãi, chia nhỏ từng giai đoạn (Phase).
   - Hãy **Gợi ý logic** kèm câu hỏi mở để User tự suy nghĩ cách giải quyết và tự viết/phác thảo mã giả (pseudocode) trước. Khi User trả lời đúng hoặc "đầu hàng", chúng ta mới tiến hành viết code chuẩn vào file.
2. **Triết lý "Tiết kiệm Token bằng Docs":** Mọi cơ chế được hai bên chốt (như cấu trúc Gear, System Trigger, Formula) phải chủ động tổng hợp và ghi đè vào file `aboutproject.md` hoặc `agent.md`. Điều này giúp tiết kiệm Token ghi nhớ cho các phiên bản AI sau.
3. **Tiết kiệm từ vựng (Concise Communication):** Trình bày thẳng vào vấn đề kỹ thuật. Hạn chế những câu chào hỏi, khen ngợi rườm rà, bay bướm hoặc lặp lại câu hỏi của người dùng để tiết kiệm tối đa Token và không gian ngữ cảnh.