class TableItem {
    __New() {
        this.TKArr := []
        this.MacroArr := []
        this.LooseStopArr := []
        this.ModeArr := []
        this.ForbidArr := []
        this.ProcessNameArr := []
        this.LoopCountArr := []
        this.RemarkArr := []
        this.TKConArr := []
        this.InfoConArr := []
        this.KeyBtnConArr := []
        this.MacroBtnConArr := []
        this.DeleteBtnConArr := []
        this.LooseStopConArr := []
        this.ModeConArr := []
        this.ForbidConArr := []
        this.ProcessNameConArr := []
        this.LoopCountConArr := []
        this.RemarkTextConArr := []
        this.RemarkConArr := []

        this.CmdActionArr := []
        this.ActionArr := []
        this.HoldKeyArr := []
        this.KilledArr := []
        this.ActionCount := []      ; 记录执行次数，用于循环次数判断
        this.UnderPosY := 0
        this.Index := 0
    }
}

class ToolCheck {
    __New() {
        this.ToolCheckCtrl := ""
        this.ToolCheckHotKeyCtrl := ""
        this.ToolMousePosCtrl := ""
        this.ToolProcessNameCtrl := ""
        this.ToolProcessTileCtrl := ""
        this.ToolProcessPidCtrl := ""
        this.ToolProcessClassCtrl := ""
        this.ToolProcessIdCtrl := ""
        this.ToolColorCtrl := ""
        this.ToolTextFilterHotKeyCtrl := ""
        this.ToolTextCtrl := ""
        this.ToolRecordMacroHotKeyCtrl := ""
        this.ToolCheckRecordMacroCtrl := ""

        this.ToolRecordMacroHotKey := ""
        this.IsToolRecord := false
        this.ToolTextFilterHotKey := ""
        this.IsToolCheck := false
        this.ToolCheckHotKey := ""
        this.PosStr := ""
        this.ProcessName := ""
        this.ProcessTile := ""
        this.ProcessPid := ""
        this.ProcessClass := ""
        this.ProcessId := ""
        this.Color := ""
        this.MouseInfoTimer := ""

        this.MacroGui := ""
        this.RecordNodeArr := []
        this.RecordKeyboardArr := []
        this.RecordHoldKeyMap := Map()
        this.RecordSpecialKeyMap := Map(33, 0, 34, 0, 35, 0, 36, 0, 37, 0, 38, 0, 39, 0, 40, 0, 45, 0, 46, 0)
        this.RecordLastMousePos := []
        this.RecordKeyboardCtrl := ""
        this.RecordKeyboardValue := ""
        this.RecordMouseCtrl := ""
        this.RecordMouseValue := ""
        this.RecordMouseRelativeCtrl := ""
        this.RecordMouseRelativeValue := ""
    }

    MouseInfoSwitch() {
        if (this.IsToolCheck) {
            this.MouseInfoTimer := Timer(SetToolCheckInfo, 100)
            this.MouseInfoTimer.On()
        }
        else
            this.MouseInfoTimer := ""
    }

    RecordMacroSwitch() {
        if (this.IsToolRecord) {
            this.RecordMacroTimer := Timer(() => {}, 100)
            this.RecordMacroTimer.On()
        }
        else
            this.RecordMacroTimer := ""
    }
}

class SoftData {
    __New() {
        this.IsExecuteShow := true
        this.ShowWinCtrl := ""
        this.IsBootStart := false
        this.BootStartCtrl := ""
        this.IsPause := false
        this.PauseToggleCtrl := ""
        this.PauseHotkey := ""
        this.PauseHotkeyCtrl := ""
        this.KillMacroHotkey := ""
        this.KillMacroHotkeyCtrl := ""
        this.HoldFloat := 0
        this.HoldFloatCtrl := ""
        this.PreIntervalFloat := 0
        this.PreIntervalFloatCtrl := ""
        this.IntervalFloat := 0
        this.IntervalFloatCtrl := ""
        this.ImageSearchBlur := 100
        this.ImageSearchBlurCtrl := ""
        this.IsLastSaved := false
        this.WinPosX := 0
        this.WinPosY := 0
        this.IsSavedWinPos := false
        this.TableIndex := 1
        this.HasSaved := false

        this.MyGui := {}
        this.TabPosX := 0
        this.TabPosY := 0
        this.BtnAdd := ""
        this.BtnSave := ""

        this.EditHotKeyCtrl := ""
        this.EditHotStrCtrl := ""

        this.TabNameArr := ["按键宏", "字串宏", "按键替换", "工具", "设置"]
        this.TabSymbolArr := ["Normal", "String", "Replace", "Tool", "Setting"]
        this.TabCtrl := {}
        this.TableInfo := []

        this.TimerActionMap := Map()

        this.SpecialKeyMap := Map("Browser_Back", 0, "Browser_Forward", 0, "Browser_Refresh", 0, "Browser_Stop", 0,
            "Browser_Search", 0, "Browser_Favorites", 0, "Browser_Home", 0, "Volume_Mute", 0, "Volume_Down", 0,
            "Volume_Up", 0, "Media_Next", 0, "Media_Prev", 0, "Media_Stop", 0, "Media_Play_Pause", 0, "Launch_Mail", 0,
            "Launch_Media", 0, "Launch_App1", 0, "Launch_App2", 0)
        this.SpecialTableItem := TableItem()

        this.ContinueKeyMap := Map("LButton", "LButton", "~LButton", "LButton", "RButton", "RButton", "~RButton",
            "RButton", "MButton", "MButton", "~MButton", "MButton", "XButton1", "XButton1", "~XButton1", "XButton1",
            "XButton2", "XButton2", "~XButton2", "XButton2")
        this.SpecialNumKeyMap := Map("WheelDown", 0, "WheelUp", 0)
        this.ContinueSecondIntervale := 200
        this.ContinueIntervale := 50

        this.GroupFixedCons := []
        this.FixedCons := []
        this.SB := ""
    }
}

class KeyboardData {
    __New() {
        this.NodeSerial := 0
        this.KeyName := ""
        this.StartTime := 0
        this.EndTime := 0
        this.StartPos := []
        this.EndPos := []
    }

    Span() {
        return this.EndTime - this.StartTime
    }
}

class RecordNodeData {
    __New() {
        this.StartTime := 0
        this.EndTime := 0
    }

    Span() {
        return this.EndTime - this.StartTime
    }
}

class MoveData {
    __New() {
        this.EndPosX := 0
        this.EndPosY := 0
        this.NodeSerial := 0
    }
}

class SearchData {
    __New() {
        this.SerialStr := ""
        this.SearchType := 1       ;1 图片  2 颜色  3 文本
        this.SearchColor := ""
        this.SearchText := ""
        this.SearchImagePath := ""
        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := A_ScreenWidth
        this.EndPosY := A_ScreenHeight
        this.SearchCount := 1
        this.SearchInterval := 1000
        this.AutoMove := 1
        this.TrueCommandStr := ""
        this.FalseCommandStr := ""
    }

}

class CompareData {
    __New() {
        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := A_ScreenWidth
        this.EndPosY := A_ScreenHeight
        this.SearchCount := 1
        this.SearchInterval := 1000
        this.AutoMove := 1

        this.SerialStr := ""
        this.TextFilter := ""
        this.TrueCommandStr := ""
        this.FalseCommandStr := ""
        this.BaseVariableArr := []
        this.VariableArr := []
        this.ExtractType := 1       ;1屏幕  2 剪切板
        this.VariableOperatorArr := ["x", "y", "w", "h"]
        this.ComparEnableArr := [1, 0, 0, 0]
        this.ComparTypeArr := [1, 1, 1, 1]  ;1大于 2大于等于 3等于 4小于等 5小于
        this.ComparValueArr := [0, 0, 0, 0]
    }
}

class CoordData {
    __New() {
        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := A_ScreenWidth
        this.EndPosY := A_ScreenHeight
        this.SearchCount := 1
        this.SearchInterval := 1000

        this.SerialStr := ""
        this.TextFilter := ""
        this.BaseVariableArr := []
        this.VariableArr := []
        this.ExtractType := 1       ;1屏幕  2 剪切板
        this.isRelative := 0         ;相对位移
        this.Speed := 90           ;移动速度
        this.VariableOperatorArr := ["x", "y"]
    }
}

class FileData {
    __New() {
        this.SerialStr := ""
        this.FilePath := ""
        this.ProcessName := ""
        this.BackPlay := 0
    }
}

class InputData {
    __New() {
        this.SerialStr := ""
        this.Text := ""
        this.IsCover := 1
        this.InputType := 1
    }
}

class StopData {
    __New(){
        this.SerialStr := ""
        this.StopType := 1
        this.StopIndex := 1
        this.StopSelf := false
    }
}
