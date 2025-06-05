#Requires AutoHotkey v2.0

class MouseMoveGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.PosAction := () => this.RefreshMousePos()

        this.PosXCon := ""
        this.PosYCon := ""
        this.SpeedCon := ""
        this.IsRelativeCon := ""
        this.CommandStrCon := ""
        this.MousePosCon := ""
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
        MyGui := Gui(, "鼠标移动指令编辑")
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

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "F1:选取当前坐标")

        PosX := 10
        PosY += 20
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "当前鼠标位置:0,0")

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置X:")
        PosX += 80
        this.PosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.PosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置Y:")
        PosX += 80
        this.PosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.PosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 40
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "90")
        this.SpeedCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 80
        this.IsRelativeCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "相对位移")
        this.IsRelativeCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosY += 40
        PosX := 10
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "MouseMove_0_0_0")

        PosY += 25
        PosX += 150
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 400, 240))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        PosX := cmdArr.Length >= 2 ? cmdArr[2] : 0
        PosY := cmdArr.Length >= 3 ? cmdArr[3] : 0
        Speed := cmdArr.Length >= 4 ? cmdArr[4] : 90
        IsRelative := cmdArr.Length >= 5 ? cmdArr[5] : 0

        this.PosXCon.Value := PosX
        this.PosYCon.Value := PosY
        this.SpeedCon.Value := Speed
        this.IsRelativeCon.Value := IsRelative
        this.UpdateCommandStr()
    }

    CheckIfValid() {
        if (!IsNumber(this.PosXCon.Value)) {
            MsgBox("坐标X请输入数字")
            return false
        }

        if (!IsNumber(this.PosYCon.Value)) {
            MsgBox("坐标Y请输入数字")
            return false
        }

        if (!IsInteger(this.SpeedCon.Value)) {
            MsgBox("移动速度请输入整数")
            return false
        }

        return true
    }

    UpdateCommandStr() {
        showRelative := this.IsRelativeCon.Value == 1
        showSpeed := showRelative || this.SpeedCon.Value != 100

        CommandStr := "移动"
        CommandStr .= "_" this.PosXCon.Value
        CommandStr .= "_" this.PosYCon.Value

        if (showSpeed) {
            CommandStr .= "_" this.SpeedCon.Value
        }
        if (showRelative) {
            CommandStr .= "_" this.IsRelativeCon.Value
        }

        this.CommandStrCon.Value := CommandStr
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.PosAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.SureCoord(), "On")
        }
        else {
            SetTimer this.PosAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.SureCoord(), "Off")
        }
    }

    RefreshMousePos() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.MousePosCon.Value := "当前鼠标位置:" mouseX "," mouseY
    }

    OnChangeEditValue() {
        this.UpdateCommandStr()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        action := this.SureBtnAction
        action(this.CommandStrCon.Value)
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnMouseMove(tableItem, this.CommandStrCon.Value, 1)
    }

    SureCoord() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.PosXCon.Value := mouseX
        this.PosYCon.Value := mouseY
        this.UpdateCommandStr()
    }

}
