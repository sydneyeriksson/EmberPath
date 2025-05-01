;
; CS-240 World 8: Final Game
;
; @file main.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"
include "src/sprites.inc"
include "src/timer.inc"

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
    call init_waters_1
    call init_spikes_1
    call init_timer
    EnableLCD
    
    ; init e as a jump counter
    ld e, NO_JUMP

    ; init d as a second timer
    ld d, LOOPS_PER_SECOND

    ; init c as the game level counter
    ld c, 1

    ; currently has 4 halts in a loop
    .game_loop
        ld a, c
        cp a, GAME_OVER
        jp z, .game_over
            halt
            call load_torches_into_WRAM
            call load_player_into_WRAM
            call move_water
            halt
            UpdateJoypad
            call move_player
            call flicker
            call light_torch
            call flicker_torches
            halt
            call update_player_from_WRAM
            call update_torches_from_WRAM
            call check_all_torches_lit
            halt
            call fire_evaporate
            call enter_door
            call update_timer
            jp .game_loop
        .game_over
        halt
        UpdateJoypad
        call check_A_pressed
        jp .game_loop