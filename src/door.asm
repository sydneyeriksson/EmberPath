;
; CS-240 World 7: Feature Complete
;
; @file door.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

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
    push de
    ld de, .call_return_address\@
    push de
    jp hl
    .call_return_address\@
    pop de
endm

UpdateFuncTable:
    dw first_level
    dw first_to_second
    dw second_to_third
    dw game_won

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

        .done
        EnableLCD

    .dont_enter
    ret

first_level:
    call load_level_1
    call init_player
    call init_door
    call init_level_1_torches
    call init_waters_1
    call init_spikes_1
    call init_timer
    inc c
    ret

first_to_second:
    call load_level_2
    call init_player
    call init_door
    call init_level_2_torches
    call init_waters_2
    call init_spikes_2
    call init_timer
    inc c
    ret

second_to_third:
    call load_level_3
    call init_player
    call init_door
    call init_level_3_torches
    call init_waters_3
    call init_spikes_3
    call init_timer
    inc c
    ret

export init_door, open_and_close_door, open_door, enter_door