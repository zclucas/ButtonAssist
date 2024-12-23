; 回调函数
OnOpen() {
    global ScriptInfo

    if (!ScriptInfo.ShowWinCtrl.Value && !ScriptInfo.IsLastSaved)
        return

    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

;UI相关函数
AddUI() {
    global MyGui, TabCtrl, TabPosY
    global ScriptInfo
    MyGui := Gui(, "Super的按键辅助器")
    MyGui.Opt("ToolWindow")
    MyGui.SetFont(, "Consolas")

    ; 参考链接
    LinkText := '<a href="https://wyagd001.github.io/v2/docs/KeyList.htm" id="notepad">按键名参考链接</a>'
    MyGui.Add("Link", "x20 w150", LinkText)

    ; 暂停模块
    MyGui.Add("Text", "x200 y5 w70", "暂停:")
    ScriptInfo.PauseToggleCtrl := MyGui.Add("CheckBox", "x235 y5 w30", "")
    ScriptInfo.PauseToggleCtrl.Value := ScriptInfo.IsPause
    ScriptInfo.PauseToggleCtrl.OnEvent("Click", OnPauseHotkey)
    MyGui.Add("Text", "x270 y5 w70", "快捷键:")
    ScriptInfo.PauseHotkeyCtrl := MyGui.Add("Hotkey", "x320 y2 Center", ScriptInfo.PauseHotkey)

    MyGui.Add("Text", "x550 y5 w150", "运行后显示窗口:")
    ScriptInfo.ShowWinCtrl := MyGui.Add("CheckBox", "x650 y5 w30", "")
    ScriptInfo.ShowWinCtrl.Value := ScriptInfo.IsExecuteShow
    ScriptInfo.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    ReloadBtnCtrl := MyGui.Add("Button", "x720 y0 w100 center", "重载")
    ReloadBtnCtrl.OnEvent("Click", MenuReload)

    TabPosY := 30
    TabCtrl := myGui.Add("Tab3", "x10 w900 y" TabPosY " Choose" ScriptInfo.TableIndex, TabNameArr)

    loop TabNameArr.Length {
        TabCtrl.UseTab(A_Index)
        func := GetUIAddFunc(A_Index)
        func(A_Index)
    }
    TabCtrl.UseTab()

    AddOperBtnUI()
}

GetUIAddFunc(index) {
    UIAddFuncArr := [AddSpecialHotkeyUI, AddNormalHotkeyUI, AddReplaceKeyUI, AddSoftUI, AddRuleUI, AddToolUI]
    return UIAddFuncArr[index]
}

;添加特殊按键宏UI
AddSpecialHotkeyUI(index) {
    global ScriptInfo
    tableItem := GetTableItem(index)
    tableItem.underPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x160 y{} w490", tableItem.underPosY), "辅助键案例：ctrl_100,0,a_100(全选快捷键)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x850 y{} w80", tableItem.underPosY), "松开停止")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

;添加正常按键宏UI
AddNormalHotkeyUI(index) {
    global ScriptInfo
    tableItem := GetTableItem(index)
    tableItem.underPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键案例：ctrl_100,0,a_100(全选快捷键)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x850 y{} w80", tableItem.underPosY), "松开停止")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

;添加按键替换UI
AddReplaceKeyUI(index) {
    tableItem := GetTableItem(index)
    tableItem.UnderPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键案例：w,d(按键替换为w和d)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

AddSoftUI(index) {
    tableItem := GetTableItem(index)
    tableItem.UnderPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键信息案例：Notepad.exe(进程名)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

AddRuleUI(index) {

    posY := TabPosY
    ; 配置规则说明
    posY += 30

    MyGui.Add("Text", Format("x20 y{} w130", posY), "按住时间浮动:")
    ScriptInfo.HoldFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), ScriptInfo.HoldFloat)

    MyGui.Add("Text", Format("x270 y{} w130", posY), "图片搜索模糊度:")
    ScriptInfo.ImageSearchBlurCtrl := MyGui.Add("Edit", Format("x380 y{} w70 center", posY - 4), ScriptInfo.ImageSearchBlur)

    posY += 30
    MyGui.Add("Text", Format("x20 y{} w130", posY), "连点间隔时间浮动:")
    ScriptInfo.ClickFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), ScriptInfo.ClickFloat)

    posY += 30
    MyGui.Add("Text", Format("x20 y{} w130", posY), "按键间隔时间浮动:")
    ScriptInfo.IntervalFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), ScriptInfo.IntervalFloat
    )

    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "禁止：勾选后对应配置不生效")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "游戏：勾选为游戏模式。若游戏内仍然无效请以管理员身份运行软件，如果非游戏模式功能正常，请忽略此项")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "指定进程名：填写后，仅在该进程获得焦点时生效，否则对所有进程生效（可通过工具模块获取进程名）")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "松开停止：勾选后，松开触键时立刻停止触发配置")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "触发键规则：填写想要触发配置的按键或组合键，增加前缀~符号，触发时，触发键原有功能不会被屏蔽")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "组合触发键：ctrl,alt,shift,win等修饰键需要用特殊符号^!+#代替，其他按键参考软件链接")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例：shift+P要填写成+P,alt+R要填写成!R等等")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY),
    "辅助键配置规则：按键名_持续时间[_按键次数_连续按键间隔],间隔时间,按键名_持续时间[_按键次数_连续按键间隔],间隔时间.....([]为可选参数)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY),
    "鼠标移动配置规则：MouseMove_X_Y[_Speed_R](X,Y为鼠标移动坐标,Speed为鼠标移动速度0~100,0为瞬移,R为是否相对位移)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例:MouseMove_100_-100_10(鼠标速度10移动到坐标100,-100)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例:MouseMove_50_-50_20_R(鼠标速度20移动到相对当前坐标50,-50)")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "图片搜索规则:ImageSearch_ImagePath[_X_Y_W_H](dosomething)(ImagePath为图片路径,X,Y为搜索区域左上角坐标,W,H为搜索区域右下角坐标)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例:ImageSearch_ImagePath_300_300_500_500(lbutton_30_2_50)。从(300,300)到(500,500)搜索图片,找到后执行lbutton_30_2_50指令")


    posY += 20

    tableItem := GetTableItem(index)
    tableItem.UnderPosY := posY
}

AddToolUI(index) {
    global ToolCheckInfo

    posY := TabPosY
    ; 配置规则说明
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "鼠标下窗口信息：")

    MyGui.Add("Text", Format("x250 y{}", posY), "持续检测:")
    ToolCheckInfo.ToolCheckCtrl := MyGui.Add("CheckBox", Format("x320 y{}", posY))
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.OnEvent("Click", OnToolCheckHotkey)
    MyGui.Add("Text", Format("x370 y{}", posY), "快捷键:")
    ToolCheckInfo.ToolCheckHotKeyCtrl := MyGui.Add("HotKey", Format("x425 y{} center", posY - 5), ToolCheckInfo.ToolCheckHotkey
    )

    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "鼠标位置坐标：")
    ToolCheckInfo.ToolMousePosCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.PosStr)

    MyGui.Add("Text", Format("x390 y{}", posY), "进程名：")
    ToolCheckInfo.ToolProcessNameCtrl := MyGui.Add("Edit", Format("x450 y{} w250", posY - 5), ToolCheckInfo.ProcessName
    )

    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "进程标题：")
    ToolCheckInfo.ToolProcessTileCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.ProcessTile
    )

    MyGui.Add("Text", Format("x390 y{}", posY), "进程PID：")
    ToolCheckInfo.ToolProcessPidCtrl := MyGui.Add("Edit", Format("x450 y{} w250", posY - 5), ToolCheckInfo.ProcessPid)

    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "进程窗口类：")
    ToolCheckInfo.ToolProcessClassCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.ProcessClass
    )

    posY += 20
    GetTableItem(index).underPosY := posY
}

RefreshToolUI() {
    global ToolCheckInfo
    
    ToolCheckInfo.ToolMousePosCtrl.Value := ToolCheckInfo.PosStr
    ToolCheckInfo.ToolProcessNameCtrl.Value := ToolCheckInfo.ProcessName
    ToolCheckInfo.ToolProcessTileCtrl.Value := ToolCheckInfo.ProcessTile
    ToolCheckInfo.ToolProcessPidCtrl.Value := ToolCheckInfo.ProcessPid
    ToolCheckInfo.ToolProcessClassCtrl.Value := ToolCheckInfo.ProcessClass
}

LoadSavedSettingUI(index) {
    tableItem := GetTableItem(index)
    isSpecialOrNormal := CheckIsSpecialOrNormalTable(index)
    isSpecial := CheckIsSpecialTable(index)
    loop tableItem.TKArr.Length {
        heightValue := isSpecialOrNormal ? 60 : 30
        posY := " y" tableItem.underPosY
        TKPosY := isSpecialOrNormal ? " y" tableItem.underPosY + 10 : " y" tableItem.underPosY
        InfoHeight := isSpecialOrNormal ? " h45" : " h20"

        symbol := GetTableSymbol(index)
        TKNameValue := " v" symbol "TK" A_Index
        InfoNameValue := " v" symbol "Info" A_Index
        ModeNameValue := " v" symbol "Mode" A_Index
        ForbidNameValue := " v" symbol "Forbid" A_Index
        ProcessNameValue := " v" symbol "ProcessName" A_Index
        LoosenStopNameValue := " v" symbol "LoosenStop" A_Index
        RemarkNameValue := " v" symbol "Remark" A_Index

        if (isSpecial) {
            newTkControl := MyGui.Add("Hotkey", "x20 Center" TKNameValue TKPosY, tableItem.TKArr[A_Index])
            newInfoControl := MyGui.Add("Edit", "x160 w490" InfoHeight InfoNameValue posY, tableItem.InfoArr[A_Index])
        }
        else {
            newTkControl := MyGui.Add("Edit", "x20 w70 Center" TKNameValue TKPosY, tableItem.TKArr[A_Index])
            newInfoControl := MyGui.Add("Edit", "x100 w550" InfoHeight InfoNameValue posY, tableItem.InfoArr[A_Index])
        }

        newModeControl := MyGui.Add("Checkbox", Format("x670 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x705 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        newProcessNameControl := MyGui.Add("Edit", Format("x740 w130 y{}", tableItem.underPosY) ProcessNameValue, "")
        if (tableItem.ProcessNameArr.Length >= A_Index) {
            value := tableItem.ProcessNameArr[A_Index]
            if (value != "")
                newProcessNameControl.value := value
        }

        if (isSpecialOrNormal) {
            newLoosenStopControl := MyGui.Add("Checkbox", Format("x880 w30 y{}", tableItem.underPosY + 5) LoosenStopNameValue,
            "")
            newLoosenStopControl.value := tableItem.LoosenStopArr.Length >= A_Index ? tableItem.LoosenStopArr[A_Index] : 0

            newRemarkTextControl := MyGui.Add("Text", Format("x670 y{} w60", tableItem.underPosY + 30), "备注:")
            newRemarkControl := MyGui.Add("Edit", Format("x720 y{} w180", tableItem.underPosY + 25) RemarkNameValue, ""
            )
            newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""

            tableItem.LoosenStopConArr.Push(newLoosenStopControl)
            tableItem.RemarkConArr.Push(newRemarkControl)
            tableItem.RemarkTextConArr.Push(newRemarkTextControl)
        }

        tableItem.TKConArr.Push(newTkControl)
        tableItem.InfoConArr.Push(newInfoControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        UpdateUnderPosY(index, heightValue)
    }
}

MaxUnderPosY() {
    maxY := 0
    loop TabNameArr.Length {
        posY := GetTableItem(A_Index).UnderPosY
        if (posY > maxY)
            maxY := posY
    }
    return maxY
}

AddOperBtnUI() {
    global BtnAdd, BtnSave, BtnRemove
    maxY := MaxUnderPosY()
    OperBtnPosY := maxY + 10
    YPos := " y" OperBtnPosY
    BtnAdd := MyGui.Add("Button", "x100 w120 vbtnAdd" YPos, "新增配置")
    BtnAdd.OnEvent("Click", OnAddSetting)
    BtnRemove := MyGui.Add("Button", "x300 w120 vbtnRemove" YPos, "删除最后的配置")
    BtnRemove.OnEvent("Click", OnRemoveSetting)
    BtnSave := MyGui.Add("Button", "x500 w120 vbtnSure" YPos, "应用并保存")
    BtnSave.OnEvent("Click", OnSaveSetting)
}

OnAddSetting(*) {
    global TabCtrl, MyGui
    TableIndex := TabCtrl.Value
    tableItem := GetTableItem(TableIndex)
    btnRemove.Visible := false
    isSpecialOrNormal := CheckIsSpecialOrNormalTable(TableIndex)
    isSpecial := CheckIsSpecialTable(TableIndex)
    tableItem.TKArr.Push("")
    tableItem.InfoArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.LoosenStopArr.Push(0)
    tableItem.RemarkArr.Push("")

    heightValue := isSpecialOrNormal ? 60 : 30
    posY := " y" tableItem.underPosY
    TKPosY := isSpecialOrNormal ? " y" tableItem.underPosY + 10 : " y" tableItem.underPosY
    InfoHeight := isSpecialOrNormal ? " h45" : " h20"

    symbol := GetTableSymbol(TableIndex)
    index := tableItem.TKArr.Length
    TKNameValue := " v" symbol "TK" index
    InfoNameValue := " v" symbol "Info" index
    ModeNameValue := " v" symbol "Mode" index
    ForbidNameValue := " v" symbol "Forbid" index
    ProcessNameValue := " v" symbol "ProcessName" index
    LoosenStopNameValue := " v" symbol "LoosenStop" index
    RemarkNameValue := " v" symbol "Remark" index

    TabCtrl.UseTab(TableIndex)
    if (isSpecial) {
        newTkControl := MyGui.Add("Hotkey", "x20 Center" TKNameValue TKPosY, "")
        newInfoControl := MyGui.Add("Edit", "x160 w490" InfoHeight InfoNameValue posY, "")
    }
    else{
        newTkControl := MyGui.Add("Edit", "x20 w70 Center" TKNameValue TKPosY, "")
        newInfoControl := MyGui.Add("Edit", "x100 w550" InfoHeight InfoNameValue posY, "")
    }
    

    newModeControl := MyGui.Add("Checkbox", Format("x670 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x705 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
    newForbidControl.value := 0
    newProcessNameControl := MyGui.Add("Edit", Format("x740 w130 y{}", tableItem.underPosY - 5) ProcessNameValue, "")
    newProcessNameControl.value := ""
    if (isSpecialOrNormal) {
        newLoosenStopControl := MyGui.Add("Checkbox", Format("x880 w30 y{}", tableItem.underPosY + 5) LoosenStopNameValue,
        "")

        newRemarkTextControl := MyGui.Add("Text", Format("x670 y{} w60", tableItem.underPosY + 30), "备注:")
        newRemarkControl := MyGui.Add("Edit", Format("x720 y{} w180", tableItem.underPosY + 25) RemarkNameValue, "")

        tableItem.LoosenStopConArr.Push(newLoosenStopControl)
        tableItem.RemarkConArr.Push(newRemarkControl)
        tableItem.RemarkTextConArr.Push(newRemarkTextControl)
    }

    tableItem.TKConArr.Push(newTkControl)
    tableItem.InfoConArr.Push(newInfoControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)

    UpdateUnderPosY(TableIndex, heightValue)

    maxY := MaxUnderPosY()
    TabCtrl.UseTab()
    TabCtrl.Move(10, TabPosY, 900, maxY - TabPosY)

    RefreshOperBtnPos()
    SaveWinPos()
    RefreshGui()
}

OnRemoveSetting(*) {
    global TabCtrl
    TableIndex := TabCtrl.Value
    tableItem := GetTableItem(TableIndex)
    isSpecialOrNormal := CheckIsSpecialOrNormalTable(TableIndex)
    btnAdd.Visible := false
    UpdateUnderPosY(TableIndex, -30)
    tableItem.TKArr.Pop()
    tableItem.InfoArr.Pop()
    tableItem.ModeArr.Pop()
    tableItem.ForbidArr.Pop()
    tableItem.ProcessNameArr.Pop()
    tableItem.TKConArr.Pop().Visible := false
    tableItem.InfoConArr.Pop().Visible := false
    tableItem.ModeConArr.Pop().Visible := false
    tableItem.ForbidConArr.Pop().Visible := false
    tableItem.ProcessNameConArr.Pop().Visible := false
    if (isSpecialOrNormal) {
        tableItem.LoosenStopConArr.Pop().Visible := false
        tableItem.RemarkConArr.Pop().Visible := false
        tableItem.RemarkTextConArr.Pop().Visible := false
    }

}

RefreshGui() {
    global ScriptInfo
    if (ScriptInfo.IsSavedWinPos)
        MyGui.Show(Format("w920" "h{} x{} y{}", MaxUnderPosY() + 50, ScriptInfo.WinPosX, ScriptInfo.WinPosY))
    else
        MyGui.Show(Format("w920" "h{} center", MaxUnderPosY() + 50))
}

RefreshOperBtnPos() {
    maxY := MaxUnderPosY()
    OperBtnPosY := maxY + 10
    BtnAdd.Move(100, OperBtnPosY)
    BtnRemove.Move(300, OperBtnPosY)
    BtnSave.Move(500, OperBtnPosY)
}
; 系统托盘优化
CustomTrayMenu() {
    A_TrayMenu.Insert("&Suspend Hotkeys", "重置位置并显示窗口", ResetWinPosAndRefreshGui)
    A_TrayMenu.Insert("&Suspend Hotkeys", "显示窗口", (*) => RefreshGui())
    A_TrayMenu.Delete("&Pause Script")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "显示窗口"
}

MenuReload(*) {
    SaveWinPos()
    Reload()
}
ResetWinPosAndRefreshGui(*) {
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    ScriptInfo.IsSavedWinPos := false
    RefreshGui()
}
OnPauseHotkey(*) {
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsPause := !ScriptInfo.IsPause
    ScriptInfo.PauseToggleCtrl.Value := ScriptInfo.IsPause
    Suspend(ScriptInfo.IsPause)
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ResetTimer()
}

OnShowWinChanged(*) {
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsExecuteShow := !ScriptInfo.IsExecuteShow
    IniWrite(ScriptInfo.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
}
