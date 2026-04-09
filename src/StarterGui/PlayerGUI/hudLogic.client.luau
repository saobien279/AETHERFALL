--strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local fill = script.Parent:WaitForChild("HealthBar"):WaitForChild("Fill")
local updateHUDEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("updateHUDEvent") :: RemoteEvent

updateHUDEvent.OnClientEvent:Connect(function(currentHp , MaxHp)
    local scale = currentHp / MaxHp
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local goal = { Size = UDim2.new(scale,0,1,0)}
    local tween = TweenService:Create(fill, tweenInfo, goal)
    tween:Play()
end)