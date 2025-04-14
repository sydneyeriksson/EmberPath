include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"
include "src/sprites.inc"


section "collision", rom0

; b is sprite x_coordinate 
; c is sprite y_coordinate
; returns global x coordinate in b, y coordinate in c
macro global_coordinates
    ; Find global x coordinate
    ; Copy a, [\1 + OAMA_X]
    ; ld b, a
    ld a, [rWX]
    add a, b
    sub a, 8
    ld b, a

    ; find global y coordinate
    ; Copy a, [\1 + OAMA_Y]
    ; ld c, a
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
; returns tile ID in a
macro find_overlapping_tile_ID
    ; calculate what tile the sprite is on

    ; find y vertical row (divide y pixel height by 8)
    ld a, \2
    srl a
    srl a
    srl a

    ; multiply y * 32
    ld l, a
    ld a, 0
    sla a
    sla l
    adc a
    ; * 2
    sla a
    sla l
    adc a
    ; * 4
    sla a
    sla l
    adc a
    ; * 8
    sla a
    sla l
    adc a
    ; * 16
    sla a
    sla l
    adc a, 0
    ; * 32
    ld h, a

    ; x
    ld a, \1
    srl a
    srl a
    srl a
    ld c, a
    
    ; add (y * 32) + x
    ld b, 0
    add hl, bc
    
    ld bc, $9800
    add hl, bc

    ld a, [hl]

    ; check vram for tile ID
    ; tilemap + calculated number    
endm

; \1 is tile ID
; returns z flag checked if no collision, nz checked if collision
macro CHECK_IF_COLLISION
    ; put the index we want to check in ROM into hl
    ld hl, $D000
    ld a, \1
    ld b, a
    srl a
    srl a
    srl a
    add a, l
    ld l, a

    ; put the bit we want to check in b
    sla a
    sla a
    sla a
    ld c, a
    ld a, b
    sub a, c
    ld b, a

    ; check if the tile index bit is a collision (is 1)
    ld a, %10000000
    inc b
    dec b
    jr z, .check_bit\@
    .next_bit\@
        srl a
        dec b
    jr nz, .next_bit\@

    .check_bit\@
    and a, [hl]
endm

; sets the zero flag if the player can go there, zero flag not set if collision
can_player_move_here:
    global_coordinates PLAYER_SPRITE
    find_overlapping_tile_ID b, c
    CHECK_IF_COLLISION a
    ret

load_collision_tiles_into_ROM:
    ld hl, $D000
    ; sprites do not cause collisions
    ld a, %00000000
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ld[hl], a
    inc hl
    ; background blocks that may cause collisions
    ld a, %11100001
    ld[hli], a
    ld a, %11000000
    ld[hli], a
    ld a, %10100001
    ld[hli], a
    ld a, %01000000
    ld[hli], a
    ld a, %11100001
    ld[hli], a
    ld a, %11000000
    ld[hli], a
    ld a, %11000000
    ld[hli], a
    ld a, %00000111
    ld[hli], a
    ld a, %00000000
    ld[hli], a
    ld a, %00000000
    ld[hli], a
    ld a, %00000000
    ld[hli], a

    ret

export can_player_move_here, load_collision_tiles_into_ROM