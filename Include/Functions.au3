#include <Process.au3>
#include <GDIPlus.au3>
#include <GDIPlusConstants.au3>
#include <Misc.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <ScreenCapture.au3>
#include <Array.au3>
#include "HandleImgSearch.au3"
#include "WindowOverlay.au3"
Global $iX1, $iY1, $iX2, $iY2
Global $p_bDropFishingRod = [762,326]
Global $p_bPullFishingRod = [843,428]
Global $p_bPreserveFish = [641, 442]
Global $p_bPreserveTrash = [770, 453]
Global $p_bPlayerBag = [925,290]
Global $p_bUtilityBag = [694,41]
Global $p_FishingRod1 = [577,201]
Global $p_FishingRod2 = [730,196]
Global $p_FishingRod3 = [878,197]
Global $p_FishingRod4 = [581,384]
Global $p_DisableFishingRod = [730,410]
Global $p_bClosePlayerBag = [929, 35]
Global $p_bCheckRod1 = [624,294]
Global $p_bCheckRod2 = [771,292]
Global $p_bCheckRod3 = [921,292]
Global $p_bCheckRod4 = [615,481]
Global $p_bFixRod1 = [580, 260]
Global $p_bFixRod2 = [728, 258]
Global $p_bFixRod3 = [878, 260]
Global $p_bFixRod4 = [581, 441]
Global $p_bPayFixRod = [499,408]
Global $p_bAcceptFixRod = [484,409]
Global $color
Global $isRan = False
Global $isWindowHide = False
Global $hDLL = DllOpen("user32.dll")
;Get ADB Device
Global $device = adb_getOnlineDevice()
Global $Emulator_hWnd = WinGetHandle("CoderDuc")
If @error And MsgBox(16, "", "Lỗi khi lấy thông tin thiết bị !!!") Then Exit
Func adb_getOnlineDevice()
	;Get pid of current cmd (adb devices) command
	Local $sOutput = ""
    Local $online_device = ""
	Local $iPID = Run(@ComSpec & " /c " & "adb devices",@ScriptDir,@SW_HIDE,$STDOUT_CHILD)
	While 1
		$sOutput &= StdoutRead($iPID)
		If @error Then ExitLoop
	WEnd
	;Get online device
	Local $str_temp = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF,2)
	For $i = 1 to UBound($str_temp) - 1 Step 1
		If StringInStr($str_temp[$i],"device") Then $online_device = StringTrimRight($str_temp[$i],6)
	Next
	Return $online_device
EndFunc

Func adb_click($device,$x,$y)
	cmd("adb -s " & $device & " shell input tap " & $x & " " & $y) ;adb click (x,y)
EndFunc

Func cmd($command)
	RunWait(@ComSpec & " /c " & $command,@ScriptDir,@SW_HIDE) ;run adb command
	Sleep(500)
EndFunc

Func isPlayerIdle()
	Local $isPlayer_idle
	Local $player_idle
	$player_idle = _HandleGetPixel($Emulator_hWnd,910,310) ;Check whether the player is idle and missed or not
	Return ($player_idle = 0xE44142) ? True : False
EndFunc

Func isRodBroken($iRod)
	Local $check_in_bag
	Local $fixrod_signal =  _HandleGetPixel($Emulator_hWnd,527,228) ;Check if the rod was broked or not
	If $fixrod_signal = 0xFFFFFF Then
		open_playerbag()
		open_utilitybag()
		Switch $iRod
		Case 1
			$check_in_bag = _HandleGetPixel($Emulator_hWnd,$p_bCheckRod1[0],$p_bCheckRod1[1])
		Case 2
			$check_in_bag = _HandleGetPixel($Emulator_hWnd,$p_bCheckRod2[0],$p_bCheckRod2[1])
		Case 3
			$check_in_bag = _HandleGetPixel($Emulator_hWnd,$p_bCheckRod3[0],$p_bCheckRod3[1])
		Case 4
			$check_in_bag = _HandleGetPixel($Emulator_hWnd,$p_bCheckRod4[0],$p_bCheckRod4[1])
		EndSwitch
	EndIf
	Return ($check_in_bag = 0xF15E4E) ? True : False
EndFunc

Func fix_rod($iRod)
	If isRodBroken($iRod) = True Then
		Switch $iRod
		Case 1
			adb_click($device,$p_bFixRod1[0],$p_bFixRod1[1])
		Case 2
			adb_click($device,$p_bFixRod2[0],$p_bFixRod2[1])
		Case 3
			adb_click($device,$p_bFixRod3[0],$p_bFixRod3[1])
		Case 4
			adb_click($device,$p_bFixRod4[0],$p_bFixRod4[1])
		EndSwitch
		adb_click($device,$p_bPayFixRod[0],$p_bPayFixRod[1])
		adb_click($device,$p_bAcceptFixRod[0],$p_bAcceptFixRod[1])
		adb_click($device,$p_bClosePlayerBag[0],$p_bClosePlayerBag[1])
	EndIf
EndFunc

Func drop_rod()
	adb_click($device,$p_bDropFishingRod[0],$p_bDropFishingRod[1])
	Return True
EndFunc

Func isGetFish()
	Local $isGetFish
	Local $get_color
	Local $get_color1
	;Check whether we catch the fish on hand
	Do
		$get_color1 = _HandleGetPixel($Emulator_hWnd,900,200)
		If isPlayerIdle() = True Then ExitLoop
	Until $get_color1 = 0xFFFFFF
	;Check if its a fish or not
	Local $get_color = _HandleGetPixel($Emulator_hWnd,900,450)
	Return ($get_color = 0xFFC71D) ? True : False
EndFunc

Func pull_rod()
	adb_click($device,$p_bPullFishingRod[0],$p_bPullFishingRod[1])
	Sleep(1500)
	If isGetFish() = True Then
		preserve_fish()
	Else
		preserve_trash()
	EndIf
	Return True
EndFunc

Func preserve_trash()
	adb_click($device,$p_bPreserveTrash[0],$p_bPreserveTrash[1])
	Return True
EndFunc

Func preserve_fish()
	adb_click($device,$p_bPreserveFish[0],$p_bPreserveFish[1])
	Return True
EndFunc

Func open_playerbag()
	adb_click($device,$p_bPlayerBag[0],$p_bPlayerBag[1])
	Return True
EndFunc

Func open_utilitybag()
	adb_click($device,$p_bUtilityBag[0],$p_bUtilityBag[1])
	Return True
EndFunc

Func isRodOpened($iRod)
	Local $bool
	Local $isOpenRod
	Switch $iRod
		Case 1
			$isOpenRod = _HandleGetPixel($Emulator_hWnd,560,180);Check if the rod 1 is opened
		Case 2
			$isOpenRod = _HandleGetPixel($Emulator_hWnd,680,190);Check if the rod 2 is opened
		Case 3
			$isOpenRod = _HandleGetPixel($Emulator_hWnd,840,199);Check if the rod 3 is opened
		Case 4
			$isOpenRod = _HandleGetPixel($Emulator_hWnd,530,380);Check if the rod 4 is opened
	EndSwitch
	Return ($isOpenRod = 0x82FB28) ? True : False
EndFunc

Func open_fishingrod($iRod)
	Switch $iRod
		Case 1
			adb_click($device,$p_FishingRod1[0],$p_FishingRod1[1])
		Case 2
			adb_click($device,$p_FishingRod2[0],$p_FishingRod2[1])
		Case 3
			adb_click($device,$p_FishingRod3[0],$p_FishingRod3[1])
		Case 4
			adb_click($device,$p_FishingRod4[0],$p_FishingRod4[1])
	EndSwitch
EndFunc

Func disable_rod()
	adb_click($device,$p_DisableFishingRod[0],$p_DisableFishingRod[1])
	Return True
EndFunc

Func close_playerbag()
	adb_click($device,$p_bClosePlayerBag[0],$p_bClosePlayerBag[1])
	Return True
EndFunc

Func isPlayerBagOpened()
	Local $isBagOpened = _HandleGetPixel($Emulator_hWnd,748, 337) ;Check if the player bag is opened
	Return ($isBagOpened = 0xE85D3C) ? True : False
EndFunc

Func first_start($iRod)
	WinActivate($Emulator_hWnd)
	If isPlayerBagOpened() = True Then close_playerbag()
	open_playerbag()
	open_utilitybag()
	If isRodOpened($iRod) = True Then
		close_playerbag()
		drop_rod()
	Else
		open_fishingrod($iRod)
		drop_rod()
	EndIf
EndFunc

;EntryPoint
Func EntryPoint($iRod)
	$isRan = Not $isRan
	Local $color = _HandleGetPixel($Emulator_hWnd,499,58);Get the first color
	Local $state = ($isRan = True) ? "On" : "Off"
	ToolTip("Tool State: " & $state,0,0,"Thông báo",1,0)
	While $isRan
		$cur_color = _HandleGetPixel($Emulator_hWnd,499,58);Get the second color
		ConsoleWrite($cur_color & @CRLF)
		If $cur_color <> $color Then ;If $cur_color doesn't match the first color then pull the rod to catch fish
			pull_rod()
			drop_rod()
			Sleep(1500)
			$color = _HandleGetPixel($Emulator_hWnd,499,58);Update the first color
		EndIf
		fix_rod($iRod)
		If isPlayerIdle() = True Then drop_rod()
	WEnd
EndFunc

;Function to set param to the EntryPoint
Func setEntryPoint()
    Switch @HotKeyPressed
		Case "{Home}"
			EntryPoint(4)
    EndSwitch
EndFunc

Func myExit()
	MsgBox(64,"Thông báo","Hẹn gặp lại <3",3)
	Exit
EndFunc

Func HideWindow()
	$isWindowHide = Not $isWindowHide
	If $isWindowHide Then
		WinSetTrans($Emulator_hWnd,"",0)
	Else
		WinSetTrans($Emulator_hWnd,"",255)
	EndIf
EndFunc