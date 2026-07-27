EnemyController = {}

EnemyState = {
    Idle = "Idle",
    Chase = "Chase",
}

EnemyController.stateDict = nil

function EnemyController:new()
    --使用局部变量
    local obj = {}
    self.__index = self
    setmetatable(obj,self)
    return obj
end

function EnemyController:Start()

    -- 创建状态对象
    self.stateDict[EnemyState.Idle] = IdleState:new()
    self.stateDict[EnemyState.Chase] = ChaseState:new()

    -- 创建状态机
    self.stateMachine = StateMachine:new(self)

    -- 初始状态
    self.stateMachine:ChangeState(self.stateDict[EnemyState.Idle])
end

function EnemyController:ChangeState(state)
    self.stateMachine:ChangeState(self.stateDict[state])
end

function EnemyController:Update()
    self.stateMachine:Execute()
end

return EnemyController