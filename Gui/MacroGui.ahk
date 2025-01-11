#Requires AutoHotkey v2.0
#Include CommandIntervalGui.ahk
#Include KeyGui.ahk
#Include MouseMoveGui.ahk
#Include SearchGui.ahk

class MacroGui {
    __new() {
        this.Gui := ""
        this.ShowSaveBtn := false
        this.SureFocusCon := ""

        this.SureBtnAction := ""
        this.SaveBtnAction := ""
        this.MacroEditStr := ""
        this.CommandArr := []
        this.SaveBtnCtrl := {}
        this.MacroStrCon := {}
        this.CmdBtnConMap := map()
        this.SubGuiMap := map()
        this.NeedCommandInterval := false
        this.EditModeType := 1
        this.EditModeCon := ""
        this.DefaultFocusCon := ""
        this.CurEditLineNum := 0
        this.CurCmdIndex := 0
        this.InitSubGui()

    }

    InitSubGui() {
        this.CommandIntervalGui := CommandIntervalGui()
        this.CommandIntervalGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("Interval", this.CommandIntervalGui)

        this.KeyGui := KeyGui()
        this.KeyGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("KeyPress", this.KeyGui)

        this.MoveMoveGui := MouseMoveGui()
        this.MoveMoveGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("MouseMove", this.MoveMoveGui)

        this.SearchGui := SearchGui()
        this.SearchGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("Search", this.SearchGui)
    }

    ShowGui(CommandStr, ShowSaveBtn) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(CommandStr, ShowSaveBtn)
        this.Refresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "指令编辑器")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 1000, 170), "当前宏指令")
        PosY += 15
        this.MacroStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX + 5, PosY, 990, 150), "")

        PosX := 20
        PosY += 160
        this.DefaultFocusCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 70), "编辑模式：")
        PosX += 70
        this.EditModeCon := MyGui.Add("ComboBox", Format("x{} y{} w{} h{}", PosX, PosY - 3, 150, 100), ["末尾追加指令",
            "调整光标行指令", "改变光标行指令"])
        this.EditModeCon.OnEvent("Change", (*) => this.OnChangeEditMode())

        PosY += 20
        PosX := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", 10, PosY, 1000, 150), "指令选项")

        PosY += 20
        PosX := 20
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "间隔")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.CommandIntervalGui))
        this.CmdBtnConMap.Set("Interval", btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "按键")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.KeyGui))
        this.CmdBtnConMap.Set("KeyPress", btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "鼠标移动")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.MoveMoveGui))
        this.CmdBtnConMap.Set("MouseMove", btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "搜索")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.SearchGui))
        this.CmdBtnConMap.Set("Search", btnCon)

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

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 1020, 420))
    }

    Refresh() {
        this.UpdateInfo()
        this.RefreshCommandBtn()
        this.MacroStrCon.Value := this.MacroEditStr
    }

    UpdateInfo() {
        this.MacroEditStr := ""
        isIntervalCmd := false
        for index, value in this.CommandArr {
            if (index != 1 && !isIntervalCmd) {
                this.MacroEditStr .= "`n"
            }

            if (isIntervalCmd) {
                this.MacroEditStr .= "," value
            }
            else {
                splitIndex := RegExMatch(value, "(\(.*\))", &match)
                if (splitIndex) {
                    value := StrReplace(value, match[1], "(...)")
                }
                this.MacroEditStr .= value
            }
            isIntervalCmd := !isIntervalCmd
        }

        this.NeedCommandInterval := false
        if (this.CommandArr.Length >= 1) {
            command := this.CommandArr[this.CommandArr.Length]
            this.NeedCommandInterval := RegExMatch(command, "_")
        }
    }

    GetMacroStr() {
        resultStr := ""
        for index, value in this.CommandArr {
            if (index != 1) {
                resultStr .= ","
            }

            resultStr .= value
        }
        return resultStr
    }

    GetCurLineCmd(isInterval) {
        lineNum := EditGetCurrentLine(this.MacroStrCon)
        cmdIndex := lineNum * 2
        cmdIndex := isInterval ? cmdIndex : cmdIndex - 1
        if (cmdIndex > this.CommandArr.Length)
            return ""
        return this.CommandArr[cmdIndex]
    }

    GetCurLineCmdSymbol() {
        cmd := this.GetCurLineCmd(false)
        if (cmd == "")
            return ""

        if (IsInteger(cmd))
            return "Interval"
        else if (SubStr(cmd, 1, 9) == "MouseMove")
            return "MouseMove"
        else if (SubStr(cmd, 1, 6) == "Search")
            return "Search"
        else
            return "KeyPress"
    }

    RefreshCommandBtn() {
        if (this.EditModeType == 1) {
            for key, value in this.CmdBtnConMap {
                value.Enabled := !this.NeedCommandInterval
            }
            this.CmdBtnConMap["Interval"].Enabled := this.NeedCommandInterval
        }
        else if (this.EditModeType == 2) {
            symbol := this.GetCurLineCmdSymbol()
            for key, value in this.CmdBtnConMap {
                enable := key == "Interval" || key == symbol
                value.Enabled := enable
            }
        }
        else if (this.EditModeType == 3) {
            for key, value in this.CmdBtnConMap {
                value.Enabled := true
            }
        }
    }

    Init(CommandStr, ShowSaveBtn) {
        this.ShowSaveBtn := ShowSaveBtn
        this.CommandArr := this.SplitCommand(CommandStr)

        this.NeedCommandInterval := false
        if (this.CommandArr.Length >= 1) {
            command := this.CommandArr[this.CommandArr.Length]
            this.NeedCommandInterval := RegExMatch(command, "_")
        }

        this.SaveBtnCtrl.Visible := this.ShowSaveBtn
        this.EditModeCon.Value := this.EditModeType
    }

    ToggleFunc(state) {
        checkAction := () => this.CheckIfChangeLineNum()
        if (state) {
            SetTimer checkAction, 100
        }
        else {
            SetTimer checkAction, 0
        }
    }

    CheckIfChangeLineNum() {
        if (this.EditModeType == 1)
            return

        lineNum := EditGetCurrentLine(this.MacroStrCon)
        if (lineNum != this.CurEditLineNum) {
            this.CurEditLineNum := lineNum
            this.RefreshCommandBtn()
        }
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

    Backspace() {
        this.CommandArr.Pop()
        this.NeedCommandInterval := !this.NeedCommandInterval
        this.Refresh()
    }

    ClearStr() {
        this.CommandArr := []
        this.NeedCommandInterval := false
        this.Refresh()
    }

    OnSaveBtnClick() {
        macroStr := this.GetMacroStr()
        action := this.SureBtnAction
        action(macroStr)

        this.SureBtnAction := ""
        this.Gui.Hide()

        action := this.SaveBtnAction
        action()
        this.SureFocusCon.Focus()
        this.ToggleFunc(false)
    }

    OnSureBtnClick() {
        macroStr := this.GetMacroStr()
        action := this.SureBtnAction
        action(macroStr)

        this.SureBtnAction := ""
        this.Gui.Hide()
        this.SureFocusCon.Focus()
        this.ToggleFunc(false)
    }

    OnOpenSubGui(subGui) {
        isIntervalGui := subGui == this.CommandIntervalGui
        curCmd := this.GetCurLineCmd(isIntervalGui)
        symbol := this.GetCurLineCmdSymbol()
        lineNum := EditGetCurrentLine(this.MacroStrCon)
        this.CurCmdIndex := lineNum * 2
        this.CurCmdIndex := isIntervalGui ? this.CurCmdIndex : this.CurCmdIndex - 1
        if (this.EditModeType == 1) {
            subGui.ShowGui("")
        }
        else if (this.EditModeType == 2) {
            subGui.ShowGui(curCmd)
        }
        else if (this.EditModeType == 3) {
            isFit := symbol != "" && this.SubGuiMap[symbol] == subGui
            isFit := isFit || isIntervalGui

            if (isFit) {
                subGui.ShowGui(curCmd)
            }
            else {
                subGui.ShowGui("")
            }
        }
    }

    OnSubGuiSureBtnClick(CommandStr) {
        if (this.EditModeType == 1) {
            this.CommandArr.Push(CommandStr)
            this.NeedCommandInterval := !this.NeedCommandInterval
        }
        else if (this.EditModeType == 2 || this.EditModeType == 3) {
            if (this.CurCmdIndex > this.CommandArr.Length){
                this.CommandArr.Push(CommandStr)
            }
            else {
                this.CommandArr[this.CurCmdIndex] := CommandStr
            }
        }

        this.Refresh()
        this.DefaultFocusCon.Focus()
    }

    OnChangeEditMode() {
        this.EditModeType := this.EditModeCon.Value
        this.DefaultFocusCon.Focus()
    }
}
