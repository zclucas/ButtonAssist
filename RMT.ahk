#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Joy\SuperCvJoyInterface.ahk
#Include Joy\JoyMacro.ahk
#Include RapidOcr\RapidOcr.ahk
#Include Plugins\WinClipAPI.ahk
#Include Plugins\WinClip.ahk
#Include Gui\TriggerKeyGui.ahk
#Include Gui\TriggerStrGui.ahk
#Include Gui\EditHotkeyGui.ahk
#Include Gui\MacroEditGui.ahk
#Include Gui\ReplaceKeyGui.ahk
#Include Gui\ScrollBar.ahk

#Include Main\Gdip_All.ahk
#Include Main\DataClass.ahk
#Include Main\AssetUtil.ahk
#Include Main\HotkeyUtil.ahk
#Include Main\RMTUtil.ahk
#Include Main\WorkPool.ahk
#Include Main\UIUtil.ahk
#Include Main\JsonUtil.ahk
#Include Main\CompareUtil.ahk
SetWorkingDir A_ScriptDir
DetectHiddenWindows true
Persistent

global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyJoyMacro := JoyMacro()
global MyWinClip := WinClip()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyEditHotkeyGui := EditHotkeyGui()
global MyMacroGui := MacroEditGui()
global MyReplaceKeyGui := ReplaceKeyGui()
global MySubMacroStopAction := SubMacroStopAction
global MyTriggerSubMacro := TriggerSubMacro

InitFilePath()  ;初始化文件路径
LoadSetting()   ;加载配置
EditListen()    ;右键编辑数据监听
InitData()      ;初始化软件数据
InitUI()        ;初始化UI
BindSave()      ;绑定保存方法
BindKey()       ;绑定快捷键

;放后面初始化，因为这初始化时间比较长
global MyWorkPool := WorkPool()
global MySpeedOcr := RapidOcr(A_ScriptDir)
global MyStandardOcr := RapidOcr(A_ScriptDir, 2)
global MyPToken := Gdip_Startup()
OpenCVLoadDll()

a:: {
    targetTitle := "QQ"
    hwnd := WinGetID(targetTitle)

    ; 点击位置（窗口客户区坐标）
    x := 30
    y := 70
    lParam := (y << 16) | (x & 0xFFFF)

    ; 发送鼠标按下消息
    PostMessage 0x201, 1, lParam, , hwnd  ; WM_LBUTTONDOWN
    Sleep 50
    ; 发送鼠标抬起消息
    PostMessage 0x202, 0, lParam, , hwnd  ; WM_LBUTTONUP
}
