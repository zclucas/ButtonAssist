; 功能函数
GetRandom(floatTime) {
    max := Abs(Integer(floatTime))
    min := -max
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

SplitCommand(info) {
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

SplitKeyCommand(macro){
    realKey := ""
    for key, value in MySoftData.SpecialKeyMap{
        newMacro := StrReplace(macro, key, "flagSymbol")
        if (newMacro != macro) {
            realKey := key
            break
        }
    }

    result := StrSplit(newMacro, "_")
    if (realKey != ""){
        result[1] := realKey
    }
    return result
}

;初始化数据
InitData() {
    InitTableItemState()

    SetGuiBtnAction()
}

SetGuiBtnAction() {
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
    MySoftData.HoldFloat := IniRead(IniFile, IniSection, "HoldFloat", 5)
    MySoftData.ClickFloat := IniRead(IniFile, IniSection, "ClickFloat", 5)
    MySoftData.IntervalFloat := IniRead(IniFile, IniSection, "IntervalFloat", 5)
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
    savedInfoArrStr := IniRead(IniFile, IniSection, symbol "InfoArr", "")
    savedModeArrStr := IniRead(IniFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(IniFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(IniFile, IniSection, symbol "ProcessNameArr", "")
    savedRemarkArrStr := IniRead(IniFile, IniSection, symbol "RemarkArr", "")
    savedLoopCountStr := IniRead(IniFile, IniSection, symbol "LoopCountArr", "")

    if (!MySoftData.HasSaved) {
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
        if (savedRemarkArrStr == "")
            savedRemarkArrStr := defaultInfo[6]
        if (savedLoopCountStr == "")
            savedLoopCountStr := defaultInfo[7]
    }

    tableItem := MySoftData.TableInfo[index]
    SetArr(savedTKArrStr, "π", tableItem.TKArr)
    SetArr(savedInfoArrStr, "π", tableItem.InfoArr)
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
    savedInfoArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    savedRemarkArrStr := ""
    savedLoopCountStr := ""
    symbol := GetTableSymbol(index)

    if (symbol == "Normal") {
        savedTKArrStr := "k"
        savedInfoArrStr :=
            "a_30_30_50,3000"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "演示配置"
        savedLoopCountStr := "1"

    }
    else if (symbol == "String") {
        savedTKArrStr := ":?*:AA"
        savedInfoArrStr := "lbutton_200,50,MouseMove_100_100_10"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "按两次a触发"
        savedLoopCountStr := "1"
    }
    else if (symbol == "Replace") {
        savedTKArrStr := "lπoπp"
        savedInfoArrStr := "leftπb,cπ"
        savedModeArrStr := "0π0π0"
        savedForbidArrStr := "1π1π1"
        savedProcessNameStr := "ππ"
    }
    else if (symbol == "Soft") {
        savedTKArrStr := "!d"
        savedInfoArrStr := "Notepad.exe"
        savedModeArrStr := "0"
        savedForbidArrStr := "0"
        savedProcessNameStr := ""
    }
    return [savedTKArrStr, savedInfoArrStr, savedModeArrStr, savedForbidArrStr, savedProcessNameStr, savedRemarkArrStr, savedLoopCountStr]
}

;资源保存
OnSaveSetting(*) {
    global MySoftData
    loop MySoftData.TabNameArr.Length {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(MySoftData.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(MySoftData.ClickFloatCtrl.Value, IniFile, IniSection, "ClickFloat")
    IniWrite(MySoftData.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(MySoftData.ImageSearchBlurCtrl.Value, IniFile, IniSection, "ImageSearchBlur")
    IniWrite(MySoftData.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
    IniWrite(MySoftData.KillMacroHotkeyCtrl.Value, IniFile, IniSection, "KillMacroHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(MySoftData.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(ToolCheckInfo.IsToolCheck, IniFile, IniSection, "IsToolCheck")
    IniWrite(ToolCheckInfo.ToolCheckHotKey, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(true, IniFile, IniSection, "HasSaved")
    SaveWinPos()
    Reload()
}

SaveTableItemInfo(index) {
    SavedInfo := GetSavedTableItemInfo(index)
    symbol := GetTableSymbol(index)
    IniWrite(SavedInfo[1], IniFile, IniSection, symbol "TKArr")
    IniWrite(SavedInfo[2], IniFile, IniSection, symbol "InfoArr")
    IniWrite(SavedInfo[3], IniFile, IniSection, symbol "ModeArr")
    IniWrite(SavedInfo[4], IniFile, IniSection, symbol "ForbidArr")
    IniWrite(SavedInfo[5], IniFile, IniSection, symbol "ProcessNameArr")
    IniWrite(SavedInfo[6], IniFile, IniSection, symbol "RemarkArr")
    IniWrite(SavedInfo[7], IniFile, IniSection, symbol "LoopCountArr")
}

GetSavedTableItemInfo(index) {
    Saved := MySoftData.MyGui.Submit()
    TKArrStr := ""
    InfoArrStr := ""
    ModeArrStr := ""
    ForbidArrStr := ""
    ProcessNameArrStr := ""
    RemarkArrStr := ""
    LoopCountArrStr := ""
    tableItem := MySoftData.TableInfo[index]
    symbol := GetTableSymbol(index)

    loop tableItem.ModeArr.Length {
        TKArrStr .= tableItem.TKConArr[A_Index].Value
        InfoArrStr .= tableItem.InfoConArr[A_Index].Value
        ModeArrStr .= tableItem.ModeConArr[A_Index].Value
        ForbidArrStr .= tableItem.ForbidConArr[A_Index].Value
        ProcessNameArrStr .= tableItem.ProcessNameConArr[A_Index].Value
        RemarkArrStr .= tableItem.RemarkConArr.Length >= A_Index ? tableItem.RemarkConArr[A_Index].Value : ""
        LoopCountArrStr .= GetItemSaveCountValue(tableItem.Index, A_Index)

        if (tableItem.ModeArr.Length > A_Index) {
            TKArrStr .= "π"
            InfoArrStr .= "π"
            ModeArrStr .= "π"
            ForbidArrStr .= "π"
            ProcessNameArrStr .= "π"
            RemarkArrStr .= "π"
            LoopCountArrStr .= "π"
        }
    }
    return [TKArrStr, InfoArrStr, ModeArrStr, ForbidArrStr, ProcessNameArrStr, RemarkArrStr, LoopCountArrStr]
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
        tableSymbol := GetTableSymbol(A_Index)
        tableItem := MySoftData.TableInfo[A_Index]
        tableItem.KeyActionArr := []
        tableItem.KilledArr := []
        tableItem.ActionCount := []
        tableItem.ImageActionArr := []
        for index, value in tableItem.ModeArr {
            tableItem.KilledArr.Push(false)
            tableItem.KeyActionArr.Push([])
            tableItem.ActionCount.Push(0)
            tableItem.ImageActionArr.Push(Map())
        }
    }
}

KillTableItemMacro() {
    loop MySoftData.TableInfo.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        for index, value in tableItem.ModeArr {
            tableItem.KilledArr[index] := true

            loop tableItem.KeyActionArr[index].Length {
                action := tableItem.KeyActionArr[index][A_Index]
                SetTimer action, 0
            }
            tableItem.KeyActionArr[index] := []

            for key, value in tableItem.ImageActionArr[index] {
                loop value.Length {
                    action := value[A_Index]
                    SetTimer action, 0
                }
            }
            tableItem.ImageActionArr[index] := Map()
        }
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

GetItemSaveCountValue(tableIndex, Index){
    itemtable := MySoftData.TableInfo[tableIndex]
    if (itemtable.LoopCountConArr.Length >= Index){
        value := itemtable.LoopCountConArr[Index].Value
        if (value == "∞")
            return -1
        if (IsInteger(value)){
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
