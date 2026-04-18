--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EntityManager = require(ReplicatedStorage.Modules.Core.EntityManager)
local TurnbaseEngine = require(ReplicatedStorage.Modules.Core.TurnbaseEngine)
local RaceRegistry = require(ReplicatedStorage.Modules.Registries.RaceRegistry)

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
    -- Mockup (Làm giả) Dữ liệu người chơi
    local dummyPlayerData = {
        Name = player.Name,
        Race = "Aetherian",
        Stats = { STR = 20, ARC = 10, END = 15, SPD = 10, LCK = 5 },
        Inventory = {
            Equipped = {
                Weapon = "FinSword",
                Armor = "IronPlate",
                Artifact = "None",
                Gears = { Slot1_Offensive = "None", Slot2_Defensive = "None", Slot3_Threshold = "None", Slot4_Active = "None" }
            }
        }
    }

    -- Mockup (Làm giả) Dữ liệu Quái vật Rừng
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

    print("--- SERVER: KHỞI TẠO DỮ LIỆU ---")
    local playerEntity = EntityManager.New(dummyPlayerData, RaceRegistry)
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
        TurnbaseEngine.ProcessPlayerTurn(state, skillID)
    else
        -- 4. Nếu UI giở trò / Rớt khung hình / Hack thì chặn ngay:
        print("[ANTI-CHEAT] " .. player.Name .. " cố tình bấm skill trước khi tới lượt!")
    end
end)
