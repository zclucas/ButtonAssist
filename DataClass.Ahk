Class TableItem
{
    __New()
    {
        this.TKArr := []
        this.InfoArr := []
        this.ModeArr := []
        this.ForbidArr := []
        this.ProcessNameArr := []
        this.TKConArr := []
        this.InfoConArr := []
        this.ModeConArr := []
        this.ForbidConArr := []
        this.ProcessNameConArr := []
        this.UnderPosY := 0

        ;Loop专用
        this.LoopState := []
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
        global ScriptInfo
        if (this.IsToolCheck)
        {
            action()
            {
                SetToolCheckInfo(1)
            }
            this.CheckTimer := Timer(action, 100)
            this.CheckTimer.On()
        }
        else
            this.CheckTimer := ""
    }
}

Class ScriptSettingInfo
{
    __New()
    {
        this.IsExecuteShow := true
        this.ShowWinCtrl := ""
        this.IsPause := false
        this.PauseToggleCtrl := ""
        this.PauseHotkey := ""
        this.PauseHotkeyCtrl := ""
        this.KeyAutoLooseTimeMin := 25
        this.KeyAutoLooseTimeMax := 35
        this.KeyAutoLooseTimeMinCtrl := ""
        this.KeyAutoLooseTimeMaxCtrl := ""
        this.NormalPeriod := 50
        this.NormalPeriodCtrl := ""
        this.IsLastSaved := false
        this.WinPosX := 0
        this.WinPosY := 0
        this.IsSavedWinPos := false
        this.TableIndex := 1
        this.HasSaved := false
    }
}