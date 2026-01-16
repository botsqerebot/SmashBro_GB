ClearOAM:
    ld a, 0
    ld b, 160
    ld hl, STARTOF(OAM)
ClearOAMLoop:
    ld [hli], a
    dec b
    jp nz, ClearOAMLoop
    
    ret


BasicMovement:
    ld a, [currentInput]
    bit 6, a
    call nz, MoveUp

    ld a, [currentInput]
    bit 7, a
    call nz, MoveDown

    ld a, [currentInput]
    bit 4, a
    call nz, MoveLeft

    ld a, [currentInput]
    bit 5, a
    call nz, MoveRight

    ld a, [playerX]
    call ChangePlayerOAMX
    
    ld a, [playerY]
    call ChangePlayerOAMY

    ret

MoveUp:
    ld a, [playerY]
    dec a
    ld [playerY], a

    ;call ChangePlayerOAMY
    ret

MoveDown:
    ld a, [playerY]
    inc a
    ld [playerY], a

    ;call ChangePlayerOAMY
    ret
MoveLeft:
    ld a, [playerX]
    inc a
    ld [playerX], a

    ;call ChangePlayerOAMX
    ret

MoveRight:
    ld a, [playerX]
    dec a
    ld [playerX], a

    ;call ChangePlayerOAMX
    ret

ChangePlayerOAMY:
    ;ld b, a
    ld [$FE00], a ; Sprite 0 Y
    ld [$FE04], a ; Sprite 1 Y
    add 8
    ld [$FE08], a ; Sprite 2 Y
    ld [$FE0C], a ; Sprite 3 Y
    ;ld a, b
    ret

ChangePlayerOAMX:
    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X
    add 8
    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X
    ret