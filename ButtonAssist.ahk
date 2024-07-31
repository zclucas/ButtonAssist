#Requires AutoHotkey v2.0
#SingleInstance Force

IniFile := "settings.ini"
IniSection := "UserSettings"
global TKArr := []
global KeyInfoArr := []
global ModeArr := []
global TkControlArr := []
global KeyControlArr := []
global ModeControlArr := []

global TKRepalceArr := []
global KeyInfoReplaceArr := []
global ModeReplaceArr := []
global TkControlReplaceArr := []
global KeyControlReplaceArr := []
global ModeControlReplaceArr := []

global IsLastSaved := false
global PauseHotkey := ""
global IsPause := false
global TabIndex := 1
global TabPosY := 0
global OperBtnPosY := 0
global HotKeyUIY := 0
global ReplaceKeyUIY := 0
global MyGui
global PauseToggleControl
global PauseHotkeyControl
global TabCtrl

OnReadSetting()
AddUI()
CustomTrayMenu()
BindHotKey()
BindReplaceKey()
OnOpen()

;-------------------------------------------函数方法------------------------------------------------------
;UI相关函数
AddUI()
{
    global MyGui, PauseToggleControl, PauseHotkeyControl, TabCtrl, TabPosY
    MyGui := Gui(, "Super的按键辅助器")
    MyGui.Opt("ToolWindow")
    MyGui.SetFont(, "Consolas")

    ; 参考链接
    LinkText := '<a href="https://wyagd001.github.io/v2/docs/KeyList.htm" id="notepad">特殊按键名参考链接</a>'
    MyGui.Add("Link", "x20 w200", LinkText)

    ; 暂停模块
    MyGui.Add("Text", "x350 y5 w70", "暂停:")
    PauseToggleControl := MyGui.Add("Checkbox", "x385 y5", "")
    PauseToggleControl.value := IsPause
    MyGui.Add("Text", "x420 y5 w70", "快捷键:")
    PauseHotkeyControl := MyGui.Add("Edit", "x470 y0 w70 Center", PauseHotkey)

    TabPosY := 30
    TabCtrl := myGui.Add("Tab3","x10 w700 y" TabPosY " Choose" TabIndex, ["按键宏", "按键替换"])
    TabCtrl.UseTab(1)
    AddHotkeyUI()
    TabCtrl.UseTab(2)
    AddReplacekeyUI()
    TabCtrl.UseTab()

    AddOperBtnUI()
}

AddHotkeyUI()
{
    global HotKeyUIY
    HotKeyUIY := TabPosY
    ; 配置规则说明
    HotKeyUIY += 30
    MyGui.Add("Text", Format("x20 y{}", HotKeyUIY), "触发键规则：“q”忽略系统q按键，“~q”系统q按键正常")
    HotKeyUIY += 20
    MyGui.Add("Text", Format("x20 y{}", HotKeyUIY), "辅助键规则：例如“a_40_50_5”(按键名_按住时间_按键间隔[_按下次数])(单位毫秒),逗号分割")
    HotKeyUIY += 20
    MyGui.Add("Text", Format("x20 y{}", HotKeyUIY), "模式：勾选为游戏模式。若游戏内无效请以管理员身份运行软件")
    HotKeyUIY += 20
    MyGui.Add("Text", Format("x30 y{} w70", HotKeyUIY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", HotKeyUIY), "辅助键：触发键按下后，依次辅助按下的按键")
    MyGui.Add("Text", Format("x650 y{} w70", HotKeyUIY), "模式")
    
    HotKeyUIY += 20
    loop TKArr.Length
    {
        YPos := " y" HotKeyUIY
        TName := " vTk" A_Index
        KName := " vKeyInfo" A_Index
        MName := " vMode" A_Index

        newTkControl := MyGui.Add("Edit", "x20 w70 Center" TName YPos, TKArr[A_Index])
        newKeyControl := MyGui.Add("Edit", "x100 w550" KName YPos, KeyInfoArr[A_Index])
        newModeControl := MyGui.Add("Checkbox", "x660 w50" MName YPos, "")
        newModeControl.Value := ModeArr[A_Index]
        TkControlArr.Push(newTkControl)
        KeyControlArr.Push(newKeyControl)
        ModeControlArr.Push(newModeControl)
        HotKeyUIY += 30
    }
}

;添加按键替换UI
AddReplacekeyUI()
{
    global ReplaceKeyUIY
    ReplaceKeyUIY := TabPosY
    ; 配置规则说明
    ReplaceKeyUIY += 30
    MyGui.Add("Text", Format("x20 y{}", ReplaceKeyUIY), "触发键规则：“q”忽略系统q按键，“~q”系统q按键正常")
    ReplaceKeyUIY += 20
    MyGui.Add("Text", Format("x20 y{}", ReplaceKeyUIY), "辅助键规则：按键名，按键名...")
    ReplaceKeyUIY += 20
    MyGui.Add("Text", Format("x20 y{}", ReplaceKeyUIY), "模式：勾选为游戏模式。若游戏内无效请以管理员身份运行软件")
    ReplaceKeyUIY += 20
    MyGui.Add("Text", Format("x30 y{} w70", ReplaceKeyUIY), "替换键")
    MyGui.Add("Text", Format("x100 y{} w550", ReplaceKeyUIY), "辅助键：替换键按下/松开后，依次辅助按下/松开的按键")
    MyGui.Add("Text", Format("x650 y{} w70", ReplaceKeyUIY), "模式")

    ReplaceKeyUIY += 20
    loop TKRepalceArr.Length
    {
        YPos := " y" ReplaceKeyUIY
        TName := " vTk" "replace" A_Index
        KName := " vKeyInfo" "replace" A_Index
        MName := " vMode" "replace" A_Index

        newTkControl := MyGui.Add("Edit", "x20 w70 Center" TName YPos, TKRepalceArr[A_Index])
        newKeyControl := MyGui.Add("Edit", "x100 w550" KName YPos, KeyInfoReplaceArr[A_Index])
        newModeControl := MyGui.Add("Checkbox", "x660 w50" MName YPos, "")
        newModeControl.Value := ModeReplaceArr [A_Index]
        TkControlReplaceArr.Push(newTkControl)
        KeyControlReplaceArr.Push(newKeyControl)
        ModeControlReplaceArr.Push(newModeControl)
        ReplaceKeyUIY += 30
    }
}

AddOperBtnUI()
{
    global OperBtnPosY
    maxY := Max(HotKeyUIY, ReplaceKeyUIY)
    OperBtnPosY := maxY + 10
    YPos := " y" OperBtnPosY
    global btnAdd := MyGui.Add("Button", "x100 w100 vbtnAdd" YPos, "新增配置")
    btnAdd.OnEvent("Click", OnAddSetting)
    global btnRemove := MyGui.Add("Button", "x300 w100 vbtnRemove" YPos, "删除最后的配置")
    btnRemove.OnEvent("Click", OnRemoveSetting)
    global btnSure := MyGui.Add("Button", "x500 w100 vbtnSure" YPos, "应用并保存")
    btnSure.OnEvent("Click", OnSaveSetting)
}


; 系统托盘优化
CustomTrayMenu(){
    A_TrayMenu.Insert("&Suspend Hotkeys", "显示设置", ShowGui)
    A_TrayMenu.Insert("&Suspend Hotkeys", "重载", MenuReload)
    A_TrayMenu.Delete("&Pause Script")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "显示设置"
}

MenuReload(*)
{
    Reload()
}

ShowGui(*)
{
    RefreshGui()
}

; 自定义函数
BindHotKey()
{
    loop TKArr.Length
    {
        if (TKArr[A_Index] != "")
        {
            key := "$" TKArr[A_Index]
            Hotkey(key, OnTriggerKey)
        }

    }

    if (PauseHotkey != "")
    {
        key := "$" PauseHotkey
        Hotkey(key, OnPauseHotkey)
    }
}

BindReplaceKey()
{
    loop TKRepalceArr.Length
    {
        if (TKRepalceArr[A_Index] != "")
        {
            key := "$" TKRepalceArr[A_Index]
            Hotkey(key, OnReplaceDownKey)
            Hotkey(key " up", OnReplaceUpKey)
        }

    }
}

RefreshGui()
{
    MyGui.Show("w720" "h" Max(HotKeyUIY, ReplaceKeyUIY) + 50)
}

RefreshOperBtnPos()
{
    global OperBtnPosY
    maxY := Max(HotKeyUIY, ReplaceKeyUIY)
    OperBtnPosY := maxY + 10
    btnAdd.Move(100, OperBtnPosY)
    btnRemove.Move(300, OperBtnPosY)
    btnSure.Move(500, OperBtnPosY)
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

SendGameModeReplaceUpKey(Key)
{
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 2, "UPtr", 0)
}

SendGameModeReplaceDownKey(Key)
{
    VK := GetKeyVK(Key), SC := GetKeySC(Key)
    DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 0, "UPtr", 0)
}

SendNormalReplaceDownKey(Key) 
{
    keyDown := "{" Key " down}"
    Send(keyDown)
}

SendNormalReplaceUpKey(Key) 
{
    keyUp := "{" Key " up}"
    Send(keyUp)
}

; 回调函数
OnOpen()
{
    if (!IsLastSaved)
        return
    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
    IniWrite(1, IniFile, IniSection, "TabIndex")
}

OnReadSetting()
{
    global IsLastSaved, PauseHotkey, TabIndex  ; 访问全局变量
    savedTK := IniRead(IniFile, IniSection, "TriggerKey", "~q,2,^+n")
    savedKeyInfo := IniRead(IniFile, IniSection, "KeyInfos", "d_30_40,a_30_40,d_30_40,a_30_10,j_30_0|ctrl_100_10,a_100_0|LButton_30_50,LButton_30_0")
    savedMode := IniRead(IniFile, IniSection, "Mode", "0,1,0")
    savedReplaceTK := IniRead(IniFile, IniSection, "TriggerReplaceKey", "e,alt,t")
    savedReplaceKeyInfo := IniRead(IniFile, IniSection, "KeyReplaceInfos", "w,d|f10|")
    savedReplaceMode := IniRead(IniFile, IniSection, "ModeReplace", "1,1,0")
    TabIndex := IniRead(IniFile, IniSection, "TabIndex", 1)
    IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    For index, value in StrSplit(savedTK, ",")
    {
        if (TKArr.Length < index)
        {
            TKArr.Push(value)
        }
        else
        {
            TKArr[index] = value
        }
    }

    For index, value in StrSplit(savedKeyInfo, "|")
    {
        if (KeyInfoArr.Length < index)
        {
            KeyInfoArr.Push(value)
        }
        else
        {
            KeyInfoArr[index] = value
        }
    }

    For index, value in StrSplit(savedMode, ",")
    {
        if (ModeArr.Length < index)
        {
            ModeArr.Push(Integer(value))
        }
        else
        {
            ModeArr[index] = Integer(value)
        }
    }

    For index, value in StrSplit(savedReplaceTK, ",")
    {
        if (TKRepalceArr.Length < index)
        {
            TKRepalceArr.Push(value)
        }
        else
        {
            TKRepalceArr[index] = value
        }
    }
    
    For index, value in StrSplit(savedReplaceKeyInfo, "|")
    {
        if (KeyInfoReplaceArr.Length < index)
        {
            KeyInfoReplaceArr.Push(value)
        }
        else
        {
            KeyInfoReplaceArr[index] = value
        }
    }

    For index, value in StrSplit(savedReplaceMode, ",")
    {
        if (ModeReplaceArr.Length < index)
        {
            ModeReplaceArr.Push(Integer(value))
        }
        else
        {
            ModeReplaceArr[index] = Integer(value)
        }
    }
}


OnAddSetting(*)
{
    global HotKeyUIY, ReplaceKeyUIY
    tabIndex := TabCtrl.Value
    postfix := tabIndex == 1 ? "" : "replace"
    UIY := tabIndex == 1 ? HotKeyUIY : ReplaceKeyUIY
    btnRemove.Visible := false

    keyArr := tabIndex == 1 ? TKArr : TKRepalceArr
    keyInfoArr := tabIndex == 1 ? KeyInfoArr : KeyInfoReplaceArr
    modeArr := tabIndex == 1 ? ModeArr : ModeReplaceArr

    keyArr.Push("")
    keyInfoArr.Push("")
    modeArr.Push(0)
    
    posY := " y" UIY
    TName := " vTk" postfix keyArr.Length
    KName := " vKeyInfo" postfix keyInfoArr.Length
    MName := " vMode" postfix modeArr.Length
    TabCtrl.UseTab(tabIndex)
    newTkControl := MyGui.Add("Edit", "x20 w70 Center" TName posY, "")
    newKeyControl := MyGui.Add("Edit", "x100 w550" KName posY, "")
    newModeControl := MyGui.Add("Checkbox", "x660 w50" MName posY, "")
    
    newModeControl.value := 0

    ; 更新 y 坐标
    UIY += 30
    if (tabIndex == 1)
    {
        HotKeyUIY := UIY
        TkControlArr.Push(newTkControl)
        KeyControlArr.Push(newKeyControl)
        ModeControlArr.Push(newModeControl)
    }
    else
    {
        ReplaceKeyUIY := UIY
        TkControlReplaceArr.Push(newTkControl)
        KeyControlReplaceArr.Push(newKeyControl)
        ModeControlReplaceArr.Push(newModeControl)
    }

    maxY := Max(HotKeyUIY, ReplaceKeyUIY)
    TabCtrl.UseTab()
    TabCtrl.Move(10, TabPosY, 700, maxY - TabPosY)

    RefreshOperBtnPos()
    RefreshGui()
}

OnRemoveSetting(*)
{
    global HotKeyUIY, ReplaceKeyUIY
    tabIndex := TabCtrl.Value
    postfix := tabIndex == 1 ? "" : "replace"
    UIY := tabIndex == 1 ? HotKeyUIY : ReplaceKeyUIY
    btnAdd.Visible := false
    UIY -= 30
    if (tabIndex == 1)
    {
        HotKeyUIY := UIY
        TKArr.Pop()
        KeyInfoArr.Pop()
        ModeArr.Pop()
        TkControlArr.Pop().Visible := false
        KeyControlArr.Pop().Visible := false
        ModeControlArr.Pop().Visible := false
    }
    else
    {
        ReplaceKeyUIY := UIY
        TKRepalceArr.Pop()
        KeyInfoReplaceArr.Pop()
        ModeReplaceArr.Pop()
        TkControlReplaceArr.Pop().Visible := false
        KeyControlReplaceArr.Pop().Visible := false
        ModeControlReplaceArr.Pop().Visible := false
    }
}

OnSaveSetting(*)
{
    curTK := ""
    curKeyInfo := ""
    curMode := ""
    curTKRepalce := ""
    curKeyReplaceInfo := ""
    curModeReplace := ""
    Saved := MyGui.Submit()

    loop TKArr.Length
    {
        TName := "Tk" A_Index
        KName := "KeyInfo" A_Index
        MName := "Mode" A_Index
        For Name, Value in Saved.OwnProps()
        {
            if (TName = Name)
            {
                curTK .= Value
            }
            if (KName = Name)
            {
                curKeyInfo .= Value
            }

            if (MName = Name)
            {
                curMode .= Value
            }
        }

        if (TKArr.Length > A_Index)
        {
            curTK .= ","
            curKeyInfo .= "|"
            curMode .= ","
        }
    }

    loop TKRepalceArr.Length
    {
        TName := "Tk" "replace" A_Index
        KName := "KeyInfo" "replace" A_Index
        MName := "Mode" "replace" A_Index
        For Name, Value in Saved.OwnProps()
        {
            if (TName = Name)
            {
                curTKRepalce .=  Value
            }
            if (KName = Name)
            {
                curKeyReplaceInfo .=  Value
            }

            if (MName = Name)
            {
                curModeReplace .=  Value
            }
        }

        if (TKRepalceArr.Length > A_Index)
        {
            curTKRepalce .= ","
            curKeyReplaceInfo .= "|"
            curModeReplace .= ","
        }
    }

    IniWrite(PauseHotkeyControl.Text, IniFile, IniSection, "PauseHotkey")
    IniWrite(curTK, IniFile, IniSection, "TriggerKey")
    IniWrite(curKeyInfo, IniFile, IniSection, "KeyInfos")
    IniWrite(curMode, IniFile, IniSection, "Mode")
    IniWrite(curTKRepalce, IniFile, IniSection, "TriggerReplaceKey")
    IniWrite(curKeyReplaceInfo, IniFile, IniSection, "KeyReplaceInfos")
    IniWrite(curModeReplace, IniFile, IniSection, "ModeReplace")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(TabCtrl.Value, IniFile, IniSection, "TabIndex")
    Reload()
}

OnTriggerKey(key)
{
    keyInfo := ""
    key := SubStr(key, 2)
    mode := 1
    loop TKArr.Length
    {
        if (TKArr[A_Index] = key)
        {
            keyInfo := KeyInfoArr[A_Index]
            mode := ModeArr[A_Index]
        }
    }
    keyInfos := StrSplit(keyInfo, ",")
    loop keyInfos.Length
    {
        info := StrSplit(keyInfos[A_Index], "_")
        count := 1
        if (info.Length > 3)
        {
            count := Integer(info[4])
        }
        loop count
        {
            if (IsPause) 
                break

            if (mode == 1)
            {
                SendGameModeKey(info[1], Integer(info[2]))
            }
            else
            {
                SendNormalKey(info[1], Integer(info[2]))
            }
            Sleep(Integer(info[3]))
        }
    }
}

OnReplaceDownKey(key)
{
    keyInfo := ""
    key := SubStr(key, 2)
    mode := 1
    loop TKRepalceArr.Length
    {
        if (TKRepalceArr[A_Index] == key)
        {
            keyInfo := KeyInfoReplaceArr[A_Index]
            mode := ModeReplaceArr[A_Index]
        }
    }
    keyInfos := StrSplit(keyInfo, ",")

    loop keyInfos.Length
    {
        assistKey := keyInfos[A_Index]
        if (mode == 1)
        {
            SendGameModeReplaceDownKey(assistKey)
        }
        else
        {
            SendNormalReplaceDownKey(assistKey)
        }
    }

    

}

OnReplaceUpKey(key)
{
    keyInfo := ""
    key := SubStr(key, 2, StrLen(key) - 4)
    mode := 1
    loop TKRepalceArr.Length
    {
        if (TKRepalceArr[A_Index] = key)
        {
            keyInfo := KeyInfoReplaceArr[A_Index]
            mode := ModeReplaceArr[A_Index]
        }
    }
    keyInfos := StrSplit(keyInfo, ",")

    loop keyInfos.Length
    {
        assistKey := keyInfos[A_Index]
        if (mode == 1)
        {
            SendGameModeReplaceUpKey(assistKey)
        }
        else
        {
            SendNormalReplaceUpKey(assistKey)
        }
    } 

}

OnPauseHotkey(key)
{
    global IsPause, PauseToggleControl  ; 访问全局变量
    IsPause := !IsPause
    PauseToggleControl.value := IsPause
    Suspend(IsPause)
}
