;
; CS-240 World 8: Final Game
;
; @file graphics.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

if !def(GRAPHICS_RGBINC)
def GRAPHICS_RGBINC equ 1

macro DisableLCD
    ; wait for the vblank
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

macro EnableLCD
    ; set the graphics parameters and turn back LCD on
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON| LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [rLCDC], a

endm

; returns a / 8
macro DivideBy8
    srl a
    srl a
    srl a
endm

; returns a * 8
macro MultiplyBy8
    sla a
    sla a
    sla a
endm

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    push de
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
    pop de
endm

; Load the new map into VRAM
; \1 is the start of the new map
; \2 is the end of the new map
macro LoadNewMapDataIntoVRAM
    push de
    ld de, \1
    ld hl, $9800
    ; move hl to the tilemap portion of VRAM
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(\2)
        jr nz, .load_tile\@
    pop de
endm

; \1 is the tile index that we want to place in the tile map
; hl contains the position we want to place the new tile
macro ChangeTile
    ld a, \1
    ld [hl], a
endm

; clear the OAM
macro InitOAM
    push bc
    push de
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
    pop de
    pop bc
endm

endc
