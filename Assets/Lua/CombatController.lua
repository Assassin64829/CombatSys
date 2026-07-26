CombatController = {}

CombatController.MeeleFighter = nil

function CombatController:Update()

    if Input.GetMouseButtonDown(0) then

        self.MeeleFighter:TryToAttack()

    end

end


return CombatController