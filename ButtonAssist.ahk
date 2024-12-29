#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Joy\SuperCvJoyInterface.ahk
#Include Joy\JoyMacro.ahk

#Include Gdip_All.ahk
#Include Gui\TriggerKeyGui.ahk
#Include Gui\TriggerStrGui.ahk

#Include DataClass.ahk
#Include AssetUtil.ahk
#Include TimerUtil.ahk
#Include HotkeyUtil.ahk
#Include UIUtil.ahk

IniFile := "settings.ini"
IniSection := "UserSettings"

global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyJoyMacro := JoyMacro()

LoadSetting()
InitData()
InitUI()
BindKey()


