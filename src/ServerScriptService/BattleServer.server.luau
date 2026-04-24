--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EntityManager = require(ReplicatedStorage.Modules.Core.EntityManager)
local TurnbaseEngine = require(ReplicatedStorage.Modules.Core.TurnbaseEngine)
local RaceRegistry = require(ReplicatedStorage.Modules.Registries.RaceRegistry)
local EnemyRegistry = require(ReplicatedStorage.Modules.Registries.EnemyRegistry)

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

-- Khởi tạo luôn BindableEvent (Cáp ngầm nội bộ Server)
local StartEncounterEvent = Events:FindFirstChild("StartEncounterEvent") :: BindableEvent
if not StartEncounterEvent then
    StartEncounterEvent = Instance.new("BindableEvent")
    StartEncounterEvent.Name = "StartEncounterEvent"
    StartEncounterEvent.Parent = Events
end

-- =======================================
-- BỘ NHỚ LƯU TRỮ VÀ QUẢN LÝ
-- =======================================
local activeBattles = {} -- Cái nhà kho lưu tất cả các quyển Sổ ghi chép trận đấu của nhiều người chơi khác nhau

-- Khi Bãi Mìn gọi điện báo cáo, nó sẽ gửi cho ta 2 thứ: Thằng nào đạp mìn (player) và đạp trúng con gì (enemyID)
StartEncounterEvent.Event:Connect(function(player: Player, enemyID: string)
    print("--- [BATTLE SERVER] ĐANG NẠP DỮ LIỆU ĐỂ ĐÁNH NHAU VỚI: " .. enemyID .. " ---")
    
    -- Lấy dữ liệu người chơi từ DataManager (Hàm này đã có cache cực nhanh)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    local accountData = profile.Data
    local currentSlot = accountData.AccountData.CurrentSlotIndex or "Slot1"
    local playerData = accountData.Characters[currentSlot]
    
    playerData.ID = player.Name

    -- Lấy dữ liệu Quái vật từ Từ điển bằng đúng cái ID mà Bãi mìn gửi sang!
    local baseEnemyData = EnemyRegistry[enemyID]
    if not baseEnemyData then
        warn("[LỖI] Không tìm thấy Quái vật nào có mã: " .. enemyID .. " trong EnemyRegistry!")
        return
    end

    local dummyEnemyData = table.clone(baseEnemyData)
    dummyEnemyData.ID = enemyID 

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
