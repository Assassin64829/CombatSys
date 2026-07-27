EnemyManager = {}

-- 静态变量
EnemyManager.Instance = nil

-- 攻击间隔
EnemyManager.timeRangeBetweenAttacks = {
    x = 1,
    y = 4
}

-- Unity引用
EnemyManager.player = nil


-- 初始化
function EnemyManager:new()
    local obj = {}

    setmetatable(obj, self)
    self.__index = self


    obj.enemiesInRange = {}

    obj.notAttackingTimer = 2
    obj.timer = 0

    EnemyManager.Instance = obj

    return obj
end


-- 添加敌人
function EnemyManager:AddEnemyInRange(enemy)

    for _, e in ipairs(self.enemiesInRange) do
        if e == enemy then
            return
        end
    end

    table.insert(self.enemiesInRange, enemy)

end



-- 删除敌人
function EnemyManager:RemoveEnemyInRange(enemy)

    for i, e in ipairs(self.enemiesInRange) do

        if e == enemy then
            table.remove(self.enemiesInRange, i)
            break
        end

    end


    if enemy == self.player.TargetEnemy then

        self.player.TargetEnemy =
            self:GetCloseEnemyToDirection(
                self.player:GetTargetingDir()
            )

    end

end



-- Update
function EnemyManager:Update()

    if #self.enemiesInRange == 0 then
        return
    end


    -- 判断是否有敌人在攻击
    local hasAttack = false

    for _, enemy in ipairs(self.enemiesInRange) do

        if enemy:IsInState(EnemyStates.Attack) then
            hasAttack = true
            break
        end

    end



    if not hasAttack then

        if self.notAttackingTimer > 0 then

            self.notAttackingTimer =
                self.notAttackingTimer - CS.UnityEngine.Time.deltaTime

        end


        if self.notAttackingTimer <= 0 then

            local enemy = self:SelectEnemyForAttack()


            if enemy ~= nil then

                enemy:ChangeState(EnemyStates.Attack)


                self.notAttackingTimer =
                    CS.UnityEngine.Random.Range(
                        self.timeRangeBetweenAttacks.x,
                        self.timeRangeBetweenAttacks.y
                    )

            end

        end

    end



    -- 目标检测
    self.timer = self.timer +
        CS.UnityEngine.Time.deltaTime


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



-- 选择攻击敌人
function EnemyManager:SelectEnemyForAttack()


    local result = nil
    local maxTimer = -math.huge


    for _, enemy in ipairs(self.enemiesInRange) do


        if enemy.Target ~= nil
            and enemy:IsInState(EnemyStates.CombatMovement) then


            if enemy.CombatMovementTimer > maxTimer then

                maxTimer = enemy.CombatMovementTimer
                result = enemy

            end

        end


    end


    return result

end



-- 获取正在攻击敌人
function EnemyManager:GetAttackingEnemy()


    for _, enemy in ipairs(self.enemiesInRange) do

        if enemy:IsInState(EnemyStates.Attack) then
            return enemy
        end

    end


    return nil

end



-- 获取方向最近敌人
function EnemyManager:GetCloseEnemyToDirection(direction)


    local minDistance = math.huge

    local closestEnemy = nil


    for _, enemy in ipairs(self.enemiesInRange) do


        local vec =
            enemy.transform.position -
            self.player.transform.position


        vec.y = 0


        -- Vector3.Angle
        local angle =
            CS.UnityEngine.Vector3.Angle(
                direction,
                vec
            )


        -- 点到方向线的距离
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