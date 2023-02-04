; Author: FrzA-OuO (https://github.com/FrzA-OuO)
; 借助 FFMpeg 清除x264编码后文件的meta信息

/*
FFMPEG Docs https://ffmpeg.org/ffmpeg-bitstream-filters.html
> For example, to remove all non-VCL NAL units from an H.264 stream:
> ` ffmpeg -i INPUT -c:v copy -bsf:v 'filter_units=pass_types=1-5' OUTPUT `
>
> To remove all AUDs, SEI and filler from an H.265 stream:
> ` ffmpeg -i INPUT -c:v copy -bsf:v 'filter_units=remove_types=35|38-40' OUTPUT `
*/
#Requires AutoHotkey v1.1.33+
#NoEnv 
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Gui, New, +HwndGUI1
Gui, Add, Text, x10 w40, Video
Gui, Add, Edit, x+10 yp+0 w300 HwndHEdit1 vEditInput,

Gui, Add, Text, x10 w40, Output
Gui, Add, Edit, x+10 yp+0 w300 HwndHEdit2 vEditOutput, 输出文件名

Gui, Add, Button, x50 w120 h30 gButtonRun, Convert

Gui, Show

Return

GuiClose:
ExitApp


GuiDropFiles:
If (A_GuiControl == "EditInput") {
	Loop, Parse, A_GuiEvent, `n
	{
		FirstFile = %A_LoopField%
		break
	}
	GuiControl,,Edit1, %FirstFile%
	
	FoundPos := InStr(FirstFile, "." , , 0)
	WithoutExt := SubStr(FirstFile, 1 ,FoundPos-1)

	GuiControl,,Edit2, % WithoutExt . "_clean.mp4"
	Return
}
Return

ButtonRun:
Gui, Submit, NoHide ; 保存用户的输入到每个控件的关联变量中.
if( EditInput != "" ){
	ClearMeta(EditInput, EditOutput)
}
Return


ClearMeta(inputFile, outputFile)
{
	command = ffmpeg -i "%inputFile%" -c:v copy -c:a copy -bsf:v 'filter_units=remove_types=6' "%outputFile%"
;	MsgBox %command%
	Run, %command%
}