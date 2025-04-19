class WinClip_base
{
    Static __Call( aTarget, aParams ) { ; 2nd param already is an array, so omit "*"
        if ObjHasOwnProp( WinClip_base, aTarget )
            return this.%aTarget%(this, aParams*) ; updated again for AHKv2
            ; return WinClip_base[ aTarget ].Call( this, aParams* ) ;updated for AHKv2 compatibility
            ;return WinClip_base[ aTarget ].( this, aParams* )
        throw Error( "Unknown function '" aTarget "' requested from object '" this.__Class "'", -1 )
    }
    
    Static Err( msg ) {
        throw Error( this.__Class " : " msg ( (A_LastError != 0) ? "`n" this.ErrorFormat( A_LastError ) : "" ), -2 )
    }
    
    Static ErrorFormat( error_id ) {
        msg := Buffer(1000,0)
        if !len := DllCall("FormatMessageW"
                    ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200      ;dwflags
                    ,"Ptr",0            ;lpSource
                    ,"UInt",error_id    ;dwMessageId
                    ,"UInt",0           ;dwLanguageId
                    ,"Ptr",msg.ptr         ;lpBuffer
                    ,"UInt",500)            ;nSize
            return
        return  strget(msg,len)
    }
}

class WinClipAPI_base extends WinClip_base
{
    Static __Get( name, initialized ) { ; ??? initialized seemed like an undefined var, on next line
        if !ObjHasOwnProp( this, initialized* )
            this.Init()
        else
            throw Error( "Unknown field '" name "' requested from object '" this.__Class "'", -1 )
    }
}

class WinClipAPI extends WinClip_base
{
    static u := StrLen(Chr(0xFFFF)) ; IsUnicode
    static m := (this.u)?2:1        ; Unicode/Ansi str buffer multiplier
    
    Static memcopy( dest, src, size ) {
        return DllCall( "msvcrt\memcpy", "ptr", dest, "ptr", src, "uint", size )
    }
    Static GlobalSize( hObj ) {
        return DllCall( "GlobalSize", "Ptr", hObj )
    }
    Static GlobalLock( hMem ) {
        return DllCall( "GlobalLock", "Ptr", hMem )
    }
    Static GlobalUnlock( hMem ) {
        return DllCall( "GlobalUnlock", "Ptr", hMem )
    }
    Static GlobalAlloc( flags, size ) {
        return DllCall( "GlobalAlloc", "Uint", flags, "Uint", size )
    }
    Static OpenClipboard() {
        return DllCall( "OpenClipboard", "Ptr", 0 )
    }
    Static CloseClipboard() {
        return DllCall( "CloseClipboard" )
    }
    Static SetClipboardData( format, hMem ) {
        return DllCall( "SetClipboardData", "Uint", format, "Ptr", hMem )
    }
    Static GetClipboardData( format ) {
        return DllCall( "GetClipboardData", "Uint", format ) 
    }
    Static EmptyClipboard() {
        return DllCall( "EmptyClipboard" )
    }
    Static EnumClipboardFormats( format ) {
        return DllCall( "EnumClipboardFormats", "UInt", format )
    }
    Static CountClipboardFormats() {
        return DllCall( "CountClipboardFormats" )
    }
    Static GetClipboardFormatName( iFormat ) {
        bufName := Buffer( 255*( this.m ), 0 )
        DllCall( "GetClipboardFormatName", "Uint", iFormat, "UPtr", bufName.ptr, "Uint", bufName.size )
        return bufName
    }
    Static GetEnhMetaFileBits( hemf, &buf ) {
        if !( bufSize := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", 0, "Ptr", 0 ) )
            return 0
        buf := Buffer( bufSize, 0 )
        if !( bytesCopied := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", bufSize, "Ptr", buf.ptr ) )
            return 0
        return bytesCopied
    }
    Static SetEnhMetaFileBits( pBuf, bufSize ) {
        return DllCall( "SetEnhMetaFileBits", "Uint", bufSize, "Ptr", pBuf )
    }
    Static DeleteEnhMetaFile( hemf ) {
        return DllCall( "DeleteEnhMetaFile", "Ptr", hemf )
    }
    Static ErrorFormat(error_id) {
        msg := Buffer(1000,0)
        if !len := DllCall("FormatMessageW"
                    ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200      ;dwflags
                    ,"Ptr",0        ;lpSource
                    ,"UInt",error_id    ;dwMessageId
                    ,"UInt",0           ;dwLanguageId
                    ,"Ptr",msg.ptr         ;lpBuffer
                    ,"UInt",500)            ;nSize
            return
        return  strget(msg,len)
    }
    Static IsInteger( var ) {
        ; if (var+0 == var) && (Floor(var) == var) ;test for integer while remaining v1 and v2 compatible
            ; return True
        ; else 
            ; return False
        return IsInteger(var)
    }
    Static LoadDllFunction( file, function ) {
            if !hModule := DllCall( "GetModuleHandleW", "Wstr", file, "UPtr" )
                    hModule := DllCall( "LoadLibraryW", "Wstr", file, "UPtr" )
            
            ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
            return ret
    }
    Static SendMessage( hWnd, Msg, wParam, lParam ) {
         static SendMessageW

         If not SendMessageW
                SendMessageW := this.LoadDllFunction( "user32.dll", "SendMessageW" )

         ret := DllCall( SendMessageW, "UPtr", hWnd, "UInt", Msg, "UPtr", wParam, "UPtr", lParam )
         return ret
    }
    Static GetWindowThreadProcessId( hwnd ) {
        return DllCall( "GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0 )
    }
    Static WinGetFocus( hwnd ) {
        GUITHREADINFO_cbsize := 24 + A_PtrSize*6
        GuiThreadInfo := Buffer( GUITHREADINFO_cbsize, 0 )    ;GuiThreadInfoSize = 48
        NumPut("UInt", GUITHREADINFO_cbsize, GuiThreadInfo, 0)
        threadWnd := this.GetWindowThreadProcessId( hwnd )
        if not DllCall( "GetGUIThreadInfo", "uint", threadWnd, "UPtr", GuiThreadInfo.ptr )
                return 0
        return NumGet( GuiThreadInfo, 8+A_PtrSize,"UPtr")  ; Retrieve the hwndFocus field from the struct.
    }
    Static GetPixelInfo( &DIB ) {
        ;~ typedef struct tagBITMAPINFOHEADER {
        ;~ DWORD biSize;              0
        ;~ LONG  biWidth;             4
        ;~ LONG  biHeight;            8
        ;~ WORD  biPlanes;            12
        ;~ WORD  biBitCount;          14
        ;~ DWORD biCompression;       16
        ;~ DWORD biSizeImage;         20
        ;~ LONG  biXPelsPerMeter;     24
        ;~ LONG  biYPelsPerMeter;     28
        ;~ DWORD biClrUsed;           32
        ;~ DWORD biClrImportant;      36
        
        bmi := DIB.ptr  ;BITMAPINFOHEADER  pointer from DIB
        biSize := numget( bmi+0, 0, "UInt" )
        ;~ return bmi + biSize
        biSizeImage := numget( bmi+0, 20, "UInt" )
        biBitCount := numget( bmi+0, 14, "UShort" )
        if ( biSizeImage == 0 )
        {
            biWidth := numget( bmi+0, 4, "UInt" )
            biHeight := numget( bmi+0, 8, "UInt" )
            biSizeImage := (((( biWidth * biBitCount + 31 ) & ~31 ) >> 3 ) * biHeight )
            numput( "UInt", biSizeImage, bmi+0, 20 )
        }
        p := numget( bmi+0, 32, "UInt" )  ;biClrUsed
        if ( p == 0 && biBitCount <= 8 )
            p := 1 << biBitCount
        p := p * 4 + biSize + bmi
        return p
    }
    Static Gdip_Startup() {
        if !DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
                    DllCall( "LoadLibraryW", "Wstr", "gdiplus", "UPtr" )
        
        GdiplusStartupInput := Buffer( 3*A_PtrSize, 0), NumPut("UInt",1,GdiplusStartupInput ,0) ; GdiplusVersion = 1
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken:=0, "Ptr", GdiplusStartupInput.ptr, "Ptr", 0)
        return pToken
    }
    Static Gdip_Shutdown(pToken) {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        if hModule := DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
            DllCall("FreeLibrary", "Ptr", hModule)
        return 0
    }
    Static StrSplit(str,delim,omit := "") {
        if (strlen(delim) > 1)
        {
            ;StringReplace,str,str,% delim,ƒ,1      ;■¶╬
            str := StrReplace(str, delim, Chr(402)) ; "ƒ" = 402
            delim := Chr(402)
        }
        ra := Array()
        loop parse str, delim, omit
            if (A_LoopField != "")
                ra.Push(A_LoopField)
        return ra
    }
    Static RemoveDubls( objArray ) {
        while True
        {
            nodubls := 1
            tempArr := Map()
            for i,val in objArray
            {
                if tempArr.has( val )
                {
                    nodubls := 0
                    objArray.RemoveAt( i )
                    break
                }
                tempArr[ val ] := 1
            }
            if nodubls
                break
        }
        return objArray
    }
    Static RegisterClipboardFormat( fmtName ) {
        return DllCall( "RegisterClipboardFormat", "str", fmtName )
    }
    Static GetOpenClipboardWindow() {
        return DllCall( "GetOpenClipboardWindow" )
    }
    Static IsClipboardFormatAvailable( iFmt ) {
        return DllCall( "IsClipboardFormatAvailable", "UInt", iFmt )
    }
    Static GetImageEncodersSize( &numEncoders, &size ) {
        return DllCall( "gdiplus\GdipGetImageEncodersSize", "Uint*", &numEncoders:=0, "UInt*", &size:=0 )
    }
    Static GetImageEncoders( numEncoders, size, pImageCodecInfo ) {
        return DllCall( "gdiplus\GdipGetImageEncoders", "Uint", numEncoders, "UInt", size, "Ptr", pImageCodecInfo )
    }
    Static GetEncoderClsid( format, &CLSID ) {
        ;format should be the following
        ;~ bmp
        ;~ jpeg
        ;~ gif
        ;~ tiff
        ;~ png
        if !format
            return 0
        format := "image/" format
        this.GetImageEncodersSize( &num, &size )
        if ( size = 0 )
            return 0
        ImageCodecInfo := Buffer( size, 0 )
        this.GetImageEncoders( num, size, ImageCodecInfo.ptr )
        loop num
        {
            pici := ImageCodecInfo.ptr + ( 48+7*A_PtrSize )*(A_Index-1)
            pMime := NumGet( pici+0, 32+4*A_PtrSize, "UPtr" )
            MimeType := StrGet( pMime, "UTF-16")
            if ( MimeType = format )
            {
                CLSID := Buffer( 16, 0 )
                this.memcopy( CLSID.ptr, pici, 16 )
                return 1
            }
        }
        return 0
    }
}
