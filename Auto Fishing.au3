#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=I:\Icon.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Description=Copyright by CoderDuc
#AutoIt3Wrapper_Res_Fileversion=1.23.0
#AutoIt3Wrapper_Res_CompanyName=CoderDuc
#AutoIt3Wrapper_Res_LegalCopyright=CoderDuc
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs
	Pointer: \x10\x80\x00\x03\x10\x00\x00\x00\x00\x80\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x00 000000000000000000000000?????????000000000000000000000000000000000000000000000000
	+ 10: playerState ==> 4 = Catched | 0 = Idle | 3 = Fishing | 8 = Got Fish | 6 == Rod Broken | 10 == isRodBroken
	- 18: isRodOpened ==> 3 = Opened | 1 = Idle
#ce
#include "Functions.au3"
Opt("CaretCoordMode",2)
Opt("MouseCoordMode",2)
If @AutoItX64 Then
	demem_dllOpen("demem64.dll")
Else
	demem_dllOpen("demem.dll")
EndIf
If Not demem_isDllLoaded() Then
	ConsoleWrite(StringFormat("!> Failed to load demem library\n"))
	Exit
EndIf
$rodSelected = InputBox("Thông báo","Chọn cần bạn muốn sử dụng: ")
If $rodSelected = "" Then
	MsgBox(16,"Thông báo","Bạn chưa chọn cần. Vui lòng thử lại !!!",3)
	Exit
EndIf
$Emulator = InputBox("Thông báo",StringFormat("Lựa chọn giả lập của bạn: \n1 = LDPlayer\n2 = Memuplay\n3 = Nox Player\n4 = BlueStacks"))
If $Emulator = "" And $Emulator > 5 Then
	MsgBox(16,"Thông báo","Bạn chưa chọn giả lập. Vui lòng thử lại !!!",3)
	Exit
EndIf
first_start($rodSelected,$Emulator)
While 1
	HotKeySet("{Home}","setEntryPoint")
	HotKeySet("{PgDn}","myExit")
WEnd

;Function to set param to the EntryPoint
Func setEntryPoint()
    Switch @HotKeyPressed
		Case "{Home}"
			EntryPoint($rodSelected)
    EndSwitch
EndFunc
