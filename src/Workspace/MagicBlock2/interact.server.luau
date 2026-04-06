--!strict
local Debris = game:GetService("Debris") -- Gọi dịch vụ gom rác của Roblox
local part = script.Parent :: Part

-- Đợi hệ thống load xong cái Prompt
local prompt = part:WaitForChild("Prompt") :: ProximityPrompt

-- Sự kiện 'Triggered' chạy khi người chơi đã giữ phím E đủ 2 giây
prompt.Triggered:Connect(function(player)
    print("Hệ thống: " .. player.Name .. " đã kích hoạt tự hủy!")
    
    -- Tắt cái Prompt đi để không ai bấm được nữa
    prompt.Enabled = false
    
    -- Đổi màu cảnh báo
    part.Material = Enum.Material.Neon
    part.Color = Color3.new(1, 0, 0)
    
    -- Dọn rác: Hẹn giờ hủy diệt vật thể này sau đúng 1 giây
    Debris:AddItem(part, 1)
end)