;
; CS-240 World 7: Feature Complete
;
; @file torch.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 21, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def UNLIT_TORCH_TILE_ID          equ 52
def START_TORCH_FLICKER_TILE_ID  equ 52
def END_TORCH_FLICKER_TILE_ID    equ 60
def OAMA_NO_FLAGS                equ 0
def LEFT_DOOR_OPEN_ID   equ 46

; level 1 torches:
def TORCH_1_START_X   equ 112
def TORCH_1_START_Y   equ 40

def TORCH_2_START_X   equ 152
def TORCH_2_START_Y   equ 72

def TORCH_3_START_X   equ 16
def TORCH_3_START_Y   equ 88

def TORCH_4_START_X   equ 152
def TORCH_4_START_Y   equ 112

; level 2 torches:
def TORCH_1_START_X_L2   equ 152
def TORCH_1_START_Y_L2   equ 48

def TORCH_2_START_X_L2   equ 64
def TORCH_2_START_Y_L2   equ 88

def TORCH_3_START_X_L2   equ 16
def TORCH_3_START_Y_L2   equ 112

def TORCH_4_START_X_L2   equ 152
def TORCH_4_START_Y_L2   equ 112

; level 3 torches:
def TORCH_1_START_X_L3   equ 96
def TORCH_1_START_Y_L3   equ 96

def TORCH_2_START_X_L3   equ 152
def TORCH_2_START_Y_L3   equ 112

def TORCH_3_START_X_L3   equ 8
def TORCH_3_START_Y_L3   equ 72

def TORCH_4_START_X_L3   equ 64
def TORCH_4_START_Y_L3   equ 64

section "torch", rom0

; adds a number (\1) to hl
; returns sum in hl
macro AddToHL
    ld a, l
    add a, \1
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
endm

init_level_1_torches:
    InitSprite TORCH_1, TORCH_1_START_X, TORCH_1_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X, TORCH_2_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X, TORCH_3_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X, TORCH_4_START_Y, UNLIT_TORCH_TILE_ID
    ret

init_level_2_torches:
    InitSprite TORCH_1, TORCH_1_START_X_L2, TORCH_1_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X_L2, TORCH_2_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X_L2, TORCH_3_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X_L2, TORCH_4_START_Y_L2, UNLIT_TORCH_TILE_ID
    ret

init_level_3_torches:
    InitSprite TORCH_1, TORCH_1_START_X_L3, TORCH_1_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X_L3, TORCH_2_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X_L3, TORCH_3_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X_L3, TORCH_4_START_Y_L3, UNLIT_TORCH_TILE_ID
    ret
 
; makes the torch flicker
; \1 is the torch sprite ID
macro TorchFlicker
    push af
    ld a, [\1 + OAMA_TILEID]
    cp a, UNLIT_TORCH_TILE_ID
    jr z, .done\@
        ; change between the flickering tileIDs
        inc a
        cp a, END_TORCH_FLICKER_TILE_ID
        jr c, .skip_reset\@
            ld a, START_TORCH_FLICKER_TILE_ID
        .skip_reset\@
        Copy [\1 + OAMA_TILEID], a
    .done\@
    pop af
    endm 

flicker_torches:
    TorchFlicker TORCH_1
    TorchFlicker TORCH_2
    TorchFlicker TORCH_3
    TorchFlicker TORCH_4
    ret

; check all torches (sprites after the doors but before the water?)
; return whichever torch is overlapping in hl
; also returns z if overlapping a torch and nz if not
light_possible:
    push bc
    push de
    ; Get player location
    ld a, [PLAYER_SPRITE + OAMA_X]
    add a, 4
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, FLOATING_OFFSET
    ld c, a

    ; Check each torch to see if overlapping
    Copy d, [TORCH_1 + OAMA_X]
    Copy e, [TORCH_1 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .torch_2
        ld hl, TORCH_1
        jp .done

    .torch_2
    Copy d, [TORCH_2 + OAMA_X]
    Copy e, [TORCH_2 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .torch_3
        ld hl, TORCH_2
        jp .done

    .torch_3
    Copy d, [TORCH_3 + OAMA_X]
    Copy e, [TORCH_3 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jp nz, .torch_4
        ld hl, TORCH_3
        jp .done

    .torch_4
    Copy d, [TORCH_4 + OAMA_X]
    Copy e, [TORCH_4 + OAMA_Y]
    FindOverlappingSprite b, c, d, e
    jr nz, .done
        ld hl, TORCH_4

    .done
    pop de
    pop bc
    ret

; lights a torch if the player is in front of an unlit torch and DOWN is being held
light_torch:
    push hl
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is DOWN being held?
    bit PADB_DOWN, a
    jr nz, .dont_light
        ; Check if player is infront of a torch
        call light_possible
        jr nz, .dont_light
            call torch_light_sound
            AddToHL OAMA_TILEID
            Copy [hl], START_TORCH_FLICKER_TILE_ID

    .dont_light
    pop hl
    ret

; opens door if all torches lit
check_all_torches_lit:
    Copy a, [LEFT_DOOR + OAMA_TILEID]
    cp a, LEFT_DOOR_OPEN_ID
    jr z, .done
        Copy a, [TORCH_1 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_2 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_3 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

        Copy a, [TORCH_4 + OAMA_TILEID]
        cp a, START_TORCH_FLICKER_TILE_ID
        jr c, .done

    call open_door
    .done
    
    ret
    
export init_level_1_torches, init_level_2_torches, init_level_3_torches, light_torch, check_all_torches_lit, flicker_torches