;
; CS-240 World 7: Feature Complete
;
; @file main.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

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
    call load_torch_data_into_WRAM
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
    call init_spikes_1
    call init_timer
    EnableLCD
    
    ; init e as a jump counter
    ld e, NO_JUMP

    ; init d as a second timer
    ld d, LOOPS_PER_SECOND

    ; init c as the game level counter
    ld c, 1

    ; currently has 6 halts in a loop
    .game_loop
        halt
        UpdateJoypad
        call flicker
        call move_player
        call light_torch
        halt
        call check_all_torches_lit
        halt
        call fire_evaporate
        halt
        call check_A_pressed
        halt
        call flicker_torches
        call update_timer
        halt
        call enter_door
        jr .game_loop