#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
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
#Include Main\TimerUtil.ahk
#Include Main\HotkeyUtil.ahk
#Include Main\UIUtil.ahk
#Include Main\JsonUtil.ahk
#Include Main\CompareUtil.ahk

global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyEditHotkeyGui := EditHotkeyGui()
global MyJoyMacro := JoyMacro()
global MyMacroGui := MacroEditGui()
global MyReplaceKeyGui := ReplaceKeyGui()
global MyWinClip := WinClip()

InitFilePath()
LoadSetting()
EditListen()
InitData()
InitUI()
BindKey()

;放后面初始化，因为这两个初始化时间比较长
global MyOcr := RapidOcr()
global MyPToken := Gdip_Startup()