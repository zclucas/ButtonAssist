#Requires AutoHotkey v2.0
#Include MacroGui.ahk

class SearchGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.PosAction := () => this.RefreshMouseInfo()

        this.MousePosCon := ""
        this.MouseColorCon := ""
        this.MouseColorTipCon := ""

        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := 0
        this.EndPosY := 0

        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""

        this.CommandStr := ""
        this.CommandStrCon := ""

        this.ImagePath := ""
        this.ImageCon := ""
        this.ImageBtn := ""
        this.ScreenshotBtn := ""

        this.HexColor := ""
        this.HexColorCon := ""
        this.HexColorTipCon := ""

        this.Text := ""
        this.TextCon := ""

        this.SearchCount := 1
        this.SearchCountCon := ""

        this.SearchInterval := 0
        this.SearchIntervalCon := ""

        this.FoundCommandStr := ""
        this.FoundCommandStrCon := ""

        this.UnFoundCommandStr := ""
        this.UnFoundCommandStrCon := ""

        this.SearchType := 1
        this.SearchTypeCon := ""

        this.AutoMove := 1
        this.AutoMoveCon := ""

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
        this.Refresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "搜索指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:选取搜索范围  F2:选取当前颜色")

        PosX := 10
        PosY += 20
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 150, 20), "当前鼠标坐标:0,0")
        PosX += 180
        this.MouseColorCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 140, 20), "当前鼠标颜色:FFFFFF")
        PosX += 140
        this.MouseColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "搜索范围:")

        PosX += 210
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索类型:")
        PosX += 80
        this.SearchTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{} h{}", PosX, PosY - 3, 80, 100), ["图片", "颜色",
            "文本"])
        this.SearchTypeCon.OnEvent("Change", (*) => this.OnChangeSearchType())
        this.SearchTypeCon.Value := 1

        PosY += 30
        PosX := 10
        SplitPosY := PosY
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

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        PosX += 75
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        this.SearchIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        con := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 180), "找到后鼠标移动至目标点")
        con.OnEvent("Click", (*) => this.OnChangeAutoMove())
        this.AutoMoveCon := con
        EndSplitPosY := PosY + 35

        PosY := SplitPosY
        PosX := 220
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "选择图片")
        btnCon.OnEvent("Click", (*) => this.OnClickSetPicBtn())
        btnCon.Focus()
        this.ImageBtn := btnCon

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "截图")
        btnCon.OnEvent("Click", (*) => this.OnScreenShotBtnClick())
        this.ScreenshotBtn := btnCon

        PosY += 30
        PosX := 220
        this.ImageCon := MyGui.Add("Picture", Format("x{} y{} w{} h{}", PosX, PosY, 100, 100), "")

        PosY += 110
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 40), "颜色:")
        PosX += 40
        this.HexColorCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "FFFFFF")
        this.HexColorCon.OnEvent("Change", (*) => this.OnChangeEditValue())
        PosX += 90
        this.HexColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")

        PosY += 35
        PosX := 220
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 40), "文本:")
        PosX += 40
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 150, 20), "检索文本")
        this.TextCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY := EndSplitPosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "找到后的指令:（可选）")

        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())

        PosY += 20
        PosX := 10
        this.FoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 430, 50), "")
        this.FoundCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 60
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "未找到后的指令:（可选）")

        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditUnFoundMacroBtnClick())

        PosY += 20
        PosX := 10
        this.UnFoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 430, 50), "")
        this.UnFoundCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX := 10
        PosY += 55
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:")
        PosY += 25
        this.CommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 430, 60),
        "ImageSearch_XXX.png_0,0,100,100")

        PosY += 70
        PosX += 175
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 450, 610))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? SplitCommand(cmd) : []
        searchCmdArr := cmdArr.Length >= 1 ? StrSplit(cmdArr[1], "_") : []
        isSearchColor := searchCmdArr.Length >= 1 ? searchCmdArr[1] == "搜索颜色" : false
        isSearchImage := searchCmdArr.Length >= 1 ? searchCmdArr[1] == "搜索图片" : false
        isSearchText := searchCmdArr.Length >= 1 ? searchCmdArr[1] == "搜索文本" : false

        this.StartPosX := searchCmdArr.Length >= 3 ? searchCmdArr[3] : 0
        this.StartPosY := searchCmdArr.Length >= 4 ? searchCmdArr[4] : 0
        this.EndPosX := searchCmdArr.Length >= 5 ? searchCmdArr[5] : A_ScreenWidth
        this.EndPosY := searchCmdArr.Length >= 6 ? searchCmdArr[6] : A_ScreenHeight
        this.AutoMove := searchCmdArr.Length >= 7 ? searchCmdArr[7] : 1
        this.SearchCount := searchCmdArr.Length >= 8 ? searchCmdArr[8] : 1
        this.SearchInterval := searchCmdArr.Length >= 9 ? searchCmdArr[9] : 1000
        this.FoundCommandStr := cmdArr.Length >= 2 ? cmdArr[2] : ""
        this.UnFoundCommandStr := cmdArr.Length >= 3 ? cmdArr[3] : ""

        if (isSearchImage) {
            this.SearchType := 1
            this.ImagePath := searchCmdArr[2]
            this.ImageCon.Value := ""
        }
        if (isSearchColor) {
            this.SearchType := 2
            this.HexColor := searchCmdArr[2]
        }
        if (isSearchText) {
            this.SearchType := 3
            this.Text := searchCmdArr[2]
        }

        this.ImageCon.Value := this.ImagePath
        this.StartPosXCon.Value := this.StartPosX
        this.StartPosYCon.Value := this.StartPosY
        this.EndPosXCon.Value := this.EndPosX
        this.EndPosYCon.Value := this.EndPosY
        this.SearchCountCon.Value := this.SearchCount
        this.SearchIntervalCon.Value := this.SearchInterval
        this.HexColorCon.Value := this.HexColor
        this.TextCon.Value := this.Text
        this.SearchTypeCon.Value := this.SearchType
        this.AutoMoveCon.Value := this.AutoMove
        this.FoundCommandStrCon.Value := this.FoundCommandStr
        this.UnFoundCommandStrCon.Value := this.UnFoundCommandStr
    }

    UpdateCommandStr() {
        if (this.SearchType == 1) {
            this.CommandStr := "搜索图片"
            this.CommandStr .= "_" this.ImagePath
        }
        else if (this.SearchType == 2) {
            this.CommandStr := "搜索颜色"
            this.CommandStr .= "_" this.HexColorCon.Value
        }
        else if (this.SearchType == 3) {
            this.CommandStr := "搜索文本"
            this.CommandStr .= "_" this.TextCon.Value
        }

        this.CommandStr .= "_" this.StartPosXCon.Value
        this.CommandStr .= "_" this.StartPosYCon.Value
        this.CommandStr .= "_" this.EndPosXCon.Value
        this.CommandStr .= "_" this.EndPosYCon.Value
        this.CommandStr .= "_" this.AutoMove
        this.CommandStr .= "_" this.SearchCountCon.Value
        this.CommandStr .= "_" this.SearchIntervalCon.Value

        if (this.FoundCommandStr != "") {
            this.CommandStr .= "(" this.FoundCommandStr ")"
        }

        if (this.UnFoundCommandStr != "") {
            this.CommandStr .= "(" this.UnFoundCommandStr ")"
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

        if (RegExMatch(this.ImagePath, "_")) {
            MsgBox("图片路径中不能包含下划线")
            return false
        }

        if (this.SearchType == 1 && this.ImagePath == "") {
            MsgBox("请选择图片")
            return false
        }

        if (this.SearchType == 2 && !RegExMatch(this.HexColorCon.Value, "^([0-9A-Fa-f]{6})$")) {
            MsgBox("请输入正确的颜色值")
            return false
        }

        return true
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.PosAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*)=> this.EnableSelectAerea(), "On")
            Hotkey("F2", (*) => this.SureColor(), "On")
        }
        else {
            SetTimer this.PosAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*)=> this.EnableSelectAerea(), "Off")
            Hotkey("F2", (*) => this.SureColor(), "Off")
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

    Refresh() {
        this.UpdateCommandStr()
        this.RefreshSearchEnabled()
        this.CommandStrCon.Value := this.CommandStr
    }

    OnChangeEditValue() {
        this.StartPosX := this.StartPosXCon.Value
        this.StartPosY := this.StartPosYCon.Value
        this.EndPosX := this.EndPosXCon.Value
        this.EndPosY := this.EndPosYCon.Value
        this.SearchCount := this.SearchCountCon.Value
        this.SearchInterval := this.SearchIntervalCon.Value
        this.FoundCommandStr := this.FoundCommandStrCon.Value
        this.UnFoundCommandStr := this.UnFoundCommandStrCon.Value
        this.HexColor := this.HexColorCon.Value
        this.Text := this.TextCon.Value
        this.Refresh()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return

        this.UpdateCommandStr()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    OnClickSetPicBtn() {
        path := FileSelect(, , "选择图片")
        this.ImagePath := path
        this.ImageCon.Value := path
        this.Refresh()
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
        this.Refresh()
    }

    OnSureUnFoundMacroBtnClick(CommandStr) {
        this.UnFoundCommandStr := CommandStr
        this.UnFoundCommandStrCon.Value := CommandStr
        this.Refresh()
    }

    OnEditFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroGui()
            this.MacroGui.SureFocusCon := this.MousePosCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnSureFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.FoundCommandStr, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroGui()
            this.MacroGui.SureFocusCon := this.MousePosCon
        }
        this.MacroGui.SureBtnAction := (command) => this.OnSureUnFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.UnFoundCommandStr, false)
    }

    OnChangeSearchType() {
        this.SearchType := this.SearchTypeCon.Value
        this.Refresh()
        this.MousePosCon.Focus()
    }

    RefreshSearchEnabled() {
        isImage := this.SearchType == 1
        isColor := this.SearchType == 2
        isText := this.SearchType == 3

        showImageTip := isImage && this.ImagePath == ""
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
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.ActionArr[1] := Map()
        OnSearch(tableItem, this.CommandStr, 1)
    }

    EnableSelectAerea() {
        Hotkey("LButton", (*)=>this.SelectArea(), "On")
        Hotkey("LButton Up", (*)=>this.DisSelectArea(), "On")
    }

    DisSelectArea(*) {
        Hotkey("LButton", (*)=>this.SelectArea(), "Off")
        Hotkey("LButton Up", (*)=>this.DisSelectArea(), "Off")
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
        this.Refresh()
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
            this.ImagePath := filePath
            this.ImageCon.Value := filePath
            this.Refresh()
            ; 停止监听
            SetTimer(, 0)
        }
    }
}
