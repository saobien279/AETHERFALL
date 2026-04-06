--strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Dùng từ khóa 'require' để nạp (import) Class Monster vào file này
-- Giống như 'using' trong C# nhưng nó gán luôn Class vào một biến
local MonsterClass = require(ReplicatedStorage.Modules.Monster)

task.wait(2)
local slimePart = Workspace:WaitForChild("Slime") :: Part

-- Khởi tạo (New) các Object
local slime = MonsterClass.new("Slime Nước", 100, slimePart)

print("--- KHAI CHIẾN ---")

-- Bắt đầu đánh và quan sát thanh máu lơ lửng bóp ngắn lại
slime:TakeDamage(20) -- Còn 80%
task.wait(1.5)

slime:TakeDamage(30) -- Còn 50%
task.wait(1.5)

slime:TakeDamage(35) -- Còn 15% (Chuyển sang màu đỏ cảnh báo)
task.wait(1.5)

slime:TakeDamage(50) -- Quá sát thương (Chết, máu về 0, xác hóa xám)