; 功能函数
GetRandom(floatTime){
    max := Abs(Integer(floatTime))
    min := -max
    return Random(min, max)
}

GetProcessName()
{
    MouseGetPos &mouseX, &mouseY, &winId
    name := WinGetProcessName(winId)
    return name
}

GetImageSize(imageFile){
    pToken := Gdip_Startup()
    pBm := Gdip_CreateBitmapFromFile(imageFile)
    width := Gdip_GetImageWidth(pBm)
    height := Gdip_GetImageHeight(pBm)

    Gdip_DisposeImage(pBm)
    Gdip_Shutdown(pToken)
    return [width, height]
}

SplitCommand(info){
    resultArr := []
    lastSymbolIndex := 0
    leftBracket := 0

    loop parse info{

        if (A_LoopField == "("){
            leftBracket += 1
        }

        if (A_LoopField == ")"){
            leftBracket -= 1
        }

        if (A_LoopField == ","){
            if (leftBracket == 0){
                curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                resultArr.Push(curCmd)
                lastSymbolIndex := A_Index
            }
        }

        if (A_Index == StrLen(info)){
            curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex)
            resultArr.Push(curCmd)
        }

    }
    return resultArr
}


;资源读取
OnReadSetting()
{
    global ToolCheckInfo, ScriptInfo
    ScriptInfo.HasSaved := IniRead(IniFile, IniSection, "HasSaved", false)
    ScriptInfo.NormalPeriod := IniRead(IniFile, IniSection, "NormalPeriod", 50)
    ScriptInfo.HoldFloat := IniRead(IniFile, IniSection, "HoldFloat", 5)
    ScriptInfo.ClickFloat := IniRead(IniFile, IniSection, "ClickFloat", 5)
    ScriptInfo.IntervalFloat := IniRead(IniFile, IniSection, "IntervalFloat", 5)
    ScriptInfo.ImageSearchBlur := IniRead(IniFile, IniSection, "ImageSearchBlur", 100)
    ScriptInfo.IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    ScriptInfo.PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    ToolCheckInfo.IsToolCheck := IniRead(IniFile, IniSection, "IsToolCheck", false)
    ToolCheckInfo.ToolCheckHotKey := IniRead(IniFile, IniSection, "ToolCheckHotKey", "!q")
    ScriptInfo.IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
    ScriptInfo.WinPosX := IniRead(IniFile, IniSection, "WinPosX", 0)
    ScriptInfo.WinPosY := IniRead(IniFile, IniSection, "WinPosY", 0)
    ScriptInfo.IsSavedWinPos := IniRead(IniFile, IniSection, "IsSavedWinPos", false)
    ScriptInfo.TableIndex := IniRead(IniFile, IniSection, "TableIndex", 1)
    Loop TabNameArr.Length
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
    savedLoosenStopArrStr := IniRead(IniFile, IniSection, symbol "LoosenStopArr", "")
    savedRemarkArrStr := IniRead(IniFile, IniSection, symbol "RemarkArr", "")

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
        if (savedLoosenStopArrStr == "")
            savedLoosenStopArrStr := defaultInfo[6]
        if (savedRemarkArrStr == "")
            savedRemarkArrStr := defaultInfo[7]
    }

    tableItem := TableInfo[index]
    SetArr(savedTKArrStr, "," , tableItem.TKArr)
    SetArr(savedInfoArrStr, "|", tableItem.InfoArr)
    SetArr(savedModeArrStr, ",", tableItem.ModeArr)
    SetArr(savedForbidArrStr, ",", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, ",", tableItem.ProcessNameArr)
    SetArr(savedLoosenStopArrStr, ",", tableItem.LoosenStopArr)
    SetArr(savedRemarkArrStr, "|", tableItem.RemarkArr)
}

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

GetTableItemDefaultInfo(index)
{
    savedTKArrStr := ""
    savedInfoArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    savedLoosenStopArrStr := ""
    savedRemarkArrStr := ""
    symbol := GetTableSymbol(index)
    if (symbol == "Special"){
        savedTKArrStr := "m,+m,h,y,i"
        savedInfoArrStr := "lbutton_200,50,MouseMove_100_100_10|lbutton_200,50,MouseMove_100_-100_10_R|lbutton_30_2_50|left_30_2_50|ImageSearch_Test.png(lbutton_30_2_50)"
        savedModeArrStr := "0,0,1,1,0"
        savedForbidArrStr := "1,1,1,1,1"
        savedProcessNameStr := ",,,,,"
        savedLoosenStopArrStr := "0,0,0,0,0"
        savedRemarkArrStr := "鼠标双击移动_绝对|鼠标移动窗口_相对|鼠标左键双击|左移两位|找到图片双击查看"
    }
    else if (symbol == "Normal")
    {
        savedTKArrStr := "k,shift,+k,^k,XButton1"
        savedInfoArrStr := "a_30_30_50,3000|b_30_2_50|c_30_5_50,250,left_30_2_50,100,d_30_2_50|ctrl_100,0,a_100|t_30,50,h_30,50,i_30,50,s_30,50,space_30,50,i_30,50,s_30,50,space_30,50,c_30,50,j_30"
        savedModeArrStr := "0,0,0,0,0"
        savedForbidArrStr := "1,1,1,1,1"
        savedProcessNameStr := ",,,,"
        savedLoosenStopArrStr := "1,0,0,0,0"
        savedRemarkArrStr := "演示配置|演示配置|演示配置|解决按住Ctrl导致宏无效|鼠标侧键宏"
      
    }
    else if (symbol == "Replace")
    {
        savedTKArrStr := "l,o,p"
        savedInfoArrStr := "left|b,c|"
        savedModeArrStr := "0,0,0"
        savedForbidArrStr := "1,1,1"
        savedProcessNameStr := ",,"
    }
    else if(symbol == "Soft")
    {
        savedTKArrStr := "!d"
        savedInfoArrStr := "Notepad.exe"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    return [savedTKArrStr, savedInfoArrStr, savedModeArrStr, savedForbidArrStr, savedProcessNameStr, savedLoosenStopArrStr, savedRemarkArrStr]
}

;资源保存
OnSaveSetting(*)
{
    global ScriptInfo, TabCtrl
    Loop TabNameArr.Length
    {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(ScriptInfo.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(ScriptInfo.ClickFloatCtrl.Value, IniFile, IniSection, "ClickFloat")
    IniWrite(ScriptInfo.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(ScriptInfo.ImageSearchBlurCtrl.Value, IniFile, IniSection, "ImageSearchBlur")
    IniWrite(ScriptInfo.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
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
    IniWrite(SavedInfo[6], IniFile, IniSection, symbol "LoosenStopArr")
    IniWrite(SavedInfo[7], IniFile, IniSection, symbol "RemarkArr")
}

GetSavedTableItemInfo(index)
{
    Saved := MyGui.Submit()
    TKArrStr := ""
    InfoArrStr := ""
    ModeArrStr := ""
    ForbidArrStr := ""
    ProcessNameArrStr := ""
    LoosenStopArrStr := ""
    RemarkArrStr := ""
    tableItem := TableInfo[index]
    symbol := GetTableSymbol(index)

    loop tableItem.ModeArr.Length
    {
        TKNameValue := symbol "TK" A_Index
        InfoNameValue := symbol "Info" A_Index
        ModeNameValue := symbol "Mode" A_Index
        ForbidNameValue := symbol "Forbid" A_Index
        ProcessNameNameValue := symbol "ProcessName" A_Index
        LoosenStopNameValue := symbol "LoosenStop" A_Index
        RemarkNameValue := symbol "Remark" A_Index

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
            if (LoosenStopNameValue == Name)
            {
                LoosenStopArrStr .= Value
            }
            if (RemarkNameValue == Name)
            {
                RemarkArrStr .= Value
            }
        }

        if (tableItem.ModeArr.Length > A_Index)
        {
            TKArrStr .= ","
            InfoArrStr .= "|"
            ModeArrStr .= ","
            ForbidArrStr .= ","
            ProcessNameArrStr .= ","
            LoosenStopArrStr .= ","
            RemarkArrStr .= "|"
        }
    }
    return [TKArrStr, InfoArrStr, ModeArrStr, ForbidArrStr, ProcessNameArrStr, LoosenStopArrStr, RemarkArrStr]
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

;Table信息相关
CreateTableItemArr()
{
    Arr := []
    Loop TabNameArr.Length
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

InitTableItemState()
{
    Loop TabNameArr.Length
    {
        tableSymbol := GetTableSymbol(A_Index)
        if (tableSymbol == "Normal" || tableSymbol == "Special")
        {
            tableItem := TableInfo[A_Index]
            tableItem.LoosenState := []
            tableItem.TimerDoubleArr := []
            For index, value in tableItem.ModeArr
            {
                if (tableItem.LoosenState.Length >= index){
                    tableItem.LoosenState[index] := false
                }
                else{
                    tableItem.LoosenState.Push(false)
                }

                if (tableItem.TimerDoubleArr.Length >= index){
                    tableItem.TimerDoubleArr[index] := []
                }
                else{
                    tableItem.TimerDoubleArr.Push([])
                }
            }
        }
    }
}

MaxUnderPosY() {
    maxY := 0
    loop TabNameArr.Length {
        posY := TableInfo[A_Index].UnderPosY
        if (posY > maxY)
            maxY := posY
    }
    return maxY
}

UpdateUnderPosY(tableIndex, value)
{
    table := TableInfo[tableIndex]
    table.UnderPosY += value
}

GetTableSymbol(index)
{
    return TabSymbolArr[index]
}
 
CheckIsSpecialTable(index){
    symbol := GetTableSymbol(index)
    if (symbol == "Special")
        return true
    return false
}

CheckIsSpecialOrNormalTable(index){
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    if (symbol == "Special")
        return true
    return false
}
