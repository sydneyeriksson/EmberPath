;
; CS-240 World 8: Final Game
;
; @file door.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025
; @brief macros and functions to control the door sprites
; @license Copyright 2025 Asher Kaplan and Sydney Eriksson

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"
include "src/timer.inc"

def WRAM_FUNC_INDEX     equ 1

def LEFT_DOOR_START_X   equ 16
def LEFT_DOOR_START_Y   equ 16
def LEFT_DOOR_TILE_ID   equ 42

def RIGHT_DOOR_START_X  equ 24
def RIGHT_DOOR_START_Y  equ 16
def RIGHT_DOOR_TILE_ID  equ 44
def RIGHT_DOOR_OPEN_ID  equ 48

def OPEN_OR_CLOSE_DOOR  equ 20
def OPEN_DOOR_TILE_IDS  equ 46
def SWITCH_DOOR_TILE_ID equ 4

section "door", rom0

; Switch the state of one half of the door (open or closed)
; \1 if the door sprite ID
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


macro CallHL
    ld de, .call_return_address\@
    push de
    jp hl
    .call_return_address\@
endm

UpdateFuncTable:
    dw load_first_level
    dw first_to_second
    dw second_to_third
    dw game_won

init_door:
   ; Init left side of door
   InitSprite LEFT_DOOR, LEFT_DOOR_START_X, LEFT_DOOR_START_Y, LEFT_DOOR_TILE_ID, OAMF_PAL1


   ; Init right side of door
   InitSprite RIGHT_DOOR, RIGHT_DOOR_START_X, RIGHT_DOOR_START_Y, RIGHT_DOOR_TILE_ID, OAMF_PAL1
   ret

; Change the left and right door tile IDs so the door appears open
open_door:
    call door_open_sound
    Copy [LEFT_DOOR + OAMA_TILEID], LEFT_DOOR_OPEN_ID
    Copy [RIGHT_DOOR + OAMA_TILEID], RIGHT_DOOR_OPEN_ID
    ret

; checks if the door is open and the player is touching it
; returns z checked if so, nz if not
enter_door_possible:
    push bc
    push de
    ; check if the door is open
    ld a, [LEFT_DOOR + OAMA_TILEID]
    cp a, LEFT_DOOR_OPEN_ID
    jr nz, .done
        ; if open, check if player is touching the left half of the door
        ld a, [PLAYER_SPRITE + OAMA_X]
        ld b, a
        ld a, [PLAYER_SPRITE + OAMA_Y]
        add a, FLOATING_OFFSET
        ld c, a

        Copy d, [LEFT_DOOR + OAMA_X]
        Copy e, [LEFT_DOOR + OAMA_Y]
        FindOverlappingSprite b, c, d, e
        
    .done
    pop de
    pop bc
    ret

; Attempt to enter the door to go to the next level 
; Player can only enter if the door is open
enter_door:
    push de
    ; Check if the door is open and player is touching it
    call enter_door_possible
    jr nz, .dont_enter

        ; Make next level appear
        DisableLCD   
        ld a, c
        ld d, 0
        ld e, a
        ld hl, UpdateFuncTable
        add hl, de
        add hl, de
    
        ld a, [hli]
        ld h, [hl]
        ld l, a
        CallHL

        ;.done
        EnableLCD
        call next_level_sound

    .dont_enter
    pop de
    ret

export init_door, open_and_close_door, open_door, enter_door