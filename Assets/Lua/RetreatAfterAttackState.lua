State:subClass("RetreatAfterAttackState")

RetreatAfterAttackState.enemy = nil
RetreatAfterAttackState.backwardWalkSpeed = 1.5 -- 后退速度
RetreatAfterAttackState.distanceToRetreat = 3 -- 停止后退距离

function RetreatAfterAttackState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner;
end

function RetreatAfterAttackState:Execute()
    self.base.Execute(self)

    if Vector3.Distance(self.enemy.target.transform.position, self.enemy.transform.position) >= self.distanceToRetreat then
        self.enemy:ChangeState(EnemyState.CombatMovement)
        return
    end

    -- 后退逻辑
    local vecToTarget = self.enemy.target.transform.position - self.enemy.transform.position
    self.enemy.navAgent:Move(-vecToTarget.normalized * self.backwardWalkSpeed * Time.deltaTime)
    vecToTarget.y = 0
    -- 保持看向敌人
    self.transform.rotation = Quaternion.RotateTowards(self.transform.rotation, Quaternion.LookRotation(vecToTarget), 500 * Time.deltaTime)
end

function RetreatAfterAttackState:Exit()
    self.base.Exit(self)
end

return RetreatAfterAttackState