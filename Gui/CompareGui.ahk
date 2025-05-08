#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class CompareGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.RemarkCon := ""
        this.CommandStr := ""
        this.FocusCon := ""

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
        ; this.ToggleFunc(true)
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
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "选框勾选且第一个选择/输入不为空对应比较生效、勾选之间是且关系")
    
        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 500), "若第二个选择/输入为空,则比较值，否则与第二个选择/输入的变量比较")
    
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "开关  选择/输入                     值       选择/输入")

        PosY += 20
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)
        con.Value := 1

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 135, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.CompareTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 3, 70), 0)
        this.ValueConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 295, PosY - 3, 100), [])
        this.VariableConArr.Push(con)

        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY - 3, 30))
        this.ToggleConArr.Push(con)
        con.Value := 1

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 135, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.CompareTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 3, 70), 0)
        this.ValueConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 295, PosY - 3, 100), [])
        this.VariableConArr.Push(con)

        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)
        con.Value := 1

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 135, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.CompareTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 3, 70), 0)
        this.ValueConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 295, PosY - 3, 100), [])
        this.VariableConArr.Push(con)

        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)
        con.Value := 1

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 135, PosY - 3, 80), ["大于", "大于等于", "等于", "小于等于",
            "小于"])
        con.Value := 1
        this.CompareTypeConArr.Push(con)
        con := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 3, 70), 0)
        this.ValueConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 295, PosY - 3, 100), [])
        this.VariableConArr.Push(con)

        PosY += 30
        PosX := 10
        SplitPosY := PosY
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 160, 20), "结果真的指令:（可选）")

        PosX += 160
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())

        PosY += 20
        PosX := 10
        this.TrueMacroCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 50), "")

        PosY := SplitPosY
        PosX := 310
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 160, 20), "结果假的指令:（可选）")

        PosX += 160
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditUnFoundMacroBtnClick())

        PosY += 20
        PosX := 310
        this.FalseMacroCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 50), "")
    
        PosY += 60
        PosX := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 320, 70), "结果保存到变量中")
    
        PosY += 20
        PosX := 15
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 290), "开关    选择/输入      真值        假值")
        
        PosY += 20
        PosX := 20
        this.SaveToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.SaveNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.TrueValueCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 70), 0)
        this.FalseValueCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 4, 70), 0)

        PosY += 40
        PosX := 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        ; MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 600, 450))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetCompareData(this.SerialStr)
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        this.TrueMacroCon.Value := this.Data.TrueMacro
        this.FalseMacroCon.Value := this.Data.FalseMacro
        this.SaveToggleCon.Value := this.Data.SaveToggle
        this.SaveNameCon.Delete()
        this.SaveNameCon.Add(VariableObjArr)
        this.SaveNameCon.Text := this.Data.SaveName
        this.TrueValueCon.Value := this.Data.TrueValue
        this.FalseValueCon.Value := this.Data.FalseValue
        loop 4 {
            this.ToggleConArr[A_Index].Value := this.Data.ToggleArr[A_Index]
            this.NameConArr[A_Index].Delete()
            this.NameConArr[A_Index].Add(VariableObjArr)
            this.NameConArr[A_Index].Text := this.Data.NameArr[A_Index]
            this.CompareTypeConArr[A_Index].Value := this.Data.CompareTypeArr[A_Index]
            this.ValueConArr[A_Index].Value := this.Data.ValueArr[A_Index]
            this.VariableConArr[A_Index].Delete()
            this.VariableConArr[A_Index].Add(VariableObjArr)
            this.VariableConArr[A_Index].Text := this.Data.VariableArr[A_Index]
        }

        hasRemark := this.RemarkCon.Value != ""
        this.CommandStr := "比较_" this.Data.SerialStr
        if (hasRemark) {
            this.CommandStr .= "_" this.RemarkCon.Value
        }
    }

    CheckIfValid() {
        return true
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

        this.SaveCompareData()
        action := this.SureBtnAction
        action(this.CommandStr)
        ; this.ToggleFunc(false)
        this.Gui.Hide()
    }

    OnTrueMacroBtnClick(CommandStr) {
        this.TrueMacroCon.Value := CommandStr
    }

    OnFalseMacroBtnClick(CommandStr) {
        this.FalseMacroCon.Value := CommandStr
    }

    OnEditFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.FocusCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnTrueMacroBtnClick(command)
        this.MacroGui.ShowGui(this.TrueMacroCon.Value, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.FocusCon
        }
        this.MacroGui.SureBtnAction := (command) => this.OnFalseMacroBtnClick(command)
        this.MacroGui.ShowGui(this.FalseMacroCon.Value, false)
    }

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.SaveCompareData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()
        OnCompare(tableItem, this.CommandStr, 1)
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
        this.Data.TrueMacro := this.TrueMacroCon.Value
        this.Data.FalseMacro := this.FalseMacroCon.Value
        loop 4 {
            this.Data.ToggleArr[A_Index] := this.ToggleConArr[A_Index].Value
            this.Data.NameArr[A_Index] := this.NameConArr[A_Index].Text
            this.Data.CompareTypeArr[A_Index] := this.CompareTypeConArr[A_Index].Value
            this.Data.ValueArr[A_Index] := this.ValueConArr[A_Index].Value
            this.Data.VariableArr := this.VariableConArr[A_Index].Text
        }

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, CompareFile, IniSection, this.Data.SerialStr)
    }
}
