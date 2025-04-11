include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

; \1 is sprite 
; returns global x coordinate in b, y coordinate in c
macro global_coordinates
    ; Find global x coordinate
    Copy a, [\1 + OAMA_X]
    ld b, a
    ld a, [rWX]
    add a, b
    sub a, 8
    ld b, a

    ; find global y coordinate
    Copy c, [\1 + OAMA_Y]
    ld c, a
    ld a, [rWX]
    add a, c
    sub a, 16
    ld c, a
endm

; make macro to check if tile next to sprite is collision
    ; if moving right:
        ; add 8 to x coordinate and check that tile
    ; if moving left:
        ; dec and 