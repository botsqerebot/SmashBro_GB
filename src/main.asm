INCLUDE "include.asm"

section "Header", ROM0[$100]

    jp Entrypoint

    ds $150 - @, 0 ; Make room for the header

Entrypoint: 
    ; Turn off audio
    ld a, 0
    ld [rNR52], a

    ld a, 0
    ld [gameState], a               ;Sets the game state to the start screen
    ld [readyLoadSprites], a
    ld [wFramesCounter], a

    ld a, 4
    ld [FlipSpritesDir], a
    ld [CurrentFlipSpritesDir], a

    ld a, 1                         ;Selects the wizard as the playable character
    ld [playerSelectedCharacter], a

    ;Init of the player
    ld a, 50
    ld [playerX], a
    ld [playerY], a
    
    call WaitVBlank

;My main loop of the game. Basically a main(){} in c
MainLoop:
    ;Wait for vblank
    ld a, [rLY]
    cp 144
    jp c, MainLoop

    ld a, [wFramesCounter]
    inc a
    ld [wFramesCounter], a
    cp 60
    call z, ResetCounter


    call InputButton        ;Takes the input

    ld a, [gameState]
    cp 0
    call z, StartScreen_State
    cp 1
    call z, Playing_State

.waitVBlankEnd:
    ld a, [rLY]
    cp 144
    jp nc, .waitVBlankEnd

    jp MainLoop 


PrintA:
    deb_msg A_msg
    ret

A_msg:
    db "A=%A%", 0

ResetCounter:
    ld a, 0
    ld [wFramesCounter], a
    ret