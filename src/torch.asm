;
; CS-240 World 5: First Draft
;
; @file torch.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 13, 2025

include "src/utils.inc"
include "src/wram.inc"


def TORCH_1          equ _OAMRAM + 3*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 41
def TORCH_1_START_Y   equ 108
def TORCH_1_TILE_ID   equ 50

/* def TORCH_2          equ _OAMRAM + 4*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 33
def TORCH_1_START_Y   equ 96
def TORCH_1_TILE_ID   equ 50

def TORCH_3          equ _OAMRAM + 5*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 33
def TORCH_1_START_Y   equ 96
def TORCH_1_TILE_ID   equ 50

def TORCH_4          equ _OAMRAM + 6*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 33
def TORCH_1_START_Y   equ 96
def TORCH_1_TILE_ID   equ 50

def TORCH_5          equ _OAMRAM + 7*sizeof_OAM_ATTRS
def TORCH_1_START_X   equ 33
def TORCH_1_START_Y   equ 96
def TORCH_1_TILE_ID   equ 50 */


def OAMA_NO_FLAGS       equ 0

/* def OPEN_OR_CLOSE_DOOR  equ 20
def OPEN_DOOR_TILE_IDS  equ 46
def SWITCH_DOOR_TILE_ID equ 4 */

section "torch", rom0

init_torch_1:
    ; Init left side of door
    Copy [TORCH_1 + OAMA_X], TORCH_1_START_X
    Copy [TORCH_1 + OAMA_Y], TORCH_1_START_Y
    Copy [TORCH_1 + OAMA_TILEID], TORCH_1_TILE_ID
    Copy [TORCH_1 + OAMA_FLAGS], OAMF_PAL1

    ; Init right side of door
/*     Copy [RIGHT_DOOR + OAMA_X], RIGHT_DOOR_START_X
    Copy [RIGHT_DOOR + OAMA_Y], RIGHT_DOOR_START_Y
    Copy [RIGHT_DOOR + OAMA_TILEID], RIGHT_DOOR_TILE_ID
    Copy [RIGHT_DOOR + OAMA_FLAGS], OAMF_PAL1 */
    ret

/* ; Switch the state of one half of the door (open or closed)
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
endm */

; opens and closes the door, returns a counter in "d" 
;       which signifies when to open and close the door
/* open_and_close_door:
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
*/
export init_torch_1