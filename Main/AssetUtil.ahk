; 功能函数
GetFloatTime(oriTime, floatValue){
    oriTime := Integer(oriTime)
    floatValue := Integer(floatValue)
    value := Abs(oriTime * (floatValue * 0.01)) 
    max := oriTime + value
    min := oriTime - value
    return Random(min, max)
}

GetProcessName() {
    MouseGetPos &mouseX, &mouseY, &winId
    name := WinGetProcessName(winId)
    return name
}

GetImageSize(imageFile) {
    pToken := Gdip_Startup()
    pBm := Gdip_CreateBitmapFromFile(imageFile)
    width := Gdip_GetImageWidth(pBm)
    height := Gdip_GetImageHeight(pBm)

    Gdip_DisposeImage(pBm)
    Gdip_Shutdown(pToken)
    return [width, height]
}

SplitMacro(info) {
    resultArr := []
    lastSymbolIndex := 0
    leftBracket := 0

    loop parse info {

        if (A_LoopField == "(") {
            leftBracket += 1
        }

        if (A_LoopField == ")") {
            leftBracket -= 1
        }

        if (A_LoopField == ",") {
            if (leftBracket == 0) {
                curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                if (curCmd != "")
                    resultArr.Push(curCmd)
                lastSymbolIndex := A_Index
            }
        }

        if (A_Index == StrLen(info)) {
            curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex)
            resultArr.Push(curCmd)
        }

    }
    return resultArr
}

SplitCommand(macro) {
    splitIndex := RegExMatch(macro, "(\(.*\))", &match)
    if (splitIndex == 0) {
        return [macro, "", ""]
    }
    else {
        macro1 := SubStr(macro, 1, splitIndex - 1)
        result := [macro1]
        lastSymbolIndex := 0
        leftBracket := 0
        loop parse match[1] {
            if (A_LoopField == "(") {
                leftBracket += 1
                if (leftBracket == 1)
                    lastSymbolIndex := A_Index
            }

            if (A_LoopField == ")") {
                leftBracket -= 1
                if (leftBracket == 0) {
                    curMacro := SubStr(match[1], lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                    result.Push(curMacro)
                }
            }
        }
        if (result.Length == 2) {
            result.Push("")
        }
        return result
    }
}

SplitKeyCommand(macro) {
    realKey := ""
    for key, value in MySoftData.SpecialKeyMap {
        newMacro := StrReplace(macro, key, "flagSymbol")
        if (newMacro != macro) {
            realKey := key
            break
        }
    }

    result := StrSplit(newMacro, "_")
    loop result.Length {
        if (result[A_Index] == "flagSymbol"){
            result[A_Index] := realKey
            break
        }
    }

    return result
}

;初始化数据
InitData() {
    InitTableItemState()
    InitJoyAxis()
    InitGui()
}

;手柄轴未使用时，状态会变为0，而非中间值
InitJoyAxis() {
    joyAxisNum := 8
    loop joyAxisNum {
        SendJoyAxisClick("JoyAxis" A_Index "Max", 30)
    }
}

InitGui() {
    MyTriggerKeyGui.SaveBtnAction := OnSaveSetting
    MyTriggerStrGui.SaveBtnAction := OnSaveSetting
    MyMacroGui.SaveBtnAction := OnSaveSetting

    
}

SetSoftData() {

}

;资源读取
LoadSetting() {
    global ToolCheckInfo, MySoftData
    MySoftData.HasSaved := IniRead(IniFile, IniSection, "HasSaved", false)
    MySoftData.NormalPeriod := IniRead(IniFile, IniSection, "NormalPeriod", 50)
    MySoftData.HoldFloat := IniRead(IniFile, IniSection, "HoldFloat", 0)
    MySoftData.PreIntervalFloat := IniRead(IniFile, IniSection, "PreIntervalFloat", 0)
    MySoftData.IntervalFloat := IniRead(IniFile, IniSection, "IntervalFloat", 0)
    MySoftData.ImageSearchBlur := IniRead(IniFile, IniSection, "ImageSearchBlur", 100)
    MySoftData.IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    MySoftData.PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    MySoftData.KillMacroHotkey := IniRead(IniFile, IniSection, "KillMacroHotkey", "!k")
    ToolCheckInfo.IsToolCheck := IniRead(IniFile, IniSection, "IsToolCheck", false)
    ToolCheckInfo.ToolCheckHotKey := IniRead(IniFile, IniSection, "ToolCheckHotKey", "!q")
    MySoftData.IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
    MySoftData.WinPosX := IniRead(IniFile, IniSection, "WinPosX", 0)
    MySoftData.WinPosY := IniRead(IniFile, IniSection, "WinPosY", 0)
    MySoftData.IsSavedWinPos := IniRead(IniFile, IniSection, "IsSavedWinPos", false)
    MySoftData.TableIndex := IniRead(IniFile, IniSection, "TableIndex", 1)
    MySoftData.TableInfo := CreateTableItemArr()
    loop MySoftData.TabNameArr.Length {
        ReadTableItemInfo(A_Index)
    }
}

ReadTableItemInfo(index) {
    global MySoftData
    symbol := GetTableSymbol(index)
    defaultInfo := GetTableItemDefaultInfo(index)
    savedTKArrStr := IniRead(IniFile, IniSection, symbol "TKArr", "")
    savedMacroArrStr := IniRead(IniFile, IniSection, symbol "MacroArr", "")
    savedModeArrStr := IniRead(IniFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(IniFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(IniFile, IniSection, symbol "ProcessNameArr", "")
    savedRemarkArrStr := IniRead(IniFile, IniSection, symbol "RemarkArr", "")
    savedLoopCountStr := IniRead(IniFile, IniSection, symbol "LoopCountArr", "")

    if (!MySoftData.HasSaved) {
        if (savedTKArrStr == "")
            savedTKArrStr := defaultInfo[1]
        if (savedMacroArrStr == "")
            savedMacroArrStr := defaultInfo[2]
        if (savedModeArrStr == "")
            savedModeArrStr := defaultInfo[3]
        if (savedForbidArrStr == "")
            savedForbidArrStr := defaultInfo[4]
        if (savedProcessNameStr == "")
            savedProcessNameStr := defaultInfo[5]
        if (savedRemarkArrStr == "")
            savedRemarkArrStr := defaultInfo[6]
        if (savedLoopCountStr == "")
            savedLoopCountStr := defaultInfo[7]
    }

    tableItem := MySoftData.TableInfo[index]
    SetArr(savedTKArrStr, "π", tableItem.TKArr)
    SetArr(savedMacroArrStr, "π", tableItem.MacroArr)
    SetArr(savedModeArrStr, "π", tableItem.ModeArr)
    SetArr(savedForbidArrStr, "π", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, "π", tableItem.ProcessNameArr)
    SetArr(savedRemarkArrStr, "π", tableItem.RemarkArr)
    SetIntArr(savedLoopCountStr, "π", tableItem.LoopCountArr)
}

SetArr(str, symbol, Arr) {
    for index, value in StrSplit(str, symbol) {
        if (Arr.Length < index) {
            Arr.Push(value)
        }
        else {
            Arr[index] = value
        }
    }
}

SetIntArr(str, symbol, Arr) {
    for index, value in StrSplit(str, symbol) {
        curValue := value
        if (value == "")
            curValue := 1
        if (Arr.Length < index) {
            Arr.Push(Integer(curValue))
        }
        else {
            Arr[index] = Integer(curValue)
        }
    }
}

GetTableItemDefaultInfo(index) {
    savedTKArrStr := ""
    savedMacroArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    savedRemarkArrStr := ""
    savedLoopCountStr := ""
    symbol := GetTableSymbol(index)

    if (symbol == "Normal") {
        savedTKArrStr := "k"
        savedMacroArrStr :=
            "PressKey_a_30_30_50,3000"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "演示配置"
        savedLoopCountStr := "1"

    }
    else if (symbol == "String") {
        savedTKArrStr := ":?*:AA"
        savedMacroArrStr := "PressKey_lbutton_200,50,MouseMove_100_100_10"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "按两次a触发"
        savedLoopCountStr := "1"
    }
    else if (symbol == "Replace") {
        savedTKArrStr := "lπoπp"
        savedMacroArrStr := "leftπb,cπ"
        savedModeArrStr := "0π0π0"
        savedForbidArrStr := "1π1π1"
        savedProcessNameStr := "ππ"
    }
    else if (symbol == "Soft") {
        savedTKArrStr := "!d"
        savedMacroArrStr := "Notepad.exe"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    return [savedTKArrStr, savedMacroArrStr, savedModeArrStr, savedForbidArrStr, savedProcessNameStr, savedRemarkArrStr,
        savedLoopCountStr]
}

;资源保存
OnSaveSetting(*) {
    global MySoftData
    loop MySoftData.TabNameArr.Length {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(MySoftData.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(MySoftData.PreIntervalFloatCtrl.Value, IniFile, IniSection, "PreIntervalFloat")
    IniWrite(MySoftData.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(MySoftData.ImageSearchBlurCtrl.Value, IniFile, IniSection, "ImageSearchBlur")
    IniWrite(MySoftData.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
    IniWrite(MySoftData.KillMacroHotkeyCtrl.Value, IniFile, IniSection, "KillMacroHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(MySoftData.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(ToolCheckInfo.IsToolCheck, IniFile, IniSection, "IsToolCheck")
    IniWrite(ToolCheckInfo.ToolCheckHotKeyCtrl.Value, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(true, IniFile, IniSection, "HasSaved")
    SaveWinPos()
    Reload()
}

SaveTableItemInfo(index) {
    SavedInfo := GetSavedTableItemInfo(index)
    symbol := GetTableSymbol(index)
    IniWrite(SavedInfo[1], IniFile, IniSection, symbol "TKArr")
    IniWrite(SavedInfo[2], IniFile, IniSection, symbol "MacroArr")
    IniWrite(SavedInfo[3], IniFile, IniSection, symbol "ModeArr")
    IniWrite(SavedInfo[4], IniFile, IniSection, symbol "ForbidArr")
    IniWrite(SavedInfo[5], IniFile, IniSection, symbol "ProcessNameArr")
    IniWrite(SavedInfo[6], IniFile, IniSection, symbol "RemarkArr")
    IniWrite(SavedInfo[7], IniFile, IniSection, symbol "LoopCountArr")
}

GetSavedTableItemInfo(index) {
    Saved := MySoftData.MyGui.Submit()
    TKArrStr := ""
    MacroArrStr := ""
    ModeArrStr := ""
    ForbidArrStr := ""
    ProcessNameArrStr := ""
    RemarkArrStr := ""
    LoopCountArrStr := ""
    tableItem := MySoftData.TableInfo[index]
    symbol := GetTableSymbol(index)

    loop tableItem.ModeArr.Length {
        TKArrStr .= tableItem.TKConArr[A_Index].Value
        MacroArrStr .= tableItem.InfoConArr[A_Index].Value
        ModeArrStr .= tableItem.ModeConArr[A_Index].Value
        ForbidArrStr .= tableItem.ForbidConArr[A_Index].Value
        ProcessNameArrStr .= tableItem.ProcessNameConArr[A_Index].Value
        RemarkArrStr .= tableItem.RemarkConArr.Length >= A_Index ? tableItem.RemarkConArr[A_Index].Value : ""
        LoopCountArrStr .= GetItemSaveCountValue(tableItem.Index, A_Index)

        if (tableItem.ModeArr.Length > A_Index) {
            TKArrStr .= "π"
            MacroArrStr .= "π"
            ModeArrStr .= "π"
            ForbidArrStr .= "π"
            ProcessNameArrStr .= "π"
            RemarkArrStr .= "π"
            LoopCountArrStr .= "π"
        }
    }
    return [TKArrStr, MacroArrStr, ModeArrStr, ForbidArrStr, ProcessNameArrStr, RemarkArrStr, LoopCountArrStr]
}

SaveWinPos() {
    global MySoftData
    MySoftData.MyGui.GetPos(&posX, &posY)
    MySoftData.WinPosX := posX
    MySoftData.WinPosy := posY
    MySoftData.IsSavedWinPos := true
    MySoftData.TableIndex := MySoftData.TabCtrl.Value
    IniWrite(MySoftData.WinPosX, IniFile, IniSection, "WinPosX")
    IniWrite(MySoftData.WinPosY, IniFile, IniSection, "WinPosY")
    IniWrite(true, IniFile, IniSection, "IsSavedWinPos")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
}

;Table信息相关
CreateTableItemArr() {
    Arr := []
    loop MySoftData.TabNameArr.Length {
        newTableItem := TableItem()
        newTableItem.Index := A_Index
        if (Arr.Length < A_Index) {
            Arr.Push(newTableItem)
        }
        else {
            Arr[A_Index] := newTableItem
        }
    }
    return Arr
}

InitTableItemState() {
    loop MySoftData.TabNameArr.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        InitSingleTableState(tableItem)
    }

    tableItem := MySoftData.SpecialtableItem
    tableItem.ModeArr := []
    tableItem.ModeArr.Push(0)
    InitSingleTableState(tableItem)
}

InitSingleTableState(tableItem) {
    tableItem.CmdActionArr := []
    tableItem.KilledArr := []
    tableItem.ActionCount := []
    tableItem.SearchActionArr := []
    for index, value in tableItem.ModeArr {
        tableItem.KilledArr.Push(false)
        tableItem.CmdActionArr.Push([])
        tableItem.ActionCount.Push(0)
        tableItem.SearchActionArr.Push(Map())
    }
}

KillTableItemMacro() {
    loop MySoftData.TableInfo.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        KillSingleTableMacro(tableItem)
    }

    KillSingleTableMacro(MySoftData.SpecialtableItem)
}

KillSingleTableMacro(tableItem) {
    for index, value in tableItem.ModeArr {
        tableItem.KilledArr[index] := true

        loop tableItem.CmdActionArr[index].Length {
            action := tableItem.CmdActionArr[index][A_Index]
            SetTimer action, 0
        }
        tableItem.CmdActionArr[index] := []

        for key, value in tableItem.SearchActionArr[index] {
            loop value.Length {
                action := value[A_Index]
                SetTimer action, 0
            }
        }
        tableItem.SearchActionArr[index] := Map()
    }
}

MaxUnderPosY() {
    maxY := 0
    loop MySoftData.TabNameArr.Length {
        posY := MySoftData.TableInfo[A_Index].UnderPosY
        if (posY > maxY)
            maxY := posY
    }
    return maxY
}

UpdateUnderPosY(tableIndex, value) {
    table := MySoftData.TableInfo[tableIndex]
    table.UnderPosY += value
}

GetTableSymbol(index) {
    return MySoftData.TabSymbolArr[index]
}

GetItemSaveCountValue(tableIndex, Index) {
    itemtable := MySoftData.TableInfo[tableIndex]
    if (itemtable.LoopCountConArr.Length >= Index) {
        value := itemtable.LoopCountConArr[Index].Value
        if (value == "∞")
            return -1
        if (IsInteger(value)) {
            if (Integer(value) < 0)
                return -1
            else
                return value
        }
    }
    return 1
}

CheckIsMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    if (symbol == "String")
        return true
    return false
}

CheckIsStringMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "String")
        return true
    return false
}
