#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Joy\SuperCvJoyInterface.ahk
#Include Gdip_All.ahk

#Include DataClass.ahk
#Include AssetUtil.ahk
#Include TimerUtil.ahk
#Include HotkeyUtil.ahk
#Include UIUtil.ahk

IniFile := "settings.ini"
IniSection := "UserSettings"

global MyGui
global TabPosY := 0

global BtnAdd
global BtnSave
global BtnRemove

global TabNameArr :=["特按键宏", "按键宏", "按键替换", "软件宏", "配置规则", "工具"]
global TabSymbolArr := ["Special", "Normal", "Replace", "Soft", "Rule", "Tool"]
global TabCtrl

global ScriptInfo := ScriptSettingInfo()
global ToolCheckInfo := ToolCheck()
global MyStick := SuperCvJoyInterface().Devices[1]
global TableInfo := CreateTableItemArr()

OnReadSetting()
InitTableItemState()
AddUI()
CustomTrayMenu()
BindTabHotKey()
BindPauseHotkey()
BindToolCheckHotkey()
ToolCheckInfo.ResetTimer()
OnOpen()

