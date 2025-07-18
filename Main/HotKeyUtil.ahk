BindScrollHotkey(key, action) {
    if (MySoftData.SB == "")
        return

    HotIfWinActive("RMTv")
    Hotkey(key, action)
    HotIfWinActive
}

BindShortcut(triggerInfo, action) {
    if (triggerInfo == "")
        return

    isString := SubStr(triggerInfo, 1, 1) == ":"

    if (isString) {
        Hotstring(triggerInfo, action)
    }
    else {
        key := "$*~" triggerInfo
        Hotkey(key, action)
    }
}

GetClosureActionNew(tableIndex, itemIndex, func) {
    funcObj := func.Bind(tableIndex, itemIndex)
    return (*) => funcObj()
}

GetClosureAction(tableItem, macro, index, func) {     ;获取闭包函数
    funcObj := func.Bind(tableItem, macro, index)
    return (*) => funcObj()
}

;按键宏命令
OnTriggerMacroKeyAndInit(tableItem, macro, index) {
    tableItem.CmdActionArr[index] := []
    tableItem.KilledArr[index] := false
    tableItem.ActionCount[index] := 0
    tableItem.VariableMapArr[index]["循环次数"] := 1
    tableItem.SuccessClearActionArr[index] := Map()
    isContinue := tableItem.TKArr.Has(index) && MySoftData.ContinueKeyMap.Has(tableItem.TKArr[index]) && tableItem.LoopCountArr[
        index] == 1
    isLoop := tableItem.LoopCountArr[index] == -1

    loop {
        isOver := tableItem.ActionCount[index] >= tableItem.LoopCountArr[index]
        isFirst := tableItem.ActionCount[index] == 0
        isSecond := tableItem.ActionCount[index] == 1

        if (tableItem.KilledArr[index])
            break

        if (!isLoop && !isContinue && isOver)
            break

        if (!isFirst && isContinue) {
            key := MySoftData.ContinueKeyMap[tableItem.TKArr[index]]
            interval := isSecond ? MySoftData.ContinueSecondIntervale : MySoftData.ContinueIntervale
            Sleep(interval)

            if (!GetKeyState(key, "P")) {
                break
            }
        }

        OnTriggerMacroOnce(tableItem, macro, index)
        tableItem.ActionCount[index]++
        tableItem.VariableMapArr[index]["循环次数"] += 1
    }
    ; OnFinishMacro(tableItem, macro, index)
}

OnTriggerMacroOnce(tableItem, macro, index) {
    global MySoftData
    cmdArr := SplitMacro(macro)

    loop cmdArr.Length {
        if (tableItem.KilledArr[index])
            break

        paramArr := StrSplit(cmdArr[A_Index], "_")
        IsMouseMove := StrCompare(paramArr[1], "移动", false) == 0
        IsSearch := StrCompare(paramArr[1], "搜索", false) == 0
        IsSearchPro := StrCompare(paramArr[1], "搜索Pro", false) == 0
        IsPressKey := StrCompare(paramArr[1], "按键", false) == 0
        IsInterval := StrCompare(paramArr[1], "间隔", false) == 0
        IsFile := StrCompare(paramArr[1], "文件", false) == 0
        IsIf := StrCompare(paramArr[1], "如果", false) == 0
        IsCoord := StrCompare(paramArr[1], "移动Pro", false) == 0
        IsOutput := StrCompare(paramArr[1], "输出", false) == 0
        IsStop := StrCompare(paramArr[1], "终止", false) == 0
        IsVariable := StrCompare(paramArr[1], "变量", false) == 0
        IsSubMacro := StrCompare(paramArr[1], "子宏", false) == 0
        IsOperation := StrCompare(paramArr[1], "运算", false) == 0
        IsBGMouse := StrCompare(paramArr[1], "后台鼠标", false) == 0
        if (IsMouseMove) {
            OnMouseMove(tableItem, cmdArr[A_Index], index)
        }
        else if (IsSearch || IsSearchPro) {
            OnSearch(tableItem, cmdArr[A_Index], index)
        }
        else if (IsPressKey) {
            OnPressKey(tableItem, cmdArr[A_Index], index)
        }
        else if (IsInterval) {
            OnInterval(tableItem, cmdArr[A_Index], index)
        }
        else if (IsFile) {
            OnRunFile(tableItem, cmdArr[A_Index], index)
        }
        else if (IsIf) {
            OnCompare(tableItem, cmdArr[A_Index], index)
        }
        else if (IsCoord) {
            OnCoord(tableItem, cmdArr[A_Index], index)
        }
        else if (IsOutput) {
            OnOutput(tableItem, cmdArr[A_Index], index)
        }
        else if (IsStop) {
            OnStop(tableItem, cmdArr[A_Index], index)
        }
        else if (IsVariable) {
            OnVariable(tableItem, cmdArr[A_Index], index)
        }
        else if (IsSubMacro) {
            OnSubMacro(tableItem, cmdArr[A_Index], index)
        }
        else if (IsOperation) {
            OnOperation(tableItem, cmdArr[A_Index], index)
        }
        else if (IsBGMouse) {
            OnBGMouse(tableItem, cmdArr[A_Index], index)
        }
    }
}

OnSearch(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    dataFile := StrCompare(paramArr[1], "搜索", false) == 0 ? SearchFile : SearchProFile
    Data := GetMacroCMDData(dataFile, paramArr[2])
    searchCount := Integer(Data.SearchCount)
    searchInterval := Integer(Data.SearchInterval)
    tableItem.SuccessClearActionArr[index].Set(Data.SerialStr, [])
    MacroType := tableItem.MacroTypeArr[index]

    LastSumTime := 0
    loop searchCount {
        if (!tableItem.SuccessClearActionArr[index].Has(Data.SerialStr)) ;第一次搜索成功就退出
            break

        if (tableItem.KilledArr[index])
            break

        FloatInterval := GetFloatTime(searchInterval, MySoftData.PreIntervalFloat)
        if (MacroType == 1) {
            OnSearchOnce(tableItem, Data, index, A_Index == searchCount)
            if (searchCount != A_Index)
                Sleep(FloatInterval)
        }
        else if (MacroType == 2) {
            if (A_Index == 1) {
                OnSearchOnce(tableItem, Data, index, A_Index == searchCount)
            }
            else {
                action := OnSearchOnce.Bind(tableItem, Data, index, A_Index == searchCount)
                tableItem.SuccessClearActionArr[index][Data.SerialStr].Push(action)
                SetTimer action, -LastSumTime
            }
            LastSumTime := LastSumTime + FloatInterval
        }
    }
}

; 定义OpenCV图片搜索函数原型
FindImage(targetPath, searchX, searchY, searchW, searchH, matchThreshold, x, y) {
    return DllCall("ImageFinder.dll\FindImage", "AStr", targetPath,
        "Int", searchX, "Int", searchY, "Int", searchW, "Int", searchH,
        "Int", matchThreshold, "Int*", x, "Int*", y, "Cdecl Int")
}

OnSearchOnce(tableItem, Data, index, isFinally) {
    X1 := Integer(Data.StartPosX)
    Y1 := Integer(Data.StartPosY)
    X2 := Integer(Data.EndPosX)
    Y2 := Integer(Data.EndPosY)
    VariableMap := tableItem.VariableMapArr[index]
    MacroType := tableItem.MacroTypeArr[index]

    CoordMode("Pixel", "Screen")
    if (Data.SearchType == 1) {
        OutputVarX := 0
        OutputVarY := 0
        found := FindImage(Data.SearchImagePath, X1, Y1, X2 - X1, Y2 - Y1, Data.Similar, &OutputVarX, &
            OutputVarY)
    }
    else if (Data.SearchType == 2) {
        color := "0X" Data.SearchColor
        similar := Integer(-2.55 * Data.Similar + 255)
        found := PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, color, similar)
    }
    else if (Data.SearchType == 3) {
        text := Data.SearchText
        found := CheckScreenContainText(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, text, Data.OCRType)
    }

    if (found || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.SuccessClearActionArr[index].Has(Data.SerialStr)) {
            SuccessClearActionArr := tableItem.SuccessClearActionArr[index].Get(Data.SerialStr)
            loop SuccessClearActionArr.Length {
                action := SuccessClearActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.SuccessClearActionArr[index].Delete(Data.SerialStr)
        }
    }

    if (found) {
        ;自动移动鼠标
        CoordMode("Mouse", "Screen")
        SendMode("Event")
        Speed := 100 - Data.Speed
        Pos := [OutputVarX, OutputVarY]
        if (Data.SearchType == 1) {
            imageSize := GetImageSize(Data.SearchImagePath)
            Pos := [OutputVarX + imageSize[1] / 2, OutputVarY + imageSize[2] / 2]
        }

        if (Data.ResultToggle) {
            VariableMap[Data.ResultSaveName] := Data.TrueValue
        }

        if (Data.CoordToogle) {
            VariableMap[Data.CoordXName] := Pos[1]
            VariableMap[Data.CoordYName] := Pos[2]
        }

        Pos[1] := GetFloatValue(Pos[1], MySoftData.CoordXFloat)
        Pos[2] := GetFloatValue(Pos[2], MySoftData.CoordYFloat)
        if (Data.AutoType == 3) {
            SetDefaultMouseSpeed(Speed)
            Click(Format("{} {} {}"), Pos[1], Pos[2], Data.ClickCount)
        }
        else if (Data.AutoType == 2) {
            MouseMove(Pos[1], Pos[2], Speed)
        }

        if (Data.TrueCommandStr == "")
            return

        if (MacroType == 1) {
            OnTriggerMacroOnce(tableItem, Data.TrueCommandStr, index)
        }
        else if (MacroType == 2) {
            action := OnTriggerMacroOnce.Bind(tableItem, Data.TrueCommandStr, index)
            SetTimer(action, -1)
        }
    }

    if (isFinally && !found) {

        if (Data.ResultToggle) {
            VariableMap[Data.ResultSaveName] := Data.FalseValue
        }

        if (Data.FalseCommandStr == "")
            return

        if (MacroType == 1) {
            OnTriggerMacroOnce(tableItem, Data.FalseCommandStr, index)
        }
        else if (MacroType == 2) {
            action := OnTriggerMacroOnce.Bind(tableItem, Data.FalseCommandStr, index)
            SetTimer(action, -1)
        }
    }
}

OnRunFile(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(FileFile, paramArr[2])
    if (Data.ProcessName != "") {
        Run(Data.ProcessName)
        return
    }

    isMp3 := RegExMatch(Data.FilePath, ".mp3$")
    if (isMp3 && Data.BackPlay) {
        playAudioCmd := Format('wscript.exe "{}" "{}"', vbsPath, Data.FilePath)
        Run(playAudioCmd)
        return
    }

    Run(Data.FilePath)
}

OnCompare(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(CompareFile, paramArr[2])
    VariableMap := tableItem.VariableMapArr[index]
    result := Data.LogicalType == 1 ? true : false
    loop 4 {
        if (!Data.ToggleArr[A_Index] || Data.NameArr[A_Index] == "空")
            continue

        Name := Data.NameArr[A_Index]
        OhterName := Data.VariableArr[A_Index]
        if (!VariableMap.Has(Name)) {
            ShowNoVariableTip(Name)
            return
        }

        if (OhterName != "空" && !VariableMap.Has(OhterName)) {
            ShowNoVariableTip(OhterName)
            return
        }

        Value := VariableMap[Name]
        OtherValue := OhterName != "空" ? VariableMap[OhterName] : Data.ValueArr[A_Index]

        currentComparison := false
        switch Data.CompareTypeArr[A_Index] {
            case 1: currentComparison := Value > OtherValue
            case 2: currentComparison := Value >= OtherValue
            case 3: currentComparison := Value == OtherValue
            case 4: currentComparison := Value <= OtherValue
            case 5: currentComparison := Value < OtherValue
        }

        if (Data.LogicalType == 1) {
            result := result && currentComparison
            if (!result)
                break
        } else {
            result := result || currentComparison
            if (result)
                break
        }
    }

    if (Data.SaveToggle) {
        SaveValue := result ? Data.TrueValue : Data.FalseValue
        VariableMap[Data.SaveName] := SaveValue
    }

    MacroType := tableItem.MacroTypeArr[index]
    macro := ""
    macro := result && Data.TrueMacro != "" ? Data.TrueMacro : macro
    macro := !result && Data.FalseMacro != "" ? Data.FalseMacro : macro
    if (macro == "")
        return

    if (MacroType == 1) {
        OnTriggerMacroOnce(tableItem, macro, index)
    }
    else if (MacroType == 2) {
        action := OnTriggerMacroOnce.Bind(tableItem, macro, index)
        SetTimer(action, -1)
    }
}

OnCoord(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(CoordFile, paramArr[2])
    MacroType := tableItem.MacroTypeArr[index]

    LastSumTime := 0
    loop Data.Count {
        if (tableItem.KilledArr[index])
            return

        FloatInterval := GetFloatTime(Data.Interval, MySoftData.PreIntervalFloat)
        if (MacroType == 1) {
            OnCoordOnce(tableItem, index, Data)
            if (A_Index != Data.Count)
                Sleep(FloatInterval)
        }
        else if (MacroType == 2) {
            if (A_Index == 1) {
                OnCoordOnce(tableItem, index, Data)
            }
            else {
                tempAction := OnCoordOnce.Bind(tableItem, index, Data)
                tableItem.CmdActionArr[index].Push(tempAction)
                SetTimer tempAction, -LastSumTime
            }
            LastSumTime := LastSumTime + FloatInterval
        }
    }
}

OnCoordOnce(tableItem, index, Data) {
    SendMode("Event")
    CoordMode("Mouse", "Screen")
    Speed := 100 - Data.Speed
    VariableMap := tableItem.VariableMapArr[index]
    if (Data.NameX != "空" && !VariableMap.Has(Data.NameX)) {
        ShowNoVariableTip(Data.NameX)
        return
    }

    if (Data.NameY != "空" && !VariableMap.Has(Data.NameY)) {
        ShowNoVariableTip(Data.NameY)
        return
    }

    PosX := Data.NameX != "空" ? VariableMap[Data.NameX] : Data.PosX
    PosY := Data.NameY != "空" ? VariableMap[Data.NameY] : Data.PosY
    PosX := GetFloatValue(PosX, MySoftData.CoordXFloat)
    PosY := GetFloatValue(PosY, MySoftData.CoordYFloat)
    if (Data.IsGameView) {
        MOUSEEVENTF_MOVE := 0x0001
        DllCall("mouse_event", "UInt", MOUSEEVENTF_MOVE, "UInt", PosX, "UInt", PosY, "UInt", 0, "UInt", 0)
    }
    else if (Data.IsRelative) {
        MouseMove(PosX, PosY, Speed, "R")
    }
    else
        MouseMove(PosX, PosY, Speed)
}

OnOutput(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(OutputFile, paramArr[2])
    VariableMap := tableItem.VariableMapArr[index]
    OutputText := Data.Text
    if (Data.Name != "空" && Data.Name != "")
        OutputText := VariableMap[Data.Name]
    if (Data.IsCover) {
        A_Clipboard := OutputText
    }

    if (Data.OutputType == 1) {
        SendText(OutputText)
    }
    else if (Data.OutputType == 2) {
        Send "{Blind}^v"
    }
    else if (Data.OutputType == 3) {
        MyWinClip.Paste(A_Clipboard)
    }
}

OnStop(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(StopFile, paramArr[2])
    tableIndex := 0
    if (Data.StopType == 1) {       ;终止自己
        KillTableItemMacro(tableItem, index)
        return
    }
    else if (Data.StopType == 2) {      ;终止按键宏
        tableIndex := 1
    }
    else if (Data.StopType == 3) {      ;终止字串宏
        tableIndex := 2
    }
    else if (Data.StopType == 4) {      ;终止子宏
        tableIndex := 3
    }
    stopTableItem := MySoftData.TableInfo[tableIndex]
    isWork := stopTableItem.IsWorkArr[Data.StopIndex]
    if (isWork || MySoftData.isWork) {
        MySubMacroStopAction(tableIndex, Data.StopIndex)
        return
    }

    KillTableItemMacro(stopTableItem, Data.StopIndex)
}

OnSubMacro(tableItem, cmd, index) {
    global MySoftData
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(SubMacroFile, paramArr[2])
    macroTableIndex := 1
    macroItem := tableItem
    macro := tableItem.MacroArr[index]
    macroIndex := Data.Type != 1 ? Data.Index : index
    if (Data.Type == 2) {
        macroTableIndex := 1
        macroItem := MySoftData.TableInfo[1]
    }
    else if (Data.Type == 3) {
        macroTableIndex := 2
        macroItem := MySoftData.TableInfo[2]
    }
    else if (Data.Type == 4) {
        macroTableIndex := 3
        macroItem := MySoftData.TableInfo[3]
    }

    redirect := macroItem.SerialArr.Length < Data.Index || macroItem.SerialArr[Data.Index] != Data.MacroSerial
    if (Data.Type != 1 && redirect) {
        loop macroItem.ModeArr.Length {
            if (Data.MacroSerial == macroItem.SerialArr[A_Index]) {
                macro := macroItem.MacroArr[A_Index]
                macroIndex := A_Index
                break
            }
        }
    }

    macro := macroItem.MacroArr[macroIndex]
    if (Data.CallType == 1) {   ;插入
        LoopCount := macroItem.LoopCountArr[macroIndex]
        IsLoop := macroItem.LoopCountArr[macroIndex] == -1
        loop {
            if (!IsLoop && LoopCount <= 0)
                break

            OnTriggerMacroOnce(tableItem, macro, index)
            LoopCount -= 1
        }
    }
    else if (Data.CallType == 2) {  ;触发
        if (Data.Type != 1 && macroItem.MacroTypeArr[macroIndex] == 1) { ;串联
            MyTriggerSubMacro(macroTableIndex, macroIndex)
            return
        }
        action := OnTriggerMacroKeyAndInit.Bind(macroItem, macro, macroIndex)
        SetTimer(action, -1)
    }
}

OnVariable(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(VariableFile, paramArr[2])
    count := Data.SearchCount
    interval := Data.SearchInterval
    tableItem.SuccessClearActionArr[index].Set(Data.ExtractStr, [])
    VariableMap := tableItem.VariableMapArr[index]

    if (Data.CreateType == 3) {     ;提取
        OnExtractingVariablesOnce(tableItem, index, Data, count == 1)
        loop count {
            if (A_Index == 1)
                continue

            if (!tableItem.SuccessClearActionArr[index].Has(Data.ExtractStr)) ;第一次比较成功就退出
                break

            tempAction := OnExtractingVariablesOnce.Bind(tableItem, index, Data, A_Index == count)
            leftTime := GetFloatTime((Integer(interval) * (A_Index - 1)), MySoftData.PreIntervalFloat)
            tableItem.SuccessClearActionArr[index][Data.ExtractStr].Push(tempAction)
            SetTimer tempAction, -leftTime
        }
        return
    }
    loop 4 {
        if (!Data.ToggleArr[A_Index])
            continue

        name := Data.NameArr[A_Index]   ;赋值
        value := Data.ValueArr[A_Index]
        if (Data.CreateType == 2) {     ;选择复制
            copyName := Data.SelectCopyNameArr[A_Index]
            if (copyName == "X坐标" || copyName == "Y坐标") {
                CoordMode("Mouse", "Screen")
                MouseGetPos &mouseX, &mouseY
                value := copyName == "X坐标" ? mouseX : mouseY
            }
            else if (VariableMap.Has(copyName)) {
                value := VariableMap[copyName]
            }
        }
        VariableMap[name] := value
    }
}

OnExtractingVariablesOnce(tableItem, index, variableData, isFinally) {
    X1 := variableData.StartPosX
    Y1 := variableData.StartPosY
    X2 := variableData.EndPosX
    Y2 := variableData.EndPosY
    if (variableData.ExtractType == 1) {
        TextObjs := GetScreenTextObjArr(X1, Y1, X2, Y2, variableData.OCRType)
        TextObjs := TextObjs == "" ? [] : TextObjs
    }
    else {
        if (!IsClipboardText())
            return
        TextObjs := []
        obj := Object()
        obj.Text := A_Clipboard
        TextObjs.Push(obj)
    }

    isOk := false
    VariableMap := tableItem.VariableMapArr[index]
    for index, value in TextObjs {
        baseVariableArr := ExtractNumbers(value.Text, variableData.ExtractStr)
        if (baseVariableArr == "")
            continue

        loop baseVariableArr.Length {
            if (variableData.ToggleArr[A_Index]) {
                name := variableData.NameArr[A_Index]
                value := baseVariableArr[A_Index]
                VariableMap[name] := value
            }
        }

        isOk := true
        break
    }

    if (isOk || isFinally) {
        ;清除后续的搜索和搜索记录
        if (tableItem.SuccessClearActionArr[index].Has(variableData.ExtractStr)) {
            SuccessClearActionArr := tableItem.SuccessClearActionArr[index].Get(variableData.ExtractStr)
            loop SuccessClearActionArr.Length {
                action := SuccessClearActionArr[A_Index]
                SetTimer action, 0
            }
            tableItem.SuccessClearActionArr[index].Delete(variableData.ExtractStr)
        }
    }
}

OnOperation(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(OperationFile, paramArr[2])
    VariableMap := tableItem.VariableMapArr[index]
    loop 4 {
        if (!Data.ToggleArr[A_Index] || Data.NameArr[A_Index] == "空")
            continue
        Name := Data.NameArr[A_Index]
        SymbolArr := Data.SymbolGroups[A_Index]
        ValueArr := Data.ValueGroups[A_Index]
        Value := GetVariableOperationResult(VariableMap, Name, SymbolArr, ValueArr)
        if (Data.UpdateTypeArr[A_Index] == 1) {
            VariableMap[Name] := Value
        }
        else {
            VariableMap[Data.UpdateNameArr[A_Index]] := Value
        }
    }
}

OnBGMouse(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    Data := GetMacroCMDData(BGMouseFile, paramArr[2])

    WM_DOWN_ARR := [0x201, 0x204, 0x207]    ;左键，中键，右键
    WM_UP_ARR := [0x202, 0x205, 0x208]    ;左键，中键，右键
    WM_DCLICK_ARR := [0x203, 0x206, 0x209]    ;左键，中键，右键

    VariableMap := tableItem.VariableMapArr[index]
    if (Data.PosXName != "空" && !VariableMap.Has(Data.PosXName)) {
        ShowNoVariableTip(Data.PosXName)
        return
    }

    if (Data.PosYName != "空" && !VariableMap.Has(Data.PosYName)) {
        ShowNoVariableTip(Data.PosYName)
        return
    }

    PosX := Data.PosXName != "空" ? VariableMap[Data.PosXName] : Data.PosX
    PosY := Data.PosYName != "空" ? VariableMap[Data.PosYName] : Data.PosY
    PosX := GetFloatValue(PosX, MySoftData.CoordXFloat)
    PosY := GetFloatValue(PosY, MySoftData.CoordYFloat)

    hwndList := WinGetList(Data.TargetTitle)
    loop hwndList.Length {
        hwnd := hwndList[A_Index]
        ; 点击位置（窗口客户区坐标）
        lParam := (PosY << 16) | (PosX & 0xFFFF)

        if (Data.MouseType == 4) {  ;滚轮
            if (Data.ScrollV != 0) {
                value := 120 * Data.ScrollV
                PostMessage(0x020A, (value << 16), lParam, , "ahk_id " hwnd)
            }
            else if (Data.ScrollH != 0) {
                value := 120 * Data.ScrollH
                PostMessage(0x020E, (value << 16), lParam, , "ahk_id " hwnd)
            }
            return
        }

        if (Data.OperateType == 1) {    ;点击
            PostMessage WM_DOWN_ARR[Data.MouseType], 1, lParam, , "ahk_id " hwnd
            Sleep Data.ClickTime
            PostMessage WM_UP_ARR[Data.MouseType], 0, lParam, , "ahk_id " hwnd
        }
        else if (Data.OperateType == 2) {   ;双击
            PostMessage WM_DCLICK_ARR[Data.MouseType], 1, lParam, , "ahk_id " hwnd
            Sleep Data.ClickTime
            PostMessage WM_UP_ARR[Data.MouseType], 0, lParam, , "ahk_id " hwnd
        }
        else if (Data.OperateType == 3) {   ;按下
            PostMessage WM_DOWN_ARR[Data.MouseType], 1, lParam, , "ahk_id " hwnd
        }
        else if (Data.OperateType == 4) {   ;松开
            PostMessage WM_UP_ARR[Data.MouseType], 0, lParam, , "ahk_id " hwnd
        }
    }
}

OnMouseMove(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    PosX := Integer(paramArr[2])
    PosY := Integer(paramArr[3])
    Speed := paramArr.Length >= 4 ? 100 - Integer(paramArr[4]) : 0
    IsRelative := paramArr.Length >= 5 ? Integer(paramArr[5]) : 0

    PosX := GetFloatValue(PosX, MySoftData.CoordXFloat)
    PosY := GetFloatValue(PosY, MySoftData.CoordYFloat)
    SendMode("Event")
    CoordMode("Mouse", "Screen")
    if (IsRelative) {
        MouseMove(PosX, PosY, Speed, "R")
    }
    else {
        MouseMove(PosX, PosY, Speed)
    }
}

OnInterval(tableItem, cmd, index) {
    paramArr := StrSplit(cmd, "_")
    if (paramArr.Length == 2) {
        interval := Integer(paramArr[2])
    }
    else {
        VariableMap := tableItem.VariableMapArr[index]
        if (!VariableMap.Has(paramArr[3])) {
            ShowNoVariableTip(paramArr[3])
            return
        }

        interval := VariableMap[paramArr[3]]
    }
    FloatInterval := GetFloatTime(interval, MySoftData.IntervalFloat)
    curTime := 0
    clip := Min(500, FloatInterval)
    while (curTime < FloatInterval) {
        if (tableItem.KilledArr[index])
            break
        Sleep(clip)
        curTime += clip
        clip := Min(500, FloatInterval - curTime)
    }
}

OnPressKey(tableItem, cmd, index) {
    paramArr := SplitKeyCommand(cmd)
    isJoyKey := SubStr(paramArr[2], 1, 3) == "Joy"
    isJoyAxis := StrCompare(SubStr(paramArr[2], 1, 7), "JoyAxis", false) == 0
    action := tableItem.ModeArr[index] == 1 ? SendGameModeKeyClick : SendNormalKeyClick
    action := isJoyKey ? SendJoyBtnClick : action
    action := isJoyAxis ? SendJoyAxisClick : action

    holdTime := Integer(paramArr[3])
    keyType := paramArr.Length >= 4 ? Integer(paramArr[4]) : 1
    count := paramArr.Length >= 5 ? Integer(paramArr[5]) : 1
    IntervalTime := paramArr.Length >= 6 ? Integer(paramArr[6]) : 1000
    MacroType := tableItem.MacroTypeArr[index]

    LastSumTime := 0
    loop count {
        if (tableItem.KilledArr[index])
            break

        FloatHold := GetFloatTime(holdTime, MySoftData.HoldFloat)
        FloatInterval := GetFloatTime(IntervalTime, MySoftData.PreIntervalFloat)
        if (MySoftData.isWork && MacroType == 1) {
            action(paramArr[2], FloatHold, tableItem, index, keyType)
            if (A_Index != count)
                Sleep(FloatInterval)
        }
        else if (MacroType == 1) {
            action(paramArr[2], FloatHold, tableItem, index, keyType)
            if (keyType == 1)
                Sleep(FloatHold)
            if (A_Index != count)
                Sleep(FloatInterval)
        }
        else if (MacroType == 2) {
            if (A_Index == 1) {
                action(paramArr[2], FloatHold, tableItem, index, keyType)
            }
            else {
                tempAction := action.Bind(paramArr[2], FloatHold, tableItem, index, keyType)
                tableItem.CmdActionArr[index].Push(tempAction)
                SetTimer tempAction, -LastSumTime
            }
            LastSumTime := LastSumTime + FloatInterval + FloatHold
        }
    }
}

;按键替换
OnReplaceDownKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 1, tableItem, index)
        }
        else {
            SendNormalKey(assistKey, 1, tableItem, index)
        }
    }

}

OnReplaceUpKey(tableItem, info, index) {
    infos := StrSplit(info, ",")
    mode := tableItem.ModeArr[index]

    loop infos.Length {
        assistKey := infos[A_Index]
        if (mode == 1) {
            SendGameModeKey(assistKey, 0, tableItem, index)
        }
        else {
            SendNormalKey(assistKey, 0, tableItem, index)
        }
    }

}

;软件宏
OnSoftTriggerKey(tableItem, info, index) {
    run info
}

;按钮回调
GetTableClosureAction(action, TableItem, index) {
    funcObj := action.Bind(TableItem, index)
    return (*) => funcObj()
}

MenuReload(*) {
    SaveWinPos()
    Reload()
}

OnChangeRecordOption(*) {
    ToolCheckInfo.RecordKeyboardValue := ToolCheckInfo.RecordKeyboardCtrl.Value
    ToolCheckInfo.RecordMouseValue := ToolCheckInfo.RecordMouseCtrl.Value
    ToolCheckInfo.RecordMouseRelativeValue := ToolCheckInfo.RecordMouseRelativeCtrl.value
    ToolCheckInfo.RecordJoyValue := ToolCheckInfo.RecordJoyCtrl.Value
}

OnToolTextFilterSelectImage(*) {
    global ToolCheckInfo
    path := FileSelect(, , "选择图片")
    if (path == "")
        return
    ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
    result := ocr.ocr_from_file(path)
    ToolCheckInfo.ToolTextCtrl.Value := result
    A_Clipboard := result
}

OnClearToolText(*) {
    ToolCheckInfo.ToolTextCtrl.Value := ""
}

OnToolTextFilterScreenShot(*) {
    A_Clipboard := ""  ; 清空剪贴板
    Run("ms-screenclip:")
    SetTimer(OnToolTextCheckScreenShot, 500)  ; 每 500 毫秒检查一次剪贴板
}

OnToolTextCheckScreenShot() {
    ; 如果剪贴板中有图像
    if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
    {
        filePath := A_WorkingDir "\Images\TextFilter.png"
        if (!DirExist(A_WorkingDir "\Images")) {
            DirCreate(A_WorkingDir "\Images")
        }

        SaveClipToBitmap(filePath)
        ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
        result := ocr.ocr_from_file(filePath)
        ToolCheckInfo.ToolTextCtrl.Value := result
        A_Clipboard := result
        ; 停止监听
        SetTimer(, 0)
    }
}

OnShowWinChanged(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsExecuteShow := !MySoftData.IsExecuteShow
    IniWrite(MySoftData.IsExecuteShow, IniFile, IniSection, "IsExecuteShow")
}

OnBootStartChanged(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsBootStart := MySoftData.BootStartCtrl.Value
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    softPath := A_ScriptFullPath
    if (MySoftData.IsBootStart) {
        RegWrite(softPath, "REG_SZ", regPath, "RMT")
    }
    else {
        RegDelete(regPath, "RMT")
    }
    IniWrite(MySoftData.BootStartCtrl.Value, IniFile, IniSection, "IsBootStart")
}

;按键模拟
SendGameModeKeyClick(key, holdTime, tableItem, index, keyType) {
    if (MySoftData.isWork && keyType == 1) {
        SendGameModeKey(Key, 1, tableItem, index)
        Sleep(holdTime)
        SendGameModeKey(Key, 0, tableItem, index)
    }
    else if (keyType == 1) {
        SendGameModeKey(key, 1, tableItem, index)
        SetTimer(() => SendGameModeKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendGameModeKey(key, state, tableItem, index)
    }
}

SendGameModeKey(Key, state, tableItem, index) {
    if (Key == "逗号")
        Key := ","
    VK := GetKeyVK(Key)
    SC := GetKeySC(Key)

    if (VK == 1 || VK == 2 || VK == 4) {   ; 鼠标左键、右键、中键
        SendGameMouseKey(key, state, tableItem, index)
        return
    }

    ; 检测是否为扩展键
    isExtendedKey := false
    extendedArr := [0x25, 0x26, 0x27, 0x28, 0X2D, 0X2E, 0X23, 0X24, 0X21, 0X22]    ; 左、上、右、下箭头
    for index, value in extendedArr {
        if (VK == value) {
            isExtendedKey := true
            break
        }
    }

    if (state == 1) {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", isExtendedKey ? 0x1 : 0, "UPtr", 0)
        tableItem.HoldKeyArr[index][key] := "Game"
    }
    else {
        DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", (isExtendedKey ? 0x3 : 0x2), "UPtr", 0)
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendGameMouseKey(key, state, tableItem, index) {
    ; 鼠标按下和松开的标志
    if (StrCompare(Key, "LButton", false) == 0) {
        mouseDown := 0x0002
        mouseUp := 0x0004
    }
    else if (StrCompare(Key, "RButton", false) == 0) {
        mouseDown := 0x0008
        mouseUp := 0x0010
    }
    else if (StrCompare(Key, "MButton", false) == 0) {
        mouseDown := 0x0020
        mouseUp := 0x0040
    }

    if (state == 1) {
        DllCall("mouse_event", "UInt", mouseDown, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        tableItem.HoldKeyArr[index][key] := "GameMouse"
    }
    else {
        DllCall("mouse_event", "UInt", mouseUp, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendNormalKeyClick(Key, holdTime, tableItem, index, keyType) {
    if (MySoftData.isWork && keyType == 1) {
        SendNormalKey(Key, 1, tableItem, index)
        Sleep(holdTime)
        SendNormalKey(Key, 0, tableItem, index)
    }
    else if (keyType == 1) {
        SendNormalKey(Key, 1, tableItem, index)
        SetTimer(() => SendNormalKey(Key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendNormalKey(Key, state, tableItem, index)
    }
}

SendNormalKey(Key, state, tableItem, index) {
    if (Key == "逗号")
        Key := ","
    if (MySoftData.SpecialNumKeyMap.Has(Key)) {
        if (state == 0)
            return
        keySymbol := "{Blind}{" Key " 1}"
        Send(keySymbol)
        return
    }

    if (state == 1) {
        keySymbol := "{Blind}{" Key " down}"
    }
    else {
        keySymbol := "{Blind}{" Key " up}"
    }

    Send(keySymbol)
    if (state == 1) {
        tableItem.HoldKeyArr[index][Key] := "Normal"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(Key)) {
            tableItem.HoldKeyArr[index].Delete(Key)
        }
    }
}

SendJoyBtnClick(key, holdTime, tableItem, index, keyType) {
    if (!CheckIfInstallVjoy()) {
        MsgBox("使用手柄功能前,请先安装Joy目录下的vJoy驱动!")
        return
    }

    if (keyType == 1) {
        SendJoyBtnKey(key, 1, tableItem, index)
        SetTimer(() => SendJoyBtnKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendJoyBtnKey(key, state, tableItem, index)
    }
}

SendJoyBtnKey(key, state, tableItem, index) {
    joyIndex := SubStr(key, 4)
    MyvJoy.SetBtn(state, joyIndex)

    if (state == 1) {
        tableItem.HoldKeyArr[index][key] := "Joy"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }
    }
}

SendJoyAxisClick(key, holdTime, tableItem, index, keyType) {
    if (!CheckIfInstallVjoy()) {
        MsgBox("使用手柄功能前,请先安装Joy目录下的vJoy驱动!")
        return
    }

    if (keyType == 1) {
        SendJoyAxisKey(key, 1, tableItem, index)
        SetTimer(() => SendJoyAxisKey(key, 0, tableItem, index), -holdTime)
    }
    else {
        state := keyType == 2 ? 1 : 0
        SendJoyAxisKey(key, state, tableItem, index)
    }
}

SendJoyAxisKey(key, state, tableItem, index) {
    percent := 50
    if (state == 1) {
        percent := MyvJoy.JoyAxisMap.Get(key)
    }
    value := percent * 327.68
    axisIndex := Integer(SubStr(key, 8, StrLen(key) - 10))
    MyvJoy.SetAxisByIndex(value, axisIndex)

    if (state == 1) {
        tableItem.HoldKeyArr[index][key] := "JoyAxis"
    }
    else {
        if (tableItem.HoldKeyArr[index].Has(key)) {
            tableItem.HoldKeyArr[index].Delete(key)
        }

    }
}
