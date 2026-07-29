--面向对象实现 
Object = {}

-- 表需要再new中初始化
-- 值类型（number、string、boolean 等）没有"修改自身"的操作，改变它们只能通过重新赋值，因此会在实例上创建（或覆盖）字段
-- 而 table 是可变对象，既可以重新赋值，也可以直接修改内部内容，因此如果共享同一张表，就会影响所有实例

--实例化
function Object:new()
	local obj = {}
	self.__index = self
	setmetatable(obj, self)
	return obj
end

--继承
function Object:subClass(className)
	_G[className] = {}
	local obj = _G[className]
	obj.base = self
	self.__index = self
	setmetatable(obj, self)
end