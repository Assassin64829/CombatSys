State:subClass("IdleState")

IdleState.enemy = nil

IdleState.name = "IdleState"

function IdleState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner;
    
    self.enemy.animator:SetBool("combatMode", false)
end

function IdleState:Execute()
    self.base.Execute(self)
    self.enemy.target = self.enemy:FindTarget()
    if self.enemy.target then
        self.enemy:ChangeState(EnemyState.CombatMovement);
    end
end

function IdleState:Exit()
    self.base.Exit(self)
end

return IdleState