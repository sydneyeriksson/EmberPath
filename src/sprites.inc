;
; CS-240 World 8: Final Game
;
; @file sprites.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025
; @brief macros to control sprites
; @license Copyright 2025 Asher Kaplan and Sydney Eriksson

if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1

include "src/utils.inc" 
include "src/wram.inc" 
include "src/graphics.inc"

def PLAYER_SPRITE       equ _OAMRAM
def LEFT_DOOR           equ _OAMRAM + sizeof_OAM_ATTRS
def RIGHT_DOOR          equ _OAMRAM + 2*sizeof_OAM_ATTRS
def TORCH_1             equ _OAMRAM + 3*sizeof_OAM_ATTRS
def TORCH_2             equ _OAMRAM + 4*sizeof_OAM_ATTRS
def TORCH_3             equ _OAMRAM + 5*sizeof_OAM_ATTRS
def TORCH_4             equ _OAMRAM + 6*sizeof_OAM_ATTRS
def WATER_1             equ _OAMRAM + 7*sizeof_OAM_ATTRS
def WATER_2             equ _OAMRAM + 8*sizeof_OAM_ATTRS
def WATER_3             equ _OAMRAM + 9*sizeof_OAM_ATTRS
def WATER_4             equ _OAMRAM + 10*sizeof_OAM_ATTRS
def WATER_5             equ _OAMRAM + 11*sizeof_OAM_ATTRS
def ONES_TIMER          equ _OAMRAM + 12*sizeof_OAM_ATTRS
def TENS_TIMER          equ _OAMRAM + 13*sizeof_OAM_ATTRS
def LARGE_SPIKE_1       equ _OAMRAM + 14*sizeof_OAM_ATTRS
def LARGE_SPIKE_2       equ _OAMRAM + 15*sizeof_OAM_ATTRS
def SMALL_SPIKE_1       equ _OAMRAM + 16*sizeof_OAM_ATTRS
def SMALL_SPIKE_2       equ _OAMRAM + 17*sizeof_OAM_ATTRS
def SMALL_SPIKE_3       equ _OAMRAM + 18*sizeof_OAM_ATTRS
def MINUTE_TIMER        equ _OAMRAM + 19*sizeof_OAM_ATTRS
def COLON               equ _OAMRAM + 20*sizeof_OAM_ATTRS

def WRAM_PLAYER_SPRITE  equ WRAM_PLAYER
def WRAM_TORCH_1        equ WRAM_TORCH + 0*sizeof_SPRITE_ATTRS
def WRAM_TORCH_2        equ WRAM_TORCH + 1*sizeof_SPRITE_ATTRS
def WRAM_TORCH_3        equ WRAM_TORCH + 2*sizeof_SPRITE_ATTRS
def WRAM_TORCH_4        equ WRAM_TORCH + 3*sizeof_SPRITE_ATTRS

def PLAYER_HIDE_X       equ 250
def PLAYER_HIDE_Y       equ 250
def FLOATING_OFFSET     equ 4
def NO_JUMP             equ 0

def WATER_ID            equ 86
def END_WATER_TILE_ID   equ 100

def LARGE_SPIKE_ID      equ 15
def SMALL_SPIKE_ID      equ 13
def OFF_SCREEN          equ 0

def LEFT_DOOR_OPEN_ID   equ 46

def UNLIT_TORCH_TILE_ID          equ 50
def START_TORCH_FLICKER_TILE_ID  equ 52
def END_TORCH_FLICKER_TILE_ID    equ 60
def OAMA_NO_FLAGS                equ 0

; make macro to check if sprites are colliding 
; \1 is  x_coordinate for the first sprite
; \2 is  y_coordinate for the first sprite
; \3 is  x_coordinate for the second sprite
; \4 is  y_coordinate for the second sprite
; if colliding, set z flag
macro FindOverlappingSprite
    push bc
    ; calculate what sprite the player_sprite is on
    ; find y vertical row (divide y pixel height by 8)
    ld a, \2
    DivideBy8
    ld h, a

    ld a, \4
    DivideBy8

    cp a, h
    jr nz, .not_overlapping\@

    ; find x horizontal col (divide y pixel height by 8)
    ld a, \1
    DivideBy8
    ld c, a

    ld a, \3
    DivideBy8
    
    cp a, c
    .not_overlapping\@
    pop bc
endm

; \1 is the sprite
; \2 is the sprite start x
; \3 is the sprite start y
; \4 is the sprite tile ID
macro InitSprite
    Copy [\1 + OAMA_X], \2
    Copy [\1 + OAMA_Y], \3
    Copy [\1 + OAMA_TILEID], \4
    Copy [\1 + OAMA_FLAGS], OAMF_PAL1
endm

; \1 is the sprite from WRAM
; \2 is the sprite start x from WRAM
; \3 is the sprite start y from WRAM
; \4 is the sprite tile ID from WRAM
; \5 is the sprite flags from WRAM
macro LoadSpriteData
    Copy [\1 + OAMA_X], \2
    Copy [\1 + OAMA_Y], \3
    Copy [\1 + OAMA_TILEID], \4
    Copy [\1 + OAMA_FLAGS], \5
endm

; \1 is the sprite
; \2 is the sprite start x
; \3 is the sprite start y
; \4 is the sprite tile ID
; \5 is the sprite flags
macro LoadWramData
    Copy [\1 + SPRITE_X], \2
    Copy [\1 + SPRITE_Y], \3
    Copy [\1 + TILE_ID], \4
    Copy [\1 + FLAGS], \5
endm

; \1 is the sprite
; \2 is the sprite start x
; \3 is the sprite start y
; \4 is the sprite tile ID
; \5 is the sprite flags
macro InitSpriteWram
    Copy [\1 + SPRITE_X], \2
    Copy [\1 + SPRITE_Y], \3
    Copy [\1 + TILE_ID], \4
    Copy [\1 + FLAGS], \5
endm

endc