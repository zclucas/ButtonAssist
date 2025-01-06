#Requires AutoHotkey v2.0

class KeyGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.KeyStr := ""
        this.HoldTime := 50
        this.KeyCount := 1
        this.PerInterval := 100
        this.CommandStr := ""

        this.HoldTimeCon := ""
        this.PerIntervalCon := ""
        this.KeyCountCon := ""
        this.CommandStrCon := ""
    }

    ShowGui() {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init()
        this.Refresh()
    }

    AddGui() {
        MyGui := Gui(,"按键指令编辑")
        this.Gui := MyGui
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", 10, 10, 1240, 440), "请从下面按钮中选择按键：")
        PosX := 20
        PosY := 25
        {
            MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "键盘")

            PosY += 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Esc")
            con.OnEvent("Click", (*) => this.OnCheckKey("Esc"))

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F1")
            con.OnEvent("Click", (*) => this.OnCheckKey("F1"))            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F2")
            con.OnEvent("Click", (*) => this.OnCheckKey("F2"))            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F3")
            con.OnEvent("Click", (*) => this.OnCheckKey("F3")) 

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F4")
            con.OnEvent("Click", (*) => this.OnCheckKey("F4"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F5")
            con.OnEvent("Click", (*) => this.OnCheckKey("F5"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F6")
            con.OnEvent("Click", (*) => this.OnCheckKey("F6"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F7")
            con.OnEvent("Click", (*) => this.OnCheckKey("F7"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F8")
            con.OnEvent("Click", (*) => this.OnCheckKey("F8"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F9")
            con.OnEvent("Click", (*) => this.OnCheckKey("F9"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F10")
            con.OnEvent("Click", (*) => this.OnCheckKey("F10"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F11")
            con.OnEvent("Click", (*) => this.OnCheckKey("F11"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F12")
            con.OnEvent("Click", (*) => this.OnCheckKey("F12"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "PrtScr")
            con.OnEvent("Click", (*) => this.OnCheckKey("PrintScreen"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Scroll")
            con.OnEvent("Click", (*) => this.OnCheckKey("ScrollLock"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Pause")
            con.OnEvent("Click", (*) => this.OnCheckKey("Pause"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "~")
            con.OnEvent("Click", (*) => this.OnCheckKey("``"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "1")
            con.OnEvent("Click", (*) => this.OnCheckKey("1"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "2")
            con.OnEvent("Click", (*) => this.OnCheckKey("2"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "3")
            con.OnEvent("Click", (*) => this.OnCheckKey("3"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "4")
            con.OnEvent("Click", (*) => this.OnCheckKey("4"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "5")
            con.OnEvent("Click", (*) => this.OnCheckKey("5"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "6")
            con.OnEvent("Click", (*) => this.OnCheckKey("6"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "7")
            con.OnEvent("Click", (*) => this.OnCheckKey("7"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "8")
            con.OnEvent("Click", (*) => this.OnCheckKey("8"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "9")
            con.OnEvent("Click", (*) => this.OnCheckKey("9"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "0")
            con.OnEvent("Click", (*) => this.OnCheckKey("0"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "-")
            con.OnEvent("Click", (*) => this.OnCheckKey("-"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "+")
            con.OnEvent("Click", (*) => this.OnCheckKey("+"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Backspace")
            con.OnEvent("Click", (*) => this.OnCheckKey("BS"))
            

            PosX += 125
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Ins")
            con.OnEvent("Click", (*) => this.OnCheckKey("Ins"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Home")
            con.OnEvent("Click", (*) => this.OnCheckKey("Home"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "PgUp")
            con.OnEvent("Click", (*) => this.OnCheckKey("PgUp"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Num")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumLock"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "/")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadDiv"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "*")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadMult"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "-")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadSub"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Tab")
            con.OnEvent("Click", (*) => this.OnCheckKey("Tab"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Q")
            con.OnEvent("Click", (*) => this.OnCheckKey("Q"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "W")
            con.OnEvent("Click", (*) => this.OnCheckKey("W"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "E")
            con.OnEvent("Click", (*) => this.OnCheckKey("E"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "R")
            con.OnEvent("Click", (*) => this.OnCheckKey("R"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "T")
            con.OnEvent("Click", (*) => this.OnCheckKey("T"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Y")
            con.OnEvent("Click", (*) => this.OnCheckKey("Y"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "U")
            con.OnEvent("Click", (*) => this.OnCheckKey("U"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "I")
            con.OnEvent("Click", (*) => this.OnCheckKey("I"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "O")
            con.OnEvent("Click", (*) => this.OnCheckKey("O"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "P")
            con.OnEvent("Click", (*) => this.OnCheckKey("P"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "[")
            con.OnEvent("Click", (*) => this.OnCheckKey("["))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "]")
            con.OnEvent("Click", (*) => this.OnCheckKey("]"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "|")
            con.OnEvent("Click", (*) => this.OnCheckKey("|"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Del")
            con.OnEvent("Click", (*) => this.OnCheckKey("Del"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "End")
            con.OnEvent("Click", (*) => this.OnCheckKey("End"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "PgDn")
            con.OnEvent("Click", (*) => this.OnCheckKey("PgDn"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "7")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad7"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "8")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad8"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "9")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad9"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "+")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadAdd"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "CapsLock")
            con.OnEvent("Click", (*) => this.OnCheckKey("CapsLock"))
            

            PosX += 90
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "A")
            con.OnEvent("Click", (*) => this.OnCheckKey("A"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "S")
            con.OnEvent("Click", (*) => this.OnCheckKey("S"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "D")
            con.OnEvent("Click", (*) => this.OnCheckKey("D"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "F")
            con.OnEvent("Click", (*) => this.OnCheckKey("F"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "G")
            con.OnEvent("Click", (*) => this.OnCheckKey("G"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "H")
            con.OnEvent("Click", (*) => this.OnCheckKey("H"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "J")
            con.OnEvent("Click", (*) => this.OnCheckKey("J"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "K")
            con.OnEvent("Click", (*) => this.OnCheckKey("K"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "L")
            con.OnEvent("Click", (*) => this.OnCheckKey("L"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), ";")
            con.OnEvent("Click", (*) => this.OnCheckKey(";"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "'")
            con.OnEvent("Click", (*) => this.OnCheckKey("'"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Enter")
            con.OnEvent("Click", (*) => this.OnCheckKey("Enter"))
            

            PosX += 360
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "4")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad4"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "5")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad5"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "6")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad6"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "LShift")
            con.OnEvent("Click", (*) => this.OnCheckKey("LShift"))
            

            PosX += 110
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Z")
            con.OnEvent("Click", (*) => this.OnCheckKey("Z"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "X")
            con.OnEvent("Click", (*) => this.OnCheckKey("X"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "C")
            con.OnEvent("Click", (*) => this.OnCheckKey("C"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "V")
            con.OnEvent("Click", (*) => this.OnCheckKey("V"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "B")
            con.OnEvent("Click", (*) => this.OnCheckKey("B"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "N")
            con.OnEvent("Click", (*) => this.OnCheckKey("N"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "M")
            con.OnEvent("Click", (*) => this.OnCheckKey("M"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), ",")
            con.OnEvent("Click", (*) => this.OnCheckKey(","))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), ".")
            con.OnEvent("Click", (*) => this.OnCheckKey("."))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "/")
            con.OnEvent("Click", (*) => this.OnCheckKey("/"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "RShift")
            con.OnEvent("Click", (*) => this.OnCheckKey("RShift"))
            

            PosX += 200
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "↑")
            con.OnEvent("Click", (*) => this.OnCheckKey("Up"))
            

            PosX += 165
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "1")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad1"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "2")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad2"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "3")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad3"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Enter")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadEnter"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "LCtrl")
            con.OnEvent("Click", (*) => this.OnCheckKey("LCtrl"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Win")
            con.OnEvent("Click", (*) => this.OnCheckKey("Win"))
            

            PosX += 50
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "LAlt")
            con.OnEvent("Click", (*) => this.OnCheckKey("LAlt"))
            

            PosX += 150
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Space")
            con.OnEvent("Click", (*) => this.OnCheckKey("Space"))
            

            PosX += 200
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "RAlt")
            con.OnEvent("Click", (*) => this.OnCheckKey("RAlt"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "AppsKey")
            con.OnEvent("Click", (*) => this.OnCheckKey("AppsKey"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "RCtrl")
            con.OnEvent("Click", (*) => this.OnCheckKey("RCtrl"))
            

            PosX += 135
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "←")
            con.OnEvent("Click", (*) => this.OnCheckKey("Left"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "↓")
            con.OnEvent("Click", (*) => this.OnCheckKey("Down"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "→")
            con.OnEvent("Click", (*) => this.OnCheckKey("Right"))
            

            PosX += 90
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "0")
            con.OnEvent("Click", (*) => this.OnCheckKey("Numpad0"))
            

            PosX += 100
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "Del")
            con.OnEvent("Click", (*) => this.OnCheckKey("NumpadDot"))
            

            PosY += 30
            PosX := 20
            con := MyGui.Add("Button", Format("x{} y{} h{}", PosX, PosY, 20), "Ctrl")
            con.OnEvent("Click", (*) => this.OnCheckKey("Ctrl"))

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{} h{}", PosX, PosY, 20), "Win")
            con.OnEvent("Click", (*) => this.OnCheckKey("Win"))

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{} h{}", PosX, PosY, 20), "Shift")
            con.OnEvent("Click", (*) => this.OnCheckKey("Shift"))

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{} h{}", PosX, PosY, 20), "Alt")
            con.OnEvent("Click", (*) => this.OnCheckKey("Alt"))

            PosY += 30
            PosX := 20
            MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "多媒体键")

            PosY += 15
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "后退")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Back"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "前进")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Forward"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "刷新")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Refresh"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "停止")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Stop"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "搜索")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Search"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "收藏夹")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Favorites"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "主页")
            con.OnEvent("Click", (*) => this.OnCheckKey("Browser_Home"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "静音")
            con.OnEvent("Click", (*) => this.OnCheckKey("Volume_Mute"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "调低音量")
            con.OnEvent("Click", (*) => this.OnCheckKey("Volume_Down"))
            

            PosX += 80
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "增加音量")
            con.OnEvent("Click", (*) => this.OnCheckKey("Volume_Up"))
            

            PosX += 80
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "下一首")
            con.OnEvent("Click", (*) => this.OnCheckKey("Media_Next"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "上一首")
            con.OnEvent("Click", (*) => this.OnCheckKey("Media_Prev"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "停止")
            con.OnEvent("Click", (*) => this.OnCheckKey("Media_Stop"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "播放/暂停")
            con.OnEvent("Click", (*) => this.OnCheckKey("Media_Play_Pause"))
            

            PosX += 90
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "此电脑")
            con.OnEvent("Click", (*) => this.OnCheckKey("Launch_App1"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "计算器")
            con.OnEvent("Click", (*) => this.OnCheckKey("Launch_App2"))
            

            PosY += 30
            PosX := 20
            MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "鼠标")

            PosY += 15
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "左键")
            con.OnEvent("Click", (*) => this.OnCheckKey("LButton"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "中键")
            con.OnEvent("Click", (*) => this.OnCheckKey("MButton"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "右键")
            con.OnEvent("Click", (*) => this.OnCheckKey("RButton"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "下滑")
            con.OnEvent("Click", (*) => this.OnCheckKey("WheelDown"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "上滑")
            con.OnEvent("Click", (*) => this.OnCheckKey("WheelUp"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "滚轮左键")
            con.OnEvent("Click", (*) => this.OnCheckKey("WheelLeft"))
            

            PosX += 85
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "滚轮右键")
            con.OnEvent("Click", (*) => this.OnCheckKey("WheelRight"))
            

            PosX += 85
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "侧键1")
            con.OnEvent("Click", (*) => this.OnCheckKey("XButton1"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "侧键2")
            con.OnEvent("Click", (*) => this.OnCheckKey("XButton2"))
            

            PosY += 30
            PosX := 20
            MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "手柄")

            PosY += 15
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮1")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy1"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮2")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy2"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮3")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy3"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮4")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy4"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮5")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy5"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮6")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy6"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮7")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy7"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮8")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy8"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮9")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy9"))
            

            PosX += 60
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮10")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy10"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮11")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy11"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮12")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy12"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮13")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy13"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮14")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy14"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮15")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy15"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮16")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy16"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮17")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy17"))
            

            PosX += 70
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "按钮18")
            con.OnEvent("Click", (*) => this.OnCheckKey("Joy18"))
            

            PosY += 30
            PosX := 20
            MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "摇杆")

            PosY += 15
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴1Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis1Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴1Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis1Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴2Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis2Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴2Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis2Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴3Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis3Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴3Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis3Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴4Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis4Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴4Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis4Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴5Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis5Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴5Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis5Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴6Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis6Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴6Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis6Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴7Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis7Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴7Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis7Max"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴8Min")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis8Min"))
            

            PosX += 75
            con := MyGui.Add("Button", Format("x{} y{}", PosX, PosY), "轴8Max")
            con.OnEvent("Click", (*) => this.OnCheckKey("JoyAxis8Max"))
            
        }

        PosY += 60
        PosX := 20
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 85), "按键按住时间:")
        PosX += 85
        this.HoldTimeCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5 , 50), this.HoldTime)
        this.HoldTimeCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 100
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), "按键次数:")
        PosX += 60
        this.KeyCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50), this.KeyCount)
        this.KeyCountCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 100
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), "每次间隔:")
        PosX += 60
        this.PerIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY-5, 50), this.PerInterval)
        this.PerIntervalCon.OnEvent("Change", (*) => this.OnChangeEditValue())

        PosX += 100
        this.CommandStrCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 300), "当前指令：无")

        PosY += 25
        PosX := 20
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 1000), "备注：请点击按键按钮，并设置按键按住时间、按键次数、每次间隔，最后点击确定按钮。")

        PosY += 30
        PosX := 500
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        
        MyGui.Show(Format("w{} h{}", 1260, 580))
    }

    Init(){
        this.KeyStr := ""
        this.HoldTime := 50
        this.KeyCount := 1
        this.PerInterval := 100

        this.HoldTimeCon.Value := this.HoldTime
        this.KeyCountCon.Value := this.KeyCount
        this.PerIntervalCon.Value := this.PerInterval
    }

    UpdateCommandStr(){
        CommandStr := this.KeyStr
        CommandStr .= "_"
        CommandStr .= this.HoldTime
        if (this.KeyCount > 1){
            CommandStr .= "_"
            CommandStr .= this.KeyCount
            CommandStr .= "_"
            CommandStr .= this.PerInterval
        }
        this.CommandStr := CommandStr
    }

    Refresh(){
        this.UpdateCommandStr()
        this.CommandStrCon.Value := "当前指令：" this.CommandStr
    }

    OnCheckKey(key) {
        this.KeyStr := key
        this.Refresh()
    }

    OnChangeEditValue() {
        if (!IsInteger(this.HoldTimeCon.Value) || Integer(this.HoldTimeCon.Value) <= 0){
            MsgBox("按键按住时间必须为大于零的整数！")
        }

        if (!IsInteger(this.KeyCountCon.Value) || Integer(this.KeyCountCon.Value) <= 0){
            MsgBox("按键次数必须为大于零的整数！")
        }

        if (!IsInteger(this.PerIntervalCon.Value) || Integer(this.PerIntervalCon.Value) <= 0){
            MsgBox("每次间隔必须为大于零的整数！")
        }

        this.HoldTime := Integer(this.HoldTimeCon.Value)
        this.KeyCount := Integer(this.KeyCountCon.Value)
        this.PerInterval := Integer(this.PerIntervalCon.Value)
        this.Refresh()
    }

    OnClickSureBtn() {
        if (this.SureBtnAction == "")
            return

        if (this.HoldTime >= this.PerInterval){
            MsgBox("按键按住时间必须小于每次间隔！")
            return
        }

        if (this.KeyStr == ""){
            MsgBox("请选择按键！")
            return
        }

        action := this.SureBtnAction
        action(this.CommandStr)
        this.Gui.Hide()
    }
}
