;绑定热键
BindKey() {
    BindPauseHotkey()
    BindToolCheckHotkey()
    BindTabHotKey()
}

BindPauseHotkey() {
    global MySoftData
    if (MySoftData.PauseHotkey != "") {
        key := "$*" MySoftData.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

BindToolCheckHotkey() {
    global ToolCheckInfo
    if (ToolCheckInfo.ToolCheckHotKey != "") {
        key := "$*" ToolCheckInfo.ToolCheckHotKey
        Hotkey(key, OnToolCheckHotkey)
    }
}

BindTabHotKey() {
    tableIndex := 0
    loop MySoftData.TabNameArr.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        tableIndex := A_Index
        for index, value in tableItem.ModeArr {
            if (tableItem.TKArr[index] == "" || (Integer)(tableItem.ForbidArr[index]))
                continue

            key := "$*" tableItem.TKArr[index]
            actionArr := GetMacroAction(tableIndex, index)
            isJoyKey := SubStr(tableItem.TKArr[index], 1, 3) == "Joy"
            isHotstring := CheckIsStringMacroTable(tableIndex)
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
    info := tableItem.InfoArr[index]
    tableSymbol := GetTableSymbol(tableIndex)
    actionDown := ""
    actionUp := ""

    if (tableSymbol == "Normal" || tableSymbol == "Normal2" || tableSymbol == "String") {
        actionDown := GetClosureAction(tableItem, info, index, OnTriggerMacroKey)
        actionUp := GetClosureAction(tableItem, info, index, OnLoosenMacroKey)
    }
    else if (tableSymbol == "Replace") {
        actionDown := GetClosureAction(tableItem, info, index, OnReplaceDownKey)
        actionUp := GetClosureAction(tableItem, info, index, OnReplaceUpKey)
    }
    else if (tableSymbol == "Soft") {
        actionDown := GetClosureAction(tableItem, info, index, OnSoftTriggerKey)
    }

    return [actionDown, actionUp]
}

GetClosureAction(tableItem, info, index, func) {     ;获取闭包函数
    funcObj := func.Bind(tableItem, info, index)
    return (*) => funcObj()
}

;按键宏命令
OnTriggerMacroKey(tableItem, info, index) {
    global MySoftData
    tableItem.LoosenState[index] := false
    infos := SplitCommand(info)
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        if (MySoftData.IsPause || tableItem.LoosenState[index])
            break

        strArr := StrSplit(infos[A_Index], "_")
        curKey := strArr[1]

        IsMouseMove := StrCompare(curKey, "MouseMove", false) == 0
        IsImageSearch := StrCompare(curKey, "ImageSearch", false) == 0
        IsJoyPress := StrCompare(SubStr(curKey, 1, 3), "Joy", false) == 0
        if (IsMouseMove) {
            OnMouseMove(strArr)
        }
        else if (IsImageSearch) {
            OnImageSearch(tableItem, infos[A_Index], index)
        }
        else if (IsJoyPress) {
            OnPressJoyKeyCommand(tableItem, strArr, index)
        }
        else {
            OnPressKeyCommand(tableItem, strArr, index)
        }

        if (infos.Length > A_Index) {
            interval := Integer(infos[A_Index + 1])
            interval += GetRandom(MySoftData.IntervalFloat)
            Sleep(interval)
            A_Index++
        }
    }
}

OnLoosenMacroKey(tableItem, info, index) {
    isLoosenStop := tableItem.LoosenStopArr[index]
    if (isLoosenStop) {
        tableItem.LoosenState[index] := true
    }
}

OnImageSearch(tableItem, info, index) {
    splitIndex := RegExMatch(info, "(\(.*\))", &match)
    imageInfoStr := SubStr(info, 1, splitIndex - 1)
    imageInfoArr := StrSplit(imageInfoStr, "_")
    findAfterActionInfo := SubStr(match[1], 2, StrLen(match[1]) - 2)

    ImageFile := Format("*{} *w0 *h0 {}", Integer(MySoftData.ImageSearchBlur), imageInfoArr[2])
    if (imageInfoArr.Length > 3) {
        X1 := Integer(imageInfoArr[3])
        Y1 := Integer(imageInfoArr[4])
        X2 := Integer(imageInfoArr[5])
        Y2 := Integer(imageInfoArr[6])
    }
    else {
        X1 := 0
        Y1 := 0
        X2 := A_ScreenWidth
        Y2 := A_ScreenHeight
    }

    CoordMode("Mouse", "Screen")
    result := ImageSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, ImageFile)

    if (result) {
        imageSize := GetImageSize(imageInfoArr[2])
        Pos := [OutputVarX + imageSize[1] / 2, OutputVarY + imageSize[2] / 2]
        MouseMove(Pos[1], Pos[2])
        if (findAfterActionInfo == "")
            return

        OnTriggerMacroKey(tableItem, findAfterActionInfo, index)
    }

}

OnMouseMove(strArr) {
    SendMode("Event")
    CoordMode("Mouse", "Screen")
    if (strArr.Length == 3) {
        MouseMove(Integer(strArr[2]), Integer(strArr[3]))
    }
    else if (strArr.Length == 4) {
        MouseMove(Integer(strArr[2]), Integer(strArr[3]), Integer(strArr[4]))
    }
    else {
        MouseMove(Integer(strArr[2]), Integer(strArr[3]), Integer(strArr[4]), strArr[5])
    }
}

OnPressJoyKeyCommand(tableItem, strArr, index) {
    key := strArr[1]
    isJoyAxis := StrCompare(SubStr(strArr[1], 1, 7), "JoyAxis", false) == 0
    holdTime := Integer(strArr[2])
    floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
    action := isJoyAxis ? SendJoyAxisClick : SendJoyBtnClick
    action(key, floatHoldTime)

    count := strArr.Length > 2 ? Integer(strArr[3]) : 1
    if (count > 1) {
        clickInterval := Integer(strArr[4])
        loop count {
            if (A_Index == 1)
                continue

            floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
            tempAction := OnContinuousPressKey.Bind(action, key, floatHoldTime, tableItem, index)

            floatLeftTime := GetRandom(MySoftData.ClickFloat) + (clickInterval * (A_Index - 1))
            tableItem.TimerDoubleArr[index].Push(tempAction)
            SetTimer tempAction, -floatLeftTime
        }
    }

}

OnPressKeyCommand(tableItem, strArr, index) {
    key := strArr[1]
    mode := tableItem.ModeArr[index]
    holdTime := Integer(strArr[2])
    floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
    action := mode == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action(key, floatHoldTime)

    count := strArr.Length > 2 ? Integer(strArr[3]) : 1
    if (count > 1) {
        clickInterval := Integer(strArr[4])
        loop count {
            if (A_Index == 1)
                continue

            floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
            tempAction := OnContinuousPressKey.Bind(action, key, floatHoldTime, tableItem, index)

            floatLeftTime := GetRandom(MySoftData.ClickFloat) + (clickInterval * (A_Index - 1))
            tableItem.TimerDoubleArr[index].Push(tempAction)
            SetTimer tempAction, -floatLeftTime
        }
    }
}

OnContinuousPressKey(action, key, time, tableItem, index) {
    if (tableItem.LoosenState[index] || MySoftData.IsPause) {
        timerActionArr := tableItem.TimerDoubleArr[index]
        for index, value in timerActionArr {
            SetTimer value, 0
        }
        tableItem.TimerDoubleArr[index] := []
        return
    }

    action(key, time)
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

OnTableEditTriggerKey(tableItem, index) {
    triggerKey := tableItem.TKConArr[index].Value
    MyTriggerKeyGui.sureCallback := (sureTriggerKey) => tableItem.TKConArr[index].Value := sureTriggerKey
    MyTriggerKeyGui.ShowGui(triggerKey)
}

OnTableEditTriggerStr(tableItem, index) {
    triggerStr := tableItem.TKConArr[index].Value
    MyTriggerStrGui.sureCallback := (sureTriggerStr) => tableItem.TKConArr[index].Value := sureTriggerStr
    MyTriggerStrGui.ShowGui(triggerStr)
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

    Suspend(MySoftData.IsPause)
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
        SoftData.HoldKeyMap[key] := "Game"
    }
    else {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0)
        SoftData.HoldKeyMap.Delete(key)
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
        SoftData.HoldKeyMap[key] := "Game"
    }
    else {
        DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        SoftData.HoldKeyMap.Delete(key)
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
        SoftData.HoldKeyMap[Key] := "Normal"
    }
    else {
        SoftData.HoldKeyMap.Delete(Key)
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
        SoftData.HoldKeyMap[key] := "Joy"
    }
    else {
        SoftData.HoldKeyMap.Delete(key)
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
    index := Integer(SubStr(key, 7, StrLen(key) - 10))
    MyvJoy.SetAxisByIndex(value, index)

    if (state == 1) {
        SoftData.HoldKeyMap[key] := "JoyAxis"
    }
    else {
        SoftData.HoldKeyMap.Delete(key)
    }
}
