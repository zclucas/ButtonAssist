#Requires AutoHotkey v2.0

class BGMouseGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.RemarkCon := ""

        this.TargetTitleCon := ""
        this.OperateTypeCon := ""
        this.MouseTypeCon := ""
        this.PosXCon := ""
        this.PosYCon := ""
        this.PosXNameCon := ""
        this.PosYNameCon := ""
        this.ClickTimeCon := ""
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
        MyGui := Gui(, "后台鼠标指令编辑")
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

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "窗口标题:")
        PosX += 80
        this.TargetTitleCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 220), "")

        ; PosX += 70
        ; this.BGMouseTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["当前宏", "按键宏",
        ;     "字串宏",
        ;     "宏"])
        ; this.BGMouseTypeCon.Value := 1
        ; this.BGMouseTypeCon.OnEvent("Change", (*) => this.OnRefresh())

        ; PosX += 160
        ; MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏序号：")

        ; PosX += 70
        ; this.BGMouseIndexCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "1")

        PosY += 100
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 240))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetBGMouseData(this.SerialStr)
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        this.TargetTitleCon.Value := this.Data.TargetTitle
        this.OperateTypeCon.Value := this.Data.OperateType
        this.MouseTypeCon.Value := this.Data.MouseType
        this.PosXCon := this.Data.PosX
        this.PosYCon := this.Data.PosY
        this.ClickTimeCon.Value := this.Data.ClickTime
        this.PosXNameCon.Delete()
        this.PosXNameCon.Add(VariableObjArr)
        this.PosXNameCon.Text := this.Data.PosXName
        this.PosYNameCon.Delete()
        this.PosYNameCon.Add(VariableObjArr)
        this.PosYNameCon.Text := this.Data.PosYName
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
        this.SaveBGMouseData()
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
        this.SaveBGMouseData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnBGMouse(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "后台鼠标_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "BGMouse" CurrentDateTime
    }

    GetBGMouseData(SerialStr) {
        saveStr := IniRead(BGMouseFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := BGMouseData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveBGMouseData() {
        this.Data.TargetTitle := this.TargetTitleCon.Value
        this.Data.OperateType := this.OperateTypeCon.Value
        this.Data.MouseType := this.MouseTypeCon.Value
        this.Data.PosX := this.PosXCon.Value
        this.Data.PosY := this.PosYCon.Value
        this.Data.PosXName := this.PosXNameCon.Text
        this.Data.PosYName := this.PosYNameCon.Text
        this.Data.ClickTime := this.ClickTimeCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, BGMouseFile, IniSection, this.Data.SerialStr)
    }
}
