State:subClass("AttackState")

AttackState.enemy = nil
AttackState.attackDistance = 1.5 -- 执行攻击的距离
AttackState.isAttacking = false

function AttackState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner;

    self.enemy.navAgent.stoppingDistance = self.attackDistance
end

function AttackState:Execute()
    self.base.Execute(self)

    if self.isAttacking then
       return 
    end

    self.enemy.navAgent:SetDestination(self.enemy.target.transform.position);


    if Vector3.Distance(self.enemy.target.transform.position, self.enemy.transform.position) <= self.attackDistance + 0.03 then
        LuaCoMgr.Start(function()
            self:Attack(Random.Range(0, self.enemy.MeeleFighter.attacks.Count + 1))
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
    self.enemy.MeeleFighter:TryToAttack()

    LuaCoMgr.WaitForFrames(1)
    self.isAttacking = true

    for i = 1, comboCount - 1 do

        LuaCoMgr.WaitUntil(function()
            return self.enemy.MeeleFighter.AttackState == AttackStates.CoolDown
        end)

        self.enemy.MeeleFighter:TryToAttack()

    end

    LuaCoMgr.WaitUntil(function()
        return self.enemy.MeeleFighter.AttackState == AttackStates.Idle
    end)

    -- self.enemy.animator.applyRootMotion = false

    self.isAttacking = false;

    if self.enemy:IsInState(EnemyState.Attack) then
        self.enemy:ChangeState(EnemyState.RetreatAfterAttack)
    end
end

return AttackState