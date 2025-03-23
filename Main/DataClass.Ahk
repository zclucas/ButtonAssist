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

        this.TabNameArr := ["按键宏", "子串宏", "按键替换", "工具", "设置"]
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

class CompareData{
    __New() {
        this.SerialStr := ""
        this.TextFilter := ""
        this.TrueCommandStr := ""
        this.FalseCommandStr := ""
        this.BaseVariableArr := []
        this.VariableArr := []
        this.VariableOperatorArr := ["x", "y", "w", "h"]
        this.ComparEnableArr := [1, 0, 0, 0]
        this.ComparTypeArr := [1, 1, 1, 1]
        this.ComparValueArr := [0, 0, 0, 0]
    }

    
}
