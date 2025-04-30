;
; CS-240 World 7: Feature Complete
;
; @file player.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def PLAYER_START_X           equ 32
def PLAYER_START_Y           equ 15
def FIRE_UPRIGHT_TILEID      equ 0
def FIRE_BALL                equ 24
def FIRE_MOVING_SIDEWAYS     equ 6
def OAMA_NO_FLAGS            equ 0
def SPRITE_MOVING_DOWN       equ 9
def SPRITE_JUMP_UP           equ 10
def SPRITE_DONE_JUMPING      equ 24
def END_FLICKER_TILE_ID      equ 6
def SPRITE_HOVER             equ 10


section "fire", rom0

macro MoveRight
    push bc
    ; move the player right
    ld a, [WRAM_PLAYER + SPRITE_X]
    inc a
    inc a
    ld [WRAM_PLAYER + SPRITE_X], a
    Copy [WRAM_PLAYER + FLAGS], OAMF_PAL1
    Copy [WRAM_PLAYER + TILE_ID], FIRE_MOVING_SIDEWAYS

    ; Checks if player can move there, undoes movement if not
    Copy b, [WRAM_PLAYER + SPRITE_X]
    Copy c, [WRAM_PLAYER + SPRITE_Y]
    ld a, c
    add a, SPRITE_MOVING_DOWN
    ld c, a
    call can_player_move_here
    jr z, .done\@
        ; undo the movement
        ld a, [WRAM_PLAYER + SPRITE_X]
        dec a
        dec a
        ld [WRAM_PLAYER + SPRITE_X], a
        Copy [WRAM_PLAYER + FLAGS], OAMF_PAL1
    .done\@
    pop bc
endm

macro MoveLeft
    push bc
    ; Move the player left
    ld a, [PLAYER_SPRITE + OAMA_X]
    dec a
    dec a
    ld [PLAYER_SPRITE + OAMA_X], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_XFLIP | OAMF_PAL1
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_MOVING_SIDEWAYS

    ; Checks if player can move there, undoes movement if not
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    ; offset the x and y coordinates to match the left side of the sprite
    sub a, FIRE_MOVING_SIDEWAYS
    ld b, a
    Copy c, [PLAYER_SPRITE + OAMA_Y]
    ld a, c
    add a, SPRITE_MOVING_DOWN
    ld c, a
    call can_player_move_here
    jr z, .done\@
        ; undo the movement
        ld a, [PLAYER_SPRITE + OAMA_X]
        inc a
        inc a
        ld [PLAYER_SPRITE + OAMA_X], a
    .done\@
    pop bc
endm

macro Gravity
    push bc
    ; move the player 1 pixel down
    ld a, [PLAYER_SPRITE + OAMA_Y]
    inc a
    ld [PLAYER_SPRITE + OAMA_Y], a
    add a, SPRITE_MOVING_DOWN

    ; load the x coordinate into b and y coordinate into c
    ld c, a
    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, 5
    ld b, a
    call can_player_move_here
    jr nz, .reset\@

    Copy b, [PLAYER_SPRITE + OAMA_X]
    ld a, b
    sub a, 2
    ld b, a
    call can_player_move_here
    jr z, .make_fire_ball\@

    .reset\@
    ld a, [PLAYER_SPRITE + OAMA_Y]
    dec a
    ld [PLAYER_SPRITE + OAMA_Y], a
    jr .done\@

    .make_fire_ball\@
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL

    .done\@
    pop bc
endm

macro JumpSprite
    push bc
    ld a, \1
    sra a
    sra a
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    sub a, b
    ld [PLAYER_SPRITE + OAMA_Y], a
    pop bc

endm

macro ReverseJumpSprite
    push bc
    ld a, \1
    sra a
    sra a
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, b
    ld [PLAYER_SPRITE + OAMA_Y], a
    pop bc
endm

; uses counter "e" which stores 
;       what part of the jump the sprite is in
jump_possible:
    push bc
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
    sub a, FLOATING_OFFSET
    ld b, a
    call can_player_move_here
    ; if on solid ground (collision detected), start a jump
    jr z, .no_start_jump
        ld e, SPRITE_JUMP_UP
    .no_start_jump

    ; reset sprite from previous check for solid ground
    ld a, [PLAYER_SPRITE + OAMA_Y]
    dec a
    ld [PLAYER_SPRITE + OAMA_Y], a

    pop bc
    ret

init_player:
    InitSprite PLAYER_SPRITE, PLAYER_START_X, PLAYER_START_Y, FIRE_UPRIGHT_TILEID, OAMF_PAL1

    InitSpriteWram WRAM_PLAYER, 0, PLAYER_START_X, PLAYER_START_Y, FIRE_UPRIGHT_TILEID, OAMF_PAL1
    ret

; make the sprite jump, returns a counter in "e" 
;       which stores what part of the jump the sprite is in
jump:
    push af
    push bc
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_YFLIP | OAMF_PAL1
    ld a, e
    cp a, NO_JUMP
    jr c, .skip_y_flip
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    .skip_y_flip
    JumpSprite e

    ; check if player can move here, if not, reverse movement
    Copy a, [PLAYER_SPRITE + OAMA_Y]
    add a, SPRITE_MOVING_DOWN
    ld c, a
    Copy a, [PLAYER_SPRITE + OAMA_X]
    sub a, 5
    ld b, a
    call can_player_move_here
    jr z, .done
        ; undo movement and end jump
        ReverseJumpSprite e
        ld e, NO_JUMP
        inc e
    .done
    dec e

    pop bc
    pop af
    ret

climb_ladder: 
    push af
    push bc
    ; get player location
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, FLOATING_OFFSET
    ld c, a
    ld a, [PLAYER_SPRITE + OAMA_X]
    sub a, FLOATING_OFFSET
    ld b, a

    call infront_of_ladder
    jr nz, .done
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_BALL
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1

        ; move sprite up
        ld a, [PLAYER_SPRITE + OAMA_Y]
        dec a
        dec a
        dec a
        ld [PLAYER_SPRITE + OAMA_Y], a
        xor a
    .done
    pop bc
    pop af
    ret
    
; makes the flame flicker
flicker:
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

; get button events, and move player
move_player:
    ; reset the flame to upright position
    ld a, [PLAYER_SPRITE + OAMA_TILEID]
    cp a, END_FLICKER_TILE_ID
    jr c, .skip_reset
        Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_UPRIGHT_TILEID
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL1
    .skip_reset

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; If right held, move right
    push af
    bit PADB_RIGHT, a
    jr nz, .done_moving_right
        ; move right
        MoveRight
    .done_moving_right
    pop af

    ; If left held, move left
    push af
    bit PADB_LEFT, a
    jr nz, .done_moving_left
        MoveLeft
    .done_moving_left
    pop af
    push af
    ; continue existing jump
    ld a, e
    cp a, NO_JUMP
    jr z, .no_jump_in_progress
        call jump
        jr .no_start_jump
    .no_jump_in_progress
    ; If a held, jump
    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .no_jump
        call jump_possible
    .no_jump
    Gravity
    Gravity
    .no_start_jump

    pop af


    ; If up held, climb ladder
    push af
    bit PADB_UP, a
    jr nz, .no_climb
        call climb_ladder     
    .no_climb

    .done
    pop af
    ret

export init_player, move_player, flicker
