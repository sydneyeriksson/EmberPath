include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

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
    EnableLCD
    ld e, 0
    .game_loop
        halt
        UpdateJoypad
        call flicker
        call move_player
        jr .game_loop

