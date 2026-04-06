
--!strict
local Workspace = game:GetService("Workspace")

local part = script.Parent :: Part

-- Đợi hệ thống load xong cái "Sensor" (ClickDetector) rồi mới lấy ra xài
local detector = part:WaitForChild("Sensor") :: ClickDetector
local Middle = Workspace.TotemGiaoUoc.Middle :: Part

-- Lắng nghe sự kiện người chơi click chuột
detector.MouseClick:Connect(function(player)
    -- Khi click, Roblox tự động truyền thông tin người đã click vào biến 'player'
    print("Hệ thống: " .. player.Name .. " vừa nhấp chuột vào khối lập phương!")
    
    -- Hàm math.random() sẽ tự động tạo ra một số ngẫu nhiên từ 0 đến 1
    local randomColor = Color3.new(math.random(), math.random(), math.random())
    part.Color = randomColor
    Middle.Color = randomColor
end)