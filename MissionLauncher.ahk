#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================
; Hotkeys - Main Methods
; =============================================
F3::{
    if(PrimariesSwap.Value and PrimariesSlot.Value > 0) {
        swapLoadout(PrimariesSlot.Value)
    }
    selectMission(Missions[MissionType.Value][Mission.Value], Difficulty.Value)
    if(not KeepCheckpoint.Value) {
        ClearCheckpoint()
    }
    LaunchMission()
    if(EntranceSlot.Value > 0) {
        swapLoadout(EntranceSlot.Value)
    }
}
F4::{
    Director() {  ; Opens the Director Menu
        exitMenus()             ; Exit any open menus
        Send "{esc}"            ; Open Escape Menu
        Sleep 1000              ; Wait for Escape Menu to load mouse movement
        ;FIXME - MouseMove(700, 385) does not appear to work
        MouseMove(700, 385)     ; Move mouse to Director button    
        Sleep 1000              ; Wait for Escape Menu to load     
        Click                   ; Click Director button
        ; TODO: Remove Launch Mission button if it exists
        Sleep 1200              ; Wait for Director to load                     
    }
}
; =============================================
; Settings
; =============================================
; Settings Index Key :: Setting Defaults = 1,1,1,0,0,0,0
SetMissionType := 1
SetMission := 2         
SetDifficulty := 3      
SetKeepCheckpoint := 4  
SetPrimariesSwap := 5   
SetEntranceSlot := 6    
SetPrimariesSlot := 7
Settings := [1, 8, 1, 0, 0, 0, 0,'SAVED']

; =============================================
; Data - Maps and Arrays
; =============================================
Planets := Map( ; Planets["name"] = [X, Y]
    "vanguard",         [ 725, 155],
    "gambit",           [ 880, 155],
    "crucible",         [1040, 155],
    "legend",           [1195, 155],
    "tower",            [ 960, 840],
    "helm",             [ 666, 575],
    "edz",              [ 705, 960],
    "cosmodrome",       [1215, 960],
    "moon",             [1555, 875],
    "nessus",           [1670, 650],
    "dreaming city",    [1590, 440],
    "eternity",         [1475, 280],
    "europa",           [ 225, 560],
    "throne world",     [ 435, 790],
    "neptune",          [ 440, 320]
)
MissionTypes := ["raid", "dungeon", "playlist", "other"]
Missions := [ ; ["name", "planet", scroll[X,Y,T], click[X, Y], [Diff_Settings] ]
    [ ; raids
        ["last wish",           "dreaming city",    [900, 20, 1000],    [615, 285],         ["normal"]],  
        ["garden of salvation", "moon",             [900, 20, 1000],    [465, 285],         ["normal"]],
        ["deepstone crypt",     "europa",           [900, 20, 1600],    [1150, 230],        ["normal"]],
        ["vault of glass",      "legend",           [0, 0, 0],          [450, 480],         ["normal", "master"]],
        ["vow of the disciple", "throne world",     [20, 20, 1800],     [960, 275],         ["normal", "master"]],
        ["kings fall",          "legend",           [0, 0, 0],          [1460, 480],        ["normal", "master"]],
        ["root of nightmares",  "neptune",          [20, 20, 1400],     [715, 405],         ["normal", "master"]],
        ["crotas end",          "legend",           [0, 0, 0],          [960, 305],         ["normal", "master"]]
    ],  
    [ ; dungeons
        ["shattered throne",        "dreaming city",    [920, 20, 1000],    [980, 280],     ["normal"]],
        ["pit of heresy",           "moon",             [900, 20, 1000],    [1330, 260],    ["normal"]],
        ["prophecy",                "legend",           [0,0,0],            [735, 780],     ["normal"]],
        ["grasp of avarice",        "eternity",         [0,0,0],            [550, 600],     ["normal", "master"]],
        ["duality",                 "moon",             [50, 1020, 1400],   [560, 690],     ["normal", "master"]],
        ["spire of the watcher",    "throne world",     [20, 540, 1000],    [410, 380],     ["normal", "master"]],
        ["ghosts of the deep",      "helm",             [0,0,0],            [385, 180],     ["normal", "master"]],
        ["warlords ruin",           "edz",              [1900, 540, 1200],  [1485, 550],    ["normal", "master"]]  
    ],
    [ ; playlist
        ["nightfall",           "vanguard", [0, 0, 0],  [690, 800],     ["hero", "legend", "master"]],
        ["grandmaster",         "vanguard", [0, 0, 0],  [1230, 805],    ["grandmaster"]             ],
        ["exotic rotator",      "legend",   [0, 0, 0],  [1185, 780],    ["normal", "legend"]        ],
        ["gambit",              "gambit",   [0, 0, 0],  [960, 530],     ["gambit"]                  ],
        ["trials of osiris",    "crucible", [0, 0, 0],  [390, 475],     ["trials"]                  ]   
    ],
    [ ; other 
        ["witch queen",             "throne world", [900, 1000, 1200],  [835,780],     ["arrival", "investigation", "ghosts", "communion", "mirror", "cunning", "last chance", "ritual"]],
        ["witch queen - legend",    "throne world", [900, 1000, 1200],  [960,780],     ["arrival", "investigation", "ghosts", "communion", "mirror", "cunning", "last chance", "ritual"]],
        ["lightfall",               "neptune",      [20, 540, 600],  [410, 400],     ["first contact", "under seige", "downfall", "breakneck", "on the verge", "no time left", "headlong", "desperate"]],
        ["lightfall - legend",      "neptune",      [20, 540, 600],  [535, 400],     ["first contact", "under seige", "downfall", "breakneck", "on the verge", "no time left", "headlong", "desperate"]]
    ]
]

; =============================================
; Functions - Auxiliary Methods
; =============================================
exitMenus() {       ; Exits any open menus
    Send "{F1}"
    Sleep 50
    Send "{esc}"
    Sleep 50
    Send "{F1}"
    Sleep 50
    Send "{esc}"
    Sleep 50
    Send "{esc}"
    Sleep 350       ; Wait for menus to close
}
swapLoadout(slot){  ; Swaps to the specified loadout slot
    if ( (not IsNumber(slot)) or slot < 1 or slot > 10 ) {      ; Check if slot is valid
        return
    }
    columnCount := 2                                            ; Number of columns in loadout menu
    slotWidth := 96                                             ; Width of loadout slot
    X := 150 + Mod(slot, columnCount) * slotWidth               ; X position of loadout slot
    Y := 389 + Floor( (slot - 1) / columnCount) * slotWidth     ; Y position of loadout slot

    Send "{F1}"         ; Open Inventory 
    Sleep 600           ; Wait for Inventory to open
    Send "{Left}"       ; Open Loadouts
    MouseMove( X, Y )   ; Select Loadout Slot
    Sleep 290           ; Wait for Loadouts to load
    Click               ; Apply Loadout  
    Send "{F1}"         ; Close Inventory
}
Director() {  ; Opens the Director Menu
    exitMenus()             ; Exit any open menus
    Send "{esc}"            ; Open Escape Menu
    MouseMove(700, 385)     ; Move mouse to Director button    
    Sleep 1100              ; Wait for Escape Menu to load     
    Click                   ; Click Director button
    ; TODO: Remove Launch Mission button if it exists
    Sleep 1200              ; Wait for Director to load                     
}
selectMission(missionsArr, diff) {
    ; Defining Mission Variables
    missionPlanet := missionsArr[2]
    missionScroll := missionsArr[3]
    missionClick := missionsArr[4]
    missionDifficulties := missionsArr[5]
    ; Open Director
    Director()                  
    ; Select Planet        
    planetCoordinates := Planets[missionPlanet]
    MouseMove(planetCoordinates[1], planetCoordinates[2])
    Sleep 100
    Click                              
    Sleep 50
    ; Scroll to Mission if needed
    if(missionScroll[3] > 0) {
        MouseMove(missionScroll[1], missionScroll[2])
        Sleep missionScroll[3]
    }
    ; Select Mission                     
    MouseMove(missionClick[1], missionClick[2])
    Sleep (1600 - missionScroll[3])     ; Wait for Mission to load
    Click                               ; Select Mission
    Sleep 1000                          ; Wait for Mission to load

    if( (not (diff <= 1 or diff > missionDifficulties.Length)) and DetectDifficulty() ) {
        ; Select Difficulty 
        Click
        Sleep 1000
        MouseMove(340, 280 + ((diff - 1) * 61))
        Sleep 100
        Click
        Sleep 50
    }
}
DetectDifficulty() {    ; Returns true if difficulty option exists (moves mouse to difficulty button)
    MouseMove(1500, 800)                            ; Move above Difficulty Button
    Sleep 50                                        ; Wait for mouse to move            
    before := PixelGetColor(1720, 835)              ; Get unselected color of Difficulty Button
    MouseMove(1500, 820)                            ; Move to Difficulty Button
    Sleep 100                                       ; Wait for mouse to move and shading to change                         
    after := PixelGetColor(1720, 835)               ; Get selected color of Difficulty Button
    return not (0 = StrCompare(before, after))      ; Return true if colors are different (difficulty option exists)
}
ClearCheckpoint(){
 
    ; check if difficulty select checkpoint exists
    reset := 0
    MouseMove(1350, 835)
    Sleep 50
    color := PixelGetColor(1350, 835)
    reset := (0 = StrCompare(color, "0xEDEDED")) ; true if matches
    
    ; check if non-difficulty select checkpoint exists
    if ( not reset) {
    ; check for diffuculty false positive
    hasDifficulty := DetectDifficulty()
    if ( not hasDifficulty) {
        ; check if checkpoint exists
        MouseMove(1420, 835)
        Sleep 50
        color := PixelGetColor(1420, 835)
        reset := (0 = StrCompare(color, "0xEDEDED")) ; true if matches
        }
    }
    
    ; reset checkpoint if exists
    if (reset) {
        Send "{f Down}"
        Sleep 2200
        Send "{f Up}"
        Sleep 50
    }
}
LaunchMission() {       ; Launches the selected mission
    MouseMove(1420, 890)    ; Move to Launch Button
    Sleep 50                
    Click                   ; Click Launch Button
    Sleep 4500              ; Wait for Mission to Launch
}
FirstIndexArray(arr) {  ; Returns the an array of the first indexes of a 2D array
    firstIndexArr := []
    loop arr.Length {
        firstIndexArr.Push(arr[A_Index][1])
    }
    return firstIndexArr
}

; =============================================
; GUI - User Interface
; =============================================
MyGui := Gui("+AlwaysOnTop", "Destiny 2 Mission Launcher")
; Row 1
MissionType := MyGui.AddDropDownList("xm w100 Center Uppercase Choose" String(Settings[SetMissionType]), MissionTypes)
Mission := MyGui.AddDropDownList("yp w180 Center Uppercase Choose" String(Settings[SetMission]), FirstIndexArray(Missions[MissionType.Value])) 
Difficulty := MyGui.AddDropDownList("yp w120 Center Uppercase Choose" String(Settings[SetDifficulty]), Missions[MissionType.Value][Mission.Value][5])
MissionType.OnEvent("Change", MissionUpdate)
Mission.OnEvent("Change", DifficultyUpdate)
; Row 2
MyGui.AddText("xm w120 Left", "   Entrance Loadout Slot: ")
EntranceSlot := MyGui.AddEdit("yp w40 Center Number Limit2")
MyGui.AddUpDown("Range0-10", Settings[SetEntranceSlot]) ; appends to the last control
MyGui.AddText("yp w10", "")
KeepCheckpoint := MyGui.AddCheckBox("Checked" String(Settings[SetKeepCheckpoint]) " w140 yp", "Keep Checkpoint")
DefaultSettingBtn := MyGui.AddButton("yp w80", "Reset Settings")
DefaultSettingBtn.OnEvent("Click", DefaultSettings)
; Row 3
MyGui.AddText("xm w120 Left ", "   Primaries Loadout Slot: ")
PrimariesSlot := MyGui.AddEdit("yp w40 Center Number Limit2")
MyGui.AddUpDown("Range0-10", Settings[SetPrimariesSlot]) ; appends to the last control
MyGui.AddText("yp w10", "")
PrimariesSwap := MyGui.AddCheckBox("Checked" String(Settings[SetPrimariesSwap]) " w140 yp", "Enable Primaries Swap")
SaveSettingBtn := MyGui.AddButton("yp w80", "Save Settings")
SaveSettingBtn.OnEvent("Click", SaveSettings)
MyGui.Show()

; =============================================
; GUI - Event Handlers
; =============================================
MissionUpdate(*){ ; Updates Mission and Difficulty dropdowns
    Mission.Delete()
    Mission.Add(FirstIndexArray(Missions[MissionType.Value]))
    Mission.Choose(1)
    DifficultyUpdate()
}
DifficultyUpdate(*){ ; Updates Difficulty dropdown
    Difficulty.Delete()
    Difficulty.Add(Missions[MissionType.Value][Mission.Value][5])
    Difficulty.Choose(1)
}
DefaultSettings(*) { ; Sets the current settings to the default values
    MissionType.Choose(1)
    Mission.Choose(1)
    Difficulty.Choose(1)
    EntranceSlot.Text := 0
    PrimariesSlot.Text := 0
    KeepCheckpoint.Value := 0
    PrimariesSwap.Value := 0
}   
SaveSettings(*) { ; Saves the Current Settings to the file
    ; Read File
    myAHK := FileRead(A_ScriptFullPath)

    ; Re-create with new Settings String
    preSettings := SubStr(myAHK, 1, InStr(myAHK, "Settings := [")-1)
    postSettings := SubStr(myAHK, InStr(myAHK, "'SAVED']"))
    newSettings :=  "Settings := [" String(MissionType.Value) ", " String(Mission.Value) ", " String(Difficulty.Value) ", " String(KeepCheckpoint.Value) ", " String(PrimariesSwap.Value) ", " String(EntranceSlot.Value) ", " String(PrimariesSlot.Value) ","

    ; Overwrite File with New Settings String
    FileDelete(A_ScriptFullPath)
    FileAppend(preSettings, A_ScriptFullPath)
    FileAppend(newSettings, A_ScriptFullPath)
    FileAppend(postSettings, A_ScriptFullPath)
}