#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Gdip_All.ahk
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

global TabNameArr :=["特按键宏", "按键宏", "按键替换", "软件宏", "配置规则", "工具"]
global TabSymbolArr := ["Special", "Normal", "Replace", "Soft", "Rule", "Tool"]
global TabCtrl

global ScriptInfo := ScriptSettingInfo()
global TableInfo := CreateTableItemArr(TabNameArr.Length)
global ToolCheckInfo := ToolCheck()

OnReadSetting()
InitLoosenState()
AddUI()
CustomTrayMenu()
BindHotKey()
BindPauseHotkey()
BindToolCheckHotkey()
ToolCheckInfo.ResetTimer()
OnOpen()

