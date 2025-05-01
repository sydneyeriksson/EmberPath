; 
; CS-240 World 8: Final Game
;
; @file wram.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025

include "src/hardware.inc"

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

rsset _RAM
def PAD_CURR                rb 1
def PAD_PREV                rb 1
def PAD_PRSS                rb 1
def PAD_RLSE                rb 1

def WRAM_TORCH              rl 4
def WRAM_PLAYER             rl 1

RSRESET
def SPRITE_X                    RB 1
def SPRITE_Y                    RB 1
def TILE_ID                     RB 1
def FLAGS                       RB 1
def sizeof_SPRITE_ATTRS         RB 0

endc