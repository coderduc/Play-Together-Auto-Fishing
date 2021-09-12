#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=I:\Icon.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Description=Copyright by CoderDuc
#AutoIt3Wrapper_Res_Fileversion=1.20.0
#AutoIt3Wrapper_Res_CompanyName=CoderDuc
#AutoIt3Wrapper_Res_LegalCopyright=CoderDuc
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "Functions.au3"
Opt("CaretCoordMode",2)
Opt("MouseCoordMode",2)
Opt("PixelCoordMode",2)
;First_rod to set the rectangle
$rodSelected = InputBox("Thông báo","Chọn cần bạn muốn sử dụng: ")
If $rodSelected = "" Then
	MsgBox(16,"Bạn chưa chọn cần. Vui lòng thử lại !!!",3)
	Exit
EndIf
first_start($rodSelected)
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

;Function to set param to the EntryPoint
Func setEntryPoint()
    Switch @HotKeyPressed
		Case "{Home}"
			EntryPoint($rodSelected)
    EndSwitch
EndFunc