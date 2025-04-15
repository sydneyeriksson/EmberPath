;
; CS-240 World 6: First Draft
;
; @file collision.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"
include "src/sprites.inc"
include "src/collision_tiles.inc"

def LADDER_TILE_ID   equ 188

section "collision", rom0

; \1 is global x_coordinate
; \2 is global y_coordinate
; returns tile ID in a
macro FindOverlappingTileID
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
; returns z flag checked if no collision, nz if collision
macro CheckIfCollision
    ; put the index we want to check in ROM into hl
    ld hl, $0000
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

; b is sprite x_coordinate 
; c is sprite y_coordinate
; returns global x coordinate in b, y coordinate in c
global_coordinates:
    ; Find global x coordinate
    ld a, [rWX]
    add a, b
    sub a, 8
    ld b, a

    ; find global y coordinate
    ld a, [rWX]
    add a, c
    sub a, 16
    ld c, a
    ret

; checks if sprite is infront of ladder
; returns z flag checked if it is, nz checked if not
infront_of_ladder:
    call global_coordinates
    FindOverlappingTileID b, c
    cp a, LADDER_TILE_ID
    ret

; sets the zero flag if the player can go there, zero flag not set if collision
can_player_move_here:
    call global_coordinates
    FindOverlappingTileID b, c
    CheckIfCollision a
    ret

export can_player_move_here, load_collision_tiles_into_ROM, infront_of_ladder, global_coordinates