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
        global NormalPeriod
        if (this.IsToolCheck)
            this.CheckTimer := Timer(SetToolCheckInfo, NormalPeriod, "")
        else
            this.CheckTimer := ""
    }
}