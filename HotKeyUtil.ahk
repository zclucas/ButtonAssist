BindHotKey() {
    tableIndex := 0
    loop TabNameArr.Length {
        tableItem := GetTableItem(A_Index)
        tableIndex := A_Index
        for index, value in tableItem.TKArr {
            isForbid := (Integer)(tableItem.ForbidArr[index])
            curProcessName := ""
            if (tableItem.ProcessNameArr.Length >= index) {
                curProcessName := tableItem.ProcessNameArr[index]
            }

            if (tableItem.TKArr[index] != "" && !isForbid) {
                key := "$" tableItem.TKArr[index]
                info := tableItem.InfoArr[index]
                mode := tableItem.ModeArr[index]

                if (curProcessName != "") {
                    processInfo := Format("ahk_exe {}", curProcessName)
                    HotIfWinActive(processInfo)
                }

                tableSymbol := GetTableSymbol(tableIndex)
                if (tableSymbol == "Normal" || tableSymbol == "Special") {
                    action := GetHotKeyAction2(tableItem, info, mode, index, OnNormalTriggerKey)
                    action2 := GetHotKeyAction2(tableItem, info, mode, index, OnNormalUpKey)
                    Hotkey(key, action)
                    Hotkey(key " up", action2)
                }
                else if (tableSymbol == "Replace") {
                    action1 := GetHotKeyAction(key, info, mode, OnReplaceDownKey)
                    action2 := GetHotKeyAction(key " up", info, mode, OnReplaceUpKey)
                    Hotkey(key, action1)
                    Hotkey(key " up", action2)
                }
                else if (tableSymbol == "Soft") {
                    action := GetHotKeyAction(key, info, mode, OnSoftTriggerKey)
                    Hotkey(key, action)
                }

                if (curProcessName != "") {
                    HotIfWinActive
                }
            }

        }
    }
}

GetHotKeyAction(key, info, mode, func) {
    funcObj := func.Bind(key, info, mode)
    return (*) => funcObj()
}

GetHotKeyAction2(tableItem, info, mode, index, func) {
    funcObj := func.Bind(tableItem, info, mode, index)
    return (*) => funcObj()
}

OnSoftTriggerKey(key, info, mode) {
    run info
}

BindPauseHotkey() {
    global ScriptInfo
    if (ScriptInfo.PauseHotkey != "") {
        key := "$" ScriptInfo.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

BindToolCheckHotkey() {
    global ToolCheckInfo
    if (ToolCheckInfo.ToolCheckHotKey != "") {
        key := "$" ToolCheckInfo.ToolCheckHotKey
        Hotkey(key, OnToolCheckHotkey)
    }
}


SendGameModeKey(Key, holdTime := 30) {
    VK := GetKeyVK(Key)
    SC := GetKeySC(Key)

    if (VK == 1 || VK == 2 || VK == 4){   ; 鼠标左键、右键、中键
        SendGameMouseClick(key, holdTime)
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

    ; 按下键
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", isExtendedKey ? 0x1 : 0, "UPtr", 0)

    ; 设置定时器模拟释放
    SetTimer(() =>DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0), -holdTime)
}

SendGameMouseClick(Key, holdTime := 30) {
    ; 鼠标按下和松开的标志
    if (StrCompare(Key, "LButton", false) == 0){
        mouseDown := 0x0002
        mouseUp := 0x0004
    }
    else if (StrCompare(Key, "RButton", false) == 0){
        mouseDown := 0x0008
        mouseUp := 0x0010
    }
    else if (StrCompare(Key, "MButton", false) == 0){
        mouseDown := 0x0020
        mouseUp := 0x0040
    }

    DllCall("mouse_event", "UInt", mouseDown, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
    SetTimer(() =>DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0), -holdTime)
}

SendNormalKey(Key, holdTime := 30) {

    keyDown := "{" Key " down}"
    keyUp := "{" Key " up}"
    Send(keyDown)
    SetTimer(() => Send(keyUp), -holdTime)
}

SendGameModeUpKey(Key) {
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 2, "UPtr", 0)
}

SendGameModeDownKey(Key) {
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 0, "UPtr", 0)
}

SendNormalDownKey(Key) {
    keyDown := "{" Key " down}"
    Send(keyDown)
}

SendNormalUpKey(Key) {
    keyUp := "{" Key " up}"
    Send(keyUp)
}

OnNormalTriggerKey(tableItem, info, mode, index) {
    global ScriptInfo
    tableItem.LoosenState[index] := false
    infos := StrSplit(info, ",")

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
            OnImageSearch(tableItem, infos[A_Index], mode, index)
        }
        else {
            oriHoldTime := Integer(strArr[2])
            holdTime := oriHoldTime + GetRandom(ScriptInfo.HoldFloat)
            action := mode == 1 ? SendGameModeKey : SendNormalKey
            action(curKey, holdTime)

            count := strArr.Length > 2 ? Integer(strArr[3]) : 1
            if (count > 1) {
                clickInterval := Integer(strArr[4])
                loop count {
                    if (A_Index == 1)
                        continue

                    tempHoldTime := oriHoldTime + GetRandom(ScriptInfo.HoldFloat)
                    tempAction := OnNormalMuchClick.Bind(action, curKey, tempHoldTime, tableItem.LoosenState, index)
                    leftTime := clickInterval * (A_Index - 1)
                    leftTime += GetRandom(ScriptInfo.ClickFloat)
                    SetTimer tempAction, -leftTime
                }
            }
        }

        if (infos.Length > A_Index) {
            interval := Integer(infos[A_Index + 1])
            interval += GetRandom(ScriptInfo.IntervalFloat)
            Sleep(interval)
            A_Index++
        }
    }

}

OnImageSearch(tableItem, info, mode, index) {
    splitIndex := RegExMatch(info, "(\(.*\))", &match)
    imageInfoStr := SubStr(info, 1, splitIndex - 1)
    imageInfoArr := StrSplit(imageInfoStr, "_")
    findAfterActionInfo := SubStr(match[1], 2, StrLen(match[1]) - 2)

    ImageFile := Format("*{} *w0 *h0 {}", Integer(ScriptInfo.ImageSearchBlur), imageInfoArr[2])
    if (imageInfoArr.Length > 3){
        X1 := Integer(imageInfoArr[3])
        Y1 := Integer(imageInfoArr[4])
        X2 := Integer(imageInfoArr[5])
        Y2 := Integer(imageInfoArr[6])
    }
    else{
        X1 := 0
        Y1 := 0
        X2 := A_ScreenWidth
        Y2 := A_ScreenHeight
    }

    CoordMode("Mouse", "Screen")
    result := ImageSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, ImageFile)

    if (result) {
        imageSize := GetImageSize(ImageFile)
        Pos := [OutputVarX + imageSize[1]/2, OutputVarY + imageSize[2]/2]
        MouseMove(Pos[1], Pos[2])
        if (findAfterActionInfo == "") 
            return

        OnNormalTriggerKey(tableItem, findAfterActionInfo, mode, index)
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

OnNormalMuchClick(action, key, time, LoosenStateArr, index) {
    if (LoosenStateArr[index])
        return

    action(key, time)
}

OnNormalUpKey(tableItem, info, mode, index) {
    isLoosenStop := tableItem.LoosenStopArr[index]
    if (isLoosenStop) {
        tableItem.LoosenState[index] := true
    }
}

OnReplaceDownKey(key, info, mode) {
    key := SubStr(key, 2)
    infos := StrSplit(info, ",")

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeDownKey(assistKey)
        }
        else {
            SendNormalDownKey(assistKey)
        }
    }

}

OnReplaceUpKey(key, info, mode) {
    key := SubStr(key, 2)
    infos := StrSplit(info, ",")

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeUpKey(assistKey)
        }
        else {
            SendNormalUpKey(assistKey)
        }
    }

}
