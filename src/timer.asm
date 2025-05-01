;
; CS-240 World 8: Final Game
;
; @file timer.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"
include "src/timer.inc"

def START_NUMBER_TILE_ID    equ 65
def END_NUMBER_TILE_ID      equ 83
def COLON_TILE_ID           equ 85
def FIVE_TILE_ID            equ 75
def TWO_TILE_ID             equ 69

def MINUTE_TIMER_X          equ 16
def COLON_TIMER_X           equ 24
def TENS_TIMER_X            equ 32
def ONES_TIMER_X            equ 40
def TIMER_Y                 equ 136

macro DecreaseOnesNumber
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

macro DecreaseMinutes
    Copy a, [\1 + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .decrease_normal\@
        ;reset to number 5
        ld a, FIVE_TILE_ID
        Copy [\1 + OAMA_TILEID], a
        jr .done\@
    .decrease_normal\@
    dec a
    dec a
    Copy [\1 + OAMA_TILEID], a
    .done\@
endm

; Checks if all of the timer numbers are 0
macro CheckOutOfTime
    Copy a, [ONES_TIMER + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .done\@

    Copy a, [TENS_TIMER + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .done\@

    Copy a, [MINUTE_TIMER + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .done\@
    .done\@

endm

section "timer", rom0

init_timer:
    InitSprite ONES_TIMER, ONES_TIMER_X, TIMER_Y, START_NUMBER_TILE_ID
    InitSprite TENS_TIMER, TENS_TIMER_X, TIMER_Y, START_NUMBER_TILE_ID
    InitSprite MINUTE_TIMER, MINUTE_TIMER_X, TIMER_Y, TWO_TILE_ID
    InitSprite COLON, COLON_TIMER_X, TIMER_Y, COLON_TILE_ID
    ret

decrease_tens_number:
    Copy a, [TENS_TIMER + OAMA_TILEID]  
    cp a, START_NUMBER_TILE_ID
    jr nz, .decrease_normal
        DecreaseMinutes MINUTE_TIMER
        ;reset to number 5
        ld a, FIVE_TILE_ID
        Copy [TENS_TIMER + OAMA_TILEID], a
        jr .done
    .decrease_normal
    dec a
    dec a
    Copy [TENS_TIMER + OAMA_TILEID], a
    .done
    ret

update_timer:
    ; skip updating the timer if the game is over
    CheckOutOfTime
    jr z, .game_over
        dec d
        jr nz, .done
            Copy a, [ONES_TIMER + OAMA_TILEID] 
            cp a, START_NUMBER_TILE_ID
            jr nz, .decrease_ones
                call decrease_tens_number
            .decrease_ones
            DecreaseOnesNumber ONES_TIMER
            ld d, LOOPS_PER_SECOND
        .done

        ; If out of time end the game
        CheckOutOfTime
        jr nz, .not_out_of_time
            call player_death_sound
            call game_over
        .not_out_of_time
    .game_over
    ret

export init_timer, update_timer