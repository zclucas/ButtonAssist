; 回调函数
OnOpen()
{
    global ScriptInfo

    if (!ScriptInfo.ShowWinCtrl.Value && !ScriptInfo.IsLastSaved) 
        return

    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

;UI相关函数
AddUI()
{
    global MyGui, TabCtrl, TabPosY,TableItemNum
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
    ScriptInfo.PauseHotkeyCtrl := MyGui.Add("Edit", "x320 y0 w80 Center", ScriptInfo.PauseHotkey)

    MyGui.Add("Text", "x450 y5 w150", "运行后显示窗口:")
    ScriptInfo.ShowWinCtrl := MyGui.Add("CheckBox", "x550 y5 w30", "")
    ScriptInfo.ShowWinCtrl.Value := ScriptInfo.IsExecuteShow
    ScriptInfo.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    ReloadBtnCtrl := MyGui.Add("Button", "x620 y0 w100 center", "重载")
    ReloadBtnCtrl.OnEvent("Click", MenuReload)

    TabPosY := 30
    tableNameArr := GetTableNameArr()
    TabCtrl := myGui.Add("Tab3","x10 w880 y" TabPosY " Choose" ScriptInfo.TableIndex, tableNameArr)
   
    loop TableItemNum
    {
        TabCtrl.UseTab(A_Index)
        func := GetUIAddFunc(A_Index)
        func(A_Index)
    }
    TabCtrl.UseTab()

    AddOperBtnUI()
}

GetUIAddFunc(index)
{
    UIAddFuncArr := [AddNormalHotkeyUI, AddLoopKeyUI, AddReplaceKeyUI, AddSoftUI, AddRuleUI, AddToolUI]
    return UIAddFuncArr[index]
}

;添加正常按键宏UI
AddNormalHotkeyUI(index)
{
    global ScriptInfo
    tableItem := GetTableItem(index)
    tableItem.underPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键案例：ctrl_100,0,a_100(全选快捷键)")
    MyGui.Add("Text", Format("x900 y{} w100", tableItem.underPosY), "连点间隔")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")
    

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

AddLoopKeyUI(index)
{
    tableItem := GetTableItem(index)
    tableItem.underPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键案例：z,50,x,50(循环输出z，x)(底层接口bug偶尔卡键，需要再次点击后松开触发键)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "游戏")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

;添加按键替换UI
AddReplaceKeyUI(index)
{
    tableItem := GetTableItem(index)
    tableItem.UnderPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键案例：w,d(按键替换为w和d)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "模式")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

AddSoftUI(index)
{
    tableItem := GetTableItem(index)
    tableItem.UnderPosY := TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)
    MyGui.Add("Text", Format("x30 y{} w70", tableItem.underPosY), "触发键")
    MyGui.Add("Text", Format("x100 y{} w550", tableItem.underPosY), "辅助键信息案例：Notepad.exe(进程名)")
    MyGui.Add("Text", Format("x660 y{} w50", tableItem.underPosY), "模式")
    MyGui.Add("Text", Format("x700 y{} w50", tableItem.underPosY), "禁止")
    MyGui.Add("Text", Format("x740 y{} w100", tableItem.underPosY), "指定进程名")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}


AddRuleUI(index)
{

    posY := TabPosY
    ; 配置规则说明
    posY += 30
    MyGui.Add("Text", Format("x20 y{} w100", posY), "按键时间范围:")
    ScriptInfo.KeyAutoLooseTimeMinCtrl := MyGui.Add("Edit", Format("x100 y{} w70 center", posY - 4), ScriptInfo.KeyAutoLooseTimeMin)
    ScriptInfo.KeyAutoLooseTimeMaxCtrl := MyGui.Add("Edit", Format("x180 y{} w70 center", posY - 4), ScriptInfo.KeyAutoLooseTimeMax)
    MyGui.Add("Text", Format("x280 y{} w600", posY), "(所有辅助键按下到松开的间隔时间)(太小软件检测不到,推荐值:25~35)")
    posY += 30
    MyGui.Add("Text", Format("x20 y{} w100", posY), "按键周期:")
    ScriptInfo.NormalPeriodCtrl := MyGui.Add("Edit", Format("x100 y{} w70 center", posY - 4), ScriptInfo.NormalPeriod)
    MyGui.Add("Text", Format("x180 y{} w600", posY), "(按键持续时间内，每隔多少毫秒触发一次)(应该比上面时间大，推荐值:50+)")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "禁止：勾选后对应配置不生效")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "模式：勾选为游戏模式。若游戏内仍然无效请以管理员身份运行软件")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "指定进程名：填写后，仅在该进程获得焦点时生效，否则对所有进程生效（可通过工具模块获取进程名）")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "触发键规则：填写想要触发配置的按键或组合键，增加前缀~符号，触发时，触发键原有功能不会被屏蔽")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "组合触发键：ctrl,alt,shift,win等修饰键需要用特殊符号代替，参考软件链接")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "简易按键宏配置规则（辅助按键之间没有交集，不重叠）")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "辅助键规则：按键名，按键间隔，按键名，按键间隔，按键名...")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例：d,30,a,30,d,30,a,30,j")
    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "按键宏配置规则（辅助键之间有交集，重叠）")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "辅助键规则：按键名_持续时间，按键间隔，按键名_持续时间，按键间隔...")
    posY += 20
    MyGui.Add("Text", Format("x20 y{}", posY), "案例：ctrl_100,0,a_100(全选快捷键)")

    posY += 20
    
    tableItem := GetTableItem(index)
    tableItem.UnderPosY := posY
}

AddToolUI(index)
{
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
    ToolCheckInfo.ToolCheckHotKeyCtrl := MyGui.Add("Edit", Format("x425 y{} w100 center", posY - 5), ToolCheckInfo.ToolCheckHotkey)


    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "鼠标位置坐标：")
    ToolCheckInfo.ToolMousePosCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.PosStr)

    MyGui.Add("Text", Format("x390 y{}", posY), "进程名：")
    ToolCheckInfo.ToolProcessNameCtrl := MyGui.Add("Edit", Format("x450 y{} w250", posY - 5), ToolCheckInfo.ProcessName)


    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "进程标题：")
    ToolCheckInfo.ToolProcessTileCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.ProcessTile)

    MyGui.Add("Text", Format("x390 y{}", posY), "进程PID：")
    ToolCheckInfo.ToolProcessPidCtrl := MyGui.Add("Edit", Format("x450 y{} w250", posY - 5), ToolCheckInfo.ProcessPid)

    posY += 30
    MyGui.Add("Text", Format("x20 y{}", posY), "进程窗口类：")
    ToolCheckInfo.ToolProcessClassCtrl := MyGui.Add("Edit", Format("x120 y{} w250", posY - 5), ToolCheckInfo.ProcessClass)

    posY += 20
    GetTableItem(index).underPosY := posY
}

RefreshToolUI()
{
    global ToolCheckInfo
    ToolCheckInfo.ToolMousePosCtrl.Value := ToolCheckInfo.PosStr
    ToolCheckInfo.ToolProcessNameCtrl.Value := ToolCheckInfo.ProcessName
    ToolCheckInfo.ToolProcessTileCtrl.Value := ToolCheckInfo.ProcessTile
    ToolCheckInfo.ToolProcessPidCtrl.Value := ToolCheckInfo.ProcessPid
    ToolCheckInfo.ToolProcessClassCtrl.Value := ToolCheckInfo.ProcessClass
}

LoadSavedSettingUI(index)
{
    tableItem := GetTableItem(index)
    loop tableItem.TKArr.Length
    {
        posY := " y" tableItem.underPosY
        symbol := GetTableSymbol(index)
        TKNameValue := " v" symbol "TK" A_Index
        InfoNameValue := " v" symbol "Info" A_Index
        ModeNameValue := " v" symbol "Mode" A_Index
        ForbidNameValue := " v" symbol "Forbid" A_Index
        ProcessNameValue := " v" symbol "ProcessName" A_Index

        newTkControl := MyGui.Add("Edit", "x20 w70 Center" TKNameValue posY, tableItem.TKArr[A_Index])
        newInfoControl := MyGui.Add("Edit", "x100 w550" InfoNameValue posY, tableItem.InfoArr[A_Index])

        newModeControl := MyGui.Add("Checkbox", Format("x670 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x705 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
        newForbidControl.value := tableItem.ForbidArr[A_Index]
        
        newProcessNameControl := MyGui.Add("Edit", Format("x740 w130 y{}", tableItem.underPosY) ProcessNameValue, "")
        if (tableItem.ProcessNameArr.Length >= A_Index)
        {
            value := tableItem.ProcessNameArr[A_Index]
            if (value != "")
                newProcessNameControl.value := value
        }

        tableItem.TKConArr.Push(newTkControl)
        tableItem.InfoConArr.Push(newInfoControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        UpdateUnderPosY(index, 30)
    }
}

MaxUnderPosY()
{
    maxY := 0
    Loop TableItemNum
    {
        posY := GetTableItem(A_Index).UnderPosY
        if (posY > maxY)
            maxY := posY
    }
    return maxY
}

AddOperBtnUI()
{
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

OnAddSetting(*)
{
    global TabCtrl, MyGui
    TableIndex := TabCtrl.Value
    tableItem := GetTableItem(TableIndex)
    btnRemove.Visible := false

    tableItem.TKArr.Push("")
    tableItem.InfoArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")

    posY := " y" tableItem.underPosY
    symbol := GetTableSymbol(TableIndex)
    index := tableItem.TKArr.Length
    TKNameValue := " v" symbol "TKA" index
    InfoNameValue := " v" symbol "Info" index
    ModeNameValue := " v" symbol "Mode" index
    ForbidNameValue := " v" symbol "Forbid" index
    ProcessNameValue := " v" symbol "ProcessName" index

    TabCtrl.UseTab(TableIndex)
    newTkControl := MyGui.Add("Edit", "x20 w70 Center" TKNameValue posY, "")
    newKeyControl := MyGui.Add("Edit", "x100 w550" InfoNameValue posY, "")

    newModeControl := MyGui.Add("Checkbox", Format("x670 w30 y{}", tableItem.underPosY + 5) ModeNameValue, "")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x705 w30 y{}", tableItem.underPosY + 5) ForbidNameValue, "")
    newForbidControl.value := 0
    newProcessNameControl := MyGui.Add("Edit", Format("x740 w130 y{}", tableItem.underPosY - 5) ProcessNameValue, "")
    newProcessNameControl.value := ""

    tableItem.TKConArr.Push(newTkControl)
    tableItem.InfoConArr.Push(newKeyControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)
    UpdateUnderPosY(TableIndex, 30)

    maxY := MaxUnderPosY()
    TabCtrl.UseTab()
    TabCtrl.Move(10, TabPosY, 880, maxY - TabPosY)

    RefreshOperBtnPos()
    SaveWinPos()
    RefreshGui()
}

OnRemoveSetting(*)
{
    global TabCtrl
    TableIndex := TabCtrl.Value
    tableItem := GetTableItem(TableIndex)
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
}

RefreshGui()
{
    global ScriptInfo
    if (ScriptInfo.IsSavedWinPos)
        MyGui.Show(Format("w900" "h{} x{} y{}", MaxUnderPosY() + 50, ScriptInfo.WinPosX, ScriptInfo.WinPosY))
    else
        MyGui.Show(Format("w900" "h{} center", MaxUnderPosY() + 50))
}

RefreshOperBtnPos()
{
    maxY := MaxUnderPosY()
    OperBtnPosY := maxY + 10
    BtnAdd.Move(100, OperBtnPosY)
    BtnRemove.Move(300, OperBtnPosY)
    BtnSave.Move(500, OperBtnPosY)
}
; 系统托盘优化
CustomTrayMenu(){
    A_TrayMenu.Insert("&Suspend Hotkeys", "重置位置并显示窗口", ResetWinPosAndRefreshGui)
    A_TrayMenu.Insert("&Suspend Hotkeys", "显示窗口", (*)=>RefreshGui())
    A_TrayMenu.Delete("&Pause Script")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "显示窗口"
}

MenuReload(*)
{
    SaveWinPos()
    Reload()
}
ResetWinPosAndRefreshGui(*)
{
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    ScriptInfo.IsSavedWinPos := false
    RefreshGui()
}
OnPauseHotkey(*)
{
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsPause := !ScriptInfo.IsPause
    ScriptInfo.PauseToggleCtrl.Value := ScriptInfo.IsPause
    Suspend(ScriptInfo.IsPause)
}

OnToolCheckHotkey(*)
{
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ResetTimer()
}


OnShowWinChanged(*)
{
    global ScriptInfo ; 访问全局变量
    ScriptInfo.IsExecuteShow := !ScriptInfo.IsExecuteShow
    IniWrite(ScriptInfo.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
}