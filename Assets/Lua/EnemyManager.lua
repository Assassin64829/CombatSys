EnemyManager = {}

-- cd重置范围
EnemyManager.timeRangeBetweenAttacks = Vector2(1, 4)

-- 范围内敌人（触发攻击状态的敌人）
EnemyManager.enemiesInRange = {}

-- 攻击冷却
EnemyManager.notAttackingTimer = 2.0
EnemyManager.timer = 0.0

EnemyManager.player = nil

function EnemyManager:Start()
    self.player = CombatController
end

-- 添加敌人（进入范围）
function EnemyManager:AddEnemyInRange(enemy)

    for _, e in ipairs(self.enemiesInRange) do
        if e == enemy then
            return
        end
    end

    table.insert(self.enemiesInRange, enemy)

end

-- 删除敌人（离开范围）
function EnemyManager:RemoveEnemyInRange(enemy)

    for i, e in ipairs(self.enemiesInRange) do

        if e == enemy then
            table.remove(self.enemiesInRange, i)
            break
        end

    end

    -- 玩家重新索敌离视线向量最近的敌人
    if enemy == EnemyManager.player.targetEnemy then

        EnemyManager.player.targetEnemy =
            self:GetCloseEnemyToDirection(
                EnemyManager.player:GetTargetingDir()
            )

    end

end

function EnemyManager:Update()

    -- 是否有攻击状态敌人
    if #self.enemiesInRange == 0 then
        return
    end

    -- 判断是否有敌人在攻击
    local hasAttack = false

    for _, enemy in ipairs(self.enemiesInRange) do

        if enemy:IsInState(EnemyState.Attack) then
            hasAttack = true
            break
        end

    end


    -- 间歇派出敌人攻击
    if not hasAttack then
        -- 敌人攻击CD
        if self.notAttackingTimer > 0 then
            self.notAttackingTimer = self.notAttackingTimer - Time.deltaTime
        end

        if self.notAttackingTimer <= 0 then

            local enemy = self:SelectEnemyForAttack()

            if enemy ~= nil then

                enemy:ChangeState(EnemyState.Attack)

                self.notAttackingTimer =
                    Random.Range(
                        self.timeRangeBetweenAttacks.x,
                        self.timeRangeBetweenAttacks.y
                    )

            end

        end

    end

    -- 每0.1秒切换玩家索敌距离视线向量最近敌人
    self.timer = self.timer + Time.deltaTime

    if self.timer >= 0.1 then

        self.timer = 0


        local closestEnemy =
            self:GetCloseEnemyToDirection(
                self.player:GetTargetingDir()
            )


        if closestEnemy ~= nil
            and closestEnemy ~= self.player.targetEnemy then

            self.player.targetEnemy = closestEnemy

        end

    end

end



-- 最久未执行攻击的敌人
function EnemyManager:SelectEnemyForAttack()


    local result = nil
    local maxTimer = -math.huge


    for _, enemy in ipairs(self.enemiesInRange) do


        if enemy.Target ~= nil
            and enemy:IsInState(EnemyState.CombatMovement) then


            if enemy.combatMovementTimer > maxTimer then

                maxTimer = enemy.combatMovementTimer
                result = enemy

            end

        end


    end

    return result

end



-- 获取正在攻击的敌人
function EnemyManager:GetAttackingEnemy()


    for _, enemy in ipairs(self.enemiesInRange) do

        if enemy:IsInState(EnemyState.Attack) then
            return enemy
        end

    end

    return nil

end



-- 获取视线方向最近敌人
function EnemyManager:GetCloseEnemyToDirection(direction)


    local minDistance = math.huge

    local closestEnemy = nil


    for _, enemy in ipairs(self.enemiesInRange) do

        local vec = enemy.transform.position - self.player.transform.position
        vec.y = 0
        local angle = Vector3.Angle(direction, vec)

        -- 点到方向线的距离
        -- magnitude：向量长度
        local distance =
            vec.magnitude *
            math.sin(
                angle * math.pi / 180
            )


        if distance < minDistance then

            minDistance = distance
            closestEnemy = enemy

        end

    end

    return closestEnemy

end



return EnemyManager