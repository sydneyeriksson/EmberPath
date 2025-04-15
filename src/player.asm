;
; CS-240 World 6: First Draft
;
; @file player.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def PLAYER_START_X           equ 32
def PLAYER_START_Y           equ 16
def FIRE_UPRIGHT_TILEID      equ 0
def FIRE_BALL                equ 24
def FIRE_MOVING_SIDEWAYS     equ 8
def OAMA_NO_FLAGS            equ 0
def SPRITE_MOVING_DOWN       equ 10
def SPRITE_DONE_JUMPING      equ 16
def END_FLICKER_TILE_ID      equ 6


section "fire", rom0

macro MoveRight
    ld a, [PLAYER_SPRITE + OAMA_X]
    inc a
    inc a
    ld [PLAYER_SPRITE + OAMA_X], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_SIDEWAYS
    ; Checks if player can move there, undoes movement if not
    Copy b, [PLAYER_SPRITE + OAMA_X]
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    ld a, c
    add a, FIRE_MOVING_SIDEWAYS
    ld c, a
    call can_player_move_here
    jr z, .done\@
        ld a, [PLAYER_SPRITE + OAMA_X]
        dec a
        dec a
        ld [PLAYER_SPRITE + OAMA_X], a
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    .done\@
endm

macro MoveLeft
    ld a, [PLAYER_SPRITE + OAMA_X]
    dec a
    dec a
    ld [PLAYER_SPRITE + OAMA_X], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_XFLIP | OAMF_PAL1
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_SIDEWAYS
    ; Checks if player can move there, undoes movement if not
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, FIRE_MOVING_SIDEWAYS
    ld b, a
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    ld a, c
    add a, FIRE_MOVING_SIDEWAYS
    ld c, a
    call can_player_move_here
    jr z, .done\@
        ld a, [PLAYER_SPRITE + OAMA_X]
        inc a
        inc a
        ld [PLAYER_SPRITE + OAMA_X], a
    .done\@
endm

macro Gravity
    ld a, [PLAYER_SPRITE + OAMA_Y]
    inc a
    ld [PLAYER_SPRITE + OAMA_Y], a
    ; Checks if player can move there, undoes movement if not
    Copy a, [PLAYER_SPRITE + OAMA_Y]
    add a, SPRITE_MOVING_DOWN
    ld c, a
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, 4
    ld b, a
    call can_player_move_here
    jr z, .done_first_check\@
        ld a, [PLAYER_SPRITE + OAMA_Y]
        dec a
        ld [PLAYER_SPRITE + OAMA_Y], a
    .done_first_check\@
endm

jump_possible:
    ; Check if player is on solid ground
    ld a, [PLAYER_SPRITE + OAMA_Y]
    inc a
    ld [PLAYER_SPRITE + OAMA_Y], a
    ; Checks if player can move down (is it on solid ground)
    Copy a, [PLAYER_SPRITE + OAMA_Y]
    add a, SPRITE_MOVING_DOWN
    ld c, a
    ; make the x coordinate of the sprite the center of the sprite
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, 4
    ld b, a
    call can_player_move_here
    ; if on solid ground (collision detected), start a jump
    jr z, .no_start_jump
        ld e, 1

    .no_start_jump
    ld a, e
    cp a, 0
    jr z, .no_jump
        call jump
    .no_jump

    ; reset sprite from previous check for solid ground
    ld a, [PLAYER_SPRITE + OAMA_Y]
    dec a
    ld [PLAYER_SPRITE + OAMA_Y], a
    ret

init_player:
    Copy [PLAYER_SPRITE + OAMA_X], PLAYER_START_X
    Copy [PLAYER_SPRITE + OAMA_Y], PLAYER_START_Y
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_UPRIGHT_TILEID
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    ret

; make the sprite jump, returns a counter in "e" 
;       which stores what part of the jump the sprite is in
jump:
    push af
    push bc
    ld a, e
    cp a, SPRITE_MOVING_DOWN
    jr nc, .down
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1

        ; move sprite up
        ld a, [PLAYER_SPRITE + OAMA_Y]
        dec a
        dec a
        ld [PLAYER_SPRITE + OAMA_Y], a
        inc e
        jr .done
    .down

    ; let sprite fall down with gravity
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_YFLIP | OAMF_PAL1

    ; increment the jump counter "e"
    inc e

    ; Check if the sprite is done jumping
    ld a, e
    cp a, SPRITE_DONE_JUMPING
    jr c, .done
        ; Reset the flame to be in normal upright mode
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_UPRIGHT_TILEID
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
        ld e, 0
    .done
    pop af
    pop bc
    ret

climb_ladder: 
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    ld a, [PLAYER_SPRITE + OAMA_X]
    sub a, 4
    ld b, a
    call infront_of_ladder
    jr nz, .done
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1

        ; move sprite up
        ld a, [PLAYER_SPRITE + OAMA_Y]
        dec a
        ld [PLAYER_SPRITE + OAMA_Y], a
        xor a
    .done
    ret
    
; makes the flame flicker
flicker:
    halt
    push af
    ld a, [PLAYER_SPRITE + OAMA_TILEID]
    cp a, END_FLICKER_TILE_ID
    jr nc, .done
        ; change between the flickering tileIDs
        inc a
        cp a, END_FLICKER_TILE_ID
        jr c, .skip_reset
            ld a, 0
        .skip_reset
        Copy [PLAYER_SPRITE + OAMA_TILEID], a
    .done
    pop af
    ret

move_player:
    halt
    ; reset the flame to upright position
    ld a, [PLAYER_SPRITE + OAMA_TILEID]
    cp a, END_FLICKER_TILE_ID
    jr c, .skip_reset
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_UPRIGHT_TILEID
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    .skip_reset

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is right being held?
    push af
    bit PADB_RIGHT, a
    jr nz, .done_moving_right
        ; move right
        MoveRight
    .done_moving_right
    pop af

    ; Is left being held?
    push af
    bit PADB_LEFT, a
    jr nz, .done_moving_left
        MoveLeft
    .done_moving_left
    pop af

    ; Is A being held?
    push af
    bit PADB_A, a
    ; Check if a jump is currently in action
    jr nz, .no_jump
        call jump_possible

    .no_jump
    pop af

    ; Is up being held?
    push af
    bit PADB_UP, a
    jr nz, .no_climb
        call climb_ladder
        ; Check if fire is standing infront of a ladder
        
        jr z, .done
    .no_climb
    Gravity

    .done
    pop af
    ret

export init_player, move_player, flicker
