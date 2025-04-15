;
; CS-240 World 6: First Draft
;
; @file torch.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

def UNLIT_TORCH_TILE_ID          equ 50
def START_TORCH_FLICKER_TILE_ID  equ 52
def END_TORCH_FLICKER_TILE_ID    equ 60
def OAMA_NO_FLAGS                equ 0

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
def TORCH_3_START_Y_L2   equ 128

def TORCH_4_START_X_L2   equ 152
def TORCH_4_START_Y_L2   equ 112

section "torch", rom0

macro InitTorch
    Copy [\1 + OAMA_X], \2
    Copy [\1 + OAMA_Y], \3
    Copy [\1 + OAMA_TILEID], \4
    Copy [\1 + OAMA_FLAGS], OAMF_PAL1
endm

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
    InitTorch TORCH_1, TORCH_1_START_X, TORCH_1_START_Y, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_2, TORCH_2_START_X, TORCH_2_START_Y, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_3, TORCH_3_START_X, TORCH_3_START_Y, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_4, TORCH_4_START_X, TORCH_4_START_Y, UNLIT_TORCH_TILE_ID
    ret

;init_level_2_torches:
init_level_2_torches:
    InitTorch TORCH_1, TORCH_1_START_X_L2, TORCH_1_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_2, TORCH_2_START_X_L2, TORCH_2_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_3, TORCH_3_START_X_L2, TORCH_3_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitTorch TORCH_4, TORCH_4_START_X_L2, TORCH_4_START_Y_L2, UNLIT_TORCH_TILE_ID
    ret
   
; check all torches (sprites after the doors but before the water?)
; return whichever torch is overlapping
light_possible:
    ld a, [PLAYER_SPRITE + OAMA_X]
    ld b, a
    ld a, [PLAYER_SPRITE + OAMA_Y]
    add a, 4
    ld c, a

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
    ret
    
light_torch:
    halt
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is DOWN being held?
    bit PADB_DOWN, a
    jr nz, .dont_light
        call light_possible
        jr nz, .dont_light
            AddToHL OAMA_TILEID
            Copy [hl], START_TORCH_FLICKER_TILE_ID

    .dont_light

    ret

; opens door if all torches lit
check_all_torches_lit:
    halt

    Copy a, [TORCH_1 + OAMA_TILEID]
    cp a, START_TORCH_FLICKER_TILE_ID
    jr nz, .not_lit

    Copy a, [TORCH_2 + OAMA_TILEID]
    cp a, START_TORCH_FLICKER_TILE_ID
    jr nz, .not_lit

    Copy a, [TORCH_3 + OAMA_TILEID]
    cp a, START_TORCH_FLICKER_TILE_ID
    jr nz, .not_lit

    Copy a, [TORCH_4 + OAMA_TILEID]
    cp a, START_TORCH_FLICKER_TILE_ID
    jr nz, .not_lit

    call open_door
    .not_lit
    
    ret
    
export init_level_1_torches, init_level_2_torches, light_torch, check_all_torches_lit