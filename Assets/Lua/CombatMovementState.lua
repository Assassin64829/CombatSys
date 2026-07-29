State:subClass("CombatMovementState")

CombatMovementState.enemy = nil

function CombatMovementState:Enter(owner)
    self.base.Enter(self, owner)
end

function CombatMovementState:Execute()
    self.base.Execute(self)
    print("hello")
end

function CombatMovementState:Exit()
    self.base.Exit(self)
end

return CombatMovementState