#include "Functions.au3"
Opt("CaretCoordMode",2)
Opt("MouseCoordMode",2)
Opt("PixelCoordMode",2)
;First_rod to set the rectangle
first_start(4)
;Draw a rectangle overlay into targe
Local $hwnd_overlay = CreateWindowOverlay($Emulator_hWnd)
If @error And MsgBox(16, "", "Lỗi khi vẽ hình chữ nhật !!!") Then Exit
_WinAPI_ShowWindow($hwnd_overlay, @SW_SHOW)
_WinAPI_UpdateWindow($hwnd_overlay)
_Graphic_StartUp($hwnd_overlay)
Local $hPen = _GDIPlus_PenCreate(0xFFF800F8, 2)
While 1
    Local $rc = UpdateOverlay($hwnd_overlay, $Emulator_hWnd)
    If @error Then Exit
    _GDIPlus_GraphicsClear($g_hGfxCtxt, 0xFF000000)
	_GDIPlus_GraphicsDrawRect($g_hGfxCtxt,499,58,10,10,$hPen) ;Draw a rectangle (499,58,10,10)
	HotKeySet("{Home}","setEntryPoint")
	HotKeySet("{End}","HideWindow")
	HotKeySet("{DEL}","myExit")
    _WinAPI_BitBlt($hDC, 0, 0, $rc.right, $rc.bottom, $buffer, 0, 0, $SRCCOPY)
WEnd
