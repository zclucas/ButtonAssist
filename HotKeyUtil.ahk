BindHotKey()
{
    tableIndex := 0
    Loop TableItemNum
    {
        tableItem := GetTableItem(A_Index)
        tableIndex := A_Index
        For index, value in tableItem.TKArr
        {
            isForbid := (Integer)(tableItem.ForbidArr[index])
            curProcessName := ""
            if (tableItem.ProcessNameArr.Length >= index)
            {
                curProcessName := tableItem.ProcessNameArr[index]
            }

            if (tableItem.TKArr[index] != "" && !isForbid)
            {
                key := "$" tableItem.TKArr[index]
                info := tableItem.InfoArr[index]
                mode := tableItem.ModeArr[index]

                if (curProcessName != "")
                {
                    processInfo := Format("ahk_exe {}", curProcessName) 
                    HotIfWinActive(processInfo)
                }

                if (tableIndex == 1)
                {
                    action := GetHotKeyAction(key, info, mode, OnSimpleTriggerKey)
                    Hotkey(key, action)
                }
                else if (tableIndex == 2)
                {
                    action := GetHotKeyAction(key, info, mode, OnNormalTriggerKey)
                    Hotkey(key, action)
                }
                else if (tableIndex == 3)
                {
                    action1 := GetHotKeyAction(key, info, mode, OnReplaceDownKey)
                    action2 := GetHotKeyAction(key " up", info, mode, OnReplaceDownKey)
                    Hotkey(key, action1) 
                    Hotkey(key " up", action2)
                }
                else if(tableIndex == 4)
                {
                    action := GetHotKeyAction(key, info, mode, OnSoftTriggerKey)
                    Hotkey(key, action)
                }

                if (curProcessName != "")
                {
                    HotIfWinActive
                }
            }

        }
    }
}

GetHotKeyAction(key, info, mode, func)
{
    funcObj := func.Bind(key, info, mode)
    return (*)=>funcObj()
}

OnSoftTriggerKey(key, info, mode)
{
    run info
}

BindPauseHotkey()
{
    global ScriptInfo
    if (ScriptInfo.PauseHotkey != "")
    {
        key := "$" ScriptInfo.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

BindToolCheckHotkey()
{
    global ToolCheckInfo
    if (ToolCheckInfo.ToolCheckHotKey != "")
    {
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

SendGameModeUpKey(Key)
{
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 2, "UPtr", 0)
}

SendGameModeDownKey(Key)
{
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 0, "UPtr", 0)
}

SendNormalDownKey(Key) 
{
    keyDown := "{" Key " down}"
    Send(keyDown)
}

SendNormalUpKey(Key) 
{
    keyUp := "{" Key " up}"
    Send(keyUp)
}

OnSimpleTriggerKey(key, info, mode)
{
    global ScriptInfo
    key := SubStr(key, 2)
    tableItem := GetTableItem(1)
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        if (ScriptInfo.IsPause) 
            break

        curKey := infos[A_Index]
        if (mode == 1)
        {
            SendGameModeDownKey(curKey)
            SendGameModeUpKey(curKey)
        }
        else
        {
            SendNormalDownKey(curKey)
            SendNormalUpKey(curKey)
        }
        if (infos.Length > A_Index)
        {
            Sleep(Integer(infos[A_Index + 1]))
            A_Index++
        }
    }
}

OnNormalTriggerKey(key, info, mode)
{
    global ScriptInfo
    key := SubStr(key, 2)
    tableItem := GetTableItem(2)
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        if (ScriptInfo.IsPause) 
            break

        strs := StrSplit(infos[A_Index], "_")
        curKey := strs[1]
        leftTime := Integer(strs[2])

        if (mode == 1)
        {
            HoldKey(SendGameModeDownKey, SendGameModeUpKey, ScriptInfo.NormalPeriod, leftTime, curKey)
        }
        else
        {
            HoldKey(SendNormalDownKey, SendNormalUpKey, ScriptInfo.NormalPeriod, leftTime, curKey)
        }

        if (infos.Length > A_Index)
        {
            Sleep(Integer(infos[A_Index + 1]))
            A_Index++
        }
    }
}

OnReplaceDownKey(key, info, mode)
{
    key := SubStr(key, 2)
    tableItem := GetTableItem(3)
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        assistKey := infos[A_Index]
        if (mode == 1)
        {
            SendGameModeDownKey(assistKey)
        }
        else
        {
            SendNormalDownKey(assistKey)
        }
    }

}

OnReplaceUpKey(key, info, mode)
{
    key := SubStr(key, 2)
    tableItem := GetTableItem(3)
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        assistKey := infos[A_Index]
        if (mode == 1)
        {
            SendGameModeUpKey(assistKey)
        }
        else
        {
            SendNormalUpKey(assistKey)
        }
    } 

}