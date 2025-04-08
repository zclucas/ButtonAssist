#Requires AutoHotkey v2.0

class MouseMoveGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.PosAction := () => this.RefreshMousePos()
        this.PosX := 0
        this.PosY := 0
        this.Speed := 0
        this.IsRelative := false
        this.IsOffset := false
        this.Count := 1
        this.PerInterval := 1000
        this.PosXCon := ""
        this.PosYCon := ""
        this.SpeedCon := ""
        this.CommandStr := ""
        this.CommandStrCon := ""
        this.RelativeCon := ""
        this.OffsetCon := ""
        this.CountCon := ""
        this.PerIntervalCon := ""

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
        this.Refresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "鼠标移动指令编辑")
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
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:选取当前坐标")

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

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "移动次数:")
        PosX += 80
        this.CountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), 1)
        this.CountCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "每次间隔:")
        PosX += 80
        this.PerIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), 1000)
        this.PerIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "90")
        this.SpeedCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 80
        this.RelativeCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "相对位移")
        this.RelativeCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosX += 100
        this.OffsetCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 150, 20), "游戏视角")
        this.OffsetCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosY += 40
        PosX := 10
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:MouseMove_0_0_0")

        PosY += 20
        PosX += 150
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 400, 255))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.PosX := cmdArr.Length >= 2 ? cmdArr[2] : 0
        this.PosY := cmdArr.Length >= 3 ? cmdArr[3] : 0
        this.Speed := cmdArr.Length >= 4 ? cmdArr[4] : 90
        this.IsRelative := cmdArr.Length >= 5 ? cmdArr[5] : 0
        this.IsOffset := cmdArr.Length >= 6 ? cmdArr[6] : 0
        this.Count := cmdArr.Length >= 7 ? cmdArr[7] : 1
        this.PerInterval := cmdArr.Length >= 8 ? cmdArr[8] : 1000

        this.PosXCon.Value := this.PosX
        this.PosYCon.Value := this.PosY
        this.CountCon.Value := this.Count
        this.PerIntervalCon.Value := this.PerInterval
        this.SpeedCon.Value := this.Speed
        this.RelativeCon.Value := this.IsRelative
        this.OffsetCon.Value := this.IsOffset
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

        if (!IsNumber(this.CountCon.Value) || Number(this.CountCon.Value) <= 0) {
            MsgBox("移动次数请输入大于0的数字")
            return false
        }

        if (IsInteger(this.SpeedCon.Value) && ((Integer(this.SpeedCon.Value) < 0 || Integer(this.SpeedCon.Value) > 100))) {
            MsgBox("移动速度请输入0~100的整数")
            return false
        }

        return true
    }

    UpdateCommandStr() {
        showCount := Number(this.CountCon.Value) > 1
        showState := this.RelativeCon.Value == 1 || this.OffsetCon.Value == 1 || showCount
        showSpeed := this.SpeedCon.Value != 100 || showState

        this.CommandStr := "移动"
        this.CommandStr .= "_" this.PosXCon.Value
        this.CommandStr .= "_" this.PosYCon.Value

        if (showSpeed) {
            this.CommandStr .= "_" this.SpeedCon.Value
        }

        if (showState) {
            this.CommandStr .= "_" this.RelativeCon.Value
            this.CommandStr .= "_" this.OffsetCon.Value
        }

        if (showCount) {
            this.CommandStr .= "_" this.CountCon.Value
            this.CommandStr .= "_" this.PerIntervalCon.Value
        }
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

    Refresh() {
        this.UpdateCommandStr()
        this.CommandStrCon.Value := "当前指令:" this.CommandStr
    }

    OnChangeEditValue() {
        this.PosX := this.PosXCon.Value
        this.PosY := this.PosYCon.Value
        this.Speed := this.SpeedCon.Value
        this.IsRelative := this.RelativeCon.Value
        this.IsOffset := this.OffsetCon.Value
        this.Count := this.CountCon.Value
        this.PerInterval := this.PerIntervalCon.Value
        this.Refresh()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        action := this.SureBtnAction
        action(this.CommandStr)
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
        tableItem.ActionArr[1] := Map()

        OnMouseMove(tableItem, this.CommandStr, 1)
    }

    SureCoord() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.PosXCon.Value := mouseX
        this.PosYCon.Value := mouseY
        this.PosX := this.PosXCon.Value
        this.PosY := this.PosYCon.Value
        this.Refresh()
    }

}
