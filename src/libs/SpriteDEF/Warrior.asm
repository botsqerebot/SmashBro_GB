warriorSpriteData:
warriorHead:
    ; Y, X, Tile ID
    db 0, 0, 0            ; Left top
    db 0, 8, 1            ; Right top
warriorBottom:
    db 8, 0, 2            ; Left
    db 8, 8, 3            ; Right

DEF warriorNumSprites equ 16 * 4

warriorAbilities:
    ;Moving Type, hp, etc
    db HOPPING   ;MovingStyle
    db 200       ;HP


warriorMoves:
    ;Move id, Name, damage,speed px, durration (frames), type flags
warriorSword:
    db 0
    db "Sword"
    db 60
    db 0
    db 10
    db MOVE_ATTACK
warriorDefence:
    db 1
    db "Sheild"
    db 0 
    db 0
    db 30
    db MOVE_DEFEND
warriorIceBlast:
    db 2
    db "Ice Blast"
    db 20
    db 10
    db 30
    db MOVE_ATTACK