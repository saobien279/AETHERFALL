--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MonsterClass = require(ReplicatedStorage.Modules.Monster)
local AttackEvent = ReplicatedStorage:WaitForChild("Events").AttackEvent :: RemoteEvent
local updateHUDEvent = ReplicatedStorage:WaitForChild("Events").updateHUDEvent :: RemoteEvent
-- ==========================================
-- 1. ĐỊNH NGHĨA MÁY TRẠNG THÁI (Bảng Liệt Kê)
-- ==========================================
local GameState = {
    WAITING = "Waiting",
    PLAYER_TURN = "PlayerTurn",
    ENEMY_TURN = "EnemyTurn",
    GAME_OVER = "GameOver"
}

-- Biến lưu trữ trạng thái hiện tại của trận đấu
local currentState = GameState.WAITING

-- ==========================================
-- 2. CHUẨN BỊ THỰC THỂ
-- ==========================================
local slimePart = Workspace:WaitForChild("Slime") :: Part
local enemyBoss = MonsterClass.new("Slime Nước", 100, slimePart)
local playerHp = 50 -- Giả lập máu của người chơi (Khang)
local CurrentHp = playerHp
local Player = nil


-- ==========================================
-- 3. HÀM CHUYỂN TRẠNG THÁI (State Transition)
-- ==========================================
local function ChangeState(newState: string)
    currentState = newState
    print("\n===============================")
    print("Trạng thái: [" .. currentState .. "]")
    print("===============================")

    if currentState == GameState.PLAYER_TURN then
        print("👉 Đến lượt Khang! (Đang chờ chọn kỹ năng...)")
        
        local plr , act = AttackEvent.OnServerEvent:Wait()

        Player = plr :: Player
        local action = act :: string
        print(action)

        if action == "Attack" then
            print("🗡️ Khang chém Slime!")
            enemyBoss:TakeDamage(40) -- Gây 40 sát thương, thanh máu sẽ tự tụt!

        elseif action == "Heal" then
            print("🗡️ Khang hồi máu!")
            CurrentHp = CurrentHp + 40 -- Gây 40 sát thương, thanh máu sẽ tự tụt!
            if CurrentHp > playerHp then
                CurrentHp = playerHp
            end
                updateHUDEvent:FireClient(Player, CurrentHp, playerHp)
            end

        -- Dùng task.wait để GIẢ LẬP việc bạn tốn 2 giây để bấm nút tấn công
        

        -- Kẻ địch hết máu thì end game, nếu không thì tới lượt kẻ địch
        if enemyBoss.CurrentHp <= 0 then
            ChangeState(GameState.GAME_OVER)
        else
            ChangeState(GameState.ENEMY_TURN)
        end

    elseif currentState == GameState.ENEMY_TURN then
        print("⚠️ Đến lượt Slime Nước!")
        
        task.wait(1.5) -- Giả lập quái vật "suy nghĩ" 1.5 giây
        
        local damageToPlayer = 15
        CurrentHp = CurrentHp - damageToPlayer

        updateHUDEvent:FireClient(Player, CurrentHp, playerHp)

        print("💥 Slime phun axit! Khang mất " .. damageToPlayer .. " Hp. (Máu Khang: " .. CurrentHp .. ")")

        -- Người chơi chết thì end game, nếu không thì trả lại lượt
        if CurrentHp <= 0 then
            ChangeState(GameState.GAME_OVER)
        else
            ChangeState(GameState.PLAYER_TURN)
        end

    elseif currentState == GameState.GAME_OVER then
        print("🏆 TRẬN CHIẾN KẾT THÚC!")
        if CurrentHp > 0 then
            print("Chiến thắng thuộc về Khang!")
        else
            print("Khang đã bị đánh bại...")
        end
    end
end

-- ==========================================
-- 4. KÍCH HOẠT VÒNG LẶP
-- ==========================================
task.wait(3) -- Đợi game load xong UI thanh máu
ChangeState(GameState.PLAYER_TURN) -- Phát súng bắt đầu trận đấu!