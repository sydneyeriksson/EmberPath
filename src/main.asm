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
    call init_timer
    ld c, 1
    EnableLCD
    
    ; init e as a jump counter
    ld e, 0

    ; init d as a second timer
    ; 60 halts = 1 second
    ; 5 halts in a loop
    ; 12 decrements of d = 1 second
    ld d, 12

    ; currently has 6 halts in a loop
    .game_loop
        halt
        UpdateJoypad
        call flicker
        call move_player
        call light_torch
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
        ;call count_down
        jr .game_loop