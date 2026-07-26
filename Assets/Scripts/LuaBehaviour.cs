using System;
using UnityEngine;
using XLua;

/// <summary>
/// Lua生命周期桥接组件：挂在需要Update/FixedUpdate等生命周期的GameObject上
/// 通过指定luaScript名称，自动加载对应Lua模块并桥接生命周期函数
/// </summary>
public class LuaBehaviour : MonoBehaviour
{
    [Tooltip("Lua模块名，如 CameraController")]
    public string luaScript;

    private LuaTable luaTable;
    private Action<LuaTable> luaAwake;
    private Action<LuaTable> luaStart;
    private Action<LuaTable> luaUpdate;
    private Action<LuaTable> luaFixedUpdate;
    private Action<LuaTable> luaLateUpdate;
    private Action<LuaTable> luaOnDestroy;
    private LuaFunction onTriggerEnter;

    void Awake()
    {
        if (string.IsNullOrEmpty(luaScript)) return;
        LuaMgr.Instance.Init(); // 确保已有解析器
        
        // 加载Lua模块并获取返回的table
        object[] result = LuaMgr.Instance.DoLuaFileReturn(luaScript);
        if (result != null && result.Length > 0)
        {
            luaTable = result[0] as LuaTable;
            if (luaTable != null)
            {
                // 有new就new
                LuaFunction newFunc = luaTable.Get<LuaFunction>("new");
                if(newFunc != null)
                {
                    luaTable = newFunc.Call(luaTable)[0] as LuaTable;
                }

                // 把C#侧的transform和gameObject注入给Lua
                luaTable.Set("transform", transform);
                luaTable.Set("gameObject", gameObject);

                // 绑定生命周期函数（Lua中可选实现）
                luaAwake = luaTable.Get<Action<LuaTable>>("Awake");
                luaStart = luaTable.Get<Action<LuaTable>>("Start");
                luaUpdate = luaTable.Get<Action<LuaTable>>("Update");
                luaFixedUpdate = luaTable.Get<Action<LuaTable>>("FixedUpdate");
                luaLateUpdate = luaTable.Get<Action<LuaTable>>("LateUpdate");
                luaOnDestroy = luaTable.Get<Action<LuaTable>>("OnDestroy");

                // 绑定触发事件
                onTriggerEnter = luaTable.Get<LuaFunction>("OnTriggerEnter");

                luaAwake?.Invoke(luaTable);
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (onTriggerEnter != null)
        {
            onTriggerEnter.Call(luaTable, other);
        }
    }

    void Start()
    {
        // gameobject下其他lua注入
        LuaBehaviour[] behaviours = gameObject.GetComponents<LuaBehaviour>();
        foreach (var other in behaviours)
        {
            if(other.luaScript != luaScript && other.luaTable != null)
            {
                luaTable.Set(other.luaScript, other.luaTable);
            }
        }
        luaStart?.Invoke(luaTable);
    }
    void Update() => luaUpdate?.Invoke(luaTable);
    void FixedUpdate() => luaFixedUpdate?.Invoke(luaTable);
    void LateUpdate() => luaLateUpdate?.Invoke(luaTable);

    void OnDestroy()
    {
        luaOnDestroy?.Invoke(luaTable);
        luaTable?.Dispose();
        luaTable = null;
    }
}
