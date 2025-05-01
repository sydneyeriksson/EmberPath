;
; CS-240 World 8: Final Game
;
; @file level_3.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/sprites.inc"
include "src/timer.inc"

def WATER_L3_Y     equ 136
def WATER_1_L3_X   equ 122
def WATER_2_L3_X   equ 130
def WATER_3_L3_X   equ 138
def WATER_4_L3_X   equ 146
def WATER_5_L3_X   equ 0

; L3 spikes
def LARGE_SPIKE_1_L3_X   equ 88
def LARGE_SPIKE_1_L3_Y   equ 24

def LARGE_SPIKE_2_L3_X   equ 40
def LARGE_SPIKE_2_L3_Y   equ 112

def SMALL_SPIKE_1_L3_X   equ 80
def SMALL_SPIKE_1_L3_Y   equ 0

def SMALL_SPIKE_2_L3_X   equ 16
def SMALL_SPIKE_2_L3_Y   equ 112

def SMALL_SPIKE_3_L3_X   equ 32
def SMALL_SPIKE_3_L3_Y   equ 112

; level 3 torches:
def TORCH_1_START_X_L3   equ 96
def TORCH_1_START_Y_L3   equ 96

def TORCH_2_START_X_L3   equ 152
def TORCH_2_START_Y_L3   equ 112

def TORCH_3_START_X_L3   equ 16
def TORCH_3_START_Y_L3   equ 72

def TORCH_4_START_X_L3   equ 64
def TORCH_4_START_Y_L3   equ 64

section "level_3", rom0

init_waters_3:
    InitSprite WATER_1, WATER_1_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L3_X, WATER_L3_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L3_X, WATER_L3_Y, WATER_ID
    ret

init_spikes_3:
    InitSprite LARGE_SPIKE_1, LARGE_SPIKE_1_L3_X, LARGE_SPIKE_1_L3_Y, LARGE_SPIKE_ID
    InitSprite LARGE_SPIKE_2, LARGE_SPIKE_2_L3_X, LARGE_SPIKE_2_L3_Y, LARGE_SPIKE_ID
    InitSprite SMALL_SPIKE_1, SMALL_SPIKE_1_L3_X, SMALL_SPIKE_1_L3_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_2, SMALL_SPIKE_2_L3_X, SMALL_SPIKE_2_L3_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_3, SMALL_SPIKE_3_L3_X, SMALL_SPIKE_3_L3_Y, SMALL_SPIKE_ID
    ret

init_level_3_torches:
    InitSprite TORCH_1, TORCH_1_START_X_L3, TORCH_1_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X_L3, TORCH_2_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X_L3, TORCH_3_START_Y_L3, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X_L3, TORCH_4_START_Y_L3, UNLIT_TORCH_TILE_ID
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

export second_to_third