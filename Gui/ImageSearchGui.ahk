#Requires AutoHotkey v2.0
#Include MacroGui.ahk

class ImageSearchGui{
    __new(){
        this.Gui := ""
        this.SureBtnAction := ""

        this.MousePosCon := ""

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
        this.ImagePicTipCon := ""

        this.SearchCount := 1
        this.SearchCountCon := ""

        this.SearchInterval := 0
        this.SearchIntervalCon := ""

        this.FoundCommandStr := ""
        this.FoundCommandStrCon := ""

        this.MacroGui := ""
    }

    InitSubGui(){
        this.MacroGui := MacroGui()
        this.MacroGui.SureBtnAction := (command) => this.OnSubGuiSureBtnClick(command)
    }

    ShowGui(){
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else{
            this.AddGui()
        }

        this.Init()
        this.Refresh()
        this.ToggleRefreshMousePos(true)
    }

    AddGui() {
        MyGui := Gui(,"图片搜索指令编辑")
        this.Gui := MyGui

        PosX := 10
        PosY := 10
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", 10, 10, 150, 20), "当前鼠标坐标:0,0")

        PosY += 30
        SplitPosY := PosY
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "搜索范围:")

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
        PosX += 75
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.StartPosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
        PosX += 75
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.StartPosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
        PosX += 75
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.EndPosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
        PosX += 75
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.EndPosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())
        PosY += 30

        EndCoordSplitPosY := PosY

        PosY := SplitPosY
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "选择图片")
        btnCon.OnEvent("Click", (*) => this.OnClickSetPicBtn())

        PosX += 100
        this.ImagePicTipCon := MyGui.Add("Text", Format("x{} y{} w{} h{} Background{}", PosX, PosY, 80, 20, "FF0000"), "请选择图片")

        PosY += 30
        PosX := 200
        this.ImageCon := MyGui.Add("Picture", Format("x{} y{} w{} h{}", PosX, PosY, 100, 100), "")

        PosY += 30
        EndPicSplitPosY := PosY

        PosY := Max(EndCoordSplitPosY, EndPicSplitPosY)
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        PosX += 75
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.SearchCountCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        PosX += 75
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.SearchIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 120, 20), "找到图片后的指令:")

        PosX += 120
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY-5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditCommandBtnClick())

        PosY += 20
        PosX := 10
        this.FoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 380, 40), "")
        this.FoundCommandStrCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX := 10
        PosY += 45
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:")
        PosY += 25
        this.CommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 380, 50), "ImageSearch_XXX.png_0,0,100,100")

        PosY += 60
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "备注：找到图片后鼠标指针默认移动到图片中心")

        PosY += 30
        PosX += 150
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.OnCloseGui())
        MyGui.Show(Format("w{} h{}", 400, 450))
    }

    Init(){
        this.StartPosX := 0
        this.StartPosY := 0
        this.EndPosX := A_ScreenWidth
        this.EndPosY := A_ScreenHeight
        this.SearchCount := 1
        this.SearchInterval := 1000

        this.StartPosXCon.Value := this.StartPosX
        this.StartPosYCon.Value := this.StartPosY
        this.EndPosXCon.Value := this.EndPosX
        this.EndPosYCon.Value := this.EndPosY
        this.SearchCountCon.Value := this.SearchCount
        this.SearchIntervalCon.Value := this.SearchInterval
    }

    UpdateCommandStr(){
        this.CommandStr := "ImageSearch"
        this.CommandStr .= "_" this.ImagePath
        this.CommandStr .= "_" this.StartPosXCon.Value
        this.CommandStr .= "_" this.StartPosYCon.Value
        this.CommandStr .= "_" this.EndPosXCon.Value
        this.CommandStr .= "_" this.EndPosYCon.Value
        this.CommandStr .= "_" this.SearchCountCon.Value
        this.CommandStr .= "_" this.SearchIntervalCon.Value
        if (this.FoundCommandStr!= ""){
            this.CommandStr .= "(" this.FoundCommandStr ")"
        }
    }

    ToggleRefreshMousePos(state){
        action := () => this.RefreshMousePos()
        if (state){
            SetTimer action, 100
        }
        else{
            SetTimer action, 0
        }
    }

    RefreshMousePos(){
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.MousePosCon.Value := "当前鼠标坐标:" mouseX "," mouseY
    }

    Refresh(){
        this.UpdateCommandStr()
        this.CommandStrCon.Value := this.CommandStr
        showImageTip := this.ImagePath == ""
        this.ImagePicTipCon.Visible := showImageTip
    }

    OnChangeEditValue(){
        this.StartPosX := this.StartPosXCon.Value
        this.StartPosY := this.StartPosYCon.Value
        this.EndPosX := this.EndPosXCon.Value
        this.EndPosY := this.EndPosYCon.Value
        this.SearchCount := this.SearchCountCon.Value
        this.SearchInterval := this.SearchIntervalCon.Value
        this.FoundCommandStr := this.FoundCommandStrCon.Value
        this.Refresh()
    }

    OnClickSureBtn(){
        if (this.SureBtnAction == "")
            return

        if (!IsNumber(this.StartPosXCon.Value) || !IsNumber(this.StartPosYCon.Value) || !IsNumber(this.EndPosXCon.Value) || !IsNumber(this.EndPosYCon.Value)){
            MsgBox("坐标中请输入数字")
            return
        }

        if (Number(this.StartPosXCon.Value) > Number(this.EndPosXCon.Value) || Number(this.StartPosYCon.Value) > Number(this.EndPosYCon.Value)){
            MsgBox("起始坐标不能大于终止坐标")
            return
        }

        if (RegExMatch(this.ImagePath, "_")){
            MsgBox("图片路径中不能包含下划线")
            return
        }

        this.UpdateCommandStr()
        action := this.SureBtnAction
        action(this.CommandStr)
        this.ToggleRefreshMousePos(false)
        this.Gui.Hide()
    }

    OnCloseGui(){
        this.ToggleRefreshMousePos(false)
    }

    OnClickSetPicBtn(){
        path := FileSelect(,,"选择图片")
        this.ImagePath := path
        this.ImageCon.Value := path
        this.Refresh()
    }

    OnSubGuiSureBtnClick(CommandStr){
        this.FoundCommandStr := CommandStr
        this.FoundCommandStrCon.Value := CommandStr
        this.Refresh()
    }

    OnEditCommandBtnClick(){
        if (this.MacroGui == "" ){
            this.MacroGui := MacroGui()
            this.MacroGui.SureBtnAction := (command) => this.OnSubGuiSureBtnClick(command)
        }
        this.MacroGui.ShowGui(this.FoundCommandStr, false)
    }
}