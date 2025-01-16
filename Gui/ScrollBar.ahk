/*
; This class is based on research of "winuser.h" and some posts from the autohotkey forums, particularly the post located at:
; https://www.autohotkey.com/board/topic/26033-scrollable-gui-proof-of-concept/#entry168174
; The class provides functionality to create a scrollable GUI with the use of a scrollbar.

; Example:

M := Gui('+Resize')
Loop 15 {
    M.Add("Button", "x5 y" 10 + ((A_Index - 1) * 100) " w800 h80", A_Index)
}
SB := ScrollBar(M, 120, 200)
M.Show('w500 h200')
M.OnEvent "Close", (*) => ExitApp()
M.OnEvent "Escape", (*) => ExitApp()

#HotIf WinActive(M.Hwnd)
    WheelUp::
    WheelDown::
    +WheelUp::
    +WheelDown:: {
        SB.ScrollMsg(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, M.Hwnd)
        return
    }
#HotIf
*/

#Include SCROLLINFO.ahk
A_MaxHotkeysPerInterval := 9999

class ScrollBar {
    ; Notification codes for horizontal and vertical scroll
    WM_HSCROLL => 0x114
    WM_VSCROLL => 0x115

    ; type of scroll bar (nBar)
    SB_HORZ => 0
    SB_VERT => 1
    SB_BOTH => 3

    ; Scroll bar parameters to set or retrieve (fMask)
    SIF_RANGE => 1
    SIF_PAGE => 2
    SIF_POS => 4
    SIF_TRACKPOS => 16
    SIF_ALL => this.SIF_RANGE | this.SIF_PAGE | this.SIF_POS | this.SIF_TRACKPOS

    ; Scroll Bar Commands
    ; The user pressed the LEFT ARROW (VK_LEFT) key or clicked the left arrow button on a horizontal scroll bar.
    SB_LINELEFT => 0
    ; The user pressed the UP ARROW (VK_UP) key or clicked the up arrow button on a vertical scroll bar.
    SB_LINEUP => 0
    ; The user pressed the RIGHT ARROW (VK_RIGHT) key or clicked the right arrow button on a horizontal scroll bar.
    SB_LINERIGHT => 1
    ; The user pressed the DOWN ARROW (VK_DOWN) key or clicked the down arrow button on a vertical scroll bar.
    SB_LINEDOWN => 1
    ; The user clicked the channel above the slider on a vertical scroll bar or to the left of the slider on a horizontal scroll bar (VK_PRIOR).
    SB_PAGELEFT => 2
    SB_PAGEUP => 2
    ; The user clicked the channel below the slider on a vertical scroll bar or to the right of the slider on a horizontal scroll bar (VK_NEXT).
    SB_PAGERIGHT => 3
    SB_PAGEDOWN => 3
    ; The scrollbar received WM_LBUTTONUP following a SB_THUMBTRACK notification code.
    SB_THUMBPOSITION => 4
    ; The user dragged the slider.
    SB_THUMBTRACK => 5
    ; The user pressed the HOME key (VK_HOME) or clicked the top arrow button on a vertical scroll bar or left arrow button on a horizontal scroll bar.
    SB_LEFT => 6
    SB_TOP => 6
    ; The user pressed the END key (VK_END) or clicked the bottom arrow button on a vertical scroll bar or right arrow button on a horizontal scroll bar.
    SB_RIGHT => 7
    SB_BOTTOM => 7
    ; The scrollbar received WM_KEYUP, meaning that the user released a key that sent a relevant virtual key code.
    SB_ENDSCROLL => 8

    ; Constructor for the ScrollBar class
    __New(guiObj, width, height) {
        ; Check if the first parameter is a Gui object
        if (guiObj is Gui) {
            ; Set the guiObj property to the first parameter
            this.guiObj := guiObj
            ; Show both scroll bars
            this.ShowScrollBar(this.SB_BOTH, true)

            ; Create a buffer for the rectangle
            this.Rect := Buffer(16)

            this.FixedControls := []

            ; Bind the ScrollMsg method to this object and set it as the message handler for WM_HSCROLL and WM_VSCROLL messages
            this.ScrollMsgBind := ObjBindMethod(this, 'ScrollMsg')
            OnMessage(this.WM_HSCROLL, this.ScrollMsgBind)
            OnMessage(this.WM_VSCROLL, this.ScrollMsgBind)

            ; Do update of scroll bars when I resize the window
            this.guiObj.OnEvent('Size', (*) => this.UpdateScrollBars())

            ; Create a new SCROLLINFO object
            this.ScrollInf := SCROLLINFO()

            ; Gets left-most, right-most, top-most, bottom-most control positions
            this.GetEdges(&Left, &Right, &Top, &Bottom)

            ; Calculate the scroll height and width
            ScrollHeight := Bottom - Top
            ScrollWidth := Right - Left

            if (IsNumber(width) and IsNumber(height) and width > 0 and height > 0) {
                ; Set the maximum scroll position and page size for the vertical scroll bar
                this.ScrollInf.nMax := ScrollHeight
                this.ScrollInf.nPage := height

                this.ScrollInf.fMask := this.SIF_RANGE | this.SIF_PAGE

                ; Set the scroll info for the vertical scroll bar
                this.SetScrollInfo(this.SB_VERT, true)

                ; Set the maximum scroll position and page size for the horizontal scroll bar
                this.ScrollInf.nMax := ScrollWidth
                this.ScrollInf.nPage := width

                ; Set the scroll info for the horizontal scroll bar
                this.SetScrollInfo(this.SB_HORZ, true)

                ; Set the mask to retrieve all scroll info
                this.ScrollInf.fMask := this.SIF_ALL
            } else throw Error('Width and height must be valid numbers') ; Throw an error if width or height are not valid numbers
        } else throw Error('Parameter is not a Gui object') ; Throw an error if the first parameter is not a Gui object
    }

    ; Updates the position of fixed controls while the user scrolls
    UpdateFixedControlsPosition() {
        ; Iterates over the list of fixed controls
        for control in this.FixedControls {
            ; Sets the new position of the control
            control.Move(control.startX, control.startY)
        }
    }

    ; Add fixed controls...
    AddFixedControls(controls) {
        ; Verifies if the parameter is an array
        if (!(controls is Array)) {
            throw Error('Parameter must be an array of controls')
        }

        ; Adds each control to the list of fixed controls
        for control in controls {
            ; Gets the coordinates of the control
            control.GetPos(&controlX, &controlY)
            control.startX := controlX
            control.startY := controlY
            ; Stores the control in the list of fixed controls
            this.FixedControls.Push(control)
        }
    }

    UpdateScrollBars() {
        ; Gets left-most, right-most, top-most, bottom-most control positions
        this.GetEdges(&Left, &Right, &Top, &Bottom)

        ; Calculate the scroll width and height
        ScrollWidth := (Right - Left) * 1.25
        ScrollHeight := (Bottom - Top) * 1.25

        ; Set the mask to update the range and page size of the scroll bar
        this.ScrollInf.fMask := this.SIF_RANGE | this.SIF_PAGE

        ; Update the maximum scroll position and page size for the vertical scroll bar
        this.ScrollInf.nMax := ScrollHeight
        this.ScrollInf.nPage := this.GetHeight()

        ; Set the scroll info for the vertical scroll bar
        this.SetScrollInfo(this.SB_VERT, true)

        ; Update the maximum scroll position and page size for the horizontal scroll bar
        this.ScrollInf.nMax := ScrollWidth
        this.ScrollInf.nPage := this.GetWidth()

        ; Set the scroll info for the horizontal scroll bar
        this.SetScrollInfo(this.SB_HORZ, true)

        /*
        The code below checks if the left or top position of the content is less than 0 and if
        the right or bottom position of the content is less than the width or height of the window. If
        both conditions are true for either axis, it calculates how much to scroll in that axis to bring
        the content back into view. It then calls the ScrollWindow function to scroll the content by that
        amount in both axes.
        */

        x := 0, y := 0

        if (Left < 0 && Right < this.GetWidth()) {
            x := Abs(Left) > this.GetWidth() - Right ? this.GetWidth() - Right : Abs(Left)
        }
        if (Top < 0 && Bottom < this.GetHeight()) {
            y := Abs(Top) > this.GetHeight() - Bottom ? this.GetHeight() - Bottom : Abs(Top)
        }
        if (x || y) {
            DllCall("ScrollWindow", "ptr", this.guiObj.Hwnd, "int", x, "int", y, "uint", 0, "uint", 0)
        }

        ; Set the mask to retrieve all scroll info
        this.ScrollInf.fMask := this.SIF_ALL
    }

    HiWord(wParam) {
        Return (wParam >> 16)
    }

    LoWord(wParam) {
        Return (wParam & 0xFFFF)
    }

    ; The ScrollMsg function is called when the window receives a WM_HSCROLL or WM_VSCROLL message.
    ; It calls the ScrollAction function to update the scroll bar position and then calls the ScrollWindow function to scroll the content.
    ScrollMsg(wParam, lParam, msg, hwnd) {
        switch msg {
            ; If the message is WM_HSCROLL, update the horizontal scroll bar
            case this.WM_HSCROLL:
                this.ScrollAction(this.SB_HORZ, wParam)
                this.ScrollWindow(this.oldPos - this.ScrollInf.nPos, 0)
                this.UpdateFixedControlsPosition()
                ; If the message is WM_VSCROLL, update the vertical scroll bar
            case this.WM_VSCROLL:
                this.ScrollAction(this.SB_VERT, wParam)
                this.ScrollWindow(0, this.oldPos - this.ScrollInf.nPos)
                this.UpdateFixedControlsPosition()
        }
    }

    ; The ScrollAction function updates the scroll bar position based on the scroll action specified in wParam.
    ; It first gets the current scroll info and position for the specified scroll bar and then calculates the new position based on the scroll action.
    ScrollAction(typeOfScrollBar, wParam) {
        ; Get current attributes of scroll bar
        this.GetScrollInfo(typeOfScrollBar)
        ; Store current position of scroll bar
        this.oldPos := this.ScrollInf.nPos

        ; Get current scroll range
        this.GetScrollRange(typeOfScrollBar, &minPos, &maxPos)

        ; Calculates max position of scroll bar's thumb (scroll box)
        maxThumbPos := this.ScrollInf.nMax - this.ScrollInf.nMin + 1 - this.ScrollInf.nPage

        ; Updates scroll bar position based on command received
        switch this.LoWord(wParam) {
            case this.SB_LINELEFT, this.SB_LINEUP:
                this.ScrollInf.nPos := max(this.ScrollInf.nPos - 30, minPos)
            case this.SB_PAGELEFT, this.SB_PAGEUP:
                this.ScrollInf.nPos := max(this.ScrollInf.nPos - this.ScrollInf.nPage, minPos)
            case this.SB_LINERIGHT, this.SB_LINEDOWN:
                this.ScrollInf.nPos := min(this.ScrollInf.nPos + 30, maxThumbPos)
            case this.SB_PAGERIGHT, this.SB_PAGEDOWN:
                this.ScrollInf.nPos := min(this.ScrollInf.nPos + this.ScrollInf.nPage, maxThumbPos)
            case this.SB_THUMBTRACK:
                this.ScrollInf.nPos := this.HiWord(wParam)
            default:
                return
        }

        this.SetScrollInfo(typeOfScrollBar, true)
    }

    GetClientRect() {
        return DllCall("GetClientRect", "uint", this.guiObj.Hwnd, "ptr", this.Rect.Ptr)
    }

    ; Gets current visible height
    GetHeight() {
        this.GetClientRect()
        return NumGet(this.Rect, 12, "int")
    }

    ; Gets current visible height
    GetWidth() {
        this.GetClientRect()
        return NumGet(this.Rect, 8, "int")
    }

    ; Gets left-most, right-most, top-most, bottom-most control positions
    GetEdges(&Left?, &Right?, &Top?, &Bottom?) {
        ; Calculate scrolling area.
        Left := Top := 9999
        Right := Bottom := 0
        ; Get a list of all controls in guiObj
        ControlList := WinGetControls(this.guiObj.Hwnd)
        ; Loops through all controls and finds the farthest sides
        For i in ControlList {

            if (SubStr(i, 1, 1) == "#")
                continue

            ; Gets all positions of current control
            this.guiObj[i].GetPos(&cX, &cY, &cW, &cH)
            ; ControlGetPos(&cX, &cY, &cW, &cH, i)
            ; If it's position is farther than the last one, saves it
            if (cX < Left) {
                Left := cX
            }
            if (cY < Top) {
                Top := cY
            }
            if (cX + cW > Right) {
                Right := cX + cW
            }
            if (cY + cH > Bottom) {
                Bottom := cY + cH
            }
        }

        ; Gives a little more space for the edges
        Left -= 8
        Top -= 8
        Right += 8
        Bottom += 8
    }

    ; The ShowScrollBar function shows or hides the specified scroll bar.
    ; f the function succeeds, the return value is nonzero.
    ShowScrollBar(typeOfScrollBar, bool) {
        return DllCall("ShowScrollBar", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "int", bool)
    }

    ; The GetScrollInfo function retrieves the parameters of a scroll bar, including the minimum and maximum scrolling positions,
    ; the page size, and the position of the scroll box (thumb).
    ; Before calling GetScrollInfo, set the cbSize member to sizeof(SCROLLINFO), and set the fMask member to specify the scroll bar parameters to retrieve.
    ; If the function retrieved any values, the return value is nonzero.
    GetScrollInfo(typeOfScrollBar) {
        return DllCall("GetScrollInfo", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", this.ScrollInf.Ptr)
    }

    ; The SetScrollInfo function sets the parameters of a scroll bar, including the minimum and maximum scrolling positions,
    ; the page size, and the position of the scroll box (thumb). The function also redraws the scroll bar, if requested.
    ; The return value is the current position of the scroll box.
    SetScrollInfo(typeOfScrollBar, redraw) {
        return DllCall("SetScrollInfo", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", this.ScrollInf.Ptr, "int", redraw)
    }

    ; The GetScrollRange function retrieves the current minimum and maximum scroll box (thumb) positions for the specified scroll bar.
    ; If the function succeeds, the return value is nonzero.
    GetScrollRange(typeOfScrollBar, &minPos, &maxPos) {
        minnn := Buffer(4)
        maxxx := Buffer(4)
        r := DllCall("GetScrollRange", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", minnn.Ptr, "ptr", maxxx.Ptr)
        minPos := NumGet(minnn, "int"), maxPos := NumGet(maxxx, "int")
        return r
    }

    ; The ScrollWindow function scrolls the contents of the specified window's client area.
    ; If the function succeeds, the return value is nonzero.
    ScrollWindow(xamount, yamount) {
        return DllCall("ScrollWindow", "ptr", this.guiObj.Hwnd, "int", xamount, "int", yamount, "ptr", 0, "ptr", 0, "int")
    }
}