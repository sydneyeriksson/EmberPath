;
; CS-240 World 5: First Draft
;
; @file player.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 9, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def PLAYER_START_X        equ 83
def PLAYER_START_Y        equ 134
def FIRE_UPRIGHT_TILEID   equ 0
def FIRE_BALL             equ 24
def FIRE_MOVING_LEFT      equ 8
def OAMA_NO_FLAGS         equ 0
def SPRITE_MOVING_DOWN    equ 8
def SPRITE_DONE_JUMPING   equ 16
def END_FLICKER_TILE_ID   equ 6

section "fire", rom0

macro move_right
    ld a, [PLAYER_SPRITE + OAMA_X]
    inc a
    ld [PLAYER_SPRITE + OAMA_X], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_LEFT
    ; Checks if player can move there, undoes movement if not
    Copy b, [PLAYER_SPRITE + OAMA_X]
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    call can_player_move_here
    jr z, .done\@
        ld a, [PLAYER_SPRITE + OAMA_X]
        dec a
        ld [PLAYER_SPRITE + OAMA_X], a
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    .done\@
endm

macro move_left
    ld a, [PLAYER_SPRITE + OAMA_X]
    dec a
    ld [PLAYER_SPRITE + OAMA_X], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_XFLIP | OAMF_PAL1
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_LEFT
    ; Checks if player can move there, undoes movement if not
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, 8
    ld b, a
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    call can_player_move_here
    jr z, .done\@
        ld a, [PLAYER_SPRITE + OAMA_X]
        inc a
        ld [PLAYER_SPRITE + OAMA_X], a
    .done\@
endm

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

        ; Calculate how much the sprite should move up based on the counter "e"
        ld a, SPRITE_DONE_JUMPING
        inc a
        sub a, e
        srl a
        srl a
        srl a
        ld c, a

        ; move sprite up
        ld a, [PLAYER_SPRITE + OAMA_Y]
        sub a, c
        ld [PLAYER_SPRITE + OAMA_Y], a
        inc e
        jr .done
    .down
    ; Calculate how much the sprite should move down based on the counter "e"
    srl a
    srl a
    srl a
    ld c, a

    ; move sprite down
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, c
    ld [PLAYER_SPRITE + OAMA_Y], a
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

; makes the flame flicker
flicker:
    push af
    halt
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
        move_right
    .done_moving_right
    pop af

    ; Is left being held?
    push af
    bit PADB_LEFT, a
    jr nz, .done_moving_left
        ; move left
        ; ld a, [PLAYER_SPRITE + OAMA_X]
        ; dec a
        ; ld [PLAYER_SPRITE + OAMA_X], a

        ; ; reset the flame
        ; ld a, [PLAYER_SPRITE + OAMA_TILEID]
        ; Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_LEFT
        ; Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_XFLIP | OAMF_PAL1
        move_left
    .done_moving_left
    pop af

    ; Is up being held?
    push af
    bit PADB_UP, a
    ; Check if a jump is currently in action
    jr nz, .no_start_jump
        ld a, e
        cp a, 0
        jr nz, .no_start_jump
            ; set the counter "e" to 1 to signify that a jump is in action
            ld e, 1

    .no_start_jump
    ; if a jump is in action, call jump to continue the jump
    ld a, e
    cp a, 0
    jr z, .no_jump
        call jump
    .no_jump
    pop af

    ret

export init_player, move_player, flicker
