Object:subClass("State")
-- 状态基类
function State:Enter(owner)
    self.owner = owner
end

function State:Execute()

end

function State:Exit()

end
