#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class SearchGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.PosAction := () => this.RefreshMouseInfo()
        this.SelectToggleCon := ""
        this.MacroEditGui := ""
        this.Data := ""
        this.MousePosCon := ""
        this.MouseColorCon := ""
        this.MouseColorTipCon := ""
        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""
        this.ImageCon := ""
        this.ImageBtn := ""
        this.ScreenshotBtn := ""
        this.HexColorCon := ""
        this.HexColorTipCon := ""
        this.TextCon := ""
        this.SearchCountCon := ""
        this.SearchIntervalCon := ""
        this.FoundCommandStrCon := ""
        this.UnFoundCommandStrCon := ""
        this.SearchTypeCon := ""
        this.AutoTypeCon := ""
        this.SpeedCon := ""
        this.MacroGui := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(cmd)
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "搜索指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S10 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 25
        PosX := 10
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F1")
        con.Enabled := false

        PosX += 30
        this.SelectToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Left", PosX, PosY, 150, 25), "左键框选搜索范围")
        this.SelectToggleCon.OnEvent("Click", (*) => this.OnClickSelectToggle())

        PosX += 150
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F2")
        con.Enabled := false
        PosX += 30
        MyGui.Add("Text", Format("x{} y{} h{} Center", PosX, PosY + 3, 25), "选取当前颜色")

        PosX += 130
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F3")
        con.Enabled := false
        PosX += 30
        MyGui.Add("Text", Format("x{} y{} h{} Center", PosX, PosY + 3, 25), "截图")

        PosX := 10
        PosY += 25
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 230, 20), "当前鼠标坐标:0,0")
        PosX += 330
        this.MouseColorCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 140, 20), "当前鼠标颜色:FFFFFF")
        PosX += 140
        this.MouseColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")
        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "搜索范围:")

        PosX := 330
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索类型:")
        PosX += 80
        this.SearchTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} h{}", PosX, PosY - 3, 80, 100), ["图片", "颜色",
            "文本"])
        this.SearchTypeCon.OnEvent("Change", (*) => this.OnChangeSearchType())
        this.SearchTypeCon.Value := 1
        PosY += 30
        PosX := 10
        SplitPosY := PosY
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
        PosX += 75
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
        PosX += 75
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
        PosX += 75
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
        PosX += 75
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        PosX += 75
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        PosX += 75
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "鼠标动作:")
        PosX += 75
        this.AutoTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 5, 130), ["无动作",
            "移动至目标", "移动至目标点击"])
        this.AutoTypeCon.Value := 1
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "90")
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "鼠标点击次数:")
        PosX += 120
        this.ClickCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "1")
        PosY := SplitPosY
        PosX := 330
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "选择图片")
        btnCon.OnEvent("Click", (*) => this.OnClickSetPicBtn())
        btnCon.Focus()
        this.ImageBtn := btnCon
        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "截图")
        btnCon.OnEvent("Click", (*) => this.OnScreenShotBtnClick())
        this.ScreenshotBtn := btnCon
        PosY += 30
        PosX := 330
        this.ImageCon := MyGui.Add("Picture", Format("x{} y{} w{} h{}", PosX, PosY, 100, 100), "")
        PosY += 110
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 40), "颜色:")
        PosX += 40
        this.HexColorCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "FFFFFF")
        PosX += 90
        this.HexColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")
        PosY += 35
        PosX := 330
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 40), "文本:")
        PosX += 40
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 150, 20), "检索文本")
        PosY += 35
        TempPosY := PosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "找到后的指令:（可选）")
        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())
        PosY += 20
        PosX := 10
        this.FoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 80), "")
        PosY := TempPosY
        PosX := 330
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "未找到后的指令:（可选）")
        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditUnFoundMacroBtnClick())
        PosY += 20
        PosX := 330
        this.UnFoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 80), "")
        TempPosY := PosY
        PosY += 90
        PosX := 270
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 640, 500))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableArr := GetSelectVariableObjArr(macro)

        this.Data := this.GetCompareData(this.SerialStr)
        this.SearchTypeCon.Value := this.Data.SearchType
        this.ImageCon.Value := this.Data.SearchImagePath
        this.HexColorCon.Value := this.Data.SearchColor
        this.TextCon.Value := this.Data.SearchText
        this.StartPosXCon.Value := this.Data.StartPosX
        this.StartPosYCon.Value := this.Data.StartPosY
        this.EndPosXCon.Value := this.Data.EndPosX
        this.EndPosYCon.Value := this.Data.EndPosY
        this.SearchCountCon.Value := this.Data.SearchCount
        this.SearchIntervalCon.Value := this.Data.SearchInterval
        this.AutoTypeCon.Value := this.Data.AutoType
        this.SpeedCon.Value := this.Data.Speed
        this.ClickCountCon.Value := this.Data.ClickCount
        this.FoundCommandStrCon.Value := this.Data.TrueCommandStr
        this.UnFoundCommandStrCon.Value := this.Data.FalseCommandStr
        this.OnChangeSearchType()
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "搜索_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Search" CurrentDateTime
    }

    GetCompareData(SerialStr) {
        saveStr := IniRead(SearchFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := SearchData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    CheckIfValid() {
        if (!IsNumber(this.StartPosXCon.Value) || !IsNumber(this.StartPosYCon.Value) || !IsNumber(this.EndPosXCon.Value
        ) || !IsNumber(this.EndPosYCon.Value)) {
            MsgBox("坐标中请输入数字")
            return false
        }

        if (Number(this.StartPosXCon.Value) > Number(this.EndPosXCon.Value) || Number(this.StartPosYCon.Value) >
        Number(
            this.EndPosYCon.Value)) {
            MsgBox("起始坐标不能大于终止坐标")
            return false
        }

        if (!IsNumber(this.SearchCountCon.Value) || Number(this.SearchCountCon.Value) <= 0) {
            MsgBox("搜索次数请输入大于0的数字")
            return false
        }

        if (this.SearchTypeCon.Value == 1 && this.Data.SearchImagePath == "") {
            MsgBox("请选择图片")
            return false
        }

        if (this.SearchTypeCon.Value == 1) {
            searchWidth := this.EndPosXCon.Value - this.StartPosXCon.Value
            searchHeight := this.EndPosYCon.Value - this.StartPosYCon.Value
            size := GetImageSize(this.Data.SearchImagePath)
            if (size[1] > searchWidth || size[2] > searchHeight) {
                MsgBox("搜索范围不能小于图片大小")
                return false
            }
        }

        if (this.SearchTypeCon.Value == 2 && !RegExMatch(this.HexColorCon.Value, "^([0-9A-Fa-f]{6})$")) {
            MsgBox("请输入正确的颜色值")
            return false
        }

        if (this.SearchTypeCon.Value == 3) {
            if (Number(this.StartPosXCon.Value) == Number(this.EndPosXCon.Value) ||
            Number(this.StartPosYCon.Value) == Number(this.EndPosYCon.Value)) {
                MsgBox("搜索文本时：搜索范围中起始坐标不能和终止坐标相同")
                return false
            }
        }

        return true
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.PosAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.EnableSelectAerea(), "On")
            Hotkey("F2", (*) => this.SureColor(), "On")
            Hotkey("F3", (*) => this.OnScreenShotBtnClick(), "On")
        }
        else {
            SetTimer this.PosAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.EnableSelectAerea(), "Off")
            Hotkey("F2", (*) => this.SureColor(), "Off")
            Hotkey("F3", (*) => this.OnScreenShotBtnClick(), "Off")
        }
    }

    RefreshMouseInfo() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.MousePosCon.Value := "当前鼠标坐标:" mouseX "," mouseY

        CoordMode("Pixel", "Screen")
        Color := PixelGetColor(mouseX, mouseY, "Slow")
        ColorText := StrReplace(Color, "0x", "")
        this.MouseColorCon.Value := "当前鼠标颜色:" ColorText
        this.MouseColorTipCon.Opt(Format("+Background0x{}", ColorText))
        this.MouseColorTipCon.Redraw()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveSearchData()
        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    OnClickSetPicBtn() {
        path := FileSelect(, , "选择图片")
        this.ImageCon.Value := path
        this.Data.SearchImagePath := path
    }

    OnScreenShotBtnClick() {
        A_Clipboard := ""  ; 清空剪贴板
        Run("ms-screenclip:")
        action := () => this.CheckClipboard()
        SetTimer(action, 500)  ; 每 500 毫秒检查一次剪贴板
    }

    OnSureFoundMacroBtnClick(CommandStr) {
        this.FoundCommandStr := CommandStr
        this.FoundCommandStrCon.Value := CommandStr
    }

    OnSureUnFoundMacroBtnClick(CommandStr) {
        this.UnFoundCommandStr := CommandStr
        this.UnFoundCommandStrCon.Value := CommandStr
    }

    OnEditFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.MousePosCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnSureFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.Data.TrueCommandStr, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.SureFocusCon := this.MousePosCon
        }
        this.MacroGui.SureBtnAction := (command) => this.OnSureUnFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.Data.FalseCommandStr, false)
    }

    OnChangeSearchType() {
        isImage := this.SearchTypeCon.Value == 1
        isColor := this.SearchTypeCon.Value == 2
        isText := this.SearchTypeCon.Value == 3

        showImageTip := isImage && this.Data.SearchImagePath == ""
        showColorTip := isColor && RegExMatch(this.HexColorCon.Value, "^([0-9A-Fa-f]{6})$")

        this.ImageBtn.Enabled := isImage
        this.ScreenshotBtn.Enabled := isImage

        this.HexColorCon.Enabled := isColor
        this.HexColorTipCon.Visible := showColorTip
        if (showColorTip) {
            this.HexColorTipCon.Opt(Format("+Background0x{}", this.HexColorCon.Value))
            this.HexColorTipCon.Redraw()
        }

        this.TextCon.Enabled := isText
        this.MousePosCon.Focus()
    }

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveSearchData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnSearch(tableItem, this.GetCommandStr(), 1)
    }

    OnClickSelectToggle() {
        state := this.SelectToggleCon.Value
        if (state == 1)
            this.EnableSelectAerea()
        else
            this.DisSelectArea()
    }

    EnableSelectAerea() {
        this.SelectToggleCon.Value := 1
        Hotkey("LButton", (*) => this.SelectArea(), "On")
        Hotkey("LButton Up", (*) => this.DisSelectArea(), "On")
    }

    DisSelectArea() {
        this.SelectToggleCon.Value := 0
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
    }

    SureColor() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY

        CoordMode("Pixel", "Screen")
        Color := PixelGetColor(mouseX, mouseY, "Slow")
        ColorText := StrReplace(Color, "0x", "")
        this.HexColorCon.Value := ColorText
        this.HexColor := ColorText
        this.HexColorTipCon.Visible := true
        this.HexColorTipCon.Opt(Format("+Background0x{}", this.HexColorCon.Value))
        this.HexColorTipCon.Redraw()
    }

    CheckClipboard(*) {
        ; 如果剪贴板中有图像
        if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
        {
            ; 获取当前日期和时间，用于生成唯一的文件名
            CurrentDateTime := FormatTime(, "HHmmss")
            filePath := A_WorkingDir "\Images\" CurrentDateTime ".png"
            if (!DirExist(A_WorkingDir "\Images")) {
                DirCreate(A_WorkingDir "\Images")
            }

            ; MyWinClip.SaveBitmap(filePath, "png")
            SaveClipToBitmap(filePath)
            this.ImageCon.Value := filePath
            this.Data.SearchImagePath := filePath
            ; 停止监听
            SetTimer(, 0)
        }
    }

    SaveSearchData() {
        data := this.Data
        data.SearchType := this.SearchTypeCon.Value
        data.SearchColor := this.HexColorCon.Value
        data.SearchText := this.TextCon.Value
        data.StartPosX := this.StartPosXCon.Value
        data.StartPosY := this.StartPosYCon.Value
        data.EndPosX := this.EndPosXCon.Value
        data.EndPosY := this.EndPosYCon.Value
        data.SearchCount := this.SearchCountCon.Value
        data.SearchInterval := this.SearchIntervalCon.Value
        data.AutoType := this.AutoTypeCon.Value
        data.ClickCount := this.ClickCountCon.Value
        data.Speed := this.SpeedCon.Value
        data.TrueCommandStr := this.FoundCommandStrCon.Value
        data.FalseCommandStr := this.UnFoundCommandStrCon.Value
        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, SearchFile, IniSection, data.SerialStr)
    }
}
