;
; CS-240 World 8: Final Game
;
; @file level_1.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/sprites.inc"
include "src/timer.inc"

def WATER_L1_Y     equ 120
def WATER_1_L1_X   equ 80
def WATER_2_L1_X   equ 88
def WATER_3_L1_X   equ 96
def WATER_4_L1_X   equ 104
def WATER_5_L1_X   equ 112 

; L1 spikes
def LARGE_SPIKE_1_L1_X   equ 32
def LARGE_SPIKE_1_L1_Y   equ 48

def LARGE_SPIKE_2_L1_X   equ 32
def LARGE_SPIKE_2_L1_Y   equ OFF_SCREEN

def SMALL_SPIKE_1_L1_X   equ 40
def SMALL_SPIKE_1_L1_Y   equ 48

def SMALL_SPIKE_2_L1_X   equ 16
def SMALL_SPIKE_2_L1_Y   equ OFF_SCREEN

def SMALL_SPIKE_3_L1_X   equ 8
def SMALL_SPIKE_3_L1_Y   equ OFF_SCREEN

; level 1 torches:
def TORCH_1_START_X   equ 112
def TORCH_1_START_Y   equ 40

def TORCH_2_START_X   equ 152
def TORCH_2_START_Y   equ 72

def TORCH_3_START_X   equ 16
def TORCH_3_START_Y   equ 88

def TORCH_4_START_X   equ 152
def TORCH_4_START_Y   equ 112

section "level_1", rom0

init_waters_1:
    InitSprite WATER_1, WATER_1_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_2, WATER_2_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_3, WATER_3_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_4, WATER_4_L1_X, WATER_L1_Y, WATER_ID
    InitSprite WATER_5, WATER_5_L1_X, WATER_L1_Y, WATER_ID
    ret

init_spikes_1:
    InitSprite LARGE_SPIKE_1, LARGE_SPIKE_1_L1_X, LARGE_SPIKE_1_L1_Y, LARGE_SPIKE_ID
    InitSprite LARGE_SPIKE_2, LARGE_SPIKE_2_L1_X, LARGE_SPIKE_2_L1_Y, LARGE_SPIKE_ID
    InitSprite SMALL_SPIKE_1, SMALL_SPIKE_1_L1_X, SMALL_SPIKE_1_L1_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_2, SMALL_SPIKE_2_L1_X, SMALL_SPIKE_2_L1_Y, SMALL_SPIKE_ID
    InitSprite SMALL_SPIKE_3, SMALL_SPIKE_3_L1_X, SMALL_SPIKE_3_L1_Y, SMALL_SPIKE_ID
    ret

init_level_1_torches:
    InitSprite TORCH_1, TORCH_1_START_X, TORCH_1_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_2, TORCH_2_START_X, TORCH_2_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_3, TORCH_3_START_X, TORCH_3_START_Y, UNLIT_TORCH_TILE_ID
    InitSprite TORCH_4, TORCH_4_START_X, TORCH_4_START_Y, UNLIT_TORCH_TILE_ID
    ret

first_level:
    call init_player
    call init_door
    call init_level_1_torches
    call init_waters_1
    call init_spikes_1
    call init_timer
    inc c
    ret

load_first_level:
    call load_level_1
    call first_level
    ret

export first_level, load_first_level