; 
; CS 240: Storing Joypad state, including pressed/released/etc
; also storing torch values.
;
; @file wram.inc
; @author Darren Strash and CS 240
; @brief a place to store all WRAM variables

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

rsset _RAM
def PAD_CURR        rb 1
def PAD_PREV        rb 1
def PAD_PRSS        rb 1
def PAD_RLSE        rb 1

def LEVEL_1_TORCHES rl 3
def LEVEL_2_TORCHES rl 3
def LEVEL_3_TORCHES rl 3 

RSRESET
def TORCH_X             RB 1
def TORCH_Y             RB 1
def TORCH_ID            RB 1
def sizeof_TORCH_ATTRS  RB 0

endc
