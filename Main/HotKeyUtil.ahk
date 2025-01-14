;绑定热键
BindKey() {
    BindPauseHotkey()
    BindShortcut(MySoftData.KillMacroHotkey, OnKillAllMacro)
    BindShortcut(ToolCheckInfo.ToolCheckHotKey, OnToolCheckHotkey)
    BindTabHotKey()
}

BindPauseHotkey() {
    global MySoftData
    if (MySoftData.PauseHotkey != "") {
        key := "$*" MySoftData.PauseHotkey
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
        key := "$*" triggerInfo
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
    }
    else if (tableSymbol == "Replace") {
        actionDown := GetClosureAction(tableItem, macro, index, OnReplaceDownKey)
        actionUp := GetClosureAction(tableItem, macro, index, OnReplaceUpKey)
    }
    else if (tableSymbol == "Soft") {
        actionDown := GetClosureAction(tableItem, macro, index, OnSoftTriggerKey)
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
    tableItem.SearchActionArr[index] := Map()
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

        if(!isFirst && isContinue){
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
        IsMouseMove := StrCompare(paramArr[1], "MouseMove", false) == 0
        IsSearch := StrCompare(SubStr(paramArr[1], 1, 6), "Search", false) == 0
        IsPressKey := StrCompare(paramArr[1], "PressKey", false) == 0
        IsInterval := StrCompare(paramArr[1], "Interval", false) == 0
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
    }
}

OnSearch(tableItem, cmd, index) {
    splitIndex := RegExMatch(cmd, "(\(.*\))", &match)
    if (splitIndex == 0) {
        searchCmdArr := StrSplit(cmd, "_")
    }
    else {
        searchMacroStr := SubStr(cmd, 1, splitIndex - 1)
        searchCmdArr := StrSplit(searchMacroStr, "_")
    }
    searchCount := Integer(searchCmdArr[8])
    searchInterval := Integer(searchCmdArr[9])

    tableItem.SearchActionArr[index].Set(searchCmdArr[2], [])

    OnSearchOnce(tableItem, cmd, index, searchCount == 1)
    loop searchCount {
        if (A_Index == 1)
            continue

        action := OnSearchOnce.Bind(tableItem, cmd, index, A_Index == searchCount)
        leftTime := GetFloatTime(searchInterval * (A_Index - 1), MySoftData.PreIntervalFloat)
        tableItem.SearchActionArr[index][searchCmdArr[2]].Push(action)
        SetTimer action, -leftTime
    }
}

OnSearchOnce(tableItem, cmd, index, isFinally) {
    macroArr := SplitCommand(cmd)
    searchCmdArr := StrSplit(macroArr[1], "_")

    X1 := Integer(searchCmdArr[3])
    Y1 := Integer(searchCmdArr[4])
    X2 := Integer(searchCmdArr[5])
    Y2 := Integer(searchCmdArr[6])

    CoordMode("Pixel", "Screen")
    if (searchCmdArr[1] == "SearchImage") {
        SearchInfo := Format("*{} *w0 *h0 {}", Integer(MySoftData.ImageSearchBlur), searchCmdArr[2])
        found := ImageSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, SearchInfo)
    }
    else if (searchCmdArr[1] == "SearchColor") {
        found := PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, searchCmdArr[2], Integer(MySoftData.ImageSearchBlur
        ))
    }

    if (found || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.SearchActionArr[index].Has(searchCmdArr[2])) {
            ActionArr := tableItem.SearchActionArr[index].Get(searchCmdArr[2])
            loop ActionArr.Length {
                action := ActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.SearchActionArr[index].Delete(searchCmdArr[2])
        }
    }

    if (found) {
        ;自动移动鼠标
        if (Integer(searchCmdArr[7])) {
            Pos := [OutputVarX, OutputVarY]
            if (searchCmdArr[1] == "SearchImage") {
                imageSize := GetImageSize(searchCmdArr[2])
                Pos := [OutputVarX + imageSize[1] / 2, OutputVarY + imageSize[2] / 2]
            }

            CoordMode("Mouse", "Screen")
            MouseMove(Pos[1], Pos[2])
        }

        if (macroArr[2] == "")
            return
        OnTriggerMacroOnce(tableItem, macroArr[2], index)
    }

    if (isFinally && !found) {
        if (macroArr[3] == "")
            return
        OnTriggerMacroOnce(tableItem, macroArr[3], index)
    }
}

OnMouseMove(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    count := Integer(paramArr[4])
    interval := Integer(paramArr[5])
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
    Speed := 100 - Integer(paramArr[6])
    isRelative := Integer(paramArr[7])
    isOffset := Integer(paramArr[8])

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
    Sleep(interval)
}

OnPressKey(tableItem, cmd, index) {
    paramArr := SplitKeyCommand(cmd)
    isJoyKey := SubStr(paramArr[2], 1, 3) == "Joy"
    isJoyAxis := StrCompare(SubStr(paramArr[2], 1, 7), "JoyAxis", false) == 0
    action := tableItem.ModeArr[index] == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action := isJoyKey ? SendJoyBtnClick : action
    action := isJoyAxis ? SendJoyAxisClick : action

    holdTime := Integer(paramArr[3])
    floatHoldTime := GetFloatTime(holdTime, MySoftData.HoldFloat)
    count := paramArr.Length > 2 ? Integer(paramArr[4]) : 1

    action(paramArr[2], floatHoldTime)

    loop count {
        if (A_Index == 1)
            continue

        floatHoldTime := GetFloatTime(holdTime, MySoftData.HoldFloat)
        tempAction := action.Bind(paramArr[2], floatHoldTime)
        leftTime := GetFloatTime((Integer(paramArr[5])) * (A_Index - 1), MySoftData.PreIntervalFloat)
        tableItem.CmdActionArr[index].Push(tempAction)
        SetTimer tempAction, -leftTime
    }
}

;按键替换
OnReplaceDownKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 1)
        }
        else {
            SendNormalKey(assistKey, 1)
        }
    }

}

OnReplaceUpKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 0)
        }
        else {
            SendNormalKey(assistKey, 0)
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

OnTableEditMacro(tableItem, index) {
    macro := tableItem.InfoConArr[index].Value
    MyMacroGui.SureBtnAction := (sureMacro) => tableItem.InfoConArr[index].Value := sureMacro
    MyMacroGui.ShowGui(macro, true)
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

    for key, value in MySoftData.HoldKeyMap {
        if (value == "Game") {
            SendGameModeKey(key, 0)
        }
        else if (value == "Normal") {
            SendNormalKey(key, 0)
        }
        else if (value == "Joy") {
            SendJoyBtnKey(key, 0)
        }
        else if (value == "JoyAxis") {
            SendJoyAxisKey(key, 0)
        }
        else if (value == "GameMouse") {
            SendGameMouseKey(key, 0)
        }
    }

    KillTableItemMacro()
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ResetTimer()
}

OnShowWinChanged(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsExecuteShow := !MySoftData.IsExecuteShow
    IniWrite(MySoftData.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
}

;按键模拟
SendGameModeKeyClick(key, holdTime := 30) {
    SendGameModeKey(key, 1)
    SetTimer(() => SendGameModeKey(key, 0), -holdTime)
}

SendGameModeKey(Key, state) {
    VK := GetKeyVK(Key)
    SC := GetKeySC(Key)

    if (VK == 1 || VK == 2 || VK == 4) {   ; 鼠标左键、右键、中键
        SendGameMouseKey(key, state)
        return
    }

    ; 检测是否为扩展键
    isExtendedKey := false
    extendedArr := [0x25, 0x26, 0x27, 0x28]    ; 左、上、右、下箭头
    for index, value in extendedArr {
        if (VK == value) {
            isExtendedKey := true
            break
        }
    }

    if (state == 1) {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", isExtendedKey ? 0x1 : 0, "UPtr", 0)
        MySoftData.HoldKeyMap[key] := "Game"
    }
    else {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0)
        if (MySoftData.HoldKeyMap.Has(key)) {
            MySoftData.HoldKeyMap.Delete(key)
        }
    }
}

SendGameMouseKey(key, state) {
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
        MySoftData.HoldKeyMap[key] := "GameMouse"
    }
    else {
        DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        if (MySoftData.HoldKeyMap.Has(key)) {
            MySoftData.HoldKeyMap.Delete(key)
        }
    }
}

SendNormalKeyClick(Key, holdTime := 30) {
    SendNormalKey(Key, 1)
    SetTimer(() => SendNormalKey(Key, 0), -holdTime)
}

SendNormalKey(Key, state) {
    if (state == 1) {
        keySymbol := "{" Key " down}"
    }
    else {
        keySymbol := "{" Key " up}"
    }

    Send(keySymbol)

    if (state == 1) {
        MySoftData.HoldKeyMap[Key] := "Normal"
    }
    else {
        if (MySoftData.HoldKeyMap.Has(key)) {
            MySoftData.HoldKeyMap.Delete(Key)
        }
    }
}

SendJoyBtnClick(key, holdTime := 30) {
    SendJoyBtnKey(key, 1)
    SetTimer(() => SendJoyBtnKey(key, 0), -holdTime)
}

SendJoyBtnKey(key, state) {
    joyIndex := SubStr(key, 4)
    MyvJoy.SetBtn(state, joyIndex)

    if (state == 1) {
        MySoftData.HoldKeyMap[key] := "Joy"
    }
    else {
        if (MySoftData.HoldKeyMap.Has(key)) {
            MySoftData.HoldKeyMap.Delete(key)
        }
    }
}

SendJoyAxisClick(key, holdTime := 30) {
    SendJoyAxisKey(key, 1)
    SetTimer(() => SendJoyAxisKey(key, 0), -holdTime)
}

SendJoyAxisKey(key, state) {
    percent := 50
    if (state == 1) {
        percent := MyvJoy.JoyAxisMap.Get(key)
    }
    value := percent * 327.68
    index := Integer(SubStr(key, 8, StrLen(key) - 10))
    MyvJoy.SetAxisByIndex(value, index)

    if (state == 1) {
        MySoftData.HoldKeyMap[key] := "JoyAxis"
    }
    else {
        if (MySoftData.HoldKeyMap.Has(key)) {
            MySoftData.HoldKeyMap.Delete(key)
        }

    }
}
