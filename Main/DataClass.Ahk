Class TableItem
{
    __New()
    {
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
        this.SearchActionArr := []
        this.HoldKeyArr := []
        this.KilledArr := []
        this.ActionCount := []      ; 记录执行次数，用于循环次数判断
        this.UnderPosY := 0
        this.Index := 0
    }
}

Class ToolCheck
{
    __New()
    {
        this.ToolCheckCtrl := "" 
        this.ToolCheckHotKeyCtrl := ""
        this.ToolMousePosCtrl := ""
        this.ToolProcessNameCtrl := ""
        this.ToolProcessTileCtrl := ""
        this.ToolProcessPidCtrl := ""
        this.ToolProcessClassCtrl := ""
        this.ToolProcessIdCtrl := ""
        this.ToolColorCtrl := ""

        this.IsToolCheck := false
        this.ToolCheckHotKey := ""
        this.PosStr := ""
        this.ProcessName := ""
        this.ProcessTile := ""
        this.ProcessPid := ""
        this.ProcessClass := ""
        this.ProcessId := ""
        this.Color := ""
        this.CheckTimer := ""
    }

    ResetTimer()
    {
        global MySoftData
        if (this.IsToolCheck)
        {
            this.CheckTimer := Timer(SetToolCheckInfo, 100)
            this.CheckTimer.On()
        }
        else
            this.CheckTimer := ""
    }
}

Class SoftData
{
    __New()
    {
        this.IsExecuteShow := true
        this.ShowWinCtrl := ""
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

        this.SpecialKeyMap := Map("Browser_Back", 0, "Browser_Forward", 0, "Browser_Refresh", 0, "Browser_Stop", 0, "Browser_Search", 0, "Browser_Favorites", 0, "Browser_Home", 0, "Volume_Mute", 0, "Volume_Down", 0, "Volume_Up", 0, "Media_Next", 0, "Media_Prev", 0, "Media_Stop", 0, "Media_Play_Pause", 0, "Launch_Mail", 0, "Launch_Media", 0, "Launch_App1", 0, "Launch_App2", 0)
        this.SpecialTableItem := TableItem()

        this.ContinueKeyMap := Map("LButton", "LButton", "~LButton", "LButton", "RButton", "RButton", "~RButton", "RButton", "MButton", "MButton", "~MButton", "MButton", "XButton1", "XButton1", "~XButton1", "XButton1", "XButton2", "XButton2", "~XButton2", "XButton2")
        this.ContinueSecondIntervale := 200
        this.ContinueIntervale := 50

        this.GroupFixedCons := []
        this.FixedCons := []
        this.SB := ""
    }
}

Class KeyboardData{
    __New(){
        this.NodeSerial := 0
        this.KeyName := ""
        this.StartTime := 0
        this.EndTime := 0
        this.StartPos := []
        this.EndPos := []
    }

    Span(){
        return this.EndTime - this.StartTime
    }
}

Class RecordNodeData{
    __New(){
        this.StartTime := 0
        this.EndTime := 0
    }

    Span(){
        return this.EndTime - this.StartTime
    }
}

Class MoveData{
    __New(){
        this.EndPosX := 0
        this.EndPosY := 0
        this.NodeSerial := 0
    }
}

