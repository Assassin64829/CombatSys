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

-- 攻击协程
function MeeleFighter:TryToAttack()

    if not self.IsAction then
        -- 协程攻击逻辑
        LuaCoMgr.Start(function()
            self:Attack()
        end)
    end

end
-- 攻击
function MeeleFighter:Attack()
    self.IsAction = true
    self.animator:CrossFade("Slash", 0.2)
    LuaCoMgr.WaitForFrames(1)
    local stateInfo = self.animator:GetNextAnimatorStateInfo(1)
    LuaCoMgr.WaitForSeconds(stateInfo.length)
    self.IsAction = false
end

-- 受击协程
function MeeleFighter:OnTriggerEnter(other)
    if other.tag == "Hitbox" and not self.IsAction then
        -- 协程受击逻辑
        LuaCoMgr.Start(function()
            self:PlayHitReaction()
        end)
    end
end
-- 受击
function MeeleFighter:PlayHitReaction()
    self.IsAction = true
    self.animator:CrossFade("Impact", 0.2)
    LuaCoMgr.WaitForFrames(1)
    local stateInfo = self.animator:GetNextAnimatorStateInfo(1)
    LuaCoMgr.WaitForSeconds(stateInfo.length)
    self.IsAction = false
end

return MeeleFighter