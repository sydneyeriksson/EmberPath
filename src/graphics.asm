;
; CS-240 World 5: First Draft
;
; @file graphics.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 9, 2025

include "src/utils.inc"
include "src/wram.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (2)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($4000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

def WINDOW_GRAPHIC_HEIGHT       equ (40)
def PAUSE_FRAMES                equ (20)
def PAUSE_WINDOW                equ (WINDOW_GRAPHIC_HEIGHT + PAUSE_FRAMES + 1)
def MOVE_WINDOW_DOWN            equ (WINDOW_GRAPHIC_HEIGHT + 1)
def MOVE_WINDOW_UP              equ (WINDOW_GRAPHIC_HEIGHT * 2 + PAUSE_FRAMES)
def WINDOW_OFFSCREEN            equ (140)

def SPRITE_0_ADDRESS equ (_OAMRAM)

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

; clear the OAM
macro InitOAM
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics", rom0

init_graphics:
    push af
    ; init the palettes
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld a, %10010011
    ld [rOBP1], a

    ; init graphics data
    InitOAM
    LoadGraphicsDataIntoVRAM

    ; enable the vblank interrupt
    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; place the window at the bottom of the LCD
    ld a, 7
    ld [rWX], a
    ld a, 0
    ld [rWY], a

    ; set the background position
    xor a
    ld [rSCX], a
    ld [rSCY], a
    pop af
    ret

move_window_offscreen:
    push af
    halt
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]
    ; Is start being held?
    bit PADB_START, a

    jr nz, .done_moving_window_offscreen
        ; Set the window position to offscreen
        ld a, WINDOW_OFFSCREEN
        ld [rWY], a
        ; Indicate that the window has been moved offscreen
        ld b, 1
    .done_moving_window_offscreen
    pop af
    ret

export init_graphics
export move_window_offscreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_empty_torch.chr"
incbin "assets/tilemap_level_1.tlm"
incbin "assets/window.tlm"