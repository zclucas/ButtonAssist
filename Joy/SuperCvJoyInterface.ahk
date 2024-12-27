#Requires AutoHotkey v2.0

Class SuperCvJoyInterface {
	DebugMode := 0
	SingleStickMode := 1 	; If set to 1, helper classes will automatically relinquish existing vjoy device on attempting to acquire one not connected.
	ResetOnAcquire := 1 	; Resets Devices to vjoy norms on Acquire via helper classes.
	ResetOnRelinquish := 1 	; Resets Devices to vjoy norms on Relinquish via helper classes.
	LibraryLoaded := 0 		; Did the Library Load OK when the class Instantiated?
	LoadLibraryLog := ""	; If Not, holds log of why it failed.
	hModule := 0 			; handle to DLL
	Devices := []			; Array for Helper Classes of Devices

	VJD_MAXDEV := 16		; Max Number of Devices vJoy Supports
 
	; ported from VjdStat in vjoyinterface.h
	VJD_STAT_OWN := 0   ; The  vJoy Device is owned by this application.
	VJD_STAT_FREE := 1  ; The  vJoy Device is NOT owned by any application (including this one).
	VJD_STAT_BUSY := 2  ; The  vJoy Device is owned by another application. It cannot be acquired by this application.
	VJD_STAT_MISS := 3  ; The  vJoy Device is missing. It either does not exist or the driver is down.
	VJD_STAT_UNKN := 4  ; Unknown

	; HID Descriptor definitions(ported from public.h)
	HID_USAGE_X := 0x30
	HID_USAGE_Y := 0x31
	HID_USAGE_Z := 0x32
	HID_USAGE_RX:= 0x33
	HID_USAGE_RY:= 0x34
	HID_USAGE_RZ:= 0x35
	HID_USAGE_SL0:= 0x36
	HID_USAGE_SL1:= 0x37

	; Handy lookups to axis HID_USAGE values
	AxisIndex := [0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37]	; Index (Axis Number) to HID Descriptor
	AxisAssoc := {x:0x30, y:0x31, z:0x32, rx:0x33, ry:0x34, rz: 0x35, sl1:0x36, sl2:0x37} ; Name (eg "x", "y", "z", "sl1") to HID Descriptor
	AxisNames := ["X","Y","Z","RX","RY","RZ","SL0","SL1"]

	Class CvJoyDevice {
		IsOwned := 0
		JoyAxisMap := Map("JoyAxis1Min", 0, "JoyAxis1Max", 100, "JoyAxis2Min", 0, "JoyAxis2Max", 100, "JoyAxis3Min", 0, "JoyAxis3Max", 100, "JoyAxis4Min", 0, "JoyAxis4Max", 100)
	
		GetStatus(){
			return this.Interface.GetVJDStatus(this.DeviceID)
		}
	
		; Converts Status to human readable form
		GetStatusName(){
			DeviceStatus := this.GetStatus()
			if (DeviceStatus = this.Interface.VJD_STAT_OWN) {
				return "OWN"
			} else if (DeviceStatus = this.Interface.VJD_STAT_FREE) {
				return "FREE"
			} else if (DeviceStatus = this.Interface.VJD_STAT_BUSY) {
				return "BUSY"
			} else if (DeviceStatus = this.Interface.VJD_STAT_MISS) {
				return "MISS"
			} else {
				return "???"
			}
		}
	
		; Acquire the device
		Acquire(){
			if (this.IsOwned){
				return 1
			}
			if (this.Interface.SingleStickMode){
				Loop this.Interface.Devices.Length {
					if (A_Index == this.DeviceID){
						Continue
					}
					if (this.Interface.Devices[A_Index].IsOwned){
						this.Interface.Devices[A_Index].Relinquish()
						break
					}
				}
			}
			ret := this.Interface.AcquireVJD(this.DeviceID)
			if (ret && this.Interface.ResetOnAcquire){
				; Reset the Device so it centers
				this.Interface.ResetVJD(this.DeviceID)
			} else {
				if (this.Interface.DebugMode) {
					OutputDebug("Error in " A_ThisFunc "`nDeviceID = " this.DeviceID ", ErrorLevel: " 1 ", Device Status: " this.GetStatusName())
				}
			}
			return ret
		}
	
		; Relinquish the device, resetting it if Owned
		Relinquish(){
			if (this.IsOwned && this.Interface.ResetOnRelinquish){
				this.Interface.ResetVJD(this.DeviceID)
			}
			return this.Interface.RelinquishVJD(this.DeviceID)
		}
	
		Reset(){
			this.Interface.ResetVJD(this.DeviceID)
		}
	
		ResetButtons(){
			this.Interface.ResetButtons(this.DeviceID)
		}
	
		ResetPovs(){
			this.Interface.ResetPovs(this.DeviceID)
		}
	
		; Does the device exist or not?
		IsEnabled(){
			state := this.GetStatus()
			return state != this.Interface.VJD_STAT_MISS && state != this.Interface.VJD_STAT_UNKN
		}
	
		; Is it possible to take control of the device?
		IsAvailable(){
			state := this.GetStatus()
			return state == this.Interface.VJD_STAT_FREE || state == this.Interface.VJD_STAT_OWN
		}
	
		; Set Axis by Index number.
		; eg x = 1, y = 2, z = 3, rx = 4
		SetAxisByIndex(axis_val, index){
			if (!this.Acquire()){
				return 0
			}
			return this.Interface.SetAxis(axis_val, this.DeviceID, this.Interface.AxisIndex[index])
		}
	
		; Set Axis by Name
		; eg "x", "y", "z", "rx"
		SetAxisByName(axis_val, name){
			if (!this.Acquire()){
				return 0
			}
			return this.Interface.SetAxis(axis_val, this.DeviceID, this.Interface.AxisAssoc[name])
		}
	
		SetBtn(btn_val, btn){
			if (!this.Acquire()){
				return 0
			}
			return this.Interface.SetBtn(btn_val, this.DeviceID, btn)
		}
	
		SetDiscPov(pov_val, pov){
			if (!this.Acquire()){
				return 0
			}
			return this.Interface.SetDiscPov(pov_val, this.DeviceID, pov)
		}
	
		SetContPov(pov_val, pov){
			if (!this.Acquire()){
				return 0
			}
			return this.Interface.SetContPov(pov_val, this.DeviceID, pov)
		}
	
		; Constructor
		__New(id, parent){
			this.DeviceID := id
			this.Interface := parent
		}
	
		; Destructor
		__Delete(){
			this.Relinquish()
		}
	}
	

	; ===== Constructors / Destructors
	__New(){
		; Build Device array
		Loop this.VJD_MAXDEV {

            device := SuperCvJoyInterface.CvJoyDevice(A_Index, this)
            if (this.Devices.Length < A_Index){
                this.Devices.Push(device)
            }
            else{
                this.Devices[A_Index] := device
            }
		}

		; Try and Load the DLL
		this.LoadLibrary()
		return this
	}

	__Delete(){
		; Relinquish Devices
		Loop this.VJD_MAXDEV {
			this.Devices[A_Index].Relinquish()
		}

		; Unload DLL
		if (this.hModule){
			DllCall("FreeLibrary", "Ptr", this.hModule)
		}
	}

	GetMyvJoy(){
		for index, value in this.Devices{
			state := value.GetStatus()
			if (state == this.VJD_STAT_MISS)
				continue
			
			return value
		}
	}

	; ===== Helper Functions
	; Converts vJoy range (0->32768 to a range like an AHK input 0->100)
	PercentTovJoy(percent){
		return percent * 327.68
	}

	vJoyToPercent(vJoy){
		return vJoy / 327.68
	}

	; ===== DLL loading / vJoy Install detection

	; Load the vJoyInterface DLL.
	LoadLibrary() {
		;Global hModule

		if (this.LibraryLoaded) {
			this.LoadLibraryLog .= "Library already loaded. Aborting...`n"
			return 1
		}

		this.LoadLibraryLog := ""

		; Check if vJoy is installed. Even with the DLL, if vJoy is not installed it will not work...
		; Find vJoy install folder by looking for registry key.
		if (A_Is64bitOS && A_PtrSize != 8){
			SetRegView(64)
		}
		vJoyFolder := RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1", "InstallLocation")

		if (!vJoyFolder){
			this.LoadLibraryLog .= "ERROR: Could not find the vJoy Registry Key.`n`nvJoy does not appear to be installed.`nPlease ensure you have installed vJoy from`n`nhttp://vjoystick.sourceforge.net."
			return 0
		}
		
		; Try to find location of correct DLL.
		; vJoy versions prior to 2.0.4 241214 lack these registry keys - if key not found, advise update.
		if (A_PtrSize == 8){
			; 64-Bit AHK
			DllKey := "DllX64Location"
		} else {
			; 32-Bit AHK
			DllKey := "DllX86Location"
		}
		DllFolder := RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1", DllKey)

		if (!DllFolder){
			; Could not find registry entry. Advise vJoy update.
			this.LoadLibraryLog .= "A vJoy install was found in " vJoyFolder ", but it appears to be an old version.`nPlease update vJoy to the latest version from `n`nhttp://vjoystick.sourceforge.net."
			return 0
		}

		DllFolder .= "\"

		; All good so far, try and load the DLL
		DllFile := "vJoyInterface.dll"
		this.LoadLibraryLog := "vJoy Install Detected. Trying to load " DllFile "...`n"
		CheckLocations := [DllFolder DllFile]

		hModule := 0
		Loop CheckLocations.Length != 0 ? CheckLocations.Length : "" {
			this.LoadLibraryLog .= "Checking " CheckLocations[A_Index] "... "
			if (FileExist(CheckLocations[A_Index])){
				this.LoadLibraryLog .= "FOUND.`nTrying to load.. "
				hModule := DllCall("LoadLibrary", "Str", CheckLocations[A_Index])
				if (hModule){
					this.hModule := hModule
					this.LoadLibraryLog .= "OK.`n"
					this.LoadLibraryLog .= "Checking driver enabled... "
					if (this.vJoyEnabled()){
						this.LibraryLoaded := 1
						this.LoadLibraryLog .= "OK.`n"
						this.LoadLibraryLog .= "Loaded vJoy DLL version " this.GetvJoyVersion() "`n"
						if (this.DebugMode){
							OutputDebug(this.LoadLibraryLog)
						}
						return 1
					} else {
						this.LoadLibraryLog .= "FAILED.`n"
					}
				} else {
					this.LoadLibraryLog .= "FAILED.`n"
				}
			} else {
				this.LoadLibraryLog .= "NOT FOUND.`n"
			}
		}
		this.LoadLibraryLog .= "`nFailed to load valid  " DllFile "`n"
		this.LibraryLoaded := 0
		return 0
	}

	; ===== vJoy Interface DLL call wrappers
	; In the order detailed in the vJoy SDK's Interface Function Reference
	; http://sourceforge.net/projects/vjoystick/files/

	; === General driver data
	vJoyEnabled(){
		return DllCall("vJoyInterface\vJoyEnabled")
	}

	GetvJoyVersion(){
		return DllCall("vJoyInterface\GetvJoyVersion")
	}

	GetvJoyProductString(){
		return DllCall("vJoyInterface\GetvJoyProductString")
	}

	GetvJoyManufacturerString(){
		return DllCall("vJoyInterface\GetvJoyManufacturerString")
	}

	GetvJoySerialNumberString(){
		return DllCall("vJoyInterface\GetvJoySerialNumberString")
	}

	; === Write access to vJoy Device
	GetVJDStatus(rID){
		return DllCall("vJoyInterface\GetVJDStatus", "UInt", rID)
	}

	; Handle setting IsOwned property outside helper class, to allow mixing
	AcquireVJD(rID){
		this.Devices[rID].IsOwned := DllCall("vJoyInterface\AcquireVJD", "UInt", rID)
		return this.Devices[rID].IsOwned
	}

	RelinquishVJD(rID){
		DllCall("vJoyInterface\RelinquishVJD", "UInt", rID)
		this.Devices[rID].IsOwned := 0
		return this.Devices[rID].IsOwned
	}

	; Not sure if this one is good. What is a "PVOID"?
	UpdateVJD(rID, pData){
		return DllCall("vJoyInterface\UpdateVJD", "UInt", rID, "PVOID", pData)
	}

	; === vJoy Device properties

	GetVJDButtonNumber(rID){
		return DllCall("vJoyInterface\GetVJDButtonNumber", "UInt", rID)
	}

	GetVJDDiscPovNumber(rID){
		return DllCall("vJoyInterface\GetVJDDiscPovNumber", "UInt", rID)
	}

	GetVJDContPovNumber(rID){
		return DllCall("vJoyInterface\GetVJDContPovNumber", "UInt", rID)
	}

	GetVJDAxisExist(rID, Axis){
		return DllCall("vJoyInterface\GetVJDAxisExist", "UInt", rID, "Uint", Axis)
	}

	ResetVJD(rID){
		return DllCall("vJoyInterface\ResetVJD", "UInt", rID)
	}

	ResetAll(){
		return DllCall("vJoyInterface\ResetAll")
	}

	ResetButtons(rID){
		return DllCall("vJoyInterface\ResetButtons", "UInt", rID)
	}

	ResetPovs(rID){
		return DllCall("vJoyInterface\ResetPovs", "UInt", rID)
	}

	SetAxis(Value, rID, Axis){
		return DllCall("vJoyInterface\SetAxis", "Int", Value, "UInt", rID, "UInt", Axis)
	}

	SetBtn(Value, rID, nBtn){
		return DllCall("vJoyInterface\SetBtn", "Int", Value, "UInt", rID, "UInt", nBtn)
	}

	SetDiscPov(Value, rID, nPov){
		return DllCall("vJoyInterface\SetDiscPov", "Int", Value, "UInt", rID, "UChar", nPov)
	}

	SetContPov(Value, rID, nPOV){
		return DllCall("vJoyInterface\SetContPov", "Int", Value, "UInt", rID, "UChar", nPov)
	}

}