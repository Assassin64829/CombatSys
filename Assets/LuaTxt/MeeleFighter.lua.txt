MeeleFighter = {}

-- 状态
MeeleFighter.IsAction = false

-- 组件
MeeleFighter.animator = nil

-- 面向对象
function MeeleFighter:new()
    --使用局部变量
    local obj = {}
    self.__index = self
    setmetatable(obj,self)
    return obj
end


function MeeleFighter:Start()
    self.animator = self.gameObject:GetComponentInChildren(typeof(Animator))
end


function MeeleFighter:TryToAttack()

    if not self.IsAction then
        -- 协程攻击逻辑
        LuaCoMgr.Start(function()
            self.IsAction = true
            self.animator:CrossFade("Slash", 0.2)
            LuaCoMgr.WaitForFrames(1)
            local stateInfo = self.animator:GetNextAnimatorStateInfo(1)
            LuaCoMgr.WaitForSeconds(stateInfo.length)
            self.IsAction = false
        end)
    end

end


return MeeleFighter