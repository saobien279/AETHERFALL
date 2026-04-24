--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Events = ReplicatedStorage:WaitForChild("Events")
local StartEncounterEvent = Events:WaitForChild("StartEncounterEvent") :: BindableEvent
local CombatEvents = Events:WaitForChild("CombatEvents") :: RemoteEvent

-- Lưu trữ danh sách ai đang trong trận để tránh lỗi đạp đè mìn
local activePlayers = {}

local function SetupZone(zonePart: BasePart)
    -- Khi có vật thể chạm vào cục gạch
    zonePart.Touched:Connect(function(hit)
        local character = hit.Parent
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Lọc ra đúng Người chơi thật (Không phải quái hay NPC dẫm)
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        -- Nếu người này đang đánh nhau rồi thì kệ, không kích hoạt nữa
        if activePlayers[player.UserId] then return end
        activePlayers[player.UserId] = true
        -- 1. TÌM ID QUÁI VẬT: Lấy tên của thằng Bố (Model) bọc ngoài cục gạch
        -- LƯU Ý: Phải lấy Parent TRƯỚC KHI XÓA cục gạch! Nếu xóa trước, Parent sẽ thành nil!
        local enemyModel = zonePart.Parent
        if not enemyModel then return end
        local enemyID = enemyModel.Name 

        -- Xóa cục mìn để không bị đạp nhiều lần
        zonePart:Destroy()

        -- 2. TRÓI CHÂN NGƯỜI CHƠI LẠI
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0

        -- 3. ĐẨY VỊ TRÍ (REPOSITION): Tạo đội hình đứng đối mặt nhau
        local enemyPrimary = enemyModel.PrimaryPart or enemyModel:FindFirstChildWhichIsA("BasePart")
        if enemyPrimary then
            -- Toán học CFrame: Từ chỗ con quái, đi thẳng tới trước mặt (-Z) 15 stud, sau đó xoay người 180 độ quay mặt lại
            local faceToFaceCFrame = enemyPrimary.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(0, math.rad(180), 0)
            character:PivotTo(faceToFaceCFrame)
        end

        -- 4. GỬI TÍN HIỆU CHO CLIENT: "CÚP CẦU DAO TẮT ĐÈN!"
        CombatEvents:FireClient(player, "FadeToBlack")

        -- 5. DELAY CHỜ MÀN HÌNH ĐEN RỒI MỚI THẢ QUÁI!
        task.wait(1.5)

        -- 6. GỌI ĐIỆN CHO BATTLE SERVER ĐỂ KHỞI TẠO LỒNG BÁT GIÁC!
        StartEncounterEvent:Fire(player, enemyID)
    end)
end

print("--- [ENCOUNTER MANAGER] ĐANG QUÉT TÌM CÁC BÃI MÌN ---")

-- 1. Quét tìm tất cả các cục gạch có dán nhãn "EncounterZone" đã cắm sẵn trên Map
for _, zonePart in ipairs(CollectionService:GetTagged("EncounterZone")) do
    if zonePart:IsA("BasePart") then
        SetupZone(zonePart)
    end
end


--Future Work (Spawn Monster)
-- 2. Lắng nghe nếu sau này hệ thống tự đẻ thêm (Spawn) quái vật mới
CollectionService:GetInstanceAddedSignal("EncounterZone"):Connect(function(zonePart)
    if zonePart:IsA("BasePart") then
        SetupZone(zonePart)
    end
end)
