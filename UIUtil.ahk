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
    MyGui.Add("Text", "x200 y5 w70", "暂停:")
    MySoftData.PauseToggleCtrl := MyGui.Add("CheckBox", "x235 y5 w30", "")
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    MySoftData.PauseToggleCtrl.OnEvent("Click", OnPauseHotkey)
    MyGui.Add("Text", "x270 y5 w70", "快捷键:")
    MySoftData.PauseHotkeyCtrl := MyGui.Add("Hotkey", "x320 y2 Center", MySoftData.PauseHotkey)

    MyGui.Add("Text", "x550 y5 w150", "运行后显示窗口:")
    MySoftData.ShowWinCtrl := MyGui.Add("CheckBox", "x650 y5 w30", "")
    MySoftData.ShowWinCtrl.Value := MySoftData.IsExecuteShow
    MySoftData.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    ReloadBtnCtrl := MyGui.Add("Button", "x720 y0 w100 center", "重载")
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
    UIAddFuncArr := [AddNormalHotkeyUI, AddNormalHotkeyUI, AddStringHotkeyUI, AddReplaceKeyUI, AddSoftUI, AddRuleUI,
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
    MyGui.Add("Text", Format("x1050 y{} w80", tableItem.underPosY), "松开停止")

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
    MyGui.Add("Text", Format("x1050 y{} w80", tableItem.underPosY), "松开停止")

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

        symbol := GetTableSymbol(index)
        TKNameValue := " v" symbol "TK" A_Index
        InfoNameValue := " v" symbol "Info" A_Index
        ModeNameValue := " v" symbol "Mode" A_Index
        ForbidNameValue := " v" symbol "Forbid" A_Index
        ProcessNameValue := " v" symbol "ProcessName" A_Index
        LoosenStopNameValue := " v" symbol "LoosenStop" A_Index
        RemarkNameValue := " v" symbol "Remark" A_Index

        newTkControl := MyGui.Add("Edit", "x20 w100 Center" TKNameValue TKPosY, "")
        newInfoControl := MyGui.Add("Edit", "x130 w650" InfoHeight InfoNameValue posY, "")
        newTkControl.Value := tableItem.TKArr.Length >= A_Index ? tableItem.TKArr[A_Index] : ""
        newInfoControl.Value := tableItem.InfoArr.Length >= A_Index ? tableItem.InfoArr[A_Index] : ""

        newKeyBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY), "触发键")
        newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, A_Index))

        newModeControl := MyGui.Add("Checkbox", Format("x870 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x905 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        newProcessNameControl := MyGui.Add("Edit", Format("x940 w130 y{}", tableItem.underPosY) ProcessNameValue, "")
        if (tableItem.ProcessNameArr.Length >= A_Index) {
            value := tableItem.ProcessNameArr[A_Index]
            if (value != "")
                newProcessNameControl.value := value
        }

        if (isMacro) {
            newMacroBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY + 25), "宏指令")

            newLoosenStopControl := MyGui.Add("Checkbox", Format("x1080 w30 y{}", tableItem.underPosY + 5) LoosenStopNameValue,
            "")
            newLoosenStopControl.value := tableItem.LoosenStopArr.Length >= A_Index ? tableItem.LoosenStopArr[A_Index] :
                0
            loosenStopVisible := GetTableLoosenStopVisible(index, A_Index)
            newLoosenStopControl.Visible := loosenStopVisible

            newRemarkTextControl := MyGui.Add("Text", Format("x870 y{} w60", tableItem.underPosY + 30), "备注:")
            newRemarkControl := MyGui.Add("Edit", Format("x920 y{} w180", tableItem.underPosY + 25) RemarkNameValue, ""
            )
            newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""

            tableItem.MacroBtnConArr.Push(newMacroBtnControl)
            tableItem.LoosenStopConArr.Push(newLoosenStopControl)
            tableItem.RemarkConArr.Push(newRemarkControl)
            tableItem.RemarkTextConArr.Push(newRemarkTextControl)
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
    isTriggerStr := CheckIsStringMacroTable(index)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    tableItem.TKArr.Push("")
    tableItem.InfoArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.LoosenStopArr.Push(0)
    tableItem.RemarkArr.Push("")

    heightValue := isMacro ? 60 : 30
    posY := " y" tableItem.underPosY
    TKPosY := isMacro ? " y" tableItem.underPosY + 10 : " y" tableItem.underPosY
    InfoHeight := isMacro ? " h50" : " h20"

    symbol := GetTableSymbol(TableIndex)
    index := tableItem.ModeArr.Length
    TKNameValue := " v" symbol "TK" index
    InfoNameValue := " v" symbol "Info" index
    ModeNameValue := " v" symbol "Mode" index
    ForbidNameValue := " v" symbol "Forbid" index
    ProcessNameValue := " v" symbol "ProcessName" index
    LoosenStopNameValue := " v" symbol "LoosenStop" index
    RemarkNameValue := " v" symbol "Remark" index

    MySoftData.TabCtrl.UseTab(TableIndex)
    newTkControl := MyGui.Add("Edit", "x20 w100 Center" TKNameValue TKPosY, "")
    newInfoControl := MyGui.Add("Edit", "x130 w650" InfoHeight InfoNameValue posY, "")

    newKeyBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY), "触发键")
    newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, index))

    newModeControl := MyGui.Add("Checkbox", Format("x870 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x905 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
    newForbidControl.value := 0
    newProcessNameControl := MyGui.Add("Edit", Format("x940 w130 y{}", tableItem.underPosY - 5) ProcessNameValue, "")
    newProcessNameControl.value := ""
    if (isMacro) {
        newMacroBtnControl := MyGui.Add("Button", Format("x790 w60 y{} h20", tableItem.underPosY + 25), "宏指令")

        newLoosenStopControl := MyGui.Add("Checkbox", Format("x1080 w30 y{}", tableItem.underPosY + 5) LoosenStopNameValue,
        "")
        loosenStopVisible := GetTableLoosenStopVisible(index, A_Index)
        newLoosenStopControl.Visible := loosenStopVisible

        newRemarkTextControl := MyGui.Add("Text", Format("x870 y{} w60", tableItem.underPosY + 30), "备注:")
        newRemarkControl := MyGui.Add("Edit", Format("x920 y{} w180", tableItem.underPosY + 25) RemarkNameValue, "")

        tableItem.MacroBtnConArr.Push(newMacroBtnControl)
        tableItem.LoosenStopConArr.Push(newLoosenStopControl)
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

    tableItem.TKConArr.Pop().Visible := false
    tableItem.InfoConArr.Pop().Visible := false
    tableItem.ModeConArr.Pop().Visible := false
    tableItem.ForbidConArr.Pop().Visible := false
    tableItem.ProcessNameConArr.Pop().Visible := false
    tableItem.KeyBtnConArr.Pop().Visible := false

    if (isMacro) {
        tableItem.LoosenStopConArr.Pop().Visible := false
        tableItem.RemarkConArr.Pop().Visible := false
        tableItem.RemarkTextConArr.Pop().Visible := false
        tableItem.MacroBtnConArr.Pop().Visible := false
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
    MyGui.Add("Text", Format("x20 y{}", posY),
    "图片搜索规则:ImageSearch_ImagePath[_X_Y_W_H](dosomething)(ImagePath为图片路径,X,Y为搜索区域左上角坐标,W,H为搜索区域右下角坐标)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY),
    "案例:ImageSearch_ImagePath_300_300_500_500(lbutton_30_2_50)。从(300,300)到(500,500)搜索图片,找到后执行lbutton_30_2_50指令")

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
