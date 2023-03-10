; Author: FrzA-OuO (https://github.com/FrzA-OuO)
; Script for using local media player 
; to play live stream from bilibili.com
#Requires AutoHotkey v1.1.33+

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include <JSON>

playerPath := "DirToPlayer\PotPlayerMini64.exe"

UrlDownloadToVar(url, method := "GET", headers := "")
{
    static whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open(method, url, true)

    if (headers != "")
    {
        for key, value in headers
        {
            whr.SetRequestHeader(key, value)
        }
    }

    whr.Send()
    whr.WaitForResponse()
    return whr.ResponseText
}

hint := "输入长房间号`n仅可输入数字"

InputBox, RoomId, 输入房间号, %hint%,,150,164
    if ErrorLevel
        Exit

While(Not RegExMatch(RoomId, "^\d+$")){
    MsgBox,0x30,, 请输入数字房间号
    InputBox, RoomId, 输入房间号, %hint%,,150,164
    if ErrorLevel
        Exit
}

result := UrlDownloadToVar("https://api.live.bilibili.com/room/v1/Room/playUrl?cid=" . RoomId . "&platform=h5&qn=150")

streamParse := JSON.Load(result)

If (streamParse.code == 0)
{
	url := streamParse.data.durl[1].url
	Run, "%playerPath%" %url% /referer="https://www.bilibili.com" /user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
}
Else{
	MsgBox,0x10,, 获取视频流出错
}
