#Requires AutoHotkey v2.0

class MouseMoveGui{
    __new(){
        this.Gui := ""
        this.SureBtnAction := ""
        this.PosX := 0
        this.PosY := 0
        this.Speed := 0
        this.IsRelative := false
        this.IsOffset := false
        this.PosXCon := ""
        this.PosYCon := ""
        this.SpeedCon := ""
        this.CommandStr := ""
        this.CommandStrCon := ""
        this.RelativeCon := ""
        this.OffsetCon := ""

        this.MousePosCon := ""
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
        MyGui := Gui(,"鼠标移动指令编辑")
        this.Gui := MyGui

        PosX := 10
        PosY := 10
        this.MousePosCon :=MyGui.Add("Text", Format("x{} y{} w{} h{}", 10, 10, 380, 20), "当前鼠标位置:0,0")

        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置X:")
        PosX += 80
        this.PosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.PosXCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 120
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "坐标位置Y:")
        PosX += 80
        this.PosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.PosYCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50))
        this.SpeedCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 120
        this.RelativeCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 100, 20), "相对位移")
        this.RelativeCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        this.OffsetCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY, 150, 20), "偏移(可调整游戏视角)")
        this.OffsetCon.OnEvent("Click", (*) => this.OnChangeEditValue())

        PosY += 30
        PosX := 10
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 350), "当前指令:MouseMove_0_0_0")

        PosY += 40
        PosX += 150
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.OnCloseGui())
        MyGui.Show(Format("w{} h{}", 400, 230))
    }

    Init(){
        this.PosX := 0
        this.PosY := 0
        this.Speed := 90
        this.IsRelative := 0
        this.IsOffset := 0

        this.PosXCon.Value := this.PosX
        this.PosYCon.Value := this.PosY
        this.SpeedCon.Value := this.Speed
        this.RelativeCon.Value := this.IsRelative
        this.OffsetCon.Value := this.IsOffset
    }

    UpdateCommandStr(){
        this.CommandStr := "MouseMove"
        this.CommandStr .= "_" this.PosXCon.Value
        this.CommandStr .= "_" this.PosYCon.Value
        this.CommandStr .= "_" this.SpeedCon.Value
        this.CommandStr .= "_" this.RelativeCon.Value
        this.CommandStr .= "_" this.OffsetCon.Value
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
        this.MousePosCon.Value := "当前鼠标位置:" mouseX "," mouseY
    }

    Refresh(){
        this.UpdateCommandStr()
        this.CommandStrCon.Value := "当前指令:" this.CommandStr
    }

    OnChangeEditValue(){
        this.PosX := this.PosXCon.Value
        this.PosY := this.PosYCon.Value
        this.Speed := this.SpeedCon.Value
        this.IsRelative := this.RelativeCon.Value
        this.IsOffset := this.OffsetCon.Value
        this.Refresh()
    }

    OnClickSureBtn(){
        if (this.SureBtnAction == "")
            return

        if (!IsNumber(this.PosXCon.Value)){
            MsgBox("坐标X请输入数字")
            return
        }

        if (!IsNumber(this.PosYCon.Value)){
            MsgBox("坐标Y请输入数字")
            return
        }
        
        if (!IsInteger(this.SpeedCon.Value)){
            MsgBox("移动速度请输入整数")
            return
        }

        if (IsInteger(this.SpeedCon.Value) && ((Integer(this.SpeedCon.Value) < 0 || Integer(this.SpeedCon.Value) > 100))){
            MsgBox("移动速度请输入0~100的整数")
            return
        }

        
        if (!IsInteger(this.PosXCon.Text) || Integer(this.PosYCon.Text) < 0){
            MsgBox("请输入大于等于0的整数")
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
}