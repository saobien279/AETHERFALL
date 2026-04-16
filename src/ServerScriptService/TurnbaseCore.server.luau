--local HttpService = game:GetService("HttpService")
local BattleStatsFol = game.ReplicatedStorage.Stats.Battle
local HttpSer = game:GetService("HttpService")
local ActionEvent = game.ReplicatedStorage.Events.ActionHandle

local TesstEnemie = {
	Test1 = {
		Health = 100,
		Damage = 15,
		Name = "Test1"
	},
	Test2 = {
		Health = 200,
		Damage = 20,
		Name = "Test2"
	}
}

local function MakeQueue(A, B)
	if type(A) ~= "table" or type(B) ~= "table" then
		warn("Error: Parameters must be tables")
		return nil
	end

	local Queue = {}

	local maxLength = math.max(#A, #B)

	for i = 1, maxLength do
		-- Check A[i]
		if A[i] ~= nil then
			table.insert(Queue, A[i])
		end

		-- Check B[i]
		if B[i] ~= nil then
			table.insert(Queue, B[i])
		end
	end
	return Queue
end

--Test Batle
local function StartBattle(PlayerStats, EnemyStats,TimeLimit:number)
	print("⚔️ --- BATTLE START: " .. PlayerStats.Name .. " VS " .. EnemyStats.Name .. " --- ⚔️")
    --SetupBattleStats--
    local BattleFol = game.ReplicatedStorage.Stats.Template.Battle:Clone()
    BattleFol.Parent = BattleStatsFol
    BattleFol.Players.Value = HttpSer:JSONEncode({PlayerStats.Name})
    BattleFol.Enemys.Value = HttpSer:JSONEncode({EnemyStats.Name})
    local connect = nil

	while PlayerStats.Health > 0 and EnemyStats.Health > 0 do

		local NextQueue = MakeQueue({PlayerStats}, {EnemyStats})

		for i, v in ipairs(NextQueue) do
            BattleFol.CurrentTurn.Value = v.Name
			if v.Health <= 0 then continue end
            local NextAction = ""
			local Target = NextQueue[(i == 1) and 2 or 1]

            if v.IsPlayer then
                connect = ActionEvent.OnServerEvent:Connect(function(player, Action:string)
                    if Action == nil then return end
                    NextAction = Action
                    connect:Disconnect()
                    connect = nil
                end)
                while NextAction == "" do
                    task.wait(0.1)
                end

                if NextAction == "Attack" then
                    print(v.Name .. " attacks " .. Target.Name .. "!")
			        Target.Health -= v.Damage
			        print(Target.Name .. " HP: " .. Target.Health)
                end
            else
                print(v.Name .. " attacks " .. Target.Name .. "!")
			    Target.Health -= v.Damage
			    print(Target.Name .. " HP: " .. Target.Health)
            end    
			if Target.Health <= 0 then
				print("🏆 " .. v.Name .. " wins the battle!")
				break
			end

			task.wait(1) 
		end

		print("--- End of Round ---")
		task.wait(1)
	end
end

--Player--
game.Players.PlayerAdded:Connect(function(player)
	print("Player joined "..player.Name)
	local playerstats = {
		Health = 100,
		Damage = 10,
		Name = player.Name,
        IsPlayer = true
	}
	local currentEnemy = {
		Health = 200,
		Damage = 20,
		Name = "Test2 (Boss)",
        IsPlayer = false
	}
	task.spawn(function()
		StartBattle(playerstats,currentEnemy,120)
	end)
end)