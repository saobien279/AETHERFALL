--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatManager = require(ReplicatedStorage.Modules.Core.CombatManager)
local SkillProcessor = require(ReplicatedStorage.Modules.SkillProcessor)
local SkillRegistry = require(ReplicatedStorage.Modules.Registries.SkillRegistry)

local TurnbaseEngine = {}

-- Các Trạng Thái (States) của trận đấu
TurnbaseEngine.States = {
    WAITING = "Waiting",         -- Chờ setup trận đấu hoặc load dữ liệu
    ENEMY_TURN = "EnemyTurn",    -- Quái vật hành động
    PLAYER_TURN = "PlayerTurn",  -- Người chơi hành động
    VICTORY = "Victory",         -- Quái chết
    DEFEAT = "Defeat"            -- Người chơi chết
}

-- [[ HÀM KHỞI TẠO TRẬN ĐẤU (START BATTLE) ]]
function TurnbaseEngine.StartBattle(playerEntity: any, enemyEntity: any)
    -- Tạo một "Căn phòng trận đấu" ảo lưu trữ thông tin
    local battleState = {
        Player = playerEntity,
        Enemy = enemyEntity,
        CurrentState = TurnbaseEngine.States.WAITING,
        TurnCount = 0
    }

    -- Luật do User định đoạt: QUÁI LUÔN ĐÁNH TRƯỚC!
    print("Trận đấu bắt đầu! Kẻ thù nhảy vào tấn công trước!")
    TurnbaseEngine.SetState(battleState, TurnbaseEngine.States.ENEMY_TURN)

    return battleState
end

-- [[ HÀM CHUYỂN TRẠNG THÁI (STATE MACHINE) ]]
function TurnbaseEngine.SetState(battleState: any, newState: string)
    --changing state
    battleState.CurrentState = newState

    if newState == TurnbaseEngine.States.ENEMY_TURN then
        -- Chạy hàm StartTurn để Quái tự tăng Energy và xả Cooldown
        SkillProcessor.ProcessStartTurn(battleState.Enemy)
        TurnbaseEngine.ProcessEnemyTurn(battleState)

    elseif newState == TurnbaseEngine.States.PLAYER_TURN then
        -- Chạy hàm StartTurn để Người tự tăng Energy và xả Cooldown
        SkillProcessor.ProcessStartTurn(battleState.Player)
        print("Đến lượt bạn! (Năng lượng hiện tại: " .. battleState.Player.Energy .. " / " .. battleState.Player.MaxEnergy .. ")")
        
    elseif newState == TurnbaseEngine.States.VICTORY then
        print("Chiến thắng! Rơi ra Loot đồ...")
        
    elseif newState == TurnbaseEngine.States.DEFEAT then
        print("Thất bại! Về thành dưỡng sức...")
    end
end

-- [[ HÀM XỬ LÝ LƯỢT QUÁI (AI PROCESSOR) ]]
function TurnbaseEngine.ProcessEnemyTurn(battleState)
    print("Quái vật bắt đầu suy nghĩ...")
    
    -- Móc nối AI (Chỉ gọi khi chạy trên Máy chủ, tránh sập Client)
    local RunService = game:GetService("RunService")
    if RunService:IsServer() then
        local MonsterAI = require(game:GetService("ServerScriptService").Modules.MonsterAI)
        MonsterAI.ProcessTurn(battleState.Enemy, battleState.Player)
    end
    
    -- Sau khi đánh xong, kiểm tra xem người chơi còn sống không
    if battleState.Player.IsDead then
        TurnbaseEngine.SetState(battleState, TurnbaseEngine.States.DEFEAT)
    else
        -- Trả lại Turn cho Người chơi
        TurnbaseEngine.SetState(battleState, TurnbaseEngine.States.PLAYER_TURN)
    end
end

-- [[ HÀM XỬ LÝ LƯỢT NGƯỜI CHƠI (TỪ UI GỬI VÀO) ]]
function TurnbaseEngine.ProcessPlayerTurn(battleState, skillID: string)
    -- 1. Triệu hồi Cảnh Sát Gác Cổng
    local isAllowed, errMessage = SkillProcessor.CanUseSkill(battleState.Player, skillID, SkillRegistry)
    
    if not isAllowed then
        -- TRẢ LỖI TRỰC TIẾP VỀ CHO SERVER ĐỂ SERVER BÁO VỀ UI!
        return false, errMessage
    end

    print("Người chơi tung đòn: " .. skillID)
    
    -- 2. Trừ Năng lượng & Cập nhật Cooldown
    SkillProcessor.ConsumeCost(battleState.Player, skillID, SkillRegistry)

    -- 3. Chuyển lệnh cho CombatManager tính sát thương
    CombatManager.DealDamage(battleState.Player, battleState.Enemy, skillID)

    -- 4. Đánh xong xem quái chết chưa
    if battleState.Enemy.IsDead then
        TurnbaseEngine.SetState(battleState, TurnbaseEngine.States.VICTORY)
    else
        -- Quái chưa chết, nhường cầu dao lại cho Quái
        TurnbaseEngine.SetState(battleState, TurnbaseEngine.States.ENEMY_TURN)
    end
    
    return true, nil
end

return TurnbaseEngine
