;
; CS-240 World 8: Final Game
;
; @file level_2.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/sprites.inc"
include "src/timer.inc"

def WATER_L2_Y     equ 64
def WATER_1_L2_X   equ 64
def WATER_2_L2_X   equ 72
def WATER_3_L2_X   equ 96
def WATER_4_L2_X   equ 104
def WATER_5_L2_X   equ 0

; L2 spikes
def LARGE_SPIKE_1_L2_X   equ 88
def LARGE_SPIKE_1_L2_Y   equ 136

def LARGE_SPIKE_2_L2_X   equ 112
def LARGE_SPIKE_2_L2_Y   equ 136

def SMALL_SPIKE_1_L2_X   equ 96
def SMALL_SPIKE_1_L2_Y   equ 136

def SMALL_SPIKE_2_L2_X   equ 104
def SMALL_SPIKE_2_L2_Y   equ 136

def SMALL_SPIKE_3_L2_X   equ 120
def SMALL_SPIKE_3_L2_Y   equ 136

; level 2 torches:
def TORCH_1_START_X_L2   equ 152
def TORCH_1_START_Y_L2   equ 48

def TORCH_2_START_X_L2   equ 64
def TORCH_2_START_Y_L2   equ 88

def TORCH_3_START_X_L2   equ 16
def TORCH_3_START_Y_L2   equ 112

def TORCH_4_START_X_L2   equ 152
def TORCH_4_START_Y_L2   equ 112

section "level_2", rom0

init_waters_2:
    InitSprite WATER_1, WATER_1_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L2_X, WATER_L2_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L2_X, WATER_L2_Y, WATER_ID
    ret

init_spikes_2:
    InitSprite LARGE_SPIKE_1, LARGE_SPIKE_1_L2_X, LARGE_SPIKE_1_L2_Y, LARGE_SPIKE_ID
    InitSprite LARGE_SPIKE_2, LARGE_SPIKE_2_L2_X, LARGE_SPIKE_2_L2_Y, LARGE_SPIKE_ID
    InitSprite SMALL_SPIKE_1, SMALL_SPIKE_1_L2_X, SMALL_SPIKE_1_L2_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_2, SMALL_SPIKE_2_L2_X, SMALL_SPIKE_2_L2_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_3, SMALL_SPIKE_3_L2_X, SMALL_SPIKE_3_L2_Y, SMALL_SPIKE_ID
    ret

init_level_2_torches:
    InitSprite TORCH_1, TORCH_1_START_X_L2, TORCH_1_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X_L2, TORCH_2_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X_L2, TORCH_3_START_Y_L2, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X_L2, TORCH_4_START_Y_L2, UNLIT_TORCH_TILE_ID
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

export first_to_second