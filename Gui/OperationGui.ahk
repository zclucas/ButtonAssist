#Requires AutoHotkey v2.0

class OperationGui{
    __new(){
        this.Gui := ""
        this.SureBtnAction := ""
        this.OperatorCon := ""
        this.FocusCon := ""
        this.OperatorNumCon := ""
        this.BaseValueCon := ""
        this.BaseResultCon := ""
        this.Index := 0
        this.variableStr := ""
    }

    ShowGui(index, variableStr, cmd){
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else{
            this.AddGui()
        }

        this.Index := index
        this.variableStr := variableStr
        this.OperatorCon.Value := cmd != "" ? cmd : ""
        this.FocusCon.Focus()
    }

    AddGui() {
        MyGui := Gui(, "变量换算编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "操作指令")
        PosY += 20
        this.OperatorCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 350, 20), "")
        this.OperatorCon.Enabled := false

        PosY += 30
        this.OperatorNumCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "0")

        PosY += 30
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


        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "假如操作变量是：")
        this.BaseValueCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX + 110, PosY - 3, 50, 20), "10")
        this.BaseValueCon.OnEvent("Change", (*)=> this.OnChangeBaseValue())

        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX + 180, PosY, 120, 20), "换算后的变量是：")
        this.BaseResultCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX + 290, PosY, 50, 20), "10")

        PosY += 40
        PosX := 10
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 50, PosY, 100, 40), "退格")
        btnCon.OnEvent("Click", (*) => this.OnBackspaceBtnClick())
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX + 200, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        

        MyGui.Show(Format("w{} h{}", 400, 240))
    }

    OnChangeBaseValue(){
        this.UpdateExampleValue()
    }

    OnClickOperatorBtn(symbol){
        text := this.OperatorCon.Value
        leftBracket := StrLen(text) == 1 ? "" : "("
        rightBracket := StrLen(text) == 1 ? "" : ")"

        text := leftBracket text rightBracket symbol this.OperatorNumCon.Value
        this.OperatorCon.Value := text
        this.UpdateExampleValue()
    }

    OnBackspaceBtnClick() {
        expression := this.OperatorCon.Value
        res := CompareExtractOperAndNum(expression)
        endIndex := res.operators.Length > 0 ? res.operators.Length - 1 : 0
        text := this.variableStr
        for index, value in res.operators{
            if (index > endIndex)
                break

        leftBracket := StrLen(text) == 1 ? "" : "("
        rightBracket := StrLen(text) == 1 ? "" : ")"
        text := leftBracket text rightBracket value res.numbers[index]
        }
        this.OperatorCon.Value := text
        this.UpdateExampleValue()
    }
    
    

    OnClickSureBtn(){
        if (this.SureBtnAction == "")
            return

        action := this.SureBtnAction
        action(this.Index, this.variableStr, this.OperatorCon.Value)
        this.Gui.Hide()
    }

    UpdateExampleValue(){
        sum := UpdateBaseValue(Number(this.BaseValueCon.Value), this.OperatorCon.Value)
        this.BaseResultCon.Value := sum
    }
}