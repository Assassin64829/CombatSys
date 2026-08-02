CombatController = {}

CombatController.animator = nil
CombatController.combatMode = false
CombatController.targetEnemy = nil
CombatController.camera = nil

function CombatController:SetTargetEnemy(enemy)

    self.targetEnemy = enemy

    if enemy == nil then
        self:SetCombatMode(false)
    end

end


function CombatController:SetCombatMode(value)

    self.combatMode = value

    if self.targetEnemy == nil then
        self.combatMode = false
    end

    self.animator:SetBool("combatMode", self.combatMode)

end

function CombatController:Start()

    self.animator = self.gameObject:GetComponentInChildren(typeof(Animator))
    EnemyManager.player = self

end

function CombatController:Update()

    -- 朝向敌人、执行攻击
    if Input.GetMouseButtonDown(0) then

        local enemyToAttack = EnemyManager:GetCloseEnemyToDirection(
            PlayerController.InputDir
        )

        local dirToAttack = nil

        if enemyToAttack ~= nil then
            dirToAttack = enemyToAttack.transform.position - self.transform.position
        end

        self.MeeleFighter:TryToAttack(dirToAttack)

        self:SetCombatMode(true)

    end

    -- 进入/退出攻击状态
    if Input.GetMouseButtonDown(2) then
        self:SetCombatMode(not self.combatMode)
    end

end

function CombatController:GetTargetingDir()
    if not self.combatMode then
        local vecFromCam = self.transform.position - CameraController.transform.position
        vecFromCam.y = 0
        return vecFromCam.normalized
    
    else
        return self.transform.forward
    end
end

return CombatController