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
#Include Main\JsonUtil.ahk
#Include Main\CompareUtil.ahk

global MySoftData := SoftData()
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyJoyMacro := JoyMacro()
global MyMacroGui := MacroGui()
global MyReplaceKeyGui := ReplaceKeyGui()

global IniFile := A_WorkingDir "\Setting\MainSettings.ini"
global SearchFile := A_WorkingDir "\Setting\SearchFile.ini"
global CompareFile := A_WorkingDir "\Setting\CompareFile.ini"
global CoordFile := A_WorkingDir "\Setting\CoordFile.ini"
global FileFile := A_WorkingDir "\Setting\FileFile.ini"
global IniSection := "UserSettings"

LoadSetting()
InitData()
InitUI()
BindKey()

;放后面初始化，因为这两个初始化时间比较长
global MyOcr := RapidOcr()
global MyPToken := Gdip_Startup()
