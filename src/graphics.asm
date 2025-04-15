;
; CS-240 World 6: First Draft
;
; @file graphics.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 14, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/graphics.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (4)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($4000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)
def TILEMAP_LEVEL_2_START           equ (GRAPHICS_DATA_ADDRESS_END - 2*BYTES_PER_TILEMAP)
def TILEMAP_GAME_OVER_START         equ (GRAPHICS_DATA_ADDRESS_END - BYTES_PER_TILEMAP)

def WINDOW_GRAPHIC_HEIGHT       equ (40)
def PAUSE_FRAMES                equ (20)
def PAUSE_WINDOW                equ (WINDOW_GRAPHIC_HEIGHT + PAUSE_FRAMES + 1)
def MOVE_WINDOW_DOWN            equ (WINDOW_GRAPHIC_HEIGHT + 1)
def MOVE_WINDOW_UP              equ (WINDOW_GRAPHIC_HEIGHT * 2 + PAUSE_FRAMES)
def WINDOW_OFFSCREEN            equ (140)

def SPRITE_0_ADDRESS equ (_OAMRAM)

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

move_window_offscreen_no_start:
    push af
    halt
    ld a, WINDOW_OFFSCREEN
    ld [rWY], a
    pop af
    ret

load_level_2:
    LoadNewMapDataIntoVRAM TILEMAP_LEVEL_2_START, TILEMAP_GAME_OVER_START
    ret

load_game_over:
    LoadNewMapDataIntoVRAM TILEMAP_GAME_OVER_START, GRAPHICS_DATA_ADDRESS_END
    ret

; sets z flag if player is hiding
check_player_hiding:
    ld a, [PLAYER_SPRITE + OAMA_X]
    cp a, PLAYER_HIDE_X
    jr nz, .done
    ld a, [PLAYER_SPRITE + OAMA_Y]
    cp a, PLAYER_HIDE_Y
    .done
    ret

check_A_pressed:
    halt
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]
    ; Is A being held?
    bit PADB_A, a
    jr nz, .done
        call check_player_hiding
        jr nz, .done
        
        DisableLCD
        call init_graphics
        EnableLCD

        call move_window_offscreen_no_start

        DisableLCD
        call init_player
        call init_door
        call init_level_1_torches
        call init_waters
        EnableLCD
    .done
    ret
    
    

export init_graphics
export move_window_offscreen, load_level_2, load_game_over, check_A_pressed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_empty_torch.chr"
incbin "assets/ladder_touching.tlm"
incbin "assets/window.tlm"
incbin "assets/level_2.tlm"
incbin "assets/tilemap_game_over.tlm"