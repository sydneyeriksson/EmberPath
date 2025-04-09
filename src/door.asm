;
; CS-240 World 5: First Draft
;
; @file door.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 9, 2025

include "src/utils.inc"
include "src/wram.inc"


def LEFT_DOOR           equ _OAMRAM + sizeof_OAM_ATTRS
def LEFT_DOOR_START_X   equ 20
def LEFT_DOOR_START_Y   equ 112
def LEFT_DOOR_TILE_ID   equ 42
def OAMA_NO_FLAGS       equ 0

def RIGHT_DOOR          equ _OAMRAM + 2*sizeof_OAM_ATTRS
def RIGHT_DOOR_START_X  equ 28
def RIGHT_DOOR_START_Y  equ 112
def RIGHT_DOOR_TILE_ID  equ 44

def PLAYER_SPRITE       equ _OAMRAM

def OPEN_OR_CLOSE_DOOR  equ 20
def OPEN_DOOR_TILE_IDS  equ 46
def SWITCH_DOOR_TILE_ID equ 4

section "door", rom0

init_door:
    ; Init left side of door
    Copy [LEFT_DOOR + OAMA_X], LEFT_DOOR_START_X
    Copy [LEFT_DOOR + OAMA_Y], LEFT_DOOR_START_Y
    Copy [LEFT_DOOR + OAMA_TILEID], LEFT_DOOR_TILE_ID
    Copy [LEFT_DOOR + OAMA_FLAGS], OAMF_PAL1

    ; Init right side of door
    Copy [RIGHT_DOOR + OAMA_X], RIGHT_DOOR_START_X
    Copy [RIGHT_DOOR + OAMA_Y], RIGHT_DOOR_START_Y
    Copy [RIGHT_DOOR + OAMA_TILEID], RIGHT_DOOR_TILE_ID
    Copy [RIGHT_DOOR + OAMA_FLAGS], OAMF_PAL1
    ret

; Switch the state of one half of the door (open or closed)
macro ChangeDoor
    push af
    ld a, [\1 + OAMA_TILEID]
    cp a, OPEN_DOOR_TILE_IDS
    jr nc, .set_closed\@
        add a, SWITCH_DOOR_TILE_ID
        Copy [\1 + OAMA_TILEID], a
        jr .done\@
    .set_closed\@
    sub a, SWITCH_DOOR_TILE_ID
    Copy [\1 + OAMA_TILEID], a
    jr .done\@
    .done\@
    pop af
endm

; opens and closes the door, returns a counter in "d" 
;       which signifies when to open and close the door
open_and_close_door:
    push af
    halt
    ld a, d
    cp a, OPEN_OR_CLOSE_DOOR
    jr c, .skip_change_door
        ChangeDoor LEFT_DOOR
        ChangeDoor RIGHT_DOOR
        ld d, 0
        jr .done
    .skip_change_door
    inc d
    .done
    pop af
    ret

export init_door, open_and_close_door