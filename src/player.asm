include "src/utils.inc"
include "src/wram.inc"

; if only used in this file, then it makes sense 
; to put player constants here. If used elsewhere (very possible)
; then put in player.inc file

def PLAYER_SPRITE         equ _OAMRAM
def FIRE_2                equ (_OAMRAM + sizeof_OAM_ATTRS)
def PLAYER_START_X        equ 83
def PLAYER_START_Y        equ 60
def FIRE_UPRIGHT_TILEID   equ 0
def OAMA_NO_FLAGS         equ 0

section "fire", rom0

init_player:
    Copy [PLAYER_SPRITE + OAMA_X], PLAYER_START_X
    Copy [PLAYER_SPRITE + OAMA_Y], PLAYER_START_Y
    Copy [PLAYER_SPRITE + OAMA_TILEID], FIRE_UPRIGHT_TILEID
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMA_NO_FLAGS
    ret


jump:
    ld a, e
    cp a, 8
    jr nc, .down
        ld a, 17
        sub a, e
        srl a
        srl a
        srl a
        ld c, a
        ; move sprite one pixel up
        ld a, [PLAYER_SPRITE + OAMA_Y]
        sub a, c
        ld [PLAYER_SPRITE + OAMA_Y], a
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0

        inc e
        jr .done
    .down
    srl a
    srl a
    srl a
    ld c, a
    ; move sprite one pixel down
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, c
    ld [PLAYER_SPRITE + OAMA_Y], a
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0
    inc e
    ld a, e
    cp a, 16
    jr c, .done
        ld e, 0
    .done
    ret

flicker:
    halt
    ld a, [PLAYER_SPRITE + OAMA_TILEID]
    inc a
    cp a, 6
    jr c, .skip_reset
        ld a, 0
    .skip_reset
    Copy [PLAYER_SPRITE + OAMA_TILEID], a

    ret


move_player:
    halt

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is right being held?
    push af
    bit PADB_RIGHT, a
    jr nz, .done_moving_right
    ; perform action
        ; move right
        ld a, [PLAYER_SPRITE + OAMA_X]
        inc a
        ld [PLAYER_SPRITE + OAMA_X], a
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0
    .done_moving_right
    pop af

    ; Is left being held?
    push af
    bit PADB_LEFT, a
    jr nz, .done_moving_left
    ; perform action
        ; move right
        ld a, [PLAYER_SPRITE + OAMA_X]
        dec a
        ld [PLAYER_SPRITE + OAMA_X], a
        Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0
    .done_moving_left
    pop af

    ; Is up being held?
    push af
    bit PADB_UP, a
    jr nz, .no_start_jump
        ld a, e
        cp a, 0
        jr nz, .no_start_jump
            ld e, 1
    ; perform action
        ; move right
        ; ld a, [PLAYER_SPRITE + OAMA_Y]
        ; dec a
        ; ld [PLAYER_SPRITE + OAMA_Y], a
        ; Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0
    .no_start_jump
    ld a, e
    cp a, 0
    jr z, .no_jump
        call jump
    .no_jump
    pop af

    ; Is down being held?
    ; push af
    ; bit PADB_DOWN, a
    ; jr nz, .done_moving_down
    ; ; perform action
    ;     ; move right
    ;     ld a, [PLAYER_SPRITE + OAMA_Y]
    ;     inc a
    ;     ld [PLAYER_SPRITE + OAMA_Y], a
    ;     Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMF_PAL0
    ; .done_moving_down
    ; pop af

        
    ; Retrieve joypad state by loading the appropriate WRAM variable
    ; (see wram.inc!)

    ; handle UP / DOWN / LEFT / RIGHT

    ; consider making a helper macro MoveSprite!

    ret

export init_player, move_player, flicker
