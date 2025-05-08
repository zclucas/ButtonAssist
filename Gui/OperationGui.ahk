#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk
#Include OperationSubGui.ahk

class OperationGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.Data := ""
        this.MacroEditGui := ""
        this.CommandStr := ""
        this.OperationSubGui := ""

        this.ToggleConArr := []
        this.NameConArr := []
        this.OperationConArr := []
        this.UpdateTypeConArr := []
        this.UpdateNameConArr := []
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

    AddGui() {
        MyGui := Gui(, "运算指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosX := 10
        PosY += 25
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY, 70, 20), "勾选开关且选择/输入1不为空时生效")

        PosX := 10
        PosY += 25
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY, 70, 20),
        "开关  选择/输入1       运算表达式                                    选择/输入2")

        PosY += 20
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 135, PosY - 3, 150), "")
        con.Enabled := false
        this.OperationConArr.Push(con)

        con := MyGui.Add("Button", Format("x{} y{} w{} Center", PosX + 290, PosY - 4, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(1))

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 350, PosY - 3, 100), ["更新自己", "创建或更新"])
        con.Value := 1
        this.UpdateTypeConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 455, PosY - 3, 100), [])
        this.UpdateNameConArr.Push(con)
    
        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 135, PosY - 3, 150), "")
        con.Enabled := false
        this.OperationConArr.Push(con)

        con := MyGui.Add("Button", Format("x{} y{} w{} Center", PosX + 290, PosY - 4, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(2))

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 350, PosY - 3, 100), ["更新自己", "创建或更新"])
        con.Value := 1
        this.UpdateTypeConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 455, PosY - 3, 100), [])
        this.UpdateNameConArr.Push(con)
    
        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 135, PosY - 3, 150), "")
        con.Enabled := false
        this.OperationConArr.Push(con)

        con := MyGui.Add("Button", Format("x{} y{} w{} Center", PosX + 290, PosY - 4, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(3))

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 350, PosY - 3, 100), ["更新自己", "创建或更新"])
        con.Value := 1
        this.UpdateTypeConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 455, PosY - 3, 100), [])
        this.UpdateNameConArr.Push(con)
    
        PosY += 35
        PosX := 15
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ToggleConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 30, PosY - 3, 100), [])
        this.NameConArr.Push(con)

        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 135, PosY - 3, 150), "")
        con.Enabled := false
        this.OperationConArr.Push(con)

        con := MyGui.Add("Button", Format("x{} y{} w{} Center", PosX + 290, PosY - 4, 50), "编辑")
        con.OnEvent("Click", (*) => this.OnEditVariableBtnClick(4))

        con := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 350, PosY - 3, 100), ["更新自己", "创建或更新"])
        con.Value := 1
        this.UpdateTypeConArr.Push(con)

        con := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 455, PosY - 3, 100), [])
        this.UpdateNameConArr.Push(con)

        PosY += 40
        PosX := 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.Show(Format("w{} h{}", 600, 280))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetOperationData(this.SerialStr)
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        loop 4 {
            this.ToggleConArr[A_Index].Value := this.Data.ToggleArr[A_Index]
            this.NameConArr[A_Index].Delete()
            this.NameConArr[A_Index].Add(VariableObjArr)
            this.NameConArr[A_Index].Text := this.Data.NameArr[A_Index]
            this.OperationConArr[A_Index].Value := this.Data.OperationArr[A_Index]
            this.UpdateTypeConArr[A_Index].Value := this.Data.UpdateTypeArr[A_Index]
            this.UpdateNameConArr[A_Index].Delete()
            this.UpdateNameConArr[A_Index].Add(VariableObjArr)
            this.UpdateNameConArr[A_Index].Text := this.Data.UpdateNameArr[A_Index]
        }

        hasRemark := this.RemarkCon.Value != ""
        this.CommandStr := "运算_" this.Data.SerialStr
        if (hasRemark) {
            this.CommandStr .= "_" this.RemarkCon.Value
        }
    }

    OnSureOperationBtnClick(index, command, SymbolArr, ValueArr) {
        con := this.OperationConArr[index]
        con.Value := command
        this.Data.SymbolGroups[index] := SymbolArr
        this.Data.ValueGroups[index] := ValueArr
    }

    OnEditVariableBtnClick(index) {
        if (this.OperationSubGui == "") {
            this.OperationSubGui := OperationSubGui()
            this.OperationSubGui.MacroEditGui := this.MacroEditGui
        }
        Name := this.NameConArr[index].Text
        if (Name == "" || Name == "空") {
            MsgBox("选择/输入1不可为空")
            return
        }
        SymbolArr := this.Data.SymbolGroups[index]
        ValueArr := this.Data.ValueGroups[index]
        this.OperationSubGui.SureBtnAction := (index, command, SymbolArr, ValueArr) => this.OnSureOperationBtnClick(index, command, SymbolArr, ValueArr)
        this.OperationSubGui.ShowGui(index, Name, this.OperationConArr[index].Value, SymbolArr, ValueArr)
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveOperationData()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        return true
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Operation" CurrentDateTime
    }

    GetOperationData(SerialStr) {
        saveStr := IniRead(OperationFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := OperationData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveOperationData() {
        loop 4 {
            this.Data.ToggleArr[A_Index] := this.ToggleConArr[A_Index].Value
            this.Data.NameArr[A_Index] := this.NameConArr[A_Index].Text
            this.Data.OperationArr[A_Index] := this.OperationConArr[A_Index].Value
            this.Data.UpdateTypeArr[A_Index] := this.UpdateTypeConArr[A_Index].Value
            this.Data.UpdateNameArr[A_Index] := this.UpdateNameConArr[A_Index].Text
        }

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, OperationFile, IniSection, this.Data.SerialStr)
    }
}
