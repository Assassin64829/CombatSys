local Mgr = {}
LuaCoMgr = Mgr

local Need_Wait_Flag = {}

local Inner = {}

local m_IdIcr = 0
local m_RunningCos = {}

function Mgr.Start(func, args)
    local co = coroutine.create(func)
    m_IdIcr = m_IdIcr + 1
    local coId = m_IdIcr

    local isSucc, yieldParam = coroutine.resume(co, args) --执行到第1个yield处暂停
    if not isSucc then
        if debug and debug.traceback then
            local strackTrace = debug.traceback(co)
            print("Mgr.Start: co first start err: "..strackTrace)
        else
            print("Mgr.Start: co first start err")
        end
        return
    end

    if "dead" ~= coroutine.status(co) then
        local coCtxt = {
            id = coId,
            co = co,
            lastResumeTime = Time.time,
        }
        if args then
            coCtxt.desc = args.desc
        end
        coCtxt.IsWait = Inner.IsNeedWait(yieldParam)

        table.insert(m_RunningCos, coCtxt)
        return coId
    else
        --已执行结束
    end

    return 0
end

function Mgr.StopCoById(coId)
    for i, v in ipairs(m_RunningCos) do
        if v.id == coId then
            v.stopFlag = true
            return true
        end
    end
    return false
end

function Mgr.WaitForSeconds(sec)
    local endTime = Time.time + sec
    local obj = {
        flag = Need_Wait_Flag,
        IsWait = function()
            local leftTime = endTime - Time.time
            return (leftTime > 0)
        end,
    }
    coroutine.yield(obj) --在此处暂停, resume唤醒时将得到yield这边传的参数
end

function Mgr.WaitForFrames(frames)
    local endFrame = Time.frameCount + frames
    local obj = {
        flag = Need_Wait_Flag,
        IsWait = function()
            local leftFrame = endFrame - Time.frameCount
            return (leftFrame > 0)
        end,
    }
    coroutine.yield(obj) --在此处暂停, resume唤醒时将得到yield这边传的参数
end

function Mgr.WaitUntil(predicate)
    local obj = {
        flag = Need_Wait_Flag,
        IsWait = function()
            return not predicate()
        end,
    }

    coroutine.yield(obj)
end

function Inner.IsNeedWait(yieldParam)
    if nil == yieldParam or "table" ~= type(yieldParam) then
        return nil
    end
    if yieldParam.flag ~= Need_Wait_Flag then
        return nil
    end
    
    local isWait = yieldParam.IsWait
    if nil == isWait or "function" ~= type(isWait) then
        return nil
    end
    return isWait
end

function Inner.ResumeCo(i, coCtxt)
    local isSucc, yieldParam = coroutine.resume(coCtxt.co)
    if not isSucc then
        --协程执行失败?
        if debug and debug.traceback then
            local strackTrace = debug.traceback(coCtxt.co)
            print("co resume fail: id:"..coCtxt.id..", "..strackTrace)
        else
            print("co resume fail: id:"..coCtxt.id)
        end
        table.remove(m_RunningCos, i)
    else
        if "dead" == coroutine.status(coCtxt.co) then
            -- print("co finish: id:"..coCtxt.id)
            table.remove(m_RunningCos, i)
        else
            coCtxt.IsWait = Inner.IsNeedWait(yieldParam) --resume后可能还要wait
        end
    end
end

function Mgr.OnUpdate()
    local curTime = Time.time
    
    for i=#m_RunningCos,1,-1 do
        local coCtxt = m_RunningCos[i]

        if coCtxt.stopFlag or "dead" == coroutine.status(coCtxt.co) then
            table.remove(m_RunningCos, i)
        else
            local isWait = coCtxt.IsWait
            if isWait and isWait() then
                --wait
                local deltaTime = curTime - coCtxt.lastResumeTime
                if deltaTime >= 30 then
                    print("!!!!!! co wait too long: id:"..coCtxt.coId..", time:"..deltaTime)
                end
            else
                coCtxt.lastResumeTime = curTime
                Inner.ResumeCo(i, coCtxt)
            end
        end
    end
end