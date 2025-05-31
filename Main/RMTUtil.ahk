#Requires AutoHotkey v2.0

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
        actionUp := GetClosureAction(tableItem, macro, index, OnTriggerKeyUp)
    }
    else if (tableSymbol == "String") {
        actionDown := GetClosureAction(tableItem, macro, index, OnTriggerMacroKeyAndInit)
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
    if (tableItem.TriggerTypeArr[itemIndex] == 1) { ;按下触发
        if (SubStr(tableItem.TKArr[itemIndex], 1, 1) != "~")
            LoosenModifyKey(tableItem.TKArr[itemIndex])
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 3) { ;松开停止
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 4) {  ;开关  todo
        if (tableItem.ToggleStateArr.Length < itemIndex)
            return
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
    else if (tableItem.TriggerTypeArr[itemIndex] == 5) {
        Sleep(tableItem.HoldTimeArr[itemIndex])

        keyCombo := LTrim(tableItem.TKArr[itemIndex], "~")
        if (AreKeysPressed(keyCombo))
            TriggerMacroHandler(tableIndex, itemIndex)
    }
}

TriggerMacroHandler(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    isSeries := tableItem.MacroTypeArr[itemIndex] == 1  ;触发串联指令
    hasWork := MyWorkPool.CheckHasWork()
    if (isSeries && hasWork) {
        workPath := MyWorkPool.Get()
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
    MyTriggerKeyGui.ShowGui(triggerKey, true)
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

    global IniFile := A_WorkingDir "\Setting\MainSettings.ini"
    global SearchFile := A_WorkingDir "\Setting\SearchFile.ini"
    global CompareFile := A_WorkingDir "\Setting\CompareFile.ini"
    global CoordFile := A_WorkingDir "\Setting\CoordFile.ini"
    global FileFile := A_WorkingDir "\Setting\FileFile.ini"
    global OutputFile := A_WorkingDir "\Setting\OutputFile.ini"
    global StopFile := A_WorkingDir "\Setting\StopFile.ini"
    global VariableFile := A_WorkingDir "\Setting\VariableFile.ini"
    global SubMacroFile := A_WorkingDir "\Setting\SubMacroFile.ini"
    global OperationFile := A_WorkingDir "\Setting\OperationFile.ini"
    global IniSection := "UserSettings"
}