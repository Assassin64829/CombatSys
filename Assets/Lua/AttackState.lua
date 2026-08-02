State:subClass("AttackState")

AttackState.enemy = nil
AttackState.attackDistance = 2.5 -- 执行攻击的距离
AttackState.isAttacking = false

AttackState.name = "AttackState"

function AttackState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner

    self.enemy.navAgent.stoppingDistance = self.attackDistance
end

function AttackState:Execute()
    self.base.Execute(self)

    if self.isAttacking then
       return 
    end

    self.enemy.navAgent:SetDestination(self.enemy.target.transform.position)

    if Vector3.Distance(self.enemy.target.transform.position, self.enemy.transform.position) <= self.attackDistance + 0.03 then
        LuaCoMgr.Start(function()
            self:Attack(math.random(0, self.enemy.MeeleFighter.attacks.Count))
            
        end)
    end
end

function AttackState:Exit()
    self.base.Exit(self)
    self.enemy.navAgent:ResetPath()
end

function AttackState:Attack(comboCount)

    comboCount = comboCount or 1 -- 默认值1

    -- self.enemy.animator.applyRootMotion = true
    local access = self.enemy.MeeleFighter:TryToAttack()

    if not access then
        -- print("攻击被打断")
        return
    end

    LuaCoMgr.WaitForFrames(1)
    self.isAttacking = true

    for i = 1, comboCount - 1 do

        LuaCoMgr.WaitUntil(function()
            return self.enemy.MeeleFighter.attackState == AttackStates.Impact
        end)

        self.enemy.MeeleFighter:TryToAttack()

    end

    LuaCoMgr.WaitUntil(function()
        return self.enemy.MeeleFighter.attackState == AttackStates.Idle
    end)

    -- self.enemy.animator.applyRootMotion = false

    self.isAttacking = false

    if self.enemy:IsInState(EnemyState.Attack) then
        self.enemy:ChangeState(EnemyState.RetreatAfterAttack)
    end
end

return AttackState