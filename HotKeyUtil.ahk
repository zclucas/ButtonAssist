;绑定热键
BindPauseHotkey() {
    global ScriptInfo
    if (ScriptInfo.PauseHotkey != "") {
        key := "$*" ScriptInfo.PauseHotkey
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
    loop TabNameArr.Length {
        tableItem := TableInfo[A_Index]
        tableIndex := A_Index
        for index, value in tableItem.ModeArr {
            if (tableItem.TKArr[index] == "" || (Integer)(tableItem.ForbidArr[index]))
                continue
    
            key := "$*" tableItem.TKArr[index]
            info := tableItem.InfoArr[index]
            curProcessName := tableItem.ProcessNameArr.Length >= index ? tableItem.ProcessNameArr[index] : ""

            if (curProcessName != "") {
                processInfo := Format("ahk_exe {}", curProcessName)
                HotIfWinActive(processInfo)
            }

            tableSymbol := GetTableSymbol(tableIndex)
            if (tableSymbol == "Normal" || tableSymbol == "Special") {
                action := GetClosureAction(tableItem, info, index, OnTriggerMacroKey)
                action2 := GetClosureAction(tableItem, info, index, OnLoosenMacroKey)
                Hotkey(key, action)
                Hotkey(key " up", action2)
            }
            else if (tableSymbol == "Replace") {
                action1 := GetClosureAction(tableItem, info, index, OnReplaceDownKey)
                action2 := GetClosureAction(tableItem, info, index, OnReplaceUpKey)
                Hotkey(key, action1)
                Hotkey(key " up", action2)
            }
            else if (tableSymbol == "Soft") {
                action := GetClosureAction(tableItem, info, index, OnSoftTriggerKey)
                Hotkey(key, action)
            }

            if (curProcessName != "") {
                HotIfWinActive
            }
        }
    }
}

GetClosureAction(tableItem, info, index, func){     ;获取闭包函数
    funcObj := func.Bind(tableItem, info, index)
    return (*) => funcObj()
}

;按键宏命令
OnTriggerMacroKey(tableItem, info, index) {
    global ScriptInfo
    tableItem.LoosenState[index] := false
    infos := SplitCommand(info)
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        if (ScriptInfo.IsPause || tableItem.LoosenState[index])
            break

        strArr := StrSplit(infos[A_Index], "_")
        curKey := strArr[1]

        IsMouseMove := StrCompare(curKey, "MouseMove", false) == 0
        IsImageSearch := StrCompare(curKey, "ImageSearch", false) == 0
        if (IsMouseMove) {
            OnMouseMove(strArr)
        }
        else if (IsImageSearch) {
            OnImageSearch(tableItem, infos[A_Index], index)
        }
        else {
            OnPressKeyCommand(tableItem, strArr, index)
        }

        if (infos.Length > A_Index) {
            interval := Integer(infos[A_Index + 1])
            interval += GetRandom(ScriptInfo.IntervalFloat)
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

    ImageFile := Format("*{} *w0 *h0 {}", Integer(ScriptInfo.ImageSearchBlur), imageInfoArr[2])
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

OnPressKeyCommand(tableItem, strArr, index) {
    key := strArr[1]
    mode := tableItem.ModeArr[index]
    holdTime := Integer(strArr[2])
    floatHoldTime := holdTime + GetRandom(ScriptInfo.HoldFloat)
    action := mode == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action(key, floatHoldTime)

    count := strArr.Length > 2 ? Integer(strArr[3]) : 1
    if (count > 1) {
        clickInterval := Integer(strArr[4])
        loop count {
            if (A_Index == 1)
                continue

            floatHoldTime := holdTime + GetRandom(ScriptInfo.HoldFloat)
            tempAction := OnContinuousPressKey.Bind(action, key, floatHoldTime, tableItem, index)

            floatLeftTime := GetRandom(ScriptInfo.ClickFloat) + (clickInterval * (A_Index - 1))
            tableItem.TimerDoubleArr[index].Push(tempAction)
            SetTimer tempAction, -floatLeftTime
        }
    }
}

OnContinuousPressKey(action, key, time, tableItem, index) {
    if (tableItem.LoosenState[index] || ScriptInfo.IsPause) {
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
MenuReload(*) {
    SaveWinPos()
    Reload()
}

ResetWinPosAndRefreshGui(*) {
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    ScriptInfo.IsSavedWinPos := false
    RefreshGui()
}
OnPauseHotkey(*) {
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsPause := !ScriptInfo.IsPause
    ScriptInfo.PauseToggleCtrl.Value := ScriptInfo.IsPause

    Suspend(ScriptInfo.IsPause)
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ResetTimer()
}

OnShowWinChanged(*) {
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsExecuteShow := !ScriptInfo.IsExecuteShow
    IniWrite(ScriptInfo.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
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
    }
    else {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0)
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
    }
    else {
        DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
    }
}

SendNormalKeyClick(Key, holdTime := 30) {

    keyDown := "{" Key " down}"
    keyUp := "{" Key " up}"
    Send(keyDown)
    SetTimer(() => Send(keyUp), -holdTime)
}

SendNormalKey(Key, state) {
    if (state == 1) {
        keySymbol := "{" Key " down}"
    }
    else {
        keySymbol := "{" Key " up}"
    }

    Send(keySymbol)
}
