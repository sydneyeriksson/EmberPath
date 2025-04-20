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

; water
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
def WATER_4_L2_X   equ 104
def WATER_5_L2_X   equ 0

def WATER_L3_Y     equ 128
def WATER_1_L3_X   equ 112
def WATER_2_L3_X   equ 120
def WATER_3_L3_X   equ 128
def WATER_4_L3_X   equ 136
def WATER_5_L3_X   equ 0

; spikes
def LARGE_SPIKE_ID    equ 15
def SMALL_SPIKE_ID    equ 13

def LARGE_SPIKE_1_L3_X   equ 88
def LARGE_SPIKE_1_L3_Y   equ 16

def LARGE_SPIKE_2_L3_X   equ 36
def LARGE_SPIKE_2_L3_Y   equ 104

def SMALL_SPIKE_1_L3_X   equ 80
def SMALL_SPIKE_1_L3_Y   equ 16

def SMALL_SPIKE_2_L3_X   equ 8
def SMALL_SPIKE_2_L3_Y   equ 104

def SMALL_SPIKE_3_L3_X   equ 24
def SMALL_SPIKE_3_L3_Y   equ 104
*/

section "water", rom0

init_waters:
    InitSprite WATER_1, WATER_1_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L1_X, WATER_L1_Y, WATER_ID
    ret

init_waters_2:
    InitSprite WATER_1, WATER_1_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L2_X, WATER_L2_Y, WATER_ID
    ret

init_waters_3:
    InitSprite WATER_1, WATER_1_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L3_X, WATER_L3_Y, WATER_ID
    ret

/** 
init_spikes_1:
    InitSprite LARGE_SPIKE_1
    InitSprite LARGE_SPIKE_2
    InitSprite SMALL_SPIKE_1
    InitSprite SMALL_SPIKE_2
    InitSprite SMALL_SPIKE_3
    ret

init_spikes_2:
    ret

init_spikes_3:
    ret
*/

; check if the player is touching any of the water sprite tiles
; return z if touching, nz if not
evaporate_possible:
    push bc
    push de
    push hl
    ; get the player location
    ld a, [PLAYER_SPRITE + OAMA_X]
    add a, 4
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, FLOATING_OFFSET
    ld c, a

    ;check if player is touching any of the water sprites
    Copy d, [WATER_1 + OAMA_X]
    Copy e, [WATER_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_2 + OAMA_X]
    Copy e, [WATER_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done
    
    Copy d, [WATER_3 + OAMA_X]
    Copy e, [WATER_3 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_4 + OAMA_X]
    Copy e, [WATER_4 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp z, .done

    Copy d, [WATER_5 + OAMA_X]
    Copy e, [WATER_5 + OAMA_Y]
    FindOverlappingSprite b, c, d, e

    .done
    pop hl
    pop de
    pop bc
    ret

; causes the player to die if it touches 
;       the water, and goes to the game over screen
fire_evaporate:
    call evaporate_possible
    jr nz, .stay_alive
        call player_death_sound
        ; if the player is not touching the water, load the game_over screen
        call game_over
    .stay_alive
    ret

export init_waters, init_waters_2, init_waters_3, fire_evaporate