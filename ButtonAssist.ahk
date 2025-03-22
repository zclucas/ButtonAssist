#Requires AutoHotkey v2.0
#SingleInstance Force 
#Include Joy\SuperCvJoyInterface.ahk
#Include Joy\JoyMacro.ahk
#Include RapidOcr\RapidOcr.ahk

#Include Gui\TriggerKeyGui.ahk
#Include Gui\TriggerStrGui.ahk
#Include Gui\MacroGui.ahk
#Include Gui\ReplaceKeyGui.ahk
#Include Gui\ScrollBar.ahk

#Include Main\Gdip_All.ahk
#Include Main\DataClass.ahk
#Include Main\AssetUtil.ahk
#Include Main\TimerUtil.ahk
#Include Main\HotkeyUtil.ahk
#Include Main\UIUtil.ahk

IniFile := "Settings.ini"
IniSection := "UserSettings"

global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyJoyMacro := JoyMacro()
global MyMacroGui := MacroGui()
global MyReplaceKeyGui := ReplaceKeyGui()
global MyOcr := RapidOcr()
global MyPToken := Gdip_Startup()

LoadSetting()
InitData()
InitUI()
BindKey()
OnExit(OnExitSoft)

