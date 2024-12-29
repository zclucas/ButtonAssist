Class TableItem
{
    __New()
    {
        this.TKArr := []
        this.InfoArr := []
        this.ModeArr := []
        this.ForbidArr := []
        this.ProcessNameArr := []
        this.LoosenStopArr := []
        this.RemarkArr := []
        this.TKConArr := []
        this.InfoConArr := []
        this.KeyBtnConArr := []
        this.MacroBtnConArr := []
        this.ReplaceBtnConArr := []
        this.ModeConArr := []
        this.ForbidConArr := []
        this.ProcessNameConArr := []
        this.LoosenStopConArr := []
        this.RemarkTextConArr := []
        this.RemarkConArr := []
        this.UnderPosY := 0

        this.LoosenState := []
        this.TimerDoubleArr := []
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

        this.IsToolCheck := false
        this.ToolCheckHotKey := ""
        this.PosStr := ""
        this.ProcessName := ""
        this.ProcessTile := ""
        this.ProcessPid := ""
        this.ProcessClass := ""
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
        this.HoldFloat := 5
        this.HoldFloatCtrl := ""
        this.ClickFloat := 5
        this.ClickFloatCtrl := ""
        this.IntervalFloat := 5
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
        this.TabPosY := 0
        this.BtnAddCon := ""
        this.BtnAddSave := ""
        this.BtnRemove := ""

        this.TabNameArr := ["按键宏", "按键宏2", "子串宏", "按键替换", "软件宏", "配置规则", "工具"]
        this.TabSymbolArr := ["Normal", "Normal2", "String", "Replace", "Soft", "Rule", "Tool"]
        this.TabCtrl := {}
        this.TableInfo := []

        this.HoldKeyMap := Map()
        this.TimerActionMap := Map()
    }
}