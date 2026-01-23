GoLeft:
    ld a, 4
    ld [FlipSpritesDir], a


    ld a, [playerX]
    cp 20
    jr z, GoLeft.MoveBackgroundLeft
    jr nz, GoLeft.MovePlayerLeft

    ret

.MovePlayerLeft:
    ld a, [playerX]
    dec a
    ld [playerX], a
    ret

.MoveBackgroundLeft:
    ld a, [rSCX]
    dec a
    ld [rSCX], a
    ret

GoRight:
    ld a, 3
    ld [FlipSpritesDir], a

    ld a, [playerX]
    cp 140
    jr z, GoRight.MoveBackgroundLeft
    jr nz, GoRight.MovePlayerLeft
    
    ret

.MovePlayerLeft:
    ld a, [playerX]
    inc a
    ld [playerX], a
    ret

.MoveBackgroundLeft:
    ld a, [rSCX]
    inc a
    ld [rSCX], a
    ret


CharacterJump:
    ;Set jump height to 70 pixels
    ld a, [hoppingHeight]
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
    call nc, FallingDown
    ret

FallingDown:
    ld a, [playerY]
    inc a
    ld [playerY], a
    ret