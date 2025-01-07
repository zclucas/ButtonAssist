;窗口&UI刷新
InitUI() {
    AddUI()
    CustomTrayMenu()
    OnOpen()
}

OnOpen() {
    global MySoftData

    if (!MySoftData.ShowWinCtrl.Value && !MySoftData.IsLastSaved)
        return

    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

RefreshGui() {
    global MySoftData
    if (MySoftData.IsSavedWinPos)
        MySoftData.MyGui.Show(Format("w1170" "h{} x{} y{}", MaxUnderPosY() + 50, MySoftData.WinPosX, MySoftData.WinPosY
        ))
    else
        MySoftData.MyGui.Show(Format("w1170" "h{} center", MaxUnderPosY() + 50))
}

RefreshOperBtnPos() {
    maxY := MaxUnderPosY()
    OperBtnPosY := maxY + 10
    MySoftData.BtnAdd.Move(100, OperBtnPosY)
    MySoftData.BtnRemove.Move(400, OperBtnPosY)
    MySoftData.BtnSave.Move(700, OperBtnPosY)
}

RefreshToolUI() {
    global ToolCheckInfo

    ToolCheckInfo.ToolMousePosCtrl.Value := ToolCheckInfo.PosStr
    ToolCheckInfo.ToolProcessNameCtrl.Value := ToolCheckInfo.ProcessName
    ToolCheckInfo.ToolProcessTileCtrl.Value := ToolCheckInfo.ProcessTile
    ToolCheckInfo.ToolProcessPidCtrl.Value := ToolCheckInfo.ProcessPid
    ToolCheckInfo.ToolProcessClassCtrl.Value := ToolCheckInfo.ProcessClass
}

;UI元素相关函数
AddUI() {
    global MySoftData
    MyGui := Gui(, "Super的按键辅助器")
    MyGui.Opt("ToolWindow")
    MyGui.SetFont(, "Consolas")
    MySoftData.MyGui := MyGui

    ; 参考链接
    LinkText := '<a href="https://wyagd001.github.io/v2/docs/KeyList.htm" id="notepad">按键名参考链接</a>'
    MyGui.Add("Link", "x20 w150", LinkText)

    ; 暂停模块
    MySoftData.PauseToggleCtrl := MyGui.Add("CheckBox", "x170 y5 w50", "暂停")
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    MySoftData.PauseToggleCtrl.OnEvent("Click", OnPauseHotkey)
    MyGui.Add("Text", "x220 y5 w80", "快捷键:")
    MySoftData.PauseHotkeyCtrl := MyGui.Add("Edit", "x270 y2 Center w100", MySoftData.PauseHotkey)

    ;终止模块
    con := MyGui.Add("Button", "x450 y0 w90 center", "终止所有宏")
    con.OnEvent("Click", OnKillAllMacro)
    MyGui.Add("Text", "x550 y5 w70", "快捷方式:")
    MySoftData.KillMacroHotkeyCtrl := MyGui.Add("Edit", "x615 y2 Center w100", MySoftData.KillMacroHotkey)

    MySoftData.ShowWinCtrl := MyGui.Add("CheckBox", "x800 y5 w150", "运行后显示窗口")
    MySoftData.ShowWinCtrl.Value := MySoftData.IsExecuteShow
    MySoftData.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    ReloadBtnCtrl := MyGui.Add("Button", "x1000 y0 w100 center", "重载")
    ReloadBtnCtrl.OnEvent("Click", MenuReload)

    MySoftData.TabPosY := 30
    MySoftData.TabCtrl := MyGui.Add("Tab3", "x10 w1150 y" MySoftData.TabPosY " Choose" MySoftData.TableIndex,
        MySoftData.TabNameArr)

    loop MySoftData.TabNameArr.Length {
        MySoftData.TabCtrl.UseTab(A_Index)
        func := GetUIAddFunc(A_Index)
        func(A_Index)
    }
    MySoftData.TabCtrl.UseTab()

    AddOperBtnUI()
}

GetUIAddFunc(index) {
    UIAddFuncArr := [AddNormalHotkeyUI, AddStringHotkeyUI, AddReplaceKeyUI, AddSoftUI, AddRuleUI,
        AddToolUI]
    return UIAddFuncArr[index]
}

;添加正常按键宏UI
AddNormalHotkeyUI(index) {
    global MySoftData
    tableItem := MySoftData.TableInfo[index]
    tableItem.underPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui := MySoftData.MyGui
    MyGui.Add("Text", Format("x30 y{} w100", tableItem.underPosY), "宏触发按键")
    MyGui.Add("Text", Format("x140 y{} w550", tableItem.underPosY), "宏指令     案例：ctrl_100,0,a_100(全选快捷键)")
    MyGui.Add("Text", Format("x810 y{} w50", tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x860 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x900 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x940 y{} w100", tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x1080 y{} w80", tableItem.underPosY), "循环次数")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

;添加正常按键宏UI
AddStringHotkeyUI(index) {
    global MySoftData
    tableItem := MySoftData.TableInfo[index]
    tableItem.underPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui := MySoftData.MyGui
    MyGui.Add("Text", Format("x30 y{} w100", tableItem.underPosY), "宏触发子串")
    MyGui.Add("Text", Format("x140 y{} w550", tableItem.underPosY), "宏指令     案例：ctrl_100,0,a_100(全选快捷键)")
    MyGui.Add("Text", Format("x810 y{} w50", tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x860 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x900 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x940 y{} w100", tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x1080 y{} w80", tableItem.underPosY), "循环次数")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

;添加按键替换UI
AddReplaceKeyUI(index) {
    tableItem := MySoftData.TableInfo[index]
    tableItem.UnderPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui := MySoftData.MyGui
    MyGui.Add("Text", Format("x30 y{} w100", tableItem.underPosY), "原按键")
    MyGui.Add("Text", Format("x140 y{} w550", tableItem.underPosY), "替换后的按键     案例:w,d(将原本按键替换成w,d)")
    MyGui.Add("Text", Format("x810 y{} w50", tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x860 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x900 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x940 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

AddSoftUI(index) {
    tableItem := MySoftData.TableInfo[index]
    tableItem.UnderPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui := MySoftData.MyGui
    MyGui.Add("Text", Format("x30 y{} w100", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x140 y{} w550", tableItem.underPosY), "辅助键信息案例:Notepad.exe(进程名)")
    MyGui.Add("Text", Format("x810 y{} w50", tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x860 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x900 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x940 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

LoadSavedSettingUI(index) {
    tableItem := MySoftData.TableInfo[index]
    isMacro := CheckIsMacroTable(index)
    curIndex := 0
    MyGui := MySoftData.MyGui
    isTriggerStr := CheckIsStringMacroTable(index)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    loop tableItem.ModeArr.Length {
        heightValue := isMacro ? 60 : 30
        posY := " y" tableItem.underPosY
        TKPosY := isMacro ? " y" tableItem.underPosY + 10 : " y" tableItem.underPosY
        InfoHeight := isMacro ? " h45" : " h20"

        newTkControl := MyGui.Add("Edit", "x20 w100 Center" TKPosY, "")
        newInfoControl := MyGui.Add("Edit", "x130 w650" InfoHeight posY, "")
        newTkControl.Value := tableItem.TKArr.Length >= A_Index ? tableItem.TKArr[A_Index] : ""
        newInfoControl.Value := tableItem.InfoArr.Length >= A_Index ? tableItem.InfoArr[A_Index] : ""

        newKeyBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY), "触发键")
        newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, A_Index))

        newModeControl := MyGui.Add("Checkbox", Format("x870 w30 y{}", tableItem.underPosY + 5), "")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x905 w30 y{}", tableItem.underPosY + 5), "")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        newProcessNameControl := MyGui.Add("Edit", Format("x940 w130 y{}", tableItem.underPosY), "")
        newProcessNameControl.value := tableItem.ProcessNameArr.Length >= A_Index ? tableItem.ProcessNameArr[A_Index] : ""

        if (isMacro) {
            newMacroBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY + 25), "宏指令")
            newMacroBtnControl.OnEvent("Click", GetTableClosureAction(OnTableEditMacro, tableItem, A_Index))
            newRemarkTextControl := MyGui.Add("Text", Format("x870 y{} w60", tableItem.underPosY + 30), "备注:")
            newRemarkControl := MyGui.Add("Edit", Format("x920 y{} w180", tableItem.underPosY + 25), ""
            )
            newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""
            newLoopCountControl := MyGui.Add("Edit", Format("x1080 y{} w50 center", tableItem.underPosY), "")
            conValue := tableItem.LoopCountArr.Length >= A_Index ? tableItem.LoopCountArr[A_Index] : "1"
            conValue := conValue == "-1" ? "∞" : conValue
            newLoopCountControl.Value := conValue

            tableItem.MacroBtnConArr.Push(newMacroBtnControl)
            tableItem.RemarkConArr.Push(newRemarkControl)
            tableItem.RemarkTextConArr.Push(newRemarkTextControl)
            tableItem.LoopCountConArr.Push(newLoopCountControl)
        }

        tableItem.TKConArr.Push(newTkControl)
        tableItem.InfoConArr.Push(newInfoControl)
        tableItem.KeyBtnConArr.Push(newKeyBtnControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        UpdateUnderPosY(index, heightValue)
    }
}

AddOperBtnUI() {
    maxY := MaxUnderPosY()
    OperBtnPosY := maxY + 10
    YPos := " y" OperBtnPosY
    MyGui := MySoftData.MyGui
    MySoftData.BtnAdd := MyGui.Add("Button", "x100 w120 vbtnAdd" YPos, "新增配置")
    MySoftData.BtnAdd.OnEvent("Click", OnAddSetting)
    MySoftData.BtnRemove := MyGui.Add("Button", "x300 w120 vbtnRemove" YPos, "删除最后的配置")
    MySoftData.BtnRemove.OnEvent("Click", OnRemoveSetting)
    MySoftData.BtnSave := MyGui.Add("Button", "x500 w120 vbtnSure" YPos, "应用并保存")
    MySoftData.BtnSave.OnEvent("Click", OnSaveSetting)
}

OnAddSetting(*) {
    MyGui := MySoftData.MyGui
    TableIndex := MySoftData.TabCtrl.Value
    tableItem := MySoftData.TableInfo[TableIndex]
    MySoftData.BtnRemove.Visible := false
    isMacro := CheckIsMacroTable(TableIndex)
    isTriggerStr := CheckIsStringMacroTable(TableIndex)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    tableItem.TKArr.Push("")
    tableItem.InfoArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.RemarkArr.Push("")
    tableItem.LoopCountArr.Push("1")

    heightValue := isMacro ? 60 : 30
    posY := " y" tableItem.underPosY
    TKPosY := isMacro ? " y" tableItem.underPosY + 10 : " y" tableItem.underPosY
    InfoHeight := isMacro ? " h50" : " h20"
    index := tableItem.ModeArr.Length

    MySoftData.TabCtrl.UseTab(TableIndex)
    newTkControl := MyGui.Add("Edit", "x20 w100 Center" TKPosY, "")
    newInfoControl := MyGui.Add("Edit", "x130 w650" InfoHeight posY, "")

    newKeyBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY), "触发键")
    newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, index))

    newModeControl := MyGui.Add("Checkbox", Format("x870 w30 y{}", tableItem.underPosY + 5), "")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x905 w30 y{}", tableItem.underPosY + 5), "")
    newForbidControl.value := 0
    newProcessNameControl := MyGui.Add("Edit", Format("x940 w130 y{}", tableItem.underPosY - 5), "")
    newProcessNameControl.value := ""
    if (isMacro) {
        newMacroBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY + 25), "宏指令")
        newMacroBtnControl.OnEvent("Click", GetTableClosureAction(OnTableEditMacro, tableItem, index))

        newRemarkTextControl := MyGui.Add("Text", Format("x870 y{} w60", tableItem.underPosY + 30), "备注:")
        newRemarkControl := MyGui.Add("Edit", Format("x920 y{} w180", tableItem.underPosY + 25), "")
        newLoopCountControl := MyGui.Add("Edit", Format("x1080 y{} w50 center", tableItem.underPosY), "1")

        tableItem.LoopCountConArr.Push(newLoopCountControl)
        tableItem.MacroBtnConArr.Push(newMacroBtnControl)
        tableItem.RemarkConArr.Push(newRemarkControl)
        tableItem.RemarkTextConArr.Push(newRemarkTextControl)
    }

    tableItem.KeyBtnConArr.Push(newKeyBtnControl)
    tableItem.TKConArr.Push(newTkControl)
    tableItem.InfoConArr.Push(newInfoControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)

    UpdateUnderPosY(TableIndex, heightValue)

    maxY := MaxUnderPosY()
    MySoftData.TabCtrl.UseTab()
    MySoftData.TabCtrl.Move(10, MySoftData.TabPosY, 1150, maxY - MySoftData.TabPosY)

    RefreshOperBtnPos()
    SaveWinPos()
    RefreshGui()
}

OnRemoveSetting(*) {
    TableIndex := MySoftData.TabCtrl.Value
    tableItem := MySoftData.TableInfo[TableIndex]
    isMacro := CheckIsMacroTable(TableIndex)
    if (tableItem.ModeArr.Length == 0) {
        return
    }
    MySoftData.BtnAdd.Visible := false
    UpdateUnderPosY(TableIndex, -30)
    tableItem.ModeArr.Pop()
    tableItem.ForbidArr.Pop()

    if (tableItem.TKArr.Length > 0)
        tableItem.TKArr.Pop()
    if (tableItem.InfoArr.Length > 0)
        tableItem.InfoArr.Pop()
    if (tableItem.ProcessNameArr.Length > 0)
        tableItem.ProcessNameArr.Pop()
    if (tableItem.LoopCountArr.Length > 0)
        tableItem.LoopCountArr.Pop()
    if (tableItem.RemarkArr.Length > 0)
        tableItem.RemarkArr.Pop()

    tableItem.TKConArr.Pop().Visible := false
    tableItem.InfoConArr.Pop().Visible := false
    tableItem.ModeConArr.Pop().Visible := false
    tableItem.ForbidConArr.Pop().Visible := false
    tableItem.ProcessNameConArr.Pop().Visible := false
    tableItem.KeyBtnConArr.Pop().Visible := false

    if (isMacro) {
        tableItem.RemarkConArr.Pop().Visible := false
        tableItem.RemarkTextConArr.Pop().Visible := false
        tableItem.MacroBtnConArr.Pop().Visible := false
        tableItem.LoopCountConArr.Pop().Visible := false
    }
}

AddRuleUI(index) {

    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    ; 配置规则说明
    posY += 30

    MyGui.Add("Text", Format("x20 y{} w130", posY), "按住时间浮动:")
    MySoftData.HoldFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), MySoftData.HoldFloat)

    MyGui.Add("Text", Format("x270 y{} w130", posY), "图片搜索模糊度:")
    MySoftData.ImageSearchBlurCtrl := MyGui.Add("Edit", Format("x380 y{} w70 center", posY - 4), MySoftData.ImageSearchBlur
    )

    posY += 30
    MyGui.Add("Text", Format("x20 y{} w130", posY), "连点间隔时间浮动:")
    MySoftData.ClickFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), MySoftData.ClickFloat)

    posY += 30
    MyGui.Add("Text", Format("x20 y{} w130", posY), "按键间隔时间浮动:")
    MySoftData.IntervalFloatCtrl := MyGui.Add("Edit", Format("x150 y{} w70 center", posY - 4), MySoftData.IntervalFloat
    )

    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "禁止：勾选后对应配置不生效")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "游戏：勾选为游戏模式。若游戏内仍然无效请以管理员身份运行软件，如果非游戏模式功能正常，请忽略此项")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "指定进程名：填写后，仅在该进程获得焦点时生效，否则对所有进程生效（可通过工具模块获取进程名）")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "循环次数：-1为无限循环(通过终止所有宏按键取消循环),大于0的整数为循环次数")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "备注：对按键宏的备注信息(这是网友在Gitee上提的第一个需求,加上以示尊重)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "快捷键：通过%工具%下的编辑快捷键获取配置")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "快捷方式：通过%工具%下的 编辑快捷 或者 编辑字串 获取配置")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "其他说明：")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "按键宏的触发键与字串宏的触发键可以混用。")

    posY += 20

    tableItem := MySoftData.TableInfo[index]
    tableItem.UnderPosY := posY
}

AddToolUI(index) {
    global ToolCheckInfo

    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    ; 配置规则说明
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "编辑快捷方式：(用于暂停，终止所有宏，持续刷新等触发配置编辑)")
    posY += 25
    MySoftData.EditHotKeyCtrl := MyGui.Add("Edit", Format("x20 y{} center w120", posY - 5), "")
    con := MyGui.Add("Button", Format("x140 y{} center w80", posY - 5), "编辑快捷键")
    con.OnEvent("Click", OnEditHotkey)

    MySoftData.EditHotStrCtrl := MyGui.Add("Edit", Format("x320 y{} center w120", posY - 5), "")
    con := MyGui.Add("Button", Format("x440 y{} center w80", posY - 5), "编辑字串")
    con.OnEvent("Click", OnEditHotStr)

    posY += 40
    MyGui.Add("Text", Format("x20 y{}", posY), "鼠标下窗口信息：")

    ToolCheckInfo.ToolCheckCtrl := MyGui.Add("CheckBox", Format("x150 y{}", posY), "持续刷新")
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.OnEvent("Click", OnToolCheckHotkey)
    MyGui.Add("Text", Format("x230 y{}", posY), "快捷方式:")
    ToolCheckInfo.ToolCheckHotKeyCtrl := MyGui.Add("Edit", Format("x300 y{} center w100", posY - 5), ToolCheckInfo.ToolCheckHotkey
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
    MySoftData.TableInfo[index].underPosY := posY
}

SetToolCheckInfo() {
    global ToolCheckInfo
    CoordMode("Mouse", "Screen")
    MouseGetPos &mouseX, &mouseY, &winId
    ToolCheckInfo.PosStr := mouseX . "," . mouseY
    ToolCheckInfo.ProcessName := WinGetProcessName(winId)
    ToolCheckInfo.ProcessTile := WinGetTitle(winId)
    ToolCheckInfo.ProcessPid := WinGetPID(winId)
    ToolCheckInfo.ProcessClass := WinGetClass(winId)
    RefreshToolUI()
}

; 系统托盘优化
CustomTrayMenu() {
    A_TrayMenu.Insert("&Suspend Hotkeys", "重置位置并显示窗口", ResetWinPosAndRefreshGui)
    A_TrayMenu.Insert("&Suspend Hotkeys", "显示窗口", (*) => RefreshGui())
    A_TrayMenu.Delete("&Pause Script")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "显示窗口"
}
