OnReadSetting()
{
    global TableItemNum, ToolCheckInfo ; 访问全局变量
    global ScriptInfo
    ScriptInfo.HasSaved := IniRead(IniFile, IniSection, "HasSaved", false)
    ScriptInfo.NormalPeriod := IniRead(IniFile, IniSection, "NormalPeriod", 50)
    ScriptInfo.IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    ScriptInfo.PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    ToolCheckInfo.IsToolCheck := IniRead(IniFile, IniSection, "IsToolCheck", false)
    ToolCheckInfo.ToolCheckHotKey := IniRead(IniFile, IniSection, "ToolCheckHotKey", "!q")
    ScriptInfo.IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
    ScriptInfo.WinPosX := IniRead(IniFile, IniSection, "WinPosX", 0)
    ScriptInfo.WinPosY := IniRead(IniFile, IniSection, "WinPosY", 0)
    ScriptInfo.IsSavedWinPos := IniRead(IniFile, IniSection, "IsSavedWinPos", false)
    ScriptInfo.TableIndex := IniRead(IniFile, IniSection, "TableIndex", 1)
    Loop TableItemNum
    {
        ReadTableItemInfo(A_Index)
    }
}

ReadTableItemInfo(index)
{
    global ScriptInfo
    symbol := GetTableSymbol(index)
    defalutInfo := GetTablItemDefaultInfo(index)
    savedTKArrStr := IniRead(IniFile, IniSection, symbol "TKArr", "")
    savedInfoArrStr := IniRead(IniFile, IniSection, symbol "InfoArr", "")
    savedModeArrStr := IniRead(IniFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(IniFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(IniFile, IniSection, symbol "ProcessNameArr", "")

    if (!ScriptInfo.HasSaved)
    {
        if (savedTKArrStr == "")
            savedTKArrStr := defalutInfo[1]
        if (savedInfoArrStr == "")
            savedInfoArrStr := defalutInfo[2]
        if (savedModeArrStr == "")
            savedModeArrStr := defalutInfo[3]
        if (savedForbidArrStr == "")
            savedForbidArrStr := defalutInfo[4]
        if (savedProcessNameStr == "")
            savedProcessNameStr := defalutInfo[5]
    }

    tableItem := GetTableItem(index)
    SetArr(savedTKArrStr, "," , tableItem.TKArr)
    SetArr(savedInfoArrStr, "|", tableItem.InfoArr)
    SetArr(savedModeArrStr, ",", tableItem.ModeArr)
    SetArr(savedForbidArrStr, ",", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, ",", tableItem.ProcessNameArr)
}

SaveWinPos()
{
    global ScriptInfo, TabCtrl
    MyGui.GetPos(&posX, &posY)
    ScriptInfo.WinPosx := posX
    ScriptInfo.WinPosy := posY
    ScriptInfo.IsSavedWinPos := true
    ScriptInfo.TableIndex := TabCtrl.Value
    IniWrite(ScriptInfo.WinPosx, IniFile, IniSection, "WinPosx")
    IniWrite(ScriptInfo.WinPosy, IniFile, IniSection, "WinPosy")
    IniWrite(true, IniFile, IniSection, "IsSavedWinPos")
    IniWrite(TabCtrl.Value, IniFile, IniSection, "TableIndex")
}

OnSaveSetting(*)
{
    global ScriptInfo, TabCtrl
    isCanSave := CheckCanSave()
    if (!isCanSave)
        return

    Loop TableItemNum
    {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(ScriptInfo.NormalPeriodCtrl.Value, IniFile, IniSection, "NormalPeriod")
    IniWrite(ScriptInfo.PauseHotkeyCtrl.Text, IniFile, IniSection, "PauseHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(ScriptInfo.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(ToolCheckInfo.IsToolCheck, IniFile, IniSection, "IsToolCheck")
    IniWrite(ToolCheckInfo.ToolCheckHotKey, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(true, IniFile, IniSection, "HasSaved")
    SaveWinPos()
    Reload()
}

SaveTableItemInfo(index)
{
    SavedInfo := GetSavedTableItemInfo(index)
    symbol := GetTableSymbol(index)
    IniWrite(SavedInfo[1], IniFile, IniSection, symbol "TKArr")
    IniWrite(SavedInfo[2], IniFile, IniSection, symbol "InfoArr")
    IniWrite(SavedInfo[3], IniFile, IniSection, symbol "ModeArr")
    IniWrite(SavedInfo[4], IniFile, IniSection, symbol "ForbidArr")
    IniWrite(SavedInfo[5], IniFile, IniSection, symbol "ProcessNameArr")
}

CreateTableItemArr(num)
{
    Arr := []
    Loop num
    {
        if (Arr.Length < A_Index)
        {
            Arr.Push(TableItem())
        }
        else
        {
            Arr[A_Index] := TableItem()
        }
    }
    return Arr
}

GetTableItem(index)
{
    global TableInfo

    return TableInfo[index]
}

GetTableSymbol(index)
{
    if (index == 1)
    {
        return "Simple"
    }
    else if (index == 2)
    {
        return "Normal"
    }
    else if (index == 3)
    {
        return "Replace"
    }
    else if(index == 4)
    {
        return "Soft"
    }
    else if(index == 5)
    {
        return "Rule"
    }
    else if(index == 6)
    {
        return "Tool"
    }
}

GetTableName(index)
{
    if (index == 1)
    {
        return "简易按键宏"
    }
    else if (index == 2)
    {
        return "按键宏"
    }
    else if (index == 3)
    {
        return "按键替换"
    }
    else if(index == 4)
    {
        return "软件宏"
    }
    else if (index == 5)
    {
        return "配置规则"
    }
    else if(index == 6)
    {
        return "工具"
    }
}

UpdateUnderPosY(tableIndex, value)
{
    table := GetTableItem(tableIndex)
    table.UnderPosY += value
    if (tableIndex == 4)
        aa := 1 ; 临时调试代码
}

SetToolCheckInfo(*)
{
    global ToolCheckInfo
    MouseGetPos &mouseX, &mouseY, &winId
    ToolCheckInfo.PosStr := mouseX . "," . mouseY
    ToolCheckInfo.ProcessName := WinGetProcessName(winId)
    ToolCheckInfo.ProcessTile := WinGetTitle(winId)
    ToolCheckInfo.ProcessPid := WinGetPID(winId)
    ToolCheckInfo.ProcessClass := WinGetClass(winId)
    RefreshToolUI()
}

GetProcessName()
{
    MouseGetPos &mouseX, &mouseY, &winId
    name := WinGetProcessName(winId)
    return name
}

;自定义函数
SetArr(str, symbol, Arr)
{
    For index, value in StrSplit(str, symbol)
    {
        if (Arr.Length < index)
        {
            Arr.Push(value)
        }
        else
        {
            Arr[index] = value
        }
    }
}

GetSavedTableItemInfo(index)
{
    Saved := MyGui.Submit()
    TKArrStr := ""
    InfoArrStr := ""
    ModeArrStr := ""
    ForbidArrStr := ""
    ProcessNameArrStr := ""
    tableItem := GetTableItem(index)
    symbol := GetTableSymbol(index)

    loop tableItem.TKArr.Length
    {
        TKNmaeValue := symbol "TKArr" A_Index
        InfoNameValue := symbol "InfoArr" A_Index
        ModeNameValue := symbol "ModeArr" A_Index
        ForbidNameValue := symbol "ForbidArr" A_Index
        ProcessNameNameValue := symbol "ProcessNameArr" A_Index

        For Name, Value in Saved.OwnProps()
        {
            if (TKNmaeValue == Name)
            {
                TKArrStr .= Value
            }
            if (InfoNameValue == Name)
            {
                InfoArrStr .= Value
            }
            if (ModeNameValue == Name)
            {
                ModeArrStr .= Value
            }
            if (ForbidNameValue == Name)
            {
                ForbidArrStr .= Value
            }
            if (ProcessNameNameValue == Name)
            {
                ProcessNameArrStr .= Value
            }
        }

        if (tableItem.TKArr.Length > A_Index)
        {
            TKArrStr .= ","
            InfoArrStr .= "|"
            ModeArrStr .= ","
            ForbidArrStr .= ","
            ProcessNameArrStr .= ","
        }
    }
    return [TKArrStr, InfoArrStr, ModeArrStr, ForbidArrStr, ProcessNameArrStr]
}

GetTablItemDefaultInfo(index)
{
    savedTKArrStr := ""
    savedInfoArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    if (index == 1)
    {
        savedTKArrStr := "q,q"
        savedInfoArrStr := "t,30,h,30,i,30,s,30,space,30,i,30,s,30,space,30,q|d,30,a,30,j"
        savedModeArrStr := "0,0"
        savedForbidArrStr := "0,0"
        savedProcessNameStr := "Notepad.exe,explorer.exe"
    }
    else if (index == 2)
    {
        savedTKArrStr := "k,m"
        savedInfoArrStr := "ctrl_100,0,a_100|a_1000"
        savedModeArrStr := "0,0"
        savedForbidArrStr := "0,0"
        savedProcessNameStr := "Notepad.exe,"
    }
    else if (index == 3)
    {
        savedTKArrStr := "e,t"
        savedInfoArrStr := "w,d|"
        savedModeArrStr := "1,0"
        savedForbidArrStr := "0,0"
        savedProcessNameStr := ","
    }
    else if(index == 4)
    {
        savedTKArrStr := "!d"
        savedInfoArrStr := "Notepad.exe"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    return [savedTKArrStr, savedInfoArrStr, savedModeArrStr, savedForbidArrStr, savedProcessNameStr]
}

CheckCanSave()
{
    Loop TableItemNum
    {
        index := A_Index
        SavedInfo := GetSavedTableItemInfo(index)
        TKArr := StrSplit(SavedInfo[1], ",")
        InfoArr := StrSplit(SavedInfo[2], "|")
        Loop TKArr.Length
        {
            tableName := GetTableName(index)
            if(!CheckTableTKSetting(TKArr[A_Index]))
            {
                MsgBox (Format("{} 模块下 第 {} 个触发键配置错误", tableName, A_Index))
                RefreshGui()
                return false
            }

            if (!CheckTableInfoSetting(index, InfoArr[A_Index]))
            {
                MsgBox (Format("{} 模块下 第 {} 个辅助信息配置错误", tableName, A_Index))
                RefreshGui()
                return false
            }
        }

        tableName := GetTableName(2)
        NormalPeriodCtrlValue := ScriptInfo.NormalPeriodCtrl.Value
        if (!IsInteger(NormalPeriodCtrlValue) || NormalPeriodCtrlValue < ScriptInfo.MinNormalPeriod)
        {
            MsgBox (Format("{} 模块下 按键周期配置错误", tableName, A_Index))
            RefreshGui()
            return false
        }

    }
    return true
}

CheckTableInfoSetting(index, str)
{
    if (index == 1)
    {
        infos := StrSplit(str, ",")
        loop infos.Length
        {
            info := infos[A_Index]
            keyName := GetKeyName(info)
            if (keyName == "")
                return false

            if (infos.Length > A_Index)
            {
                A_Index++
                if (!IsInteger(infos[A_Index]))
                    return false
            }
        }
        return true
    }
    else if (index == 2)
    {
        infos := StrSplit(str, ",")
        loop infos.Length
        {
            info := infos[A_Index]
            infoArr := StrSplit(info, "_")
            keyName := GetKeyName(infoArr[1])
            if (keyName == "")
                return false

            if (infoArr.Length != 2)
                return false
            if (!IsInteger(infoArr[2]))
                return false

            if (infos.Length > A_Index)
            {
                A_Index++
                if (!IsInteger(infos[A_Index]))
                    return false
            }
        }
        return true
    }
    else if(index == 3)
    {
        infos := StrSplit(str, ",")
        loop infos.Length
        {
            info := infos[A_Index]
            keyName := GetKeyName(info)
            if (keyName == "")
                return false
        }
        return true
    }
    return true
}

CheckTableTKSetting(str)
{
    if (str == "")
        return true

    key := RemoveHotkeyPrefix(str)

    keyName := GetKeyName(key)
    if (keyName == "")
        return false

    return true
}

RemoveHotkeyPrefix(hotkey) {
    prefix := ""
    ; 检查并去掉前缀
    if InStr(hotkey, "^") ; Ctrl
        prefix .= "^"
    if InStr(hotkey, "!") ; Alt
        prefix .= "!"
    if InStr(hotkey, "+") ; Shift
        prefix .= "+"
    if InStr(hotkey, "#") ; Win
        prefix .= "#"
    if InStr(hotkey, "~") ; 系统
        prefix .= "~"
    if InStr(hotkey, "$") ; 系统
        prefix .= "$"

    ; 去掉前缀并返回按键部分
    return SubStr(hotkey, StrLen(prefix) + 1)
}