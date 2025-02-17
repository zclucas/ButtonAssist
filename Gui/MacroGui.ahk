#Requires AutoHotkey v2.0
#Include IntervalGui.ahk
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
        this.SaveBtnCtrl := {}
        this.MacroEditStrCon := {}
        this.CmdBtnConMap := map()
        this.SubGuiMap := map()
        this.NeedCommandInterval := false
        this.EditModeType := 1
        this.EditModeCon := ""
        this.DefaultFocusCon := ""
        this.CurEditLineNum := 0
        this.EditLineNum := 0
        this.SubMacroMap := Map()
        this.SubMacroLastIndex := 0
        this.InitSubGui()

    }

    InitSubGui() {
        this.IntervalGui := IntervalGui()
        this.IntervalGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("Interval", this.IntervalGui)

        this.KeyGui := KeyGui()
        this.KeyGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("PressKey", this.KeyGui)

        this.MoveMoveGui := MouseMoveGui()
        this.MoveMoveGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("MouseMove", this.MoveMoveGui)

        this.SearchGui := SearchGui()
        this.SearchGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("Search", this.SearchGui)
    }

    GetSubGuiSymbol(subGui) {
        for key, value in this.SubGuiMap {
            if (value == subGui)
                return key
        }
        return ""
    }

    ShowGui(CommandStr, ShowSaveBtn) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(CommandStr, ShowSaveBtn)
        this.RefreshCommandBtn()
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
        this.MacroEditStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX + 5, PosY, 990, 150), "")

        PosX := 20
        PosY += 160
        this.DefaultFocusCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 70), "编辑模式：")
        PosX += 70
        this.EditModeCon := MyGui.Add("ComboBox", Format("x{} y{} w{} h{}", PosX, PosY - 3, 150, 100), ["末尾追加指令",
            "调整光标行指令", "光标行插入指令"])
        this.EditModeCon.OnEvent("Change", (*) => this.OnChangeEditMode())

        PosY += 20
        PosX := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", 10, PosY, 1000, 150), "指令选项")

        PosY += 20
        PosX := 20
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "间隔")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.IntervalGui))
        this.CmdBtnConMap.Set("Interval", btnCon)

        PosX += 125
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "按键")
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.KeyGui))
        this.CmdBtnConMap.Set("PressKey", btnCon)

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

    Init(CommandStr, ShowSaveBtn) {
        this.ShowSaveBtn := ShowSaveBtn
        this.SubMacroLastIndex := 0
        this.SaveBtnCtrl.Visible := this.ShowSaveBtn
        this.EditModeCon.Value := this.EditModeType
        this.MacroEditStrCon.Value := this.GetMacroEditStr(CommandStr)
    }

    RefreshCommandBtn() {
        if (this.EditModeType == 1) {
            for key, value in this.CmdBtnConMap {
                value.Enabled := true
            }
        }
        else if (this.EditModeType == 2) {
            for key, value in this.CmdBtnConMap {
                cmd := this.GetLineCmd(this.CurEditLineNum, key)
                value.Enabled := cmd != ""
            }
        }
        else  if (this.EditModeType == 3) {
            for key, value in this.CmdBtnConMap {
                value.Enabled := true
            }
        }
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

        lineNum := EditGetCurrentLine(this.MacroEditStrCon)
        if (lineNum != this.CurEditLineNum) {
            this.CurEditLineNum := lineNum
            this.RefreshCommandBtn()
        }
    }

    GetMacroEditStr(macro) {
        CammandArr := this.SplitMacro(macro)
        macroEditStr := ""
        processedIndex := 0
        for index, value in CammandArr {
            if (processedIndex >= index)
                continue
            processedIndex := index
            isInterval := StrCompare(SubStr(value, 1, 8), "Interval", false) == 0
            if (isInterval) {
                SubCammandArr := StrSplit(value, "_")
                intervalValue := Integer(SubCammandArr[2])
                loop {
                    curIndex := index + A_Index
                    if (curIndex > CammandArr.Length)
                        break

                    SubCammandArr := StrSplit(CammandArr[curIndex], "_")
                    isIntervaAgain := StrCompare(SubStr(SubCammandArr[1], 1, 8), "Interval", false) == 0
                    if (!isIntervaAgain)
                        break
                    intervalValue += Integer(SubCammandArr[2])
                    processedIndex := curIndex
                }
                macroEditStr := index == 1 ? macroEditStr : macroEditStr ","
                macroEditStr .= "Interval_" intervalValue "`n"
                continue
            }

            isPressKey := StrCompare(SubStr(value, 1, 8), "PressKey", false) == 0
            if (isPressKey) {
                macroEditStr .= value
                loop {
                    curIndex := index + A_Index
                    if (curIndex > CammandArr.Length)
                        break

                    SubCammandArr := StrSplit(CammandArr[curIndex], "_")
                    isPressKeyAgain := StrCompare(SubStr(SubCammandArr[1], 1, 8), "PressKey", false) == 0
                    if (!isPressKeyAgain)
                        break
                    macroEditStr .= "," CammandArr[curIndex]
                    processedIndex := curIndex
                }
            }

            isSearch := StrCompare(SubStr(value, 1, 6), "Search", false) == 0
            if (isSearch) {
                splitIndex := RegExMatch(value, "(\(.*\))", &match)
                isSubMacro := splitIndex && RegExMatch(match[1], "SubMacro")
                if (splitIndex && !isSubMacro) {
                    this.SubMacroLastIndex += 1
                    value := StrReplace(value, match[1], Format("({})", "SubMacro" this.SubMacroLastIndex))
                    this.SubMacroMap.Set(this.SubMacroLastIndex, match[1])
                }
                macroEditStr .= value
            }

            isMouseMove := StrCompare(SubStr(value, 1, 9), "MouseMove", false) == 0
            if (isMouseMove) {
                macroEditStr .= value
            }

            nextIndex := processedIndex + 1
            isNextInterval := nextIndex <= CammandArr.Length
            isNextInterval := isNextInterval && StrCompare(SubStr(CammandArr[nextIndex], 1, 8), "Interval", false) == 0
            if (!isNextInterval) {
                macroEditStr .= "`n"
            }
        }
        return macroEditStr
    }
    
    SplitMacro(macro) {
        resultArr := []
        lastSymbolIndex := 0
        leftBracket := 0

        loop parse macro {

            if (A_LoopField == "(") {
                leftBracket += 1
            }

            if (A_LoopField == ")") {
                leftBracket -= 1
            }

            if (A_LoopField == ",") {
                if (leftBracket == 0) {
                    curCmd := SubStr(macro, lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                    if (curCmd != "")
                        resultArr.Push(curCmd)
                    lastSymbolIndex := A_Index
                }
            }

            if (A_Index == StrLen(macro)) {
                curCmd := SubStr(macro, lastSymbolIndex + 1, A_Index - lastSymbolIndex)
                resultArr.Push(curCmd)
            }

        }
        return resultArr
    }

    GetMacroStr(LineArr) {
        macroStr := ""
        for index, value in LineArr {
            macroStr .= value
            if (index != LineArr.Length) {
                macroStr .= ","
            }
        }
        macroStr := Trim(macroStr, ",")
        macroStr := RegExReplace(macroStr, ",+" , ",")
        return macroStr
    }

    GetFiniallyMacroStr() {
        MacroLineArr := StrSplit(this.MacroEditStrCon.Value, "`n")
        macro := this.GetMacroStr(MacroLineArr)
        for key, value in this.SubMacroMap {
            macro := StrReplace(macro, Format("(SubMacro{})", key), value)
        }
        return macro
    }

    GetMacroStrLineArr() {
        MacroLineArr := StrSplit(this.MacroEditStrCon.Value, "`n")
        if (MacroLineArr.Length == 0){
            MacroLineArr.Push("")
        }
        return MacroLineArr
    }

    GetLineCmd(lineNum, symbol) {
        cmd := ""
        lineArr := this.GetMacroStrLineArr()

        cmdArr := StrSplit(lineArr[lineNum], ",")
        for index, value in cmdArr {
            paramArr := StrSplit(value, "_")
            curSymbol := paramArr[1]
            if (curSymbol == symbol) {
                cmd := value
                break
            }

            if(symbol == "Search" && SubStr(curSymbol, 1, 6) == "Search"){
                cmd := value
                break
            }
        }

        for key, value in this.SubMacroMap {
            cmd := StrReplace(cmd, Format("(SubMacro{})", key), value)
        }
        return cmd
    }

    Backspace() {
        macro := this.GetFiniallyMacroStr()
        CammandArr := this.SplitMacro(macro)
        CammandArr.Pop()
        macro := this.GetMacroStr(CammandArr)
        this.MacroEditStrCon.Value := this.GetMacroEditStr(macro)
    }

    ClearStr() {
        this.MacroEditStrCon.Value := ""
    }

    OnSaveBtnClick() {
        macroStr := this.GetFiniallyMacroStr()
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
        macroStr := this.GetFiniallyMacroStr()
        action := this.SureBtnAction
        action(macroStr)

        this.SureBtnAction := ""
        this.Gui.Hide()
        this.SureFocusCon.Focus()
        this.ToggleFunc(false)
    }

    OnOpenSubGui(subGui) {
        symbol := this.GetSubGuiSymbol(subGui)
        lineNum := EditGetCurrentLine(this.MacroEditStrCon)
        this.EditLineNum := lineNum
        cmd := this.GetLineCmd(lineNum, symbol)

        if (this.EditModeType == 1) {
            subGui.ShowGui("")
        }
        else if (this.EditModeType == 2) {
            subGui.ShowGui(cmd)
        }
        else if (this.EditModeType == 3) {
            subGui.ShowGui("")
        }
    }

    OnSubGuiSureBtnClick(CommandStr) {
        splitIndex := RegExMatch(CommandStr, "(\(.*\))", &match)
        if (splitIndex){
            this.SubMacroLastIndex += 1
            CommandStr := StrReplace(CommandStr, match[1], Format("({})", "SubMacro" this.SubMacroLastIndex))
            this.SubMacroMap.Set(this.SubMacroLastIndex, match[1])
        }

        LineArr := this.GetMacroStrLineArr()
        if (this.EditModeType == 1) {
            LineArr := this.OnAddCmd(LineArr, CommandStr)
        }
        else if (this.EditModeType == 2) {
            LineArr := this.OnModifyCmd(LineArr, CommandStr)
        }
        else if (this.EditModeType == 3){
            LineArr := this.OnInsertCmd(LineArr, CommandStr)
        }
        macro := this.GetMacroStr(LineArr)
        this.MacroEditStrCon.Value := this.GetMacroEditStr(macro)

        this.DefaultFocusCon.Focus()
    }

    OnAddCmd(LineArr, CommandStr){
        value := LineArr[LineArr.Length]
        if (value == "") {
            LineArr[LineArr.Length] := CommandStr
        }
        else {
            LineArr[LineArr.Length] .= "," CommandStr
        }
        return LineArr
    }

    OnModifyCmd(LineArr, CommandStr){
        value := LineArr[this.EditLineNum]
        cmdArr := StrSplit(value, ",")
        curCmdSymbol := StrSplit(CommandStr, "_")[1]
        loop cmdArr.Length {
            paramArr := StrSplit(cmdArr[A_Index], "_")
            if (paramArr[1] == curCmdSymbol) {
                cmdArr[A_Index] := CommandStr
                break
            }
        }
        newValue := ""
        for index, value in cmdArr {
            newValue .= "," value
        }
        newValue := Trim(newValue, ",")
        LineArr[this.EditLineNum] := newValue
        return LineArr
    }

    OnInsertCmd(LineArr, CommandStr){
        LineArr.InsertAt(this.EditLineNum, CommandStr)
        return LineArr
    }

    OnChangeEditMode() {
        this.EditModeType := this.EditModeCon.Value
        this.CurEditLineNum := 1
        this.RefreshCommandBtn()
        this.DefaultFocusCon.Focus()
    }
}
