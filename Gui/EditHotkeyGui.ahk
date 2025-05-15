#Requires AutoHotkey v2.0

class EditHotkeyGui {
    __new() {
        this.Gui := ""
        this.KeyCon := ""
        this.OnlyTriggerKey := false
        this.TriggerStrBtnCon := ""
    }

    ShowGui(KeyCon, OnlyTriggerKey) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.KeyCon := KeyCon
        this.OnlyTriggerKey := OnlyTriggerKey
        this.TriggerStrBtnCon.Enabled := !this.OnlyTriggerKey
    }

    AddGui() {
        MyGui := Gui(, "快捷方式编辑")
        this.Gui := MyGui
        MyGui.SetFont("S12 W550 Q2", "Consolas")

        PosX := 75
        PosY := 30
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 50), "快捷键")
        con.OnEvent("Click", (*) => this.OnEditHotKey(MyTriggerKeyGui))

        PosX += 150
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 50), "字串")
        con.OnEvent("Click", (*) => this.OnEditHotKey(MyTriggerStrGui))
        this.TriggerStrBtnCon := con

        MyGui.Show(Format("w{} h{}", 420, 120))
    }

    OnEditHotKey(gui) {
        triggerKey := this.KeyCon.Value
        gui.SureBtnAction := (sureTriggerStr) => this.KeyCon.Value := sureTriggerStr
        gui.ShowGui(triggerKey, false)
        this.Gui.Hide()
    }
}
