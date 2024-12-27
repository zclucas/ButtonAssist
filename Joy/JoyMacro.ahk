#Requires AutoHotkey v2.0

class JoyMacro {

    class MacroInfo{
        __New(action, processName) {
            this.actionFunc := action
            this.processName := processName
        }

        Action(){
            if (this.processName != ""){
                MouseGetPos &mouseX, &mouseY, &winId
                curProcessName := WinGetProcessName(winId)
                if (curProcessName != this.processName)
                    return
            }

            action := this.actionFunc
            action()
        }
    }

    __New() {
        this.MacroMap := Map()
        this.interval := 100
        this.controllerNum := 4
        this.joyBtnNum := 32
        this.joyFloat := 5
        this.axisMaxValue := 100
        
        this.timerAction := this.CheckMacro.Bind(this)
        this.joyAxises :=  Map("JoyXMin", 0, "JoyXMax", 100, "JoyYMin", 0, "JoyYMax", 100, "JoyZMin", 0, "JoyZMax", 100, "JoyRMin", 0, "JoyRMax", 100, "JoyUMin", 0, "JoyUMax", 100, "JoyVMin", 0, "JoyVMax", 100)
        this.joyPOVMap := Map("JoyPOV_0", 0, "JoyPOV_9000", 9000, "JoyPOV_18000", 18000, "JoyPOV_27000", 27000)

        this.xboxJoyBtnMap := Map("Joy1", 12, "Joy2", 13, "Joy3", 14, "Joy4", 15, "Joy5", 8, "Joy6", 9, "Joy7", 5, "Joy8", 4, "Joy9", 6, "Joy10", 7,
    "JoyPOV_0", 0, "JoyPOV_18000", 1, "JoyPOV_27000", 2, "JoyPOV_9000", 3)
        this.xboxJosAxisMap := Map("JoyXMin", -32768, "JoyXMax", 32767, "JoyYMin", -32768, "JoyYMax", 32767, "JoyZMin", 255, "JoyZMax", 255, "JoyRMin", -32768, "JoyRMax", 32767, "JoyUMin", -32768, "JoyUMax", 32767, "JoyVMin", -32768, "JoyVMax", 32767)
        
    }

    __Delete() {
        SetTimer this.timerAction, 0 
    }

    AddMacro(key, action, processName){
        macro := JoyMacro.MacroInfo(action, processName)
        this.MacroMap.Set(key, macro)
        this.Enable()
    }

    Enable(){
        if (this.MacroMap.Count == 0)
            return

        SetTimer this.timerAction, 0 
        SetTimer this.timerAction, this.interval
    }


    CheckMacro(){
        for key, macro in this.MacroMap{
            isJoyAxis := this.joyAxises.Has(key)
            isJoyPOV := this.joyPOVMap.Has(key)
            isJoyBtn := !isJoyAxis && !isJoyPOV

            if (isJoyBtn){
                this.CheckBtnMacro(key)
            }
            else if (isJoyPOV){
                this.CheckPOVMacro(key)
            }
            else{
                this.CheckAxisMacro(key)
            }
        }
    }

    CheckBtnMacro(joyBtnSymbol){
        loop this.controllerNum{
            if (GetKeyState(A_Index joyBtnSymbol)){
                this.MacroMap.Get("Joy" A_Index).Action()
                return
            }
        }

        this.CheckXboxBtnOrPOVMacro(joyBtnSymbol)
    }

    CheckPOVMacro(joyPOVSymbol){
        loop this.controllerNum{
            state := GetKeyState(A_Index joyPOVSymbol)
            value := this.joyPOVMap.Get(joyPOVSymbol)
            if (state == value){
                this.MacroMap.Get(joyPOVSymbol).Action()
                return
            }
        }

        this.CheckXboxBtnOrPOVMacro(joyPOVSymbol)
    }

    CheckAxisMacro(joyAxisSymbol){
        loop this.controllerNum{
            joyAxisName := SubStr(joyAxisSymbol, 1, 4)
            state := GetKeyState(A_Index joyAxisName)
            valueSection := this.GetAxisTriggerSection(joyAxisSymbol, false)
            if (IsNumber(state) && state >= valueSection[0] && state <= valueSection[1]){
                this.MacroMap.Get(joyAxisSymbol).Action()
                return
            }
        }

        this.CheckXboxAxisMacro(joyAxisSymbol)
    }

    CheckXboxBtnOrPOVMacro(joySymbol){
        isXboxHasBtn := this.xboxJoyBtnMap.Has(joySymbol)
        state := this.XInputState(0)
        if (isXboxHasBtn && state != 0){
            bitSymbol := this.xboxJoyBtnMap.Get(joySymbol)
            isPressed := (state.wButtons >> bitSymbol) & 1
            if (isPressed){
                this.MacroMap.Get(joySymbol).Action()
            }
        }
    }

    CheckXboxAxisMacro(joyAxisSymbol){
        valueSection := this.GetAxisTriggerSection(joyAxisSymbol, true)
        value := this.GetXboxAxisValue(joyAxisSymbol)
        if (value == 0)
            return
        
        if (value >= valueSection[0] && value <= valueSection[1]){
            this.MacroMap.Get(joyAxisSymbol).Action()
        }
    }

    ;数据获取函数
    GetAxisTriggerSection(axisKey, isXbox){
        value := this.joyAxises.Get(axisKey)
        floatValue := this.axisMaxValue * (this.joyFloat / 100)
        if (isXbox){
            value := this.xboxJosAxisMap.Get(axisKey)
            floatValue := Abs(value) * (this.joyFloat / 100)
        }
        if (value <= 0){
            return [value, value + floatValue]
        }
        else{
            return [value - floatValue, value]
        }
    }

    GetXboxAxisValue(joyAxisSymbol){
        joyAxisName := SubStr(joyAxisSymbol, 1, 4)
        State := this.XInputState(0)
        if (State == 0) 
            return 0 

        if (joyAxisSymbol == "JoyZMin"){
            return State.bRightTrigger
        }
        else if (joyAxisSymbol == "JoyZMax"){
            return State.bLeftTrigger
        }


        if (joyAxisName == "JoyX"){
            return State.sThumbLX
        }
        else if (joyAxisName == "JoyY"){
            return State.sThumbLY
        }
        else if (joyAxisName == "JoyR"){
            return State.sThumbRY
        }
        else if (joyAxisName == "JoyU"){
            return State.sThumbRX
        }
        else if (joyAxisName == "JoyV"){
            return State.sThumbRY   ;可能是sThumbRX
        }
       
        return 0
    }

    ;XInput API
    XInputState(UserIndex) {
        xiState := Buffer(16)
        if err := DllCall("XInput1_4\XInputGetState", "uint", UserIndex, "ptr", xiState) {
            if err = 1167 ; ERROR_DEVICE_NOT_CONNECTED
                return 0
            throw OSError(err, -1)
        }
        return {
            dwPacketNumber: NumGet(xiState,  0, "UInt"),
            wButtons:       NumGet(xiState,  4, "UShort"),
            bLeftTrigger:   NumGet(xiState,  6, "UChar"),
            bRightTrigger:  NumGet(xiState,  7, "UChar"),
            sThumbLX:       NumGet(xiState,  8, "Short"),
            sThumbLY:       NumGet(xiState, 10, "Short"),
            sThumbRX:       NumGet(xiState, 12, "Short"),
            sThumbRY:       NumGet(xiState, 14, "Short"),
        }
    }

}