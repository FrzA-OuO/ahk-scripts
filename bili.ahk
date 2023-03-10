; Author: FrzA-OuO (https://github.com/FrzA-OuO)
; Script for using local media player 
; to play live stream from bilibili.com
; API source: https://github.com/SocialSisterYi/bilibili-API-collect
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

InputBox, RoomId, 输入房间号, 长/短房间号均可`n仅可输入数字,,160,144
    if ErrorLevel
        Exit

While(Not RegExMatch(RoomId, "^\d+$")){
    MsgBox,0x30,, 请不要输入除数字外的其余符号
    InputBox, RoomId, 输入房间号, 长/短房间号均可`n仅可输入数字,,160,144
    if ErrorLevel
        Exit
}

headers := {"Connection": "close"
    ,"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61"
    ,"DNT": "1", "Accept": "*/*", "Sec-Fetch-Site": "same-site"
    ,"Sec-Fetch-Mode": "no-cors", "Sec-Fetch-Dest": "script"
    , "Referer": "https://space.bilibili.com/", "Accept-Encoding": "gzip, deflate"
    ,"Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"}

result := UrlDownloadToVar("https://api.live.bilibili.com/room/v1/Room/room_init?id=" . RoomId, "GET", headers)

infoParse := JSON.Load(result)

If (infoParse.code == 0 )
{
    If (infoParse.data.live_status == 1){
        RoomRealId := infoParse.data.room_id
        
        result := UrlDownloadToVar("https://api.live.bilibili.com/room/v1/Room/playUrl?cid=" . RoomRealId . "&platform=h5&quality=2", "GET", headers)
        streamParse := JSON.Load(result)
        
        If (streamParse.code == 0)
        {
            url := streamParse.data.durl[1].url
            Run, "%playerPath%" %url% /referer="https://www.bilibili.com" /user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"
        }
        Else{
            MsgBox,0x10,, 获取视频流出错
        }
    }
    Else{
        MsgBox,0x30,, 尚未开播
    }
}
Else If (infoParse.code == 60004 ){
    MsgBox,0x30,, 直播间不存在
}
Else{
    MsgBox,0x10,, 解析出错 infoParse.code
}
