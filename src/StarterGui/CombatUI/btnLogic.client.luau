--strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local button = script.Parent.AttackBtn :: TextButton
local button2 = script.Parent:WaitForChild("HealBtn") :: TextButton

--local attackEvent = ReplicatedStorage:WaitForChild("Events").AttackEvent :: RemoteEvent
--local healEvent = ReplicatedStorage:WaitForChild("Events").HealEvent :: RemoteEvent

local actionEvent = ReplicatedStorage:WaitForChild("Events").AttackEvent :: RemoteEvent

button.MouseButton1Click:Connect(function()
    print("💻 Client: Bạn đã bấm nút! Đang gửi tín hiệu lên Server...")
    actionEvent:FireServer("Attack")
end)

button2.MouseButton1Click:Connect(function()
    print("💻 Client: Bạn đã bấm nút hồi máu! Đang gửi tín hiệu lên Server...")
    actionEvent:FireServer("Heal")
end)