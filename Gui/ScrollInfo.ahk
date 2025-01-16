/* This class defines the structure below(SCROLLINFO) on Winuser.h:

typedef struct tagSCROLLINFO {
  UINT cbSize;
  UINT fMask;
  int  nMin;
  int  nMax;
  UINT nPage;
  int  nPos;
  int  nTrackPos;
} SCROLLINFO, *LPSCROLLINFO */
class ScrollInfo {
    __New() {
        ; Reserves space in computer memory for scrollInf structure with 28 bytes
        this.scrollInf := Buffer(28, 0)
        ; Set cbSize
        NumPut("uint", this.scrollInf.size, this.scrollInf)
    }

    Ptr => this.scrollInf.Ptr

    ; cbSize: Specifies the size, in bytes, of this structure. The caller must set this to sizeof(SCROLLINFO).
    cbSize => NumGet(this.scrollInf, "uint")

    /*  Specifies the scroll bar parameters to set or retrieve. This member can be a combination of the following values:

    SIF_ALL                     Combination of SIF_PAGE, SIF_POS, SIF_RANGE, and SIF_TRACKPOS.
    SIF_DISABLENOSCROLL         If the scroll bar's new parameters make the scroll bar unnecessary, disable the scroll bar instead of removing it.
    SIF_PAGE                    The nPage member contains the page size for a proportional scroll bar.
    SIF_POS                     The nPos member contains the scroll box position, which is not updated while the user drags the scroll box.
    SIF_RANGE                   The nMin and nMax members contain the minimum and maximum values for the scrolling range.
    SIF_TRACKPOS                The nTrackPos member contains the current position of the scroll box while the user is dragging it.                 */
    fMask {
        get => NumGet(this.scrollInf, 4, "uint")
        set => NumPut("uint", value, this.scrollInf, 4)
    }

    ; Specifies the minimum scrolling position.
    nMin {
        get => NumGet(this.scrollInf, 8, "int")
        set => NumPut("int", value, this.scrollInf, 8)
    }

    ; Specifies the maximum scrolling position.
    nMax {
        get => NumGet(this.scrollInf, 12, "int")
        set => NumPut("int", value, this.scrollInf, 12)
    }

    ; Specifies the page size, in device units. A scroll bar uses this value to determine the appropriate size of the proportional scroll box.
    nPage {
        get => NumGet(this.scrollInf, 16, "uint")
        set => NumPut("uint", value, this.scrollInf, 16)
    }

    ; Specifies the position of the scroll box.
    nPos {
        get => NumGet(this.scrollInf, 20, "int")
        set => NumPut("ptr", value, this.scrollInf, 20)
    }

    ; Specifies the immediate position of a scroll box that the user is dragging. An application can retrieve this value while processing the SB_THUMBTRACK request code. 
    ; An application cannot set the immediate scroll position; the SetScrollInfo function ignores this member.
    nTrackPos {
        get => NumGet(this.scrollInf, 24, "int")
        set => NumPut("ptr", value, this.scrollInf, 24)
    }
}