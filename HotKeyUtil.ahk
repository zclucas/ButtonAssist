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
                    funcObj := OnSimpleTriggerKey.Bind(key, info, mode)
                    Hotkey(key, (key)=>funcObj())
                }
                else if (tableIndex == 2)
                {
                    Hotkey(key, OnNormalTriggerKey)
                }
                else if (tableIndex == 3)
                {
                    Hotkey(key, OnReplaceDownKey)
                    Hotkey(key " up", OnReplaceUpKey)
                }

                if (curProcessName != "")
                {
                    HotIfWinActive
                }
            }

        }
    }
}

BindPauseHotkey()
{
    if (PauseHotkey != "")
    {
        key := "$" PauseHotkey
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
    key := SubStr(key, 2)
    tableItem := GetTableItem(1)
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        if (IsPause) 
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

OnNormalTriggerKey(key)
{
    info := ""
    key := SubStr(key, 2)
    mode := 1
    tableItem := GetTableItem(2)
    TKArr := tableItem.TKArr
    loop TKArr.Length
    {
        if (TKArr[A_Index] == key)
        {
            info := tableItem.InfoArr[A_Index]
            mode := tableItem.ModeArr[A_Index]
        }
    }
    infos := StrSplit(info, ",")

    loop infos.Length
    {
        if (IsPause) 
            break

        strs := StrSplit(infos[A_Index], "_")
        curKey := strs[1]
        leftTime := Integer(strs[2])

        if (mode == 1)
        {
            HoldKey(SendGameModeDownKey, SendGameModeUpKey, NormalPeriod, leftTime, curKey)
        }
        else
        {
            HoldKey(SendNormalDownKey, SendNormalUpKey, NormalPeriod, leftTime, curKey)
        }

        if (infos.Length > A_Index)
        {
            Sleep(Integer(infos[A_Index + 1]))
            A_Index++
        }
    }
}

OnReplaceDownKey(key)
{
    keyInfo := ""
    key := SubStr(key, 2)
    mode := 1
    tableItem := GetTableItem(3)
    TKArr := tableItem.TKArr
    loop TKArr.Length
    {
        if (TKArr[A_Index] == key)
        {
            keyInfo := tableItem.InfoArr[A_Index]
            mode := tableItem.ModeArr[A_Index]
        }
    }
    keyInfos := StrSplit(keyInfo, ",")

    loop keyInfos.Length
    {
        assistKey := keyInfos[A_Index]
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

OnReplaceUpKey(key)
{
    keyInfo := ""
    key := SubStr(key, 2, StrLen(key) - 4)
    mode := 1
    tableItem := GetTableItem(3)
    TKArr := tableItem.TKArr
    loop TKArr.Length
    {
        if (TKArr[A_Index] = key)
        {
            keyInfo := tableItem.InfoArr[A_Index]
            mode := tableItem.ModeArr[A_Index]
        }
    }
    keyInfos := StrSplit(keyInfo, ",")

    loop keyInfos.Length
    {
        assistKey := keyInfos[A_Index]
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