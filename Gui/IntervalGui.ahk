#Requires AutoHotkey v2.0

class IntervalGui {
    __new() {
        this.Gui := ""
        this.MacroEditGui := ""
        this.SureBtnAction := ""
        this.TimeTextCon := ""
        this.TimeVarCon := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init(cmd)
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        this.TimeVarCon.Delete()
        this.TimeVarCon.Add(VariableObjArr)
        this.TimeVarCon.Text := "空"
        if (cmdArr.Length == 2) {
            this.TimeTextCon.Value := cmdArr[2]
        }
        else if (cmdArr.Length == 3) {
            this.TimeVarCon.Text := cmdArr[3]
        }
        else {
            this.TimeTextCon.Value := "200"
        }
    }

    AddGui() {
        MyGui := Gui(, "指令间隔编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S10 W550 Q2", "Consolas")

        PosY := 10
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 320), "时间：选择/输入为空则使用值，否则使用选择/输入的变量数值")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "                  值         选择/输入")

        PosX := 10
        PosY += 20
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 90, 20), "时间(毫秒)：")

        PosX += 90
        this.TimeTextCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 2, 80))

        PosX += 90
        this.TimeVarCon := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX, PosY - 2, 100), [])

        PosY += 40
        PosX := 130
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.Show(Format("w{} h{}", 360, 150))
    }

    OnClickSureBtn() {
        if (this.SureBtnAction == "")
            return

        timeText := this.TimeTextCon.Value
        if (this.TimeVarCon.Text == "空") {
            if (!IsInteger(timeText) || Integer(timeText) < 0) {
                MsgBox("请输入大于等于0的整数")
                return
            }
        }

        action := this.SureBtnAction
        action(this.GetCmdStr())
        this.Gui.Hide()
    }

    GetCmdStr() {
        if (this.TimeVarCon.Text == "空") {
            return "间隔_" this.TimeTextCon.Value
        }

        return "间隔_变量_" this.TimeVarCon.Text
    }
}
