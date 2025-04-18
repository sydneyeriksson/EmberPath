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
def WATER_4_L2_X   equ 104
def WATER_5_L2_X   equ 0

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
    halt
    call evaporate_possible
    jr nz, .stay_alive
        call player_death_sound
        ; if the player is not touching the water, load the game_over screen
        call game_over
    .stay_alive
    ret

export init_waters, init_waters_2, fire_evaporate