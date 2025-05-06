#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk
#Include OperationGui.ahk

class CompareGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""

        this.Data := ""
        this.ToggleConArr := []
        this.NameConArr := []
        this.CompareTypeConArr := []
        this.ValueConArr := []
        this.VariableConArr := []
        this.TrueMacroCon := ""
        this.FalseMacroCon := ""
        this.SaveToggleCon := ""
        this.SaveNameCon := ""
        this.TrueValueCon := ""
        this.FalseValueCon := ""
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
        MyGui := Gui(, "搜索指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "选框勾选后,对应比较生效、勾选之间是且关系")

        PosY += 30
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)
        con.Value := 1
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "x:")
        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ValueConArr.Push(con)

        PosX := 240
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ToggleConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "y:")
        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ValueConArr.Push(con)

        PosY += 30
        PosX := 10
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ToggleConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "z:")
        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ValueConArr.Push(con)

        PosX := 240
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ToggleConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "w:")
        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ValueConArr.Push(con)

        PosY += 30
        PosX := 10
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 180), "找到后鼠标移动至文本处")
        con.OnEvent("Click", (*) => this.OnChangeAutoMove())
        this.AutoMoveCon := con

        PosY += 30
        PosX := 10
        SplitPosY := PosY
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 160, 20), "结果真的指令:（可选）")

        PosX += 160
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())

        PosY += 20
        PosX := 10
        this.TrueCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 50), "")
        this.TrueCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY := SplitPosY
        PosX := 310
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 160, 20), "结果假的指令:（可选）")

        PosX += 160
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditUnFoundMacroBtnClick())

        PosY += 20
        PosX := 310
        this.FalseCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 50), "")
        this.FalseCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX := 10
        PosY += 55
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:（若未提取到变量，则不执行任何指令）")
        PosY += 25
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 550))

        PosY += 30
        PosX += 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 600, 600))
    }

    Init(cmd) {
        searchCmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := searchCmdArr.Length >= 2 ? searchCmdArr[2] : this.GetSerialStr()
        this.compareData := this.GetCompareData(this.SerialStr)
        this.VariableFilterCon.Value := this.compareData.TextFilter
        this.StartPosXCon.Value := this.compareData.StartPosX
        this.StartPosYCon.Value := this.compareData.StartPosY
        this.EndPosXCon.Value := this.compareData.EndPosX
        this.EndPosYCon.Value := this.compareData.EndPosY
        this.SearchCountCon.Value := this.compareData.SearchCount
        this.SearchIntervalCon.Value := this.compareData.SearchInterval
        this.AutoMoveCon.Value := this.compareData.AutoMove
        this.TrueCommandStrCon.Value := this.compareData.TrueCommandStr
        this.FalseCommandStrCon.Value := this.compareData.FalseCommandStr
        this.ExtractTypeCon.Value := this.compareData.ExtractType
        loop 4 {
            this.CompareTypeConArr[A_Index].Value := this.compareData.VariableOperatorArr[A_Index]
            this.ToggleConArr[A_Index].Value := this.compareData.ComparToggleArr[A_Index]
            this.ValueConArr[A_Index].Value := this.compareData.ComparValueArr[A_Index]
            this.ComparTypeConArr[A_Index].Value := this.compareData.ComparTypeArr[A_Index]
        }
    }

    UpdateCommandStr() {
        this.CommandStr := "比较"
        this.CommandStr .= "_" this.SerialStr
    }

    CheckIfValid() {
        if (!IsNumber(this.StartPosXCon.Value) || !IsNumber(this.StartPosYCon.Value) || !IsNumber(this.EndPosXCon.Value
        ) || !IsNumber(this.EndPosYCon.Value)) {
            MsgBox("坐标中请输入数字")
            return false
        }

        if (Number(this.StartPosXCon.Value) > Number(this.EndPosXCon.Value) || Number(this.StartPosYCon.Value) > Number(
            this.EndPosYCon.Value)) {
            MsgBox("起始坐标不能大于终止坐标")
            return false
        }

        if (!IsNumber(this.SearchCountCon.Value) || Number(this.SearchCountCon.Value) <= 0) {
            MsgBox("搜索次数请输入大于0的数字")
            return false
        }

        return true
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.EnableSelectAerea(), "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.EnableSelectAerea(), "Off")
        }
    }

    Refresh() {
        this.UpdateCommandStr()
        this.CommandStrCon.Value := this.CommandStr
    }

    OnChangeEditValue() {
        this.StartPosX := this.StartPosXCon.Value
        this.StartPosY := this.StartPosYCon.Value
        this.EndPosX := this.EndPosXCon.Value
        this.EndPosY := this.EndPosYCon.Value
        this.SearchCount := this.SearchCountCon.Value
        this.SearchInterval := this.SearchIntervalCon.Value
        this.TrueCommandStr := this.TrueCommandStrCon.Value
        this.FalseCommandStr := this.FalseCommandStrCon.Value
        this.Refresh()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        this.SaveCompareData()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    OnSureFoundMacroBtnClick(CommandStr) {
        this.TrueCommandStr := CommandStr
        this.TrueCommandStrCon.Value := CommandStr
        this.Refresh()
    }

    OnSureUnFoundMacroBtnClick(CommandStr) {
        this.FalseCommandStr := CommandStr
        this.FalseCommandStrCon.Value := CommandStr
        this.Refresh()
    }

    OnSureVariableOperationBtnClick(index, command) {
        con := this.CompareTypeConArr[index]
        con.Value := command
        this.Refresh()
    }

    ; OnEditVariableBtnClick(index, variableStr) {
    ;     if (this.OperationGui == "") {
    ;         this.OperationGui := OperationGui()
    ;         this.OperationGui.SureFocusCon := this.Gui
    ;     }

    ;     this.OperationGui.SureBtnAction := (index, variableStr, command) => this.OnSureVariableOperationBtnClick(index,
    ;         command)
    ;     this.OperationGui.ShowGui(index, variableStr, this.CompareTypeConArr[index].Value)
    ; }

    OnEditFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.FocusCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnSureFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.TrueCommandStr, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.FocusCon
        }
        this.MacroGui.SureBtnAction := (command) => this.OnSureUnFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.FalseCommandStr, false)
    }

    OnChangeAutoMove() {
        this.AutoMove := this.AutoMoveCon.Value
        this.Refresh()
    }

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        this.SaveCompareData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()
        OnCompare(tableItem, this.CommandStr, 1)
    }

    EnableSelectAerea() {
        Hotkey("LButton", (*) => this.SelectArea(), "On")
        Hotkey("LButton Up", (*) => this.DisSelectArea(), "On")
    }

    DisSelectArea(*) {
        Hotkey("LButton", (*) => this.SelectArea(), "Off")
        Hotkey("LButton Up", (*) => this.DisSelectArea(), "Off")
    }

    SelectArea(*) {
        ; 获取起始点坐标
        startX := startY := endX := endY := 0
        CoordMode("Mouse", "Screen")
        MouseGetPos(&startX, &startY)

        ; 创建 GUI 用于绘制矩形框
        MyGui := Gui("+ToolWindow -Caption +AlwaysOnTop -DPIScale")
        MyGui.BackColor := "Red"
        WinSetTransColor(" 150", MyGui)
        MyGui.Opt("+LastFound")
        GuiHwnd := WinExist()

        ; 显示初始 GUI
        MyGui.Show("NA x" startX " y" startY " w1 h1")

        ; 跟踪鼠标移动
        while GetKeyState("LButton", "P") {
            CoordMode("Mouse", "Screen")
            MouseGetPos(&endX, &endY)
            width := Abs(endX - startX)
            height := Abs(endY - startY)
            x := Min(startX, endX)
            y := Min(startY, endY)

            MyGui.Show("NA x" x " y" y " w" width " h" height)
        }
        ; 销毁 GUI
        MyGui.Destroy()
        ; 返回坐标

        this.StartPosXCon.Value := Min(startX, endX)
        this.StartPosYCon.Value := Min(startY, endY)
        this.EndPosXCon.Value := Max(startX, endX)
        this.EndPosYCon.Value := Max(startY, endY)
        this.Refresh()
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Compare" CurrentDateTime
    }

    GetCompareData(SerialStr) {
        saveStr := IniRead(CompareFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := CompareData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveCompareData() {
        data := this.compareData
        data.SerialStr := this.SerialStr
        data.StartPosX := this.StartPosXCon.Value
        data.StartPosY := this.StartPosYCon.Value
        data.EndPosX := this.EndPosXCon.Value
        data.EndPosY := this.EndPosYCon.Value
        data.SearchCount := this.SearchCountCon.Value
        data.SearchInterval := this.SearchIntervalCon.Value
        data.AutoMove := this.AutoMoveCon.Value

        data.TextFilter := this.VariableFilterCon.Value
        data.TrueCommandStr := this.TrueCommandStrCon.Value
        data.FalseCommandStr := this.FalseCommandStrCon.Value
        data.ExtractType := this.ExtractTypeCon.Value

        data.VariableOperatorArr := []
        data.ComparToggleArr := []
        data.ComparValueArr := []
        data.ComparTypeArr := []
        loop 4 {
            data.VariableOperatorArr.Push(this.CompareTypeConArr[A_Index].Value)
            data.ComparToggleArr.Push(this.ToggleConArr[A_Index].Value)
            data.ComparTypeArr.Push(this.ComparTypeConArr[A_Index].Value)
            compareValue := this.ValueConArr[A_Index].Value
            compareValue := IsFloat(compareValue) ? Format("{:.4g}", compareValue) : compareValue
            compareValue := IsInteger(compareValue) ? Integer(compareValue) : compareValue
            data.ComparValueArr.Push(compareValue)
        }

        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, CompareFile, IniSection, data.SerialStr)
    }
}
