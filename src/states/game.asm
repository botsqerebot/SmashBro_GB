
Playing_State:
    ld a, [currentInput]
    bit 3, a
    jp nz, GoToStart_State

    ret

GoToStart_State:
    ld a, 0
    ld [gameState], a

    call WaitVBlank
    ret
