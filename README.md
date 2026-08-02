# CombatSys

### Lua部分

#### Lua 脚本管理 + 双模式加载器

自定义 AddLoader，分别重定向到AB包文件夹和Assets/Lua文件夹。允许在 Assets/Lua 下自由创建子文件夹来分模块管理 .lua 文件，提升脚本组织性；同时 AB 包加载器自动忽略 require 路径中的目录层级，打包后文件平铺在单个 lua 包中，开发期目录结构不干扰运行期加载，兼顾开发体验与包体效率



#### Lua 自动打包预处理工具

编写 LuaCopyEditor 编辑器工具，递归获取 Assets/Lua 下所有子文件夹内的 .lua 文件，统一 copy 出 .lua.txt 并归入 LuaTxt 目录，同时自动指定打包包名，省去手动转换和配置步骤



#### Lua 生命周期桥接

编写 LuaBehaviour 通用桥接组件，将 Unity 的 生命周期自动映射到对应 Lua 模块的函数，同时在 Awake 中向 lua 表注入gameObject和 transform 以便相关调用。只需在 GameObject 上挂载组件并指定 Lua 脚本名，实现在Lua 端编写核心逻辑。

进一步补充同一GameObject下其他 LuaBehaviour 中所绑定的lua表的获取，并以“Lua 脚本名-Lua表”的对应形式在 Start 中注入到本 LuaBehaviour 关联的 lua 表中，便于lua中直接获取并使用同一GameObject下关联的其他lua表对象

进一步补充可选指定 ScriptableObject 数据、GameObject 对象注入到lua表



#### Lua面向对象模拟

LuaBehaviour 通过 LuaEnv 加载对应 Lua 脚本并获取返回的 Lua表。若 Table 没有 new 方法，则直接作为单例使用；若存在 new 方法，则调用 new 创建独立 Lua 表实例，并通过元表机制继承原 Table 的方法，模拟面向对象

```lua
function Object:new()
    local obj = {}、
    self.__index = self
    setmetatable(obj,self)
    return obj
end
```

状态基类模拟继承，在State基类基础上拓展各个敌人状态类的行为逻辑

```lua
function Object:subClass(className)
	--根据名字生成一张表 就是一个类
	_G[className] = {}
	local obj = _G[className]
	--设置自己的“父类”
	obj.base = self
	--给子类设置元表 以及 __index
	self.__index = self
	setmetatable(obj, self)
end
```



### 战斗部分

#### 状态机设计

常态移动采用 1D 混合树，用 forwardSpeed 驱动 Idle、Walk、Move 三个动作之间的平滑过渡；战斗移动采用 2D Freeform Directional 混合树，用 forwardSpeed 控制前后移动、strafeSpeed 控制左右移动，实现全方向战斗移动。两种移动模式通过 Animator 布尔参数 combatMode 进行切换；新增攻击 Layer（Weight=1），配置攻击、受击等动作状态，并统一连接至 Empty 状态，通过代码调用 Animator.CrossFade 实现动作的平滑切换



#### 第三人称玩家控制

相机采用 Lerp 实现平滑跟随与视角过渡；角色通过水平、竖直输入控制移动，并结合重力模拟与地面检测实现贴地及自然下落；鼠标左键触发攻击并根据输入方向自动锁定目标、朝向目标攻击；鼠标中键切换常态移动/战斗移动模式，战斗模式下角色始终面向目标环绕移动



#### 攻击受击

基于协程驱动攻击、受击流程，根据 ScriptableObject 配置的攻击数据构建攻击状态机，将攻击划分为前摇（WindUp）、执行（Impact）和后摇（CoolDown）三阶段；在执行、后摇阶段缓存连击输入，并于后摇阶段根据连击标识递归执行攻击协程，实现多段连击；受击基于武器 Trigger 碰撞检测完成命中判定，并通过事件回调机制驱动敌人受击后的状态切换



#### 敌人管理

维护进入攻击状态的敌人列表，结合攻击冷却、敌人状态及攻击优先级设计敌人调度机制，采用**最久未攻击优先**策略实现敌人轮流攻击，提升战斗节奏；定时以玩家 forward 方向为基准计算距离视线最近的敌人，实现目标锁定持续索敌



#### 敌人状态控制

基于 FSM 架构设计敌人 AI 状态控制，通过状态基类统一管理 Enter、Execute、Exit 生命周期，实现状态逻辑解耦与行为扩展；Idle 状态负责检测视野范围内目标并触发战斗流程；CombatMovement 状态结合 NavMesh 实现目标追踪、战斗距离保持及环绕移动；Attack 状态结合近战系统完成攻击连击逻辑，并通过 RetreatAfterAttack 状态调整与玩家距离，最终重新回到战斗移动状态；受击后进入 GettingHit 状态执行僵直处理。形成完整敌人 AI 行为闭环
