State:subClass("GettingHitState")

GettingHitState.enemy = nil
GettingHitState.stunnTime = 1.5 -- 角色攻击结束后，脱离受击状态的时间

GettingHitState.name = "GettingHitState"

function GettingHitState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner;
    table.insert(
        self.MeeleFighter.OnHitComplete,
        function()
            LuaCoMgr.Start(function()
                self:GoToCombatMovement()
            end)
        end
    )
end

function GettingHitState:GoToCombatMovement()
    LuaCoMgr.WaitForSeconds(self.stunnTime)
    self.enemy:ChangeState(EnemyState.CombatMovement)
end

function GettingHitState:Execute()
    self.base.Execute(self)
end

function GettingHitState:Exit()
    self.base.Exit(self)
end

return GettingHitState