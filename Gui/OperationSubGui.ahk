#Requires AutoHotkey v2.0

class OperationSubGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.FocusCon := ""
        this.Index := 0
        this.Name := ""
        this.SymbolArr := []
        this.ValueArr := []

        this.ExpressionCon := ""
        this.ValueCon := ""
        this.NameCon := ""
        this.BaseValueCon := ""
        this.BaseResultCon := ""
    }

    ShowGui(index, Name, cmd, SymbolArr, ValurArr) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableArr := GetSelectVariableObjArr(macro)
        this.Index := index
        this.Name := Name
        this.ExpressionCon.Value := cmd != "" ? cmd : Name
        this.SymbolArr := SymbolArr
        this.ValueArr := ValurArr
    
        this.NameCon.Delete()
        this.NameCon.Add(VariableArr)
        this.NameCon.Text := "空"
        this.FocusCon.Focus()
    }

    AddGui() {
        MyGui := Gui(, "变量换算编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "选择/输入为空时与操作值进行运算，否则与选择/输入的变量值运算")

        PosX := 10
        PosY += 30
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "..按钮字符拼接操作")

        PosX := 10
        PosY += 25
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "当前运算表达式")
        PosY += 20
        this.ExpressionCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "")
        this.ExpressionCon.Enabled := false

        PosX := 10
        PosY += 25
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "操作值               选择/输入")
        PosY += 20
        this.ValueCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "0")
        PosX += 150
        this.NameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY, 100), [])

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "操作运算符")
        PosX := 10
        PosY += 20
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "+")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn("+"))
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 60, PosY, 50, 30), "-")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn("-"))
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 120, PosY, 50, 30), "*")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn("*"))
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 180, PosY, 50, 30), "/")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn("/"))
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 240, PosY, 50, 30), "^")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn("^"))
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 300, PosY, 50, 30), "..")
        con.OnEvent("Click", (*) => this.OnClickOperatorBtn(".."))

        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "假如操作变量是：")
        this.BaseValueCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX + 110, PosY - 3, 50, 20), "10")
        this.BaseValueCon.OnEvent("Change", (*) => this.OnChangeBaseValue())

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "换算后的变量是：")
        this.BaseResultCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX + 125, PosY, 120, 20), "10")

        PosY += 30
        PosX := 10
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 75, PosY, 100, 40), "退格")
        btnCon.OnEvent("Click", (*) => this.OnBackspaceBtnClick())
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 225, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.Show(Format("w{} h{}", 400, 320))
    }

    OnChangeBaseValue() {
        this.UpdateExampleValue()
    }

    OnClickOperatorBtn(Symbol) {
        text := this.Name
        Value := this.ValueCon.Value
        if (this.NameCon.Text != "空" && this.NameCon.Text != "")
            Value := "&" this.NameCon.Text

        this.SymbolArr.Push(Symbol)
        this.ValueArr.Push(Value)
        loop this.SymbolArr.Length {
            leftBracket := A_Index == 1 ? "" : "("
            rightBracket := A_Index == 1 ? "" : ")"
            CurSymbol := this.SymbolArr[A_Index]
            CurValue := this.ValueArr[A_Index]
            if (SubStr(CurValue, 1, 1) == "&")
                CurValue := SubStr(CurValue, 2)
            text := leftBracket text rightBracket CurSymbol CurValue
        }
        this.ExpressionCon.Value := text
        this.UpdateExampleValue()
    }

    OnBackspaceBtnClick() {
        if (this.SymbolArr.Length <= 0)
            return
        this.SymbolArr.Pop()
        this.ValueArr.Pop()

        text := this.Name
        loop this.SymbolArr.Length {
            leftBracket := A_Index == 1 ? "" : "("
            rightBracket := A_Index == 1 ? "" : ")"
            Symbol := this.SymbolArr[A_Index]
            Value := this.ValueArr[A_Index]
            if (SubStr(CurValue, 1, 1) == "&")
                CurValue := SubStr(CurValue, 2)
            text := leftBracket text rightBracket Symbol Value
        }
        this.ExpressionCon.Value := text
        this.UpdateExampleValue()
    }

    OnClickSureBtn() {
        if (this.SureBtnAction == "")
            return

        action := this.SureBtnAction
        action(this.Index, this.ExpressionCon.Value, this.SymbolArr, this.ValueArr)
        this.Gui.Hide()
    }

    UpdateExampleValue() {
        HasVariable := false
        loop this.ValueArr.Length {
            if (SubStr(this.ValueArr[A_Index], 1, 1) == "&") {
                HasVariable := true
                break
            }
        }

        if (HasVariable) {
            this.BaseResultCon.Value := "有变量无法预算"
            return
        }

        sum := GetOperationResult(this.BaseValueCon.Value, this.SymbolArr, this.ValueArr)
        this.BaseResultCon.Value := sum
    }
}
