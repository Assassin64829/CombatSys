-- 初始化类别名、工具类
require("Base.Object") -- lua面向对象实现
require("Base.SplitTools") -- 字符串分割方法
require("Base.LuaCoMgr") -- 封装协程
Json = require("Base.JsonUtility") -- Json数据持久化
require("StateMachine") -- 状态机类

-- 脚本
ABMgr = CS.ABMgr.GetInstance()

-- Unity相关
GameObject = CS.UnityEngine.GameObject
Resources = CS.UnityEngine.Resources
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
TextAsset = CS.UnityEngine.TextAsset
Input = CS.UnityEngine.Input
Time = CS.UnityEngine.Time
Space = CS.UnityEngine.Space
Cursor = CS.UnityEngine.Cursor
CursorLockMode = CS.UnityEngine.CursorLockMode
Mathf = CS.UnityEngine.Mathf
KeyCode = CS.UnityEngine.KeyCode
Physics = CS.UnityEngine.Physics
LayerMask = CS.UnityEngine.LayerMask
CharacterController = CS.UnityEngine.CharacterController
Animator = CS.UnityEngine.Animator
Camera = CS.UnityEngine.Camera
Collider = CS.UnityEngine.Collider
NavMeshAgent= CS.UnityEngine.AI.NavMeshAgent

-- 图集对象类
SpriteAtlas = CS.UnityEngine.U2D.SpriteAtlas
Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
Quaternion = CS.UnityEngine.Quaternion

-- UI相关
Image = CS.UnityEngine.UI.Image
Text = CS.UnityEngine.UI.Text
Button = CS.UnityEngine.UI.Button
Toggle = CS.UnityEngine.UI.Toggle
ScrollRect = CS.UnityEngine.UI.ScrollRect

-- 战斗相关
WaitForSeconds = CS.UnityEngine.WaitForSeconds
