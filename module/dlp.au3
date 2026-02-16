Func dlmp3($link)
GUISetState(@SW_HIDE, $mainform)
Global $cmd=' /c yt-dlp -P "./download/mp3" --ffmpeg-location "lib/ffmpeg.exe" -x --audio-format mp3 '
RunWait(@ComSpec & $cmd & $link, @ScriptDir, @SW_SHOW)
MsgBox(64, "Notice", "You have downloaded mp3 successfully")
GUISetState(@SW_SHOW, $mainform)


EndFunc

Func dlvideo($link)
	GUISetState(@SW_HIDE, $mainform)
Global $cmd=' /c yt-dlp -P "./download/video" '
RunWait(@ComSpec & $cmd & $link, @ScriptDir, @SW_SHOW)
MsgBox(64, "Notice", "You have downloaded the video successfully")
GUISetState(@SW_SHOW, $mainform)
EndFunc

Func dlwav($link)
GUISetState(@SW_HIDE, $mainform)
Global $cmd=' /c yt-dlp -P "./download/wav" --ffmpeg-location "lib/ffmpeg.exe" -x --audio-format wav '
RunWait(@ComSpec & $cmd & $link, @ScriptDir, @SW_SHOW)
MsgBox(64, "Notice", "You have successfully downloaded WAV")
GUISetState(@SW_SHOW, $mainform)


EndFunc


Func playmedia($url)
GUICreate("starting, pleas wait",300,300)
GUISetState()
RunWait(@ComSpec&' /c yt-dlp -o "./output.mp4" '&$url,@ScriptDir,@SW_HIDE)
GUIDelete()
If Not FileExists(@ScriptDir&"\output.mp4") Then
MsgBox(16,"Error","There was a problem preparing the file for playback using the default player")
EndIf
$playid=ShellExecute(@ScriptDir&"\output.mp4")
If $playid=0 Then
MsgBox(16,"error", "unable to play the file with the default player")
Else
ProcessWaitClose($playid)

Sleep(500)
FileDelete(@ScriptDir&"\output.mp4")
EndIf

EndFunc
Func online_play($url)
ShellExecute($url)
EndFunc