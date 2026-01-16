wizardSpriteData:
wizardHead:
    ; Y, X, Tile ID
    db 0, 0, 0            ; Left top
    db 0, 8, 1            ; Right top
wizardBottom:
    db 8, 0, 2            ; Left
    db 8, 8, 3            ; Right

DEF WizardNumSprites equ 16 * 4

wizardAbilities:
    ;Moving Type, hp, etc
    db FLYING   ;MovingStyle
    db 160      ;HP


wizardMoves:
    ;Move id, Name, damage,speed px, durration (frames), type flags
wizardFireball:
    db 0
    db "FireBall"
    db 40
    db 5
    db 60
    db MOVE_ATTACK
wizardDefence:
    db 1
    db "Sheild"
    db 0 
    db 0
    db 30
    db MOVE_DEFEND
wizardIceBlast:
    db 2
    db "Ice Blast"
    db 20
    db 10
    db 30
    db MOVE_ATTACK