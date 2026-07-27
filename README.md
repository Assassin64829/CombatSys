# CombatSys

### Lua部分

#### Lua 脚本管理 + 双模式加载器

自定义 AddLoader，分别重定向到AB包文件夹和Assets/Lua文件夹。允许在 Assets/Lua 下自由创建子文件夹来分模块管理 .lua 文件，提升脚本组织性；同时 AB 包加载器自动忽略 require 路径中的目录层级，打包后文件平铺在单个 lua 包中，开发期目录结构不干扰运行期加载，兼顾开发体验与包体效率



#### Lua 自动打包预处理工具

编写 LuaCopyEditor 编辑器工具，递归获取 Assets/Lua 下所有子文件夹内的 .lua 文件，统一 copy 出 .lua.txt 并归入 LuaTxt 目录，同时自动指定打包包名，省去手动转换和配置步骤



#### Lua 生命周期桥接组件

编写 LuaBehaviour 通用桥接组件，将 Unity 的 生命周期自动映射到对应 Lua 模块的函数，同时在 Awake 中向 lua 表注入gameObject和 transform 以便相关调用。只需在 GameObject 上挂载组件并指定 Lua 脚本名，实现在Lua 端编写核心逻辑。

进一步补充同一GameObject下其他 LuaBehaviour 中所绑定的lua表的获取，并以“Lua 脚本名-Lua表”的对应形式在 Start 中注入到本 LuaBehaviour 关联的 lua 表中，便于lua中直接获取并使用同一GameObject下关联的其他lua表对象



#### Lua面向对象模拟

LuaBehaviour 通过 LuaEnv 加载对应 Lua 脚本并获取返回的 Lua表。若 Table 没有 new 方法，则直接作为单例使用；若存在 new 方法，则调用 new 创建独立 Lua 表实例，并通过元表机制继承原 Table 的方法，模拟面向对象

```lua
function Object:new()
    local obj = {}
    self.__index = self
    setmetatable(obj,self)
    return obj
end
```

状态类模拟继承，在State基类基础上拓展多状态类功能

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







