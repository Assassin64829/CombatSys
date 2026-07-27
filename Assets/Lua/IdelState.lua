State:subClass("IdleState")
-- 状态基类
function IdleState:Enter(owner)
    self.base.Enter(self, owner)
end

function IdleState:Execute()
    self.base.Execute(self)
end

function IdleState:Exit()
    self.base.Exit(self)
end
