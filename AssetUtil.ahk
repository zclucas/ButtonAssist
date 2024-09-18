OnReadSetting()
{
    global IsLastSaved, PauseHotkey, TabIndex, IsExecuteShow, TableItemNum, ToolCheckInfo ; 访问全局变量

    Loop TableItemNum
    {
        ReadTableItemInfo(A_Index)
    }
    TabIndex := IniRead(IniFile, IniSection, "TabIndex", 1)
    
    IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    ToolCheckInfo.IsToolCheck := IniRead(IniFile, IniSection, "IsToolCheck", false)
    ToolCheckInfo.ToolCheckHotKey := IniRead(IniFile, IniSection, "ToolCheckHotKey", "!o")
    IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
}

ReadTableItemInfo(index)
{
    symbol := GetTableSymbol(index)
    defalutInfo := GetTablItemDefaultInfo(index)
    savedTKArrStr := IniRead(IniFile, IniSection, symbol "TKArr", "")
    savedInfoArrStr := IniRead(IniFile, IniSection, symbol "InfoArr", "")
    savedModeArrStr := IniRead(IniFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(IniFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(IniFile, IniSection, symbol "ProcessNameArr", "")

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


    tableItem := GetTableItem(index)
    aa := tableItem.ProcessNameArr
    SetArr(savedTKArrStr, "," , tableItem.TKArr)
    SetArr(savedInfoArrStr, "|", tableItem.InfoArr)
    SetArr(savedModeArrStr, ",", tableItem.ModeArr)
    SetArr(savedForbidArrStr, ",", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, ",", tableItem.ProcessNameArr)
}


OnSaveSetting(*)
{
    Loop TableItemNum
    {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(PauseHotkeyCtrl.Text, IniFile, IniSection, "PauseHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(TabCtrl.Value, IniFile, IniSection, "TabIndex")
    IniWrite(ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(ToolCheckInfo.IsToolCheck, IniFile, IniSection, "IsToolCheck")
    IniWrite(ToolCheckInfo.ToolCheckHotKey, IniFile, IniSection, "ToolCheckHotKey")

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
        return "Rule"
    }
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
        savedTKArrStr := "q"
        savedInfoArrStr := "d,30,a,30,j"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    else if (index == 2)
    {
        savedTKArrStr := "k"
        savedInfoArrStr := "ctrl_100,0,a_100"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    else if (index == 3)
    {
        savedTKArrStr := "e,~alt,t"
        savedInfoArrStr := "w,d|f10|"
        savedModeArrStr := "1,1,0"
        savedForbidArrStr := "0,0,0"
        savedProcessNameStr := ",,"
    }
    return [savedTKArrStr, savedInfoArrStr, savedModeArrStr, savedForbidArrStr, savedProcessNameStr]
}