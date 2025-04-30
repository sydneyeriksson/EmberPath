; 
; CS 240: Storing Joypad state, including pressed/released/etc
; also storing torch values.
;
; @file wram.inc
; @author Darren Strash and CS 240
; @brief a place to store all WRAM variables

include "src/hardware.inc"

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

rsset _RAM
def PAD_CURR                rb 1
def PAD_PREV                rb 1
def PAD_PRSS                rb 1
def PAD_RLSE                rb 1

def WRAM_TORCH                   rl 4
def WRAM_PLAYER             rl 1

RSRESET
def SPRITE_X                    RB 1
def SPRITE_Y                    RB 1
def TILE_ID                     RB 1
def FLAGS                       RB 1
def sizeof_SPRITE_ATTRS         RB 0

endc