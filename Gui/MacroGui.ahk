#Requires AutoHotkey v2.0
#Include CommandIntervalGui.ahk
#Include KeyGui.ahk
#Include MouseMoveGui.ahk
#Include SearchGui.ahk

class MacroGui{
    __new(){
        this.Gui := ""
        this.ShowSaveBtn := false
        this.SureBtnAction := ""
        this.SaveBtnAction := ""
        this.CommandStr := ""
        this.CommandArr := []
        this.SaveBtnCtrl := {}
        this.CommandTextCtrl := {}
        this.AllCommandBtnCon := []
        this.CommandBtnIntervalCon := {}
        this.NeedCommandInterval := false

        this.InitSubGui()

    }

    InitSubGui(){
        this.CommandIntervalGui := CommandIntervalGui()
        this.CommandIntervalGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)

        this.KeyGui := KeyGui()
        this.KeyGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)

        this.MoveMoveGui := MouseMoveGui()
        this.MoveMoveGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)

        this.SearchGui := SearchGui()
        this.SearchGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
    }

    ShowGui(CommandStr, ShowSaveBtn){
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else{
            this.AddGui()
        }

        this.Init(CommandStr, ShowSaveBtn)
        this.Refresh()
    }

    AddGui(){
        MyGui := Gui(, "指令编辑器")
        this.Gui := MyGui
        
        PosX := 20
        PosY := 20
        MyGui.Add("GroupBox",Format("x{} y{} w{} h{}", 10, 10, 1000, 100) , "当前宏指令")
        this.CommandTextCtrl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", 15, 25, 990, 120), "")

        PosY += 140
        MyGui.Add("Text", Format("x{} y{} w{}", 15, 150, 900), "规则1:指令之间必须用% 间隔 %指令衔接。形如：按键，间隔，鼠标移动，间隔，按键，间隔。")
        
        PosY += 20
        MyGui.Add("GroupBox",Format("x{} y{} w{} h{}", 10, PosY, 1000, 150) , "指令选项")

        PosY += 20
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "间隔")
        btnCon.OnEvent("Click", (*) => this.CommandIntervalGui.ShowGui())
        this.CommandBtnIntervalCon := btnCon
        this.AllCommandBtnCon.Push(btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "按键")
        btnCon.OnEvent("Click", (*) => this.KeyGui.ShowGui())
        this.AllCommandBtnCon.Push(btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "鼠标移动")
        btnCon.OnEvent("Click", (*) => this.MoveMoveGui.ShowGui())
        this.AllCommandBtnCon.Push(btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "搜索")
        btnCon.OnEvent("Click", (*) => this.SearchGui.ShowGui())
        this.AllCommandBtnCon.Push(btnCon)

        PosX := 20
        PosY += 140
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "Backspace")
        btnCon.OnEvent("Click", (*) => this.Backspace())

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "清空指令")
        btnCon.OnEvent("Click", (*) => this.ClearStr())

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "确定")
        btnCon.OnEvent("Click", (*) => this.OnSureBtnClick())

        PosX += 200
        this.SaveBtnCtrl := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "应用并保存")
        this.SaveBtnCtrl.OnEvent("Click", (*) => this.OnSaveBtnClick())

        MyGui.Show(Format("w{} h{}", 1020, 400))
    }

    Refresh(){
        this.CommandTextCtrl.Text := this.CommandStr
        this.RefreshCommandBtn()
    }

    RefreshCommandBtn(){
        for index, value in this.AllCommandBtnCon {
            value.Enabled := !this.NeedCommandInterval
        }
        this.CommandBtnIntervalCon.Enabled := this.NeedCommandInterval
    }

    Init(CommandStr, ShowSaveBtn){
        this.ShowSaveBtn := ShowSaveBtn
        this.CommandStr := CommandStr
        this.CommandArr:= this.SplitCommand(this.CommandStr)

        this.NeedCommandInterval := false
        if (this.CommandArr.Length >= 1){
            command := this.CommandArr[this.CommandArr.Length]
            this.NeedCommandInterval := RegExMatch(command, "_")
        }

        this.SaveBtnCtrl.Visible := this.ShowSaveBtn
    }

    SplitCommand(Str) {
        resultArr := []
        lastSymbolIndex := 0
        leftBracket := 0
    
        loop parse Str {
    
            if (A_LoopField == "(") {
                leftBracket += 1
            }
    
            if (A_LoopField == ")") {
                leftBracket -= 1
            }
    
            if (A_LoopField == ",") {
                if (leftBracket == 0) {
                    curCmd := SubStr(Str, lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                    resultArr.Push(curCmd)
                    lastSymbolIndex := A_Index
                }
            }
    
            if (A_Index == StrLen(Str)) {
                curCmd := SubStr(Str, lastSymbolIndex + 1, A_Index - lastSymbolIndex)
                resultArr.Push(curCmd)
            }
    
        }
        return resultArr
    }

    Backspace(){
        this.CommandArr.Pop()
        Str := ""
        for index, value in this.CommandArr{
            Str .= value
            if (index < this.CommandArr.Length){
                Str .= ","
            }
        }
        this.NeedCommandInterval := !this.NeedCommandInterval
        this.CommandStr := Str
        this.Refresh()
    }

    ClearStr(){
        this.CommandStr := ""
        this.CommandArr := []
        this.NeedCommandInterval := false
        this.Refresh()
    }

    OnSaveBtnClick() {
        isSure := this.SureTriggerKey()

        if (!isSure) {
            return
        }     

        this.Gui.Hide()
        if (this.SaveBtnAction != "") {
            action := this.SaveBtnAction
            action()
        }
    }

    OnSureBtnClick() {
        isSure := this.SureTriggerKey()

        if (isSure) {
            this.Gui.Hide()
        }        
    }

    SureTriggerKey(){
        if (this.SureBtnAction != "") {
            action := this.SureBtnAction
            action(this.CommandStr)
            this.SureBtnAction := ""
        }
        return true
    }
    
    OnSubGuiSureBtnClick(CommandStr){
        if (this.CommandStr != ""){
            this.CommandStr .= ","
        }
        this.CommandStr .= CommandStr
        this.CommandArr.Push(CommandStr)
        this.NeedCommandInterval := !this.NeedCommandInterval
        this.Refresh()
    }
}