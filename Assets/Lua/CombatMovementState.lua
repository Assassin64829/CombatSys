State:subClass("CombatMovementState")

CombatMovementState.enemy = nil
CombatMovementState.distanceToStand = 3.0 -- 停止追逐距离
CombatMovementState.state = nil -- AICombatStates
CombatMovementState.adjustDistanceThreshold = 1.0 -- 开始追逐额外距离
CombatMovementState.timer = 0.0 -- 倒计时计时器
CombatMovementState.idleTimeRange = Vector2(2, 5) -- Idle持续时间随机数
CombatMovementState.circlingTimeRange = Vector2(3, 6) -- Circling持续时间随机数
CombatMovementState.circlingDir = 1 -- 绕圈方向-左右
CombatMovementState.circlingSpeed = Vector2(3, 6) -- 绕圈速度

function CombatMovementState:Enter(owner)
    self.base.Enter(self, owner)
    self.enemy = owner;

    self.enemy.navAgent.stoppingDistance = self.distanceToStand
    self.enemy.combatMovementTimer = 0
    self.enemy.animator:SetBool("combatMode", true)
end

function CombatMovementState:Execute()
    self.base.Execute(self)
    -- 寻敌，未找到则切Idle
    if self.enemy.target == nil then
        self.enemy.target = self.enemy:FindTarget()
        if self.enemy.target == nil then
            self.enemy.target = self.enemy:FindTarget()
        end
    end

    -- 敌人太远开始追逐（最初的state）
    if Vector3.Distance(
            self.enemy.target.transform.position,
            self.enemy.transform.position) >
            self.distanceToStand + self.adjustDistanceThreshold 
        then

        self:StartChase()
    end

    -- 处理state下行为
    if self.state == AICombatStates.Idle then

        -- 随机行为
        if self.timer <= 0 then
            if Random.Range(0, 2) == 0 then
                self:StartIdle()
            else
                self:StartCircling()
            end
        end

    elseif self.state == AICombatStates.Chase then

        -- 停止追逐
        if Vector3.Distance(
            self.enemy.target.transform.position,
            self.enemy.transform.position) <= 
            self.distanceToStand + 0.03
        then
            self:StartIdle()
            return
        end

        -- nav自动寻路追逐
        self.enemy.navAgent:SetDestination(self.enemy.target.transform.position)

    elseif self.state == AICombatStates.Chase then
    
        -- 绕圈结束
        if self.timer <= 0 then
            self:StartIdle()
            return;
        end

        -- 绕圈逻辑
        local vecToTarget = self.enemy.transform.position - self.enemy.target.transform.position
        local rotatePos = Quaternion.Euler(0, self.circlingSpeed * self.circlingDir * Time.deltaTime, 0) * vecToTarget;
        self.enemy.navAgent:Move(rotatePos - vecToTarget);
        self.enemy.transform.rotation = Quaternion.LookRotation(-rotatePos);

    end
        

    -- 计时器
    self.timer = self.timer - Time.deltaTime
    self.enemy.combatMovementTimer = self.enemy.combatMovementTimer + Time.deltaTime

end

function CombatMovementState:StartChase()
    self.state = AICombatStates.Chase
end

function CombatMovementState:StartIdle()
    self.state = AICombatStates.Idle
    self.timer = Random.Range(self.idleTimeRange.x, self.idleTimeRange.y)
end

function CombatMovementState:StartCircling()
    self.state = AICombatStates.Circling
    self.timer = Random.Range(self.circlingTimeRange.x, self.circlingTimeRange.y)
end

function CombatMovementState:Exit()
    self.base.Exit(self)
    self.enemy.combatMovementTimer = 0
end

return CombatMovementState