-- 初始化类别名、工具类
require("InitClass")

-- 测试字符串分割
-- local str = string.split("a,b,c,ess", ",")
-- for i,v in ipairs(str) do
--     print(i, v)
-- end


-- 测试协程
-- LuaCoMgr.Start(function()
--     print("frame 1:"..Time.frameCount)
--     LuaCoMgr.WaitForFrames(1)
--     print("frame 2:"..Time.frameCount)
--     print("time 1:"..Time.time)
--     LuaCoMgr.WaitForSeconds(1.2)
--     print("time 2:"..Time.time)
-- end)