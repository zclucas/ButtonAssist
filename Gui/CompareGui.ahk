#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk
#Include OperationGui.ahk

class CompareGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.FocusCon := ""

        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := 0
        this.EndPosY := 0

        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""

        this.AutoMove := 1
        this.AutoMoveCon := ""

        this.SerialStr := ""

        this.SearchCount := 1
        this.SearchCountCon := ""
        this.SearchInterval := 0
        this.SearchIntervalCon := ""

        this.TrueCommandStr := ""
        this.TrueCommandStrCon := ""

        this.FalseCommandStr := ""
        this.FalseCommandStrCon := ""

        this.CommandStr := ""
        this.CommandStrCon := ""

        this.compareData := ""
        this.VariableFilterCon := ""
        this.ExtractTypeCon := ""
        this.VariableMap := Map(1, false, 2, false, 3, false, 4, false)
        this.VariableOperatorConArr := []
        this.ComparValueConArr := []
        this.ComparEnableConArr := []
        this.ComparTypeConArr := []

        this.MacroGui := ""
        this.OperationGui := ""
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

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:选取搜索范围")

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 550),
        "使用x、y、z、w代替变量位置   形如：`"坐标(x,y)`"可以提取`"坐标(10.5,8.6)`"中的10.5和8.6")

        PosY += 35
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "变量提取：")
        this.VariableFilterCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 75, PosY - 5, 250), "")
        this.ExtractTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 345, PosY - 5, 80), ["屏幕", "剪切板"])
        this.ExtractTypeCon.Value := 1

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "搜索范围:")
        SplitPosY := PosY

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
        PosX += 75
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.StartPosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
        PosX += 75
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.StartPosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
        PosX += 75
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.EndPosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
        PosX += 75
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.EndPosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        PosX += 75
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.SearchCountCon.OnEvent("Change", (*) => this.OnChangeEditValue())
        EndSplitPosY := PosY + 30

        PosY := SplitPosY
        PosX := 240
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "变量更新:")

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "x:")
        con := MyGui.Add("Edit", Format("x{} y{} w{} ", PosX + 20, PosY - 5, 200), "x")
        con.Enabled := false
        this.VariableOperatorConArr.Push(con)
        con := MyGui.Add("Button", Format("x{} y{} w{} ", PosX + 230, PosY - 5, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(1, "x"))

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "y:")
        con := MyGui.Add("Edit", Format("x{} y{} w{} ", PosX + 20, PosY - 5, 200), "y")
        con.Enabled := false
        this.VariableOperatorConArr.Push(con)
        con := MyGui.Add("Button", Format("x{} y{} w{} ", PosX + 230, PosY - 5, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(2, "y"))

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "z:")
        con := MyGui.Add("Edit", Format("x{} y{} w{} ", PosX + 20, PosY - 5, 200), "z")
        con.Enabled := false
        this.VariableOperatorConArr.Push(con)
        con := MyGui.Add("Button", Format("x{} y{} w{} ", PosX + 230, PosY - 5, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(3, "z"))

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "w:")
        con := MyGui.Add("Edit", Format("x{} y{} w{} ", PosX + 20, PosY - 5, 200), "w")
        con.Enabled := false
        this.VariableOperatorConArr.Push(con)
        con := MyGui.Add("Button", Format("x{} y{} w{} ", PosX + 230, PosY - 5, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(4, "w"))

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 75, PosY - 5, 50))
        this.SearchIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY := EndSplitPosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "选框勾选后,对应比较生效      对比对象可以是任意自然数或变量:x、y、z、w")

        PosY += 30
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ComparEnableConArr.Push(con)
        con.Value := 1
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "x:")
        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于", "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ComparValueConArr.Push(con)

        PosX := 240
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ComparEnableConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "y:")
        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于", "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ComparValueConArr.Push(con)

        PosY += 30
        PosX := 10
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ComparEnableConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "z:")
        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于", "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ComparValueConArr.Push(con)

        PosX := 240
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        con.Value := 0
        this.ComparEnableConArr.Push(con)
        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 30, PosY, 20), "w:")
        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 50, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于", "小于"])
        con.Value := 1
        this.ComparTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 50), 0)
        this.ComparValueConArr.Push(con)

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
            this.VariableOperatorConArr[A_Index].Value := this.compareData.VariableOperatorArr[A_Index]
            this.ComparEnableConArr[A_Index].Value := this.compareData.ComparEnableArr[A_Index]
            this.ComparValueConArr[A_Index].Value := this.compareData.ComparValueArr[A_Index]
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
        con := this.VariableOperatorConArr[index]
        con.Value := command
        this.Refresh()
    }

    OnEditVariableBtnClick(index, variableStr) {
        if (this.OperationGui == "") {
            this.OperationGui := OperationGui()
            this.OperationGui.SureFocusCon := this.Gui
        }

        this.OperationGui.SureBtnAction := (index, variableStr, command) => this.OnSureVariableOperationBtnClick(index,
            command)
        this.OperationGui.ShowGui(index, variableStr, this.VariableOperatorConArr[index].Value)
    }

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
        tableItem.ActionArr[1] := Map()
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
        data.ComparEnableArr := []
        data.ComparValueArr := []
        data.ComparTypeArr := []
        loop 4 {
            data.VariableOperatorArr.Push(this.VariableOperatorConArr[A_Index].Value)
            data.ComparEnableArr.Push(this.ComparEnableConArr[A_Index].Value)
            data.ComparTypeArr.Push(this.ComparTypeConArr[A_Index].Value)
            compareValue := this.ComparValueConArr[A_Index].Value
            compareValue := IsFloat(compareValue) ? Format("{:.4g}", compareValue) : compareValue
            compareValue := IsInteger(compareValue) ? Integer(compareValue) : compareValue
            data.ComparValueArr.Push(compareValue)
        }

        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, CompareFile, IniSection, data.SerialStr)
    }
}
