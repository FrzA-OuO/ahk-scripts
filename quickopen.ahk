;Author: xml123 (https://meta.appinn.net/t/topic/3743/35)
#Requires AutoHotkey v1.1.33+
#SingleInstance Force
#NoEnv
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input
SetBatchLines -1
SetWorkingDir %A_ScriptDir%


#IfWinActive ahk_class #32770		; Open/Save dialog

^g::								; Control-g
{
	$WinID := WinExist("A")

;---------------[ File Explorer ]----------------------------------------

	For $Exp in ComObjCreate("Shell.Application").Windows	{
		$This := $Exp.Document.Folder.Self.Path
		Menu ContextMenu, Add,  %$This%, Choice
		Menu ContextMenu, Icon, %$This%, shell32.dll, 5
	}

;	Clean up
	$Exp := ""

;---------------[ Total Commander ]--------------------------------------

;	Total Commander internal codes
	cm_CopySrcPathToClip  := 2029
	cm_CopyTrgPathToClip  := 2030

	ClipSaved := ClipboardAll
	Clipboard := ""

	SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_class TTOTAL_CMD

	If (ErrorLevel = 0) {
			Menu ContextMenu, Add
			Menu ContextMenu, Add,  %clipboard%, Choice
			Menu ContextMenu, Icon, %clipboard%, shell32.dll, 5
	}

	SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_class TTOTAL_CMD

	If (ErrorLevel = 0) {
			Menu ContextMenu, Add,  %clipboard%, Choice
			Menu ContextMenu, Icon, %clipboard%, shell32.dll, 5
	}


	Clipboard := ClipSaved
	ClipSaved := ""

;---------------

	Menu ContextMenu, Show
	Menu ContextMenu, Delete

}

#IfWinActive
Return



;_____________________________________________________________________________
;
					Choice:
;_____________________________________________________________________________
;

	$FolderPath := A_ThisMenuItem 
;	MsgBox Folder = %$FolderPath%


	Gosub FeedExplorerOpenSave
		
return


;_____________________________________________________________________________
;
					FeedExplorerOpenSave:
;_____________________________________________________________________________
;    

	WinActivate, ahk_id %$WinID%


;	Read the current text in the "File Name:" box (= $OldText)
	ControlGetText $OldText, Edit1, A
	ControlFocus Edit1, A


;	Go to Folder
	Loop, 5
	{
		ControlSetText, Edit1, %$FolderPath%, ahk_id %$WinID%		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1, ahk_id %$WinID%		; check
		if ($CurControlText = $FolderPath)
			break
	}

	Sleep, 50
	ControlSend Edit1, {Enter}, A
	Sleep, 50


;	Insert original filename
	If !$OldText
		return

	Loop, 5
	{
		ControlSetText, Edit1, %$OldText%, A		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1, A		; check
		if ($CurControlText = $OldText)
			break
	}

return