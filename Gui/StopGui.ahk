#Requires AutoHotkey v2.0

class StopGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""

        this.StopTypeCon := ""
        this.StopIndexCon := ""
        this.StopSelfCon := ""
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
        MyGui := Gui(, "停止指令编辑")
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

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "宏类型:")

        PosX += 80
        this.StopTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["按键宏", "字串宏"])
        this.StopTypeCon.Value := 1

        PosX += 140
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏序号：")

        PosX += 80
        MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "1")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "输入的文本")

        PosY += 20
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 480, 50))

        PosY += 80
        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 280))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetStopData(this.SerialStr)

        this.TextCon.Value := this.Data.Text
        this.StopTypeCon.Value := this.Data.InputType
        this.StopSelfCon.Value := this.Data.IsCover
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
        }
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveInputData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        return true
    }

    TriggerMacro() {
        this.SaveInputData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.ActionArr[1] := Map()

        OnInput(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "输入_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Stop" CurrentDateTime
    }

    GetStopData(SerialStr) {
        saveStr := IniRead(StopFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := InputData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveInputData() {
        this.Data.Text := this.TextCon.Value
        this.Data.InputType := this.StopTypeCon.Value
        this.Data.IsCover := this.StopSelfCon.value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, InputFile, IniSection, this.Data.SerialStr)
    }
}
