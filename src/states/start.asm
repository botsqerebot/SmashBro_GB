StartScreen_State:
    ld a, [currentInput]
    bit 0, a
    jp nz, GoToGame_State

    ret



GoToStart_State:
    ld a, 0
    ld [gameState], a
    ld [readyLoadSprites], a

    call WaitVBlank
    ret