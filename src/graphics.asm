;
; CS-240 World 8: Final Game
;
; @file graphics.asm
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/utils.inc"
include "src/wram.inc"
include "src/graphics.inc"
include "src/sprites.inc"
include "src/timer.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (5)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($4000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)
def TILEMAP_LEVEL_2_START           equ (GRAPHICS_DATA_ADDRESS_END - 3*BYTES_PER_TILEMAP)
def TILEMAP_LEVEL_3_START           equ (GRAPHICS_DATA_ADDRESS_END - 2*BYTES_PER_TILEMAP)
def TILEMAP_GAME_OVER_START         equ (GRAPHICS_DATA_ADDRESS_END - BYTES_PER_TILEMAP)

def WINDOW_GRAPHIC_HEIGHT       equ (40)
def PAUSE_FRAMES                equ (20)
def PAUSE_WINDOW                equ (WINDOW_GRAPHIC_HEIGHT + PAUSE_FRAMES + 1)
def MOVE_WINDOW_DOWN            equ (WINDOW_GRAPHIC_HEIGHT + 1)
def MOVE_WINDOW_UP              equ (WINDOW_GRAPHIC_HEIGHT * 2 + PAUSE_FRAMES)
def WINDOW_OFFSCREEN            equ (140)

def BEGIN_CONGRATS              equ ($9905)
def BLANK_TILE_ID               equ ($0)
def C_TILE_ID                   equ ($42)
def O_TILE_ID                   equ ($4E)
def N_TILE_ID                   equ ($4D)
def G_TILE_ID                   equ ($46)
def R_TILE_ID                   equ ($51)
def A_TILE_ID                   equ ($40)
def T_TILE_ID                   equ ($53)
def S_TILE_ID                   equ ($52)
def BEGIN_START_REPLAY          equ ($99C9)
def E_TILE_ID                   equ ($44)
def P_TILE_ID                   equ ($4F)
def L_TILE_ID                   equ ($4B)
def Y_TILE_ID                   equ ($58)

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

; is start is held, moves the window offscreen and sets b to 1
move_window_offscreen:
    push af
    ; get the joypad buttons that are being held
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

; moves the window off screen
move_window_offscreen_no_start:
    push af
    ld a, WINDOW_OFFSCREEN
    ld [rWY], a
    pop af
    ret
        
load_level_1:
    LoadNewMapDataIntoVRAM GRAPHICS_DATA_ADDRESS_END, TILEMAP_LEVEL_2_START
    ret

load_level_2:
    LoadNewMapDataIntoVRAM TILEMAP_LEVEL_2_START, TILEMAP_LEVEL_3_START
    ret

load_level_3:
    LoadNewMapDataIntoVRAM TILEMAP_LEVEL_3_START, TILEMAP_GAME_OVER_START
    ret

load_game_over:
    LoadNewMapDataIntoVRAM TILEMAP_GAME_OVER_START, GRAPHICS_DATA_ADDRESS_END
    ret

load_congrats_letters:
    push hl
    ; load congrats into the window tilemap
    ld hl, BEGIN_CONGRATS
    ChangeTile BLANK_TILE_ID
    inc hl
    ChangeTile C_TILE_ID
    inc hl
    ChangeTile O_TILE_ID
    inc hl
    ChangeTile N_TILE_ID
    inc hl
    ChangeTile G_TILE_ID
    inc hl
    ChangeTile R_TILE_ID
    inc hl
    ChangeTile A_TILE_ID
    inc hl
    ChangeTile T_TILE_ID
    inc hl
    ChangeTile S_TILE_ID
    inc hl
    ChangeTile BLANK_TILE_ID

    ; load replay into the window tilemap
    ld hl, BEGIN_START_REPLAY
    ChangeTile R_TILE_ID
    inc hl
    ChangeTile E_TILE_ID
    inc hl
    ChangeTile P_TILE_ID
    inc hl
    ChangeTile L_TILE_ID
    inc hl
    ChangeTile A_TILE_ID
    inc hl
    ChangeTile Y_TILE_ID
    pop hl
    ret

; sets z flag if player is hiding
check_end_screen:
    ld a, c
    cp a, GAME_OVER
    ret

; Check if A is pressed after player has died
check_A_pressed:
    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]
    ; Is A being held?
    bit PADB_A, a
    jr nz, .done
        ; if player is offscreen (dead), restart the game
        call check_end_screen
        jr nz, .done
        
        DisableLCD
        call init_graphics
        EnableLCD

        call move_window_offscreen_no_start

        DisableLCD
        call init_player
        call load_player_into_WRAM
        call init_door
        call init_level_1_torches
        call load_torches_into_WRAM
        call init_waters_1
        call init_spikes_1
        call init_timer
        ld c, 1
        EnableLCD
    .done
    ret

; loads the game over screen and hides the player
game_over:
    ld c, GAME_OVER
    DisableLCD
    call load_game_over
    InitOAM
    Copy [WRAM_PLAYER + SPRITE_X], PLAYER_HIDE_X
    EnableLCD
    ret

; loads the game won screen and hides the player
game_won:
    ld c, GAME_OVER
    call load_game_over
    call load_congrats_letters
    InitOAM
    Copy [WRAM_PLAYER + SPRITE_X], PLAYER_HIDE_X
    ret
    

export move_window_offscreen, load_level_1, load_level_2, load_game_over, check_A_pressed, game_over, count_down, load_level_3, game_won, init_graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_waters.chr"
incbin "assets/level_1.tlm"
incbin "assets/correct_window.tlm"
incbin "assets/level_2.tlm"
incbin "assets/third_level_ladders.tlm"
incbin "assets/game_over_map.tlm"