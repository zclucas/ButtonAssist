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
global isLastSaved := false
global PauseHotkey := ""
global isPause := false
global curY := 110

ReadSetting()

MyGui := Gui(, "Super的按键辅助器")
MyGui.Opt("ToolWindow")
MyGui.SetFont(, "Consolas")

; 参考链接
LinkText := '<a href="https://wyagd001.github.io/v2/docs/KeyList.htm" id="notepad">特殊按键名参考链接</a>'
MyGui.Add("Link", "x20 w200", LinkText)

; 暂停模块
MyGui.Add("Text", "x350 y5 w70", "暂停:")
global pauseToggleControl := MyGui.Add("Checkbox", "x385 y5", "")
pauseToggleControl.value := isPause
MyGui.Add("Text", "x420 y5 w70", "快捷键:")
global pauseHotkeyControl := MyGui.Add("Edit", "x470 y0 w70 Center", PauseHotkey)

; 配置规则说明
MyGui.Add("Text", "x20 y30", "触发键规则：“q”忽略系统q按键，“~q”系统q按键正常")
MyGui.Add("Text", "x20 y50", "辅助键规则：“a_40_50_5”(按键名_按住时间_按键间隔[_按下次数])(单位毫秒)")
MyGui.Add("Text", "x20 y70", "模式：勾选为游戏模式。若游戏内无效请以管理员身份运行软件")
MyGui.Add("Text", "x25 y90 w70", "触发键")
MyGui.Add("Text", "x100 y90  w550", "辅助键：触发键按下后，依次辅助按下的按键")
MyGui.Add("Text", "x650 y90 w70", "模式")

loop TKArr.Length
{
    YPos := " y" curY
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
    ; 更新 y 坐标
    curY += 30
}

YPos := " y" curY + 30
btnAdd := MyGui.Add("Button", "x100 w100 vbtnAdd" YPos, "新增配置")
btnAdd.OnEvent("Click", OnAddSetting)
btnRemove := MyGui.Add("Button", "x300 w100 vbtnRemove" YPos, "删除最后的配置")
btnRemove.OnEvent("Click", OnRemoveSetting)
btnSure := MyGui.Add("Button", "x500 w100 vbtnSure" YPos, "应用并保存")
btnSure.OnEvent("Click", OnSaveSetting)

A_TrayMenu.Insert("&Suspend Hotkeys", "显示设置", ShowHideGui)
A_TrayMenu.Insert("&Suspend Hotkeys", "重载", MenuReload)
A_TrayMenu.Delete("&Pause Script")
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default := "显示设置"

BindHotKey()
TryShowGui()

;-------------------------------------------函数方法------------------------------------------------------
MenuReload(*)
{
    Reload()
}

ShowHideGui(*)
{
    global MyGui, curY
    MyGui.Show("w720" "h" curY + 80)
}


TryShowGui()
{
    global MyGui, curY
    if (!isLastSaved)
        return
    MyGui.Show("w720" "h" curY + 80)
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

ReadSetting()
{
    global MyGui, TKArr, KeyInfoArr, ModeArr, isLastSaved, PauseHotkey  ; 访问全局变量
    SavedTK := IniRead(IniFile, IniSection, "TriggerKey", "~q,w,^+n")
    SavedKeyInfo := IniRead(IniFile, IniSection, "KeyInfos", "d_30_40,a_30_40,d_30_40,a_30_10,j_30_0|ctrl_100_10,a_100_0|LButton_30_50,LButton_30_0")
    SavedMode := IniRead(IniFile, IniSection, "Mode", "0,1,0")
    isLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    For index, value in StrSplit(SavedTK, ",")
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

    For index, value in StrSplit(SavedKeyInfo, "|")
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

    For index, value in StrSplit(SavedMode, ",")
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
}

OnAddSetting(*)
{
    global MyGui, curY, TKArr, KeyInfoArr, ModeArr, TkControlArr, KeyControlArr ; 访问全局变量
    btnRemove.Visible := false
    TKArr.Push("")
    KeyInfoArr.Push("")
    ModeArr.Push(0)
    YPos := " y" curY
    TName := " vTk" TKArr.Length
    KName := " vKeyInfo" KeyInfoArr.Length
    MName := " vMode" ModeArr.Length

    newTkControl := MyGui.Add("Edit", "x20 w50 Center" TName YPos, "")
    newKeyControl := MyGui.Add("Edit", "x80 w550" KName YPos, "")
    newModeControl := MyGui.Add("Checkbox", "x670 w50" MName YPos, "")
    newModeControl.value := 0
    TkControlArr.Push(newTkControl)
    KeyControlArr.Push(newKeyControl)
    ModeControlArr.Push(newModeControl)

    ; 更新 y 坐标
    curY += 30

    YPos := curY + 30
    btnAdd.Move(100, YPos)
    btnRemove.Move(300, YPos)
    btnSure.Move(500, YPos)
    MyGui.Show("w720" "h" curY + 80)
}

OnRemoveSetting(*)
{
    global MyGui, curY, TKArr, KeyInfoArr, ModeArr, TkControlArr, KeyControlArr, ModeControlArr ; 访问全局变量
    btnAdd.Visible := false
    TKArr.Pop()
    KeyInfoArr.Pop()
    ModeArr.Pop()
    TkControlArr.Pop().Visible := false
    KeyControlArr.Pop().Visible := false
    ModeControlArr.Pop().Visible := false

    ; 更新 y 坐标
    curY -= 30

    YPos := curY + 30
    btnAdd.Move(100, YPos)
    btnRemove.Move(300, YPos)
    btnSure.Move(500, YPos)
    MyGui.Show("w720" "h" curY + 80)
}

OnSaveSetting(*)
{
    global MyGui, TKArr, KeyInfoArr, ModeArr  ; 访问全局变量

    TK := ""
    KeyInfo := ""
    Mode := ""
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
                TK := TK Value
            }
            if (KName = Name)
            {
                KeyInfo := KeyInfo Value
            }

            if (MName = Name)
            {
                Mode := Mode Value
            }
        }

        if (TKArr.Length > A_Index)
        {
            TK .= ","
            KeyInfo .= "|"
            Mode .= ","
        }
    }

    IniWrite(pauseHotkeyControl.Text, IniFile, IniSection, "PauseHotkey")
    IniWrite(TK, IniFile, IniSection, "TriggerKey")
    IniWrite(KeyInfo, IniFile, IniSection, "KeyInfos")
    IniWrite(Mode, IniFile, IniSection, "Mode")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    Reload()
}

OnTriggerKey(key)
{
    global MyGui, TKArr, KeyInfoArr, ModeArr, isPause  ; 访问全局变量
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
            if (isPause) 
                break
            

            if (mode = 1)
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

OnPauseHotkey(key)
{
    global isPause, pauseToggleControl  ; 访问全局变量
    isPause := !isPause
    pauseToggleControl.value := isPause
}


BindHotKey()
{
    global TKArr  ; 访问全局变量

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