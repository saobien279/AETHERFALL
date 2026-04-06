--!strict
local part = script.Parent :: Part

-- Biến cờ (Flag) để tránh việc code chạy liên tục hàng nghìn lần mỗi giây khi đang đứng trên đó
local isFlashing = true

part.Touched:Connect(function(hit)
    -- Nếu đã bị dẫm rồi thì không chạy lại nữa
    if isFlashing == true then
    
    isFlashing = false
    local character = hit.Parent
    -- Kiểm tra xem thứ dẫm lên có phải là con người (có Humanoid) không
    if character and character:FindFirstChild("Humanoid") then
        print("Hệ thống: " .. character.Name .. " đã kích hoạt bệ đá!")
        
        -- Đổi màu và chất liệu để phát sáng
        part.Material = Enum.Material.Neon
        part.Color = Color3.new(0.317647, 1, 0) -- Màu đỏ
        task.wait(0.5)
        part.Color = Color3.new(0.278431, 0.086274, 0.501960) -- Màu đỏ
        task.wait(0.5)
        part.Color = Color3.new(0.780392, 0.788235, 0.341176) -- Màu đỏ
        task.wait(0.5)
        part.Color = Color3.new(0.368627, 0.023529, 0.184313) -- Màu đỏ
        task.wait(0.5)
        part.Color = Color3.new(1, 0, 0) -- Màu đỏ

        task.wait(1)
        isFlashing = true   
    end
end
end)