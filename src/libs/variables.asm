section "Variables", wram0

;A variable with 8 bits
VariableExample: ds 1

;Current frames. Max 255 (256) frames counted
wFramesCounter: ds 1

;--------------------------------------------------------
;   Bit 0-3:    Buttons
;   Bit 4-7:    DPad

;   Bit 0   A       Mask $01
;   Bit 1   B       Mask $02
;   Bit 2   Select  Mask $04
;   Bit 3   Start   Mask $08
;   Bit 4   Right   Mask $10
;   Bit 5   Left    Mask $20
;   Bit 6   Up      Mask $40
;   Bit 7   Down    Mask $80
currentInput: ds 1

;--------------------------
;0 = Start Screen
;1 = Walking Screen
gameState: ds 1

;0 = False
;nz (Not zero) = true
readyLoadSprites: ds 1

;Says if the obj sprite should be flipped
;0 = False
;1 = Up
;2 = Down
;3 = Left
;4 = Right
FlipSpritesDir: ds 1

;Sets the last direction that the character is facing
;0 = False
;1 = Up
;2 = Down
;3 = Left
;4 = Right
CurrentFlipSpritesDir: ds 1


playerX: ds 1
playerY: ds 1

;This is the currently selected character from the player.
;IDs are stored in the CharacterID file
playerSelectedCharacter: ds 1