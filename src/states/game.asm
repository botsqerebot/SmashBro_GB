Playing_State:
    ld a, [currentInput]
    bit 3, a
    jp nz, GoToStart_State

    ret

GoToGame_State:
    ld a, 1
    ld [gameState], a
    ld [readyLoadSprites], a
    
    call WaitVBlank

    ret