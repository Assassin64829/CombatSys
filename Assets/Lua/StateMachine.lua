StateMachine = {}

StateMachine.currentState = nil
StateMachine.owner = nil

function StateMachine:new(owner)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)

    obj.owner = owner
    obj.currentState = nil

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

return StateMachine