#Requires AutoHotkey v2.0
class WorkPool {
    __New() {
        this.maxSize := MySoftData.MutiThread ? MySoftData.MutiThreadNum : 0
        this.pool := []              ; 对象池数组
        this.hwndMap := Map()
        this.pidMap := Map()
        loop this.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            Run (Format("{} {} {}", workPath, MySoftData.MyGui.Hwnd, A_Index))
        }
        OnMessage(WM_LOAD_WORK, this.MsgFinishLoad.Bind(this))  ; 工作器完成工作回调
        OnMessage(WM_RELEASE_WORK, this.MsgReleaseHandler.Bind(this))  ; 工作器完成工作回调
    }

    __Delete() {
        this.Clear()
    }

    CheckHasWork() {
        return this.pool.Length >= 1
    }

    ; 从池中获取一个对象
    Get() {
        workPath := ""
        if (this.pool.Length >= 1) {
            workPath := this.pool.Pop()
        }
        return workPath
    }

    GetWorkHwnd(workPath) {
        if (!this.hwndMap.Has(workPath)) {
            workIndex := StrReplace(workPath, A_ScriptDir "\Thread\Work")
            workIndex := StrReplace(workIndex, ".exe")
            try {
                hwnd := WinGetID("RMTWork" workIndex)
                this.hwndMap.Set(workPath, hwnd)
            }
        }
        return this.hwndMap.Get(workPath, 0)
    }

    ; 清空对象池
    Clear() {
        loop this.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            this.PostMessage(WM_CLEAR_WORK, workPath, 0, 0)
        }
        this.pool := []
    }

    PostMessage(type, workPath, wParam, lParam) {
        hwnd := this.GetWorkHwnd(workPath)
        try {
            PostMessage(type, wParam, lParam, , "ahk_id " hwnd)
        }
    }

    MsgReleaseHandler(wParam, lParam, msg, hwnd) {
        workPath := A_ScriptDir "\Thread\Work" wParam ".exe"
        this.pool.Push(workPath)
    }

    MsgFinishLoad(wParam, lParam, msg, hwnd) {
        workPath := A_ScriptDir "\Thread\Work" wParam ".exe"
        this.pool.Push(workPath)
    }
}
