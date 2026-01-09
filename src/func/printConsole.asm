;To write a debug message to emulicious do:
;   debug_message "What you want to write in anperstands"

MACRO debug_message
    ld      d,d
    jr      :+
    dw      $6464           ; Two ASCII characters: "dd"
    dw      $0000           ; Identifier for this debug message type
    db      \1
:
ENDM

MACRO deb_msg
        ld      d,d
        jr      :+
        dw      $6464           ; Two ASCII characters: "dd"
        dw      $0001           ; Identifier for this debug message type
        dw      \1
        dw      bank(\1)
:
endm

