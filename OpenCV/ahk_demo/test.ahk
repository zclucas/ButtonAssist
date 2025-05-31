#Requires AutoHotkey v2.0

; 配置参数
global imageFile := "./11.png"        ; 目标图片路径
global searchX := 0                   ; 搜索区域X
global searchY := 0                   ; 搜索区域Y
global searchW := A_ScreenWidth       ; 默认全屏宽度
global searchH := A_ScreenHeight      ; 默认全屏高度
global matchThreshold := 90           ; 匹配阈值(0-100)

; 加载DLL
dllPath := A_ScriptDir "\ImageFinder.dll"
if !FileExist(dllPath) {
    MsgBox "ImageFinder.dll 未找到！"
    ExitApp
}

; 定义DLL函数原型
FindImage(targetPath, searchX, searchY, searchW, searchH, matchThreshold, x, y) {
    return DllCall("ImageFinder\FindImage", "AStr", targetPath,
        "Int", searchX, "Int", searchY, "Int", searchW, "Int", searchH,
        "Int", matchThreshold, "Int*", x, "Int*", y, "Cdecl Int")
}

; 热键绑定
F10:: StartSearch()  ; 启动搜索
Esc:: ExitApp        ; 退出脚本

; 搜索控制变量
global isSearching := false

StartSearch() {
    global
    x := y := 0  ; 必须每次重置坐标

    ; 调用DLL函数
    success := FindImage(
        imageFile,        ; 图片路径
        searchX,          ; 搜索区X
        searchY,          ; 搜索区Y
        searchW,         ; 搜索区宽度`
        searchH,         ; 搜索区高度
        matchThreshold,  ; 匹配阈值
        &x,             ; 接收X坐标
        &y              ; 接收Y坐标
    )

    if success == 1 {
        MsgBox "找到目标！坐标：X" x " Y" y
        MouseMove x, y, 0
        return
    }
}