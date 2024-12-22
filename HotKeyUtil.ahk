BindHotKey() {
    tableIndex := 0
    loop TableItemNum {
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
                if (tableSymbol == "Normal") {
                    action := GetHotKeyAction(key, info, mode, OnNewNormalTriggerKey)
                    Hotkey(key, action)
                }
                else if (tableSymbol == "Loop") {
                    action1 := GetHotKeyAction2(key, info, mode, index, OnLoopTriggerDownKey)
                    action2 := GetHotKeyAction2(key " up", info, mode, index, OnLoopTriggerUpKey)
                    Hotkey(key, action1)
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

GetHotKeyAction2(key, info, mode, index, func) {
    funcObj := func.Bind(key, info, mode, index)
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

; 模拟按键相关函数
SendGameModeKey(Key, holdTime := 30) {

    VK := GetKeyVK(Key), SC := GetKeySC(Key)

    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 0, "UPtr", 0)
    SetTimer(() => DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 2, "UPtr", 0), -holdTime)
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

OnNewNormalTriggerKey(key, info, mode) {
    global ScriptInfo
    key := SubStr(key, 2)
    tableIndex := GetTableIndex("Normal")
    tableItem := GetTableItem(tableIndex)
    infos := StrSplit(info, ",")

    loop infos.Length {
        if (ScriptInfo.IsPause)
            break

        strArr := StrSplit(infos[A_Index], "_")
        curKey := strArr[1]

        IsMouseMove := curKey == "MouseMove"
        if (IsMouseMove) {
            SendMode("Event")
            MouseMove(Integer(strArr[2]), Integer(strArr[3]), Integer(strArr[4]), strArr[5])
        }
        else {
            clickTime := Integer(strArr[2])
            action := mode == 1 ? SendGameModeKey : SendNormalKey
            action(curKey, clickTime)

            count := strArr.Length > 2 ? Integer(strArr[3]) : 1
            if (count > 1) {
                clickInterval := Integer(strArr[4])
                loop count {
                    if (A_Index == 1)
                        continue
                    tempAction := mode == 1 ? SendGameModeKey : SendNormalKey
                    tempAction := tempAction.Bind(curKey, clickTime)
                    leftTime := clickInterval * (A_Index - 1)
                    SetTimer tempAction, -leftTime
                }
            }
        }

        if (infos.Length > A_Index) {
            Sleep(Integer(infos[A_Index + 1]))
            A_Index++
        }
    }

}

OnNormalTriggerKey(key, info, mode) {
    global ScriptInfo
    key := SubStr(key, 2)
    tableIndex := GetTableIndex("Normal")
    tableItem := GetTableItem(tableIndex)
    infos := StrSplit(info, ",")

    loop infos.Length {
        if (ScriptInfo.IsPause)
            break

        strArr := StrSplit(infos[A_Index], "_")
        curKey := strArr[1]
        leftTime := Integer(strArr[2])

        if (mode == 1) {
            HoldKey(SendGameModeDownKey, SendGameModeUpKey, ScriptInfo.NormalPeriod, leftTime, curKey)
        }
        else {
            HoldKey(SendNormalDownKey, SendNormalUpKey, ScriptInfo.NormalPeriod, leftTime, curKey)
        }

        if (infos.Length > A_Index) {
            Sleep(Integer(infos[A_Index + 1]))
            A_Index++
        }
    }
}

OnLoopTriggerDownKey(key, info, mode, index) {
    key := SubStr(key, 2)
    tableIndex := GetTableIndex("Loop")
    tableItem := GetTableItem(tableIndex)
    infos := StrSplit(info, ",")
    realKey := RemoveHotkeyPrefix(key)
    tableItem.LoopState[index] := true
    isHold := GetKeyState(realKey, "P")
    isHold2 := GetKeyState(realKey)

    while (GetKeyState(realKey, "P") && !ScriptInfo.IsPause && tableItem.LoopState[index]) {
        loop infos.Length {
            if (ScriptInfo.IsPause || !GetKeyState(realKey, "P") || !tableItem.LoopState[index])
                break

            curKey := infos[A_Index]
            looseTime := GetRandomAutoLooseTime()
            if (mode == 1) {
                SendGameModeDownKey(curKey)
                funcObj := SendGameModeUpKey.Bind(curKey)
                SetTimer funcObj, -looseTime
            }
            else {
                SendNormalDownKey(curKey)
                funcObj := SendNormalUpKey.Bind(curKey)
                SetTimer funcObj, -looseTime
            }
            if (infos.Length > A_Index) {
                Sleep(Integer(infos[A_Index + 1]))
                A_Index++
            }
        }
    }

}

OnLoopTriggerUpKey(key, info, mode, index) {
    tableIndex := GetTableIndex("Loop")
    tableItem := GetTableItem(tableIndex)
    tableItem.LoopState[index] := False
}

OnReplaceDownKey(key, info, mode) {
    key := SubStr(key, 2)
    tableIndex := GetTableIndex("Replace")
    tableItem := GetTableItem(tableIndex)
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
    tableIndex := GetTableIndex("Replace")
    tableItem := GetTableItem(tableIndex)
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
