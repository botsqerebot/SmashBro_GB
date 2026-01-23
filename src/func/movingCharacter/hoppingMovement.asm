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
    ld a, 30
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

ReadyFallingDown:
    ld a, [pixelsLeftHopping]
    cp 0
    call z, CheckCollisionFallingDown
    ret

CheckCollisionFallingDown:
    ld a, [currentTileStandingOn]
    cp NoWalkTiles
    call nz, FallingDown
    ret

FallingDown:
    ld a, [playerY]
    inc a
    ld [playerY], a
    ret