INCLUDE "include.asm"

section "Header", ROM0[$100]

    jp Entrypoint

    ds $150 - @, 0 ; Make room for the header
