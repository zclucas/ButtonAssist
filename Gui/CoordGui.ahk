#Requires AutoHotkey v2.0
#Include MacroGui.ahk
#Include OperationGui.ahk

class CoordGui {
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

        this.SerialStr := ""

        this.SearchCount := 1
        this.SearchCountCon := ""
        this.SearchInterval := 0
        this.SearchIntervalCon := ""

        this.CommandStr := ""
        this.CommandStrCon := ""

        this.IsRelativeCon := ""
        this.SpeedCon := ""

        this.coordData := ""
        this.VariableFilterCon := ""
        this.ExtractTypeCon := ""
        this.VariableOperatorConArr := []

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
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 60, 20), "快捷方式:")
        PosX += 60
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
        "使用x、y代替变量位置   形如：`"坐标(x,y)`"可以提取`"坐标(10.5,8.6)`"中的10.5和8.6")

        PosY += 25
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

        
        EndSplitPosY := PosY + 30

        PosY := SplitPosY
        PosX := 200
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
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 75, PosY - 5, 50))
        this.SearchCountCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        MyGui.Add("Text", Format("x{} y{} w{}", PosX + 180, PosY, 120), "移动速度(0~100):")
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 290, PosY - 5, 50), "90")
        this.SpeedCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 75, PosY - 5, 50))
        this.SearchIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        this.IsRelativeCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX + 180, PosY - 5, 120), "相对位移")
        this.IsRelativeCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosY := EndSplitPosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:（若未提取到变量，则不执行任何指令）")
        PosY += 25
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 550))

        PosY += 40
        PosX += 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 600, 380))
    }

    Init(cmd) {
        searchCmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        VariableFilterText := searchCmdArr.Length >= 1 ? searchCmdArr[2] : "坐标（x，y）"

        this.StartPosX := searchCmdArr.Length >= 3 ? searchCmdArr[3] : 0
        this.StartPosY := searchCmdArr.Length >= 4 ? searchCmdArr[4] : 0
        this.EndPosX := searchCmdArr.Length >= 5 ? searchCmdArr[5] : A_ScreenWidth
        this.EndPosY := searchCmdArr.Length >= 6 ? searchCmdArr[6] : A_ScreenHeight
        this.SerialStr := searchCmdArr.Length >= 7 ? searchCmdArr[7] : this.GetSerialStr()
        this.SearchCount := searchCmdArr.Length >= 8 ? searchCmdArr[8] : 1
        this.SearchInterval := searchCmdArr.Length >= 9 ? searchCmdArr[9] : 1000

        this.VariableFilterCon.Value := VariableFilterText
        this.StartPosXCon.Value := this.StartPosX
        this.StartPosYCon.Value := this.StartPosY
        this.EndPosXCon.Value := this.EndPosX
        this.EndPosYCon.Value := this.EndPosY
        this.SearchCountCon.Value := this.SearchCount
        this.SearchIntervalCon.Value := this.SearchInterval

        this.coordData := this.GetCoordData(this.SerialStr)
        this.ExtractTypeCon.Value := this.coordData.ExtractType
        this.SpeedCon.Value := this.coordData.Speed
        this.IsRelativeCon.Value := this.coordData.isRelative
        loop 2 {
            this.VariableOperatorConArr[A_Index].Value := this.coordData.VariableOperatorArr[A_Index]
        }
    }

    UpdateCommandStr() {
        this.CommandStr := "坐标"
        this.CommandStr .= "_" this.VariableFilterCon.Value
        this.CommandStr .= "_" this.StartPosXCon.Value
        this.CommandStr .= "_" this.StartPosYCon.Value
        this.CommandStr .= "_" this.EndPosXCon.Value
        this.CommandStr .= "_" this.EndPosYCon.Value
        this.CommandStr .= "_" this.SerialStr
        if (Number(this.SearchCountCon.Value) > 1) {
            this.CommandStr .= "_" this.SearchCountCon.Value
            this.CommandStr .= "_" this.SearchIntervalCon.Value
        }
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
        this.Refresh()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        this.SaveCoordData()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.ToggleFunc(false)
        this.Gui.Hide()
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

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        this.SaveCoordData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.ActionArr[1] := Map()
        OnCoord(tableItem, this.CommandStr, 1)
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
        data := this.coordData
        data.SerialStr := this.SerialStr
        data.TextFilter := this.VariableFilterCon.Value
        data.ExtractType := this.ExtractTypeCon.Value
        data.isRelative := this.IsRelativeCon.Value
        data.Speed := Number(this.SpeedCon.Value)

        data.VariableOperatorArr := []
        loop 2 {
            data.VariableOperatorArr.Push(this.VariableOperatorConArr[A_Index].Value)
        }

        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, CoordFile, IniSection, data.SerialStr)
    }
}
