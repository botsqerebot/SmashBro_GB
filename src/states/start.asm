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
    bit 6, a
    call z, StartScreen_State.incStartScreenSelection

    ld a, [currentInput]
    bit 7, a
    call z, StartScreen_State.decStartScreenSelection

    
    call StartScreen_State.changeArrowLocation
    
    ret

.viewCharacterSelectScreen:
    ret

.viewMapSelectScreen:
    ret

.incStartScreenSelection:
    ld a, [startScreenMenuSelection]
    cp 2
    ret z

    ld a, [currentInput]
    and %10000000
    ld b, a
    ld a, [lastInput]
    and %10000000
    cp b
    ret z
    

    ld a, [startScreenMenuSelection]
    inc a
    ld [startScreenMenuSelection], a
    ret

.decStartScreenSelection:
    ld a, [startScreenMenuSelection]
    cp 0
    ret z

    ld a, [currentInput]
    and %01000000
    ld b, a
    ld a, [lastInput]
    and %01000000
    cp b
    ret z

    ld a, [startScreenMenuSelection]
    dec a
    ld [startScreenMenuSelection], a
    ret
    

.changeArrowLocation
    ld de, StartScreen_State.startScreenArrowLocations
    call StartScreen_State.setSelection
    
    ld b, 1
    ld hl, _OAMRAM
    jp StartScreen_State.LoadArrowLoop
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