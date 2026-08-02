Object:subClass("VisionSensor")

-- 获取父节点enemy
function VisionSensor:GetEnemy()

    local parent = self.transform.parent

    if parent == nil then
        return nil
    end

    return self:GetLuaTable(parent.gameObject, "EnemyController")

end

-- 获取指定gameobject上的定lua表
function VisionSensor:GetLuaTable(gameObject, luaScript)

    local behaviours = gameObject:GetComponents(typeof(CS.LuaBehaviour))

    for i = 0, behaviours.Length - 1 do
        local behaviou = behaviours[i]
        if behaviou.luaScript == luaScript then
            return behaviou.LuaTable
        end
    end

    return nil

end

-- 将攻击范围内meeleFighter目标插入enemyController、EnemyManager表中
function VisionSensor:OnTriggerEnter(other)

    local target = self:GetLuaTable(other.gameObject, "MeeleFighter")
    local enemy = self:GetEnemy()

    if target ~= nil and enemy ~= nil then
        table.insert(enemy.targetsInRange, target)
        EnemyManager:AddEnemyInRange(enemy)
    end

end


-- 将攻击范围内meeleFighter目标移出enemyController、EnemyManager表中
function VisionSensor:OnTriggerExit(other)

    local target = self:GetLuaTable(other.gameObject, "MeeleFighter")
    local enemy = self:GetEnemy()

    if target ~= nil and enemy ~= nil then
        for i, v in ipairs(enemy.targetsInRange) do
            if v == target then
                table.remove(enemy.targetsInRange, i)
                break
            end
        end

        EnemyManager:RemoveEnemyInRange(enemy)
    end

end

return VisionSensor