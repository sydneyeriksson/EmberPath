;
; CS-240 World 6: First Draft
;
; @file water.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

def WATER_ID    equ 61

def WATER_L1_Y     equ 120
def WATER_1_L1_X   equ 80
def WATER_2_L1_X   equ 88
def WATER_3_L1_X   equ 96
def WATER_4_L1_X   equ 104
def WATER_5_L1_X   equ 112 

def WATER_L2_Y     equ 64
def WATER_1_L2_X   equ 64
def WATER_2_L2_X   equ 72
def WATER_3_L2_X   equ 96
def WATER_4_L2_X   equ 102
def WATER_5_L2_X   equ 0

section "water", rom0

macro init_water
    Copy [\1 + OAMA_X], \2
    Copy [\1 + OAMA_Y], \3
    Copy [\1 + OAMA_TILEID], WATER_ID
    Copy [\1 + OAMA_FLAGS], OAMF_PAL1
endm

init_waters:
    init_water WATER_1, WATER_1_L1_X, WATER_L1_Y
    init_water WATER_2, WATER_2_L1_X, WATER_L1_Y
    init_water WATER_3, WATER_3_L1_X, WATER_L1_Y
    init_water WATER_4, WATER_4_L1_X, WATER_L1_Y
    init_water WATER_5, WATER_5_L1_X, WATER_L1_Y
    ret

init_waters_2:
    init_water WATER_1, WATER_1_L2_X, WATER_L2_Y
    init_water WATER_2, WATER_2_L2_X, WATER_L2_Y
    init_water WATER_3, WATER_3_L2_X, WATER_L2_Y
    init_water WATER_4, WATER_4_L2_X, WATER_L2_Y
    init_water WATER_5, WATER_5_L2_X, WATER_L2_Y
    ret

evaporate_possible:
    push bc
    push de
    ld a, [PLAYER_SPRITE + OAMA_X]
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, 4
    ld c, a
    ld hl, 0

    Copy d, [WATER_1 + OAMA_X]
    Copy e, [WATER_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .water_2
        ld hl, WATER_1
        jp .done
        
    .water_2
    Copy d, [WATER_2 + OAMA_X]
    Copy e, [WATER_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .water_3
        ld hl, WATER_2
        jp .done
    
    .water_3
    Copy d, [WATER_3 + OAMA_X]
    Copy e, [WATER_3 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .water_4
        ld hl, WATER_3
        jp .done

    .water_4
    Copy d, [WATER_4 + OAMA_X]
    Copy e, [WATER_4 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .water_5
        ld hl, WATER_4
        jp .done
        
    .water_5
    Copy d, [WATER_5 + OAMA_X]
    Copy e, [WATER_5 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .done
        ld hl, WATER_5

    .done
    pop de
    pop bc
    ret

fire_evaporate:
    halt
    call evaporate_possible
    ; add condition for if evaporate_possible is not 0
    jr nz, .stay_alive
        DisableLCD
        call load_game_over
        InitOAM
        Copy [PLAYER_SPRITE + OAMA_X], PLAYER_HIDE_X
        EnableLCD
    .stay_alive
    ret

export init_waters, init_waters_2, fire_evaporate