;Usage instruction:
;------------
;ld de, (The definition of the sprite youll use, x, y and tile id)
;ld b, (The total sprites for the defenition)
SetupSpriteData:
    ld hl, _OAMRAM
    jp LoadSpriteLoop

LoadSpriteLoop:
    ;Y position
    ld a, [de]
    ld c, a
    ld a, [CharacterYOffset]
    add c
    inc de
    ld [hli], a

    ;X position
    ld a, [de]
    ld c, a
    ld a, [CharacterXOffset]
    add c
    inc de
    ld [hli], a

    ;Tile ID
    ld a, [de]
    inc de
    ld [hli], a

    ld a, [FlipSpritesDir]
    cp 3
    call z, flipSprites
    call nz, notFlipSprites

    dec b
    jr nz, LoadSpriteLoop
    ret


flipSprites:
    ;Attributes (0 right now)
    ld a, [B_OAM_YFLIP]
    ld [hli], a
    ret
notFlipSprites:
    xor a
    ld [hli], a
    ret
