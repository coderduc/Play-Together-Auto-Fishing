#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>
Global $g_hGfxCtxt, $hDC, $hHBitmap, $buffer
Func UpdateOverlay($hwnd_overlay, $hwnd_target)

    If WinExists($hwnd_target) = False Then Return SetError(1, 0, False)

    Static $old_rc = _WindowGetClientRect($hwnd_target)

    Local $hwnd_active = _WinAPI_GetForegroundWindow()
    If ($hwnd_active = $hwnd_target) Then
        Local $hwnd_highestZIndexlol = _WinAPI_GetWindow($hwnd_target, $GW_HWNDPREV)
        _WinAPI_SetWindowPos($hwnd_overlay, $hwnd_highestZIndexlol, 0, 0, 0, 0, BitOR($SWP_NOMOVE, $SWP_NOSIZE))
    EndIf

    $rc = _WindowGetClientRect($hwnd_target)
    If $rc.left <> $old_rc.left Or $rc.top <> $old_rc.top Or $rc.right <> $old_rc.right Or $rc.bottom <> $old_rc.bottom Then

        If $rc.right <> $old_rc.right Or $rc.bottom <> $old_rc.bottom Then

            Local $hRegion = _GDIPlus_RegionCreateFromRect(0, 0, $rc.right, $rc.bottom)

    _GDIPlus_GraphicsSetClipRegion($g_hGfxCtxt, $hRegion)
            _GDIPlus_RegionDispose($hRegion)
        EndIf

        $old_rc = $rc
        _WinAPI_SetWindowPos($hwnd_overlay, $hwnd_target, $rc.left, $rc.top, $rc.right, $rc.bottom, $SWP_NOREDRAW)
    EndIf

    ; return window rect
    Return $rc
EndFunc


Func CreateWindowOverlay($hwnd_target)
    OnAutoItExitRegister("__OverlayExit")
    ; Create a class cursor

    If WinExists($hwnd_target) = False Then Return SetError(1, 0, False)

    Local $rc = _WindowGetClientRect($hwnd_target)

    Local Const $sClass = 'OverlayWindow'
    Local $hCursor = _WinAPI_LoadCursor(0, 32512) ; IDC_ARROW

    ; Create a class icons (large and small)
    Local $tIcons = DllStructCreate('ptr;ptr')
    _WinAPI_ExtractIconEx(@SystemDir & '\shell32.dll', 130, DllStructGetPtr($tIcons, 1), DllStructGetPtr($tIcons, 2), 1)
    Local $hIcon = DllStructGetData($tIcons, 1)
    Local $hIconSm = DllStructGetData($tIcons, 2)

    ; Create DLL callback function (window procedure)
    Local $hProc = DllCallbackRegister('WndProcOverlay', 'lresult', 'hwnd;uint;wparam;lparam')

    ; Create and fill $tagWNDCLASSEX structure
    Local $tWCEX = DllStructCreate($tagWNDCLASSEX & ';wchar szClassName[' & (StringLen($sClass) + 1) & ']')
    DllStructSetData($tWCEX, 'Size', DllStructGetPtr($tWCEX, 'szClassName') - DllStructGetPtr($tWCEX))
    DllStructSetData($tWCEX, 'Style', 0)
    DllStructSetData($tWCEX, 'hWndProc', DllCallbackGetPtr(DllCallbackRegister('WndProcOverlay', 'lresult', 'hwnd;uint;wparam;lparam')))
    DllStructSetData($tWCEX, 'ClsExtra', 0)
    DllStructSetData($tWCEX, 'WndExtra', 0)
    DllStructSetData($tWCEX, 'hInstance', Null)
    DllStructSetData($tWCEX, 'hIcon', $hIcon)
    DllStructSetData($tWCEX, 'hCursor', $hCursor)
    DllStructSetData($tWCEX, 'hBackground', Null)
    DllStructSetData($tWCEX, 'MenuName', Null)
    DllStructSetData($tWCEX, 'szClassName', $sClass)
    DllStructSetData($tWCEX, 'ClassName', DllStructGetPtr($tWCEX, 'szClassName'))
    DllStructSetData($tWCEX, 'hIconSm', $hIconSm)

    If _WinAPI_RegisterClassEx($tWCEX) = 0 Then Return SetError(2, 0, False)
    Local $hwnd = _WinAPI_CreateWindowEx(Null, $sClass, "codedbythedemons", BitOR($WS_POPUP, $WS_VISIBLE), $rc.left, $rc.top, $rc.right, $rc.bottom, Null, Null, $tWCEX.hInstance, Null)

    If $hwnd = 0 Then Return SetError(2, 0, False)
    Local $margin = DllStructCreate("int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight;")
        $margin.cxLeftWidth = -1
        $margin.cxRightWidth = -1
        $margin.cyTopHeight = -1
        $margin.cyBottomHeight = -1

    Local $result = DllCall("dwmapi.dll", "long*", "DwmExtendFrameIntoClientArea", "uint", $hwnd, "ptr", DllStructGetPtr($margin))
    If @error Then Return SetError(3, 0, False)


    _WinAPI_SetWindowLong($hwnd, $GWL_EXSTYLE, BitOR($WS_EX_LAYERED, $WS_EX_TRANSPARENT, $WS_EX_TOOLWINDOW))
    If @error Then Return SetError(4, 0, False)

    Return $hwnd
EndFunc

Func _WindowGetClientRect($hwnd)
    Local $p = DllStructCreate("int x;int y")
    _WinAPI_ClientToScreen($hwnd, $p)

    Local $rc = _WinAPI_GetClientRect($hwnd)
    $rc.left = $p.x
    $rc.top = $p.y
    Return $rc
EndFunc


Func __OverlayExit()
    Local $hwnd = WinGetHandle("[CLASS:OverlayWindow]")
    While $hwnd <> 0
        _WinAPI_DestroyWindow($hwnd)
        $hwnd = WinGetHandle("[CLASS:OverlayWindow]")
    WEnd
    _WinAPI_UnregisterClass("OverlayWindow", Null);
EndFunc

Func WndProcOverlay($hWnd, $iMsg, $wParam, $lParam)
    Switch $iMsg
        Case $WM_CLOSE
            $g_bExit = True
    EndSwitch
    Return _WinAPI_DefWindowProcW($hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>_WndProc

Func _Graphic_StartUp($GUI)

    If WinExists($GUI) = False Then Return False
    _GDIPlus_Startup()

    ; install gdi
    Local $rc = _WindowGetClientRect($GUI)
    $hDC = _WinAPI_GetDC($GUI)
    $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC, @DesktopWidth, @DesktopHeight)

    $buffer = _WinAPI_CreateCompatibleDC($hDC)
    _WinAPI_SelectObject($buffer, $hHBitmap)

    $g_hGfxCtxt = _GDIPlus_GraphicsCreateFromHDC($buffer)
    _GDIPlus_GraphicsSetSmoothingMode($g_hGfxCtxt, $GDIP_SMOOTHINGMODE_HIGHQUALITY)
    _GDIPlus_GraphicsSetPixelOffsetMode($g_hGfxCtxt, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)

    Local $hRegion = _GDIPlus_RegionCreateFromRect(0, 0, $rc.right, $rc.bottom)
    _GDIPlus_GraphicsSetClipRegion($g_hGfxCtxt, $hRegion)
    _GDIPlus_RegionDispose($hRegion)

EndFunc