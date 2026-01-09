section "Input Buttons", ROM0

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

;ldh accesess the higher places in ram with hardware variables, $FF00 - $FFFF
InputButton:
    ;Read d-pad
    ld a, JOYP_GET_CTRL_PAD     ;Loads the number that we send to the joypad register to ask for dpad
    call .onenibble
    swap a                      ;Swaps the lower 4 bits with the higher bits so we can have the whole input in one byte
    ld b, a                     ;Store the input in b so we can accesess the other buttons

    ;Read buttons    
    ld a, JOYP_GET_BUTTONS      ;Loads the number that we send to the joypad register to ask for buttons
    call .onenibble
    or b                        ;Combines the inputs into one single byte to have everything 
    cpl                         ; Invert the bits so 1 is pressed

    ld [currentInput], a    ;Stores the current input

    ret


;Only gives out the 4 important bits of input 
.onenibble:
    ldh [rJOYP], a              ;sends a request to the joypad register with either the value for the dpad or buttons, this will give a return
    call .knownRet              ;a function that just take time so that the output stabalize, takes 10 cycles
    ldh a, [rJOYP]              ;fetch the joypad multible times until it gets stable
    ldh a, [rJOYP]
    ldh a, [rJOYP]
    and $0F                     ;0F = 00001111, The "and" masks the bits. Will only return 1 in the byte if both bits are 1. This will make it only keep the button inputs and remove the command we used to specify the buttons or dpad
    ret
    
.knownRet:
    ret