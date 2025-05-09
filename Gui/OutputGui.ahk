#Requires AutoHotkey v2.0

class OutputGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.MacroEditGui := ""
        this.OutputTypeCon := ""
        this.TextCon := ""
        this.IsCoverCon := ""
        this.NameCon := ""
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
        MyGui := Gui(, "输出指令编辑")
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
        PosY += 25
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "选择/输入为空时输出文本，否则输出选择/输入的变量值")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "输出方式:")

        PosX += 80
        this.OutputTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["SendText",
            "Send粘贴", "Win粘贴"])
        this.OutputTypeCon.Value := 1

        PosX += 140
        this.IsCoverCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 200), "输出内容复制到剪切板")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "文本                              选择/输入")

        PosY += 20
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 200, 50))

        PosX += 240
        this.NameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY, 100), [])

        PosY += 80
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 270))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetOutputData(this.SerialStr)
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableArr := GetSelectVariableObjArr(macro)
        this.TextCon.Value := this.Data.Text
        this.OutputTypeCon.Value := this.Data.OutputType
        this.IsCoverCon.Value := this.Data.IsCover
        this.NameCon.Delete()
        this.NameCon.Add(VariableArr)
        this.NameCon.Text := this.Data.Name
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
        this.SaveOutputData()
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
        this.SaveOutputData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnOutput(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "输出_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Output" CurrentDateTime
    }

    GetOutputData(SerialStr) {
        saveStr := IniRead(OutputFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := OutputData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveOutputData() {
        this.Data.Text := this.TextCon.Value
        this.Data.OutputType := this.OutputTypeCon.Value
        this.Data.IsCover := this.IsCoverCon.value
        this.Data.Name := this.NameCon.Text

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, OutputFile, IniSection, this.Data.SerialStr)
    }
}
