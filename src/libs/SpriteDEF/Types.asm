DEF MOVE_ATTACK equ 1
DEF MOVE_DEFEND equ 2
DEF MOVE_FREEZE equ 3
DEF MOVE_HEAL   equ 4

DEF WALKING     equ 0
DEF FLYING      equ 1
DEF HOPPING     equ 2

CharacterMovementTable:
    db 0                ; ID 0 - NONE (No characters on id 0)
    db HOPPING           ; ID 1 - Wizard
    db HOPPING          ; ID 2 - 
    db HOPPING          ; ID 3 - 