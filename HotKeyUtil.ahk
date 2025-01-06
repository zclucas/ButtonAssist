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

            key := "$*" tableItem.TKArr[index]
            actionArr := GetMacroAction(tableIndex, index)
            isJoyKey := SubStr(tableItem.TKArr[index], 1, 3) == "Joy"
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
    info := tableItem.InfoArr[index]
    tableSymbol := GetTableSymbol(tableIndex)
    actionDown := ""
    actionUp := ""

    if (tableSymbol == "Normal" || tableSymbol == "Normal2" || tableSymbol == "String") {
        actionDown := GetClosureAction(tableItem, info, index, OnTriggerMacroKeyAndInit)
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
OnTriggerMacroKeyAndInit(tableItem, info, index) {
    tableItem.KeyActionArr[index] := []
    tableItem.KilledArr[index] := false
    tableItem.ActionCount[index] := 0
    tableItem.ImageActionArr[index] := Map()

    loop {
        if (tableItem.KilledArr[index])
            break

        if (tableItem.LoopCountArr[index] != -1 && tableItem.ActionCount[index] >= tableItem.LoopCountArr[index])
            break

        OnTriggerMacroKey(tableItem, info, index)
        tableItem.ActionCount[index]++
    }

}

OnTriggerMacroKey(tableItem, info, index) {
    global MySoftData
    infos := SplitCommand(info)

    loop infos.Length {
        if (tableItem.KilledArr[index])
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
            OnPressKeyboardCommand(tableItem, infos[A_Index], index)
        }

        if (infos.Length > A_Index) {
            interval := Integer(infos[A_Index + 1])
            interval += GetRandom(MySoftData.IntervalFloat)
            Sleep(interval)
            A_Index++
        }
    }
}

OnImageSearch(tableItem, macro, index) {
    splitIndex := RegExMatch(macro, "(\(.*\))", &match)
    if (splitIndex == 0){
        searchMacroArr := StrSplit(macro, "_")
        findAfterMacro := ""
    }
    else{
        searchMacroStr := SubStr(macro, 1, splitIndex - 1)
        searchMacroArr := StrSplit(searchMacroStr, "_")
        findAfterMacro := SubStr(match[1], 2, StrLen(match[1]) - 2)
    }
    searchCount := Integer(searchMacroArr[7])
    searchInterval := Integer(searchMacroArr[8])

    tableItem.ImageActionArr[index].Set(searchMacroArr[2], [])

    OnImageSearchOnce(tableItem, macro, index)

    loop searchCount {
        if (A_Index == 1)
            continue

        if (!tableItem.ImageActionArr[index].Has(searchMacroArr[2]))
            break

        if (tableItem.KilledArr[index])
            break

        action := OnImageSearchOnce.Bind(tableItem, macro, index)
        floatLeftTime := GetRandom(MySoftData.ClickFloat) + (searchInterval * (A_Index - 1))
        tableItem.ImageActionArr[index][searchMacroArr[2]].Push(action)
        SetTimer action, -floatLeftTime
    }
}

OnImageSearchOnce(tableItem, macro, index) {
    splitIndex := RegExMatch(macro, "(\(.*\))", &match)
    if (splitIndex == 0){
        searchMacroArr := StrSplit(macro, "_")
        findAfterMacro := ""
    }
    else{
        searchMacroStr := SubStr(macro, 1, splitIndex - 1)
        searchMacroArr := StrSplit(searchMacroStr, "_")
        findAfterMacro := SubStr(match[1], 2, StrLen(match[1]) - 2)
    }

    if (tableItem.KilledArr[index])
        return

    if (!tableItem.ImageActionArr[index].Has(searchMacroArr[2]))
        return

    ImageInfo := Format("*{} *w0 *h0 {}", Integer(MySoftData.ImageSearchBlur), searchMacroArr[2])
    X1 := Integer(searchMacroArr[3])
    Y1 := Integer(searchMacroArr[4])
    X2 := Integer(searchMacroArr[5])
    Y2 := Integer(searchMacroArr[6])

    CoordMode("Pixel", "Screen")
    result := ImageSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, ImageInfo)

    if (result) {
        if (tableItem.ImageActionArr[index].Has(searchMacroArr[2])) {
            ActionArr := tableItem.ImageActionArr[index].Get(searchMacroArr[2])
            loop ActionArr.Length {
                action := ActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.ImageActionArr[index].Delete(searchMacroArr[2])
        }

        imageSize := GetImageSize(searchMacroArr[2])
        Pos := [OutputVarX + imageSize[1] / 2, OutputVarY + imageSize[2] / 2]
        CoordMode("Mouse", "Screen")
        MouseMove(Pos[1], Pos[2])
        if (findAfterMacro == "")
            return

        OnTriggerMacroKey(tableItem, findAfterMacro, index)
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
    loop count {
        if (A_Index == 1)
            continue

        floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
        tempAction := action.Bind(key, floatHoldTime)
        floatLeftTime := GetRandom(MySoftData.ClickFloat) + (Integer(strArr[4]) * (A_Index - 1))
        tableItem.KeyActionArr[index].Push(tempAction)
        SetTimer tempAction, -floatLeftTime
    }

}

OnPressKeyboardCommand(tableItem, macro, index) {
    strArr := SplitKeyCommand(macro)
    key := strArr[1]
    mode := tableItem.ModeArr[index]
    holdTime := Integer(strArr[2])
    floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
    action := mode == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action(key, floatHoldTime)

    count := strArr.Length > 2 ? Integer(strArr[3]) : 1
    loop count {
        if (A_Index == 1)
            continue

        floatHoldTime := holdTime + GetRandom(MySoftData.HoldFloat)
        tempAction := action.Bind(key, floatHoldTime)
        floatLeftTime := GetRandom(MySoftData.ClickFloat) + (Integer(strArr[4]) * (A_Index - 1))
        tableItem.KeyActionArr[index].Push(tempAction)
        SetTimer tempAction, -floatLeftTime
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
    index := Integer(SubStr(key, 7, StrLen(key) - 10))
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
