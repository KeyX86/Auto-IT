#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=temperature (1).ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <String.au3>
#include <Array.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>

;### LƯU Ý, NHẬP TÊN THÀNH PHỐ CÓ DẤU DỄ GÂY LỖI.

_GDIPlus_Startup()
Global $API = '8cc0cf33ff7c6ac14e22653a3f1eca9b' ;API Public
Global $Weather = GetWeatherHTML("Hồ Chí Minh", $API)

$hGUI = GUICreate("Simple Weather", 222, 176, 192, 124)
GUISetBkColor(0xcee1ff)
GUISetFont(10, 400, 0, "Segoe UI", $hGUI, 5)
$Input = GUICtrlCreateInput($Weather[0], 16, 8, 113, 21, 0x0001)
$Search = GUICtrlCreateButton("Tìm", 136, 7, 59, 23)
$Icon = GUICtrlCreatePic("", 128, 102, 50, 50)
$Tinh = GUICtrlCreateLabel($Weather[0], 10, 48, 200, 32, BitOR(0x01, 0x200))
GUICtrlSetFont(-1, 15, 400, 0, "Segoe UI")
$Nhietdo = GUICtrlCreateLabel("Nhiệt độ " & @CR & $Weather[1], 125, 80, 115, 40)
$May = GUICtrlCreateLabel("Mây " & $Weather[3], 24, 80, 98, 17)
$Doam = GUICtrlCreateLabel("Độ ẩm " & $Weather[4], 24, 96, 99, 17)
$Gio = GUICtrlCreateLabel("Gió " & $Weather[5], 24, 112, 95, 17)
$Apsuat = GUICtrlCreateLabel("Áp suất " & $Weather[6], 24, 128, 96, 17)
SetWeatherIcon($Icon, $Weather[2])
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case -3
			Exit
		Case $Search
			GetWeather(GUICtrlRead($Input))
	EndSwitch
WEnd

Func GetWeather($sLocation)
	Local $aRet = GetWeatherHTML($sLocation, $API)
	If Not IsArray($aRet) Then Return
	GUICtrlSetData($Tinh, $aRet[0])
	GUICtrlSetData($Nhietdo, "Nhiệt độ" & @CR & $aRet[1])
	SetWeatherIcon($Icon, $aRet[2])
	GUICtrlSetData($May, "Mây " & $aRet[3])
	GUICtrlSetData($Doam, "Độ ẩm " & $aRet[4])
	GUICtrlSetData($Gio, "Gió " & $aRet[5])
	GUICtrlSetData($Apsuat, "Áp suất" & $aRet[6])
EndFunc

Func SetWeatherIcon($hPic, $sCode, $iLeft = -1, $iTop = -1, $iWidth = -1, $iHeight = -1)
	Local Const $BinaryImg = InetRead("http://openweathermap.org/img/w/" & $sCode &".png", 1)
	If @error Then Return
	Local Const $aBmp = _GDIPlus_BitmapCreateFromMemory($BinaryImg)
	Local Const $hBmp = _GDIPlus_BitmapCreateDIBFromBitmap($aBmp)
	If Not $iLeft = -1 Then GUICtrlSetPos($hPic, $iLeft)
	If Not $iTop = -1 Then GUICtrlSetPos($hPic, $iLeft, $iTop)
	If $iWidth = -1 Then
		$iWidth = _GDIPlus_ImageGetWidth($aBmp)
	Else
		GUICtrlSetPos($hPic, $iLeft, $iTop, $iWidth)
	EndIf
	If $iHeight = -1 Then
		$iHeight = _GDIPlus_ImageGetHeight($aBmp)
	Else
		GUICtrlSetPos($hPic, $iLeft, $iTop, $iWidth, $iHeight)
	EndIf
	_WinAPI_DeleteObject(GUICtrlSendMsg($hPic, 0x0172, 0, 0))
	_WinAPI_DeleteObject(GUICtrlSendMsg($hPic, 0x0172, 0, $hBmp))
	_GDIPlus_BitmapDispose($aBmp)
	_WinAPI_DeleteObject($hBmp)
EndFunc

Func GetWeatherHTML($sLocation, $sAPIKey)
	Local $aRet[7]
	$aRet[0] = StringUpper($sLocation)
	$sLocation = StringReplace($sLocation, " ", "%20")
	Local $sReq = 'http://api.openweathermap.org/data/2.5/' _
				& 'weather?q=' &		$sLocation _
				& '&mode=html&appid=' & $sAPIKey
	Local $sRet = InetRead($sReq, 1)
	If @error Then Return False
	$sRet = BinaryToString($sRet, 4)
	If StringInStr($sRet, ":404") Then Return False
	$aRet[1] = _StringBetween($sRet, '"Current Temperature">', '</div>')[0]
	$aRet[2] = _StringBetween($sRet, 'org/img/w/', '.png&quot;')[0]
	If @HOUR > 18 Then $aRet[2] = StringReplace($aRet[2], "d", "n")
	$aRet[3] = _StringBetween($sRet, '>Clouds:', '</div>')[0]
	$aRet[4] = _StringBetween($sRet, '>Humidity:', '</div>')[0]
	$aRet[5] = _StringBetween($sRet, '>Wind:', '</div>')[0]
	$aRet[6] = _StringBetween($sRet, '>Pressure:', '</div>')[0]
	Return $aRet
EndFunc