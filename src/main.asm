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
    
    call WaitVBlank

;My main loop of the game. Basically a main(){} in c
MainLoop:
    ;Wait for vblank
    ld a, [rLY]
    cp 144
    jp c, MainLoop

    call InputButton        ;Takes the input

    ld a, [gameState]
    cp 0
    call z, StartScreen_State
    cp 1
    call z, Playing_State


    jp MainLoop 


PrintA:
    deb_msg A_msg
    ret

A_msg:
    db "A=%A%", 0
