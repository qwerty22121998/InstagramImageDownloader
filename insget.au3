#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=instagram.ico
#AutoIt3Wrapper_Outfile=Instagram Images Downloader.Exe
#AutoIt3Wrapper_Res_Fileversion=0.2.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <IE.au3>
#include <GDIPlus.au3>
#include <Math.au3>
#include-once

Global $img_path = @TempDir & "\insgettmp.jpg"
Global $link
Global $insta_profile
Global $is_error = 1
Global $Pic1

Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=D:\Project\insget.kxf
$Form2 = GUICreate("Instagram Images Downloader", 353, 511, 346, 78)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
$link_input = GUICtrlCreateInput("", 64, 16, 209, 24)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$link_label = GUICtrlCreateLabel("Link", 16, 16, 38, 28)
GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
$image_group = GUICtrlCreateGroup("Image", 8, 120, 336, 384)
GUICtrlSetResizing(-1, $GUI_DOCKAUTO + $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKHCENTER + $GUI_DOCKVCENTER + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
$insta_name = GUICtrlCreateLabel("", 16, 144, 316, 17)
GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetOnEvent(-1, "insta_nameClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$get_button = GUICtrlCreateButton("Get", 8, 56, 153, 41)
GUICtrlSetOnEvent(-1, "get_buttonClick")
$save_button = GUICtrlCreateButton("Save as", 176, 56, 163, 41)
GUICtrlSetOnEvent(-1, "save_buttonClick")
$bar = GUICtrlCreateProgress(8, 104, 329, 9, $PBS_SMOOTH)
GUICtrlSetState(-1, $GUI_DISABLE)
$login_button = GUICtrlCreateButton("Login First", 280, 16, 57, 25)
GUICtrlSetOnEvent(-1, "login_buttonClick")

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Sleep(100)
WEnd

Func Form2Close()
	Exit (0)
EndFunc   ;==>Close

Func show($path)
	_GDIPlus_Startup()
	$oldImage = _GDIPlus_ImageLoadFromFile($path)
	$tmp = @TempDir & "\insgetthumbtmp.jpg"
	$GC = _GDIPlus_ImageGetGraphicsContext($oldImage)
	$newW = _GDIPlus_ImageGetWidth($oldImage)
	$newH = _GDIPlus_ImageGetHeight($oldImage)
	$rate = 320 / _Max($newW, $newH)
	$newW *= $rate
	$newH *= $rate
	$newBmp = _GDIPlus_BitmapCreateFromGraphics($newW, $newH, $GC)
	$newGC = _GDIPlus_ImageGetGraphicsContext($newBmp)
	_GDIPlus_GraphicsDrawImageRect($newGC, $oldImage, 0, 0, $newW, $newH)
	_GDIPlus_ImageSaveToFile($newBmp, $tmp)
	_GDIPlus_GraphicsDispose($GC)
	_GDIPlus_GraphicsDispose($newGC)
	_GDIPlus_BitmapDispose($newBmp)
	_GDIPlus_ImageDispose($oldImage)
	_GDIPlus_Shutdown()
	GUICtrlDelete($Pic1)
	$Pic1 = GUICtrlCreatePic("", 16 + ((320) - $newW) / 2, 162 + (320 - $newH) / 2, $newW, $newH)
	GUICtrlSetImage($Pic1, $tmp)
EndFunc   ;==>Show image

Func download($img_link)
	$size = InetGetSize($img_link)
	$file = InetGet($img_link, $img_path, 1, 1)
	While Not InetGetInfo($file, 2)
		GUICtrlSetData($bar, Int(InetGetInfo($file, 0) / $size * 90))
	WEnd
	show($img_path)
	GUICtrlSetData($bar, 100)

EndFunc   ;==>Download Image

Func login_buttonClick()
	_IECreate("https://www.instagram.com/")
EndFunc   ;==>Login

Func setButtonState($state)
	GUICtrlSetState($get_button,$state)
	GUICtrlSetState($link_input,$state)
	GUICtrlSetState($login_button,$state)
	GUICtrlSetState($save_button,$state)
	GUICtrlSetState($insta_name,$state)
EndFunc

Func get_buttonClick()
	setButtonState($GUI_DISABLE)
	$link = GUICtrlRead($link_input)
	$is_error = 1
	$oIE = _IECreate($link, 0, 0, 1, 1)
	If @error Then
		MsgBox($MB_ICONERROR, "Error " & @error, "Check your connection!")
		Return
	EndIf
	$insta_profile = getacc($oIE)
	GUICtrlSetData($insta_name, $insta_profile)
	_IEQuit($oIE)
	setButtonState($GUI_ENABLE)
EndFunc   ;==>Get button

Func getimg($oIE)
	$tags = $oIE.document.getElementsByTagName("img")
	For $tag In $tags
		$class = $tag.className
		If $class == "_icyx7" Then
			$img_link = $tag.href
			download($img_link)
			$is_error = 0
		EndIf
	Next
	If $is_error Then
		MsgBox($MB_ICONERROR, "Error " & @error, "Can't find image!" & @CRLF & "Make sure that you entered correct url or you have logged in!")
		Return
	EndIf

EndFunc   ;==>Find Image


Func enableButton()


EndFunc

Func getacc($oIE)
	$tags = $oIE.document.GetElementsByTagName("a")
	For $tag In $tags
		$class = $tag.className
		If $class == "_5lote _pss4f _vbtk2" Then
			$name = $tag.href
			$is_error = 0
		EndIf
	Next
	If $is_error Then
		MsgBox($MB_ICONERROR, "Error " & @error, "Can't find image!" & @CRLF & "Make sure that you entered correct url or you have logged in!")
		Return "Error!"
	EndIf
	getimg($oIE)
	Return $name

EndFunc   ;==>Find profile link

Func insta_nameClick()
	If $insta_profile <> "Error!" And $insta_profile <> "" Then
		_IECreate($insta_profile)
	EndIf

EndFunc   ;==>Insta Profile

Func save_buttonClick()
	if Not $is_error Then
		$path = FileSaveDialog("Save as","","Image (*.jpg)",$FD_PROMPTOVERWRITE,"InsImg.jpg")
		$copy = FileCopy($img_path,$path,1)
		If $copy Then
			MsgBox(0,"Done","Image Saved!")
		Else
			MsgBox($MB_ICONERROR,"Error","Can't save image!")
		EndIf
	Else
		MsgBox($MB_ICONERROR,"Error","No image")
	EndIf
EndFunc   ;==>Save button
