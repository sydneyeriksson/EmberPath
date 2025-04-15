;
; CS-240 World 6: First Draft
;
; @file main.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jr main
    ds $150 - @, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "main", rom0[$0155]
main:
    DisableLCD
    call init_graphics
    EnableLCD
    InitJoypad

    ; Show the start screen, change when start is pressed
    .start_loop
        halt
        UpdateJoypad
        ld b, 0
        call move_window_offscreen
        ld a, b
        add a, 0
        jr z, .start_loop

    DisableLCD
    call init_player
    call init_door
    call init_level_1_torches
    call init_waters
    EnableLCD
    ld e, 0
    ld d, 0

    .game_loop
        halt
        UpdateJoypad
        call flicker
        call move_player
        call light_torch
        call check_all_torches_lit
        call enter_door
        call fire_evaporate
        call check_A_pressed
        jr .game_loop