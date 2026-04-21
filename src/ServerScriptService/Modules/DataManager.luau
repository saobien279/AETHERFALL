local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Nhập Thư viện ProfileStore (Phiên bản cực xịn của ProfileService)
local ProfileStore = require(ServerScriptService.Modules.ProfileStore)

-- Lấy Khuôn mẫu Dữ liệu mặc định
local DataTemplate = require(ReplicatedStorage.Modules.Data.DataTemplate)

-- Khởi tạo Kho (Store)
local PlayerStore = ProfileStore.New("Aetherfall_Data_v1", DataTemplate)

-- BỘ XƯƠNG CỦA MODULE (Thư Viện Mở)
local DataManager = {}
local Profiles = {} -- Bộ nhớ lưu trữ Profile đang online (RAM)

local function PlayerAdded(player)
    -- Tải dữ liệu với cơ chế Khóa Phiên (Session Lock) chống Dupe Đồ
    local profile = PlayerStore:StartSessionAsync(tostring(player.UserId), {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if profile ~= nil then
        profile:AddUserId(player.UserId)
        -- Tự động đắp thêm Data mới nếu file DataTemplate có bổ sung (ví dụ Update thêm tiền vàng)
        profile:Reconcile()

        profile.OnSessionEnd:Connect(function()
            Profiles[player] = nil
            player:Kick("Dữ liệu của bạn đã được sao lưu an toàn và phiên chơi tự đóng.")
        end)

        if player.Parent == Players then
            Profiles[player] = profile
            print("🟢 TẢI DỮ LIỆU THÀNH CÔNG: " .. player.Name)
            
            -- Tương lai: Khi load xong Data, nhảy qua gọi TurnbaseEngine bằng Data lõi này!
        else
            profile:EndSession()
        end
    else
        player:Kick("🔴 LỖI: Dữ liệu của bạn đang kẹt ở máy chủ khác (Session-Locked). Thử lại sau ít phút.")
    end
end

-- Lưu và nhả dữ liệu khi người chơi rớt mạng hoặc thoát game
-- Xin phép và Xả dữ liệu khi rớt mạng
local function PlayerRemoving(player)
    local profile = Profiles[player]
    if profile then
        profile:EndSession()
    end
end

-- =======================================
-- AI ĐÓ BÊN NGOÀI PHẢI GỌI HÀM NÀY ĐỂ KÍCH HOẠT NHÀ MÁY
-- =======================================
function DataManager.Init()
    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(PlayerRemoving)

    -- Phóng vòng lặp chữa cháy cho Studio
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(PlayerAdded, player)
    end
end

-- =======================================
-- HÀM MOI MÓC DỮ LIỆU CÔNG KHAI
-- =======================================
function DataManager.GetProfile(player: Player)
    -- Trả về cuốn Khóa Phiên của player đó (Bao gồm .Data của họ luôn)
    return Profiles[player]
end

return DataManager
