;
; CS-240 World 6: First Draft
;
; @file door.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

def LEFT_DOOR_START_X   equ 16
def LEFT_DOOR_START_Y   equ 16
def LEFT_DOOR_TILE_ID   equ 42
def LEFT_DOOR_OPEN_ID   equ 46
def OAMA_NO_FLAGS       equ 0

def RIGHT_DOOR_START_X  equ 24
def RIGHT_DOOR_START_Y  equ 16
def RIGHT_DOOR_TILE_ID  equ 44
def RIGHT_DOOR_OPEN_ID  equ 48

def OPEN_OR_CLOSE_DOOR  equ 20
def OPEN_DOOR_TILE_IDS  equ 46
def SWITCH_DOOR_TILE_ID equ 4

section "door", rom0

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

open_door:
    Copy [LEFT_DOOR + OAMA_TILEID], LEFT_DOOR_OPEN_ID
    Copy [RIGHT_DOOR + OAMA_TILEID], RIGHT_DOOR_OPEN_ID
    ret

; opens and closes the door, returns a counter in "d" 
;       which signifies when to open and close the door
open_and_close_door:
    push af
    halt
    ChangeDoor LEFT_DOOR
    ChangeDoor RIGHT_DOOR

    pop af
    ret

enter_door_possible:
    ; check if the door is open
    ld a, [LEFT_DOOR + OAMA_TILEID]
    cp a, LEFT_DOOR_OPEN_ID
    jr nz, .done
        ; if open, check if player is touching the door
        ld a, [PLAYER_SPRITE + OAMA_X]
        ld b, a
        ld a, [PLAYER_SPRITE + OAMA_Y]
        add a, 4
        ld c, a

        Copy d, [LEFT_DOOR + OAMA_X]
        Copy e, [LEFT_DOOR + OAMA_Y]
        FindOverlappingSprite b, c, d, e
        jp nz, .right_door
            ld hl, LEFT_DOOR
            jp .done
            
        .right_door
        Copy d, [RIGHT_DOOR + OAMA_X]
        Copy e, [RIGHT_DOOR + OAMA_Y]
        FindOverlappingSprite b, c, d, e
        jp nz, .done
            ld hl, RIGHT_DOOR
        
    .done
    ret

enter_door:
    halt
    call enter_door_possible
    jr nz, .dont_enter
        ; if door is open and player is touching it, make next level appear
        DisableLCD
        call load_level_2
        call init_player
        call init_door
        call init_level_2_torches
        call init_waters_2
        EnableLCD
    .dont_enter
    ret

export init_door, open_and_close_door, open_door, enter_door