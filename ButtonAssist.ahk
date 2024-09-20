#Requires AutoHotkey v2.0
#SingleInstance Force
#Include TimerUtil.ahk
#Include AssetUtil.ahk
#Include UIUtil.ahk
#Include HotkeyUtil.ahk
#Include DataClass.ahk

IniFile := "settings.ini"
IniSection := "UserSettings"

global MyGui
global TabPosY := 0

global BtnAdd
global BtnSave
global BtnRemove

global TabCtrl
global TableItemNum := 7

global ScriptInfo := ScriptSettingInfo()
global TableInfo := CreateTableItemArr(TableItemNum)
global ToolCheckInfo := ToolCheck()

OnReadSetting()
AddUI()
CustomTrayMenu()
BindHotKey()
BindPauseHotkey()
BindToolCheckHotkey()
ToolCheckInfo.ResetTimer()
OnOpen()

