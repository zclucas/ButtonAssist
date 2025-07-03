#Requires AutoHotkey v2.0
RecordControllerNum := 4
RecordJoyHoldMap := Map()
RecordAllJoyMap := Map("Joy1", 1, "Joy2", 1, "Joy3", 1, "Joy4", 1, "Joy5", 1, "Joy6", 1, "Joy7", 1, "Joy8", 1,
    "Joy9", 1, "Joy10", 1, "Joy11", 1, "Joy12", 1, "Joy13", 1, "Joy14", 1, "Joy15", 1, "Joy16", 1,
    "Joy17", 1, "Joy18", 1, "Joy19", 1, "Joy20", 1, "Joy21", 1, "Joy22", 1, "Joy23", 1, "Joy24", 1,
    "Joy25", 1, "Joy26", 1, "Joy27", 1, "Joy28", 1, "Joy29", 1, "Joy30", 1, "Joy31", 1, "Joy32", 1,
    "JoyXMin", 0, "JoyXMax", 100, "JoyYMin", 0, "JoyYMax", 100, "JoyZMin", 0, "JoyZMax", 100,
    "JoyRMin", 0, "JoyRMax", 100, "JoyUMin", 0, "JoyUMax", 100, "JoyVMin", 0, "JoyVMax", 100,
    "JoyPOV_0", 0, "JoyPOV_9000", 9000, "JoyPOV_18000", 18000, "JoyPOV_27000", 27000)

RecordJoyAxises := Map("JoyXMin", 0, "JoyXMax", 100, "JoyYMin", 0, "JoyYMax", 100, "JoyZMin", 0, "JoyZMax", 100,
    "JoyRMin", 0, "JoyRMax", 100, "JoyUMin", 0, "JoyUMax", 100, "JoyVMin", 0, "JoyVMax", 100)
RecordJoyPOVMap := Map("JoyPOV_0", 0, "JoyPOV_9000", 9000, "JoyPOV_18000", 18000, "JoyPOV_27000", 27000)

XboxJoyAndPOVMap := Map("Joy1", 12, "Joy2", 13, "Joy3", 14, "Joy4", 15, "Joy5", 8, "Joy6", 9, "Joy7", 5,
    "Joy8", 4, "Joy9", 6, "Joy10", 7,
    "JoyPOV_0", 0, "JoyPOV_18000", 1, "JoyPOV_27000", 2, "JoyPOV_9000", 3)

XboxJosAxisMap := Map("JoyXMin", -32768, "JoyXMax", 32767, "JoyYMin", -32768, "JoyYMax", 32767, "JoyZMin",
    255, "JoyZMax", 255, "JoyRMin", -32768, "JoyRMax", 32767, "JoyUMin", -32768, "JoyUMax", 32767, "JoyVMin", -
    32768, "JoyVMax", 32767)

RecordJoy() {
    for key, value in RecordAllJoyMap {
        isJoyAxis := RecordJoyAxises.Has(key)
        isJoyPOV := RecordJoyPOVMap.Has(key)
        isJoyBtn := !isJoyAxis && !isJoyPOV

        if (isJoyBtn) {
            RecordJoyCheckBtnDown(key)
        }
        else if (isJoyPOV) {
            ; this.CheckPOVMacro(key)
        }
        else {
            ; this.CheckAxisMacro(key)
        }
    }
}

RecordJoyCheckBtnDown(key) {
    loop RecordControllerNum {
        if (GetKeyState(A_Index key)) {
            OnRecordJoyDown(key)
            return
        }
    }

    ; this.CheckXboxBtnOrPOVMacro(key)
}

OnRecordJoyDown(joyName) {

}

OnRecordJoyUp(joyName) {

}
