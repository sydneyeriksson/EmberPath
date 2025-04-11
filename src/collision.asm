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
; \1 is global x_coordinate
; \2 is global y_coordinate
macro find_overlapping_tile_ID
    ; calculate what tile the sprite is on
    ld a, \1
    srl a
    srl a
    srl a
    sla a
    sla a
    sla a
    ld b, a

    ld a, \2
    srl a
    srl a0
    srl a
    sla a
    sla a
    sla a
    ld c, a

    ; multiply y * 32
    ld hl, c
    sla hl
    sla hl
    sla hl
    sla hl
    sla hl
    
    ; add (y * 32) + x
    add hl, b
    
    add hl, $8000

    

    ; check vram for tile ID
    ; tilemap + calculated number    
endm