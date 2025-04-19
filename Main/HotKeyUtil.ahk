;绑定热键
OnExitSoft(*) {
    global MyPToken, MyOcr
    Gdip_Shutdown(MyPToken)
    MyOcr := ""
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

BindScrollHotkey(key, action) {
    if (MySoftData.SB == "")
        return

    processInfo := Format("ahk_exe {}", "AutoHotkey64.exe")
    HotIfWinActive(processInfo)
    Hotkey(key, action)
    HotIfWinActive
}

BindPauseHotkey() {
    global MySoftData
    if (MySoftData.PauseHotkey != "") {
        key := "$*~" MySoftData.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

BindShortcut(triggerInfo, action) {
    if (triggerInfo == "")
        return

    isString := SubStr(triggerInfo, 1, 1) == ":"

    if (isString) {
        Hotstring(triggerInfo, action)
    }
    else {
        key := "$*~" triggerInfo
        Hotkey(key, action)
    }
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

GetMacroAction(tableIndex, index) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[index]
    tableSymbol := GetTableSymbol(tableIndex)
    actionDown := ""
    actionUp := ""

    if (tableSymbol == "Normal" || tableSymbol == "String") {
        actionDown := GetClosureAction(tableItem, macro, index, OnTriggerMacroKeyAndInit)
        actionUp := GetClosureAction(tableItem, macro, index, OnStopMacro)
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

GetClosureAction(tableItem, macro, index, func) {     ;获取闭包函数
    funcObj := func.Bind(tableItem, macro, index)
    return (*) => funcObj()
}

;按键宏命令
OnTriggerMacroKeyAndInit(tableItem, macro, index) {
    tableItem.CmdActionArr[index] := []
    tableItem.KilledArr[index] := false
    tableItem.ActionCount[index] := 0
    tableItem.ActionArr[index] := Map()
    isContinue := MySoftData.ContinueKeyMap.Has(tableItem.TKArr[index]) && tableItem.LoopCountArr[index] == 1
    isLoop := tableItem.LoopCountArr[index] == -1

    loop {
        isOver := tableItem.ActionCount[index] >= tableItem.LoopCountArr[index]
        isFirst := tableItem.ActionCount[index] == 0
        isSecond := tableItem.ActionCount[index] == 1

        if (tableItem.KilledArr[index])
            break

        if (!isLoop && !isContinue && isOver)
            break

        if (!isFirst && isContinue) {
            key := MySoftData.ContinueKeyMap[tableItem.TKArr[index]]
            interval := isSecond ? MySoftData.ContinueSecondIntervale : MySoftData.ContinueIntervale
            Sleep(interval)

            if (!GetKeyState(key, "P")) {
                break
            }
        }

        OnTriggerMacroOnce(tableItem, macro, index)
        tableItem.ActionCount[index]++
    }

}

OnTriggerMacroOnce(tableItem, macro, index) {
    global MySoftData
    cmdArr := SplitMacro(macro)

    loop cmdArr.Length {
        if (tableItem.KilledArr[index])
            break

        paramArr := StrSplit(cmdArr[A_Index], "_")
        IsMouseMove := StrCompare(paramArr[1], "移动", false) == 0
        IsSearch := StrCompare(SubStr(paramArr[1], 1, 2), "搜索", false) == 0
        IsPressKey := StrCompare(paramArr[1], "按键", false) == 0
        IsInterval := StrCompare(paramArr[1], "间隔", false) == 0
        IsFile := StrCompare(paramArr[1], "文件", false) == 0
        IsCompare := StrCompare(paramArr[1], "比较", false) == 0
        IsCoord := StrCompare(paramArr[1], "坐标", false) == 0
        ISInput := StrCompare(paramArr[1], "输入", false) == 0
        if (IsMouseMove) {
            OnMouseMove(tableItem, cmdArr[A_Index], index)
        }
        else if (IsSearch) {
            OnSearch(tableItem, cmdArr[A_Index], index)
        }
        else if (IsPressKey) {
            OnPressKey(tableItem, cmdArr[A_Index], index)
        }
        else if (IsInterval) {
            OnInterval(tableItem, cmdArr[A_Index], index)
        }
        else if (IsFile) {
            OnRunFile(tableItem, cmdArr[A_Index], index)
        }
        else if (IsCompare) {
            OnCompare(tableItem, cmdArr[A_Index], index)
        }
        else if (IsCoord) {
            OnCoord(tableItem, cmdArr[A_Index], index)
        }
        else if (ISInput) {
            OnInput(tableItem, cmdArr[A_Index], index)
        }
    }
}

OnSearch(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    saveStr := IniRead(SearchFile, IniSection, paramArr[2], "")
    searchData := JSON.parse(saveStr, , false)
    searchCount := Integer(searchData.SearchCount)
    searchInterval := Integer(searchData.SearchInterval)

    tableItem.ActionArr[index].Set(searchData.SerialStr, [])

    OnSearchOnce(tableItem, searchData, index, searchCount == 1)
    loop searchCount {
        if (A_Index == 1)
            continue

        if (!tableItem.ActionArr[index].Has(searchData.SerialStr)) ;第一次搜索成功就退出
            break

        action := OnSearchOnce.Bind(tableItem, cmd, index, A_Index == searchCount)
        leftTime := GetFloatTime(searchInterval * (A_Index - 1), MySoftData.PreIntervalFloat)
        tableItem.ActionArr[index][searchData.SerialStr].Push(action)
        SetTimer action, -leftTime
    }
}

OnSearchOnce(tableItem, searchData, index, isFinally) {
    X1 := Integer(searchData.StartPosX)
    Y1 := Integer(searchData.StartPosY)
    X2 := Integer(searchData.EndPosX)
    Y2 := Integer(searchData.EndPosY)

    CoordMode("Pixel", "Screen")
    if (searchData.SearchType == 1) {
        SearchInfo := Format("*{} *w0 *h0 {}", Integer(MySoftData.ImageSearchBlur), searchData.SearchImagePath)
        found := ImageSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, SearchInfo)
    }
    else if (searchData.SearchType == 2) {
        color := "0X" searchData.SearchColor
        found := PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, color, Integer(MySoftData.ImageSearchBlur
        ))
    }
    else if (searchData.SearchType == 3) {
        text := searchData.SearchText
        found := CheckScreenContainText(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, text)
    }

    if (found || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.ActionArr[index].Has(searchData.SerialStr)) {
            ActionArr := tableItem.ActionArr[index].Get(searchData.SerialStr)
            loop ActionArr.Length {
                action := ActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.ActionArr[index].Delete(searchData.SerialStr)
        }
    }

    if (found) {
        ;自动移动鼠标
        if (Integer(searchData.AutoMove)) {
            Pos := [OutputVarX, OutputVarY]
            if (searchData.SearchType == 1) {
                imageSize := GetImageSize(searchData.SearchImagePath)
                Pos := [OutputVarX + imageSize[1] / 2, OutputVarY + imageSize[2] / 2]
            }

            CoordMode("Mouse", "Screen")
            MouseMove(Pos[1], Pos[2])
        }

        if (searchData.TrueCommandStr == "")
            return
        OnTriggerMacroOnce(tableItem, searchData.TrueCommandStr, index)
    }

    if (isFinally && !found) {
        if (searchData.FalseCommandStr == "")
            return
        OnTriggerMacroOnce(tableItem, searchData.FalseCommandStr, index)
    }
}

OnRunFile(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    saveStr := IniRead(FileFile, IniSection, paramArr[2], "")
    fileData := JSON.parse(saveStr, , false)

    if (fileData.ProcessName != "") {
        Run(fileData.ProcessName)
        return
    }

    isMp3 := RegExMatch(fileData.FilePath, ".mp3$")
    if (isMp3 && fileData.BackPlay) {
        vbsPath := A_WorkingDir "\VBS\PlayAudio.vbs"
        playAudioCmd := Format('wscript.exe "{}" "{}"', vbsPath, fileData.FilePath)
        Run(playAudioCmd)
        return
    }

    Run(fileData.FilePath)
}

OnCompare(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    saveStr := IniRead(CompareFile, IniSection, paramArr[2], "")
    compareData := JSON.parse(saveStr, , false)

    count := compareData.SearchCount
    interval := compareData.SearchInterval
    tableItem.ActionArr[index].Set(compareData.TextFilter, [])
    isVaild := CompareCheckIfValid(compareData)
    if (!isVaild)
        return

    OnCompareOnce(tableItem, index, compareData, count == 1)
    loop count {
        if (A_Index == 1)
            continue

        if (!tableItem.ActionArr[index].Has(compareData.TextFilter)) ;第一次比较成功就退出
            break

        tempAction := OnCompareOnce.Bind(tableItem, index, compareData, A_Index == count)
        leftTime := GetFloatTime((Integer(interval) * (A_Index - 1)), MySoftData.PreIntervalFloat)
        tableItem.ActionArr[index][compareData.TextFilter].Push(tempAction)
        SetTimer tempAction, -leftTime
    }
}

OnCompareOnce(tableItem, index, compareData, isFinally) {
    X1 := compareData.StartPosX
    Y1 := compareData.StartPosY
    X2 := compareData.EndPosX
    Y2 := compareData.EndPosY
    isAutoMove := Integer(compareData.AutoMove)
    if (compareData.ExtractType == 1) {
        TextObjs := GetScreenTextObjArr(X1, Y1, X2, Y2)
        TextObjs := TextObjs == "" ? [] : TextObjs
    }
    else {
        if (!IsClipboardText())
            return
        TextObjs := []
        obj := Object()
        obj.Text := A_Clipboard
        TextObjs.Push(obj)
    }

    isOk := false
    macthTextObj := ""

    for index, value in TextObjs {
        baseVariableArr := ExtractNumbers(value.Text, compareData.TextFilter)
        if (baseVariableArr == "")
            continue
        macthTextObj := value
        isOk := CompareGetResult(compareData, baseVariableArr)
        break
    }

    if (isOk || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.ActionArr[index].Has(compareData.TextFilter)) {
            ActionArr := tableItem.ActionArr[index].Get(compareData.TextFilter)
            loop ActionArr.Length {
                action := ActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.ActionArr[index].Delete(compareData.TextFilter)
        }
    }

    if (isOk && isAutoMove && compareData.ExtractType == 1) {
        posArr := GetMatchCoord(macthTextObj, X1, Y1)
        SendMode("Event")
        CoordMode("Mouse", "Screen")
        MouseMove(posArr[1], posArr[2])
    }

    if (isOk && compareData.TrueCommandStr != "")
        OnTriggerMacroOnce(tableItem, compareData.TrueCommandStr, index)

    if (isFinally && !isOk && compareData.FalseCommandStr != "")
        OnTriggerMacroOnce(tableItem, compareData.FalseCommandStr, index)
}

OnCoord(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    saveStr := IniRead(CoordFile, IniSection, paramArr[2], "")
    coordData := JSON.parse(saveStr, , false)
    count := coordData.SearchCount
    interval := coordData.SearchInterval
    tableItem.ActionArr[index].Set(paramArr[2], [])

    OnCoordOnce(tableItem, index, coordData, count == 1)
    loop count {
        if (A_Index == 1)
            continue

        if (!tableItem.ActionArr[index].Has(paramArr[2])) ;第一次比较成功就退出
            break

        tempAction := OnCoordOnce.Bind(tableItem, index, coordData, A_Index == count)
        leftTime := GetFloatTime((Integer(interval) * (A_Index - 1)), MySoftData.PreIntervalFloat)
        tableItem.ActionArr[index][paramArr[2]].Push(tempAction)
        SetTimer tempAction, -leftTime
    }
}

OnCoordOnce(tableItem, index, coordData, isFinally) {
    X1 := Integer(coordData.StartPosX)
    Y1 := Integer(coordData.StartPosY)
    X2 := Integer(coordData.EndPosX)
    Y2 := Integer(coordData.EndPosY)

    if (coordData.ExtractType == 1) {
        TextObjs := GetScreenTextObjArr(X1, Y1, X2, Y2)
        TextObjs := TextObjs == "" ? [] : TextObjs
    }
    else {
        if (!IsClipboardText())
            return
        TextObjs := []
        obj := Object()
        obj.Text := A_Clipboard
        TextObjs.Push(obj)
    }

    isOk := false
    for index, value in TextObjs {
        baseVariableArr := ExtractNumbers(value.Text, coordData.TextFilter)
        if (baseVariableArr == "")
            continue
        CoordUpdateVariable(coordData, baseVariableArr)
        isOk := true
        break
    }

    if (isOk) {
        posArr := coordData.VariableArr
        SendMode("Event")
        CoordMode("Mouse", "Screen")
        Speed := 100 - coordData.Speed
        if (coordData.isRelative) {
            MouseMove(posArr[1], posArr[2], Speed, "R")
        }
        else
            MouseMove(posArr[1], posArr[2], Speed)

    }

    if (isOk || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.ActionArr[index].Has(coordData.SerialStr)) {
            ActionArr := tableItem.ActionArr[index].Get(coordData.SerialStr)
            loop ActionArr.Length {
                action := ActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.ActionArr[index].Delete(coordData.SerialStr)
        }
    }
}

OnInput(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    saveStr := IniRead(InputFile, IniSection, paramArr[2], "")
    inputData := JSON.parse(saveStr, , false)

    if (inputData.IsCover) {
        A_Clipboard := inputData.Text
    }

    if (inputData.InputType == 1) {
        SendText(inputData.Text)
    }
    else if (inputData.InputType == 2) {
        Send "^v"
    }
    else if (inputData.InputType == 3) {
        MyWinClip.Paste(A_Clipboard)
    }
}

OnMouseMove(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    count := paramArr.Length >= 7 ? Integer(paramArr[7]) : 1
    interval := paramArr.Length >= 8 ? Integer(paramArr[8]) : 100
    OnMouseMoveOnce(tableItem, cmd, index)

    loop count {
        if (A_Index == 1)
            continue

        tempAction := OnMouseMoveOnce.Bind(tableItem, cmd, index)
        leftTime := GetFloatTime((Integer(interval) * (A_Index - 1)), MySoftData.PreIntervalFloat)
        tableItem.CmdActionArr[index].Push(tempAction)
        SetTimer tempAction, -leftTime
    }
}

OnMouseMoveOnce(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    SendMode("Event")
    CoordMode("Mouse", "Screen")
    PosX := Integer(paramArr[2])
    PosY := Integer(paramArr[3])
    Speed := paramArr.Length >= 4 ? 100 - Integer(paramArr[4]) : 0
    isRelative := paramArr.Length >= 5 ? Integer(paramArr[5]) : 0
    isOffset := paramArr.Length >= 6 ? Integer(paramArr[6]) : 0

    if (isOffset) {
        MOUSEEVENTF_MOVE := 0x0001
        DllCall("mouse_event", "UInt", MOUSEEVENTF_MOVE, "UInt", PosX, "UInt", PosY, "UInt", 0, "UInt", 0)
    }
    else if (isRelative) {
        MouseMove(PosX, PosY, Speed, "R")
    }
    else {
        MouseMove(PosX, PosY, Speed)
    }
}

OnInterval(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    interval := Integer(paramArr[2])
    interval := GetFloatTime(interval, MySoftData.IntervalFloat)
    curTime := 0
    clip := Min(500, interval)
    while (curTime < interval) {
        if (tableItem.KilledArr[index])
            break
        Sleep(clip)
        curTime += clip
        clip := Min(500, interval - curTime)
    }
}

OnPressKey(tableItem, cmd, index) {
    paramArr := SplitKeyCommand(cmd)
    isJoyKey := SubStr(paramArr[2], 1, 3) == "Joy"
    isJoyAxis := StrCompare(SubStr(paramArr[2], 1, 7), "JoyAxis", false) == 0
    action := tableItem.ModeArr[index] == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action := isJoyKey ? SendJoyBtnClick : action
    action := isJoyAxis ? SendJoyAxisClick : action

    holdTime := Integer(paramArr[3])
    keyType := paramArr.Length >= 4 ? Integer(paramArr[4]) : 1
    floatHoldTime := GetFloatTime(holdTime, MySoftData.HoldFloat)
    count := paramArr.Length >= 5 ? Integer(paramArr[5]) : 1
    action(paramArr[2], floatHoldTime, tableItem, index, keyType)
    loop count {
        if (A_Index == 1)
            continue

        floatHoldTime := GetFloatTime(holdTime, MySoftData.HoldFloat)
        tempAction := action.Bind(paramArr[2], floatHoldTime, tableItem, index, keyType)
        leftTime := GetFloatTime((Integer(paramArr[6])) * (A_Index - 1), MySoftData.PreIntervalFloat)
        tableItem.CmdActionArr[index].Push(tempAction)
        SetTimer tempAction, -leftTime
    }
}

;松开停止
OnStopMacro(tableItem, macro, index) {
    if (tableItem.LooseStopArr.Length < index)
        return
    if (tableItem.LooseStopArr[index] == false)
        return
    KillTableItemMacro(tableItem, index)

}

;按键替换
OnReplaceDownKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 1, tableItem, index)
        }
        else {
            SendNormalKey(assistKey, 1, tableItem, index)
        }
    }

}

OnReplaceUpKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 0, tableItem, index)
        }
        else {
            SendNormalKey(assistKey, 0, tableItem, index)
        }
    }

}

;软件宏
OnSoftTriggerKey(tableItem, info, index) {
    run info
}

;按钮回调
GetTableClosureAction(action, TableItem, index) {
    funcObj := action.Bind(TableItem, index)
    return (*) => funcObj()
}

OnTableDelete(tableItem, index) {
    TableIndex := MySoftData.TabCtrl.Value
    isMacro := CheckIsMacroTable(TableIndex)
    if (tableItem.ModeArr.Length == 0) {
        return
    }
    result := MsgBox("是否删除当前配置", "提示", 1)
    if (result == "Cancel")
        return

    deleteMacro := tableItem.LoopCountArr.Length >= index ? tableItem.MacroArr[index] : ""
    ClearUselessSetting(deleteMacro)

    MySoftData.BtnAdd.Enabled := false
    tableItem.ModeArr.RemoveAt(index)
    tableItem.ForbidArr.RemoveAt(index)
    tableItem.LooseStopArr.RemoveAt(index)
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

    tableItem.ModeConArr.RemoveAt(index)
    tableItem.ForbidConArr.RemoveAt(index)
    tableItem.LooseStopConArr.RemoveAt(index)
    tableItem.TKConArr.RemoveAt(index)
    tableItem.InfoConArr.RemoveAt(index)
    tableItem.ProcessNameConArr.RemoveAt(index)
    tableItem.LoopCountConArr.RemoveAt(index)
    tableItem.RemarkConArr.RemoveAt(index)

    OnSaveSetting()
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

OnEditHotKey(*) {
    triggerKey := MySoftData.EditHotKeyCtrl.Value
    MyTriggerKeyGui.SureBtnAction := (sureTriggerKey) => MySoftData.EditHotKeyCtrl.Value := sureTriggerKey
    MyTriggerKeyGui.ShowGui(triggerKey, false)
}

OnEditHotStr(*) {
    triggerKey := MySoftData.EditHotStrCtrl.Value
    MyTriggerStrGui.SureBtnAction := (sureTriggerStr) => MySoftData.EditHotStrCtrl.Value := sureTriggerStr
    MyTriggerStrGui.ShowGui(triggerKey, false)
}

MenuReload(*) {
    SaveWinPos()
    Reload()
}

ResetWinPosAndRefreshGui(*) {
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    MySoftData.IsSavedWinPos := false
    RefreshGui()
}

OnPauseHotkey(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsPause := !MySoftData.IsPause
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    OnKillAllMacro()

    Suspend(MySoftData.IsPause)
}

OnKillAllMacro(*) {
    global MySoftData ; 访问全局变量

    loop MySoftData.TableInfo.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        KillSingleTableMacro(tableItem)
    }

    KillSingleTableMacro(MySoftData.SpecialTableItem)
}

OnChangeSrollValue(*) {
    wParam := InStr(A_ThisHotkey, "Down") ? 1 : 0
    lParam := 0
    msg := GetKeyState("Shift") ? 0x114 : 0x115
    MySoftData.SB.ScrollMsg(wParam, lParam, msg, MySoftData.MyGui.Hwnd)
    for index, value in MySoftData.GroupFixedCons {
        value.redraw()
    }
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.MouseInfoSwitch()
}

OnToolRecordMacro(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolRecord := !ToolCheckInfo.IsToolRecord
    ToolCheckInfo.ToolCheckRecordMacroCtrl.Value := ToolCheckInfo.IsToolRecord
    state := ToolCheckInfo.IsToolRecord
    StateSymbol := state ? "On" : "Off"
    loop 255 {
        key := Format("$*~vk{:X}", A_Index)
        if (ToolCheckInfo.RecordSpecialKeyMap.Has(A_Index)) {
            keyName := GetKeyName(Format("vk{:X}", A_Index))
            key := Format("$*~sc{:X}", GetKeySC(keyName))
        }

        try {
            Hotkey(key, OnRecordMacroKeyDonw, StateSymbol)
            Hotkey(key " Up", OnRecordMacroKeyUp, StateSymbol)
        }
        catch {
            continue
        }
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
    }
    else {
        node := ToolCheckInfo.RecordNodeArr[ToolCheckInfo.RecordNodeArr.Length]
        node.EndTime := GetCurMSec()

        OnFinishRecordMacro()
    }
}

OnRecordMacroKeyDonw(*) {
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
    ToolCheckInfo.ToolTextCtrl.Value := macro
    A_Clipboard := macro
}

OnChangeRecordOption(*) {
    ToolCheckInfo.RecordKeyboardValue := ToolCheckInfo.RecordKeyboardCtrl.Value
    ToolCheckInfo.RecordMouseValue := ToolCheckInfo.RecordMouseCtrl.Value
    ToolCheckInfo.RecordMouseRelativeValue := ToolCheckInfo.RecordMouseRelativeCtrl.value
}

OnToolTextFilterSelectImage(*) {
    global ToolCheckInfo
    path := FileSelect(, , "选择图片")
    result := MyOcr.ocr_from_file(path)
    ToolCheckInfo.ToolTextCtrl.Value := result
    A_Clipboard := result
}

OnClearToolText(*) {
    ToolCheckInfo.ToolTextCtrl.Value := ""
}

OnToolTextFilterScreenShot(*) {
    A_Clipboard := ""  ; 清空剪贴板
    Run("ms-screenclip:")
    SetTimer(OnToolTextCheckScreenShot, 500)  ; 每 500 毫秒检查一次剪贴板
}

OnToolTextCheckScreenShot() {
    ; 如果剪贴板中有图像
    if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
    {
        filePath := A_WorkingDir "\Images\TextFilter.png"
        if (!DirExist(A_WorkingDir "\Images")) {
            DirCreate(A_WorkingDir "\Images")
        }

        SaveClipToBitmap(filePath)
        result := MyOcr.ocr_from_file(filePath)
        ToolCheckInfo.ToolTextCtrl.Value := result
        A_Clipboard := result
        ; 停止监听
        SetTimer(, 0)
    }
}

OnShowWinChanged(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsExecuteShow := !MySoftData.IsExecuteShow
    IniWrite(MySoftData.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
}

OnBootStartChanged(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsBootStart := !MySoftData.IsBootStart
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    softPath := A_ScriptFullPath
    if (MySoftData.IsBootStart) {
        RegWrite(softPath, "REG_SZ", regPath, "ButtonAssist")
    }
    else {
        RegDelete(regPath, "ButtonAssist")
    }
}

;按键模拟
SendGameModeKeyClick(key, holdTime, tableItem, index, keyType) {
    if (keyType == 1) {
        SendGameModeKey(key, 1, tableItem, index)
        SetTimer(() => SendGameModeKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendGameModeKey(key, state, tableItem, index)
    }
}

SendGameModeKey(Key, state, tableItem, index) {
    if (Key == "逗号")
        Key := ","
    VK := GetKeyVK(Key)
    SC := GetKeySC(Key)

    if (VK == 1 || VK == 2 || VK == 4) {   ; 鼠标左键、右键、中键
        SendGameMouseKey(key, state, tableItem, index)
        return
    }

    ; 检测是否为扩展键
    isExtendedKey := false
    extendedArr := [0x25, 0x26, 0x27, 0x28, 0X2D, 0X2E, 0X23, 0X24, 0X21, 0X22]    ; 左、上、右、下箭头
    for index, value in extendedArr {
        if (VK == value) {
            isExtendedKey := true
            break
        }
    }

    if (state == 1) {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", isExtendedKey ? 0x1 : 0, "UPtr", 0)
        tableItem.HoldKeyArr[index][key] := "Game"
    }
    else {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0)
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendGameMouseKey(key, state, tableItem, index) {
    ; 鼠标按下和松开的标志
    if (StrCompare(Key, "LButton", false) == 0) {
        mouseDown := 0x0002
        mouseUp := 0x0004
    }
    else if (StrCompare(Key, "RButton", false) == 0) {
        mouseDown := 0x0008
        mouseUp := 0x0010
    }
    else if (StrCompare(Key, "MButton", false) == 0) {
        mouseDown := 0x0020
        mouseUp := 0x0040
    }

    if (state == 1) {
        DllCall("mouse_event", "UInt", mouseDown, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        tableItem.HoldKeyArr[index][key] := "GameMouse"
    }
    else {
        DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendNormalKeyClick(Key, holdTime, tableItem, index, keyType) {
    if (keyType == 1) {
        SendNormalKey(Key, 1, tableItem, index)
        SetTimer(() => SendNormalKey(Key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendNormalKey(Key, state, tableItem, index)
    }
}

SendNormalKey(Key, state, tableItem, index) {
    if (Key == "逗号")
        Key := ","
    if (MySoftData.SpecialNumKeyMap.Has(Key)) {
        if (state == 0)
            return
        keySymbol := "{Blind}{" Key " 1}"
        Send(keySymbol)
        return
    }

    if (state == 1) {
        keySymbol := "{Blind}{" Key " down}"
    }
    else {
        keySymbol := "{Blind}{" Key " up}"
    }

    Send(keySymbol)
    if (state == 1) {
        tableItem.HoldKeyArr[index][Key] := "Normal"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(Key)) {
            tableItem.HoldKeyArr[index].Delete(Key)
        }
    }
}

SendJoyBtnClick(key, holdTime, tableItem, index, keyType) {
    if (!CheckIfInstallVjoy()) {
        MsgBox("使用手柄功能前,请先安装Joy目录下的vJoy驱动!")
        return
    }
    if (keyType == 1) {
        SendJoyBtnKey(key, 1, tableItem, index)
        SetTimer(() => SendJoyBtnKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendJoyBtnKey(key, state, tableItem, index)
    }
}

SendJoyBtnKey(key, state, tableItem, index) {
    joyIndex := SubStr(key, 4)
    MyvJoy.SetBtn(state, joyIndex)

    if (state == 1) {
        tableItem.HoldKeyArr[index][key] := "Joy"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendJoyAxisClick(key, holdTime, tableItem, index, keyType) {
    if (!CheckIfInstallVjoy()) {
        MsgBox("使用手柄功能前,请先安装Joy目录下的vJoy驱动!")
        return
    }

    if (keyType == 1) {
        SendJoyAxisKey(key, 1, tableItem, index)
        SetTimer(() => SendJoyAxisKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendJoyAxisKey(key, state, tableItem, index)
    }
}

SendJoyAxisKey(key, state, tableItem, index) {
    percent := 50
    if (state == 1) {
        percent := MyvJoy.JoyAxisMap.Get(key)
    }
    value := percent * 327.68
    axisIndex := Integer(SubStr(key, 8, StrLen(key) - 10))
    MyvJoy.SetAxisByIndex(value, axisIndex)

    if (state == 1) {
        tableItem.HoldKeyArr[index][key] := "JoyAxis"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }

    }
}
