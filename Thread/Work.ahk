#Requires AutoHotkey v2.0
#Include "..\Main\DataClass.ahk"
#Include "..\Main\JsonUtil.ahk"
#Include "..\Main\AssetUtil.ahk"
#Include "..\Main\HotkeyUtil.ahk"
#Include "..\Main\Gdip_All.ahk"
#Include "..\Main\CompareUtil.ahk"
#Include "..\Joy\SuperCvJoyInterface.ahk"
#Include "..\Joy\JoyMacro.ahk"
#Include "..\RapidOcr\RapidOcr.ahk"
#Include "..\Plugins\WinClipAPI.ahk"
#Include "..\Plugins\WinClip.ahk"
#Include "WorkUtil.ahk"
#SingleInstance Force
DetectHiddenWindows true
Persistent
#NoTrayIcon

global parentHwnd := A_Args[1]
global workIndex := A_Args[2]
global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyJoyMacro := JoyMacro()
global MyWinClip := WinClip()
InitWorkFilePath()  ;初始化文件路径
LoadSetting()   ;加载配置
InitData()
InitWork()

;放后面初始化，因为这初始化时间比较长
global MySpeedOcr := RapidOcr(A_ScriptDir "\..")
global MyStandardOcr := RapidOcr(A_ScriptDir "\..", 2)
global MyPToken := Gdip_Startup()
global MySubMacroStopAction := SubMacroStopAction
global MyTriggerSubMacro := TriggerSubMacro
WorkOpenCVLoadDll()

; 注册消息
OnMessage(WM_TR_MACRO, MsgTriggerMacroHandler)
OnMessage(WM_STOP_MACRO, MsgStopMacroHandler)
OnMessage(WM_CLEAR_WORK, MsgExitHandler)

myTitle := "RMTWork" workIndex
mygui := Gui("+ToolWindow")          ; 创建 GUI，无标题栏
mygui.Title := myTitle               ; 设置窗口标题（这才是 WinGetTitle 能读到的）
mygui.Show("Hide")                   ; 隐藏窗口
global myHwnd := mygui.Hwnd
MsgSendHandler(WM_LOAD_WORK, workIndex, 0)

SubMacroStopAction(tableIndex, itemIndex) {
    MsgSendHandler(WM_STOP_MACRO, tableIndex, itemIndex)
}

TriggerSubMacro(tableIndex, itemIndex) {
    MsgSendHandler(WM_TR_MACRO, tableIndex, itemIndex)
}
