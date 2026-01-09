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