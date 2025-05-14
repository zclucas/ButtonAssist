#Requires AutoHotkey v2.0

class IntervalGui{
    __new(){
        this.Gui := ""
        this.SureBtnAction := ""
        this.TimeTextCon := ""
    }

    ShowGui(cmd){
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else{
            this.AddGui()
        }

        this.TimeTextCon.Value := ""
        if (cmd != ""){
            cmdArr := StrSplit(cmd, "_")
            this.TimeTextCon.Value := cmdArr[2]
        }
    }

    AddGui() {
        MyGui := Gui(, "指令间隔编辑")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 300, 20), "指令间隔时间(毫秒)")

        PosY += 20
        this.TimeTextCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY, 300))

        PosY += 40
        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.Show(Format("w{} h{}", 320, 120))
    }

    OnClickSureBtn(){
        if (this.SureBtnAction == "")
            return

        timeText := this.TimeTextCon.Value
        if (!IsInteger(timeText) || Integer(timeText) < 0){
            MsgBox("请输入大于等于0的整数")
            return
        }

        action := this.SureBtnAction
        action("间隔_" timeText)
        this.Gui.Hide()
    }
}