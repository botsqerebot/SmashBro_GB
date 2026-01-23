WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank
    
    ;Turn off lcd to change the graphics
    ld a, 0
    ld [rLCDC], a

    ;changes what to load depending on the gamestate
    ld a, [gameState]
    cp 0
    call z, LoadStartScreen
    cp 1
    call z, SetupChosenMap

    call ClearOAM

    ;Loads the sprite textures to memory if sprites are now viewable
    ld a, [readyLoadSprites]
    cp 1
    ld de, Wizard
    ld bc, WizardNumSprites
    call z, loadPlayerSprites

    ld de, Wizard
    ld bc, WizardNumSprites
    call z, loadCPUSprites

    ld b, 4
    ld de, wizardSpriteData
    call z, SetupSpriteData

    
    
    ;Turn on lcd
    ld a, LCDC_ON | LCDC_BG_ON |LCDC_OBJ_ON
    ld [rLCDC], a


    ;Set pallette for background
    ld a, %11100100
    ld [rBGP], a

    ;Set object pallette and sprite pallette
    ld a, %11100100
    ld [rOBP0], a
    ld [rOBP1], a

    ret



;-------------------------------------------------------------------------------

;---------------------------------------------------------------------------------
;Loading the main game world map (outside)
SetupChosenMap:
    ld a, [selectedBattleMap]
    cp 0
    call z, LoadBattleArena1
    cp 1
    call z, LoadChineseStadium
    ret
LoadWorldMap:
    ;Copy tile data
    ld de, First
    ld hl, $9000
    ld bc, 4 * 16
    call CopyTiles

    ;Copy tile map
    ld de, WorldTileMap
    ld hl, $9800
    ld bc, WorldTileMapWidth * WorldTileMapHeight
    call CopyTilemap

    ret

LoadBattleArena1:
    ;Copy tile data
    ld de, First
    ld hl, $9000
    ld bc, 4 * 16
    call CopyTiles

    ;Copy tile map
    ld de, BattleArena
    ld hl, $9800
    ld bc, BattleArenaWidth * BattleArenaHeight
    call CopyTilemap

    ret

LoadChineseStadium:
    ;Copy tile data
    ld de, ChineseStadionTiles
    ld hl, $9000
    ld bc, 11 * 16
    call CopyTiles

    ;Copy tile map
    ld de, ChineseStadium
    ld hl, $9800
    ld bc, ChineseStadiumWidth * ChineseStadiumHeight
    call CopyTilemap

    ret

;Loads the menu screen, also called start screen
LoadStartScreen:
    ;Copy tile data
    ld de, HelloWorld_Tiles
    ld hl, $9000
    ld bc, HelloWorld_TilesEnd - HelloWorld_Tiles
    call CopyTiles

    ;Copy tile map
    ld de, HelloWorldmap
    ld hl, $9800
    ld bc, HelloWorldmapEnd - HelloWorldmap
    call CopyTilemap

    ret

CopyTiles:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTiles
    ret ;Returns to the initial caller of the function
    
CopyTilemap:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTilemap
    ret
