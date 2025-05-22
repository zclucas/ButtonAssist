#Requires AutoHotkey v2.0
#Include "../Main/DataClass.ahk"
#Include "../Main/JsonUtil.ahk"
#Include "../Main/AssetUtil.ahk"
#Include "../Main/HotkeyUtil.ahk"
#NoTrayIcon

; 16进制串转字符串
HexToStr(hex) {
    str := ""
    loop parse hex {
        if (Mod(A_Index, 2) = 1) {
            charCode := "0x" SubStr(hex, A_Index, 2)
            str .= Chr(charCode)
        }
    }
    return str
}

global tableData := JSON.parse(HexToStr(A_Args[1]), false, false)
global macro := JSON.parse(HexToStr(A_Args[2]), false, false)
global index := A_Args[2]
    
OnTriggerMacroKeyAndInit(tableData, macro, index)
    

