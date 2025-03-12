#Requires AutoHotkey v2.0
#Include MacroGui.ahk

class SearchGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""

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
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 60, 20), "快捷方式:")
        PosX += 60
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosY += 20
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "S:确定起始坐标   E:确定终止坐标  C:选取当前颜色")

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
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), "搜索类型:")
        PosX += 60
        this.SearchTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{} h{}", PosX, PosY - 3, 80, 100), ["图片", "颜色"])
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

        PosY += 20
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

        PosY := EndSplitPosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "找到后的指令:")

        PosX += 120
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())

        PosY += 20
        PosX := 10
        this.FoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 430, 50), "")
        this.FoundCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 60
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "未找到后的指令:")

        PosX += 120
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
        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := A_ScreenWidth
        this.EndPosY := A_ScreenHeight
        this.SearchCount := 1
        this.SearchInterval := 1000
        this.HexColor := "FFFFFF"
        this.SearchType := 1
        this.AutoMove := 1
        this.ImagePath := ""
        this.FoundCommandStr := ""
        this.UnFoundCommandStr := ""

        if (cmd != "") {
            cmdArr := SplitCommand(cmd)
            searchCmdArr := StrSplit(cmdArr[1], "_")
            this.StartPosX := searchCmdArr[3]
            this.StartPosY := searchCmdArr[4]
            this.EndPosX := searchCmdArr[5]
            this.EndPosY := searchCmdArr[6]
            this.AutoMove := searchCmdArr[7]
            this.SearchCount := searchCmdArr[8]
            this.SearchInterval := searchCmdArr[9]

            isSearchImage := searchCmdArr[1] == "搜索图片"
            if (isSearchImage) {
                this.SearchType := 1
                this.ImagePath := searchCmdArr[2]
                this.ImageCon.Value := ""
            }
            else {
                this.SearchType := 2
                this.HexColor := searchCmdArr[2]
            }

            this.FoundCommandStr := cmdArr[2]
            this.UnFoundCommandStr := cmdArr[3]
        }

        this.ImageCon.Value := this.ImagePath
        this.StartPosXCon.Value := this.StartPosX
        this.StartPosYCon.Value := this.StartPosY
        this.EndPosXCon.Value := this.EndPosX
        this.EndPosYCon.Value := this.EndPosY
        this.SearchCountCon.Value := this.SearchCount
        this.SearchIntervalCon.Value := this.SearchInterval
        this.HexColorCon.Value := this.HexColor
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
        PosAction := () => this.RefreshMouseInfo()
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer PosAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("S", (*) => this.SureStartCoord(), "On")
            Hotkey("E", (*) => this.SureEndCoord(), "On")
            Hotkey("C", (*) => this.SureColor(), "On")
        }
        else {
            SetTimer PosAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("S", (*) => this.SureStartCoord(), "Off")
            Hotkey("E", (*) => this.SureEndCoord(), "Off")
            Hotkey("C", (*) => this.SureColor(), "Off")
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
        tableItem.SearchActionArr[1] := Map()
        OnSearch(tableItem, this.CommandStr, 1)
    }

    SureStartCoord() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.StartPosXCon.Value := mouseX
        this.StartPosYCon.Value := mouseY
        this.Refresh()
    }

    SureEndCoord() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.EndPosXCon.Value := mouseX
        this.EndPosYCon.Value := mouseY
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
            if (!DirExist(A_WorkingDir "\Images")){
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
