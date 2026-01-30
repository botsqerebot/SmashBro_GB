StartScreen_State:
    ld a, [startScreenState]
    cp 0
    jr z, StartScreen_State.viewStartScreen
    cp 1
    jr z, StartScreen_State.viewCharacterSelectScreen
    cp 2
    jr z, StartScreen_State.viewMapSelectScreen

    jr StartScreen_State.viewStartScreen
    ret



.viewStartScreen:
    ld a, [currentInput]
    bit 7, a
    call nz, StartScreen_State.incStartScreenSelection

    ld a, [currentInput]
    bit 6, a
    call nz, StartScreen_State.decStartScreenSelection

    ld a, [currentInput]
    bit 0, a
    call nz, StartScreen_State.passToCorrectState

    ;ld a, [startScreenMenuSelection]
    ;cp 2
    ;call z, StartScreen_State.startGameCheck


    
    call StartScreen_State.changeArrowLocation
    
    ret

.viewCharacterSelectScreen:
    ld a, [currentInput]
    bit 7, a
    call nz, StartScreen_State.incStartScreenSelection

    ld a, [currentInput]
    bit 6, a
    call nz, StartScreen_State.decStartScreenSelection

    ld a, [currentInput]
    bit 0, a
    call nz, StartScreen_State.characterSelectionSet

    ld a, [currentInput]
    bit 1, a
    call nz, GoToGame_State

    call StartScreen_State.changeArrowLocation

    ret

.characterSelectionSet:
    ld a, [startScreenMenuSelection]
    ld b, a
    cp 0
    call z, StartScreen_State.setCharacter0
    ld a, b
    cp 1
    call z, StartScreen_State.setCharacter1

    ret

.setCharacter0:
    ld a, WizardID
    ld [playerSelectedCharacter], a 
    ret

.setCharacter1:
    ld a, WarriorID
    ld [playerSelectedCharacter], a 
    ret

.viewMapSelectScreen:
    ret

.passToCorrectState:
    ld a, [startScreenMenuSelection]
    ld b, a
    cp 0
    jp z, GoToSelectCharacter_State
    ld a, b
    cp 1
    jp z, GoToSelectMap_State
    ld a, b
    cp 2
    jp z, GoToGame_State
    ret



.incStartScreenSelection:
    ld a, [startScreenMenuSelection]
    cp 2
    ret z

    ld a, [lastInput]
    bit 7, a
    ret nz

    ld a, [startScreenMenuSelection]
    inc a
    ld [startScreenMenuSelection], a
    ret

.decStartScreenSelection:
    ld a, [startScreenMenuSelection]
    cp 0
    ret z

    ld a, [lastInput]
    bit 6, a
    ret nz

    ld a, [startScreenMenuSelection]
    dec a
    ld [startScreenMenuSelection], a
    ret
    

.changeArrowLocation:
    ld a, [startScreenState]
    ld b, a
    cp 0
    call z, StartScreen_State.setStartScreenLocation
    ld a, b
    cp 1
    call z, StartScreen_State.setCharacterSelectLocation
    
    
    ld b, 1
    ld hl, _OAMRAM
    jp StartScreen_State.LoadArrowLoop
    ret

.setStartScreenLocation:
    ld de, StartScreen_State.startScreenArrowLocations
    call StartScreen_State.setSelection
    ret

.setCharacterSelectLocation:
    ld de, StartScreen_State.characterSelectArrowLocations
    call StartScreen_State.setSelection
    ret

.LoadArrowLoop:
    ld a, [de]
    inc de
    ld [hli], a
 
    ;X position
    ld a, [de]
    inc de
    ld [hli], a

    ;Tile ID
    ld a, 0
    ld [hli], a
    ret

.startScreenArrowLocations: 
    db 9 * 8, 6 * 8
    db 11 * 8, 6 * 8
    db 16 * 8, 6 * 8

.characterSelectArrowLocations:
    db 6 * 8, 8 * 8
    db 8 * 8, 8 * 8
    db 16 * 8, 2 * 8

.setSelection
    ld a, [startScreenMenuSelection]
.setSelectionLoop
    cp 0
    ret z

    inc de
    inc de

    dec a

    jr StartScreen_State.setSelectionLoop
    



GoToStart_State:
    ld a, 0
    ld [gameState], a
    ld [startScreenState], a
    ld [readyLoadSprites], a
    ld [rSCY], a
    ld [rSCX], a

    call WaitVBlank
    ret

GoToSelectCharacter_State:
    ld a, 0
    ld [gameState], a
    ld [readyLoadSprites], a
    ld [rSCY], a
    ld [rSCX], a

    ld a, 1
    ld [startScreenState], a

    call WaitVBlank
    ret

GoToSelectMap_State:
    ld a, 0
    ld [gameState], a
    ld [readyLoadSprites], a
    ld [rSCY], a
    ld [rSCX], a

    ld a, 2
    ld [startScreenState], a
    
    call WaitVBlank
    ret