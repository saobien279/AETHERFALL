local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. Tìm đường dây điện thoại
local ActionMenuEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ActionMenuEvent")

-- 2. Đợi UI của người chơi tải xuống xong (Vì lúc người chơi mới vào, UI chưa load kịp)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- 3. Tìm tới giao diện ActionMenu và các nút bấm của User xây bên trong Studio
local actionMenu = playerGui:WaitForChild("ActionMenu")
local attackBtn = actionMenu:WaitForChild("AttackBtn")

-- 4. Gắn hành động click chọc thẳng lên Máy chủ
attackBtn.MouseButton1Click:Connect(function()
    print("[UI Client] Đã ấn gửi lệnh Normal Attack!")
    ActionMenuEvent:FireServer("Normal Attack")
end)
