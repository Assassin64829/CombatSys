CameraController = {}

CameraController.target = nil
CameraController.bodyHeight = 1.5
CameraController.distance = 5.0

-- 俯仰角
CameraController.minVerticalAngle = -30.0
CameraController.maxVerticalAngle = 45.0

-- 旋转
CameraController.rotationX = 0.0
CameraController.rotationY = 0.0
CameraController.rotationSpeed = 1.0 -- 鼠标灵敏度

-- 平滑旋转控制
CameraController.currentRotX = 0.0
CameraController.currentRotY = 0.0
CameraController.rotateSmoothSpeed = 10.0

CameraController.smoothTargetPos = nil
CameraController.followSmoothSpeed = 10.0

-- 玩家旋转属性
function CameraController:GetPlayerRotation()
    return Quaternion.Euler(
        0,
        self.rotationY,
        0
    )
end

function CameraController:Start()
    -- 如果target未被注入，则尝试从全局PlayerController获取
    if self.target == nil then
        self.target = PlayerController.transform
    end

    Cursor.visible = false
    Cursor.lockState = CursorLockMode.Locked
    self.smoothTargetPos = self.target.position
end

function CameraController:Update()
    -- 按 Alt 调出鼠标
    if Input.GetKey(KeyCode.LeftAlt) then
        Cursor.visible = true
        Cursor.lockState = CursorLockMode.None
    else
        Cursor.visible = false
        Cursor.lockState = CursorLockMode.Locked
    end

    -- 鼠标旋转输入
    self.rotationX = self.rotationX - Input.GetAxis("Mouse Y") * self.rotationSpeed
    self.rotationY = self.rotationY + Input.GetAxis("Mouse X") * self.rotationSpeed

    -- 俯仰角控制
    self.rotationX = Mathf.Clamp(
        self.rotationX,
        self.minVerticalAngle,
        self.maxVerticalAngle
    )

    -- 平滑旋转
    self.currentRotX = Mathf.Lerp(
        self.currentRotX,
        self.rotationX,
        Time.deltaTime * self.rotateSmoothSpeed
    )
    self.currentRotY = Mathf.Lerp(
        self.currentRotY,
        self.rotationY,
        Time.deltaTime * self.rotateSmoothSpeed
    )
    local targetRotation =
        Quaternion.Euler(
            self.currentRotX,
            self.currentRotY,
            0
        )
    self.transform.rotation = targetRotation

    -- 平滑跟随
    self.smoothTargetPos =
        Vector3.Lerp(
            self.smoothTargetPos,
            self.target.position,
            Time.deltaTime * self.followSmoothSpeed
        )
    self.transform.position =
        self.smoothTargetPos
        + Vector3(0, self.bodyHeight, 0)
        - targetRotation * Vector3(0, 0, self.distance)

end

return CameraController
