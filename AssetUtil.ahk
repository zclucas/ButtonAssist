InitLoopHotkeyState()
{
    Loop TableItemNum
    {
        tableSymbol := GetTableSymbol(A_Index)
        if (tableSymbol == "Loop")
        {
            tableItem := GetTableItem(A_Index) 
            tableItem.LoopState := []
            For index, value in tableItem.TKArr
            {
                if (tableItem.LoopState.Length >= index){
                    tableItem.LoopState[index] := true
                }
                else{
                    tableItem.LoopState.Push(true)
                }
            }
        }
    }
}

OnReadSetting()
{
    global TableItemNum, ToolCheckInfo ; 访问全局变量
    global ScriptInfo
    ScriptInfo.HasSaved := IniRead(IniFile, IniSection, "HasSaved", false)
    ScriptInfo.NormalPeriod := IniRead(IniFile, IniSection, "NormalPeriod", 50)
    ScriptInfo.KeyAutoLooseTimeMin := IniRead(IniFile, IniSection, "KeyAutoLooseTimeMin", 25)
    ScriptInfo.KeyAutoLooseTimeMax := IniRead(IniFile, IniSection, "KeyAutoLooseTimeMax", 35)
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
    defaultInfo := GetTableItemDefaultInfo(index)
    savedTKArrStr := IniRead(IniFile, IniSection, symbol "TKArr", "")
    savedInfoArrStr := IniRead(IniFile, IniSection, symbol "InfoArr", "")
    savedModeArrStr := IniRead(IniFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(IniFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(IniFile, IniSection, symbol "ProcessNameArr", "")

    if (!ScriptInfo.HasSaved)
    {
        if (savedTKArrStr == "")
            savedTKArrStr := defaultInfo[1]
        if (savedInfoArrStr == "")
            savedInfoArrStr := defaultInfo[2]
        if (savedModeArrStr == "")
            savedModeArrStr := defaultInfo[3]
        if (savedForbidArrStr == "")
            savedForbidArrStr := defaultInfo[4]
        if (savedProcessNameStr == "")
            savedProcessNameStr := defaultInfo[5]
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
    ScriptInfo.WinPosX := posX
    ScriptInfo.WinPosy := posY
    ScriptInfo.IsSavedWinPos := true
    ScriptInfo.TableIndex := TabCtrl.Value
    IniWrite(ScriptInfo.WinPosX, IniFile, IniSection, "WinPosX")
    IniWrite(ScriptInfo.WinPosY, IniFile, IniSection, "WinPosY")
    IniWrite(true, IniFile, IniSection, "IsSavedWinPos")
    IniWrite(TabCtrl.Value, IniFile, IniSection, "TableIndex")
}

OnSaveSetting(*)
{
    global ScriptInfo, TabCtrl
    ; isCanSave := CheckCanSave()
    ; if (!isCanSave)
    ;     return

    Loop TableItemNum
    {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(ScriptInfo.NormalPeriodCtrl.Value, IniFile, IniSection, "NormalPeriod")
    IniWrite(ScriptInfo.KeyAutoLooseTimeMinCtrl.Value, IniFile, IniSection, "KeyAutoLooseTimeMin")
    IniWrite(ScriptInfo.KeyAutoLooseTimeMaxCtrl.Value, IniFile, IniSection, "KeyAutoLooseTimeMax")
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

GetTableSymbolArr()
{
    tableSymbolArr := ["Normal", "Loop", "Replace", "Soft", "Rule", "Tool"]
    return tableSymbolArr
}

GetTableSymbol(index)
{
    return GetTableSymbolArr()[index]
}

GetTableIndex(symbol)
{
    tableSymbolArr := GetTableSymbolArr()
    Loop tableSymbolArr.Length
    {
        if (tableSymbolArr[A_Index] == symbol)
        {
            return A_Index
        }
    }
}

GetTableNameArr()
{
    tableNameArr := ["按键宏", "循环宏", "按键替换", "软件宏", "配置规则", "工具"]
    return tableNameArr
}

GetTableName(index)
{
    return GetTableNameArr()[index]
}

UpdateUnderPosY(tableIndex, value)
{
    table := GetTableItem(tableIndex)
    table.UnderPosY += value
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

GetRandomAutoLooseTime()
{
    global ScriptInfo
    return Random(ScriptInfo.KeyAutoLooseTimeMin, ScriptInfo.KeyAutoLooseTimeMax)
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
        TKNameValue := symbol "TK" A_Index
        InfoNameValue := symbol "Info" A_Index
        ModeNameValue := symbol "Mode" A_Index
        ForbidNameValue := symbol "Forbid" A_Index
        ProcessNameNameValue := symbol "ProcessName" A_Index

        For Name, Value in Saved.OwnProps()
        {
            if (TKNameValue == Name)
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

GetTableItemDefaultInfo(index)
{
    savedTKArrStr := ""
    savedInfoArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    if (index == 1)
    {
        savedTKArrStr := "k,m"
        savedInfoArrStr := "ctrl_100,0,a_100|a_1000"
        savedModeArrStr := "0,0"
        savedForbidArrStr := "0,0"
        savedProcessNameStr := "Notepad.exe,"
    }
    else if (index == 2)
    {
        savedTKArrStr := "z"
        savedInfoArrStr := "z,50,x,50"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ","
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
    }

    tableName := GetTableName(6)
    if (!IsInteger(ScriptInfo.KeyAutoLooseTimeMinCtrl.Value) || !IsInteger(ScriptInfo.KeyAutoLooseTimeMaxCtrl.Value))
    {
        MsgBox (Format("{} 模块下 按键时间配置错误", tableName))
        RefreshGui()
        return false
    }
    if (!IsInteger(ScriptInfo.NormalPeriodCtrl.Value))
    {
        MsgBox (Format("{} 模块下 按键周期配置错误", tableName))
        RefreshGui()
        return false
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

            if (infos.Length > A_Index)
            {
                A_Index++
                if (!IsInteger(infos[A_Index]))
                    return false
            }
        }
        return true
    }
    else if(index == 4)
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