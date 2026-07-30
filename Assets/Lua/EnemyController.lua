Object:subClass("EnemyController")

EnemyController.targetsInRange = {}
EnemyController.stateDict = {}

EnemyController.fov = 180
EnemyController.target = nil -- 索敌目标MeeleFighter

EnemyController.navAgent = nil
EnemyController.animator = nil

EnemyController.stateMachine = nil

EnemyController.prePos = nil
EnemyController.combatMovementTimer = 0

function EnemyController:new()

    local obj = EnemyController.base.new(self)

    obj.targetsInRange = {}
    obj.stateDict = {}

    return obj

end


function EnemyController:Start()
    -- 初始化 枚举-状态类 字典
    self.stateDict[EnemyState.Idle] = self.IdleState
    self.stateDict[EnemyState.CombatMovement] = self.CombatMovementState
    self.stateDict[EnemyState.Attack] = self.AttackState
    self.stateDict[EnemyState.RetreatAfterAttack] = self.RetreatAfterAttackState
    self.stateDict[EnemyState.GettingHitState] = self.GettingHitState

    -- 组件获取
    self.navAgent = self.gameObject:GetComponent(typeof(NavMeshAgent))
    self.animator = self.gameObject:GetComponentInChildren(typeof(Animator))

    -- 初始状态
    self.stateMachine = StateMachine:new(self)
    self.stateMachine:ChangeState(self.stateDict[EnemyState.Idle])

    self.prePos = self.transform.position

    -- 受击回调
    table.insert(
        self.MeeleFighter.OnGotHit,
        function()
            self:ChangeState(
                EnemyState.GettingHitState
            )
        end
    )

end

-- 状态行为、动作适配Mav移动
function EnemyController:Update()

    self.stateMachine:Execute()

    local deltaPos = Vector3.zero

    -- 不使用根运动
    if not self.animator.applyRootMotion then
        deltaPos = self.transform.position - self.prePos        
    end

    -- 计算向前分速度（播放对应程度向前动作）
    local velocity = deltaPos / Time.deltaTime
    local forwardSpeed =
        Vector3.Dot(
            velocity,
            self.transform.forward
        )
    self.animator:SetFloat(
        "forwardSpeed",
        forwardSpeed / self.navAgent.speed,
        0.2,
        Time.deltaTime
    )

    -- 计算向右分速度
    local angle =
        Vector3.SignedAngle(
            self.transform.forward,
            velocity,
            Vector3.up
        )
    local strafeSpeed =
        Mathf.Sin(angle * Mathf.Deg2Rad)
    self.animator:SetFloat(
        "strafeSpeed",
        strafeSpeed,
        0.2,
        Time.deltaTime
    )

    self.prePos = self.transform.position

end

-- 状态切换
function EnemyController:ChangeState(state)
    self.stateMachine:ChangeState(self.stateDict[state])
end

-- 状态判断
function EnemyController:IsInState(state)
    return self.stateMachine.currentState == self.stateDict[state]
end

-- 从检测范围内目标中，找出位于fov视野范围内目标
function EnemyController:FindTarget()

    for _, target in ipairs(self.targetsInRange) do

        local vecToTarget = target.transform.position - self.transform.position
        local angle = Vector3.Angle(self.transform.forward, vecToTarget)

        if angle < self.fov * 0.5 then
            return target
        end

    end

    return nil

end

return EnemyController