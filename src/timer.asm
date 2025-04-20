;
; CS-240 World 6: First Draft
;
; @file graphics.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def START_NUMBER_TILE_ID    equ 65
def END_NUMBER_TILE_ID      equ 83

def ONES_TIMER_X            equ 136
def TENS_TIMER_X            equ 128
def TIMER_Y                 equ 128

; \1 is number of seconds
; returns the ones number in a
macro FindOnesNumber
    ld a, \1
    .check_under_ten\@
    cp a, 10
    jr c, .done\@
        sub a, 10
        jr .check_under_ten\@
    .done\@
endm

macro DecreaseNumber
    Copy a, [\1 + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .decrease_normal\@
        ;reset to number 9
        ld a, END_NUMBER_TILE_ID
        Copy [\1 + OAMA_TILEID], a
        jr .done\@
    .decrease_normal\@
    dec a
    dec a
    Copy [\1 + OAMA_TILEID], a
    .done\@
endm

section "timer", rom0

init_timer:
    InitSprite ONES_TIMER, ONES_TIMER_X, TIMER_Y, START_NUMBER_TILE_ID
    InitSprite TENS_TIMER, TENS_TIMER_X, TIMER_Y, START_NUMBER_TILE_ID
    ret

update_timer:
    dec d
    jr nz, .done
        Copy a, [ONES_TIMER + OAMA_TILEID] 
        cp a, START_NUMBER_TILE_ID
        jr nz, .decrease_ones
            DecreaseNumber TENS_TIMER
        .decrease_ones
        DecreaseNumber ONES_TIMER
        ld d, 15
    .done
    ret

export init_timer, update_timer