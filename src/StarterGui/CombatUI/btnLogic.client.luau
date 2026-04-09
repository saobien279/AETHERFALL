--strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local button = script.Parent.AttackBtn :: TextButton

local attackEvent = ReplicatedStorage:WaitForChild("Events").AttackEvent :: RemoteEvent

button.MouseButton1Click:Connect(function()
    print("💻 Client: Bạn đã bấm nút! Đang gửi tín hiệu lên Server...")
    attackEvent:FireServer()
end)