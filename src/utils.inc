;
; CS-240 World 8: Final Game
;
; @file utils.inc
; @authors Asher Kaplan and Sydney Eriksson
; @date April 30, 2025
; @brief utility macros
; @license Copyright 2025 Asher Kaplan and Sydney Eriksson

if !def(UTILS_RGBINC)
def UTILS_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "src/hardware.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Copy \2 into \1 through (a)
; example: Copy [$FF84], 10
macro Copy
    ld a, \2
    ld \1, a
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc

