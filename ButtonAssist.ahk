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
global PauseHotkey := ""


global TabIndex := 1
global TabPosY := 0
global OperBtnPosY := 0

global BtnAdd
global BtnSave
global BtnRemove

global TabCtrl
global TableItemNum := 5
global TableInfo := CreateTableItemArr(TableItemNum)
global ToolCheckInfo := ToolCheck()
global ShowWinCtrl
global PauseToggleCtrl
global PauseHotkeyCtrl


global IsPause := false
global IsLastSaved := false
global IsExecuteShow := true
global NormalPeriod := 50

OnReadSetting()
AddUI()
CustomTrayMenu()
BindHotKey()
BindPauseHotkey()
BindToolCheckHotkey()
ToolCheckInfo.ResetTimer()
OnOpen()

