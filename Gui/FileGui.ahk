#Requires AutoHotkey v2.0

class FileGui {
    __new() {
        this.Gui := ""

        this.SureBtnAction := ""
        this.ProcessTextCon := ""
        this.PathTextCon := ""
        this.MouseProNameCon := ""

        this.Path := ""
        this.ProcessName := ""
        this.CommandStr := ""
        this.RefreshAction := () => this.RefreshProcessName()
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(cmd)
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "文件运行指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:确定鼠标下进程")

        PosX := 10
        PosY += 20
        this.MouseProNameCon :=MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "鼠标下进程名:Zone.exe")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "通过进程运行软件(系统软件，等通过安装的软件)")

        PosY += 20
        this.ProcessTextCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY, 300))

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 200, 20), "文件的绝对路径")

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "指定文件")
        btnCon.OnEvent("Click", (*) => this.OnClickFileSelectBtn())

        PosY += 25
        PosX := 10
        this.PathTextCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 300))

        PosY += 25
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "支持文件后缀:exe、txt、bat、mp4等等")

        PosY += 40
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "进程、绝对路径两者只要填写其中一项就行")

        PosY += 25
        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        
        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 360, 320))
    }

    Init(cmd){
        this.ProcessName := ""
        this.Path := ""

        if (cmd != ""){
            cmdArr := StrSplit(cmd, "_")
            isPath := SubStr(cmdArr[2], 2, 1) == ":"
            if (isPath){
                this.Path := cmdArr[2]
            }
            else{
                this.ProcessName := cmdArr[2]
            }
        }

        this.ProcessTextCon.Value := this.ProcessName
        this.PathTextCon.Value := this.Path
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.RefreshAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.SureProcessName(), "On")
        }
        else {
            SetTimer this.RefreshAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.SureProcessName(), "Off")
        }
    }

    RefreshProcessName() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY, &winId
        processName := WinGetProcessName(winId)
        this.MouseProNameCon.Value := Format("当前鼠标下进程名:{}", processName)
    }

    SureProcessName() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY, &winId
        processName := WinGetProcessName(winId)
        this.ProcessTextCon.Value := processName
    }

    OnClickFileSelectBtn() {
        fileString := FileSelect("S1", "", "选择要运行的文件")
        if (fileString == "")
            return

        this.PathTextCon.Value := fileString
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.ToggleFunc(false)
        this.UpdateCommandStr()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid(){
        if (this.PathTextCon.Value == "" && this.ProcessTextCon.Value == ""){
            MsgBox("请输入进程名或者绝对路径！")
            Return false
        }
        Return true
    }

    UpdateCommandStr(){
        this.CommandStr := "文件_"
        if (this.PathTextCon.Value != ""){
            this.CommandStr .= this.PathTextCon.Value
        }
        else{
            this.CommandStr .= this.ProcessTextCon.Value
        }
    }

    TriggerMacro() {
        this.UpdateCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.ActionArr[1] := Map()

        OnRunFile(tableItem, this.CommandStr, 1)
    }
}
