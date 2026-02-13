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
    jr z, GoRight.MoveBackgroundRight
    jr nz, GoRight.MovePlayerRight
    
    ret

.MovePlayerRight:
    ld a, [playerX]
    inc a
    ld [playerX], a
    ret

.MoveBackgroundRight:
    ld a, [rSCX]
    inc a
    ld [rSCX], a
    ret


StartJump:
    ld a, [currentTileStandingOn]
    cp NoWalkTiles
    ret nc       ; Return if in air (currentTileStandingOn < NoWalkTiles)

    debug_message "Jumping"
    ld a, -10
    ld [playerVY], a
    ret

UpdateVerticalMovement:
    ld a, [playerVY]

    cp 128
    jr nc, .movingUp

    cp 4
    jr c, .applyGravity
    ld a, 4
    ld [playerVY], a
    jr .applyPosition

.movingUp:
    ld a, [playerVY]
    inc a
    ld [playerVY], a
    jr .applyPosition

.applyGravity:
    ld a, [playerVY]
    inc a
    ld [playerVY], a
.applyPosition:
    ld a, [playerVY]
    ld b, a

    ld a, [playerY]
    add a, b
    ld [playerY], a
    
    ; Check if we're now on or below ground
    call checkCollision

    ld a, [currentTileStandingOn]
    call PrintA

    ld a, [currentTileStandingOn]
    cp NoWalkTiles
    ret nc       ; Return if still in air
    
    ; We hit ground - snap to ground level and stop falling
    ld a, [playerY]
    and $F8     ; Align to 8-pixel grid (clear lower 3 bits)
    ld [playerY], a
    xor a
    ld [playerVY], a    ; Stop vertical movement
    
    ret
    
