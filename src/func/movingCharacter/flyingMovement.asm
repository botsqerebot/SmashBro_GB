MoveUp:
    ld a, [playerY]
    dec a
    ld [playerY], a

    ret

MoveDown:
    ld a, [currentTileStandingOn]
    cp NoWalkTiles
    ret z
    ld a, [playerY]
    inc a
    ld [playerY], a

    ret
MoveLeft:
    ld a, [playerX]
    inc a
    ld [playerX], a

    ld a, 3
    ld [FlipSpritesDir], a

    ret

MoveRight:
    ld a, 4
    ld [FlipSpritesDir], a

    ld a, [playerX]
    cp 140
    jr z, GoRight.MoveBackgroundRight
    jr nz, GoRight.MovePlayerRight

    ret

.MoveBackgroundRight:
    ld a, [rSCX]
    inc a
    ld [rSCX], a

    ret

.MovePlayerRight:
    ld a, [playerX]
    inc a 