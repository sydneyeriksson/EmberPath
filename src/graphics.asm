; build with
; make

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

def WINDOW_GRAPHIC_HEIGHT       equ(40)
def PAUSE_FRAMES                equ(20)
def PAUSE_WINDOW                equ(WINDOW_GRAPHIC_HEIGHT + PAUSE_FRAMES + 1)
def MOVE_WINDOW_DOWN            equ(WINDOW_GRAPHIC_HEIGHT + 1)
def MOVE_WINDOW_UP              equ(WINDOW_GRAPHIC_HEIGHT * 2 + PAUSE_FRAMES)

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
    ; init the palettes
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld a, %00011011
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

    ret

move_window_offscreen:
    halt

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is start being held?
    bit PADB_START, a
    jr nz, .done_moving_window_offscreen
        ; Set the window position to offscreen
        ld a, 140
        ld [rWY], a

        ; Indicate that the window has been moved offscreen
        ld b, 1
    .done_moving_window_offscreen
    ret

export init_graphics
export move_window_offscreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset.chr"
incbin "assets/tilemap.tlm"
incbin "assets/fireboy_watergirl_window.tlm"

;
; CS-240 World 4: Moving window and assets
;
; @file graphics.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date March 12, 2025


; def TILES_COUNT                 equ (384)
; def BYTES_PER_TILE              equ (16)
; def TILES_BYTE_SIZE             equ (TILES_COUNT * BYTES_PER_TILE)
; def TILEMAPS_COUNT              equ (2)
; def BYTES_PER_TILEMAP           equ (1024)
; def TILEMAPS_BYTE_SIZE          equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)
; def GRAPHICS_DATA_SIZE          equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
; def GRAPHICS_DATA_ADDRESS_END   equ ($8000)
; def GRAPHICS_DATA_ADDRESS_START \
;     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)
; def WINDOW_GRAPHIC_HEIGHT       equ(40)
; def PAUSE_FRAMES                equ(20)
; def PAUSE_WINDOW                equ(WINDOW_GRAPHIC_HEIGHT + PAUSE_FRAMES + 1)
; def MOVE_WINDOW_DOWN            equ(WINDOW_GRAPHIC_HEIGHT + 1)
; def MOVE_WINDOW_UP              equ(WINDOW_GRAPHIC_HEIGHT * 2 + PAUSE_FRAMES)

; section "vblank_interrupt", rom0[$0040]
;     reti

; section "graphics_functions", rom0

; macro LoadGraphicsIntoVRAM
;     ld de, GRAPHICS_DATA_ADDRESS_START
;     ld hl, _VRAM8000
;     .load\@
;         ld a, [de]
;         inc de
;         ld [hli], a
;         ld a, d
;         cp a, high(GRAPHICS_DATA_ADDRESS_END)
;         jr nz, .load\@
; endm

; init_graphics:

;     ld a, %11100100
;     ld [rBGP], a

;     LoadGraphicsIntoVRAM

;     ld a, IEF_VBLANK
;     ld [rIE], a
;     ei

;     ld a, 7
;     ld [rWX], a
;     ld a, 140
;     ld [rWY], a

;     ; turn the LCD on
;     ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
;     ld [rLCDC], a
;     ret

; move_window_offscreen:
;     ; Move the window every 5 frames
;     halt
;     dec b
;     jr nz, .end

;     ; For the first 200 frames, move the window onscreen
;     ld a, c
;     cp a, PAUSE_WINDOW
;     jr c, .pause
;         ld a, [rWY]
;         dec a
;         ld [rWY], a
;         jr .all
    
;     ; For the next 100 frames, don't move the window, 
;     ;   then for the next 200 frames, move the window offscreen
;     .pause
;     cp a, MOVE_WINDOW_DOWN
;     jr nc, .all
;         ld a, [rWY]
;         inc a
;         ld [rWY], a
    
;     .all
;     dec c
;     jr nz, .skip_reset_c
;         ld c, MOVE_WINDOW_UP

;     .skip_reset_c
;     ld b, 5

;     .end
;     ret

; export init_graphics
; export move_window_offscreen

; section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
; incbin "assets/tileset.chr"
; incbin "assets/fireboy_watergirl_background.tlm"
; incbin "assets/fireboy_watergirl_window.tlm"