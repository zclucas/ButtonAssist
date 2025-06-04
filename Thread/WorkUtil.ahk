#Requires AutoHotkey v2.0

MsgTriggerMacroHandler(wParam, lParam, msg, hwnd) {
    TriggerMacro(wParam, lParam)
    MsgSendHandler(WM_RELEASE_WORK, wParam, lParam)
}

MsgExitHandler(wParam, lParam, msg, hwnd) {
   ExitApp()
}

MsgStopMacroHandler(wParam, lParam, msg, hwnd) {
   KillTableItemMacro(wParam, lParam)
}


TriggerMacro(tableIndex, itemIndex) {
    tableData := MySoftData.TableInfo[tableIndex]
    macro := tableData.MacroArr[itemIndex]
    OnTriggerMacroKeyAndInit(tableData, macro, itemIndex)
}

MsgSendHandler(type, wParam, lParam) {
    PostMessage(type, wParam, lParam, ,"ahk_id " parentHwnd)
}

InitWorkFilePath() {
    global vbsPath := A_WorkingDir "\..\VBS\PlayAudio.vbs"
    global IniFile := A_WorkingDir "\..\Setting\MainSettings.ini"
    global SearchFile := A_WorkingDir "\..\Setting\SearchFile.ini"
    global SearchProFile := A_WorkingDir "\..\Setting\SearchProFile.ini"
    global CompareFile := A_WorkingDir "\..\Setting\CompareFile.ini"
    global CoordFile := A_WorkingDir "\..\Setting\CoordFile.ini"
    global FileFile := A_WorkingDir "\..\Setting\FileFile.ini"
    global OutputFile := A_WorkingDir "\..\Setting\OutputFile.ini"
    global StopFile := A_WorkingDir "\..\Setting\StopFile.ini"
    global VariableFile := A_WorkingDir "\..\Setting\VariableFile.ini"
    global SubMacroFile := A_WorkingDir "\..\Setting\SubMacroFile.ini"
    global OperationFile := A_WorkingDir "\..\Setting\OperationFile.ini"
    global IniSection := "UserSettings"
}

InitWork(){
    global MySoftData
    MySoftData.isWork := true
}

WorkOpenCVLoadDll() {
    dllpath := A_ScriptDir "\..\OpenCV\x64\ImageFinder.dll"

    ; 构建包含 DLL 文件的目录路径
    dllDir := A_ScriptDir "\..\OpenCV\x64"

    ; 使用 SetDllDirectory 将 dllDir 添加到 DLL 搜索路径中
    DllCall("SetDllDirectory", "Str", dllDir)
    DllCall('LoadLibrary', 'str', dllpath, "Ptr")
}

SubMacroStopAction(tableIndex, itemIndex){
    MsgSendHandler(WM_STOP_MACRO, tableIndex, itemIndex)
}

TriggerSubMacro(tableIndex, itemIndex) {
    MsgSendHandler(WM_TR_MACRO, tableIndex, itemIndex)
}
