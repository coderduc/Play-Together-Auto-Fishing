#include <Process.au3>
#include <Misc.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <demem.au3>
Global $iX1, $iY1, $iX2, $iY2
Global $p_bDropFishingRod = [762,326]
Global $p_bPullFishingRod = [843,428]
Global $p_bPreserveFish = [636,419]
Global $p_bPreserveTrash = [770, 453]
Global $p_bPlayerBag = [925,290]
Global $p_bUtilityBag = [763,36]
Global $p_FishingRod1 = [577,201]
Global $p_FishingRod2 = [730,196]
Global $p_FishingRod3 = [878,197]
Global $p_FishingRod4 = [581,384]
Global $p_DisableFishingRod = [730,410]
Global $p_bClosePlayerBag = [928,41]
Global $p_bFixRod1 = [580, 260]
Global $p_bFixRod2 = [728, 258]
Global $p_bFixRod3 = [878, 260]
Global $p_bFixRod4 = [581, 441]
Global $p_bPayFixRod = [499,408]
Global $p_bAcceptFixRod = [484,409]
Global $pid
Global $hProcess
Global $proc
Global $rodSelected
Global $playerState
Global $rodState
Global $isRan = False
Global $errorCount = 0
Global $iFishCount = 0
Global $Pointer
Global $oCount
Global $hDLL = DllOpen("user32.dll")
Global $offRodState = 0x5C
Global $offplayerState = 0x1C
;Get ADB Device
Global $device = adb_getOnlineDevice()
Global $Emulator_hWnd = ControlGetHandle("CoderDuc","","")
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
	Return ($playerState == 0) ? True : False 
EndFunc

Func isRodBroken()
	Return ($playerState == 10) ? True : False
EndFunc

Func fix_rod($iRod)
	open_playerbag()
	open_utilitybag()
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
	Sleep(500)
	adb_click($device,$p_bPayFixRod[0],$p_bPayFixRod[1])
	Sleep(500)
	adb_click($device,$p_bAcceptFixRod[0],$p_bAcceptFixRod[1])
	Sleep(500)
	adb_click($device,$p_bClosePlayerBag[0],$p_bClosePlayerBag[1])
EndFunc

Func drop_rod()
	adb_click($device,$p_bDropFishingRod[0],$p_bDropFishingRod[1])
	Return True
EndFunc

Func isGetFish()
	Return ($playerState == 8) ? True : False
EndFunc

Func pull_rod()
	adb_click($device,$p_bPullFishingRod[0],$p_bPullFishingRod[1])
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

Func isRodOpened()
	Return ($rodState == 103) ? True : False
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

Func getPointer($Emulator)
	$proc = ($Emulator = "1") ? "LdVBoxHeadless.exe" : ($Emulator = "2") ? "MemuHeadless.exe" : ($Emulator = "3") ? "NoxVMHandle.exe" : ($Emulator = "4") ? "HD-Player.exe" : ""
	$pid = ProcessExists($proc)
	ProcessWait($pid)
	$hProcess = demem_open($pid)
	If $hProcess = False Then
		MsgBox(16,"Thông báo",StringFormat("Lỗi khi lấy process của giả lập !!!"))
		Exit
	EndIf
	Return demem_scanAOB($hProcess, "?? ?? ?? 69 ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 69 01 00 00 00 00 00 00 00 01 00 00 00", 1)[0]
EndFunc

Func first_start($iRod,$Emulator)
	WinActivate($Emulator_hWnd)
	ToolTip("Tool State: Setting up" ,0,0,"Thông báo",1,0)
	$Pointer = getPointer($Emulator)
	ToolTip("Done ! Press HOME to starting detect" ,0,0,"Thông báo",1,0)
	$rodState = demem_readInt($hProcess,$Pointer - $offRodState)
	If isRodOpened() = True Then
		drop_rod()
	Else
		open_playerbag()
		open_utilitybag()
		open_fishingrod($iRod)
		drop_rod()
	EndIf
EndFunc

;EntryPoint
Func EntryPoint($iRod)
	$isRan = Not $isRan
	Local $state = ($isRan = True) ? "On" : "Off"
	ToolTip("Tool State: " & $state,0,0,"Thông báo",1,0)
	While $isRan
		$playerState = demem_readInt($hProcess,$Pointer - $offplayerState)
		If $playerState == 4 Then
			pull_rod()
		EndIf
		If $playerState == 6 Then
			Sleep(1000)
			$iFishCount+= 1
		EndIf
		If isGetFish() = True Then
			Sleep(60)
			preserve_fish()
			preserve_trash()
		EndIf
		If isRodBroken() = True Then fix_rod($iRod)
		If isPlayerIdle() == True Then drop_rod()
	WEnd
EndFunc

Func myExit()
	MsgBox(64,"Thông báo","Số cá bạn câu được: " & $iFishCount,3)
	WinSetTrans($Emulator_hWnd,"",255)
	Exit
EndFunc
