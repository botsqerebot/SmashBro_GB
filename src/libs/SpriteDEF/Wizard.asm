wizardSpriteData:
wizardHead:
    ; Y, X, Tile ID
    db 0, 0, 0            ; Left top
    db 0, 8, 1            ; Right top
wizardBottom:
    db 8, 0, 2            ; Left
    db 8, 8, 3            ; Right

DEF WizardNumSprites equ 16 * 4


wizardMoves:
    ;Move id, damage, type flags
wizardFireball:
    db 0
    db 40
    db MOVE_ATTACK
wizardDefence:
    db 1
    db 0 
    db MOVE_DEFEND
wizardIceBlast:
    db 2
    db 20
    db MOVE_ATTACK