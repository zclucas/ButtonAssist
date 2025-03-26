; 功能函数
GetFloatTime(oriTime, floatValue) {
    oriTime := Integer(oriTime)
    floatValue := Integer(floatValue)
    value := Abs(oriTime * (floatValue * 0.01))
    max := oriTime + value
    min := oriTime - value
    return Random(min, max)
}

GetCurMSec() {
    return A_Hour * 3600 * 1000 + A_Min * 60 * 1000 + A_Sec * 1000 + A_mSec
}

GetProcessName() {
    MouseGetPos &mouseX, &mouseY, &winId
    name := WinGetProcessName(winId)
    return name
}

SaveClipToBitmap(filePath) {
    ; 保存位图到文件; 检查剪切板中是否有位图
    if !DllCall("IsClipboardFormatAvailable", "uint", 2)  ; 2 是 CF_BITMAP
    {
        MsgBox("剪切板中没有位图")
    }

    ; 打开剪切板
    if !DllCall("OpenClipboard", "ptr", 0) {
        MsgBox("无法打开剪切板")
        return
    }

    ; 获取剪切板中的位图句柄
    hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr")  ; 2 是 CF_BITMAP
    if !hBitmap {
        MsgBox("无法获取位图句柄")
        DllCall("CloseClipboard")
        return
    }

    ; 关闭剪切板
    DllCall("CloseClipboard")

    ; 创建 GDI+ 位图对象
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
    if !pBitmap {
        MsgBox("无法创建 GDI+ 位图对象")
        return
    }

    ; 保存位图到文件
    Gdip_SaveBitmapToFile(pBitmap, filePath)

    ; 释放 GDI+ 位图对象
    Gdip_DisposeImage(pBitmap)
}

GetImageSize(imageFile) {
    pBm := Gdip_CreateBitmapFromFile(imageFile)
    width := Gdip_GetImageWidth(pBm)
    height := Gdip_GetImageHeight(pBm)

    Gdip_DisposeImage(pBm)
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
        if (result[A_Index] == "flagSymbol") {
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
    if (!CheckIfInstallVjoy())
        return
    joyAxisNum := 8
    tableItem := MySoftData.SpecialTableItem
    tableItem.HoldKeyArr[1] := Map()
    loop joyAxisNum {
        SendJoyAxisClick("JoyAxis" A_Index "Max", 30, tableItem, 1)
    }
}

InitGui() {
    MyTriggerKeyGui.SaveBtnAction := OnSaveSetting
    MyTriggerStrGui.SaveBtnAction := OnSaveSetting
    MyMacroGui.SaveBtnAction := OnSaveSetting
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
    ToolCheckInfo.ToolRecordMacroHotKey := IniRead(IniFile, IniSection, "RecordMacroHotKey", "!r")
    ToolCheckInfo.ToolTextFilterHotKey := IniRead(IniFile, IniSection, "ToolTextFilterHotKey", "!w")
    ToolCheckInfo.RecordKeyboardValue := IniRead(IniFile, IniSection, "RecordKeyboardValue", true)
    ToolCheckInfo.RecordMouseValue := IniRead(IniFile, IniSection, "RecordMouseValue", true)
    ToolCheckInfo.RecordMouseRelativeValue := IniRead(IniFile, IniSection, "RecordMouseRelativeValue", false)
    MySoftData.IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
    MySoftData.IsBootStart := IniRead(IniFile, IniSection, "IsBootStart", false)
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
    savedLooseStopArrStr := IniRead(IniFile, IniSection, symbol "LooseStopArr", "")

    if (!MySoftData.HasSaved) {
        if (savedTKArrStr == "")
            savedTKArrStr := defaultInfo[1]
        if (savedMacroArrStr == "")
            savedMacroArrStr := defaultInfo[2]
        if (savedLooseStopArrStr == "")
            savedLooseStopArrStr := defaultInfo[3]
        if (savedModeArrStr == "")
            savedModeArrStr := defaultInfo[4]
        if (savedForbidArrStr == "")
            savedForbidArrStr := defaultInfo[5]
        if (savedProcessNameStr == "")
            savedProcessNameStr := defaultInfo[6]
        if (savedRemarkArrStr == "")
            savedRemarkArrStr := defaultInfo[7]
        if (savedLoopCountStr == "")
            savedLoopCountStr := defaultInfo[8]
    }

    tableItem := MySoftData.TableInfo[index]
    SetArr(savedTKArrStr, "π", tableItem.TKArr)
    SetArr(savedMacroArrStr, "π", tableItem.MacroArr)
    SetArr(savedModeArrStr, "π", tableItem.ModeArr)
    SetArr(savedForbidArrStr, "π", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, "π", tableItem.ProcessNameArr)
    SetArr(savedRemarkArrStr, "π", tableItem.RemarkArr)
    SetIntArr(savedLoopCountStr, "π", tableItem.LoopCountArr)
    SetArr(savedLooseStopArrStr, "π", tableItem.LooseStopArr)
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
    savedLooseStopArrStr := ""
    symbol := GetTableSymbol(index)

    if (symbol == "Normal") {
        savedTKArrStr := "k"
        savedMacroArrStr := "按键_a_30_30_50,间隔_3000"
        savedLooseStopArrStr := "0"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "取消禁止配置才能生效"
        savedLoopCountStr := "1"

    }
    else if (symbol == "String") {
        savedTKArrStr := ":?*:AA"
        savedMacroArrStr := "按键_LButton_50,间隔_50,移动_100_100_90"
        savedLooseStopArrStr := "0"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "按两次a触发"
        savedLoopCountStr := "1"
    }
    else if (symbol == "Replace") {
        savedTKArrStr := "l"
        savedMacroArrStr := "Left,a"
        savedLooseStopArrStr := "0"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
    }
    return [savedTKArrStr, savedMacroArrStr, savedLooseStopArrStr, savedModeArrStr, savedForbidArrStr,
        savedProcessNameStr, savedRemarkArrStr,
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
    IniWrite(MySoftData.BootStartCtrl.Value, IniFile, IniSection, "IsBootStart")
    IniWrite(ToolCheckInfo.IsToolCheck, IniFile, IniSection, "IsToolCheck")
    IniWrite(ToolCheckInfo.ToolCheckHotKeyCtrl.Value, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(ToolCheckInfo.ToolRecordMacroHotKeyCtrl.Value, IniFile, IniSection, "RecordMacroHotKey")
    IniWrite(ToolCheckInfo.ToolTextFilterHotKeyCtrl.Value, IniFile, IniSection, "ToolTextFilterHotKey")
    IniWrite(ToolCheckInfo.RecordKeyboardCtrl.Value, IniFile, IniSection, "RecordKeyboardValue")
    IniWrite(ToolCheckInfo.RecordMouseCtrl.Value, IniFile, IniSection, "RecordMouseValue")
    IniWrite(ToolCheckInfo.RecordMouseRelativeCtrl.Value, IniFile, IniSection, "RecordMouseRelativeValue")
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
    IniWrite(SavedInfo[4], IniFile, IniSection, symbol "LooseStopArr")
    IniWrite(SavedInfo[5], IniFile, IniSection, symbol "ForbidArr")
    IniWrite(SavedInfo[6], IniFile, IniSection, symbol "ProcessNameArr")
    IniWrite(SavedInfo[7], IniFile, IniSection, symbol "RemarkArr")
    IniWrite(SavedInfo[8], IniFile, IniSection, symbol "LoopCountArr")
}

GetSavedTableItemInfo(index) {
    Saved := MySoftData.MyGui.Submit()
    TKArrStr := ""
    MacroArrStr := ""
    ModeArrStr := ""
    LooseStopArrStr := ""
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
        LooseStopArrStr .= tableItem.LooseStopConArr[A_Index].Value
        ProcessNameArrStr .= tableItem.ProcessNameConArr[A_Index].Value
        RemarkArrStr .= tableItem.RemarkConArr.Length >= A_Index ? tableItem.RemarkConArr[A_Index].Value : ""
        LoopCountArrStr .= GetItemSaveCountValue(tableItem.Index, A_Index)

        if (tableItem.ModeArr.Length > A_Index) {
            TKArrStr .= "π"
            MacroArrStr .= "π"
            ModeArrStr .= "π"
            LooseStopArrStr .= "π"
            ForbidArrStr .= "π"
            ProcessNameArrStr .= "π"
            RemarkArrStr .= "π"
            LoopCountArrStr .= "π"
        }
    }
    MacroArrStr := StrReplace(MacroArrStr, "`n", ",")
    return [TKArrStr, MacroArrStr, ModeArrStr, LooseStopArrStr, ForbidArrStr, ProcessNameArrStr, RemarkArrStr,
        LoopCountArrStr]
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

    tableItem := MySoftData.SpecialTableItem
    tableItem.ModeArr := [0]
    InitSingleTableState(tableItem)
}

InitSingleTableState(tableItem) {
    tableItem.CmdActionArr := []
    tableItem.KilledArr := []
    tableItem.ActionCount := []
    tableItem.ActionArr := []
    tableItem.HoldKeyArr := []
    for index, value in tableItem.ModeArr {
        tableItem.KilledArr.Push(false)
        tableItem.CmdActionArr.Push([])
        tableItem.ActionCount.Push(0)
        tableItem.ActionArr.Push(Map())
        tableItem.HoldKeyArr.Push(Map())
    }
}

KillSingleTableMacro(tableItem) {
    for index, value in tableItem.ModeArr {
        KillTableItemMacro(tableItem, index)
    }
}

KillTableItemMacro(tableItem, index) {
    tableItem.KilledArr[index] := true
    for key, value in tableItem.HoldKeyArr[index] {
        if (value == "Game") {
            SendGameModeKey(key, 0, tableItem, index)
        }
        else if (value == "Normal") {
            SendNormalKey(key, 0, tableItem, index)
        }
        else if (value == "Joy") {
            SendJoyBtnKey(key, 0, tableItem, index)
        }
        else if (value == "JoyAxis") {
            SendJoyAxisKey(key, 0, tableItem, index)
        }
        else if (value == "GameMouse") {
            SendGameMouseKey(key, 0, tableItem, index)
        }
    }

    loop tableItem.CmdActionArr[index].Length {
        action := tableItem.CmdActionArr[index][A_Index]
        SetTimer action, 0
    }
    tableItem.CmdActionArr[index] := []

    for key, value in tableItem.ActionArr[index] {
        loop value.Length {
            action := value[A_Index]
            SetTimer action, 0
        }
    }
    tableItem.ActionArr[index] := Map()
}

GetTabHeight() {
    maxY := 0
    loop MySoftData.TabNameArr.Length {
        posY := MySoftData.TableInfo[A_Index].UnderPosY
        if (posY > maxY)
            maxY := posY
    }

    height := maxY - MySoftData.TabPosY
    return Max(height, 500)
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


GetRecordMacroEditStr(macro) {
    CommandArr := SplitMacro(macro)
    macroEditStr := ""
    processedIndex := 0
    for index, value in CommandArr {
        if (processedIndex >= index)
            continue
        processedIndex := index
        isInterval := StrCompare(SubStr(value, 1, 2), "间隔", false) == 0
        if (isInterval) {
            SubCommandArr := StrSplit(value, "_")
            intervalValue := Integer(SubCommandArr[2])
            loop {
                curIndex := index + A_Index
                if (curIndex > CommandArr.Length)
                    break

                SubCommandArr := StrSplit(CommandArr[curIndex], "_")
                isIntervalAgain := StrCompare(SubStr(SubCommandArr[1], 1, 2), "间隔", false) == 0
                if (!isIntervalAgain)
                    break
                intervalValue += Integer(SubCommandArr[2])
                processedIndex := curIndex
            }
            macroEditStr := index == 1 ? macroEditStr : macroEditStr ","
            macroEditStr .= "间隔_" intervalValue "`n"
            continue
        }

        isPressKey := StrCompare(SubStr(value, 1, 2), "按键", false) == 0
        if (isPressKey) {
            macroEditStr .= value
            loop {
                curIndex := index + A_Index
                if (curIndex > CommandArr.Length)
                    break

                SubCommandArr := StrSplit(CommandArr[curIndex], "_")
                isPressKeyAgain := StrCompare(SubStr(SubCommandArr[1], 1, 2), "按键", false) == 0
                if (!isPressKeyAgain)
                    break
                macroEditStr .= "," CommandArr[curIndex]
                processedIndex := curIndex
            }
        }

        isMouseMove := StrCompare(SubStr(value, 1, 2), "移动", false) == 0
        if (isMouseMove) {
            macroEditStr .= value
        }

        nextIndex := processedIndex + 1
        isNextInterval := nextIndex <= CommandArr.Length
        isNextInterval := isNextInterval && StrCompare(SubStr(CommandArr[nextIndex], 1, 2), "间隔", false) == 0
        if (!isNextInterval) {
            macroEditStr .= "`n"
        }
    }
    return macroEditStr
}


CheckIsNormalTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    return false
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

CheckIsHotKey(key) {
    if (SubStr(key, 1, 1) == ":")
        return false

    if (SubStr(key, 1, 3) == "Joy")
        return false

    if (MySoftData.SpecialKeyMap.Has(key))
        return false

    return true
}

CheckIfInstallVjoy() {
    vJoyFolder := RegRead(
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1",
        "InstallLocation", "")
    if (!vJoyFolder)
        return false
    return true
}

CheckAutoStart() {
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    try {
        ; 尝试读取注册表项
        RegRead(regPath, "ButtonAssist")
        return true
    } catch {
        return false
    }
}

CheckContainText(source, text) {
    ; 返回布尔值：true 表示包含，false 表示不包含
    return InStr(source, text) > 0
}

GetScreenTextObjArr(X1, Y1, X2, Y2) {
    global MyOcr
    width := X2 - X1
    height := Y2 - Y1
    pBitmap := Gdip_BitmapFromScreen(X1 "|" Y1 "|" width "|" height)

    ; 获取位图的宽度和高度
    Width := Gdip_GetImageWidth(pBitmap)
    Height := Gdip_GetImageHeight(pBitmap)

    ; 锁定位图以获取位图数据
    Gdip_LockBits(pBitmap, 0, 0, Width, Height, &Stride, &Scan0, &BitmapData)

    ; 创建 BITMAP_DATA 结构
    BITMAP_DATA := Buffer(24)  ; BITMAP_DATA 结构大小为 24 字节
    NumPut("ptr", Scan0, BITMAP_DATA, 0)  ; bits
    NumPut("uint", Stride, BITMAP_DATA, 8)  ; pitch
    NumPut("int", Width, BITMAP_DATA, 12)  ; width
    NumPut("int", Height, BITMAP_DATA, 16)  ; height
    NumPut("int", 4, BITMAP_DATA, 20)  ; bytespixel (假设是 32 位图像)

    ; 调用 ocr_from_bitmapdata 方法
    result := MyOcr.ocr_from_bitmapdata(BITMAP_DATA, , true)

    ; 解锁位图
    Gdip_UnlockBits(pBitmap, &BitmapData)
    ; 释放位图
    Gdip_DisposeImage(pBitmap)
    return result
}

CheckScreenContainText(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, text){
    result := GetScreenTextObjArr(X1, Y1, X2, Y2)
    if (result == "" || !result)
        return false
    for index, value in result {
        isContain := CheckContainText(value.text, text)
        if (isContain) {
            pos := GetMatchCoord(value, X1, Y1)
            OutputVarX := pos[1]
            OutputVarY := pos[2]
            break
        }
    }
    return isContain
}

GetMatchCoord(screenTextObj, x1, y1){
    value := screenTextObj
    pointX := value.boxPoint[1].x + value.boxPoint[2].x + value.boxPoint[3].x + value.boxPoint[4].x
    pointY := value.boxPoint[1].y + value.boxPoint[2].y + value.boxPoint[3].y + value.boxPoint[4].y
    OutputVarX := x1 + pointX / 4
    OutputVarY := y1 + pointY / 4
    return [OutputVarX, OutputVarY]
}

IsClipboardText() {
    ; 检查是否存在文本格式
    if DllCall("IsClipboardFormatAvailable", "UInt", 1)  ; CF_TEXT = 1
        return true
    if DllCall("IsClipboardFormatAvailable", "UInt", 13) ; CF_UNICODETEXT = 13
        return true
    return false
}

ClearUselessSetting(deleteMacro){
    if (deleteMacro == "")
        return
    RegExMatch(deleteMacro, "(Compare\d+)", &match)
    match := match != "" ? match : [] 
    for id, value in match{
        if (value == "")
            continue
        IniDelete(CompareFile, IniSection, value)
    }

    RegExMatch(deleteMacro, "(Coord\d+)", &match)
    match := match != "" ? match : [] 
    for id, value in match{
        if (value == "")
            continue
        IniDelete(CoordFile, IniSection, value)
    }
}