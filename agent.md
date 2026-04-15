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

## 4. Tạo Part bằng `.model.json`

Thay vì tạo Part trực tiếp trong Studio, tạo file `.model.json` trong `src/Workspace/`.

```json
{
  "ClassName": "Part",
  "Properties": {
    "Anchored": true,
    "Color": [1, 0, 0],
    "Position": [0, 5, 0],
    "Size": [4, 4, 4]
  }
}
```

> ⚠️ **Không đặt trường `"Name"` bên trong `"Properties"`** — Rojo sẽ crash. Tên Instance lấy từ tên file.

---

## 5. Tạo UI bằng `.meta.json`

Để tạo một UI element (ScreenGui, Frame, TextButton...), tạo thư mục + file `init.meta.json`:

**Ví dụ: Tạo TextButton tên `MyButton`**

```
src/StarterGui/MyButton/
├── init.meta.json      ← định nghĩa ClassName
└── logic.client.luau   ← logic xử lý sự kiện
```

```json
// init.meta.json
{
  "className": "TextButton",
  "properties": {
    "Text": "Click Me",
    "Size": { "UDim2": [[0, 200], [0, 50]] },
    "Position": { "UDim2": [[0.5, 0], [0.5, 0]] },
    "AnchorPoint": [0.5, 0.5]
  }
}
```

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