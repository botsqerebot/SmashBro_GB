StartScreen_State:
    ld a, [currentInput]
    bit 0, a
    jp nz, GoToGame_State

    ret

GoToGame_State:
    ld a, 1
    ld [gameState], a
    
    call WaitVBlank

    ret
