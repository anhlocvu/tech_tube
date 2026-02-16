#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Comment=youtube downloader
#AutoIt3Wrapper_Res_Description=Tech Tube - Developed by Anh Loc
#AutoIt3Wrapper_Res_Fileversion=3.5
#AutoIt3Wrapper_Res_ProductName=Tech Tube
#AutoIt3Wrapper_Res_ProductVersion=3.5
#AutoIt3Wrapper_Res_CompanyName=Technology Entertainment Studio
#AutoIt3Wrapper_Res_LegalCopyright=Anh Loc
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstants.au3>
#include <ColorConstants.au3>
#include <GuiListBox.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include <Misc.au3>
#include <Array.au3>

Global $version = "4.0"
Global $YT_DLP_PATH = @ScriptDir & "\lib\yt-dlp.exe"
Global $FFPLAY_PATH = @ScriptDir & "\lib\ffplay.exe"
Global $dll = DllOpen("user32.dll")

Global $aSearchIds[1]
Global $aSearchTitles[1]
Global $sCurrentKeyword = ""
Global $iTotalLoaded = 0
Global $bIsSearching = False

If Not FileExists("download") Then DirCreate("download")

If Not FileExists($YT_DLP_PATH) Then
    MsgBox(16, "Error", "The file lib\yt-dlp.exe does not exist!" & @CRLF & "Please double-check the lib folder.")
EndIf
$lding=GUICreate("loading",300,300)
GUISetState()
RunWait(@ComSpec & " /c """ & $YT_DLP_PATH & """ -U", @ScriptDir, @SW_HIDE)
GUIDelete($lding)
SoundPlay(@ScriptDir & "\data\sounds\start.mp3")

Global $mainform = GUICreate("Tech Tube, Version " & $version, 400, 450)
GUISetBkColor($COLOR_BLUE)

Global $tabs = GUICtrlCreateTab(10, 350, 380, 40)

GUICtrlCreateTabItem("You Tube &Downloader")
GUICtrlCreateLabel("&Enter the URL link of the video you want to download here:", 10, 10, 380, 40)
Global $edit = GUICtrlCreateInput("", 10, 40, 380, 20)
Global $clip = ClipGet()
If StringInStr($clip, "youtube.com") Or StringInStr($clip, "youtu.be") Then GUICtrlSetData($edit, $clip)

Global $paste = GUICtrlCreateButton("&Paste Link", 320, 80, 70, 20)

GUICtrlCreateLabel("Select Format:", 10, 80, 200, 20)
Global $cbo_dl_format = GUICtrlCreateCombo("Video MP4 (Best)", 10, 100, 280, 20)
GUICtrlSetData(-1, "Video WebM|Audio MP3|Audio M4A|Audio WAV")

Global $btn_start_dl = GUICtrlCreateButton("&Download", 10, 140, 380, 30)
Global $openbtn = GUICtrlCreateButton("&Open Download Folder", 10, 180, 380, 30)

GUICtrlCreateTabItem("You Tube &Player")
GUICtrlCreateLabel("Enter the video link you want to play:", 10, 10, 380, 20)
Global $linkedit = GUICtrlCreateInput("", 10, 30, 380, 20)
Global $play_btn = GUICtrlCreateButton("Play (Default Player)", 200, 80, 140, 40)
Global $online_play_btn = GUICtrlCreateButton("Play in Browser", 200, 140, 140, 40)

GUICtrlCreateTabItem("&Search on YouTube")
GUICtrlCreateLabel("Enter keyword to search:", 10, 10, 380, 20)
Global $inp_search = GUICtrlCreateInput("", 10, 30, 300, 20)
Global $btn_search_go = GUICtrlCreateButton("Search", 320, 30, 70, 20)
Global $lst_results = GUICtrlCreateList("", 10, 60, 380, 280, BitOR($LBS_NOTIFY, $WS_VSCROLL, $WS_BORDER))

GUICtrlCreateTabItem("")

Global $menu = GUICtrlCreateMenu("Help")
Global $menu1 = GUICtrlCreateMenuItem("About and Readme", $menu)
Global $menu2 = GUICtrlCreateMenuItem("Exit", $menu)

GUISetState(@SW_SHOW, $mainform)

While 1
    Local $msg = GUIGetMsg()

    If _IsPressed("0D", $dll) And WinActive($mainform) Then
        _HandleEnterKey()
        Do
            Sleep(10)
        Until Not _IsPressed("0D", $dll)
    EndIf

    If GUICtrlRead($tabs) = 2 Then 
        Local $iIndex = _GUICtrlListBox_GetCurSel($lst_results)
        Local $iCount = _GUICtrlListBox_GetCount($lst_results)
        
        If $iIndex <> -1 And $iIndex = $iCount - 1 And Not $bIsSearching And $sCurrentKeyword <> "" And Not _IsPressed("0D", $dll) Then
            _SearchYouTube($sCurrentKeyword, True)
        EndIf
    EndIf
    
    Switch $msg
        Case $GUI_EVENT_CLOSE, $menu2
            SoundPlay("data/sounds/exit.mp3", 1)
            DllClose($dll)
            Exit

        Case $btn_search_go
            $sCurrentKeyword = GUICtrlRead($inp_search)
            If $sCurrentKeyword <> "" Then _SearchYouTube($sCurrentKeyword, False)

        Case $btn_start_dl
            $url = GUICtrlRead($edit)
            If $url = "" Then
                MsgBox(16, "Error", "Please enter the URL!")
            Else
                Local $sTxt = GUICtrlRead($cbo_dl_format)
                Local $sFmt = ""
                
                If StringInStr($sTxt, "MP3") Then 
                    $sFmt = "-x --audio-format mp3"
                ElseIf StringInStr($sTxt, "WAV") Then
                    $sFmt = "-x --audio-format wav"
                ElseIf StringInStr($sTxt, "M4A") Then
                    $sFmt = "-x --audio-format m4a"
                ElseIf StringInStr($sTxt, "WebM") Then
                    $sFmt = "bestvideo+bestaudio --merge-output-format webm"
                Else
                    $sFmt = "-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
                EndIf
                
                GUICtrlSetState($btn_start_dl, $GUI_DISABLE)
                RunWait(@ComSpec & ' /c ""' & $YT_DLP_PATH & '" ' & $sFmt & ' -o "download/%(title)s.%(ext)s" "' & $url & '""', @ScriptDir, @SW_SHOW)
                GUICtrlSetState($btn_start_dl, $GUI_ENABLE)
                MsgBox(64, "Info", "Download Complete!")
            EndIf

        Case $paste
            GUICtrlSetData($edit, ClipGet())
        
        Case $openbtn
            ShellExecute(@ScriptDir & "\download")

        Case $play_btn
            $input_text = GUICtrlRead($linkedit)
            If $input_text <> "" Then playmedia($input_text)
        Case $online_play_btn
            $input_text = GUICtrlRead($linkedit)
            If $input_text <> "" Then online_play($input_text)
            
        Case $menu1
            about()
    EndSwitch
WEnd

Func _HandleEnterKey()
    Local $iTab = GUICtrlRead($tabs)
    If $iTab <> 2 Then Return 

    Local $hFocus = ControlGetFocus($mainform)
    Local $hFocusHandle = ControlGetHandle($mainform, "", $hFocus)
    
    If $hFocusHandle = GUICtrlGetHandle($inp_search) Then
        $sCurrentKeyword = GUICtrlRead($inp_search)
        If $sCurrentKeyword <> "" Then _SearchYouTube($sCurrentKeyword, False)
    ElseIf $hFocusHandle = GUICtrlGetHandle($lst_results) Then
        _ShowContextMenu()
    EndIf
EndFunc

Func _SearchYouTube($sKeyword, $bAppend)
    $bIsSearching = True
    
    Local $hWaitGui = 0
    If Not $bAppend Then
        $hWaitGui = GUICreate("Searching...", 250, 80, -1, -1, BitOR($WS_POPUP, $WS_BORDER), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW), $mainform)
        GUICtrlCreateLabel("Searching YouTube for: " & StringLeft($sKeyword, 20) & "...", 10, 25, 230, 20, $SS_CENTER)
        GUISetBkColor(0xFFFFFF, $hWaitGui)
        GUISetState(@SW_SHOW, $hWaitGui)
        GUISetCursor(15, 1)
    EndIf
    GUICtrlSetData($mainform, "Tech Tube - Searching...")
    
    Local $iStart = $bAppend ? $iTotalLoaded + 1 : 1
    Local $iFetch = 20
    Local $iEnd = $iStart + $iFetch - 1
    
    Local $sSearchQuery = "ytsearch" & $iEnd & ":" & $sKeyword
    Local $sParams = '--flat-playlist --print "%(title)s|%(id)s" --playlist-start ' & $iStart & ' --playlist-end ' & $iEnd & ' --encoding utf-8 "' & $sSearchQuery & '"'
    
    Local $iPID = Run(@ComSpec & ' /c ""' & $YT_DLP_PATH & '" ' & $sParams & '"', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
    
    Local $bData = Binary("")
    While ProcessExists($iPID)
        $bData &= StdoutRead($iPID, False, True)
        Sleep(10)
    WEnd
    $bData &= StdoutRead($iPID, False, True)
    
    Local $sOutput = BinaryToString($bData, 4) 

    If Not $bAppend Then
        GUICtrlSetData($lst_results, "")
        Global $aSearchIds[1]
        Global $aSearchTitles[1]
        $iTotalLoaded = 0
    EndIf

    Local $aLines = StringSplit(StringStripCR($sOutput), @LF)
    
    If $aLines[0] > 0 Then
        Local $iCount = UBound($aSearchIds)
        For $i = 1 To $aLines[0]
            Local $sLine = $aLines[$i]
            If $sLine = "" Then ContinueLoop
            
            Local $aItem = StringSplit($sLine, "|")
            If $aItem[0] >= 2 Then
                $iTotalLoaded += 1
                _GUICtrlListBox_AddString($lst_results, $iTotalLoaded & ". " & $aItem[1])
                
                ReDim $aSearchIds[$iCount + 1]
                ReDim $aSearchTitles[$iCount + 1]
                $aSearchIds[$iCount] = $aItem[2]
                $aSearchTitles[$iCount] = $aItem[1]
                $iCount += 1
            EndIf
        Next
    EndIf
    
    If $iTotalLoaded = 0 And Not $bAppend Then
         MsgBox(16, "Info", "No results found for: " & $sKeyword)
    EndIf
    
    If Not $bAppend And IsHWnd($hWaitGui) Then 
        GUIDelete($hWaitGui)
        GUISetCursor(2, 0)
        ControlFocus($mainform, "", $lst_results)
    EndIf
    
    GUICtrlSetData($mainform, "Tech Tube, Version " & $version)
    $bIsSearching = False
EndFunc

Func _ShowContextMenu()
    Local $iIndex = _GUICtrlListBox_GetCurSel($lst_results)
    If $iIndex = -1 Then Return
    
    Local $sTitle = $aSearchTitles[$iIndex + 1]
    
    Local $hMenuGui = GUICreate("Options", 250, 200, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, $mainform)
    GUISetBkColor(0xFFFFFF)
    GUICtrlCreateLabel(StringLeft($sTitle, 35) & "...", 10, 10, 230, 20)
    
    Local $btn_Play = GUICtrlCreateButton("Play", 10, 35, 230, 30)
    Local $btn_DL = GUICtrlCreateButton("Download", 10, 70, 230, 30)
    Local $btn_Web = GUICtrlCreateButton("Open in Browser", 10, 105, 230, 30)
    Local $btn_Copy = GUICtrlCreateButton("Copy Link", 10, 140, 230, 30)
    
    GUISetState(@SW_SHOW, $hMenuGui)
    
    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                GUIDelete($hMenuGui)
                ExitLoop
            Case $btn_Play
                GUIDelete($hMenuGui)
                _PlayLoop($iIndex)
                ExitLoop
            Case $btn_DL
                GUIDelete($hMenuGui)
                _ShowDownloadDialog($aSearchIds[$iIndex + 1])
                ExitLoop
            Case $btn_Web
                GUIDelete($hMenuGui)
                ShellExecute("https://www.youtube.com/watch?v=" & $aSearchIds[$iIndex + 1])
                ExitLoop
            Case $btn_Copy
                GUIDelete($hMenuGui)
                Local $sUrl = "https://www.youtube.com/watch?v=" & $aSearchIds[$iIndex + 1]
                ClipPut($sUrl)
                MsgBox(64, "Info", "Link copied to clipboard!")
                ExitLoop
        EndSwitch
    WEnd
EndFunc

Func _PlayLoop($iCurrentIndex)
    While 1
        If $iCurrentIndex < 0 Or $iCurrentIndex >= ($iTotalLoaded) Then ExitLoop
        
        Local $sID = $aSearchIds[$iCurrentIndex + 1]
        Local $sTitle = $aSearchTitles[$iCurrentIndex + 1]
        
        GUICtrlSetData($mainform, "Getting Stream URL: " & StringLeft($sTitle, 20) & "...")
        
        Local $pid_url = Run(@ComSpec & ' /c ""' & $YT_DLP_PATH & '" -g -f "best[ext=mp4]/best" ' & $sID & '"', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
        Local $sUrl = ""
        While ProcessExists($pid_url)
            $sUrl &= StdoutRead($pid_url)
        WEnd
        $sUrl = StringStripWS($sUrl, 3)
        
        GUICtrlSetData($mainform, "Tech Tube, Version " & $version)

        If $sUrl = "" Then
            MsgBox(16, "Error", "Cannot get stream URL.")
            ExitLoop
        EndIf

        Local $iPID_Play = Run('"' & $FFPLAY_PATH & '" -window_title "' & $sTitle & '" -autoexit -infbuf -x 640 -y 360 "' & $sUrl & '"', @ScriptDir, @SW_SHOW)
        
        Local $sAction = ""
        While ProcessExists($iPID_Play)
            
            If _IsPressed("11", $dll) Then ; CTRL Key
                If _IsPressed("25", $dll) Then ; LEFT ARROW (Back)
                    $sAction = "BACK"
                    ProcessClose($iPID_Play)
                    ExitLoop
                EndIf
                If _IsPressed("27", $dll) Then ; RIGHT ARROW (Next)
                    $sAction = "NEXT"
                    ProcessClose($iPID_Play)
                    ExitLoop
                EndIf
            EndIf

            If _IsPressed("24", $dll) Then
                _ReportStatus("Start of track")
                $sAction = "RESTART"
                ProcessClose($iPID_Play)
                ExitLoop
            EndIf

            If _IsPressed("23", $dll) Then
                _ReportStatus("End of track")
                $sAction = "END"
                ProcessClose($iPID_Play)
                ExitLoop
            EndIf
            
            Sleep(50)
        WEnd
        
        If $sAction = "NEXT" Then
            $iCurrentIndex += 1
        ElseIf $sAction = "BACK" Then
            $iCurrentIndex -= 1
        ElseIf $sAction = "RESTART" Then
            ; Do nothing to index, loop repeats same video
        ElseIf $sAction = "END" Then
             ; Simulate end of track. In playlist, this usually means go next, 
             ; but if you want it to just stop the player loop, use ExitLoop.
             ; Based on "End of track", I will let it just loop to next if available or exit if end.
             ; But standard behavior for "Stop" is often exit. 
             ; However, "End of track" implies finishing listening. 
             ; I will make it go to Next to keep flow, or ExitLoop if single play.
             ; Assuming list play, let's treat it as Skip/Next essentially.
             $iCurrentIndex += 1
        Else
            ExitLoop 
        EndIf
    WEnd
EndFunc

Func _ShowDownloadDialog($sID)
    Local $sUrl = "https://www.youtube.com/watch?v=" & $sID
    Local $hDLGui = GUICreate("Download Options", 300, 150, -1, -1, -1, -1, $mainform)
    GUICtrlCreateLabel("Select Format:", 10, 20, 280, 20)
    Local $cboFormat = GUICtrlCreateCombo("Video MP4 (Best)", 10, 40, 280, 20)
    GUICtrlSetData(-1, "Video WebM|Audio MP3|Audio M4A|Audio WAV")
    Local $btn_DownloadNow = GUICtrlCreateButton("Download", 100, 80, 100, 30)
    
    GUISetState(@SW_SHOW, $hDLGui)
    
    While 1
        Local $nMsg = GUIGetMsg()
        If $nMsg = $GUI_EVENT_CLOSE Then
            GUIDelete($hDLGui)
            ExitLoop
        ElseIf $nMsg = $btn_DownloadNow Then
            Local $sTxt = GUICtrlRead($cboFormat)
            GUIDelete($hDLGui)
            
            Local $sFmt = ""
            If StringInStr($sTxt, "MP3") Then 
                $sFmt = "-x --audio-format mp3"
            ElseIf StringInStr($sTxt, "WAV") Then
                $sFmt = "-x --audio-format wav"
            ElseIf StringInStr($sTxt, "M4A") Then
                $sFmt = "-x --audio-format m4a"
            ElseIf StringInStr($sTxt, "WebM") Then
                $sFmt = "bestvideo+bestaudio --merge-output-format webm"
            Else
                $sFmt = "-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            EndIf
            
            RunWait(@ComSpec & ' /c ""' & $YT_DLP_PATH & '" ' & $sFmt & ' -o "download/%(title)s.%(ext)s" "' & $sUrl & '""', @ScriptDir, @SW_SHOW)
            MsgBox(64, "Info", "Download Complete!")
            ExitLoop
        EndIf
    WEnd
EndFunc

Func playmedia($url)
    GUICtrlSetData($mainform, "Tech Tube - Loading Stream...")
    
    Local $pid = Run(@ComSpec & ' /c ""' & $YT_DLP_PATH & '" -g -f "best" "' & $url & '""', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
    ProcessWaitClose($pid)
    Local $dlink = StdoutRead($pid)
    $dlink = StringStripWS($dlink, 3)
    
    GUICtrlSetData($mainform, "Tech Tube, Version " & $version)

    If $dlink <> "" Then
        Local $sCmd = '"' & $FFPLAY_PATH & '" -autoexit -window_title "Tech Tube Player" -infbuf -x 640 -y 360 "' & $dlink & '"'
        Local $pid_play = Run($sCmd, @ScriptDir, @SW_SHOW)
        
        While ProcessExists($pid_play)
            
            If _IsPressed("24", $dll) Then ; HOME - Start of track (Restart)
                _ReportStatus("Start of track")
                ProcessClose($pid_play)
                $pid_play = Run($sCmd, @ScriptDir, @SW_SHOW)
                ; Wait key release
                Do 
                    Sleep(10) 
                Until Not _IsPressed("24", $dll)
            EndIf
            
            If _IsPressed("23", $dll) Then ; END - End of track (Stop)
                _ReportStatus("End of track")
                ProcessClose($pid_play)
                ExitLoop
            EndIf
            
            Sleep(50)
        WEnd
    Else
        MsgBox(16, "Error", "Cannot get video stream from this link.")
    EndIf
EndFunc

Func online_play($url)
    ShellExecute($url)
EndFunc

Func _ReportStatus($sText)
    ToolTip($sText, 0, 0, "Info", 1)
    Sleep(1000)
    ToolTip("")
EndFunc

Func about()
    $agui = GUICreate("about", 400, 400)
    GUISetBkColor($COLOR_BLUE)
    GUICtrlCreateTab(10, 10, 480, 20)
    GUICtrlCreateTabItem("about")
    Local $txtAbout = FileExists(@ScriptDir & "\data\dock\about.txt") ? FileRead(@ScriptDir & "\data\dock\about.txt") : "Tech Tube"
    GUICtrlCreateEdit($txtAbout, 10, 40, 380, 250, BitOR($ES_READONLY, $WS_TABSTOP))
    GUICtrlCreateTabItem("read me")
    Local $txtRead = FileExists(@ScriptDir & "\data\dock\readme.txt") ? FileRead(@ScriptDir & "\data\dock\readme.txt") : "Read Me"
    GUICtrlCreateEdit($txtRead, 10, 40, 380, 250)
    GUICtrlCreateTabItem("contact")
    $fb = GUICtrlCreateButton("face book", 10, 40, 180, 20)
    $email = GUICtrlCreateButton("email", 10, 80, 180, 20)
    $telegram = GUICtrlCreateButton("telegram", 10, 120, 180, 20)
    GUICtrlCreateTabItem("")
    $Close = GUICtrlCreateButton("close", 320, 300, 70, 20)
    GUISetState(@SW_SHOW, $agui)
    While 1
        $msg = GUIGetMsg()
        Switch $msg
            Case $GUI_EVENT_CLOSE, $Close
                GUIDelete($agui)
                ExitLoop
            Case $fb
                ShellExecute("https://www.facebook.com/anhloc2004/")
            Case $email
                ShellExecute("https://mail.google.com/mail/u/0/?fs=1&tf=cm&source=mailto&to=locvuu2105@gmail.com")
            Case $telegram
                ShellExecute("https://t.me/Loc2004")
        EndSwitch
    WEnd
EndFunc