using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class LuaCopyEditor : Editor
{
   [MenuItem("XLua/Lua打包预处理")]
   public static void CopyLuaToTxt()
   {
        string path = Application.dataPath + "/Lua/";
        if( !Directory.Exists(path) ) return;

        // 准备新的空文件夹LuaTxt
        // string[] strs = Directory.GetFiles(path, "*.lua");
        string[] strs = Directory.GetFiles(path, "*.lua", SearchOption.AllDirectories); // 补充：递归到子文件夹
        string newPath = Application.dataPath + "/LuaTxt/";
        if( !Directory.Exists(newPath))
        {
            Directory.CreateDirectory(newPath);
        }else{
            string[] oldFileStrs = Directory.GetFiles(newPath, "*.txt");
            for (int i = 0; i < oldFileStrs.Length; i++)
            {
                File.Delete(oldFileStrs[i]);
            }
        }

        // .lua转成.lua.txt然后放入LuaTxt
        List<string> newFileNames = new List<string>();
        string fileName;
        for(int i = 0; i < strs.Length; ++i)
        {
            // fileName = newPath + strs[i].Substring(strs[i].LastIndexOf("/")+1) + ".txt";
            // 修改：存在混合路径，既有 / 又有 \，改用GetFileName
            fileName = Path.Combine(newPath, Path.GetFileName(strs[i]) + ".txt");
            newFileNames.Add(fileName);
            File.Copy(strs[i], fileName);
        }

        // 刷新
        AssetDatabase.Refresh();

        // 指定包名，方便后续直接打AB包
        for (int i = 0; i < newFileNames.Count; i++)
        {
            AssetImporter importer = AssetImporter.GetAtPath( newFileNames[i].Substring(newFileNames[i].IndexOf("Assets")));
            if(importer != null)
                importer.assetBundleName = "lua";
        }
   }
}
