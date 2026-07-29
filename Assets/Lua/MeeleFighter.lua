Object:subClass("MeeleFighter")

-- 状态
MeeleFighter.IsAction = false

-- 组件
MeeleFighter.animator = nil

MeeleFighter.attackState = nil
MeeleFighter.doCombo = false
MeeleFighter.comboCount = 0.0
MeeleFighter.rotationSpeed = 500.0


-- 事件
MeeleFighter.OnGotHit = {}
MeeleFighter.OnHitComplete = {}

function MeeleFighter:new()

    local obj = MeeleFighter.base.new(self)

    obj.OnGotHit = {}
    obj.OnHitComplete = {}

    return obj

end

function MeeleFighter:Start()
    self.animator = self.gameObject:GetComponentInChildren(typeof(Animator))

    self:DisableAllHitbox()
end

-- 不攻击时禁用武器碰撞
function MeeleFighter:EnableHitbox()
    if self.Weapon ~= nil then
        local weaponCollider = self.Weapon:GetComponent(typeof(Collider))
        weaponCollider.enabled = true
    end
end

-- 不攻击时禁用武器碰撞
function MeeleFighter:DisableAllHitbox()
    if self.Weapon ~= nil then
        local weaponCollider = self.Weapon:GetComponent(typeof(Collider))
        weaponCollider.enabled = false
    end
end

-- 攻击协程
function MeeleFighter:TryToAttack(attackDir)
    if not self.IsAction then
        -- 协程攻击逻辑
        LuaCoMgr.Start(function()
            self:Attack(attackDir)
        end)
    -- 激活连击
    elseif self.attackState == AttackState.Impact or self.attackState == AttackState.CoolDown then
         self.doCombo = true
    end
end
-- 攻击
function MeeleFighter:Attack(attackDir)
    self.IsAction = true
    self.attackState = AttackState.WindUp

    -- 根据连击层数执行不同攻击动作
    self.animator:CrossFade(self.attacks[self.comboCount].AnimName, 0.2)
    
    LuaCoMgr.WaitForFrames(1)
    local stateInfo = self.animator:GetNextAnimatorStateInfo(1)

    local timer = 0.0

    -- 一整个动作在while中进行
    while timer <= stateInfo.length do
        timer = timer + Time.deltaTime
        local progress = timer / stateInfo.length -- 计算动作进度

        -- 攻击时面对对方
        if attackDir ~= nil then
            self.transform.rotation = Quaternion.RotateTowards(self.transform.rotation, Quaternion.LookRotation(attackDir), self.rotationSpeed);
        end

        if self.attackState == AttackState.WindUp then
            if progress >= self.attacks[self.comboCount].ImpactStartTime then
                self.attackState = AttackState.Impact
                self:EnableHitbox()
            end
        elseif self.attackState == AttackState.Impact then
            if progress >= self.attacks[self.comboCount].ImpactEndTime then
                self.attackState = AttackState.CoolDown;
                self:DisableAllHitbox()
            end
        elseif self.attackState == AttackState.CoolDown then
            if self.doCombo then
                self.doCombo = false
                self.comboCount = (self.comboCount + 1) % self.attacks.Count

                -- 执行 comboCount 的连击
                LuaCoMgr.Start(function()
                    self:Attack()
                end)

                return -- 触发连击不执行结束逻辑

            end
        end
        
        LuaCoMgr.WaitForFrames(1)
    end
    -- 动作结束，状态重置
    self.attackState = AttackState.Idle;
    self.comboCount = 0.0
    self.IsAction = false
end

-- 受击协程
function MeeleFighter:OnTriggerEnter(other)
    if other.tag == "Hitbox" and not self.IsAction then
        -- 协程受击逻辑
        LuaCoMgr.Start(function()
            self:PlayHitReaction(other:GetComponentInParent(typeof(CS.LuaBehaviour)).transform)
        end)
    end
end
-- 受击
function MeeleFighter:PlayHitReaction(attacker)
    self.IsAction = true

    -- 转向
    local dispVec = attacker.position - self.transform.position
    dispVec.y = 0
    self.transform.rotation = Quaternion.LookRotation(dispVec)

    self.animator:CrossFade("Impact", 0.2)
    LuaCoMgr.WaitForFrames(1)
    local stateInfo = self.animator:GetNextAnimatorStateInfo(1)
    LuaCoMgr.WaitForSeconds(stateInfo.length * 0.7) -- 连击状态提前结束

    for _, func in ipairs(self.OnGotHit) do
        func()
    end
    for _, func in ipairs(self.OnHitComplete) do
        func()
    end

    self.IsAction = false
end

return MeeleFighter