using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

public class LuaMgr
{
    private static LuaMgr instance = new LuaMgr();
    public static LuaMgr Instance => instance;

    private LuaEnv luaEnv;

    // Lua解析器
    public LuaEnv LuaEnv
    {
        get
        {
            return luaEnv;
        }
    }

    // _G
    public LuaTable Global
    {
        get
        {
            return luaEnv.Global;
        }
    }

    // 初始化解析器（包括重定向）并加载入口脚本
    public void Init()
    {
        if (luaEnv != null)
            return;
        luaEnv = new LuaEnv();
        luaEnv.AddLoader(MyCustomLoader); // 从Lua文件夹加载（开发用）
        luaEnv.AddLoader(MyCustomABLoader); // 从打好的AB包加载
        DoLuaFile("Main");
    }

    private byte[] MyCustomLoader(ref string filePath)
    {
        // 补充：目录分隔符转换（目录结构）
        filePath = filePath.Replace('.', '/');
        string path = Application.dataPath + "/Lua/" + filePath + ".lua";
        if (File.Exists(path))
        {
            return File.ReadAllBytes(path);
        }
        else
        {
            Debug.Log("MyCustomLoader重定向失败，文件名为" + filePath);
        }
        return null;
    }

    private byte[] MyCustomABLoader(ref string filePath)
    {
        // 补充：忽略.之前内容（忽略原有目录结构）
        int index = filePath.LastIndexOf('.');
        if (index != -1)
        {
            filePath = filePath.Substring(index + 1);
        }

        TextAsset lua = ABMgr.GetInstance().LoadRes<TextAsset>("lua", filePath + ".lua");
        if (lua != null)
            return lua.bytes;
        else
            Debug.Log("MyCustomABLoader重定向失败，文件名为：" + filePath);

        return null;
    }

    // 一般Lua脚本
    public void DoLuaFile(string fileName)
    {
        string str = string.Format("require('{0}')", fileName);
        DoString(str);
    }
    public void DoString(string str)
    {
        if (luaEnv == null)
        {
            Debug.Log("解析器未初始化");
            return;
        }
        luaEnv.DoString(str);
    }

    // 有返回值Lua脚本
    public object[] DoLuaFileReturn(string fileName)
    {
        string str = string.Format("return require('{0}')", fileName);
        if (luaEnv == null)
        {
            Debug.Log("解析器未初始化");
            return null;
        }
        return luaEnv.DoString(str);
    }

    // 释放lua垃圾
    public void Tick()
    {
        if (luaEnv == null)
        {
            Debug.Log("解析器未初始化");
            return;
        }
        luaEnv.Tick();
    }

    // 销毁解析器
    public void Dispose()
    {
        if (luaEnv == null)
        {
            Debug.Log("解析器未初始化");
            return;
        }
        luaEnv.Dispose();
        luaEnv = null;
    }
}