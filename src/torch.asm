;
; CS-240 World 5: First Draft
;
; @file torch.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 13, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def UNLIT_TORCH_TILE_ID   equ 50

; level 1 torches:
def TORCH_1          equ _OAMRAM + 3*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 112
def TORCH_1_START_Y   equ 40

def TORCH_2          equ _OAMRAM + 4*sizeof_OAM_ATTRS
def TORCH_2_START_X   equ 152
def TORCH_2_START_Y   equ 72

def TORCH_3          equ _OAMRAM + 5*sizeof_OAM_ATTRS
def TORCH_3_START_X   equ 16
def TORCH_3_START_Y   equ 88

def TORCH_4          equ _OAMRAM + 6*sizeof_OAM_ATTRS
def TORCH_4_START_X   equ 152
def TORCH_4_START_Y   equ 112

; level 2 torches:
def TORCH_1_START_X_L2   equ 152
def TORCH_1_START_Y_L2   equ 56

def TORCH_2_START_X_L2   equ 64
def TORCH_2_START_Y_L2   equ 96

def TORCH_3_START_X_L2   equ 16
def TORCH_3_START_Y_L2   equ 136

def TORCH_4_START_X_L2   equ 152
def TORCH_4_START_Y_L2   equ 120

def OAMA_NO_FLAGS       equ 0

section "torch", rom0

; make macro to check if sprites are colliding 
; \1 is global x_coordinate for the first sprite
; \2 is global y_coordinate for the first sprite
; \3 is global x_coordinate for the second sprite
; \4 is global y_coordinate for the second sprite
; if colliding, set carry flag
macro find_overlapping_sprite
    ; calculate what sprite the player_sprite is on

    ; find y vertical row (divide y pixel height by 8)
    ld a, \2
    srl a
    srl a
    srl a
    ld h, a

    ld a, \4
    srl a
    srl a
    srl a

    cp a, h
    jr nz, .not_overlapping

    ; find x horizontal col (divide y pixel height by 8)
    ld a, \1
    srl a
    srl a
    srl a
    ld c, a

    ld a, \3
    srl a
    srl a
    srl a
    
    cp a, c
    jr nz, .not_overlapping
        scf
    .not_overlapping
endm

macro init_torch
    Copy [\1 + OAMA_X], \2
    Copy [\1 + OAMA_Y], \3
    Copy [\1 + OAMA_TILEID], \4
    Copy [\1 + OAMA_FLAGS], OAMF_PAL1
endm

; adds a number (\1) to hl
; returns sum in hl
macro add_to_hl
    ld a, l
    add a, \1
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
endm

; nc checked if torch lit
; c checked if torch not lit
macro check_torch_lit
    ; check if tile id is greater than 52 (torch is lit)
    Copy a, [\1 + OAMA_TILEID]
    cp a, [UNLIT_TORCH_TILE_ID + 2]
endm

init_level_1_torches:
    init_torch TORCH_1, TORCH_1_START_X, TORCH_1_START_Y, UNLIT_TORCH_TILE_ID
    init_torch TORCH_2, TORCH_2_START_X, TORCH_2_START_Y, UNLIT_TORCH_TILE_ID
    init_torch TORCH_3, TORCH_3_START_X, TORCH_3_START_Y, UNLIT_TORCH_TILE_ID
    init_torch TORCH_4, TORCH_4_START_X, TORCH_4_START_Y, UNLIT_TORCH_TILE_ID
    ret

;init_level_2_torches:
init_level_2_torches:
    init_torch TORCH_1, TORCH_1_START_X_L2, TORCH_1_START_Y_L2, UNLIT_TORCH_TILE_ID
    init_torch TORCH_2, TORCH_2_START_X_L2, TORCH_2_START_Y_L2, UNLIT_TORCH_TILE_ID
    init_torch TORCH_3, TORCH_3_START_X_L2, TORCH_3_START_Y_L2, UNLIT_TORCH_TILE_ID
    init_torch TORCH_4, TORCH_4_START_X_L2, TORCH_4_START_Y_L2, UNLIT_TORCH_TILE_ID
    ret
   
; check all torches (sprites after the doors but before the water?)
; return whichever torch is overlapping
light_possible:
    ; while the sprite in question is between (_OAMRAM + 3*sizeof_OAM_ATTRS) and (_OAMRAM + 6*sizeof_OAM_ATTRS);;;;tile ID is 50
        ; compare the sprite locations
        ; if the same, break and return that torch 
        ; if get to the end and none, return 0
    ld hl, TORCH_1
    .check_next_torch
    jr c, .touching
        ; go to next torch
        add_to_hl sizeof_OAM_ATTRS
        ; ld a, sizeof_OAM_ATTRS
        ; add a, l
        ; ld l, a
        ; ld a, h
        ; adc a, 0
        ; ld h, a

        push bc
        push de

        Copy b, [PLAYER_SPRITE + OAMA_X]
        Copy c, [PLAYER_SPRITE + OAMA_Y]
        
        push hl
        add_to_hl OAMA_X
        ld d, [hl]
        pop hl
        push hl
        add_to_hl OAMA_Y
        ld e, [hl]
        pop hl
        find_overlapping_sprite b, c, d, e

        pop de
        pop bc

        jr c, .touching
            inc c
            ld a, c
            cp a, 4
            jr nz, .check_next_torch
                ld h, 0
                ld l, 0
    .touching
    ret
    
light_torch:
    halt
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is B being held?
    push af
    bit PADB_DOWN, a
    jr nz, .dont_light
        call light_possible
        inc hl
        dec hl
        jr z, .dont_light
            add_to_hl OAMA_TILEID
            Copy [hl], 52


    .dont_light
    pop af

    ret

; opens door if all torches lit
check_all_torches_lit:
    push hl
    push bc
    ld c, 0
    ld hl, TORCH_1
    .check_next_torch
    jr c, .done
        ; go to next torch
        ld a, sizeof_OAM_ATTRS
        add a, l
        ld l, a
        ld a, h
        adc a, 0
        ld h, a

        ; check if all torches have been checked
        inc c
        ld a, c
        cp a, 4
        jr nz, .check_next_torch
    call open_and_close_door
    .done
    ret
    pop bc
    pop hl
    

export init_level_1_torches, light_torch