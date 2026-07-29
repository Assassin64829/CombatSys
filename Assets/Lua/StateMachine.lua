Object:subClass("StateMachine")

StateMachine.currentState = nil
StateMachine.owner = nil -- EnemyController对象

function StateMachine:new(owner)
    local obj = StateMachine.base.new(self)

    obj.owner = owner

    return obj
end

function StateMachine:ChangeState(newState)
    if self.currentState then
        self.currentState:Exit()
    end

    self.currentState = newState

    if self.currentState then
        self.currentState:Enter(self.owner)
    end
end

function StateMachine:Execute()
    if self.currentState then
        self.currentState:Execute()
    end
end