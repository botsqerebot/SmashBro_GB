GoLeft:
    ld a, [playerX]
    inc a
    ld [playerX], a

    ld a, 3
    ld [FlipSpritesDir], a

    ret

GoRight:
    ld a, [playerX]
    dec a
    ld [playerX], a

    ld a, 4
    ld [FlipSpritesDir], a
    
    ret

CharacterJump:
    ;Set jump height to 70 pixels
    ld a, 70
    ld [pixelsLeftHopping], a

    ld a, [playerY]
    dec a 
    ld [playerY], a

    ret


ContinueCharacterJump:
    ld a, [pixelsLeftHopping]
    dec a
    ld [pixelsLeftHopping], a

    ld a, [playerY]
    dec a
    ld [playerY], a

    ret




SetJumpHeight:
    ld a, 10
    ld [pixelsLeftHopping], a 
    ld [currentlyJumping], a