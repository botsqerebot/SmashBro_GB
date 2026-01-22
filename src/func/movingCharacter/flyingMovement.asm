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
    ld a, [playerX]
    dec a
    ld [playerX], a

    ld a, 4
    ld [FlipSpritesDir], a
    
    ret
