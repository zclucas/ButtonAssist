#Requires AutoHotkey v2.0

class VariableGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""

        this.CreateTypeCon := ""
        this.ToggleConArr := []
        this.NameConArr := []
        this.ValueConArr := []
        this.CopyConArr := []
        this.ExtractStrCon := ""
        this.ExtractTypeCon := ""
        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""
        this.SearchCountCon := ""
        this.SearchIntervalCon := ""
        this.Data := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(cmd)
        this.OnRefresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "变量创建指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Consolas")

        PosX := 10
        PosY := 10
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
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

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "创建方式:")

        PosX += 70
        this.CreateTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["赋值", "复制", "提取"])
        this.CreateTypeCon.OnEvent("Change", (*) => this.OnRefresh())

        {
            PosX := 10
            PosY += 25
            MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 580, 100), "变量：")

            PosX := 11
            PosY += 20
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 50, 20), "开关")

            PosX += 50
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "变量名")

            PosX += 75
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "初始值")

            PosX += 75
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 80, 20), "复制对象")

            PosX := 300
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 50, 20), "开关")

            PosX += 50
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "变量名")

            PosX += 75
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "初始值")

            PosX += 75
            MyGui.Add("Text", Format("x{} y{} w{} h{} Center", PosX, PosY, 80, 20), "复制对象")

            PosX := 10
            PosY += 20
            con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX + 20, PosY, 30, 20), "")
            con.Value := 1
            this.ToggleConArr.Push(con)

            PosX += 50
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "Num1")
            this.NameConArr.Push(con)

            PosX += 75
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "0")
            this.ValueConArr.Push(con)

            PosX += 75
            con := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX, PosY - 2, 80), [])
            this.CopyConArr.Push(con)

            PosX := 300
            con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX + 20, PosY, 30, 20), "")
            con.Value := 0
            this.ToggleConArr.Push(con)

            PosX += 50
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "Num2")
            this.NameConArr.Push(con)

            PosX += 75
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "0")
            this.ValueConArr.Push(con)

            PosX += 75
            con := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX, PosY - 2, 80), [])
            this.CopyConArr.Push(con)

            PosX := 10
            PosY += 30
            con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX + 20, PosY, 30, 20), "")
            con.Value := 0
            this.ToggleConArr.Push(con)

            PosX += 50
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "Num3")
            this.NameConArr.Push(con)

            PosX += 75
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "0")
            this.ValueConArr.Push(con)

            PosX += 75
            con := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX, PosY - 2, 80), [])
            this.CopyConArr.Push(con)

            PosX := 300
            con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX + 20, PosY, 30, 20), "")
            con.Value := 0
            this.ToggleConArr.Push(con)

            PosX += 50
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "Num4")
            this.NameConArr.Push(con)

            PosX += 75
            con := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY, 70, 20), "0")
            this.ValueConArr.Push(con)

            PosX += 75
            con := MyGui.Add("ComboBox", Format("x{} y{} w{} Center", PosX, PosY - 2, 80), [])
            this.CopyConArr.Push(con)
        }
        {
            PosX := 10
            PosY += 40
            MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 580, 210), "提取相关配置：")

            PosY += 20
            PosX := 20
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:左键选取搜索范围")

            PosY += 20
            PosX := 20
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 550),
            "使用x、y、z、w代替变量位置   `n形如：`"坐标(x,y)`"可以提取`"坐标(10.5,8.6)`"中的10.5和8.6到变量1和变量2")

            PosY += 40
            PosX := 20
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "提取文本：")
            this.ExtractStrCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 75, PosY - 5, 250), "")
            this.ExtractTypeCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX + 345, PosY - 5, 80), ["屏幕", "剪切板"])
            this.ExtractTypeCon.Value := 1

            PosX := 20
            PosY += 30
            MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 300, 90), "搜索范围:")

            PosY += 30
            PosX := 25
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
            PosX += 75
            this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

            PosX := 180
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
            PosX += 75
            this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

            PosX := 350
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
            PosX += 75
            this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

            PosY += 30
            PosX := 25
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
            PosX += 75
            this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

            PosX := 180
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
            PosX += 75
            this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

            PosX := 350
            MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
            this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 75, PosY - 5, 50))
        }

        PosY += 50
        PosX := 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{} Center", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 600, 450))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetVariableData(this.SerialStr)
        VariableObjArr := ["price", "hight", "happy"]

        this.CreateTypeCon.Value := this.Data.CreateType
        this.ExtractStrCon := this.Data.ExtractStr
        this.ExtractTypeCon.Value := this.Data.ExtractType
        this.StartPosXCon.Value := this.Data.StartPosX
        this.StartPosYCon.Value := this.Data.StartPosY
        this.EndPosXCon.Value := this.Data.EndPosX
        this.EndPosYCon.Value := this.Data.EndPosY
        loop 4 {
            copyName := this.GetCopyNameText(VariableObjArr, this.Data.CopyNameArr[A_Index])
            this.ToggleConArr[A_Index].Value := this.Data.ToggleArr[A_Index]
            this.NameConArr[A_Index].Value := this.Data.NameArr[A_Index]
            this.ValueConArr[A_Index].Value := this.Data.ValueArr[A_Index]
            this.CopyConArr[A_Index].Delete()
            this.CopyConArr[A_Index].Add(VariableObjArr)
            this.CopyConArr[A_Index].Text := copyName
        }
    }

    GetCopyNameText(VariableObjArr, copyName) {
        if (VariableObjArr.Length <= 0)
            return ""
        loop VariableObjArr.Length {
            if (VariableObjArr[A_Index] == copyName)
                return copyName
        }

        return VariableObjArr[1]
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
        }
    }

    OnRefresh() {
        enableVariable := this.CreateTypeCon.Value == 1
        enableCopy := this.CreateTypeCon.Value == 2
        loop 4 {
            this.ValueConArr[A_Index].Enabled := enableVariable
            this.CopyConArr[A_Index].Enabled := enableCopy
        }
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveVariableData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        return true
    }

    TriggerMacro() {
        this.SaveVariableData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        ; OnVariable(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "变量_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "Variable" CurrentDateTime
    }

    GetVariableData(SerialStr) {
        saveStr := IniRead(VariableFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := VariableData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveVariableData() {
        this.Data.CreateType := this.CreateTypeCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, VariableFile, IniSection, this.Data.SerialStr)
    }
}
