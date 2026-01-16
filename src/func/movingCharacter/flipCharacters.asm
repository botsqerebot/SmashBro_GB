flipLeftFacing:
    ld a, [playerX]
    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X
    add 8
    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X
    ret

flipRightFacing:
    ld a, [playerX]
    ld [$FE01], a ; Sprite 0 X
    ld [$FE09], a ; Sprite 2 X
    add 8
    ld [$FE05], a ; Sprite 1 X
    ld [$FE0D], a ; Sprite 3 X
    ret

