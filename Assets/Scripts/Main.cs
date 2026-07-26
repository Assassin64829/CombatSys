using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class Main : MonoBehaviour
{

    private LuaTable luaCoMgr;
    private LuaFunction luaCoMgr_OnUpdate;
    void Start()
    {
        // 修改：改为由LuaBehaviour的Awake调用
        // LuaMgr.Instance.Init();
        // LuaMgr.Instance.DoLuaFile("Main");
        luaCoMgr = LuaMgr.Instance.Global.Get<LuaTable>("LuaCoMgr");
        luaCoMgr_OnUpdate = luaCoMgr.Get<LuaFunction>("OnUpdate");
    }

    void Update()
    {
        luaCoMgr_OnUpdate.Action(0);
    }
}
