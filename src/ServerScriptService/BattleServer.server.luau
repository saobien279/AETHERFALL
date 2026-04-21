--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EntityManager = require(ReplicatedStorage.Modules.Core.EntityManager)
local TurnbaseEngine = require(ReplicatedStorage.Modules.Core.TurnbaseEngine)
local RaceRegistry = require(ReplicatedStorage.Modules.Registries.RaceRegistry)

-- NẠP DATA BẰNG TAY Ở ĐÂY
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.Modules.DataManager)

-- 🔔 Bấm còi kích hoạt Nhà máy Load Dữ liệu ngay và luôn
DataManager.Init()

-- Khởi tạo hoặc tìm Folder Events
local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then
    Events = Instance.new("Folder")
    Events.Name = "Events"
    Events.Parent = ReplicatedStorage
end

-- Khởi tạo tự động RemoteEvent luôn để User không phải thao tác tay trong Roblox Studio
local ActionMenuEvent = Events:FindFirstChild("ActionMenuEvent") :: RemoteEvent
if not ActionMenuEvent then
    ActionMenuEvent = Instance.new("RemoteEvent")
    ActionMenuEvent.Name = "ActionMenuEvent"
    ActionMenuEvent.Parent = Events
end

-- =======================================
-- BỘ NHỚ LƯU TRỮ VÀ QUẢN LÝ
-- =======================================
local activeBattles = {} -- Cái nhà kho lưu tất cả các quyển Sổ ghi chép trận đấu của nhiều người chơi khác nhau

-- Kích hoạt Trận đánh Demo ngay khi Người chơi vào game để dễ test
Players.PlayerAdded:Connect(function(player)
    print("--- [BATTLE SERVER] ĐANG ĐỢI DỮ LIỆU TỪ DATAMANAGER ---")
    
    -- VÒNG LẶP RÌNH RẬP (Cách A)
    -- Ngồi đợi cho tới khi DataManager lấy được thông tin từ Đám mây về
    local profile = nil
    repeat
        task.wait(0.5)
        profile = DataManager.GetProfile(player)
    until profile ~= nil or player.Parent ~= Players

    -- Nếu thằng này out game trong lúc chờ thì Dẹp, không tạo trận đấu nữa.
    if not profile then return end

    -- Lấy cục Ruột dữ liệu thật ra! (DataTemplate nằm trong lõi này)
    local playerData = profile.Data
    
    -- Bơm thêm cái Tên của người chơi vào để hiển thị UI
    playerData.Name = player.Name

    -- Mockup (Làm giả) Dữ liệu Quái vật Rừng (Vì quái không có Save Data)
    local dummyEnemyData = {
        Name = "Lowly Bandit",
        Race = "Sylvanus", 
        Stats = { STR = 10, ARC = 0, END = 5, SPD = 8, LCK = 2 },
        Inventory = {
            Equipped = {
                Weapon = "LowFinSword",
                Armor = "RecruitLeathers",
                Artifact = "None",
                Gears = { Slot1_Offensive = "None", Slot2_Defensive = "None", Slot3_Threshold = "None", Slot4_Active = "None" }
            }
        }
    }

    print("--- SERVER: DỮ LIỆU ĐÃ NẠP XONG! KHỞI TẠO LỒNG BÁT GIÁC ---")
    local playerEntity = EntityManager.New(playerData, RaceRegistry)
    local enemyEntity = EntityManager.New(dummyEnemyData, RaceRegistry)

    -- Mở cái Lồng bát giác ở đây, đẩy ra quyển Sổ và nhét vô Danh sách quản lý
    local battleState = TurnbaseEngine.StartBattle(playerEntity, enemyEntity)
    activeBattles[player] = battleState
end)

-- =======================================
-- LẮNG NGHE ĐIỆN THOẠI (UI NÉM PACKET LÊN)
-- =======================================
ActionMenuEvent.OnServerEvent:Connect(function(player, skillID)
    -- 1. Tìm quyển Sổ ghi chép của người vừa gửi điện tín
    local state = activeBattles[player]
    if not state then return end

    -- 2. Kiểm tra Thẩm quyền: "Cái luồng này có phải Lượt của Khứa này không?"
    if state.CurrentState == TurnbaseEngine.States.PLAYER_TURN then
        -- 3. Gọi Core Engine đấm đối thủ
        local success, errMessage = TurnbaseEngine.ProcessPlayerTurn(state, skillID)
        
        -- Nếu bị Ông Cảnh Sát SkillProcessor gõ đầu (Thiếu Mana/Dính Cooldown)
        if not success then
            print("[HỆ THỐNG] TỪ CHỐI CHIÊU: " .. errMessage)
            -- Trong tương lai: RemoteEventError:FireClient(player, errMessage) để Pop cục Text Đỏ lên UI
        end
    else
        -- 4. Nếu UI giở trò / Rớt khung hình / Hack thì chặn ngay:
        print("[ANTI-CHEAT] " .. player.Name .. " cố tình bấm skill trước khi tới lượt!")
    end
end)
