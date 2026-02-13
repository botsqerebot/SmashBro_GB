Playing_State:
    call checkCollision
    
    ld a, [currentInput]
    bit 3, a
    jp nz, GoToStart_State

    call MovingCharacterTypes
    ;call UpdateVerticalMovement


    ret

GoToGame_State:
    ld a, 1
    ld [gameState], a
    ld [readyLoadSprites], a
    
    call WaitVBlank

    

    ret