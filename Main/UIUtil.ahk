;窗口&UI刷新
InitUI() {
    global MySoftData
    MyGui := Gui(, "Super的按键辅助器")
    MyGui.Opt("ToolWindow")
    MyGui.SetFont(, "Consolas")
    MySoftData.MyGui := MyGui

    AddUI()
    CustomTrayMenu()
    OnOpen()
}

OnOpen() {
    global MySoftData

    if (!MySoftData.IsExecuteShow && !MySoftData.IsLastSaved)
        return

    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

RefreshGui() {
    global MySoftData
    if (MySoftData.IsSavedWinPos)
        MySoftData.MyGui.Show(Format("x{} y{} w{} h{}", MySoftData.WinPosX, MySoftData.WinPosY, 1080, 520))
    else
        MySoftData.MyGui.Show(Format("w{} h{} center", 1080, 520))

}

RefreshToolUI() {
    global ToolCheckInfo

    ToolCheckInfo.ToolMousePosCtrl.Value := ToolCheckInfo.PosStr
    ToolCheckInfo.ToolProcessNameCtrl.Value := ToolCheckInfo.ProcessName
    ToolCheckInfo.ToolProcessTileCtrl.Value := ToolCheckInfo.ProcessTile
    ToolCheckInfo.ToolProcessPidCtrl.Value := ToolCheckInfo.ProcessPid
    ToolCheckInfo.ToolProcessClassCtrl.Value := ToolCheckInfo.ProcessClass
    ToolCheckInfo.ToolProcessIdCtrl.Value := ToolCheckInfo.ProcessId
    ToolCheckInfo.ToolColorCtrl.Value := ToolCheckInfo.Color
}

;UI元素相关函数
AddUI() {
    global MySoftData
    MyGui := MySoftData.MyGui
    AddOperBtnUI()
    MySoftData.TabPosY := 10
    MySoftData.TabPosX := 130
    MySoftData.TabCtrl := MyGui.Add("Tab3", Format("x{} y{} w{} Choose{}", MySoftData.TabPosX, MySoftData.TabPosY, 920,
        MySoftData.TableIndex), MySoftData.TabNameArr)

    loop MySoftData.TabNameArr.Length {
        MySoftData.TabCtrl.UseTab(A_Index)
        func := GetUIAddFunc(A_Index)
        func(A_Index)
    }
    MySoftData.TabCtrl.UseTab()
    height := GetTabHeight()
    MySoftData.TabCtrl.Move(MySoftData.TabPosX, MySoftData.TabPosY, 920, height)

    SB := ScrollBar(MyGui, 100, 100)
    MySoftData.SB := SB
    SB.AddFixedControls(MySoftData.FixedCons)
}

AddOperBtnUI() {
    MyGui := MySoftData.MyGui
    con := MyGui.Add("GroupBox", Format("x{} y{} w{} h{} center", 10, 10, 110, 500), "全局操作")
    MySoftData.FixedCons.Push(con)
    MySoftData.GroupFixedCons.Push(con)

    posY := 35
    ; 暂停模块
    MySoftData.PauseToggleCtrl := MyGui.Add("CheckBox", Format("x{} y{} w{} h{}", 15, posY, 100, 20), "暂停")
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    MySoftData.PauseToggleCtrl.OnEvent("Click", OnPauseHotkey)
    MySoftData.FixedCons.Push(MySoftData.PauseToggleCtrl)
    posY += 20
    con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{}", 15, posY, 100, 20), MySoftData.PauseHotkey)
    con.Enabled := false
    MySoftData.FixedCons.Push(con)
    posY += 40

    ;终止模块
    con := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "终止所有宏")
    con.OnEvent("Click", OnKillAllMacro)
    MySoftData.FixedCons.Push(con)
    posY += 31
    isHotKey := CheckIsHotKey(MySoftData.KillMacroHotkey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{} h{}", 15, posY, 100, 20), MySoftData.KillMacroHotkey)
    con.Enabled := false
    MySoftData.FixedCons.Push(con)
    posY += 40

    ReloadBtnCtrl := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "重载")
    ReloadBtnCtrl.OnEvent("Click", MenuReload)
    MySoftData.FixedCons.Push(ReloadBtnCtrl)
    posY += 40

    MySoftData.BtnAdd := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "新增配置")
    MySoftData.BtnAdd.OnEvent("Click", OnAddSetting)
    posY += 40

    posY := 470
    MySoftData.BtnSave := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "应用并保存")
    MySoftData.BtnSave.OnEvent("Click", OnSaveSetting)

    MySoftData.FixedCons.Push(MySoftData.BtnAdd)
    MySoftData.FixedCons.Push(MySoftData.BtnSave)

    MyTriggerKeyGui.SureFocusCon := MySoftData.BtnSave
    MyTriggerStrGui.SureFocusCon := MySoftData.BtnSave
    MyMacroGui.SureFocusCon := MySoftData.BtnSave
    MyReplaceKeyGui.SureFocusCon := MySoftData.BtnSave
}

GetUIAddFunc(index) {
    UIAddFuncArr := [AddMacroHotkeyUI, AddMacroHotkeyUI, AddReplaceKeyUI,
        AddToolUI, AddSettingUI]
    return UIAddFuncArr[index]
}

;添加正常按键宏UI
AddMacroHotkeyUI(index) {
    global MySoftData
    tableItem := MySoftData.TableInfo[index]
    tableItem.underPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui := MySoftData.MyGui
    MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 20, tableItem.underPosY), "宏触发按键")
    MyGui.Add("Text", Format("x{} y{} w550", MySoftData.TabPosX + 140, tableItem.underPosY), "宏指令")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 540, tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 590, tableItem.underPosY), "松止")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 630, tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 670, tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 705, tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x{} y{} w80", MySoftData.TabPosX + 840, tableItem.underPosY), "循环次数")

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
    MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 20, tableItem.underPosY), "原按键")
    MyGui.Add("Text", Format("x{} y{} w550", MySoftData.TabPosX + 140, tableItem.underPosY),
    "替换后的按键     案例:w,d(将原本按键替换成w,d)")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 540, tableItem.underPosY), "编辑")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 590, tableItem.underPosY), "松止")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 630, tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x{} y{} w50", MySoftData.TabPosX + 670, tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 705, tableItem.underPosY), "指定进程名")
    MyGui.Add("Text", Format("x{} y{} w80", MySoftData.TabPosX + 840, tableItem.underPosY), "循环次数")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

LoadSavedSettingUI(index) {
    tableItem := MySoftData.TableInfo[index]
    isMacro := CheckIsMacroTable(index)
    isNormal := CheckIsNormalTable(index)
    curIndex := 0
    MyGui := MySoftData.MyGui
    TabPosX := MySoftData.TabPosX
    isTriggerStr := CheckIsStringMacroTable(index)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    EditMacroAction := isMacro ? OnTableEditMacro : OnTableEditReplaceKey
    loop tableItem.ModeArr.Length {
        heightValue := 60
        TKPosY := tableItem.underPosY + 10
        InfoHeight := 45

        newTkControl := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 10, TKPosY, 100), "")
        newInfoControl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 120, tableItem.underPosY, 400,
            InfoHeight), "")
        newTkControl.Value := tableItem.TKArr.Length >= A_Index ? tableItem.TKArr[A_Index] : ""
        newInfoControl.Value := tableItem.MacroArr.Length >= A_Index ? tableItem.MacroArr[A_Index] : ""

        newKeyBtnControl := MyGui.Add("Button", Format("x{} y{} w60 h20", TabPosX + 530, tableItem.underPosY), "触发键")
        newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, A_Index))

        newLooseStopControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 600, tableItem.underPosY + 5), "")
        newLooseStopControl.value := tableItem.LooseStopArr[A_Index]
        newLooseStopControl.Enabled := isNormal

        newModeControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 635, tableItem.underPosY + 5), "")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 670, tableItem.underPosY + 5), "")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w130", TabPosX + 700, tableItem.underPosY), "")
        newProcessNameControl.value := tableItem.ProcessNameArr.Length >= A_Index ? tableItem.ProcessNameArr[A_Index] :
            ""

        newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w60 h20", TabPosX + 530, tableItem.underPosY + 25),
        "宏指令")
        newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w50 h20", TabPosX + 600, tableItem.underPosY + 25),
        "删除")
        newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, A_Index))
        newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, A_Index))
        newRemarkTextControl := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, tableItem.underPosY + 30), "备注:"
        )
        newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w190", TabPosX + 700, tableItem.underPosY + 25), ""
        )
        newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""
        newLoopCountControl := MyGui.Add("Edit", Format("x{} y{} w50 center", TabPosX + 840, tableItem.underPosY), "")
        conValue := tableItem.LoopCountArr.Length >= A_Index ? tableItem.LoopCountArr[A_Index] : "1"
        conValue := conValue == "-1" ? "∞" : conValue
        newLoopCountControl.Value := conValue

        tableItem.MacroBtnConArr.Push(newMacroBtnControl)
        tableItem.RemarkConArr.Push(newRemarkControl)
        tableItem.RemarkTextConArr.Push(newRemarkTextControl)
        tableItem.LoopCountConArr.Push(newLoopCountControl)

        if (!isMacro) {
            newLoopCountControl.Enabled := false
        }

        tableItem.TKConArr.Push(newTkControl)
        tableItem.InfoConArr.Push(newInfoControl)
        tableItem.KeyBtnConArr.Push(newKeyBtnControl)
        tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.LooseStopConArr.Push(newLooseStopControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        UpdateUnderPosY(index, heightValue)
    }
}

OnAddSetting(*) {
    MyGui := MySoftData.MyGui
    TableIndex := MySoftData.TabCtrl.Value
    tableItem := MySoftData.TableInfo[TableIndex]
    TabPosX := MySoftData.TabPosX
    isMacro := CheckIsMacroTable(TableIndex)
    isNormal := CheckIsNormalTable(TableIndex)
    isTriggerStr := CheckIsStringMacroTable(TableIndex)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    EditMacroAction := isMacro ? OnTableEditMacro : OnTableEditReplaceKey
    tableItem.TKArr.Push("")
    tableItem.MacroArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.RemarkArr.Push("")
    tableItem.LoopCountArr.Push("1")
    tableItem.LooseStopArr.Push(0)

    heightValue := 60
    TKPosY := tableItem.underPosY + 10
    InfoHeight := 45
    index := tableItem.ModeArr.Length

    MySoftData.TabCtrl.UseTab(TableIndex)
    newTkControl := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 10, TKPosY, 100), "")
    newInfoControl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 120, tableItem.underPosY, 400, InfoHeight),
    "")

    newKeyBtnControl := MyGui.Add("Button", Format("x{} y{} w60 h20", TabPosX + 530, tableItem.underPosY), "触发键")
    newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, index))

    newLooseStopControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 600, tableItem.underPosY + 5), "")
    newLooseStopControl.value := 0
    newLooseStopControl.Enabled := isNormal
    
    newModeControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 635, tableItem.underPosY + 5), "")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x{} y{} w30", TabPosX + 670, tableItem.underPosY + 5), "")
    newForbidControl.value := 0
    newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w130", TabPosX + 700, tableItem.underPosY), "")
    newProcessNameControl.value := ""

    newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w60 h20", TabPosX + 530, tableItem.underPosY + 25),
    "宏指令")
    newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w50 h20", TabPosX + 600, tableItem.underPosY + 25),
    "删除")
    newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, index))
    newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, index))

    newRemarkTextControl := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, tableItem.underPosY + 30), "备注:"
    )
    newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w190", TabPosX + 700, tableItem.underPosY + 25), "")
    newLoopCountControl := MyGui.Add("Edit", Format("x{} y{} w50 center", TabPosX + 840, tableItem.underPosY), "1")

    tableItem.LoopCountConArr.Push(newLoopCountControl)
    tableItem.MacroBtnConArr.Push(newMacroBtnControl)
    tableItem.RemarkConArr.Push(newRemarkControl)
    tableItem.RemarkTextConArr.Push(newRemarkTextControl)

    if (!isMacro) {
        newLoopCountControl.Enabled := false
    }

    tableItem.KeyBtnConArr.Push(newKeyBtnControl)
    tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
    tableItem.TKConArr.Push(newTkControl)
    tableItem.InfoConArr.Push(newInfoControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.LooseStopConArr.Push(newLooseStopControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)

    UpdateUnderPosY(TableIndex, heightValue)

    MySoftData.TabCtrl.UseTab()
    height := GetTabHeight()
    MySoftData.TabCtrl.Move(MySoftData.TabPosX, MySoftData.TabPosY, 920, height)

    SaveWinPos()
    RefreshGui()
}


AddSettingUI(index) {

    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX
    ; 配置规则说明
    posY += 35
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "获取快捷方式：(暂停只能用快捷键触发，其他可以用快捷键或字串触发)")
    posY += 25
    MySoftData.EditHotKeyCtrl := MyGui.Add("Edit", Format("x{} y{} center w120", posX + 20, posY - 5), "")
    con := MyGui.Add("Button", Format("x{} y{} center w80", posX + 140, posY - 5), "编辑快捷键")
    con.OnEvent("Click", OnEditHotkey)

    MySoftData.EditHotStrCtrl := MyGui.Add("Edit", Format("x{} y{} center w120", posX + 320, posY - 5), "")
    con := MyGui.Add("Button", Format("x{} y{} center w80", posX + 440, posY - 5), "编辑字串")
    con.OnEvent("Click", OnEditHotStr)

    posY += 40
    con := MyGui.Add("Text", Format("x{} y{} w130", posX + 20, posY), "脚本暂停快捷键:")
    MySoftData.PauseHotkeyCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 130, posY - 4), MySoftData.PauseHotkey
    )

    con := MyGui.Add("Text", Format("x{} y{} w130", posX + 270, posY), "终止宏快捷方式:")
    MySoftData.KillMacroHotkeyCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 380, posY - 4), MySoftData
    .KillMacroHotkey)

    MyGui.Add("Text", Format("x{} y{}", posX + 520, posY), "工具刷新快捷方式:")
    ToolCheckInfo.ToolCheckHotKeyCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 635, posY - 4),
    ToolCheckInfo.ToolCheckHotkey
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{} w130", posX + 20, posY), "按住时间浮动:")
    MySoftData.HoldFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 130, posY - 4), MySoftData.HoldFloat
    )

    MyGui.Add("Text", Format("x{} y{} w130", posX + 270, posY), "每次间隔时间浮动:")
    MySoftData.PreIntervalFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 380, posY - 4),
    MySoftData.PreIntervalFloat)

    MyGui.Add("Text", Format("x{} y{} w130", posX + 520, posY), "间隔指令时间浮动:")
    MySoftData.IntervalFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 635, posY - 4), MySoftData.IntervalFloat
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{} w130", posX + 20, posY), "搜索模糊0~255:")
    MySoftData.ImageSearchBlurCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 130, posY - 4), MySoftData
    .ImageSearchBlur
    )

    MySoftData.ShowWinCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 270, posY), "运行后显示窗口")
    MySoftData.ShowWinCtrl.Value := MySoftData.IsExecuteShow
    MySoftData.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "禁止：勾选后对应配置不生效")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "游戏：勾选为游戏模式。若游戏内仍然无效请以管理员身份运行软件，如果非游戏模式功能正常，请忽略此项")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "松止：勾选后，当松开触发键时，停止对应触发的宏")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "指定进程名：填写后，仅在该进程获得焦点时生效，否则对所有进程生效（可通过工具模块获取进程名）")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "循环次数：-1为无限循环(通过终止所有宏按键取消循环),大于0的整数为循环次数")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "备注：对按键宏的备注信息(这是网友在Gitee上提的第一个需求,加上以示尊重)")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "快捷键：通过%工具%下的编辑快捷键获取配置")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "快捷方式：通过%工具%下的 编辑快捷 或者 编辑字串 获取配置")
    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "其他说明：")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "按键宏的触发键与字串宏的触发键可以混用。")
    posY += 20
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "所有操作只有点击%应用并保存%按钮后才会生效。")

    posY += 20

    tableItem := MySoftData.TableInfo[index]
    tableItem.UnderPosY := posY
}

AddToolUI(index) {
    global ToolCheckInfo

    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX
    ; 配置规则说明
    posY += 35
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "鼠标下窗口信息：")

    ToolCheckInfo.ToolCheckCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 150, posY, 60), "刷新")
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.OnEvent("Click", OnToolCheckHotkey)

    isHotKey := CheckIsHotKey(ToolCheckInfo.ToolCheckHotkey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{} h{}", posX + 210, posY - 5, 100, 20), ToolCheckInfo.ToolCheckHotkey)
    con.Enabled := false

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "鼠标位置坐标：")
    ToolCheckInfo.ToolMousePosCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 120, posY - 5), ToolCheckInfo.PosStr
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 390, posY), "进程名：")
    ToolCheckInfo.ToolProcessNameCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 450, posY - 5), ToolCheckInfo.ProcessName
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "进程标题：")
    ToolCheckInfo.ToolProcessTileCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 120, posY - 5), ToolCheckInfo.ProcessTile
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 390, posY), "进程PID:")
    ToolCheckInfo.ToolProcessPidCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 450, posY - 5), ToolCheckInfo.ProcessPid
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "进程窗口类：")
    ToolCheckInfo.ToolProcessClassCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 120, posY - 5), ToolCheckInfo
    .ProcessClass
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 390, posY), "句柄Id:")
    ToolCheckInfo.ToolProcessIdCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 450, posY - 5), ToolCheckInfo.ProcessId
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "颜色值：")
    ToolCheckInfo.ToolColorCtrl := MyGui.Add("Edit", Format("x{} y{} w250", posX + 120, posY - 5), ToolCheckInfo.Color
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
    ToolCheckInfo.ProcessId := winId
    ToolCheckInfo.Color := StrReplace(PixelGetColor(mouseX, mouseY, "Slow"), "0x", "")
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
