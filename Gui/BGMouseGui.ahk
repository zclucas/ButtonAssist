#Requires AutoHotkey v2.0

class BGMouseGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.RemarkCon := ""
        this.RefreshInfoAction := () => this.RefreshInfo()

        this.CurTitleCon := ""
        this.CurPosCon := ""

        this.TargetTitleCon := ""
        this.OperateTypeCon := ""
        this.MouseTypeCon := ""
        this.PosXCon := ""
        this.PosYCon := ""
        this.PosXNameCon := ""
        this.PosYNameCon := ""
        this.ScrollVCon := ""
        this.ScrollHCon := ""
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
        this.OnRefresh()
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

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "F1:选取当前窗口标题   F2:选取当前窗口位置   F3:选取标题和位置")

        PosX := 10
        PosY += 20
        this.CurTitleCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "当前窗口标题:RMT")
        PosX := 10
        PosY += 20
        this.CurPosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "当前窗口坐标:0,0")

        PosX := 10
        PosY += 25
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "选择/输入为空时使用坐标数值，否则使用选择/输入的变量值")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "窗口标题:")
        PosX += 80
        this.TargetTitleCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 300), "")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "鼠标按键:")
        PosX += 80
        this.MouseTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 3, 70), ["左键", "中键", "右键",
            "滚轮"])
        this.MouseTypeCon.OnEvent("Change", (*) => this.OnRefresh())

        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "操作类型:")
        PosX += 80
        this.OperateTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 3, 100), ["点击", "双击", "按下",
            "松开"])

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "窗口坐标X:")
        PosX += 80
        this.PosXCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 70), "")
        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "选择/输入:")
        PosX += 80
        this.PosXNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY - 3, 100), [])

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "窗口坐标Y:")
        PosX += 80
        this.PosYCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 70), "")
        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "选择/输入:")
        PosX += 80
        this.PosYNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY - 3, 100), [])

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "垂直滚动:")
        PosX += 80
        this.ScrollVCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 70), "")
        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "水平滚动")
        PosX += 80
        this.ScrollHCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 100), "")

        PosX := 10
        PosY += 40
        con := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "点击时间:")
        con.Visible := false
        PosX += 80
        this.ClickTimeCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 70), "")
        this.ClickTimeCon.Visible := false

        ; PosY += 100
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 375))
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
        this.PosXCon.Value := this.Data.PosX
        this.PosYCon.Value := this.Data.PosY
        this.ClickTimeCon.Value := this.Data.ClickTime
        this.PosXNameCon.Delete()
        this.PosXNameCon.Add(VariableObjArr)
        this.PosXNameCon.Text := this.Data.PosXName
        this.PosYNameCon.Delete()
        this.PosYNameCon.Add(VariableObjArr)
        this.PosYNameCon.Text := this.Data.PosYName
        this.ScrollVCon.Value := this.Data.ScrollV
        this.ScrollHCon.Value := this.Data.ScrollH
    }

    OnRefresh() {
        isScroll := this.MouseTypeCon.Value == 4    ;滚轮
        this.OperateTypeCon.Enabled := !isScroll
        this.ScrollVCon.Enabled := isScroll
        this.ScrollHCon.Enabled := isScroll
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.RefreshInfoAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.OnF1(), "On")
            Hotkey("F2", (*) => this.OnF2(), "On")
            Hotkey("F3", (*) => this.OnF3(), "On")
        }
        else {
            SetTimer this.RefreshInfoAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.OnF1(), "Off")
            Hotkey("F2", (*) => this.OnF2(), "Off")
            Hotkey("F3", (*) => this.OnF3(), "Off")
        }
    }

    OnF1() {
        CoordMode("Mouse", "Window")
        MouseGetPos &mouseX, &mouseY, &winId
        this.TargetTitleCon.Value := WinGetTitle(winId)
    }

    OnF2() {
        PosArr := GetWinPos()
        this.PosXCon.Value := PosArr[1]
        this.PosYCon.Value := PosArr[2]
    }

    OnF3() {
        this.OnF1()
        this.OnF2()
    }

    RefreshInfo() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY, &oriId
        PosArr := GetWinPos()

        this.CurPosCon.Value := "当前窗口坐标: " PosArr[1] "," PosArr[2]
        this.CurTitleCon.Value := "当前窗口标题: " WinGetTitle(oriId)

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
        if (this.TargetTitleCon.Value == "") {
            MsgBox("目标窗口标题不能为空")
            return false
        }
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
        this.Data.ScrollV := this.ScrollVCon.Value
        this.Data.ScrollH := this.ScrollHCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, BGMouseFile, IniSection, this.Data.SerialStr)
    }
}
