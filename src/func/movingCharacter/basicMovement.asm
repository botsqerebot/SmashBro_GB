ClearOAM:
    ld a, 0
    ld b, 160
    ld hl, STARTOF(OAM)
ClearOAMLoop:
    ld [hli], a
    dec b
    jp nz, ClearOAMLoop
    
    ret

MovingCharacterTypes:
    call MovingType
    cp FLYING
    jp z, FlyingMovement
    cp WALKING
    ;jp z, WalkingMovement
    cp HOPPING
    jp z, HoppingMovement

    ;fallBack
    jp FlyingMovement

MovingType:
    ld a, [playerSelectedCharacter]
    ld hl, CharacterMovementTable
    ld d, 0
    ld e, a
    add hl, de
    ld a, [hl]
    ret

HoppingMovement:
    ;First check if the character is currently jumping
    ld a, [pixelsLeftHopping]
    cp 0
    call nz, ContinueCharacterJump
    
    ;Checks if last input also was up
    ld a, [currentInput]
    and %01000000
    ld b, a
    ld a, [lastInput]
    and %01000000
    cp b
    call nz, CharacterJump
    call z, ReadyFallingDown

    ld a, [currentInput]
    bit 7, a
    ;call nz, MoveDown

    ld a, [currentInput]
    bit 4, a
    call nz, GoRight

    ld a, [currentInput]
    bit 5, a
    call nz, GoLeft

    ld a, [playerX]
    call ChangePlayerOAMXAdv
    
    ld a, [playerY]
    call ChangePlayerOAMY

    ret

FlyingMovement:
    ld a, [currentInput]
    bit 6, a
    call nz, MoveUp

    ld a, [currentInput]
    bit 7, a
    call nz, MoveDown

    ld a, [currentInput]
    bit 4, a
    call nz, GoRight

    ld a, [currentInput]
    bit 5, a
    call nz, GoLeft

    ld a, [playerX]
    call ChangePlayerOAMXAdv
    
    ld a, [playerY]
    call ChangePlayerOAMY

    ret


ChangePlayerOAMY:
    ld [$FE00], a ; Sprite 0 Y
    ld [$FE04], a ; Sprite 1 Y
    add 8
    ld [$FE08], a ; Sprite 2 Y
    ld [$FE0C], a ; Sprite 3 Y
    ret

ChangePlayerOAMX:
    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X
    add 8
    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X
    ret

ChangePlayerOAMXAdv:
    ld a, [FlipSpritesDir]
    cp 4
    jp z, MoveSpritesLeft

    ld a, [FlipSpritesDir]
    cp 3
    jp z, MoveSpritesRight

    ret

MoveSpritesLeft:
    ld a, [playerX]

    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X
    add 8
    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X

    ld a, $20
    ld [$FE03], a ; Sprite 0 X
    ld [$FE07], a ; Sprite 1 X
    ld [$FE0B], a ; Sprite 2 X
    ld [$FE0F], a ; Sprite 3 X

    ld a, 3
    ld [CurrentFlipSpritesDir], a 

    ret

MoveSpritesRight:
    ld a, [playerX]

    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X
    add 8
    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X

    ld a, $00
    ld [$FE03], a ; Sprite 0 X
    ld [$FE07], a ; Sprite 1 X
    ld [$FE0B], a ; Sprite 2 X
    ld [$FE0F], a ; Sprite 3 X

    ld a, 4
    ld [CurrentFlipSpritesDir], a 

    ret


