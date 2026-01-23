DEF NoWalkTiles equ 9

checkCollision:
    call getPlayerTileX
    call getPlayerTileY
    call getTileID
    ret

getPlayerTileY:
    ld a, [rSCY]
    ld b, a
    ld a, [playerY]
    add b
    srl a
    srl a
    srl a
    ld [playerTileY], a
    ret

getPlayerTileX:
    ld a, [rSCX]
    ld b, a
    ld a, [playerX]
    add b
    srl a
    srl a
    srl a
    ld [playerTileX], a
    ret

getTileID:
    ;Formula to get the tile ID:    $9800 + (tileY * 32) + tileX
    ld h, 0
    ld a, [playerTileY]
    ld l, a

    ;multiply by 32 (shift left 5 times)
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl

    ;Add tile x
    ld d, 0
    ld a, [playerTileX]
    ld e, a
    add hl, de              ; HL = (tileY * 32) + tileX

    ld de, $9800
    add hl, de

    ld a, [hl]
    ld [currentTileStandingOn], a
    ;call PrintA

    ret
