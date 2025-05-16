#Requires AutoHotkey v2.0

class FileGui {
    __new() {
        this.Gui := ""
        this.RemarkCon := ""
        this.SureBtnAction := ""
        this.ProcessTextCon := ""
        this.PathTextCon := ""
        this.MouseProNameCon := ""
        this.BackPlayCon := ""

        this.RefreshAction := () => this.RefreshProcessName()
        this.Data := ""
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
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S10 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:确定鼠标下进程")

        PosX := 10
        PosY += 20
        this.MouseProNameCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "鼠标下进程名:Zone.exe")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "进程(系统软件，等通过安装的软件)")

        PosY += 20
        this.ProcessTextCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY, 400))

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "绝对路径")

        PosX += 80
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 2, 70, 20), "选择文件")
        btnCon.OnEvent("Click", (*) => this.OnClickFileSelectBtn())

        PosY += 20
        PosX := 10
        this.PathTextCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 400))

        PosY += 25
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "支持文件后缀:exe、txt、bat、mp4、vbs、mp3等等")

        PosX := 10
        PosY += 25
        this.BackPlayCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 400), "后台播放mp3文件")

        PosY += 45
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 400, 20), "进程、绝对路径两者只要填写其中一项就行")

        PosY += 25
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 340))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetFileData(this.SerialStr)

        this.ProcessTextCon.Value := this.Data.ProcessName
        this.PathTextCon.Value := this.Data.FilePath
        this.BackPlayCon.Value := this.Data.BackPlay
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "文件_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
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
        this.SaveFileData()
        this.ToggleFunc(false)
        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.Gui.Hide()
    }

    CheckIfValid() {
        if (this.PathTextCon.Value == "" && this.ProcessTextCon.Value == "") {
            MsgBox("请输入进程名或者绝对路径！")
            return false
        }
        return true
    }

    TriggerMacro() {
        this.SaveFileData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnRunFile(tableItem, this.GetCommandStr(), 1)
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "File" CurrentDateTime
    }

    GetFileData(SerialStr) {
        saveStr := IniRead(FileFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := FileData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveFileData() {
        this.Data.ProcessName := this.ProcessTextCon.Value
        this.Data.FilePath := this.PathTextCon.Value
        this.Data.BackPlay := this.BackPlayCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, FileFile, IniSection, this.Data.SerialStr)
    }
}
