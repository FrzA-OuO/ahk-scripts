; Author: FrzA-OuO (https://github.com/FrzA-OuO)
; Script to change wallpaper for 2 monitors seperately
; with philhansen/WallpaperChanger (https://github.com/philhansen/WallpaperChanger)

#Requires AutoHotkey v2.0
#Include <Yaml>
;TraySetIcon("WallpaperUpdater.ico")
CONFIG_FILE_PATH := "Config.yaml"
exePath := "WallpaperChanger.exe" ; Path to wallpaperChanger.exe
MonitorDefault := {Path: "", Index: 0}
last_update := A_Now
interval := 1440 ; Update interval (minutes)
CONFIG_OBJ:={ExePath: exePath, Monitor: [MonitorDefault.Clone(), MonitorDefault.Clone()], Update: last_update, Interval: interval}
YAML_OBJ := Yaml("")
trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Config", openConfigWindow)
trayMenu.Add("Next", changeNext)
trayMenu.Default := "Config"
trayMenu.Add("Exit", trayExit)

trayExit(*){
    ExitApp
}

openConfigWindow(*){
    
    MyGui := Gui(,"Config")

    finishConfig(GuiCtrlObj, params*){
        saveConfigFile(CONFIG_FILE_PATH)
        init()
        GuiCtrlObj.Gui.Submit()
    }
    
    MyGui.Add("Text", "x9 y9 w60 R1", "Monitor 1")
    EditPath1 := MyGui.Add("Edit", "x+ yp w300 R1" , CONFIG_OBJ.Monitor[1].Path)
    BtnImg1 := MyGui.Add("Button", "x+4 yp w60 R1" , "Image")
    BtnFolder1 := MyGui.Add("Button", "x+4 yp w70 R1" , "Folder")
    MyGui.Add("Text", "x9 yp+30 w60 R1", "Monitor 2")
    EditPath2 := MyGui.Add("Edit", "x+ yp w300 R1" , CONFIG_OBJ.Monitor[2].Path)
    BtnImg2 := MyGui.Add("Button", "x+4 yp w60 R1", "Image")
    BtnFolder2 := MyGui.Add("Button", "x+4 yp w70 R1", "Folder")
    BtnOK := MyGui.Add("Button", "x+-134 y+4 w134 R1.5" , "Apply")

    BtnImg1.OnEvent("Click", openImagePath.Bind(EditPath1, CONFIG_OBJ.Monitor[1], ""))
    BtnFolder1.OnEvent("Click", openImagePath.Bind(EditPath1, CONFIG_OBJ.Monitor[1], "D"))
    BtnImg2.OnEvent("Click", openImagePath.Bind(EditPath2, CONFIG_OBJ.Monitor[2], ""))
    BtnFolder2.OnEvent("Click", openImagePath.Bind(EditPath2, CONFIG_OBJ.Monitor[2], "D"))

    EditPath1.OnEvent("Change", updatePath.Bind(EditPath1.Value, EditPath1, CONFIG_OBJ.Monitor[1]))
    EditPath2.OnEvent("Change", updatePath.Bind(EditPath2.Value, EditPath2, CONFIG_OBJ.Monitor[2]))
    BtnOK.OnEvent("Click", finishConfig)

    MyGui.Show()
    return WinExist("A")
}

updatePath(path, editCtl, monitorObj, params*){
    editCtl.Value := path
    monitorObj.Path := path
    monitorObj.Index := 0
}

openImagePath( editCtl, monitorObj, option:="", params*){
    if option
        path := FileSelect("D3", ,"Select Image Folder")
    else
        path := FileSelect("3", ,"Select Image", "Image Files (*.jpeg; *.jpg; *.png; *.bmp)")

    if path
        updatePath(path, editCtl, monitorObj)
}

; Save Config file in yaml
saveConfigFile(path){
    YAML_OBJ["ChangeWallpaper"] := CONFIG_OBJ
    yamlStr := Yaml(YAML_OBJ , 5)
    try
        fileObj := FileOpen(path, "w")
    catch as Err
        {
            MsgBox "Can't open '" path "' for writing."
                . "`n`nError " Err.Extra ": " Err.Message
            return
        }
        fileObj.Write(yamlStr)
        fileObj.Close()
}

; create yaml config file
createConfigFile(path){
    WinWaitClose( openConfigWindow() )
    yamlStr := Yaml({ChangeWallpaper: CONFIG_OBJ}, 5)  ; object to Yaml String
    try
        fileObj := FileOpen(path, "w")
    catch as Err
    {
        MsgBox "Can't open '" path "' for writing."
            . "`n`nError " Err.Extra ": " Err.Message
        return
    }
    fileObj.Write(yamlStr)
    fileObj.Close()

    return Yaml(yamlStr)  ; Yaml string file to map object
}

; load config file
loadConfig(configObject){
    if FileExist(CONFIG_FILE_PATH){
        yamlStr := FileRead(CONFIG_FILE_PATH)
        global YAML_OBJ := Yaml(yamlStr)[1]
    }
    else
        global YAML_OBJ := createConfigFile(CONFIG_FILE_PATH)[1]

    rootMap := YAML_OBJ["ChangeWallpaper"]
    Monitor1 := {Path: rootMap["Monitor"][1]["Path"], Index: rootMap["Monitor"][1]["Index"]}
    Monitor2 := {Path: rootMap["Monitor"][2]["Path"], Index: rootMap["Monitor"][2]["Index"]}
    configObject.ExePath := rootMap["ExePath"]
    configObject.Monitor := [Monitor1, Monitor2]
    configObject.Update := rootMap["Update"]
    configObject.Interval := rootMap["Interval"]
}

loadImageArray(imageArray, path, op){
    if InStr(op, "D"){
        loop files, path "\*.*"{
            if RegExMatch(A_LoopFileFullPath, "i)^.*\.(?:jpg|jpeg|png|bmp)$")
                imageArray.Push(A_LoopFileFullPath)
        }
    }
    else{
        imageArray.Push(path)
    }
}

init(){
    loadConfig(CONFIG_OBJ)
    ; Check WallpaperChanger.exe
    if !FileExist(CONFIG_OBJ.ExePath){
        MsgBox("WallpaperChanger.exe does not exist. Please put it in the script directory.")
        ExitApp
    }

    f1e := FileExist(CONFIG_OBJ.Monitor[1].Path)
    f2e := FileExist(CONFIG_OBJ.Monitor[2].Path)

    ; if path is not correct, open config window
    if( !f1e || !f2e ){
        MsgBox("The wallpaper directory has not been configured.")
        WinWaitClose( openConfigWindow() )
        f1e := FileExist(CONFIG_OBJ.Monitor[1].Path)
        f2e := FileExist(CONFIG_OBJ.Monitor[2].Path)
    }

    if( !f1e || !f2e ){
        MsgBox("An error occurred while loading the wallpaper path.")
        ExitApp(-1)
    }

    global imageArr1 := Array()
    global imageArr2 := Array()

    loadImageArray(imageArr1, CONFIG_OBJ.Monitor[1].Path, f1e )
    loadImageArray(imageArr2, CONFIG_OBJ.Monitor[2].Path, f2e )
}

changeNext(*){
    ; Change for Monitor1
    len := imageArr1.Length
    idx := CONFIG_OBJ.Monitor[1].Index + 1
    if idx > len
        idx := 1
    if idx != CONFIG_OBJ.Monitor[1].Index{
        ChangeWallpaper(imageArr1[idx], 1)
        CONFIG_OBJ.Monitor[1].Index := idx
    }

    ; Change for Monitor2
    len := imageArr2.Length
    idx := CONFIG_OBJ.Monitor[2].Index + 1
    if idx > len
        idx := 1
    if idx != CONFIG_OBJ.Monitor[2].Index{
        ChangeWallpaper(imageArr2[idx], 2)
        CONFIG_OBJ.Monitor[2].Index := idx
    }

    ; Update last modify time
    CONFIG_OBJ.Update := A_Now

    ; Dump updates into config file
    saveConfigFile(CONFIG_FILE_PATH)
}

WatchWallpaper(){
    diff := DateDiff(A_Now, CONFIG_OBJ.Update, "Minutes")
    if( diff >= CONFIG_OBJ.Interval){
        changeNext()
    }
}

ChangeWallpaper(imagePath, MonitorId){
    ExitCode := RunWait('"' CONFIG_OBJ.ExePath '" -m ' MonitorId-1 ' "' imagePath '" "' A_WorkingDir '"',,"Hide")
    sleep(1000) ; wait windows changing wallpaper
}

init()
WatchWallpaper() ; Check immediately if wallpapers are needed to be changed
SetTimer WatchWallpaper, 1000*60*10 ; Time interval of checking (ms). set to 10 minutes