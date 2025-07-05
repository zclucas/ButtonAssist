#Requires AutoHotkey v2.0

;绑定热键
OnExitSoft(*) {
    global MyPToken, MyChineseOcr
    Gdip_Shutdown(MyPToken)
    MyChineseOcr := ""
    MyEnglishOcr := ""
    MyWorkPool.Clear()
}

BindPauseHotkey() {
    global MySoftData
    if (MySoftData.PauseHotkey != "") {
        key := "$*~" MySoftData.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

OnPauseHotkey(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsPause := !MySoftData.IsPause
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    OnKillAllMacro()
    if (MySoftData.IsPause)
        TraySetIcon("Images\Soft\IcoPause.ico")
    else
        TraySetIcon("Images\Soft\rabit.ico")
    Suspend(MySoftData.IsPause)
}

OnKillAllMacro(*) {
    global MySoftData ; 访问全局变量

    loop MySoftData.TableInfo.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        KillSingleTableMacro(tableItem)
    }
    MyWorkPool.Clear()
    KillSingleTableMacro(MySoftData.SpecialTableItem)
}

;资源保存
OnSaveSetting(*) {
    global MySoftData
    MyWorkPool.Clear()
    loop MySoftData.TabNameArr.Length {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(MySoftData.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(MySoftData.PreIntervalFloatCtrl.Value, IniFile, IniSection, "PreIntervalFloat")
    IniWrite(MySoftData.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(MySoftData.CoordXFloatCon.Value, IniFile, IniSection, "CoordXFloat")
    IniWrite(MySoftData.CoordYFloatCon.Value, IniFile, IniSection, "CoordYFloat")
    IniWrite(MySoftData.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
    IniWrite(MySoftData.KillMacroHotkeyCtrl.Value, IniFile, IniSection, "KillMacroHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(MySoftData.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(MySoftData.BootStartCtrl.Value, IniFile, IniSection, "IsBootStart")
    IniWrite(MySoftData.MutiThreadNumCtrl.Value, IniFile, IniSection, "MutiThreadNum")
    IniWrite(MySoftData.MutiThreadCtrl.Value, IniFile, IniSection, "MutiThread")
    IniWrite(ToolCheckInfo.ToolCheckHotKeyCtrl.Value, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(ToolCheckInfo.ToolRecordMacroHotKeyCtrl.Value, IniFile, IniSection, "RecordMacroHotKey")
    IniWrite(ToolCheckInfo.ToolTextFilterHotKeyCtrl.Value, IniFile, IniSection, "ToolTextFilterHotKey")
    IniWrite(ToolCheckInfo.RecordKeyboardCtrl.Value, IniFile, IniSection, "RecordKeyboardValue")
    IniWrite(ToolCheckInfo.RecordMouseCtrl.Value, IniFile, IniSection, "RecordMouseValue")
    IniWrite(ToolCheckInfo.RecordJoyCtrl.Value, IniFile, IniSection, "RecordJoyValue")
    IniWrite(ToolCheckInfo.RecordMouseRelativeCtrl.Value, IniFile, IniSection, "RecordMouseRelativeValue")
    IniWrite(ToolCheckInfo.OCRTypeCtrl.Value, IniFile, IniSection, "OCRType")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(true, IniFile, IniSection, "HasSaved")
    SaveWinPos()
    Reload()
}

OnTableDelete(tableItem, index) {
    if (tableItem.ModeArr.Length == 0) {
        return
    }
    result := MsgBox("是否删除当前配置", "提示", 1)
    if (result == "Cancel")
        return

    deleteMacro := tableItem.MacroArr.Length >= index ? tableItem.MacroArr[index] : ""
    ClearUselessSetting(deleteMacro)

    MySoftData.BtnAdd.Enabled := false
    tableItem.ModeArr.RemoveAt(index)
    tableItem.ForbidArr.RemoveAt(index)
    tableItem.HoldTimeArr.RemoveAt(index)
    if (tableItem.TKArr.Length >= index)
        tableItem.TKArr.RemoveAt(index)
    if (tableItem.MacroArr.Length >= index)
        tableItem.MacroArr.RemoveAt(index)
    if (tableItem.ProcessNameArr.Length >= index)
        tableItem.ProcessNameArr.RemoveAt(index)
    if (tableItem.LoopCountArr.Length >= index)
        tableItem.LoopCountArr.RemoveAt(index)
    if (tableItem.RemarkArr.Length >= index)
        tableItem.RemarkArr.RemoveAt(index)
    if (tableItem.SerialArr.Length >= index)
        tableItem.SerialArr.RemoveAt(index)
    if (tableItem.MacroTypeArr.Length >= index)
        tableItem.MacroTypeArr.RemoveAt(index)
    tableItem.IndexConArr.RemoveAt(index)
    tableItem.TriggerTypeConArr.RemoveAt(index)
    tableItem.ModeConArr.RemoveAt(index)
    tableItem.ForbidConArr.RemoveAt(index)
    tableItem.TKConArr.RemoveAt(index)
    tableItem.InfoConArr.RemoveAt(index)
    tableItem.ProcessNameConArr.RemoveAt(index)
    tableItem.LoopCountConArr.RemoveAt(index)
    tableItem.RemarkConArr.RemoveAt(index)
    tableItem.MacroTypeConArr.RemoveAt(index)

    OnSaveSetting()
}
BindTabHotKey() {
    tableIndex := 0
    loop MySoftData.TabNameArr.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        tableIndex := A_Index
        for index, value in tableItem.ModeArr {
            if (tableItem.TKArr.Length < index || tableItem.TKArr[index] == "" || (Integer)(tableItem.ForbidArr[index]))
                continue

            if (tableItem.MacroArr.Length < index || tableItem.MacroArr[index] == "")
                continue

            key := "$*" tableItem.TKArr[index]
            actionArr := GetMacroAction(tableIndex, index)
            isJoyKey := RegExMatch(tableItem.TKArr[index], "Joy")
            isHotstring := SubStr(tableItem.TKArr[index], 1, 1) == ":"
            curProcessName := tableItem.ProcessNameArr.Length >= index ? tableItem.ProcessNameArr[index] : ""

            if (curProcessName != "") {
                processInfo := Format("ahk_exe {}", curProcessName)
                HotIfWinActive(processInfo)
            }

            if (isJoyKey) {
                MyJoyMacro.AddMacro(tableItem.TKArr[index], actionArr[1], curProcessName)
            }
            else if (isHotstring) {
                Hotstring(tableItem.TKArr[index], actionArr[1])
            }
            else {
                if (actionArr[1] != "")
                    Hotkey(key, actionArr[1])

                if (actionArr[2] != "")
                    Hotkey(key " up", actionArr[2])
            }

            if (curProcessName != "") {
                HotIfWinActive
            }
        }
    }
}

OnFinishMacro(tableItem, macro, index) {

    key := "$*" tableItem.TKArr[index]
    actionArr := GetMacroAction(tableItem.Index, index)
    isJoyKey := RegExMatch(tableItem.TKArr[index], "Joy")
    isHotstring := SubStr(tableItem.TKArr[index], 1, 1) == ":"
    curProcessName := tableItem.ProcessNameArr.Length >= index ? tableItem.ProcessNameArr[index] : ""

    if (curProcessName != "") {
        processInfo := Format("ahk_exe {}", curProcessName)
        HotIfWinActive(processInfo)
    }

    if (isJoyKey) {
        MyJoyMacro.AddMacro(tableItem.TKArr[index], actionArr[1], curProcessName)
    }
    else if (isHotstring) {
        Hotstring(tableItem.TKArr[index], actionArr[1])
    }
    else {
        if (actionArr[1] != "") {
            Hotkey(key, actionArr[1], "OFF")
            Hotkey(key, actionArr[1], "ON")
        }

        if (actionArr[2] != "") {
            Hotkey(key " up", actionArr[2], "OFF")
            Hotkey(key " up", actionArr[2], "ON")
        }

    }

    if (curProcessName != "") {
        HotIfWinActive
    }
}

GetMacroAction(tableIndex, index) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[index]
    tableSymbol := GetTableSymbol(tableIndex)
    actionDown := ""
    actionUp := ""

    if (tableSymbol == "Normal") {
        actionDown := GetClosureActionNew(tableIndex, index, OnTriggerKeyDown)
        actionUp := GetClosureActionNew(tableIndex, index, OnTriggerKeyUp)
    }
    else if (tableSymbol == "String") {
        actionDown := GetClosureActionNew(tableIndex, index, TriggerMacroHandler)
    }
    else if (tableSymbol == "Replace") {
        actionDown := GetClosureAction(tableItem, macro, index, OnReplaceDownKey)
        actionUp := GetClosureAction(tableItem, macro, index, OnReplaceUpKey)
    }

    return [actionDown, actionUp]
}

OnTriggerKeyDown(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    if (tableItem.IsWorkArr[itemIndex] && tableItem.TriggerTypeArr[itemIndex] != 4) ;不是开关
    {
        return
    }

    if (tableItem.TriggerTypeArr[itemIndex] == 1) { ;按下触发
        if (SubStr(tableItem.TKArr[itemIndex], 1, 1) != "~")
            LoosenModifyKey(tableItem.TKArr[itemIndex])
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 3) { ;松开停止
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 4) {  ;开关
        OnToggleTriggerMacro(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 5) {    ;长按
        Sleep(tableItem.HoldTimeArr[itemIndex])

        keyCombo := LTrim(tableItem.TKArr[itemIndex], "~")
        if (AreKeysPressed(keyCombo))
            TriggerMacroHandler(tableIndex, itemIndex)
    }
}

;松开停止
OnTriggerKeyUp(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    isWork := tableItem.IsWorkArr[itemIndex]
    if (tableItem.TriggerTypeArr[itemIndex] == 2 && !isWork) { ;松开触发
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 3) {  ;松开停止
        if (isWork) {
            workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
            MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
            return
        }

        KillTableItemMacro(tableItem, itemIndex)
    }
}

OnToggleTriggerMacro(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    isSeries := tableItem.MacroTypeArr[itemIndex] == 1  ;触发串联指令
    hasWork := MyWorkPool.CheckHasWork()

    if (tableItem.IsWorkArr[itemIndex]) {
        workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
        tableItem.IsWorkArr[itemIndex] := false
        MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
        return
    }

    if (isSeries && hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
        return
    }

    isTrigger := tableItem.ToggleStateArr[itemIndex]
    if (!isTrigger) {
        action := OnTriggerMacroKeyAndInit.Bind(tableItem, macro, itemIndex)
        SetTimer(action, -1)
        tableItem.ToggleActionArr[itemIndex] := action
        tableItem.ToggleStateArr[itemIndex] := true
    }
    else {
        action := tableItem.ToggleActionArr[itemIndex]
        if (action == "")
            return

        SetTimer(action, 0)
        KillTableItemMacro(tableItem, itemIndex)
        tableItem.ToggleStateArr[itemIndex] := false
    }
}

TriggerMacroHandler(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    isSeries := tableItem.MacroTypeArr[itemIndex] == 1  ;触发串联指令
    isWork := tableItem.IsWorkArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()
    if (isWork)
        return

    if (isSeries && hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
    }
    else {
        OnTriggerMacroKeyAndInit(tableItem, macro, itemIndex)
    }
}

OnTableEditMacro(tableItem, index) {
    macro := tableItem.InfoConArr[index].Value
    MyMacroGui.SureBtnAction := (sureMacro) => tableItem.InfoConArr[index].Value := sureMacro
    MyMacroGui.ShowGui(macro, true)
}

OnTableEditReplaceKey(tableItem, index) {
    replaceKey := tableItem.InfoConArr[index].Value
    MyReplaceKeyGui.SureBtnAction := (sureReplaceKey) => tableItem.InfoConArr[index].Value := sureReplaceKey
    MyReplaceKeyGui.ShowGui(replaceKey)
}

OnTableEditTriggerKey(tableItem, index) {
    triggerKey := tableItem.TKConArr[index].Value
    MyTriggerKeyGui.SureBtnAction := (sureTriggerKey) => tableItem.TKConArr[index].Value := sureTriggerKey
    args := TriggerKeyGuiArgs()
    args.IsToolEdit := false
    args.tableItem := tableItem
    args.tableIndex := index
    MyTriggerKeyGui.ShowGui(triggerKey, args)
}

OnTableEditTriggerStr(tableItem, index) {
    triggerStr := tableItem.TKConArr[index].Value
    MyTriggerStrGui.SureBtnAction := (sureTriggerStr) => tableItem.TKConArr[index].Value := sureTriggerStr
    MyTriggerStrGui.ShowGui(triggerStr, true)
}

ResetWinPosAndRefreshGui(*) {
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    MySoftData.IsSavedWinPos := false
    RefreshGui()
}

BindSave() {
    MyTriggerKeyGui.SaveBtnAction := OnSaveSetting
    MyTriggerStrGui.SaveBtnAction := OnSaveSetting
    MyMacroGui.SaveBtnAction := OnSaveSetting
}

BindKey() {
    BindPauseHotkey()
    BindShortcut(MySoftData.KillMacroHotkey, OnKillAllMacro)
    BindShortcut(ToolCheckInfo.ToolCheckHotKey, OnToolCheckHotkey)
    BindShortcut(ToolCheckInfo.ToolTextFilterHotKey, OnToolTextFilterScreenShot)
    BindShortcut(ToolCheckInfo.ToolRecordMacroHotKey, OnToolRecordMacro)
    BindTabHotKey()
    BindScrollHotkey("~WheelUp", OnChangeSrollValue)
    BindScrollHotkey("~WheelDown", OnChangeSrollValue)
    BindScrollHotkey("~+WheelUp", OnChangeSrollValue)
    BindScrollHotkey("~+WheelDown", OnChangeSrollValue)

    OnExit(OnExitSoft)
}

OnChangeSrollValue(*) {
    wParam := InStr(A_ThisHotkey, "Down") ? 1 : 0
    lParam := 0
    msg := GetKeyState("Shift") ? 0x114 : 0x115
    MySoftData.SB.ScrollMsg(wParam, lParam, msg, MySoftData.MyGui.Hwnd)
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck

    if (ToolCheckInfo.IsToolCheck) {
        ToolCheckInfo.MouseInfoTimer := Timer(SetToolCheckInfo, 100)
        ToolCheckInfo.MouseInfoTimer.On()
    }
    else
        ToolCheckInfo.MouseInfoTimer := ""
}

OnToolAlwaysOnTop(*) {
    global MySoftData, ToolCheckInfo
    state := ToolCheckInfo.AlwaysOnTopCtrl.Value
    if (state) {
        MySoftData.MyGui.Opt("+AlwaysOnTop")
    }
    else {
        MySoftData.MyGui.Opt("-AlwaysOnTop")
    }
}

InitFilePath() {
    if (!DirExist(A_WorkingDir "\Setting")) {
        DirCreate(A_WorkingDir "\Setting")
    }
    if (!DirExist(A_WorkingDir "\Images")) {
        DirCreate(A_WorkingDir "\Images")
    }
    if (!DirExist(A_WorkingDir "\Images\Soft")) {
        DirCreate(A_WorkingDir "\Images\Soft")
    }

    FileInstall("Images\Soft\WeiXin.png", "Images\Soft\WeiXin.png", 1)
    FileInstall("Images\Soft\ZhiFuBao.png", "Images\Soft\ZhiFuBao.png", 1)
    FileInstall("Images\Soft\rabit.ico", "Images\Soft\rabit.ico", 1)
    FileInstall("Images\Soft\IcoPause.ico", "Images\Soft\IcoPause.ico", 1)

    global vbsPath := A_WorkingDir "\VBS\PlayAudio.vbs"
    global IniFile := A_WorkingDir "\Setting\MainSettings.ini"
    global SearchFile := A_WorkingDir "\Setting\SearchFile.ini"
    global SearchProFile := A_WorkingDir "\Setting\SearchProFile.ini"
    global CompareFile := A_WorkingDir "\Setting\CompareFile.ini"
    global CoordFile := A_WorkingDir "\Setting\CoordFile.ini"
    global FileFile := A_WorkingDir "\Setting\FileFile.ini"
    global OutputFile := A_WorkingDir "\Setting\OutputFile.ini"
    global StopFile := A_WorkingDir "\Setting\StopFile.ini"
    global VariableFile := A_WorkingDir "\Setting\VariableFile.ini"
    global SubMacroFile := A_WorkingDir "\Setting\SubMacroFile.ini"
    global OperationFile := A_WorkingDir "\Setting\OperationFile.ini"
    global BGMouseFile := A_WorkingDir "\Setting\BGMouseFile.ini"
    global IniSection := "UserSettings"
}

SubMacroStopAction(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
    tableItem.IsWorkArr[itemIndex] := false
    MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
}

TriggerSubMacro(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    isSeries := tableItem.MacroTypeArr[itemIndex] == 1  ;触发串联指令
    isWork := tableItem.IsWorkArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()

    if (isSeries && hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
    }
    else {
        OnTriggerMacroKeyAndInit(tableItem, macro, itemIndex)
    }
}

OnToolRecordMacro(*) {
    global ToolCheckInfo, MySoftData
    spacialKeyArr := ["NumpadEnter"]
    ToolCheckInfo.IsToolRecord := !ToolCheckInfo.IsToolRecord
    ToolCheckInfo.ToolCheckRecordMacroCtrl.Value := ToolCheckInfo.IsToolRecord
    if (MySoftData.MacroEditGui != "") {
        MySoftData.RecordToggleCon.Value := ToolCheckInfo.IsToolRecord
    }
    state := ToolCheckInfo.IsToolRecord
    StateSymbol := state ? "On" : "Off"
    loop 255 {
        key := Format("$*~vk{:X}", A_Index)
        if (ToolCheckInfo.RecordSpecialKeyMap.Has(A_Index)) {
            keyName := GetKeyName(Format("vk{:X}", A_Index))
            key := Format("$*~sc{:X}", GetKeySC(keyName))
        }

        try {
            Hotkey(key, OnRecordMacroKeyDown, StateSymbol)
            Hotkey(key " Up", OnRecordMacroKeyUp, StateSymbol)
        }
        catch {
            continue
        }
    }

    loop spacialKeyArr.Length {
        key := Format("$*~sc{:X}", GetKeySC(spacialKeyArr[A_Index]))
        Hotkey(key, OnRecordMacroKeyDown, StateSymbol)
        Hotkey(key " Up", OnRecordMacroKeyUp, StateSymbol)
    }

    if (state) {
        ToolCheckInfo.RecordNodeArr := []
        ToolCheckInfo.RecordKeyboardArr := []
        ToolCheckInfo.RecordHoldKeyMap := Map()

        node := RecordNodeData()
        node.StartTime := GetCurMSec()
        ToolCheckInfo.RecordNodeArr.Push(node)

        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        ToolCheckInfo.RecordLastMousePos := [mouseX, mouseY]
        if (ToolCheckInfo.RecordJoyValue)
            SetTimer RecordJoy, -1
    }
    else {
        if (ToolCheckInfo.RecordNodeArr.Length > 0) {
            node := ToolCheckInfo.RecordNodeArr[ToolCheckInfo.RecordNodeArr.Length]
            node.EndTime := GetCurMSec()
        }
        OnFinishRecordMacro()
    }
}

OnRecordMacroKeyDown(*) {
    key := StrReplace(A_ThisHotkey, "$", "")
    key := StrReplace(key, "*~", "")
    keyName := GetKeyName(key)
    if (ToolCheckInfo.RecordHoldKeyMap.Has(keyName))
        return
    ToolCheckInfo.RecordHoldKeyMap.Set(keyName, true)

    node := ToolCheckInfo.RecordNodeArr[ToolCheckInfo.RecordNodeArr.Length]
    node.EndTime := GetCurMSec()

    CoordMode("Mouse", "Screen")
    MouseGetPos &mouseX, &mouseY
    data := KeyboardData()
    data.StartTime := GetCurMSec()
    data.NodeSerial := ToolCheckInfo.RecordNodeArr.Length
    data.keyName := keyName
    data.StartPos := [mouseX, mouseY]
    ToolCheckInfo.RecordKeyboardArr.Push(data)

    node := RecordNodeData()
    node.StartTime := GetCurMSec()
    ToolCheckInfo.RecordNodeArr.Push(node)

    if (keyName == "WheelUp" || keyName == "WheelDown") {
        ToolCheckInfo.RecordHoldKeyMap.Delete(keyName)
        data.EndTime := data.StartTime + 50
        data.EndPos := [mouseX, mouseY]
    }
}

OnRecordMacroKeyUp(*) {
    key := StrReplace(A_ThisHotkey, "$", "")
    key := StrReplace(key, "*~", "")
    key := StrReplace(key, " Up", "")
    keyName := GetKeyName(key)
    if (ToolCheckInfo.RecordHoldKeyMap.Has(keyName))
        ToolCheckInfo.RecordHoldKeyMap.Delete(keyName)

    for index, value in ToolCheckInfo.RecordKeyboardArr {
        if (value.keyName == keyName && value.EndTime == 0) {
            CoordMode("Mouse", "Screen")
            MouseGetPos &mouseX, &mouseY
            value.EndTime := GetCurMSec()
            value.EndPos := [mouseX, mouseY]
            break
        }
    }
}

OnFinishRecordMacro() {
    macro := ""
    for index, value in ToolCheckInfo.RecordNodeArr {
        macro .= "间隔_" value.Span() ","

        for key, value in ToolCheckInfo.RecordKeyboardArr {
            if (value.NodeSerial != index || value.EndTime == 0)
                continue
            keyName := value.keyName
            IsMouse := keyName == "LButton" || keyName == "RButton" || keyName == "MButton"
            IsKeyboard := !IsMouse

            if (IsMouse && ToolCheckInfo.RecordMouseValue) {
                isRelative := ToolCheckInfo.RecordMouseRelativeValue
                posX := isRelative ? value.StartPos[1] - ToolCheckInfo.RecordLastMousePos[1] : value.StartPos[1]
                posY := isRelative ? value.StartPos[2] - ToolCheckInfo.RecordLastMousePos[2] : value.StartPos[2]
                symbol := isRelative ? "_100_1" : ""
                macro .= "移动_" posX "_" posY symbol ","
                macro .= "按键_" value.keyName "_" value.Span() ","

                if (value.StartPos[1] != value.EndPos[1] || value.StartPos[2] != value.EndPos[2]) {
                    posX := isRelative ? value.EndPos[1] - value.StartPos[1] : value.EndPos[1]
                    posY := isRelative ? value.EndPos[2] - value.StartPos[2] : value.EndPos[2]
                    speed := Max(100 - Integer(value.Span() * 0.02), 90)
                    symbol := isRelative ? "_" speed "_1" : "_" speed
                    macro .= "移动_" posX "_" posY symbol ","
                }

                ToolCheckInfo.RecordLastMousePos[1] := value.EndPos[1]
                ToolCheckInfo.RecordLastMousePos[2] := value.EndPos[2]
            }

            if (IsKeyboard && ToolCheckInfo.RecordKeyboardValue) {
                macro .= "按键_" value.keyName "_" value.Span() ","
            }
        }
    }
    macro := Trim(macro, ",")
    macro := GetRecordMacroEditStr(macro)
    macro := Trim(macro, ",")
    macro := Trim(macro, "`n")
    ToolCheckInfo.ToolTextCtrl.Value := macro
    if (MySoftData.MacroEditGui != "") {
        MySoftData.MacroEditCon.Value .= macro
    }
    A_Clipboard := macro
}
