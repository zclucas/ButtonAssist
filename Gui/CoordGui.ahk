#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class CoordGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.FocusCon := ""
        this.RemarkCon := ""
        this.Data := ""
        this.PosAction := () => this.RefreshMousePos()

        this.PosXCon := ""
        this.PosYCon := ""
        this.NameXCon := ""
        this.NameYCon := ""
        this.IsRelativeCon := ""
        this.isGameViewCon := ""
        this.SpeedCon := ""
        this.CountCon := ""
        this.IntervalCon := ""
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
        MyGui := Gui(, "搜索指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        ; this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        ; PosX += 80
        ; con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        ; con.Enabled := false

        ; PosX += 90
        ; btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        ; btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        ; PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:选取当前坐标")

        PosX := 10
        PosY += 20
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "当前鼠标位置:0,0")

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "坐标：选择/输入为空,则使用值，否则使用选择/输入的变量数值")

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "游戏视角：调整原神，cf等游戏视角、此模式下相对位移，速度100")

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置X:")
        PosX += 80
        this.PosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.NameXCon := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX + 55, PosY - 5, 100), [])

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置Y:")
        PosX += 80
        this.PosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.NameYCon := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX + 55, PosY - 5, 100), [])

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "移动次数:")
        PosX += 80
        this.CountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), 1)

        PosX += 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "每次间隔:")
        PosX += 80
        this.IntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), 1000)

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "90")

        PosX += 110
        this.IsRelativeCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "相对位移")

        PosX += 100
        this.IsGameViewCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 150, 20), "游戏视角")

        PosY += 35
        PosX := 175
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 450, 300))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.Data := this.GetCoordData(this.SerialStr)
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        this.PosXCon.Value := this.Data.PosX
        this.PosYCon.Value := this.Data.PosY
        this.NameXCon.Delete()
        this.NameXCon.Add(VariableObjArr)
        this.NameXCon.Text := this.Data.NameX
        this.NameYCon.Delete()
        this.NameYCon.Add(VariableObjArr)
        this.NameYCon.Text := this.Data.NameY
        this.IsRelativeCon.Value := this.Data.IsRelative
        this.isGameViewCon.Value := this.Data.IsGameView
        this.SpeedCon.Value := this.Data.Speed
        this.CountCon.Value := this.Data.Count
        this.IntervalCon.Value := this.Data.Interval
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "移动Pro_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    CheckIfValid() {
        return true
    }

    RefreshMousePos() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.MousePosCon.Value := "当前鼠标位置:" mouseX "," mouseY
    }

    ToggleFunc(state) {
        if (state) {
            SetTimer this.PosAction, 100
            Hotkey("F1", (*) => this.SureCoord(), "On")
        }
        else {
            SetTimer this.PosAction, 0
            Hotkey("F1", (*) => this.SureCoord(), "Off")
        }
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.SaveCoordData()
        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    SureCoord() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.PosXCon.Value := mouseX
        this.PosYCon.Value := mouseY
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Coord" CurrentDateTime
    }

    GetCoordData(SerialStr) {
        saveStr := IniRead(CoordFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := CoordData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveCoordData() {
        this.Data.PosX := this.PosXCon.Value
        this.Data.PosY := this.PosYCon.Value
        this.Data.NameX := this.NameXCon.Text
        this.Data.NameY := this.NameYCon.Text
        this.Data.IsRelative := this.IsRelativeCon.Value
        this.Data.IsGameView := this.isGameViewCon.Value
        this.Data.Speed := this.SpeedCon.Value
        this.Data.Count := this.CountCon.Value
        this.Data.Interval := this.IntervalCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, CoordFile, IniSection, this.Data.SerialStr)
    }
}
