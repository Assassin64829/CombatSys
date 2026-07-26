PlayerController = {}

-- 参数
PlayerController.moveSpeed = 5.0
PlayerController.rotationSpeed = 500.0

-- 组件
PlayerController.animator = nil
PlayerController.characterController = nil

-- 旋转
PlayerController.targetRotation = nil

-- 重力
PlayerController.groundCheckRadius = 0.2
PlayerController.groundCheckOffdet = Vector3.zero
PlayerController.groundLayer = nil

PlayerController.isGrounded = false
PlayerController.ySpeed = 0.0

-- 输入方向
PlayerController.InputDir = Vector3.zero

function PlayerController:Start()
    self.animator = self.gameObject:GetComponentInChildren(typeof(Animator))
    self.characterController = self.gameObject:GetComponent(typeof(CharacterController))
    self.targetRotation = self.transform.rotation
    self.groundLayer = LayerMask.GetMask("Obstacle")
    self.groundCheckOffdet = Vector3(0, 0.18, 0.07)
end

function PlayerController:Update()

    local h = Input.GetAxis("Horizontal")
    local v = Input.GetAxis("Vertical")
    local moveAmount = Mathf.Clamp01(Mathf.Abs(h) + Mathf.Abs(v))
    local moveInput = Vector3(h, 0, v).normalized

    -- 计算移动方向
    local moveDir = moveInput
    if CameraController ~= nil then
        moveDir = CameraController:GetPlayerRotation() * moveInput
    end
    self.InputDir = moveDir

    -- 重力模拟
    self:GroundCheck()
    if self.isGrounded then
        self.ySpeed = -0.5
    else
        self.ySpeed = self.ySpeed + Physics.gravity.y * Time.deltaTime
    end

    -- 移动
    local move = moveDir * self.moveSpeed
    move.y = self.ySpeed
    self.characterController:Move(
        move * Time.deltaTime
    )

    -- 平滑转向
    if moveAmount > 0 then
        self.targetRotation = Quaternion.LookRotation(moveDir)
    end
    self.transform.rotation =
        Quaternion.RotateTowards(
            self.transform.rotation,
            self.targetRotation,
            self.rotationSpeed
            * Time.deltaTime
        )

    -- 动作
    self.animator:SetFloat(
        "forwardSpeed",
        moveAmount,
        0.2,
        Time.deltaTime
    )

    
end

-- 着地判断
function PlayerController:GroundCheck()
    self.isGrounded =
        Physics.CheckSphere(
            self.transform:TransformPoint(
                self.groundCheckOffdet
            ),
            self.groundCheckRadius,
            self.groundLayer
        )

end

return PlayerController
